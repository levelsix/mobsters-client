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

- (id) init {
  if ((self = [super init])) {
    self.usedItems = [NSMutableSet set];
  }
  return self;
}

- (NSArray *) reloadItemsArray {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *userItems = [[gs.itemUtil getItemsForType:ItemTypeSpeedUp staticDataId:0] mutableCopy];
  
  for (ItemProto *ip in gs.staticItems.allValues) {
    if (ip.itemType == ItemTypeSpeedUp) {
      UserItem *ui = [[UserItem alloc] init];
      ui.itemId = ip.itemId;
      
      if (![userItems containsObject:ui] && (ip.alwaysDisplayToUser || [self.usedItems containsObject:@(ui.itemId)])) {
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
      BOOL anyOwned1 = [obj1 numOwned] > 0 || [self.usedItems containsObject:@([obj1 itemId])];
      BOOL anyOwned2 = [obj2 numOwned] > 0 || [self.usedItems containsObject:@([obj2 itemId])];
      
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

- (int) numGems {
  return [self.delegate numGemsForTotalSpeedup];
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
    if (![io isKindOfClass:[UserItem class]] || [io numOwned] > 0) {
      if ([io isKindOfClass:[UserItem class]]) {
        [self.usedItems addObject:@([(UserItem *)io itemId])];
      }
      [self.delegate speedupItemUsed:io viewController:viewController];
    } else {
      UserItem *ui = (UserItem *)io;
      [Globals addAlertNotification:[NSString stringWithFormat:@"You don't own any %@s.", ui.name]];
    }
}

- (NSString *) titleName {
  return @"SPEEDUP COMPLETION";
}

- (void) itemSelectClosed:(id)viewController {
  [self.delegate itemSelectClosed:viewController];
}

- (BOOL) canCloseOnFullBar {
  return YES;
}

@end
