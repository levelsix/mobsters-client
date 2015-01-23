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

#define DAY_VIEW_ORIGIN -1
#define DAY_VIEW_SPACING 1

#import "DailyEventScheduleViewController.h"
#import "PersistentEventProto+Time.h"

#import "GameState.h"

@implementation EventScheduleDayView

- (void) initWithEvent:(PersistentEventProto*)event {
  MSDate *date = [MSDate date];
  NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date.relativeNSDate];
  NSInteger today = [comps weekday];
  
  if (event.type == PersistentEventProto_EventTypeEnhance) {
    switch (event.monsterElement) {
      case ElementFire:
        self.characterImage.image = [UIImage imageNamed:FIRE_KID];
        self.background.image = [UIImage imageNamed:FIRE_BG];
        break;
      case ElementEarth:
        self.characterImage.image = [UIImage imageNamed:EARTH_KID];
        self.background.image = [UIImage imageNamed:EARTH_BG];
        break;
      case ElementLight:
        self.characterImage.image = [UIImage imageNamed:LIGHT_KID];
        self.background.image = [UIImage imageNamed:LIGHT_BG];
        break;
      case ElementDark:
        self.characterImage.image = [UIImage imageNamed:NIGHT_KID];
        self.background.image = [UIImage imageNamed:NIGHT_BG];
        break;
      case ElementWater:
        self.characterImage.image = [UIImage imageNamed:WATER_KID];
        self.background.image = [UIImage imageNamed:WATER_BG];
      default:
        break;
    }
  } else if (event.type == PersistentEventProto_EventTypeEvolution) {
    switch (event.monsterElement) {
      case ElementFire:
        self.characterImage.image = [UIImage imageNamed:FIRE_SCIENTIST];
        self.background.image = [UIImage imageNamed:FIRE_BG];
        break;
      case ElementEarth:
        self.characterImage.image = [UIImage imageNamed:EARTH_SCIENTIST];
        self.background.image = [UIImage imageNamed:EARTH_BG];
        break;
      case ElementDark:
        self.characterImage.image = [UIImage imageNamed:NIGHT_SCIENTIST];
        self.background.image = [UIImage imageNamed:NIGHT_BG];
        break;
      case ElementLight:
        self.characterImage.image = [UIImage imageNamed:LIGHT_SCIENTIST];
        self.background.image = [UIImage imageNamed:LIGHT_BG];
        break;
        case ElementWater:
        self.characterImage.image = [UIImage imageNamed:WATER_SCIENTIST];
        self.background.image = [UIImage imageNamed:WATER_BG];
        
      default:
        break;
    }
  }
  if(event.dayOfWeek != today) {
    self.alpha = 0.5f;
    if((event.dayOfWeek == DayOfWeekSaturday && today != DayOfWeekSunday) || event.dayOfWeek == DayOfWeekSunday) {
      //greyout
      self.background.image = [UIImage imageNamed:GREY_BG];
    }
  } else {
    self.alpha = 1.f;
    self.day.text = @"TODAY";
  }
}

@end


@implementation DailyEventScheduleView

- (void) initWithEventList:(NSArray*)eventList {
  //for each event create the view for it
  for (int i = 0; i<eventList.count; i++) {
    EventScheduleDayView *dayView = (EventScheduleDayView*) [[NSBundle mainBundle] loadNibNamed:@"EventScheduleDayView" owner:self options:nil][0];
    [self addSubview:dayView];
    CGFloat newX = DAY_VIEW_ORIGIN + (dayView.width * i) + DAY_VIEW_SPACING;
    [dayView setOrigin:CGPointMake(newX, 0.f)];
    [dayView initWithEvent:eventList[i]];
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



