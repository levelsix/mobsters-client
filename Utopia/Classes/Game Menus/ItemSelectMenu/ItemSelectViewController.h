//
//  ItemSelectViewController.h
//  Utopia
//
//  Created by Ashwin on 11/7/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ItemObject.h"
#import "NibUtils.h"

@interface ItemSelectCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *itemIcon;
@property (nonatomic, retain) IBOutlet THLabel *iconLabel;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *quantityLabel;

@property (nonatomic, retain) IBOutlet UILabel *buttonLabel;
@property (nonatomic, retain) IBOutlet UIButton *useButton;

@property (nonatomic, retain) IBOutlet UILabel *gemsLabel;

@property (nonatomic, retain) IBOutlet UIView *useButtonView;
@property (nonatomic, retain) IBOutlet UIView *gemsButtonView;

- (void) updateForItemObject:(id<ItemObject>)itemObject;

@end

@protocol ItemSelectDelegate <NSObject>

- (int) numberOfItems;
- (id<ItemObject>) itemObjectAtIndex:(int)idx;
- (void) itemSelectedAtIndex:(int)idx;
- (NSString *) titleName;

@end

@interface ItemSelectViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UIView *bgdView;
@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *headerView;

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIView *triangle;

@property (nonatomic, retain) IBOutlet UITableView *itemsTable;

@property (nonatomic, retain) IBOutlet ItemSelectCell *selectCell;

@property (nonatomic, assign) id<ItemSelectDelegate> delegate;

- (void) reloadDataAnimated:(BOOL)animated;
- (void) reloadData;

@end
