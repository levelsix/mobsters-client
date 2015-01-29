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
#define DAY_VIEW_SPACING 2

#define SECONDS_IN_A_DAY 86400

#import "DailyEventScheduleViewController.h"
#import "PersistentEventProto+Time.h"

#import "GameState.h"

@implementation EventScheduleDayView

- (void) initMissingEventWithType:(PersistentEventProto_EventType)eventType {
  self.detailA.hidden = NO;
  self.detailB.hidden = YES;
  self.detailC.hidden = YES;
  self.detailD.hidden = YES;
  
  self.detailA.text = @"NO EVENT";
  
  [self setTextColorToHex:GREY];
  
  if(eventType == PersistentEventProto_EventTypeEnhance) {
    [Globals imageNamed:FIRE_KID withView:self.characterImage maskedColor:[UIColor colorWithHexString:GREY] indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:NO];
  } else if (eventType == PersistentEventProto_EventTypeEvolution) {
    [Globals imageNamed:FIRE_SCIENTIST withView:self.characterImage maskedColor:[UIColor colorWithHexString:GREY] indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:NO];
  }
  
}

- (void) initWithEventList:(NSArray *)eventList {
  //timers are hidden unless there are multiple events in the day
  self.detailA.hidden = YES;
  self.detailB.hidden = YES;
  self.detailC.hidden = YES;
  self.detailD.hidden = YES;
  
  //calender for all the time calculations
  NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  
  
  
  //assuming that these is at least a single event active or otherwise
  //the first event is just used to initialize the visuals
  PersistentEventProto *event = eventList[0];
  
  MSDate *date = [MSDate date];
  
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
    switch (event.monsterElement) {
      case ElementFire:
        self.characterImage.image = [Globals imageNamed:FIRE_KID];
        self.background.image = [Globals imageNamed:FIRE_BG];
        [self setTextColorToHex:RED];
        break;
      case ElementEarth:
        self.characterImage.image = [Globals imageNamed:EARTH_KID];
        self.background.image = [Globals imageNamed:EARTH_BG];
        [self setTextColorToHex:GREEN];
        break;
      case ElementLight:
        self.characterImage.image = [Globals imageNamed:LIGHT_KID];
        self.background.image = [Globals imageNamed:LIGHT_BG];
        [self setTextColorToHex:YELLOW];
        break;
      case ElementDark:
        self.characterImage.image = [Globals imageNamed:NIGHT_KID];
        self.background.image = [Globals imageNamed:NIGHT_BG];
        [self setTextColorToHex:PURPLE];
        break;
      case ElementWater:
        self.characterImage.image = [Globals imageNamed:WATER_KID];
        self.background.image = [Globals imageNamed:WATER_BG];
        [self setTextColorToHex:BLUE];
      default:
        break;
    }
    
    //show times for all events
    for (int i = 0; i < eventList.count; i++) {
      UILabel *curLabel;
      switch (i) {
        case 0:
          curLabel = _detailA;
          break;
        case 1:
          curLabel = _detailB;
          break;
        case 2:
          curLabel = _detailC;
          break;
        case 3:
          curLabel = _detailD;
          break;
        default:
          break;
      }
      
      if(curLabel) {
        PersistentEventProto *curEvent = eventList[i];
        curLabel.hidden = NO;
        MSDate *eventStart = curEvent.startTime;
        NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"ha"];
        NSString *formattedDateString = [dateFormatter stringFromDate:eventStart.relativeNSDate];
        
        NSDateComponents *tempComp = [[NSDateComponents alloc] init];
        tempComp.hour = curEvent.eventDurationMinutes/60;
        
        NSDate *endDate = [calendar dateByAddingComponents:tempComp toDate:eventStart.relativeNSDate options:0];
        NSString *endTime = [dateFormatter stringFromDate:endDate];
        
        curLabel.text = [NSString stringWithFormat:@"%@-%@", formattedDateString, endTime];
      }
    }
    
  } else if (event.type == PersistentEventProto_EventTypeEvolution) {
    switch (event.monsterElement) {
      case ElementFire:
        self.characterImage.image = [Globals imageNamed:FIRE_SCIENTIST];
        self.background.image = [Globals imageNamed:FIRE_BG];
        [self setTextColorToHex:RED];
        break;
      case ElementEarth:
        self.characterImage.image = [Globals imageNamed:EARTH_SCIENTIST];
        self.background.image = [Globals imageNamed:EARTH_BG];
        [self setTextColorToHex:GREEN];
        break;
      case ElementDark:
        self.characterImage.image = [Globals imageNamed:NIGHT_SCIENTIST];
        self.background.image = [Globals imageNamed:NIGHT_BG];
        [self setTextColorToHex:PURPLE];
        break;
      case ElementLight:
        self.characterImage.image = [Globals imageNamed:LIGHT_SCIENTIST];
        self.background.image = [Globals imageNamed:LIGHT_BG];
        [self setTextColorToHex:YELLOW];
        break;
        case ElementWater:
        self.characterImage.image = [Globals imageNamed:WATER_SCIENTIST];
        self.background.image = [Globals imageNamed:WATER_BG];
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
      self.detailA.text = @"MYSTERY";
      self.detailB.text = @"MYSTERY";
      self.detailC.text = @"MYSTERY";
      self.detailD.text = @"MYSTERY";
      if(event.type == PersistentEventProto_EventTypeEnhance) {
        [Globals imageNamed:FIRE_KID withView:self.characterImage maskedColor:[UIColor colorWithHexString:GREY] indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:NO];
      } else if (event.type == PersistentEventProto_EventTypeEvolution) {
        [Globals imageNamed:FIRE_SCIENTIST withView:self.characterImage maskedColor:[UIColor colorWithHexString:GREY] indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:NO];
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
  self.detailD.textColor = [UIColor colorWithHexString:hex];
}

@end


@implementation DailyEventScheduleView

- (void) initWithEventList:(NSArray*)eventList {
  NSMutableDictionary *dictByDays = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                     [[NSMutableArray alloc] init], @(DayOfWeekSunday),
                                     [[NSMutableArray alloc] init], @(DayOfWeekMonday),
                                     [[NSMutableArray alloc] init], @(DayOfWeekTuesday),
                                     [[NSMutableArray alloc] init], @(DayOfWeekWednesday),
                                     [[NSMutableArray alloc] init], @(DayOfWeekThursday),
                                     [[NSMutableArray alloc] init], @(DayOfWeekFriday),
                                     [[NSMutableArray alloc] init], @(DayOfWeekSaturday),
                                     nil];
  
  //for each event create the view for it
  //bucket sort by day
  for (int i = 0; i<eventList.count; i++) {
    PersistentEventProto *event = eventList[i];
    NSMutableArray *dayArray = [dictByDays objectForKey:@(event.dayOfWeek)];
    [dayArray addObject:eventList[i]];
  }
  
  for(int i = (int)DayOfWeekSunday; i <= (int)DayOfWeekSaturday; i++) {
    [self createDayViewWithEventList:[dictByDays objectForKey:@(i)] AndDayNumber:i];
  }
  NSString *description = @"";
  NSString *Title = @"";
  PersistentEventProto *firstEvent = eventList[0];
  if(firstEvent.type == PersistentEventProto_EventTypeEnhance) {
    description = @"The Cake Kid element schedule repeats every Monday-Friday.  \nSaturday and Sunday are revealed when the event goes live.";
    Title = @"HOW CAKE KID EVENTS WORK";
  } else if (firstEvent.type == PersistentEventProto_EventTypeEvolution) {
    description = @"The Scientist event schedule repeats every Monday-Friday.  \nSaturday and Sunday are revealed when the event goes live.";
    Title = @"HOW SCIENTIST EVENTS WORK";
  }
  
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  [paragraphStyle setLineSpacing:4];
  [paragraphStyle setAlignment:NSTextAlignmentLeft];
  NSMutableAttributedString *descriptionString = [[NSMutableAttributedString alloc] initWithString:description attributes:@{NSParagraphStyleAttributeName : paragraphStyle}];
  self.descriptionLabel.attributedText = descriptionString;
  
  NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:Title attributes:@{NSParagraphStyleAttributeName : paragraphStyle}];
  self.typeTitleLabel.attributedText = titleString;
}

- (void) createDayViewWithEventList:(NSArray*)eventList AndDayNumber:(int)dayNumber {
    int offSetDayNumber = dayNumber - 2;//-2 for enum off set. so we start at 0s
    if( dayNumber == DayOfWeekSunday) {
      offSetDayNumber = DayOfWeekSaturday - 1; //sunday needs to appear after saturday, not before monday
    }
  
  EventScheduleDayView *dayView = (EventScheduleDayView*) [[NSBundle mainBundle] loadNibNamed:@"EventScheduleDayView" owner:self options:nil][0];
  [self.weekView addSubview:dayView];
  CGFloat newX = DAY_VIEW_ORIGIN + (dayView.width * (offSetDayNumber)) + (DAY_VIEW_SPACING * (offSetDayNumber));
  [dayView setOrigin:CGPointMake(newX, 0.f)];
  [dayView initWithEventList:eventList];
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
  
  if (eventType == PersistentEventProto_EventTypeEvolution) {
    self.title = @"Scientist Schedule";
  } else if (eventType == PersistentEventProto_EventTypeEnhance) {
    self.title = @"Cake Kid Schedule";
  }
  
  [self.dailyEventScheduleView initWithEventList:eventList];
}

@end



