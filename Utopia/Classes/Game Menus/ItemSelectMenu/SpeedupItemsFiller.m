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
  
  // Add a gems item object.. maybe
  int gems = [self.delegate numGemsForTotalSpeedup];
  GemsItemObject *gio = [[GemsItemObject alloc] initWithNumGems:gems];
  [userItems addObject:gio];
  
  [userItems sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    if ([obj1 isKindOfClass:[UserItem class]] && [obj2 isKindOfClass:[UserItem class]]) {
      ItemProto *ip1 = [gs itemForId:[obj1 itemId]];
      ItemProto *ip2 = [gs itemForId:[obj2 itemId]];
      
      return [@(ip1.amount) compare:@(ip2.amount)];
    } else if ([obj1 class] != [obj2 class]) {
      // Prioritize gems
      return [obj1 isKindOfClass:[GemsItemObject class]] ? NSOrderedAscending : NSOrderedDescending;
    }
    return NSOrderedSame;
  }];
  
  self.items = userItems;
}

- (int) numberOfItems {
  return (int)self.items.count;
}

- (id<ItemObject>) itemObjectAtIndex:(int)idx {
  return self.items[idx];
}

- (void) itemSelected:(id)viewController atIndex:(int)idx {
  if (idx < self.items.count) {
    id<ItemObject> io = self.items[idx];
    [self.delegate itemUsed:io viewController:viewController];
  }
}

- (NSString *) titleName {
  return @"SPEEDUP COMPLETION";
}

- (void) itemSelectClosed:(id)viewController {
  [self.delegate itemSelectClosed];
}

@end
