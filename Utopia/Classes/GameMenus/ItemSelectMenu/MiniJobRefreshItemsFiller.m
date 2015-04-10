//
//  MiniJobRefreshItemsFiller.m
//  Utopia
//
//  Created by Kenneth Cox on 4/9/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "MiniJobRefreshItemsFiller.h"

#import "GameState.h"

@implementation MiniJobRefreshItemsFiller

- (void) itemSelected:(id<ItemObject>)item viewController:(id)viewController {
  if ([self.delegate respondsToSelector:@selector(refreshItemUsed:viewController:)]) {
    [self.delegate refreshItemUsed:item viewController:viewController];
  }
}

- (void) itemSelectClosed:(id)viewController {
  [self.delegate itemSelectClosed:viewController];
}

- (TimerProgressBarColor) progressBarColor {
  return TimerProgressBarColorGreen;
}

- (float) progressBarPercent {
  return 1.f;
}

- (NSString *) progressBarText {
  return @"no one should see this";
}

- (int) numGems {
  //gems item not used
  return 999;
}

- (NSString *) titleName {
  return @"Refresh Items";
}

- (NSArray *) reloadItemsArray {
  GameState *gs = [GameState sharedGameState];
  
  NSMutableArray *realItems = [[gs.itemUtil getItemsForType:ItemTypeRefreshMiniJob staticDataId:0] mutableCopy];
  NSMutableArray *userItems = [NSMutableArray array];
  for (ItemProto *ip in gs.staticItems.allValues) {
    if (ip.itemType == ItemTypeRefreshMiniJob) {
      UserItem *ui = [[UserItem alloc] init];
      ui.itemId = ip.itemId;
      
      int numUsed = [self.usedItems[@(ui.itemId)] intValue];
      
      NSInteger idx = [realItems indexOfObject:ui];
      if (idx != NSNotFound) {
        UserItem *realItem = [realItems objectAtIndex:idx];

        ui.quantity = realItem.quantity;
      }
      
      if (ip.alwaysDisplayToUser || ui.quantity > 0 || numUsed) {
        [userItems addObject:ui];
      }
    }
  }
  
  [userItems sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    if ([obj1 isKindOfClass:[UserItem class]] && [obj2 isKindOfClass:[UserItem class]]) {
      // Put items that were used at the top of the list too so that it doesn't look weird flying down
      // And to prevent misclicking if you're using them fast
      BOOL anyOwned1 = [obj1 numOwned] > 0 || self.usedItems[@([obj1 itemId])];
      BOOL anyOwned2 = [obj2 numOwned] > 0 || self.usedItems[@([obj2 itemId])];
      
      if (anyOwned1 != anyOwned2) {
        return [@(anyOwned2) compare:@(anyOwned1)];
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

- (BOOL) canCloseOnFullBar {
  //bar not used
  return NO;
}

@end
