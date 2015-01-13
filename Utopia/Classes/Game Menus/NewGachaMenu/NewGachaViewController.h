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

@interface NewGachaViewController : GenViewController
<EasyTableViewDelegate, NewGachaFocusScrollViewDelegate, TabBarDelegate, NewGachaFeaturedViewCallbackDelegate, BattleSkillCounterPopupCallbackDelegate> {
  BOOL _isSpinning;
  
  NSInteger _curPage;
  
  NSInteger _numPuzzlePieces;
  
  NSInteger _cachedDailySpin;
  BOOL      _lastSpinWasFree;
}

@property (nonatomic, retain) BoosterPackProto *boosterPack;
@property (nonatomic, retain) BoosterPackProto *badBoosterPack;
@property (nonatomic, retain) BoosterPackProto *goodBoosterPack;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) BoosterItemProto *prize;

@property (nonatomic, retain) EasyTableView *gachaTable;
@property (nonatomic, retain) IBOutlet UIView *tableContainerView;
@property (nonatomic, retain) IBOutlet NewGachaFocusScrollView *focusScrollView;
@property (nonatomic, retain) IBOutlet UIImageView *machineImage;
@property (nonatomic, retain) IBOutlet UIImageView *logoImage;
@property (nonatomic, retain) IBOutlet UIImageView *logoSeparatorImage;

@property (nonatomic, retain) IBOutlet UILabel *gemCostLabel;
@property (nonatomic, retain) IBOutlet UIView *gemCostView;
@property (nonatomic, retain) IBOutlet UIView *spinView;
@property (nonatomic, retain) IBOutlet UIButton *spinButton;
@property (weak, nonatomic) IBOutlet UILabel *spinActionLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, retain) IBOutlet NewGachaItemCell *itemCell;
@property (nonatomic, retain) IBOutlet NewGachaFeaturedView *featuredView;
@property (nonatomic, retain) IBOutlet NewGachaPrizeView *prizeView;

@property (nonatomic, retain) IBOutlet NewGachaTabBar *navBar;
@property (nonatomic, retain) IBOutlet BadgeIcon *badBadge;
@property (nonatomic, retain) IBOutlet BadgeIcon *goodBadge;
@property (nonatomic, retain) IBOutlet BadgeIcon *eventBadge;

@property (nonatomic, retain) IBOutlet BattleSkillCounterPopupView* skillPopup;
@property (nonatomic, retain) IBOutlet UIButton* skillPopupCloseButton;

- (id) initWithBoosterPack:(BoosterPackProto *)bpp;

- (IBAction) hideSkillPopup:(id)sender;

@end
