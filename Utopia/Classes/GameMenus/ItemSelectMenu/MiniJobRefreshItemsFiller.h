//
//  MiniJobRefreshItemsFiller.h
//  Utopia
//
//  Created by Kenneth Cox on 4/9/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItemSelectViewController.h"

@protocol RefreshItemsFillerDelegate <NSObject>

- (void) itemSelectClosed:(id)viewController;
- (void) refreshItemUsed:(id<ItemObject>)itemObject viewController:(ItemSelectViewController *)viewController gems:(int)gems;

@end

@interface MiniJobRefreshItemsFiller : NSObject <ItemSelectDelegate, GemsItemDelegate>

@property (nonatomic, retain) NSMutableSet *usedItems;

@property (nonatomic, assign) id<RefreshItemsFillerDelegate> delegate;

@end
