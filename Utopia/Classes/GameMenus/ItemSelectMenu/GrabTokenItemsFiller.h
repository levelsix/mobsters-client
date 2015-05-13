//
//  GrabTokenItemsFiller.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 5/12/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ItemSelectViewController.h"

@protocol GrabTokenItemsFillerDelegate <NSObject>

- (void) itemSelectClosed:(id)viewController;

@optional

- (void) resourceItemUsed:(id<ItemObject>)itemObject viewController:(ItemSelectViewController*)viewController;
- (void) resourceItemsUsed:(NSDictionary*)itemUsages; // Will return a dictionary of itemId -> numUsed. Gems will also be included as itemId 0, should recalculate gems

@end

@interface GrabTokenItemsFiller : NSObject <ItemSelectDelegate, GemsItemDelegate>
{
  ResourceType _resourceType;
  ItemType _itemType;
  int _requiredAmount;
  BOOL _accumulate;
}

@property (nonatomic, assign) ResourceType resourceType;
@property (nonatomic, assign) int requiredAmount;
@property (nonatomic, retain) NSMutableDictionary* usedItems;
@property (nonatomic, assign) id<GrabTokenItemsFillerDelegate> delegate;

- (id) initWithRequiredAmount:(int)requiredAmount;

@end
