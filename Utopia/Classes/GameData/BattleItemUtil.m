//
//  BattleItemUtil.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/9/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "BattleItemUtil.h"

@implementation UserBattleItem

- (id) initWithProto:(UserBattleItemProto *)bip {
  if ((self = [super init])) {
    self.battleItemId = bip.battleItemId;
    self.userUuid = bip.userUuid;
    self.quantity = bip.quantity;
  }
  return self;
}

@end

@implementation BattleItemUtil

- (id) initWithQueueProtos:(NSArray *)queueProtos itemProtos:(NSArray *)itemProtos {
  if ((self = [super init])) {
    self.battleItemQueue = [[BattleItemQueue alloc] init];
    [self.battleItemQueue addAllBattleItemQueueObjects:queueProtos];
    
    self.battleItems = [NSMutableArray array];
    for (UserBattleItemProto *bip in itemProtos) {
      UserBattleItem *ubi = [[UserBattleItem alloc] initWithProto:bip];
      [self.battleItems addObject:ubi];
    }
  }
  return self;
}

@end
