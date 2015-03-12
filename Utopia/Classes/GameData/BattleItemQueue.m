//
//  BattleItemQueue.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/9/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "BattleItemQueue.h"

#import "GameState.h"
#import "Globals.h"
#import "SocketCommunication.h"

@implementation BattleItemQueueObject

- (id) initWithProto:(BattleItemQueueForUserProto *)proto {
  if ((self = [super init])) {
    self.priority = proto.priority;
    self.userUuid = proto.userUuid;
    self.battleItemId = proto.battleItemId;
    self.expectedStartTime = [MSDate dateWithTimeIntervalSince1970:proto.expectedStartTime/1000.];
    self.elapsedTime = proto.elapsedTime;
  }
  return self;
}

- (BattleItemProto *) staticBattleItem {
  GameState *gs = [GameState sharedGameState];
  return [gs battleItemWithId:self.battleItemId];
}

- (int) totalSecondsToComplete {
  return self.staticBattleItem.minutesToCreate*60;
}

- (MSDate *) expectedEndTime {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int seconds = self.totalSecondsToComplete;
  
  // Account for clan helps
  int numHelps = [gs.clanHelpUtil getNumClanHelpsForType:GameActionTypeCreateBattleItem userDataUuid:self.battleItemQueueUuid];
  if (numHelps > 0) {
    int secsToDockPerHelp = MAX(gl.battleItemClanHelpConstants.amountRemovedPerHelp*60, roundf(seconds*gl.battleItemClanHelpConstants.percentRemovedPerHelp));
    seconds -= numHelps*secsToDockPerHelp;
  }
  
  // CAN'T USE THIS: Because of userDataUuid we are unable to use a speedup on multiple battle items at once. We must just move startTime back and not use the speedup item usages.
  // Account for speedups
  //int speedupMins = [gs.itemUtil getSpeedupMinutesForType:GameActionTypeCreateBattleItem userDataUuid:self.battleItemQueueUuid earliestDate:self.expectedStartTime];
  //if (speedupMins > 0) {
  //  seconds -= speedupMins*60;
  //}
  
  return [self.expectedStartTime dateByAddingTimeInterval:seconds];
}

- (NSString *)battleItemQueueUuid {
  return [NSString stringWithFormat:@"%d", self.priority];
}

- (BattleItemQueueForUserProto *) convertToProto {
  BattleItemQueueForUserProto_Builder *bldr = [BattleItemQueueForUserProto builder];
  bldr.priority = self.priority;
  bldr.userUuid = self.userUuid;
  bldr.battleItemId = self.battleItemId;
  bldr.expectedStartTime = self.expectedStartTime.timeIntervalSince1970*1000.;
  bldr.elapsedTime = self.elapsedTime;
  return bldr.build;
}

- (id) copy {
  BattleItemQueueObject *item = [[BattleItemQueueObject alloc] init];
  item.userUuid = self.userUuid;
  item.priority = self.priority;
  item.battleItemId = self.battleItemId;
  item.expectedStartTime = [self.expectedStartTime copy];
  item.elapsedTime = self.elapsedTime;
  return item;
}

- (BOOL) isEqual:(BattleItemQueueObject *)object {
  if ([object class] != [BattleItemQueueObject class]) {
    return NO;
  }
  return [object.userUuid isEqualToString:self.userUuid] && self.priority == object.priority && self.battleItemId == object.battleItemId;
}

- (NSUInteger) hash {
  return self.userUuid.hash*31 + self.priority*17 + self.battleItemId*11;
}

@end

@implementation BattleItemQueue

- (id) init {
  if ((self = [super init])) {
    self.queueObjects = [NSMutableArray array];
  }
  return self;
}

- (void) addAllBattleItemQueueObjects:(NSArray *)objects {
  [self.queueObjects removeAllObjects];
  
  for (BattleItemQueueForUserProto *proto in objects) {
    [self.queueObjects addObject:[[BattleItemQueueObject alloc] initWithProto:proto]];
  }
  
  [self.queueObjects sortUsingComparator:^NSComparisonResult(BattleItemQueueObject *obj1, BattleItemQueueObject *obj2) {
    return [@(obj1.priority) compare:@(obj2.priority)];
  }];
  
  [[SocketCommunication sharedSocketCommunication] reloadBattleItemQueueSnapshot];
  
  [self readjustQueueObjects];
  
  self.hasShownFreeSpeedup = NO;
}

- (void) addToEndOfQueue:(BattleItemQueueObject *)item {
  BattleItemQueueObject *prevItem = [self.queueObjects lastObject];
  item.priority = prevItem.priority+1;
  item.elapsedTime = prevItem.elapsedTime;
  
  if (self.queueObjects.count == 0) {
    item.expectedStartTime = [MSDate date];
  } else {
    item.expectedStartTime = prevItem.expectedEndTime;
  }
  
  [self.queueObjects addObject:item];
  
  [self readjustQueueObjects];
  
  Globals *gl = [Globals sharedGlobals];
  if (self.queueEndTime.timeIntervalSinceNow > gl.maxMinutesForFreeSpeedUp*60) {
    self.hasShownFreeSpeedup = NO;
  } else {
    self.hasShownFreeSpeedup = YES;
  }
}

- (void) removeFromQueue:(BattleItemQueueObject *)item {
  NSInteger index = [self.queueObjects indexOfObject:item];
  NSInteger total = self.queueObjects.count;
  
  if (index != NSNotFound && total > index+1) {
    if (index == 0) {
      BattleItemQueueObject *next = [self.queueObjects objectAtIndex:1];
      next.expectedStartTime = [MSDate date];
    }
  }
  
  [self.queueObjects removeObject:item];
  
  [self readjustQueueObjects];
  
  Globals *gl = [Globals sharedGlobals];
  if (self.queueEndTime.timeIntervalSinceNow < gl.maxMinutesForFreeSpeedUp*60) {
    self.hasShownFreeSpeedup = YES;
  }
}

- (void) readjustQueueObjects {
  for (int i = 1; i < self.queueObjects.count; i++) {
    BattleItemQueueObject *prev = self.queueObjects[i-1];
    BattleItemQueueObject *cur = self.queueObjects[i];
    
    cur.expectedStartTime = prev.expectedEndTime;
  }
  
  [[SocketCommunication sharedSocketCommunication] setBattleItemQueueDirtyWithCoinChange:0 oilChange:0 gemCost:0];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:BATTLE_ITEM_QUEUE_CHANGED_NOTIFICATION object:self];
}

- (MSDate *) queueEndTime {
  BattleItemQueueObject *last = [self.queueObjects lastObject];
  
  return last.expectedEndTime;
}

- (float) totalTimeForQueue {
  BattleItemQueueObject *first = [self.queueObjects firstObject];
  float totalTime = first.elapsedTime;
  
  for (BattleItemQueueObject *item in self.queueObjects) {
    totalTime += item.totalSecondsToComplete;
  }
  
  return totalTime;
}

- (void) updateElapsedTimesWithCompletedObjects:(NSArray *)objs {
  for (BattleItemQueueObject *obj in objs) {
    for (BattleItemQueueObject *biqo in self.queueObjects) {
      biqo.elapsedTime += obj.totalSecondsToComplete;
    }
  }
}

@end
