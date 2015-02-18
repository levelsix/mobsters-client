//
//  HospitalQueue.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/2/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "HospitalQueue.h"

#import "UserData.h"
#import "GameState.h"

#import "QuestUtil.h"
#import "SocketCommunication.h"
#import "HospitalQueueSimulator.h"

@implementation UserMonsterHealingItem

- (id) initWithHealingProto:(UserMonsterHealingProto *)proto {
  if ((self = [super init])){
    self.userUuid = proto.userUuid;
    self.userMonsterUuid = proto.userMonsterUuid;
    self.userHospitalStructUuid = proto.userHospitalStructUuid;
    self.queueTime = proto.hasQueuedTimeMillis ? [MSDate dateWithTimeIntervalSince1970:proto.queuedTimeMillis/1000.0] : nil;
    self.healthProgress = proto.healthProgress;
    self.priority = proto.priority;
    self.elapsedTime = proto.elapsedSeconds;
  }
  return self;
}

+ (id) userMonsterHealingItemWithProto:(UserMonsterHealingProto *)proto {
  return [[self alloc] initWithHealingProto:proto];
}

- (UserMonster *) userMonster {
  GameState *gs = [GameState sharedGameState];
  return [gs myMonsterWithUserMonsterUuid:self.userMonsterUuid];
}

- (UserMonsterHealingProto *) convertToProto {
  UserMonsterHealingProto_Builder *bldr = [[[[[[[UserMonsterHealingProto builder]
                                                setUserUuid:self.userUuid]
                                               setUserMonsterUuid:self.userMonsterUuid]
                                              setHealthProgress:self.healthProgress]
                                             setPriority:self.priority]
                                            setElapsedSeconds:self.elapsedTime]
                                           setUserHospitalStructUuid:self.userHospitalStructUuid];
  
  [bldr setQueuedTimeMillis:self.queueTime.timeIntervalSince1970*1000];
  return [bldr build];
}

- (float) totalSeconds {
  float secs = 0;
  for (int i = 0; i < self.timeDistribution.count; i += 2) {
    secs += [self.timeDistribution[i] floatValue];
  }
  return secs;
}

- (float) currentPercentage {
  float totalSecs = [self totalSeconds];
  float timeLeft = [self.endTime timeIntervalSinceNow];
  float timeCompleted = MAX(totalSecs-timeLeft, 0);
  
  float healthToHeal = 0;
  for (int i = 1; i < self.timeDistribution.count; i += 2) {
    healthToHeal += [self.timeDistribution[i] intValue];
  }
  
  Globals *gl = [Globals sharedGlobals];
  UserMonster *um = self.userMonster;
  float totalHealth = [gl calculateMaxHealthForMonster:um]-self.userMonster.curHealth;
  
  float basePerc = (totalHealth-healthToHeal)/totalHealth;
  float percentage = basePerc;
  for (int i = 0; i < self.timeDistribution.count; i += 2) {
    float secs = [self.timeDistribution[i] floatValue];
    float health = [self.timeDistribution[i+1] floatValue];
    
    if (timeCompleted > secs) {
      timeCompleted -= secs;
      percentage += health/healthToHeal;
    } else {
      percentage += health/healthToHeal*timeCompleted/secs*(1-basePerc);
      break;
    }
  }
  
  return percentage;
}

- (id) copy {
  UserMonsterHealingItem *item = [[UserMonsterHealingItem alloc] init];
  item.userUuid = self.userUuid;
  item.userMonsterUuid = self.userMonsterUuid;
  item.queueTime = [self.queueTime copy];
  item.healthProgress = self.healthProgress;
  item.priority = self.priority;
  item.elapsedTime = self.elapsedTime;
  item.userHospitalStructUuid = self.userHospitalStructUuid;
  return item;
}

- (BOOL) isEqual:(UserMonsterHealingItem *)object {
  if (![object respondsToSelector:@selector(userMonsterUuid)]) {
    return NO;
  }
  return [object.userMonsterUuid isEqualToString:self.userMonsterUuid];
}

- (NSUInteger) hash {
  return self.userMonsterUuid.hash;
}

- (NSString *) description {
  return [NSString stringWithFormat:@"%p: %@, QT: %@, H: %f, TS: %f, ET: %f", self, self.userMonsterUuid, self.queueTime, self.healthProgress, self.totalSeconds, self.elapsedTime];
}

@end

@implementation HospitalQueue

- (id) init {
  if ((self = [super init])) {
    self.healingItems = [NSMutableArray array];
  }
  return self;
}

- (UserStruct *) myHospital {
  GameState *gs = [GameState sharedGameState];
  return [gs myStructWithUuid:self.userHospitalStructUuid];
}

