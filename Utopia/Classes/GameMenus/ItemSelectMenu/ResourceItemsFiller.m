//
//  ResourceItemsFiller.m
//  Utopia
//
//  Created by Ashwin on 11/10/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ResourceItemsFiller.h"

#import "GameState.h"
#import "GenericPopupController.h"

@implementation ResourceItemsFiller

- (id) initWithResourceType:(ResourceType)resType requiredAmount:(int)requiredAmount shouldAccumulate:(BOOL)accumulate {
  if ((self = [super init])) {
    _resourceType = resType;
    _requiredAmount = requiredAmount;
    _accumulate = accumulate;
    
    _itemType = _resourceType == ResourceTypeCash ? ItemTypeItemCash : ItemTypeItemOil;
    
    self.usedItems = [NSMutableDictionary dictionary];
    self.nonPurchasedItemsUsed = [[NSMutableSet alloc] init];
  }
  return self;
}

- (int) currentAmount {
  Globals *gl = [Globals sharedGlobals];
  if (_accumulate) {
    return MIN(_requiredAmount, [gl calculateTotalResourcesForResourceType:_resourceType itemIdsToQuantity:self.usedItems]);
  } else {
    return MIN(_requiredAmount, [gl calculateTotalResourcesForResourceType:_resourceType itemIdsToQuantity:nil]);
  }
}

- (NSArray *) reloadItemsArray {
  GameState *gs = [GameState sharedGameState];
  
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
        
        if (_accumulate) {
          ui.quantity = MAX(0, realItem.quantity-numUsed);
        } else {
          ui.quantity = realItem.quantity;
        }
      }
      
      if (ip.alwaysDisplayToUser || ui.quantity > 0 || numUsed) {
        [userItems addObject:ui];
      }
    }
  }
  
  // Add a gems item object.. maybe
  int amountLeft = _requiredAmount-[self currentAmount];
  if (amountLeft > 0 || _accumulate) {
    GemsItemObject *gio = [[GemsItemObject alloc] init];
    gio.delegate = self;
    [userItems addObject:gio];
  }
  
  [userItems sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    if ([obj1 isKindOfClass:[UserItem class]] && [obj2 isKindOfClass:[UserItem class]]) {
      // Put items that were used at the top of the list too so that it doesn't look weird flying down
      // And to prevent misclicking if you're using them fast
      BOOL anyOwned1 = [obj1 numOwned] > 0 || [self.nonPurchasedItemsUsed containsObject:@([obj1 itemId])];
      BOOL anyOwned2 = [obj2 numOwned] > 0 || [self.nonPurchasedItemsUsed containsObject:@([obj2 itemId])];
      
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
  Globals *gl = [Globals sharedGlobals];
  int amountLeft = _requiredAmount-[self currentAmount];
  int gems = [gl calculateGemConversionForResourceType:_resourceType amount:amountLeft];
  return gems;
}

- (BOOL) wantsProgressBar {
  return YES;
}

- (TimerProgressBarColor) progressBarColor {
  return _resourceType == ResourceTypeCash ? TimerProgressBarColorGreen : TimerProgressBarColorYellow;
}

- (NSString *) progressBarText {
  return [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:[self currentAmount]], [Globals commafyNumber:_requiredAmount]];
}

- (float) progressBarPercent {
  return [self currentAmount]/(float)_requiredAmount;
}

- (NSString *) titleName {
  if (_accumulate) {
    int missingAmount = _requiredAmount-[self currentAmount];
    return [NSString stringWithFormat:@"MISSING %@ %@", [Globals commafyNumber:missingAmount], [Globals stringForResourceType:_resourceType].uppercaseString];
  } else {
    return [NSString stringWithFormat:@"FILL %@", [Globals stringForResourceType:_resourceType].uppercaseString];
  }
}

- (void) itemSelected:(id<ItemObject>)io viewController:(id)viewController {
  GameState *gs = [GameState sharedGameState];
  
  if ([io isKindOfClass:[UserItem class]]) {
    UserItem *ui = (UserItem *)io;
    int numUsed = [self.usedItems[@(ui.itemId)] intValue];
    
    if (ui.numOwned > 0) {
      [self.nonPurchasedItemsUsed addObject:@(ui.itemId)];
    } else if ([ui useGemsButton]) {
      if (gs.gems >= [ui costToPurchase]) {
        if (_accumulate) {
          [gs changeFakeGemTotal:-[ui costToPurchase]];
        }
      } else {
        [GenericPopupController displayNotEnoughGemsView];
        return;
      }
    } else {
      [Globals addAlertNotification:[NSString stringWithFormat:@"You don't own any %@ packages.", ui.name]];
      return;
    }
    
    self.usedItems[@(ui.itemId)] = @(numUsed+1);
    
    if (!_accumulate) {
      [self.delegate resourceItemUsed:io viewController:viewController];
    } else {
      if ([self currentAmount] >= _requiredAmount) {
        [self.delegate resourceItemsUsed:self.usedItems];
        [viewController closeClicked:nil];
      } else {
        [viewController reloadDataAnimated:YES];
      }
    }
  } else {
    // Gem object - delegate should recalculate how many gems should be sent..
    self.usedItems[@0] = @1;
    if (!_accumulate) {
      [self.delegate resourceItemUsed:io viewController:viewController];
    } else {
      [self.delegate resourceItemsUsed:self.usedItems];
      [viewController closeClicked:nil];
    }
  }
}

- (void) itemSelectClosed:(id)viewController {
  GameState *gs = [GameState sharedGameState];
  [gs disableFakeGemTotal];
  [self.delegate itemSelectClosed:viewController];
}

- (BOOL) canCloseOnFullBar {
  return _accumulate;
}

@end
