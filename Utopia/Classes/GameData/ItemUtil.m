//
//  ItemUtil.m
//  Utopia
//
//  Created by Ashwin on 11/7/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ItemUtil.h"

#import "GameState.h"

#import "OutgoingEventController.h"

@implementation ItemUtil

- (id) initWithItemProtos:(NSArray *)items itemUsageProtos:(NSArray *)itemUsages {
  if ((self = [super init])) {
    self.myItems = [NSMutableArray array];
    self.myItemUsages = [NSMutableArray array];
    
    [self addToMyItems:items];
    [self addToMyItemUsages:itemUsages];
    
    [self cleanupRogueItemUsages];
  }
  return self;
}

- (void) addToMyItems:(NSArray *)itemProtos {
  for (UserItemProto *uip in itemProtos) {
    UserItem *ui = [UserItem userItemWithProto:uip];
    
    if ([self.myItems containsObject:ui]) {
      NSInteger idx = [self.myItems indexOfObject:ui];
      [self.myItems replaceObjectAtIndex:idx withObject:ui];
      
      LNLog(@"Replacing item at index %d..", (int)idx);
    } else {
      [self.myItems addObject:ui];
    }
  }
  
  [[NSNotificationCenter defaultCenter] postNotificationName:ITEMS_CHANGED_NOTIFICATION object:self];
}

- (void) addToMyItemUsages:(NSArray *)itemUsageProtos {
  for (UserItemUsageProto *iup in itemUsageProtos) {
    UserItemUsage *uiu = [UserItemUsage userItemUsageWithProto:iup];
    
    NSInteger idx = [self.myItemUsages indexOfObject:uiu];
    if (idx != NSNotFound) {
      [self.myItemUsages replaceObjectAtIndex:idx withObject:uiu];
    } else {
      [self.myItemUsages addObject:uiu];
    }
  }
  
  [self cleanupRogueItemUsages];
}

- (UserItem *) getUserItemForItemId:(int)itemId {
  for (UserItem *ui in self.myItems) {
    if (ui.itemId == itemId) {
      return ui;
    }
  }
  return nil;
}

- (void) incrementItemId:(int)itemId quantity:(int)quantity {
  UserItem *ui = [self getUserItemForItemId:itemId];
  
  if (!ui) {
    GameState *gs = [GameState sharedGameState];
    
    ui = [[UserItem alloc] init];
    ui.itemId = itemId;
    ui.userUuid = gs.userUuid;
    
    [self.myItems addObject:ui];
  }
  
  ui.quantity += quantity;
  
  [[NSNotificationCenter defaultCenter] postNotificationName:ITEMS_CHANGED_NOTIFICATION object:self];
}

- (NSArray *) getItemsForType:(ItemType)type {
  return [self getItemsForType:type staticDataId:0];
}

- (NSArray *) getItemsForType:(ItemType)type staticDataId:(int)staticDataId {
  return [self getItemsForType:type staticDataId:staticDataId gameActionType:GameActionTypeNoHelp];
}

- (NSArray *) getItemsForType:(ItemType)type staticDataId:(int)staticDataId gameActionType:(GameActionType)gameActionType {
  NSMutableArray *arr = [NSMutableArray array];
  
  GameState *gs = [GameState sharedGameState];
  for (UserItem *ui in self.myItems) {
    ItemProto *ip = [gs itemForId:ui.itemId];
    
    if (ip.itemType == type && (!staticDataId || ip.staticDataId == staticDataId) && (ui.gameActionType == GameActionTypeNoHelp || ui.gameActionType == gameActionType)) {
      [arr addObject:ui];
    }
  }
  
  return arr;
}

