//
//  SpeedupItemsFiller.h
//  Utopia
//
//  Created by Ashwin on 11/10/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ItemSelectViewController.h"

@protocol SpeedupItemsFillerDelegate <NSObject>

- (void) speedupItemUsed:(id<ItemObject>)itemObject viewController:(ItemSelectViewController *)viewController;
- (int) numGemsForTotalSpeedup;
- (void) itemSelectClosed:(id)viewController;
- (int) timeLeftForSpeedup;
- (int) totalSecondsRequired;

@end

@interface SpeedupItemsFiller : NSObject <ItemSelectDelegate, GemsItemDelegate> {
  GameActionType _gameActionType;
  
  BOOL _askedGemPermission;
  id _gemPermissionItem;
  id _gemPermissionVc;
}

- (id) initWithGameActionType:(GameActionType)gameActionType;

@property (nonatomic, retain) NSMutableSet *usedItems;
@property (nonatomic, retain) NSMutableSet *nonPurchasedItemsUsed;

@property (nonatomic, weak) id<SpeedupItemsFillerDelegate> delegate;

@end
