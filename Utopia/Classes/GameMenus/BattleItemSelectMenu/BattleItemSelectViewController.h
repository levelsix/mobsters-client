//
//  BattleItemSelectViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/12/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "PopoverViewController.h"

#import "BattleItemUtil.h"
#import "NibUtils.h"

#import "PopoverViewController.h"

@interface BattleItemSelectCell : UITableViewCell {
  UIColor *_origIconLabelColor;
}

@property (nonatomic, retain) IBOutlet UIImageView *itemIcon;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *quantityLabel;

@property (nonatomic, retain) IBOutlet UILabel *gemsLabel;
@property (nonatomic, retain) IBOutlet UILabel *buttonLabel;

@property (nonatomic, retain) IBOutlet UIButton *useButton;
@property (nonatomic, retain) IBOutlet UIButton *gemsButton;
@property (nonatomic, retain) IBOutlet UIImageView *gemIcon;

@property (nonatomic, retain) IBOutlet UIView *useButtonView;
@property (nonatomic, retain) IBOutlet UIView *gemsButtonView;

- (void) updateForBattleItem:(UserBattleItem *)itemObject isValid:(BOOL)isValid showButton:(BOOL)showButton;

@end

@protocol BattleItemSelectDelegate <NSObject>

- (void) battleItemSelected:(UserBattleItem *)item viewController:(id)viewController;
- (void) battleItemSelectClosed:(id)viewController;

- (NSArray *) reloadItemsArray;

- (NSString *) progressBarText;
- (float) progressBarPercent;

@end

@interface BattleItemSelectViewController : PopoverViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *itemsTable;

@property (nonatomic, retain) IBOutlet UIView *progressBarView;
@property (nonatomic, retain) IBOutlet THLabel *progressBarLabel;
@property (nonatomic, retain) IBOutlet SplitImageProgressBar *progressBar;

@property (nonatomic, retain) IBOutlet BattleItemSelectCell *selectCell;

@property (nonatomic, retain) NSArray *battleItems;

@property (nonatomic, assign) id<BattleItemSelectDelegate> delegate;

- (void) reloadDataAnimated:(BOOL)animated;

@end