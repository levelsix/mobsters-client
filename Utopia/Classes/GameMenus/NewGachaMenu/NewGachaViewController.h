//
//  NewGachaViewController.h
//  Utopia
//
//  Created by Behrouz N. on 12/18/14.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenViewController.h"
#import "EasyTableView.h"
#import "Protocols.pb.h"
#import "NewGachaFocusScrollView.h"
#import "NewGachaViews.h"
#import "BattleHudView.h"
#import "NewGachaTicker.h"
#import "PurchaseHighRollerModeViewController.h"
#import "GrabTokenItemsFiller.h"

@interface NewGachaViewController : GenViewController <EasyTableViewDelegate, NewGachaFocusScrollViewDelegate, TabBarDelegate,
  NewGachaFeaturedViewCallbackDelegate, BattleSkillCounterPopupCallbackDelegate, PurchaseHighRollerModeCallbackDelegate, GrabTokenItemsFillerDelegate>
{
  BOOL _isSpinning;
  BOOL _isMultiSpinAvailable;

  NSArray* _lastSpinPrizes;             // List of BoosterItemProtos awarded in the last spin
  NSArray* _lastSpinMonsterDescriptors; // List of dictionaries containing monster IDs and corresponding number of puzzle pieces awarded in the last spin
  
  NSInteger _cachedDailySpin;
  BOOL      _lastSpinWasFree;
  BOOL      _lastSpinWasMultiSpin;
  
  int _lastSpinPurchaseGemsSpent;
  int _lastSpinPurchaseTokensChange;
  
  NewGachaTicker* _tickerController;
}

@property (nonatomic, retain) BoosterPackProto *boosterPack;
@property (nonatomic, retain) BoosterPackProto *badBoosterPack;
@property (nonatomic, retain) BoosterPackProto *goodBoosterPack;
@property (nonatomic, retain) NSArray *items;

@property (nonatomic, retain) EasyTableView *gachaTable;
@property (nonatomic, retain) IBOutlet UIView *tableContainerView;
@property (nonatomic, retain) IBOutlet NewGachaFocusScrollView *focusScrollView;
@property (nonatomic, retain) IBOutlet UIImageView *machineImage;
@property (nonatomic, retain) IBOutlet UIImageView *logoImage;
@property (nonatomic, retain) IBOutlet UIImageView *logoSeparatorImage;

@property (nonatomic, retain) IBOutlet UIImageView* gachaBgTopLeft;
@property (nonatomic, retain) IBOutlet UIImageView* gachaBgBottomRight;

@property (nonatomic, retain) IBOutlet UIView *singleSpinContainer;
@property (nonatomic, retain) IBOutlet THLabel *singleSpinGemCostLabel;
@property (nonatomic, retain) IBOutlet UIImageView *singleSpinGemCostIcon;
@property (nonatomic, retain) IBOutlet UIView *singleSpinGemCostView;
@property (nonatomic, retain) IBOutlet UIView *singleSpinView;
@property (nonatomic, retain) IBOutlet UIButton *singleSpinButton;
@property (nonatomic, retain) IBOutlet THLabel *singleSpinActionLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *singleSpinSpinner;

@property (nonatomic, retain) IBOutlet UIView *multiSpinContainer;
@property (nonatomic, retain) IBOutlet THLabel *multiSpinGemCostLabel;
@property (nonatomic, retain) IBOutlet UIImageView *multiSpinGemCostIcon;
@property (nonatomic, retain) IBOutlet UIView *multiSpinGemCostView;
@property (nonatomic, retain) IBOutlet UIView *multiSpinView;
@property (nonatomic, retain) IBOutlet UIButton *multiSpinButton;
@property (nonatomic, retain) IBOutlet THLabel *multiSpinActionLabel;
@property (nonatomic, retain) IBOutlet THLabel *multiSpinTapToUnlockLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *multiSpinSpinner;

@property (nonatomic, retain) IBOutlet NewGachaItemCell *itemCell;
@property (nonatomic, retain) IBOutlet NewGachaFeaturedView *featuredView;
@property (nonatomic, retain) IBOutlet NewGachaPrizeView *prizeView;

@property (nonatomic, retain) IBOutlet ButtonTabBar *navBar;
@property (nonatomic, retain) IBOutlet BadgeIcon *badBadge;
@property (nonatomic, retain) IBOutlet BadgeIcon *goodBadge;
@property (nonatomic, retain) IBOutlet BadgeIcon *eventBadge;
@property (nonatomic, retain) IBOutlet UIButton *addTokensButton;

@property (nonatomic, retain) IBOutlet BattleSkillCounterPopupView* skillPopup;
@property (nonatomic, retain) IBOutlet UIButton* skillPopupCloseButton;

@property (nonatomic, retain) IBOutlet UIImageView* ticker;

@property (nonatomic, retain) IBOutlet UIView* itemSelectFooterView;
@property (nonatomic, retain) IBOutlet UILabel* itemSelectPackagesLabel;
@property (nonatomic, retain) IBOutlet UILabel* itemSelectTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel* itemSelectDescriptionLabel;

@property (nonatomic, retain) ItemSelectViewController *itemSelectViewController;
@property (nonatomic, retain) GrabTokenItemsFiller *grabTokenItemsFiller;
@property (nonatomic, assign) UIButton *buttonInvokingItemSelect;

- (id) initWithBoosterPack:(BoosterPackProto *)bpp;

- (IBAction) singleSpinClicked:(id)sender;
- (IBAction) multiSpinClicked:(id)sender;
- (IBAction) showItemSelect:(id)sender;
- (IBAction) itemSelectToPackagesClicked:(id)sender;
- (IBAction) hideSkillPopup:(id)sender;

@end
