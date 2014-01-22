//
//  HospitalQueueSimulator.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/13/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "HospitalQueueSimulator.h"
#import "GameState.h"

#define SimLog(...) //LNLog(__VA_ARGS__)

@implementation HospitalSim

- (id) initWithHospital:(UserStruct *)hospital {
  if ((self = [super init])) {
    self.healthPerSecond = ((HospitalProto *)hospital.staticStruct).healthPerSecond;
    self.upgradeCompleteDate = !hospital.isComplete ? hospital.buildCompleteDate : nil;
    self.userStructId = hospital.userStructId;
  }
  return self;
}

- (NSString *) description {
  return [NSString stringWithFormat:@"Hospital: %d, %@, %f", self.userStructId, self.upgradeCompleteDate, self.healthPerSecond];
}

@end

@implementation HealingItemSim

- (id) initWithHealingItem:(UserMonsterHealingItem *)healingItem {
  if ((self = [super init])) {
    self.userMonsterId = healingItem.userMonsterId;
    self.healthProgress = healingItem.healthProgress;
    self.queueTime = healingItem.queueTime;
    
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    UserMonster *um = [gs myMonsterWithUserMonsterId:self.userMonsterId];
    self.totalHealthToHeal = [gl calculateMaxHealthForMonster:um]-um.curHealth;
    
    self.timeDistribution = [NSMutableArray array];
  }
  return self;
}

- (NSString *) description {
//  return [NSString stringWithFormat:@"HealingItem: %d, Q: %@, H: %d, T: %d S: %@, E: %@", self.userMonsterId, self.queueTime, self.totalHealthToHeal-self.healthProgress, (int)[self.endTime timeIntervalSinceDate:self.startTime], self.startTime, self.endTime];
  NSMutableString *s = [NSMutableString stringWithFormat:@"("];
  for (int i = 0; i < self.timeDistribution.count; i+=2) {
    if (i > 0) [s appendFormat:@", "];
    [s appendFormat:@"%@s: %@", self.timeDistribution[i], self.timeDistribution[i+1]];
  }
  [s appendFormat:@")"];
  
  return [NSString stringWithFormat:@"HealingItem: %d, T: %@, P: %f, S: %@, E: %@", self.userMonsterId, s, self.healthProgress, self.startTime, self.endTime];
}

@end

@implementation HospitalQueueSimulator

- (id) initWithHospitals:(NSArray *)hospitals healingItems:(NSArray *)healingItems {
  if ((self = [super init])) {
    NSMutableArray *hosp = [NSMutableArray array];
    NSMutableArray *heal = [NSMutableArray array];
    
    for (UserStruct *us in hospitals) {
      HospitalSim *sim = [[HospitalSim alloc] initWithHospital:us];
      [hosp addObject:sim];
    }
    
    for (UserMonsterHealingItem *hi in healingItems) {
      HealingItemSim *sim = [[HealingItemSim alloc] initWithHealingItem:hi];
      [heal addObject:sim];
    }
    
    self.hospitals = hosp;
    self.healingItems = heal;
    
    SimLog(@"Hospitals: %@", self.hospitals);
    SimLog(@"Healing Items: %@", self.healingItems);
  }
  return self;
}

- (void) simulateUntilDate:(NSDate *)date {
  if (!self.healingItems.count) {
    return;
  }
  SimLog(@"-------------------------------------");
  SimLog(@"Starting with date: %@", [self.healingItems[0] queueTime]);
  [self readjustAllItemsForDate:[self.healingItems[0] queueTime]];
  SimLog(@"");
  SimLog(@"%@", self.healingItems);
  SimLog(@"-------------------------------------");
  
  int i = 0;
  for (NSDate *next = self.getNextDate; next && [date compare:next] != NSOrderedAscending; next = self.getNextDate) {
    SimLog(@"Round %d: %@", i, next);
    i++;
    [self readjustAllItemsForDate:next];
    SimLog(@"");
    SimLog(@"%@", self.healingItems);
    SimLog(@"-------------------------------------");
  }
  
  if (date) {
    SimLog(@"Round %d: %@", i, date);
    [self readjustAllItemsForDate:date];
    SimLog(@"Readjusted for date");
    SimLog(@"-------------------------------------");
  }
  
  SimLog(@"Healing Items: %@", self.healingItems);
  SimLog(@"-------------------------------------");
  SimLog(@"-------------------------------------");
  SimLog(@"-------------------------------------");
}

