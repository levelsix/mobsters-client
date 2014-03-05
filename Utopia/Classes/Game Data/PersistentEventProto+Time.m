//
//  PersistentEventProto+Time.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/21/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PersistentEventProto+Time.h"
#import "GameState.h"

NSDate* startTime(int dayOfWeek, int startHour, int durationMinutes);

@implementation PersistentEventProto (Time)

- (NSDate *) startTime {
  return startTime(self.dayOfWeek, self.startHour, self.eventDurationMinutes);
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

@implementation PersistentClanEventProto (Time)

- (NSDate *) startTime {
  return startTime(self.dayOfWeek, self.startHour, self.eventDurationMinutes);
}

- (NSDate *) endTime {
  return [self.startTime dateByAddingTimeInterval:self.eventDurationMinutes*60];
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

@implementation PersistentClanEventClanInfoProto (Time)

- (ClanRaidStageProto *) currentStage {
  GameState *gs = [GameState sharedGameState];
  ClanRaidProto *raid = [gs raidWithId:self.clanRaidId];
  ClanRaidStageProto *stage = [raid stageWithId:self.clanRaidStageId];
  return stage;
}

- (ClanRaidStageMonsterProto *) currentMonster {
  ClanRaidStageProto *stage = [self currentStage];
  ClanRaidStageMonsterProto *mon = [stage monsterWithId:self.crsmId];
  return mon;
}

- (float) percentOfStageComplete {
  GameState *gs = [GameState sharedGameState];
  ClanRaidStageProto *stage = [self currentStage];
  
  int totalHealth = 0;
  for (ClanRaidStageMonsterProto *mon in stage.monstersList) {
    totalHealth += mon.monsterHp;
  }
  
  int completedDmg = 0;
  for (PersistentClanEventUserInfoProto *userInfo in gs.curClanRaidUserInfos) {
    completedDmg += userInfo.crsDmgDone + userInfo.crsmDmgDone;
  }
  
  return completedDmg/(float)totalHealth; 
}

- (int) curHealthOfActiveStageMonster {
  GameState *gs = [GameState sharedGameState];
  int completedDmg = 0;
  for (PersistentClanEventUserInfoProto *userInfo in gs.curClanRaidUserInfos) {
    completedDmg += userInfo.crsmDmgDone;
  }
  return self.currentMonster.monsterHp-completedDmg;
}

- (float) raidContributionForUserInfo:(PersistentClanEventUserInfoProto *)userInfo {
  GameState *gs = [GameState sharedGameState];
  int totalDmgDealt = 0;
  for (PersistentClanEventUserInfoProto *userInfo in gs.curClanRaidUserInfos) {
    totalDmgDealt += userInfo.crDmgDone+userInfo.crsDmgDone+userInfo.crsmDmgDone;
  }
  
  int thisUserDmg = userInfo.crDmgDone+userInfo.crsDmgDone+userInfo.crsmDmgDone;
  return thisUserDmg/(float)totalDmgDealt;
}

- (NSDate *) stageEndTime {
  ClanRaidStageProto *stage = [self currentStage];
  NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.stageStartTime/1000.];
  return [date dateByAddingTimeInterval:stage.durationMinutes*60];
}

@end

NSDate *startTime(int dayOfWeek, int startHour, int durationMinutes) {
  NSDate *date = [NSDate date];
  NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
  int weekday = [comps weekday];
  int hour = [comps hour];
  int minute = [comps minute];
  
  int cur1 = weekday*1440+hour*60+minute;
  
  int startVal1 = dayOfWeek*1440+startHour*60;
  int endVal1 = startVal1+durationMinutes;
  int startVal2 = startVal1+10080;
  int startVal0 = startVal1-10080;
  int endVal0 = endVal1-10080;
  
  int diff = 0;
  if (endVal0 > cur1) {
    diff = startVal0-cur1;
  } else if (endVal1 > cur1) {
    diff = startVal1-cur1;
  } else {
    diff = startVal2-cur1;
  }
  
  int64_t ti = date.timeIntervalSince1970;
  ti = ti-ti%60;
  ti += diff*60;
  NSDate *start = [NSDate dateWithTimeIntervalSince1970:ti];
  return start;
}
