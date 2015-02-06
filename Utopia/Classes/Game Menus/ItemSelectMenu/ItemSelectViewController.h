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

#import "TimerAction.h"

#import "PopoverViewController.h"

@interface ItemSelectCell : UITableViewCell {
  UIColor *_origIconLabelColor;
}

@property (nonatomic, retain) IBOutlet UIImageView *itemIcon;
@property (nonatomic, retain) IBOutlet THLabel *iconLabel;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *quantityLabel;

@property (nonatomic, retain) IBOutlet UILabel *buttonLabel;
@property (nonatomic, retain) IBOutlet UIButton *useButton;

@property (nonatomic, retain) IBOutlet UILabel *gemsLabel;
@property (nonatomic, retain) IBOutlet UILabel *freeLabel;

@property (nonatomic, retain) IBOutlet UIView *useButtonView;
@property (nonatomic, retain) IBOutlet UIView *gemsButtonView;

- (void) updateForItemObject:(id<ItemObject>)itemObject;
- (void) updateForTime:(id<ItemObject>)itemObject;

@end

@protocol ItemSelectDelegate <NSObject>

- (NSString *) titleName;

- (void) itemSelected:(id<ItemObject>)item viewController:(id)viewController;
- (void) itemSelectClosed:(id)viewController;

- (NSArray *) reloadItemsArray;

- (TimerProgressBarColor) progressBarColor;
- (NSString *) progressBarText;
- (float) progressBarPercent;

// So that speedups will auto close when its at the end
// But the resource bar won't
- (BOOL) canCloseOnFullBar;

@end

@interface ItemSelectViewController : PopoverViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *itemsTable;

@property (nonatomic, retain) IBOutlet UIView *progressBarView;
@property (nonatomic, retain) IBOutlet THLabel *progressBarLabel;
@property (nonatomic, retain) IBOutlet SplitImageProgressBar *progressBar;

@property (nonatomic, retain) IBOutlet ItemSelectCell *selectCell;

@property (nonatomic, retain) NSArray *items;

@property (nonatomic, assign) id<ItemSelectDelegate> delegate;

@property (strong, nonatomic) NSTimer *updateTimer;

- (void) reloadDataAnimated:(BOOL)animated;
- (void) reloadData;

@end
