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

@interface BattleItemInfoView : UIView {
  UIColor *_origIconLabelColor;
}

@property (nonatomic, retain) IBOutlet UIImageView *bgdIcon;
@property (nonatomic, retain) IBOutlet UIImageView *itemIcon;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *quantityLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel *typeLabel;
@property (nonatomic, retain) IBOutlet UILabel *powerLabel;

@property (nonatomic, retain) IBOutlet UILabel *gemsLabel;
@property (nonatomic, retain) IBOutlet UILabel *buttonLabel;

@property (nonatomic, retain) IBOutlet UIButton *useButton;
@property (nonatomic, retain) IBOutlet UIButton *gemsButton;
@property (nonatomic, retain) IBOutlet UIImageView *gemIcon;

@property (nonatomic, retain) IBOutlet UIView *useButtonView;
@property (nonatomic, retain) IBOutlet UIView *gemsButtonView;

@property (nonatomic, retain) IBOutlet UIImageView *arrowIcon;

@end

@interface BattleItemSelectCell : UITableViewCell

@property (nonatomic, retain) IBOutlet BattleItemInfoView *infoView;

@end

@protocol BattleItemSelectDelegate <NSObject>

- (void) battleItemSelectClosed:(id)viewController;

- (NSArray *) reloadBattleItemsArray;

@optional
- (void) battleItemSelected:(UserBattleItem *)item viewController:(id)viewController;
- (void) battleItemDiscarded:(UserBattleItem *)item;
- (BOOL) battleItemIsValid:(UserBattleItem *)item;

- (NSString *) progressBarText;
- (float) progressBarPercent;

@end

@interface BattleItemSelectViewController : PopoverViewController <UITableViewDataSource, UITableViewDelegate> {
  BOOL _showUseButton;
  BOOL _showFooterView;
  BOOL _showItemFactory;
  
  BOOL _isEditing;
  
  UserBattleItem *_selectedItem;
}

@property (nonatomic, retain) IBOutlet UITableView *itemsTable;

@property (nonatomic, retain) IBOutlet UIView *progressBarView;
@property (nonatomic, retain) IBOutlet THLabel *progressBarLabel;
@property (nonatomic, retain) IBOutlet SplitImageProgressBar *progressBar;

@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UIView *contentView;

@property (nonatomic, retain) IBOutlet BattleItemInfoView *infoView;
@property (nonatomic, retain) IBOutlet UIView *backView;
@property (nonatomic, retain) IBOutlet UIView *footerView;

@property (nonatomic, retain) IBOutlet UIImageView *footerImageView;
@property (nonatomic, retain) IBOutlet UILabel *footerTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *footerDescLabel;
@property (nonatomic, retain) IBOutlet UILabel *infoTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *editLabel;
@property (nonatomic, retain) IBOutlet UILabel *noItemsLabel;
@property (nonatomic, retain) IBOutlet MaskedButton *editButton;

@property (nonatomic, retain) NSArray *battleItems;

@property (nonatomic, assign) id<BattleItemSelectDelegate> delegate;

- (id) initWithShowUseButton:(BOOL)showUseButton showFooterView:(BOOL)showFooterView showItemFactory:(BOOL)showItemFactory;
- (void) loadInfoViewForBattleItem:(UserBattleItem *)ubi animated:(BOOL)animated;
- (void) reloadDataAnimated:(BOOL)animated;
- (IBAction)closeClicked:(id)sender;

@end