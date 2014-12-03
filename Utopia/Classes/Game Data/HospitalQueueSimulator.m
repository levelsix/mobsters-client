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
    self.secsToFullyHealMultiplier = ((HospitalProto *)hospital.staticStruct).secsToFullyHealMultiplier;
    self.upgradeCompleteDate = !hospital.isComplete ? hospital.buildCompleteDate : nil;
    self.userStructUuid = hospital.userStructUuid;
  }
  return self;
}

- (NSString *) description {
  return [NSString stringWithFormat:@"Hospital: %@, %@, %f", self.userStructUuid, self.upgradeCompleteDate, self.secsToFullyHealMultiplier];
}

@end

@implementation HealingItemSim

- (id) initWithHealingItem:(UserMonsterHealingItem *)healingItem {
  if ((self = [super init])) {
    self.userMonsterUuid = healingItem.userMonsterUuid;
    self.healthProgress = healingItem.healthProgress;
    self.queueTime = healingItem.queueTime;
    
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    UserMonster *um = [gs myMonsterWithUserMonsterUuid:self.userMonsterUuid];
    self.totalHealthToHeal = [gl calculateMaxHealthForMonster:um]-um.curHealth;
    self.baseHealthPerSecond = self.totalHealthToHeal/[gl calculateBaseSecondsToHealMonster:um];
    
    // Subtract additional hp for clan helps
    int numHelps = [gs.clanHelpUtil getNumClanHelpsForType:GameActionTypeHeal userDataUuid:self.userMonsterUuid];
    if (numHelps > 0) {
      int healthToDockPerHelp = MAX(gl.healClanHelpConstants.amountRemovedPerHelp, roundf(self.totalHealthToHeal*gl.healClanHelpConstants.percentRemovedPerHelp));
      self.totalHealthToHeal -= numHelps*healthToDockPerHelp;
    }
    
    self.totalHealthToHeal = MAX(0, self.totalHealthToHeal);
    
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
  
  return [NSString stringWithFormat:@"HealingItem: %@, T: %@, P: %f, S: %@, E: %@, TS: %f", self.userMonsterUuid, s, self.healthProgress, self.startTime, self.endTime, self.totalSeconds];
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
    
    SimLog(@" ");
    SimLog(@"-------------------------------------");
    SimLog(@"Hospitals: %@", self.hospitals);
    SimLog(@"Healing Items: %@", self.healingItems);
    SimLog(@"-------------------------------------");
  }
  return self;
}

- (void) simulateUntilDate:(MSDate *)date {
  if (!self.healingItems.count) {
    return;
  }
  MSDate *prev = nil;
  MSDate *first = [self.healingItems[0] queueTime];
  SimLog(@"-------------------------------------");
  SimLog(@"Starting with date: %@", first);
  [self readjustAllItemsForDate:first secondsSinceLastItem:-[prev timeIntervalSinceDate:first]];
  prev = first;
  SimLog(@"");
  SimLog(@"%@", self.healingItems);
  SimLog(@"-------------------------------------");
  
  int i = 0;
  for (MSDate *next = self.getNextDate; next && [date compare:next] != NSOrderedAscending; next = self.getNextDate) {
    SimLog(@"Round %d: %@", i, next);
    i++;
    [self readjustAllItemsForDate:next secondsSinceLastItem:-[prev timeIntervalSinceDate:next]];
    prev = next;
    SimLog(@" ");
    SimLog(@"%@", self.healingItems);
    SimLog(@"-------------------------------------");
  }
  
  if (date) {
    SimLog(@"Round %d: %@", i, date);
    [self readjustAllItemsForDate:date secondsSinceLastItem:-[prev timeIntervalSinceDate:date]];
    SimLog(@"Readjusted for date");
    SimLog(@"-------------------------------------");
  }
  
  SimLog(@"Healing Items: %@", self.healingItems);
  SimLog(@"-------------------------------------");
  SimLog(@"-------------------------------------");
}

- (void) simulate {
  [self simulateUntilDate:nil];
}

- (HospitalSim *) hospitalWithUuid:(NSString *)userStructUuid {
  for (HospitalSim *hs in self.hospitals) {
    if ([hs.userStructUuid isEqualToString:userStructUuid]) {
      return hs;
    }
  }
  return nil;
}

- (MSDate *) getNextDate {
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

- (void) readjustAllItemsForDate:(MSDate *)date secondsSinceLastItem:(float)secondsSinceLastItem {
  // First unschedule all monsters
  for (HealingItemSim *item in self.healingItems) {
    if (item.userStructUuid) {
      MSDate *startDate = item.startTime;
      float seconds = [date timeIntervalSinceDate:startDate];
      HospitalSim *hs = [self hospitalWithUuid:item.userStructUuid];
      
      if ([item.endTime isEqualToDate:date]) {
        SimLog(@"Item %@ finished", item.userMonsterUuid);
        item.isFinished = YES;
        item.userStructUuid = nil;
        item.totalSeconds += seconds;
        
        [item.timeDistribution addObject:@(seconds)];
        [item.timeDistribution addObject:@(item.totalHealthToHeal-item.healthProgress)];
      }
      
      if (!item.isFinished) {
        float healthPerSecond = item.baseHealthPerSecond*hs.secsToFullyHealMultiplier;
        
        item.healthProgress += healthPerSecond * seconds;
        item.totalSeconds += seconds;
        
        [item.timeDistribution addObject:@(seconds)];
        [item.timeDistribution addObject:@(healthPerSecond*seconds)];
        
        item.userStructUuid = nil;
        item.startTime = nil;
        item.endTime = nil;
      }
    } else if (!item.isFinished) {
      // This item is waiting
      item.waitingSeconds += secondsSinceLastItem;
    }
  }
  
  // Reschedule monsters
  NSMutableArray *validHospitals = [NSMutableArray array];
  for (HospitalSim *sim in self.hospitals) {
    if (sim.upgradeCompleteDate && [date compare:sim.upgradeCompleteDate] != NSOrderedAscending) {
      SimLog(@"Hospital %@ finished", sim.userStructUuid);
      sim.upgradeCompleteDate = nil;
    }
    
    if (!sim.upgradeCompleteDate) {
      [validHospitals addObject:sim];
    }
  }
  [validHospitals sortUsingComparator:^NSComparisonResult(HospitalSim *obj1, HospitalSim *obj2) {
    return [@(obj2.secsToFullyHealMultiplier) compare:@(obj1.secsToFullyHealMultiplier)];
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
    
    hi.userStructUuid = us.userStructUuid;
    hi.startTime = [date compare:hi.queueTime] == NSOrderedDescending ? date : hi.queueTime;
    
    float healthPerSecond = hi.baseHealthPerSecond*us.secsToFullyHealMultiplier;
    hi.endTime = [hi.startTime dateByAddingTimeInterval:(hi.totalHealthToHeal-hi.healthProgress)/healthPerSecond];
  }
}

@end
