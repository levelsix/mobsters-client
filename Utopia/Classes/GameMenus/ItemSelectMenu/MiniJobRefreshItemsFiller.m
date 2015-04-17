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

- (id) init {
  if ((self = [super init])) {
    self.usedItems = [NSMutableSet set];
  }
  return self;
}

- (void) itemSelected:(id<ItemObject>)io viewController:(id)viewController {
  if (![io isKindOfClass:[UserItem class]] || [io numOwned] >= 0) {
    if ([io isKindOfClass:[UserItem class]]) {
      [self.usedItems addObject:@([(UserItem *)io itemId])];
    }
    [self.delegate refreshItemUsed:io viewController:viewController];
  } else {
    UserItem *ui = (UserItem *)io;
    [Globals addAlertNotification:[NSString stringWithFormat:@"You don't own any %@s.", ui.name]];
  }
}

- (void) itemSelectClosed:(id)viewController {
  [self.delegate itemSelectClosed:viewController];
}

- (int) numGems {
  //gems item not used
  return 999;
}

- (NSString *) titleName {
  return @"REFRESH ITEMS";
}

- (NSArray *) reloadItemsArray {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *userItems = [[gs.itemUtil getItemsForType:ItemTypeRefreshMiniJob staticDataId:0] mutableCopy];
  
  for (ItemProto *ip in gs.staticItems.allValues) {
    if (ip.itemType == ItemTypeRefreshMiniJob) {
      UserItem *ui = [[UserItem alloc] init];
      ui.itemId = ip.itemId;
      
      if (![userItems containsObject:ui] && (ip.alwaysDisplayToUser || [self.usedItems containsObject:@(ui.itemId)])) {
        [userItems addObject:ui];
      }
    }
  }
  
  [userItems sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    ItemProto *ip1 = [gs itemForId:[obj1 itemId]];
    ItemProto *ip2 = [gs itemForId:[obj2 itemId]];
    
    return [@(ip1.quality) compare:@(ip2.quality)];
  }];
  
  return userItems;
}

- (BOOL) canCloseOnFullBar {
  //bar not used
  return NO;
}

@end
