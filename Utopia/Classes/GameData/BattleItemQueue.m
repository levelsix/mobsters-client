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
  return [self.expectedStartTime dateByAddingTimeInterval:self.totalSecondsToComplete];
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
  
  self.hasShownFreeSpeedup = NO;
  
  [[NSNotificationCenter defaultCenter] postNotificationName:HEAL_WAIT_COMPLETE_NOTIFICATION object:nil];
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
  
  self.queueEndTime = item.expectedEndTime;
  self.totalTimeForHealQueue = item.elapsedTime+item.totalSecondsToComplete;
  
  [self.queueObjects addObject:item];
  
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
    BattleItemQueueObject *next = [self.queueObjects objectAtIndex:index+1];
    if (index == 0) {
      next.expectedStartTime = [MSDate date];
    } else {
      BattleItemQueueObject *prev = [self.queueObjects objectAtIndex:index-1];
      next.expectedStartTime = prev.expectedEndTime;
    }
    
    for (NSInteger i = index+2; i < total; i++) {
      BattleItemQueueObject *next2 = [self.queueObjects objectAtIndex:i];
      BattleItemQueueObject *next1 = [self.queueObjects objectAtIndex:i-1];
      next2.expectedStartTime = next1.expectedEndTime;
    }
  }
  
  [self.queueObjects removeObject:item];
  
  Globals *gl = [Globals sharedGlobals];
  if (self.queueEndTime.timeIntervalSinceNow < gl.maxMinutesForFreeSpeedUp*60) {
    self.hasShownFreeSpeedup = YES;
  }
}

@end
