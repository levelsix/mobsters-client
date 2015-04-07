//
//  TopBarViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/14/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NibUtils.h"
#import "GameMap.h"
#import "ChatBottomView.h"
#import "TopBarQuestProgressView.h"
#import "ShopViewController.h"
#import "HomeViewController.h"
#import "TimerViewController.h"
#import "ResourceItemsFiller.h"

@interface TopBarMonsterView : UIView

@property (nonatomic, retain) IBOutlet UIView *iconView;
@property (nonatomic, retain) IBOutlet MiniMonsterView *monsterView;

@property (nonatomic, retain) IBOutlet UILabel *topLabel;
@property (nonatomic, retain) IBOutlet UILabel *botLabel;

@property (nonatomic, retain) IBOutlet SplitImageProgressBar *healthBar;
@property (nonatomic, retain) IBOutlet UIView *healthBarView;

@end

@interface TopBarViewController : UIViewController <NumTransitionLabelDelegate, ChatBottomViewDelegate, ResourceItemsFillerDelegate> {
  CGPoint _originalProgressCenter;
  
  int _structIdForArrow;
  
  BOOL _isAnimatingFallingGems;
}

@property (nonatomic, assign) IBOutlet SplitImageProgressBar *expBar;
@property (nonatomic, assign) IBOutlet SplitImageProgressBar *cashBar;
@property (nonatomic, assign) IBOutlet SplitImageProgressBar *oilBar;

@property (nonatomic, assign) IBOutlet UILabel *nameLabel;
@property (nonatomic, assign) IBOutlet UILabel *levelLabel;
@property (nonatomic, assign) IBOutlet NumTransitionLabel *expLabel;
@property (nonatomic, assign) IBOutlet NumTransitionLabel *cashLabel;
@property (nonatomic, assign) IBOutlet NumTransitionLabel *oilLabel;
@property (nonatomic, assign) IBOutlet NumTransitionLabel *gemsLabel;
@property (nonatomic, assign) IBOutlet UILabel *cashMaxLabel;
@property (nonatomic, assign) IBOutlet UILabel *oilMaxLabel;
@property (nonatomic, assign) IBOutlet UIImageView *clanIcon;
@property (nonatomic, assign) IBOutlet UIImageView *clanShieldIcon;

@property (nonatomic, assign) IBOutlet UILabel *shieldLabel;
@property (nonatomic, retain) NSTimer *updateTimer;

@property (nonatomic, assign) IBOutlet UIImageView *expBgd;
@property (nonatomic, assign) IBOutlet UIImageView *cashBgd;
@property (nonatomic, assign) IBOutlet UIImageView *oilBgd;

@property (nonatomic, retain) IBOutlet UIView *expView;
@property (nonatomic, retain) IBOutlet UIView *cashView;
@property (nonatomic, retain) IBOutlet UIView *oilView;
@property (nonatomic, retain) IBOutlet UIView *gemsView;
@property (nonatomic, retain) IBOutlet UIView *timersView;

@property (nonatomic, assign) IBOutlet UILabel *timerHeaderLabel;

@property (nonatomic, assign) IBOutlet UILabel *buildersLabel;
@property (nonatomic, assign) IBOutlet UIButton *addBuilderButton;
@property (nonatomic, assign) IBOutlet UIView *saleView;
@property (nonatomic, assign) IBOutlet UIImageView *saleGemsIcon;
@property (nonatomic, assign) IBOutlet UILabel *saleLabel;
@property (nonatomic, assign) IBOutlet UILabel *saleTimeLabel;
@property (nonatomic, assign) IBOutlet UIImageView *saleMultiplierIcon;

@property (nonatomic, retain) IBOutlet UIView *freeGemsView;
@property (nonatomic, retain) IBOutlet UIView *freeGemsSpinner;

@property (nonatomic, retain) IBOutlet UIView *secretGiftView;
@property (nonatomic, retain) IBOutlet UIView *secretGiftTimerView;
@property (nonatomic, retain) IBOutlet UIImageView *secretGiftIcon;
@property (nonatomic, retain) IBOutlet UILabel *secretGiftLabel;

@property (nonatomic, retain) IBOutlet UIView* miniEventView;
@property (nonatomic, retain) IBOutlet UIImageView* miniEventIcon;
@property (nonatomic, retain) IBOutlet UILabel* miniEventLabel;
@property (nonatomic, retain) IBOutlet UILabel* miniEventTimeLabel;
@property (nonatomic, retain) IBOutlet BadgeIcon* miniEventBadge;

@property (nonatomic, retain) IBOutlet BadgeIcon *questBadge;
@property (nonatomic, retain) IBOutlet BadgeIcon *mailBadge;
@property (nonatomic, retain) IBOutlet BadgeIcon *attackBadge;
@property (nonatomic, retain) IBOutlet BadgeIcon *shopBadge;
@property (nonatomic, retain) IBOutlet BadgeIcon *freeGemsBadge;
@property (nonatomic, retain) IBOutlet UIImageView *shopBadgeImage;

@property (nonatomic, retain) IBOutlet UIView *myCityView;
@property (nonatomic, retain) IBOutlet UIView *clanView;
@property (nonatomic, retain) IBOutlet UIView *shopView;
@property (nonatomic, retain) IBOutlet UIView *attackView;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *coinBarsView;
@property (nonatomic, retain) IBOutlet UIView *questView;

@property (nonatomic, retain) IBOutletCollection(UIView) NSArray *topBarMonsterViewContainers;
@property (nonatomic, retain) IBOutlet TopBarMonsterView *topBarMonsterView;
@property (nonatomic, retain) IBOutlet UIView *monsterView;

@property (nonatomic, retain) IBOutlet TopBarQuestProgressView *questProgressView;

@property (nonatomic, retain) IBOutlet ChatBottomView *chatBottomView;

@property (nonatomic, retain) ShopViewController *shopViewController;
@property (nonatomic, retain) IBOutlet TimerViewController *timerViewController;

@property (nonatomic, assign) MapBotView *curViewOverChatView;

@property (nonatomic, retain) ItemSelectViewController *itemSelectViewController;
@property (nonatomic, retain) ResourceItemsFiller *resourceItemsFiller;

- (void) showMyCityView;
- (void) removeMyCityView;
- (void) showClanView;
- (void) removeClanView;

- (IBAction)attackClicked:(id)sender;
- (IBAction)menuClicked:(id)sender;
- (IBAction)questsClicked:(id)sender;
- (void) replaceChatViewWithView:(MapBotView *)view;
- (void) removeViewOverChatView;

- (void) displayQuestProgressViewForQuest:(FullQuestProto *)fqp userQuest:(UserQuest *)uq jobId:(int)jobId completion:(void (^)(void))completion;

- (void) openShop;
- (void) closeShop;
- (void) openShopWithFunds;
- (void) openShopWithBuildings:(int)structId;
- (void) openShopWithGacha;
- (void) showArrowToStructId:(int)structId;

- (void) displayHomeViewController:(HomeViewController *)hvc;

@end
