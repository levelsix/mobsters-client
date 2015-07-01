//
//  ResourceItemsFiller.h
//  Utopia
//
//  Created by Ashwin on 11/10/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ItemSelectViewController.h"

@protocol ResourceItemsFillerDelegate <NSObject>

- (void) itemSelectClosed:(id)viewController;

@optional
- (void) resourceItemUsed:(id<ItemObject>)itemObject viewController:(ItemSelectViewController *)viewController;

// Will return a dictionary of itemId -> numUsed. Gems will also be included as itemId 0, should recalculate gems.
- (void) resourceItemsUsed:(NSDictionary *)itemUsages;

@end


@interface ResourceItemsFiller : NSObject <ItemSelectDelegate, GemsItemDelegate> {
  ResourceType _resourceType;
  ItemType _itemType;
  int _requiredAmount;
  BOOL _accumulate;
  
  BOOL _askedGemPermission;
  id _gemPermissionItem;
  id _gemPermissionVc;
}

@property (nonatomic, assign) ResourceType resourceType;
@property (nonatomic, assign) int requiredAmount;

- (id) initWithResourceType:(ResourceType)resType requiredAmount:(int)requiredAmount shouldAccumulate:(BOOL)accumulate;

@property (nonatomic, retain) NSMutableDictionary *usedItems;
@property (nonatomic, retain) NSMutableSet *nonPurchasedItemsUsed;

@property (nonatomic, weak) id<ResourceItemsFillerDelegate> delegate;

@end