- (void) simulate {
  [self simulateUntilDate:nil];
}

- (HospitalSim *) hospitalWithId:(int)userStructId {
  for (HospitalSim *hs in self.hospitals) {
    if (hs.userStructId == userStructId) {
      return hs;
    }
  }
  return nil;
}

- (NSDate *) getNextDate {
  NSMutableArray *dates = [NSMutableArray array];
  for (HospitalSim *hosp in self.hospitals) {
    if (hosp.upgradeCompleteDate) {
      [dates addObject:hosp.upgradeCompleteDate];
    }
  }
  
  for (HealingItemSim *item in self.healingItems) {
    if (!item.isFinished && item.endTime) {
      [dates addObject:item.endTime];
    }
  }
  
  [dates sortUsingSelector:@selector(compare:)];
  
  return dates.count ? dates[0] : nil;
}

- (void) readjustAllItemsForDate:(NSDate *)date {
  // First unschedule all monsters
  for (HealingItemSim *item in self.healingItems) {
    if (item.userStructId) {
      HospitalSim *hs = [self hospitalWithId:item.userStructId];
      NSDate *startDate = item.startTime;
      float seconds = [date timeIntervalSinceDate:startDate];
      
      if ([item.endTime isEqualToDate:date]) {
        SimLog(@"Item %d finished", item.userMonsterId);
        item.isFinished = YES;
        item.userStructId = 0;
        item.totalSeconds += seconds;
        
        [item.timeDistribution addObject:@(seconds)];
        [item.timeDistribution addObject:@(item.totalHealthToHeal-item.healthProgress)];
      }
      
      if (!item.isFinished) {
        float healthPerSecond = hs.healthPerSecond;
        
        item.healthProgress += healthPerSecond * seconds;
        item.totalSeconds += seconds;
        
        [item.timeDistribution addObject:@(seconds)];
        [item.timeDistribution addObject:@(healthPerSecond*seconds)];
        
        item.userStructId = 0;
        item.startTime = nil;
        item.endTime = nil;
      }
    }
  }
  
  // Reschedule monsters
  NSMutableArray *validHospitals = [NSMutableArray array];
  for (HospitalSim *sim in self.hospitals) {
    if (sim.upgradeCompleteDate && [date compare:sim.upgradeCompleteDate] != NSOrderedAscending) {
      SimLog(@"Hospital %d finished", sim.userStructId);
      sim.upgradeCompleteDate = nil;
    }
    
    if (!sim.upgradeCompleteDate) {
      [validHospitals addObject:sim];
    }
  }
  [validHospitals sortUsingComparator:^NSComparisonResult(HospitalSim *obj1, HospitalSim *obj2) {
    return [@(obj2.healthPerSecond) compare:@(obj1.healthPerSecond)];
  }];
  
  NSMutableArray *validItems = [NSMutableArray array];
  for (HealingItemSim *sim in self.healingItems) {
    if (!sim.isFinished) {
      [validItems addObject:sim];
    }
  }
  
  for (int i = 0; i < validHospitals.count && i < validItems.count; i++) {
    HospitalSim *us = validHospitals[i];
    HealingItemSim *hi = validItems[i];
    
    hi.userStructId = us.userStructId;
    hi.startTime = [date compare:hi.queueTime] == NSOrderedDescending ? date : hi.queueTime;
    hi.endTime = [hi.startTime dateByAddingTimeInterval:(hi.totalHealthToHeal-hi.healthProgress)/us.healthPerSecond];
  }
}

@end
