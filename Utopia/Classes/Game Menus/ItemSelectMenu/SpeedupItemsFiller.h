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

- (void) itemUsed:(id<ItemObject>)itemObject viewController:(ItemSelectViewController *)viewController;
- (int) numGemsForTotalSpeedup;

@end

@interface SpeedupItemsFiller : NSObject <ItemSelectDelegate>

@property (nonatomic, retain) NSMutableArray *items;

@property (nonatomic, assign) id<SpeedupItemsFillerDelegate> delegate;

- (void) reloadItemsArray;

@end
