//
//  SpeedupItemsFiller.m
//  Utopia
//
//  Created by Ashwin on 11/10/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SpeedupItemsFiller.h"

#import "GameState.h"
#import "GenericPopupController.h"

@implementation SpeedupItemsFiller

- (id) initWithGameActionType:(GameActionType)gameActionType {
  if ((self = [super init])) {
    self.usedItems = [NSMutableSet set];
    self.nonPurchasedItemsUsed = [[NSMutableSet alloc] init];
    _gameActionType = gameActionType;
  }
  return self;
}

- (NSArray *) reloadItemsArray {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *userItems = [[gs.itemUtil getItemsForType:ItemTypeSpeedUp staticDataId:0 gameActionType:_gameActionType] mutableCopy];
  
  for (ItemProto *ip in gs.staticItems.allValues) {
    if (ip.itemType == ItemTypeSpeedUp) {
      UserItem *ui = [[UserItem alloc] init];
      ui.itemId = ip.itemId;
      
      if ((![userItems containsObject:ui] && (ip.alwaysDisplayToUser || [self.usedItems containsObject:@(ui.itemId)])) &&
          (ui.gameActionType == GameActionTypeNoHelp || ui.gameActionType == _gameActionType)) {
        [userItems addObject:ui];
      }
    }
  }
  
  
  // Add a gems item object.. maybe
  GemsItemObject *gio = [[GemsItemObject alloc] init];
  gio.delegate = self;
  [userItems addObject:gio];
  [userItems sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    if ([obj1 isKindOfClass:[UserItem class]] && [obj2 isKindOfClass:[UserItem class]]) {
      BOOL anyOwned1 = [obj1 numOwned] > 0 || [self.nonPurchasedItemsUsed containsObject:@([obj1 itemId])];
      BOOL anyOwned2 = [obj2 numOwned] > 0 || [self.nonPurchasedItemsUsed containsObject:@([obj2 itemId])];
      
      GameActionType gameAction1 = [obj1 gameActionType];
      GameActionType gameAction2 = [obj2 gameActionType];
      
      if (anyOwned1 != anyOwned2) {
        return [@(anyOwned2) compare:@(anyOwned1)];
      } else if (gameAction1 != gameAction2) {
        return gameAction1 != GameActionTypeNoHelp ? NSOrderedAscending : NSOrderedDescending;
      } else {
        ItemProto *ip1 = [gs itemForId:[obj1 itemId]];
        ItemProto *ip2 = [gs itemForId:[obj2 itemId]];
        
        return [@(ip1.amount) compare:@(ip2.amount)];
      }
    } else if ([obj1 class] != [obj2 class]) {
      // Prioritize gems
      return [obj1 isKindOfClass:[GemsItemObject class]] ? NSOrderedAscending : NSOrderedDescending;
    }
    return NSOrderedSame;
  }];
  
  return userItems;
}

- (int) numGems {
  return [self.delegate numGemsForTotalSpeedup];
}

- (BOOL) wantsProgressBar {
  return YES;
}

- (TimerProgressBarColor) progressBarColor {
  int gems = [self.delegate numGemsForTotalSpeedup];
  if (gems <= 0) {
    return TimerProgressBarColorPurple;
  } else {
    return TimerProgressBarColorYellow;
  }
}

- (NSString *) progressBarText {
  int secsLeft = [self.delegate timeLeftForSpeedup];
  return [[Globals convertTimeToShortString:secsLeft] uppercaseString];
}

- (float) progressBarPercent {
  return (1.f-[self.delegate timeLeftForSpeedup]/(float)[self.delegate totalSecondsRequired]);
}

- (void) itemSelected:(id<ItemObject>)io viewController:(id)viewController {
  GameState *gs = [GameState sharedGameState];
  
  if ([io isKindOfClass:[UserItem class]]) {
    UserItem *item = (UserItem *)io;
    if (item.numOwned > 0) {
      [self.nonPurchasedItemsUsed addObject:@(item.itemId)];
    } else if ([item useGemsButton]) {
      if (!_askedGemPermission) {
        int cost = [item costToPurchase];
        NSString *desc = [NSString stringWithFormat:@"Would you like to purchase a %@ for %@ gem%@?", item.name, [Globals commafyNumber:cost], cost == 1 ? @"" : @"s"];
        [GenericPopupController displayGemConfirmViewWithDescription:desc title:@"Use Gems?" gemCost:cost target:self selector:@selector(gemPermissionGranted)];
        
        _gemPermissionItem = io;
        _gemPermissionVc = viewController;
        
        return;
      }
      
      if (gs.gems >= [item costToPurchase]) {
        // No need to use fake gem total since speedups aren't queued up
        //[gs changeFakeGemTotal:-[item costToPurchase]];
      } else {
        [GenericPopupController displayNotEnoughGemsView];
        return;
      }
    } else {
      [Globals addAlertNotification:[NSString stringWithFormat:@"You don't own any %@s.", item.name]];
      return;
    }
    
    [self.usedItems addObject:@([item itemId])];
  }
  
  [self.delegate speedupItemUsed:io viewController:viewController];
}

- (void) gemPermissionGranted {
  _askedGemPermission = YES;
  
  [self itemSelected:_gemPermissionItem viewController:_gemPermissionVc];
  
  _gemPermissionItem = nil;
  _gemPermissionVc = nil;
}

- (NSString *) titleName {
  return @"Speedup Completion";
}

- (void) itemSelectClosed:(id)viewController {
  [self.delegate itemSelectClosed:viewController];
}

- (BOOL) canCloseOnFullBar {
  return YES;
}

@end
