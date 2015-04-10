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
@optional
- (void) refreshItemUsed:(id<ItemObject>)itemObject viewController:(ItemSelectViewController *)viewController;

@end

@interface MiniJobRefreshItemsFiller : NSObject <ItemSelectDelegate, GemsItemDelegate>

@property (nonatomic, retain) NSMutableDictionary *usedItems;

@property (nonatomic, assign) id<RefreshItemsFillerDelegate> delegate;

@end
