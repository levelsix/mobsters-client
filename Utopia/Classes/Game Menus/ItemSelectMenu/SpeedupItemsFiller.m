//
//  SpeedupItemsFiller.m
//  Utopia
//
//  Created by Ashwin on 11/10/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SpeedupItemsFiller.h"

#import "GameState.h"

@implementation SpeedupItemsFiller

- (void) reloadItemsArray {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *userItems = [[gs.itemUtil getItemsForType:ItemTypeSpeedUp staticDataId:0] mutableCopy];
  
  for (ItemProto *ip in gs.staticItems.allValues) {
    if (ip.itemType == ItemTypeSpeedUp) {
      UserItem *ui = [[UserItem alloc] init];
      ui.itemId = ip.itemId;
      
      if (![userItems containsObject:ui]) {
        [userItems addObject:ui];
      }
    }
  }
  
  [userItems sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    if ([obj1 isKindOfClass:[UserItem class]] && [obj2 isKindOfClass:[UserItem class]]) {
      ItemProto *ip1 = [gs itemForId:[obj1 itemId]];
      ItemProto *ip2 = [gs itemForId:[obj2 itemId]];
      
      return [@(ip1.amount) compare:@(ip2.amount)];
    } else {
      // Prioritize gems
#warning fix
      return NSOrderedAscending;
    }
  }];
  
  self.items = userItems;
}

- (int) numberOfItems {
  return self.items.count;
}

- (id<ItemObject>) itemObjectAtIndex:(int)idx {
  return self.items[idx];
}

- (void) itemSelectedAtIndex:(int)idx {
  NSLog(@"Meep");
}

- (NSString *) titleName {
  return @"SPEEDUP COMPLETION";
}

@end
