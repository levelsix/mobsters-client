//
//  ResourceItemsFiller.m
//  Utopia
//
//  Created by Ashwin on 11/10/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ResourceItemsFiller.h"

#import "GameState.h"

@implementation ResourceItemsFiller

- (id) initWithResourceType:(ResourceType)resType requiredAmount:(int)requiredAmount shouldAccumulate:(BOOL)accumulate {
  if ((self = [super init])) {
    _resourceType = resType;
    _requiredAmount = requiredAmount;
    _accumulate = accumulate;
    
    _itemType = _resourceType == ResourceTypeCash ? ItemTypeItemCash : ItemTypeItemOil;
    
    self.usedItems = [NSMutableDictionary dictionary];
  }
  return self;
}

- (int) currentAmount {
  Globals *gl = [Globals sharedGlobals];
  return [gl calculateTotalResourcesForResourceType:_resourceType itemIdsToQuantity:self.usedItems];
}

- (void) reloadItemsArray {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *realItems = [[gs.itemUtil getItemsForType:_itemType staticDataId:0] mutableCopy];
  NSMutableArray *userItems = [NSMutableArray array];
  for (ItemProto *ip in gs.staticItems.allValues) {
    if (ip.itemType == _itemType) {
      UserItem *ui = [[UserItem alloc] init];
      ui.itemId = ip.itemId;
      
      int numUsed = [self.usedItems[@(ui.itemId)] intValue];
      
      NSInteger idx = [realItems indexOfObject:ui];
      if (idx != NSNotFound) {
        UserItem *realItem = [realItems objectAtIndex:idx];
        ui.quantity = realItem.quantity-numUsed;
      }
      
      [userItems addObject:ui];
    }
  }
  
  // Add a gems item object.. maybe
  int gems = [gl calculateGemConversionForResourceType:_resourceType amount:_requiredAmount-[self currentAmount]];
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

- (NSString *) titleName {
  if (_accumulate) {
    int missingAmount = _requiredAmount-[self currentAmount];
    return [NSString stringWithFormat:@"MISSING %@ %@", [Globals commafyNumber:missingAmount], [Globals stringForResourceType:_resourceType].uppercaseString];
  } else {
    return [NSString stringWithFormat:@"FILL %@", [Globals stringForResourceType:_resourceType].uppercaseString];
  }
}

- (void) itemSelected:(ItemSelectViewController *)viewController atIndex:(int)idx {
  if (idx < self.items.count) {
    id<ItemObject> io = self.items[idx];
    
    if ([io isKindOfClass:[UserItem class]]) {
      UserItem *ui = (UserItem *)io;
      int numUsed = [self.usedItems[@(ui.itemId)] intValue];
      if ([io numOwned]-numUsed > 0) {
        if (!_accumulate) {
          [self.delegate resourceItemUsed:io viewController:viewController];
        } else {
          self.usedItems[@(ui.itemId)] = @(numUsed+1);
          
          if ([self currentAmount] > _requiredAmount) {
            [self.delegate resourceItemsUsed:self.usedItems];
            [viewController closeClicked:nil];
          } else {
            [viewController reloadDataAnimated:YES];
          }
        }
      } else {
        [Globals addAlertNotification:[NSString stringWithFormat:@"You don't own any %@ packages.", ui.name]];
      }
    } else {
      // Gem object - delegate should recalculate how many gems should be sent..
      if (!_accumulate) {
        [self.delegate resourceItemUsed:io viewController:viewController];
      } else {
        self.usedItems[@0] = @1;
        [self.delegate resourceItemsUsed:self.usedItems];
        [viewController closeClicked:nil];
      }
    }
  }
}

- (void) itemSelectClosed:(id)viewController {
  [self.delegate itemSelectClosed:viewController];
}

@end