- (int) getSpeedupMinutesForType:(GameActionType)type userDataUuid:(NSString *)userDataUuid earliestDate:(MSDate *)date {
  int speedupMins = 0;
  
  GameState *gs = [GameState sharedGameState];
  for (UserItemUsage *uiu in self.myItemUsages) {
    if (uiu.actionType == type && [uiu.userDataUuid isEqualToString:userDataUuid] && [uiu.timeOfEntry compare:date] == NSOrderedDescending) {
      ItemProto *ip = [gs itemForId:uiu.itemId];
      if (ip.itemType == ItemTypeSpeedUp) {
        speedupMins += ip.amount;
      }
    }
  }
  
  return speedupMins;
}

- (void) cleanupRogueItemUsages {
  GameState *gs = [GameState sharedGameState];
  
  // Grab all individual clan helps
  NSMutableArray *toRemove = [NSMutableArray array];
  NSMutableArray *removeUsageUuids = [NSMutableArray array];
  for (UserItemUsage *iu in self.myItemUsages) {
    BOOL isValid = NO;
    
    if (iu.actionType == GameActionTypeUpgradeStruct) {
      UserStruct *us = [gs myStructWithUuid:iu.userDataUuid];
      // If us doesn't exist, this will also return true which is good in case city hasn't loaded.
      isValid = !us.isComplete;
    } else if (iu.actionType == GameActionTypeRemoveObstacle) {
      UserObstacle *uo = nil;
      for (UserObstacle *u in gs.myObstacles) {
        if ([u.userObstacleUuid isEqualToString:iu.userDataUuid]) {
          uo = u;
        }
      }
      
      isValid = !!uo.removalTime;
    } else if (iu.actionType == GameActionTypeMiniJob) {
      UserMiniJob *umj = nil;
      for (UserMiniJob *u in gs.myMiniJobs) {
        if ([u.userMiniJobUuid isEqualToString:iu.userDataUuid]) {
          umj = u;
        }
      }
      
      isValid = !!umj.timeStarted;
    } else if (iu.actionType == GameActionTypeHeal) {
      UserMonsterHealingItem *hi = nil;
      for (HospitalQueue *hq in gs.monsterHealingQueues.allValues) {
        for (UserMonsterHealingItem *u in hq.healingItems) {
          if ([u.userMonsterUuid isEqualToString:iu.userDataUuid]) {
            hi = u;
          }
        }
      }
      
      isValid = !!hi;
    } else if (iu.actionType == GameActionTypeEvolve) {
      UserEvolution *ue = gs.userEvolution;
      
      isValid = ([ue.userMonsterUuid1 isEqualToString:iu.userDataUuid]);
    } else if (iu.actionType == GameActionTypeEnhanceTime) {
      UserEnhancement *ue = gs.userEnhancement;
      
      isValid = [ue.baseMonster.userMonsterUuid isEqualToString:iu.userDataUuid];
    } else if (iu.actionType == GameActionTypeCombineMonster) {
      UserMonster *um = [gs myMonsterWithUserMonsterUuid:iu.userDataUuid];
      
      isValid = um.isCombining;
    } else if (iu.actionType == GameActionTypeCreateBattleItem) {
      BattleItemQueueObject *biq = nil;
      for (BattleItemQueueObject *item in gs.battleItemUtil.battleItemQueue.queueObjects) {
        if ([item.battleItemQueueUuid isEqualToString:iu.userDataUuid]) {
          biq = item;
        }
      }
      
      isValid = !!biq;
    } else if (iu.actionType == GameActionTypePerformingResearch) {
      UserResearch *ur = [gs.researchUtil currentResearch];
      isValid = !!ur && [ur.userResearchUuid isEqualToString:iu.userDataUuid];
    }
    
    // Wait till it is at least
    if (!isValid) {
      [toRemove addObject:iu];
      
      if (iu.usageUuid) {
        [removeUsageUuids addObject:iu.usageUuid];
      }
    }
  }
  
  if (removeUsageUuids.count) {
    [self.myItemUsages removeObjectsInArray:toRemove];
    
    LNLog(@"Removing %d item usages.", (int)removeUsageUuids.count);
    
    [[OutgoingEventController sharedOutgoingEventController] removeUserItemUsed:removeUsageUuids];
  }
}

@end