- (void) addAllMonsterHealingProtos:(NSArray *)items {
  [self.healingItems removeAllObjects];
  
  for (UserMonsterHealingProto *proto in items) {
    if ([proto.userHospitalStructUuid isEqualToString:self.userHospitalStructUuid]) {
      [self.healingItems addObject:[UserMonsterHealingItem userMonsterHealingItemWithProto:proto]];
    }
  }
  
  [self.healingItems sortUsingComparator:^NSComparisonResult(UserMonsterHealingItem *obj1, UserMonsterHealingItem *obj2) {
    return [@(obj1.priority) compare:@(obj2.priority)];
  }];
  
  [[SocketCommunication sharedSocketCommunication] reloadHealQueueSnapshot];
  
  [self readjustAllMonsterHealingProtos]; 
  
  self.hasShownFreeHealingQueueSpeedup = NO;
  
  [[NSNotificationCenter defaultCenter] postNotificationName:HEAL_WAIT_COMPLETE_NOTIFICATION object:nil];
  
  [QuestUtil checkAllDonateQuests];
}

- (void) addUserMonsterHealingItemToEndOfQueue:(UserMonsterHealingItem *)item {
  // Save the last guy's health progress so we get elapsed time as well.
  [self saveHealthProgressesFromIndex:self.healingItems.count-1];
  
  UserMonsterHealingItem *prevItem = [self.healingItems lastObject];
  item.priority = prevItem.priority+1;
  item.queueTime = [MSDate date];
  item.elapsedTime = prevItem.elapsedTime;
  
  [self.healingItems addObject:item];
  [self readjustAllMonsterHealingProtos];
  
  Globals *gl = [Globals sharedGlobals];
  if (self.queueEndTime.timeIntervalSinceNow > gl.maxMinutesForFreeSpeedUp*60) {
    self.hasShownFreeHealingQueueSpeedup = NO;
  } else {
    self.hasShownFreeHealingQueueSpeedup = YES;
  }
  
  [QuestUtil checkAllDonateQuests];
}

- (void) removeUserMonsterHealingItem:(UserMonsterHealingItem *)item {
  NSInteger index = [self.healingItems indexOfObject:item];
  [self saveHealthProgressesFromIndex:index];
  
  [self.healingItems removeObject:item];
  
  [self readjustAllMonsterHealingProtos];
  
  Globals *gl = [Globals sharedGlobals];
  if (self.queueEndTime.timeIntervalSinceNow < gl.maxMinutesForFreeSpeedUp*60) {
    self.hasShownFreeHealingQueueSpeedup = YES;
  }
  
  [QuestUtil checkAllDonateQuests];
}

- (void) saveHealthProgressesFromIndex:(NSInteger)index {
  [self saveHealthProgressesFromIndex:index withDate:[MSDate date]];
}

- (void) saveHealthProgressesFromIndex:(NSInteger)index withDate:(MSDate *)date {
  NSArray *allHospitals = @[[self myHospital]];
  
  HospitalQueueSimulator *sim = [[HospitalQueueSimulator alloc] initWithHospitals:allHospitals healingItems:self.healingItems];
  [sim simulateUntilDate:date];
  
  for (NSInteger i = index; i < sim.healingItems.count; i++) {
    HealingItemSim *hi = sim.healingItems[i];
    UserMonsterHealingItem *item = nil;
    for (UserMonsterHealingItem *i in self.healingItems) {
      if (!item || [hi.userMonsterUuid isEqualToString:i.userMonsterUuid]) {
        item = i;
      }
    }
    item.healthProgress = [item.endTime compare:date] == NSOrderedAscending ? hi.totalHealthToHeal : hi.healthProgress;
    item.elapsedTime += -[item.queueTime timeIntervalSinceDate:date];
    
    // Essentially, we use this method to allow us to skip forward in time, i.e. using a speedup
    // What will happen is that we save healthProgress as if we are at date, but set queue time to right now
    item.queueTime = [MSDate date];//date;
  }
}

- (void) readjustAllMonsterHealingProtos {
  UserStruct *myHospital = [self myHospital];
  
  if (myHospital) {
    NSArray *allHospitals = @[myHospital];
    
    HospitalQueueSimulator *sim = [[HospitalQueueSimulator alloc] initWithHospitals:allHospitals healingItems:self.healingItems];
    [sim simulate];
    
    MSDate *lastDate = nil;
    float totalTime = 0;
    for (HealingItemSim *hi in sim.healingItems) {
      UserMonsterHealingItem *item = nil;
      for (UserMonsterHealingItem *i in self.healingItems) {
        if (!item || [hi.userMonsterUuid isEqualToString:i.userMonsterUuid]) {
          item = i;
        }
      }
      item.timeDistribution = hi.timeDistribution;
      item.totalSeconds = hi.totalSeconds;
      item.endTime = hi.endTime;
      
      if (!lastDate || [lastDate compare:hi.endTime] == NSOrderedAscending) {
        lastDate = hi.endTime;
      }
      
      totalTime = MAX(totalTime, item.totalSeconds+item.elapsedTime+hi.waitingSeconds);
    }
    self.queueEndTime = lastDate;
    self.totalTimeForHealQueue = totalTime;
    
    [[SocketCommunication sharedSocketCommunication] setHealQueueDirtyWithCoinChange:0 gemCost:0];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HEAL_QUEUE_CHANGED_NOTIFICATION object:self];
  }
}

@end
