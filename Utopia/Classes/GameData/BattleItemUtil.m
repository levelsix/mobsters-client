//
//  BattleItemUtil.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/9/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "BattleItemUtil.h"

#import "GameState.h"

@implementation UserBattleItem

- (id) initWithProto:(UserBattleItemProto *)bip {
  if ((self = [super init])) {
    self.battleItemId = bip.battleItemId;
    self.userUuid = bip.userUuid;
    self.quantity = bip.quantity;
  }
  return self;
}

- (BattleItemProto *) staticBattleItem {
  GameState *gs = [GameState sharedGameState];
  return [gs battleItemWithId:self.battleItemId];
}

- (BOOL) isEqual:(UserBattleItem *)object {
  if ([object class] != [UserBattleItem class]) {
    return NO;
  }
  return [object.userUuid isEqualToString:self.userUuid] && self.battleItemId == object.battleItemId;
}

- (NSUInteger) hash {
  return self.userUuid.hash*31 + self.battleItemId*11;
}

@end

@implementation BattleItemUtil

- (void) updateWithQueueProtos:(NSArray *)queueProtos itemProtos:(NSArray *)itemProtos {
  self.battleItemQueue = [[BattleItemQueue alloc] init];
  [self.battleItemQueue addAllBattleItemQueueObjects:queueProtos];
  
  self.battleItems = [NSMutableArray array];
  [self addToMyItems:itemProtos];
}

- (int) currentPowerAmountFromCreatedItems {
  int pwr = 0;
  
  for (UserBattleItem *bi in self.battleItems) {
    pwr += bi.staticBattleItem.powerAmount*bi.quantity;
  }
  
  return pwr;
}

- (int) totalPowerAmount {
  int pwr = 0;
  
  pwr += [self currentPowerAmountFromCreatedItems];
  
  for (BattleItemQueueObject *item in self.battleItemQueue.queueObjects) {
    pwr += item.staticBattleItem.powerAmount;
  }
  
  return pwr;
}

- (void) addToMyItems:(NSArray *)itemProtos {
  for (UserBattleItemProto *bip in itemProtos) {
    UserBattleItem *ubi = [[UserBattleItem alloc] initWithProto:bip];
    
    if ([self.battleItems containsObject:ubi]) {
      NSInteger idx = [self.battleItems indexOfObject:ubi];
      [self.battleItems replaceObjectAtIndex:idx withObject:ubi];
      
      LNLog(@"Replacing item at index %d..", (int)idx);
    } else {
      [self.battleItems addObject:ubi];
    }
  }
}

- (UserBattleItem *) getUserBattleItemForBattleItemId:(int)itemId {
  for (UserBattleItem *ui in self.battleItems) {
    if (ui.battleItemId == itemId) {
      return ui;
    }
  }
  return nil;
}

- (void) incrementBattleItemId:(int)itemId quantity:(int)quantity {
  UserBattleItem *ui = [self getUserBattleItemForBattleItemId:itemId];
  
  if (!ui) {
    GameState *gs = [GameState sharedGameState];
    
    ui = [[UserBattleItem alloc] init];
    ui.battleItemId = itemId;
    ui.userUuid = gs.userUuid;
    
    [self.battleItems addObject:ui];
  }
  
  ui.quantity += quantity;
}

@end
