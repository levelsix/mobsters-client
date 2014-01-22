//
//  PersistentEventProto+Time.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/21/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PersistentEventProto+Time.h"
#import "GameState.h"

@implementation PersistentEventProto (Time)

- (NSDate *) startTime {
  NSDate *date = [NSDate date];
  NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
  int weekday = [comps weekday];
  int hour = [comps hour];
  int minute = [comps minute];
  
  int cur1 = weekday*1440+hour*60+minute;
  
  int startVal1 = self.dayOfWeek*1440+self.startHour*60;
  int endVal1 = startVal1+self.eventDurationMinutes;
  int startVal2 = startVal1+10080;
  
  int diff = 0;
  if (endVal1 > cur1) {
    diff = startVal1-cur1;
  } else {
    diff = startVal2-cur1;
  }
  
  int64_t ti = date.timeIntervalSince1970;
  ti = ti-ti%60;
  ti += diff;
  NSDate *start = [NSDate dateWithTimeIntervalSince1970:ti];
  return start;
}

- (NSDate *) endTime {
  return [self.startTime dateByAddingTimeInterval:self.eventDurationMinutes*60];
}

- (NSDate *) cooldownEndTime {
  GameState *gs = [GameState sharedGameState];
  NSDate *date = gs.eventCooldownTimes[@(self.eventId)];
  return [date dateByAddingTimeInterval:self.cooldownMinutes*60];
}

- (BOOL) isRunning {
  NSDate *date = [NSDate date];
  if ([self.startTime compare:date] != NSOrderedDescending &&
      [self.endTime compare:date] == NSOrderedDescending) {
    return YES;
  }
  return NO;
}

@end
