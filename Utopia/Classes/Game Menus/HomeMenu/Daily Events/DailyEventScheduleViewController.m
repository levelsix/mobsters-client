//
//  DailyEventScheduleViewController.m
//  Utopia
//
//  Created by Kenneth Cox on 1/22/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#define EARTH_BG @"earthcal.png"
#define FIRE_BG @"firecal.png"
#define GREY_BG @"greycal.png"
#define LIGHT_BG @"lightcal.png"
#define NIGHT_BG @"nightcal.png"
#define WATER_BG @"watercal.png"

#define EARTH_KID @"earthcakekid.png"
#define FIRE_KID @"firecakekid.png"
#define LIGHT_KID @"lightcakekid.png"
#define NIGHT_KID @"nightcakekid.png"
#define WATER_KID @"watercakekid.png"

#define EARTH_SCIENTIST @"earthscientisteventguy.png"
#define FIRE_SCIENTIST @"firescientisteventguy.png"
#define LIGHT_SCIENTIST @"lightscientisteventguy.png"
#define NIGHT_SCIENTIST @"nightscientisteventguy.png"
#define WATER_SCIENTIST @"waterscientisteventguy.png"

#define GREEN @"42a500"
#define RED @"ff3822"
#define YELLOW @"ff8a2c"
#define PURPLE @"582bff"
#define BLUE @"10adff"
#define GREY @"434343"

#define DAY_VIEW_ORIGIN -1
#define DAY_VIEW_SPACING 1

#define SECONDS_IN_A_DAY 86400

#import "DailyEventScheduleViewController.h"
#import "PersistentEventProto+Time.h"

#import "GameState.h"

@implementation EventScheduleDayView

- (void) initWithEvent:(PersistentEventProto*)event {
  MSDate *date = [MSDate date];
  NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  
  //get the current weekday
  NSDateComponents *weekComps = [gregorian components:NSCalendarUnitWeekday|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date.relativeNSDate];
  NSInteger today = [weekComps weekday];
  
  NSInteger dayOffset;
  if (event.dayOfWeek != DayOfWeekSunday) {
    dayOffset = event.dayOfWeek - today;
  } else {
    dayOffset = (DayOfWeekSaturday + 1) - today;
  }
  
  //get numerical day for this event base on how far we are from the current day
  MSDate *offSetDate = [date dateByAddingTimeInterval:(dayOffset * SECONDS_IN_A_DAY)];
  NSDateComponents *components = [gregorian components:NSCalendarUnitDay|NSCalendarUnitMonth fromDate:offSetDate.relativeNSDate];
  NSInteger day = [components day];
  NSInteger month = [components month];
  self.date.text = [NSString stringWithFormat:@"%ld/%ld", (long)month ,(long)day];
  
  switch (event.dayOfWeek) {
    case DayOfWeekSunday:
      self.day.text = @"SUN";
      break;
    case DayOfWeekMonday:
      self.day.text= @"MON";
      break;
    case DayOfWeekTuesday:
      self.day.text = @"TUE";
      break;
    case DayOfWeekWednesday:
      self.day.text = @"WED";
      break;
    case DayOfWeekThursday:
      self.day.text = @"THUR";
      break;
    case DayOfWeekFriday:
      self.day.text = @"FRI";
      break;
    case DayOfWeekSaturday:
      self.day.text = @"SAT";
      break;
      
    default:
      break;
  }
  
  if (event.type == PersistentEventProto_EventTypeEnhance) {
    self.detailA.hidden = NO;
    self.detailB.hidden = NO;
    self.detailC.hidden = NO;
    switch (event.monsterElement) {
      case ElementFire:
        self.characterImage.image = [UIImage imageNamed:FIRE_KID];
        self.background.image = [UIImage imageNamed:FIRE_BG];
        [self setTextColorToHex:RED];
        break;
      case ElementEarth:
        self.characterImage.image = [UIImage imageNamed:EARTH_KID];
        self.background.image = [UIImage imageNamed:EARTH_BG];
        [self setTextColorToHex:GREEN];
        break;
      case ElementLight:
        self.characterImage.image = [UIImage imageNamed:LIGHT_KID];
        self.background.image = [UIImage imageNamed:LIGHT_BG];
        [self setTextColorToHex:YELLOW];
        break;
      case ElementDark:
        self.characterImage.image = [UIImage imageNamed:NIGHT_KID];
        self.background.image = [UIImage imageNamed:NIGHT_BG];
        [self setTextColorToHex:PURPLE];
        break;
      case ElementWater:
        self.characterImage.image = [UIImage imageNamed:WATER_KID];
        self.background.image = [UIImage imageNamed:WATER_BG];
        [self setTextColorToHex:BLUE];
      default:
        break;
    }
  } else if (event.type == PersistentEventProto_EventTypeEvolution) {
    self.detailA.hidden = YES;
    self.detailB.hidden = YES;
    self.detailC.hidden = YES;
    switch (event.monsterElement) {
      case ElementFire:
        self.characterImage.image = [UIImage imageNamed:FIRE_SCIENTIST];
        self.background.image = [UIImage imageNamed:FIRE_BG];
        [self setTextColorToHex:RED];
        break;
      case ElementEarth:
        self.characterImage.image = [UIImage imageNamed:EARTH_SCIENTIST];
        self.background.image = [UIImage imageNamed:EARTH_BG];
        [self setTextColorToHex:GREEN];
        break;
      case ElementDark:
        self.characterImage.image = [UIImage imageNamed:NIGHT_SCIENTIST];
        self.background.image = [UIImage imageNamed:NIGHT_BG];
        [self setTextColorToHex:PURPLE];
        break;
      case ElementLight:
        self.characterImage.image = [UIImage imageNamed:LIGHT_SCIENTIST];
        self.background.image = [UIImage imageNamed:LIGHT_BG];
        [self setTextColorToHex:YELLOW];
        break;
        case ElementWater:
        self.characterImage.image = [UIImage imageNamed:WATER_SCIENTIST];
        self.background.image = [UIImage imageNamed:WATER_BG];
        [self setTextColorToHex:BLUE];
        
      default:
        break;
    }
  }
  
  //set display for hidden or inactive events
  if(event.dayOfWeek != today) {
    self.alpha = 0.37f;
    if((event.dayOfWeek == DayOfWeekSaturday && today != DayOfWeekSunday) || event.dayOfWeek == DayOfWeekSunday) {
      //greyout
      self.background.image = [UIImage imageNamed:GREY_BG];
      [self setTextColorToHex:GREY];
      if(event.type == PersistentEventProto_EventTypeEnhance) {
        self.characterImage.image = [UIImage imageNamed:FIRE_KID];
      } else if (event.type == PersistentEventProto_EventTypeEvolution) {
        self.characterImage.image = [UIImage imageNamed:FIRE_SCIENTIST];
      }
    }
  } else {
    self.alpha = 1.f;
    self.date.text = @"TODAY";
  }
  
  //resize the height so that we can place the sprite on the base of the view
  float targetHeight = self.characterImage.size.height;
  self.characterImage.size = CGSizeMake(self.characterImage.size.width, targetHeight);
  
  
}

