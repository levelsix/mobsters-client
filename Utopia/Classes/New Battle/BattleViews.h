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

@interface BattleLostView : CCNode

@property (nonatomic, retain) CCNode *bgdNode;
@property (nonatomic, retain) CCNode *headerView;
@property (nonatomic, retain) CCSprite *youLostHeader;
@property (nonatomic, retain) CCSprite *spinner;
@property (nonatomic, retain) CCSprite *stickerHead;
@property (nonatomic, retain) CCNode *shareButton;
@property (nonatomic, retain) CCNode *continueButton;
@property (nonatomic, retain) CCNode *doneButton;
@property (nonatomic, retain) CCNode *manageButton;

@end

@interface BattleWonView : CCNode <UIScrollViewDelegate>

@property (nonatomic, retain) CCNode *bgdNode;
@property (nonatomic, retain) CCNode *shareButton;
@property (nonatomic, retain) CCNode *doneButton;
@property (nonatomic, retain) CCNode *manageButton;
@property (nonatomic, retain) CCNode *headerView;
@property (nonatomic, retain) CCSprite *youWonHeader;
@property (nonatomic, retain) CCSprite *spinner;
@property (nonatomic, retain) CCNode *rewardsBgd;
@property (nonatomic, retain) CCNode *rewardsView;

@property (nonatomic, retain) UIScrollView *rewardsScrollView;

- (void) updateForRewards:(NSArray *)rewards;

@end

@interface BattleRewardNode : CCSprite

- (id) initWithReward:(Reward *)reward;

@end

@interface BattleElementView : UIView

- (void) open;
- (void) close;

@end

@interface BattleDeployCardView : UIView

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *emptyView;

@property (nonatomic, retain) IBOutlet UIImageView *bgdIcon;
@property (nonatomic, retain) IBOutlet UIImageView *monsterIcon;
@property (nonatomic, retain) IBOutlet ProgressBar *healthbar;
@property (nonatomic, retain) IBOutlet UILabel *healthLabel;

@end

@interface BattleDeployView : UIView

@property (nonatomic, retain) IBOutletCollection(BattleDeployCardView) NSArray *cardViews;

- (void) updateWithBattlePlayers:(NSArray *)players;

@end

@interface BattleQueueNode : CCNode

@property (nonatomic, retain) IBOutlet CCLabelTTF *nameLabel;
@property (nonatomic, retain) IBOutlet CCLabelTTF *cashLabel;
@property (nonatomic, retain) IBOutlet CCLabelTTF *oilLabel;
@property (nonatomic, retain) IBOutlet CCLabelTTF *nextMatchCostLabel;
@property (nonatomic, retain) IBOutlet CCLabelTTF *leagueLabel;
@property (nonatomic, retain) IBOutlet CCLabelTTF *rankLabel;

@property (nonatomic, retain) IBOutlet CCNode *cashNode;
@property (nonatomic, retain) IBOutlet CCNode *oilNode;
@property (nonatomic, retain) IBOutlet CCNode *leagueNode;
@property (nonatomic, retain) IBOutlet CCNode *nextButtonNode;
@property (nonatomic, retain) IBOutlet CCNode *attackButtonNode;
@property (nonatomic, retain) IBOutlet CCNode *gradientNode;

- (void) updateForPvpProto:(PvpProto *)pvp;
- (void) fadeInAnimation;
- (void) fadeOutAnimation;

@end
