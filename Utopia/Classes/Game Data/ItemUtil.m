//
//  ItemUtil.m
//  Utopia
//
//  Created by Ashwin on 11/7/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ItemUtil.h"

#import "GameState.h"

@implementation ItemUtil

- (id) initWithItemProtos:(NSArray *)items itemUsageProtos:(NSArray *)itemUsages {
  if ((self = [super init])) {
    self.myItems = [NSMutableArray array];
    self.myItemUsages = [NSMutableArray array];
    
    [self addToMyItems:items];
    [self addToMyItemUsages:itemUsages];
  }
  return self;
}

- (void) addToMyItems:(NSArray *)itemProtos {
  for (UserItemProto *uip in itemProtos) {
    UserItem *ui = [UserItem userItemWithProto:uip];
    
    if ([self.myItems containsObject:ui]) {
      NSInteger idx = [self.myItems indexOfObject:ui];
      [self.myItems replaceObjectAtIndex:idx withObject:ui];
      
      LNLog(@"Replacing item at index %d..", idx);
    } else {
      [self.myItems addObject:ui];
    }
  }
}

- (void) addToMyItemUsages:(NSArray *)itemUsageProtos {
}

- (NSArray *) getItemsForType:(ItemType)type staticDataId:(int)staticDataId {
  NSMutableArray *arr = [NSMutableArray array];
  
  GameState *gs = [GameState sharedGameState];
  for (UserItem *ui in self.myItems) {
    ItemProto *ip = [gs itemForId:ui.itemId];
    
    if (ip.itemType == type && (!staticDataId || ip.staticDataId == staticDataId)) {
      [arr addObject:ui];
    }
  }
  
  return arr;
}

- (int) getSpeedupMinutesForType:(GameActionType)type userDataId:(uint64_t)userDataId {
  int speedupMins = 0;
  
  GameState *gs = [GameState sharedGameState];
  for (UserItemUsage *uiu in self.myItemUsages) {
    if (uiu.actionType == type && uiu.userDataId == userDataId) {
      ItemProto *ip = [gs itemForId:uiu.itemId];
      if (ip.itemType == ItemTypeSpeedUp) {
        speedupMins += ip.amount;
      }
    }
  }
  
  return speedupMins;
}

@end
