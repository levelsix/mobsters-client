//
//  BattleContinueView.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/18/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"
#import "RewardsView.h"
#import "NibUtils.h"
#import "UserData.h"
#import "BattlePlayer.h"
#import <cocos2d.h>
#import <cocos2d-ui.h>

@interface BattleLostView : CCNode <UIScrollViewDelegate>

@property (nonatomic, retain) CCNode *bgdNode;
@property (nonatomic, retain) CCNode *headerView;
@property (nonatomic, retain) CCSprite *youLostHeader;
@property (nonatomic, retain) CCSprite *spinner;
@property (nonatomic, retain) CCSprite *stickerHead;
@property (nonatomic, retain) CCButton *shareButton;
@property (nonatomic, retain) CCButton *continueButton;
@property (nonatomic, retain) CCButton *doneButton;
@property (nonatomic, retain) CCButton *manageButton;
@property (nonatomic, retain) CCNode *lostLabel;
@property (nonatomic, retain) CCNode *rewardsBgd;
@property (nonatomic, retain) CCNode *rewardsView;

@property (nonatomic, retain) CCNode *shareLabel;
@property (nonatomic, retain) CCNode *continueLabel;

@property (nonatomic, retain) UIScrollView *rewardsScrollView;
@property (nonatomic, retain) UIActivityIndicatorView *loadingSpinner;

- (void) updateForRewards:(NSArray *)rewards;

- (void) spinnerOnDone;
- (void) spinnerOnManage;

@end

@interface BattleWonView : CCNode <UIScrollViewDelegate>

@property (nonatomic, retain) CCNode *bgdNode;
@property (nonatomic, retain) CCButton *shareButton;
@property (nonatomic, retain) CCButton *doneButton;
@property (nonatomic, retain) CCButton *manageButton;
@property (nonatomic, retain) CCNode *headerView;
@property (nonatomic, retain) CCSprite *youWonHeader;
@property (nonatomic, retain) CCSprite *spinner;
@property (nonatomic, retain) CCNode *rewardsBgd;
@property (nonatomic, retain) CCNode *rewardsView;

@property (nonatomic, retain) UIScrollView *rewardsScrollView;
@property (nonatomic, retain) UIActivityIndicatorView *loadingSpinner;

- (void) updateForRewards:(NSArray *)rewards;

- (void) spinnerOnDone;
- (void) spinnerOnManage;

@end

@interface BattleRewardNode : CCSprite

- (id) initWithReward:(Reward *)reward isForLoss:(BOOL)loss;

@end

@interface BattleElementView : UIView

- (void) open;
- (void) close;

@end

@interface BattleDeployCardView : UIView

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *emptyView;

@property (nonatomic, retain) IBOutlet MiniMonsterView *monsterView;
@property (nonatomic, retain) IBOutlet ProgressBar *healthbar;
@property (nonatomic, retain) IBOutlet UILabel *healthLabel;

@end

@interface BattleDeployView : UIView

@property (nonatomic, retain) IBOutletCollection(BattleDeployCardView) NSArray *cardViews;

- (void) updateWithBattlePlayers:(NSArray *)players;

@end

@interface BattleQueueNode : CCNode {
  CGPoint _originalRankCenter;
}

@property (nonatomic, retain) IBOutlet CCLabelTTF *nameLabel;
@property (nonatomic, retain) IBOutlet CCLabelTTF *cashLabel;
@property (nonatomic, retain) IBOutlet CCLabelTTF *oilLabel;
@property (nonatomic, retain) IBOutlet CCLabelTTF *nextMatchCostLabel;

@property (nonatomic, retain) IBOutlet CCNode *cashNode;
@property (nonatomic, retain) IBOutlet CCNode *oilNode;
@property (nonatomic, retain) IBOutlet CCNode *leagueNode;
@property (nonatomic, retain) IBOutlet CCNode *nextButtonNode;
@property (nonatomic, retain) IBOutlet CCNode *attackButtonNode;
@property (nonatomic, retain) IBOutlet CCNode *gradientNode;

@property (nonatomic, retain) IBOutlet CCSprite *leagueBgd;
@property (nonatomic, retain) IBOutlet CCSprite *leagueIcon;
@property (nonatomic, retain) IBOutlet CCLabelTTF *rankLabel;
@property (nonatomic, retain) IBOutlet CCLabelTTF *rankQualifierLabel;
@property (nonatomic, retain) IBOutlet CCLabelTTF *leagueLabel;
@property (nonatomic, retain) IBOutlet CCLabelTTF *placeLabel;

@property (nonatomic, retain) IBOutlet CCSprite *monsterBgd;
@property (nonatomic, retain) IBOutlet CCSprite *monsterIcon;

- (void) updateForPvpProto:(PvpProto *)pvp;
- (void) fadeInAnimationForIsRevenge:(BOOL)isRevenge;
- (void) fadeOutAnimation;

@end
