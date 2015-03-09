//
//  BattleItemQueue.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/9/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "BattleItemQueue.h"

#import "Globals.h"

@implementation BattleItemQueueObject

- (id) initWithProto:(BattleItemQueueForUserProto *)proto {
  if ((self = [super init])) {
    self.priority = proto.priority;
    self.userUuid = proto.userUuid;
    self.battleItemId = proto.battleItemId;
    self.expectedStartTime = [MSDate dateWithTimeIntervalSince1970:proto.expectedStartTime/1000.];
  }
  return self;
}

- (id) copy {
  BattleItemQueueObject *item = [[BattleItemQueueObject alloc] init];
  item.userUuid = self.userUuid;
  item.priority = self.priority;
  item.battleItemId = self.battleItemId;
  item.expectedStartTime = [self.expectedStartTime copy];
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

//- (void) addAllBattleItemQueueObjects:(NSArray *)objects {
//  [self.queueObjects removeAllObjects];
//  
//  for (BattleItemQueueForUserProto *proto in objects) {
//      [self.queueObjects addObject:[[BattleItemQueueObject alloc] initWithProto:proto]];
//  }
//  
//  [self.queueObjects sortUsingComparator:^NSComparisonResult(BattleItemQueueObject *obj1, BattleItemQueueObject *obj2) {
//    return [@(obj1.priority) compare:@(obj2.priority)];
//  }];
//  
//  [[SocketCommunication sharedSocketCommunication] reloadHealQueueSnapshot];
//  
//  [self readjustAllMonsterHealingProtos];
//  
//  self.hasShownFreeHealingQueueSpeedup = NO;
//  
//  [[NSNotificationCenter defaultCenter] postNotificationName:HEAL_WAIT_COMPLETE_NOTIFICATION object:nil];
//}
//
//- (void) addUserMonsterHealingItemToEndOfQueue:(UserMonsterHealingItem *)item {
//  // Save the last guy's health progress so we get elapsed time as well.
//  [self saveHealthProgressesFromIndex:self.healingItems.count-1];
//  
//  UserMonsterHealingItem *prevItem = [self.healingItems lastObject];
//  item.priority = prevItem.priority+1;
//  item.queueTime = [MSDate date];
//  item.elapsedTime = prevItem.elapsedTime;
//  
//  [self.healingItems addObject:item];
//  [self readjustAllMonsterHealingProtos];
//  
//  Globals *gl = [Globals sharedGlobals];
//  if (self.queueEndTime.timeIntervalSinceNow > gl.maxMinutesForFreeSpeedUp*60) {
//    self.hasShownFreeHealingQueueSpeedup = NO;
//  } else {
//    self.hasShownFreeHealingQueueSpeedup = YES;
//  }
//}
//
//- (void) removeUserMonsterHealingItem:(UserMonsterHealingItem *)item {
//  NSInteger index = [self.healingItems indexOfObject:item];
//  [self saveHealthProgressesFromIndex:index];
//  
//  [self.healingItems removeObject:item];
//  
//  [self readjustAllMonsterHealingProtos];
//  
//  Globals *gl = [Globals sharedGlobals];
//  if (self.queueEndTime.timeIntervalSinceNow < gl.maxMinutesForFreeSpeedUp*60) {
//    self.hasShownFreeHealingQueueSpeedup = YES;
//  }
//}

@end