- (void) setTextColorToHex:(NSString *)hex {
  self.date.textColor = [UIColor colorWithHexString:hex];
  self.day.textColor = [UIColor colorWithHexString:hex];
  self.detailA.textColor = [UIColor colorWithHexString:hex];
  self.detailB.textColor = [UIColor colorWithHexString:hex];
  self.detailC.textColor = [UIColor colorWithHexString:hex];
}

@end


@implementation DailyEventScheduleView

- (void) initWithEventList:(NSArray*)eventList {
  //for each event create the view for it
  for (int i = 0; i<eventList.count; i++) {
    EventScheduleDayView *dayView = (EventScheduleDayView*) [[NSBundle mainBundle] loadNibNamed:@"EventScheduleDayView" owner:self options:nil][0];
    [self.weekView addSubview:dayView];
    CGFloat newX = DAY_VIEW_ORIGIN + (dayView.width * i) + (DAY_VIEW_SPACING * i);
    [dayView setOrigin:CGPointMake(newX, 0.f)];
    [dayView initWithEvent:eventList[i]];
    
    NSString *description = @"The Scientist event schedule repeats every Monday-Friday.  Saturday and Sunday are revealed when the event goes live.";
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:4];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:description attributes:@{NSParagraphStyleAttributeName : paragraphStyle}];
    self.descriptionLabel.attributedText = attributedString;
  }
}

@end

@implementation DailyEventScheduleViewController

- (void) initWithEventType:(PersistentEventProto_EventType)eventType {
  //get all events of correct type
  GameState *gs = [GameState sharedGameState];
  NSArray *allEvents = gs.persistentEvents;
  NSMutableArray *eventList = [[NSMutableArray alloc] init];
  for (PersistentEventProto *event in allEvents) {
    if(event.type == eventType) {
      [eventList addObject:event];
    }
  }
  
  [self.dailyEventScheduleView initWithEventList:eventList];
}

@end



