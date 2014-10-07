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

@interface BattleEndView : CCNode <UIScrollViewDelegate>

@property (nonatomic, retain) CCNode *bgdNode;

@property (nonatomic, retain) CCNode *headerView;
@property (nonatomic, retain) CCSprite *topLabelHeader;
@property (nonatomic, retain) CCSprite *botLabelHeader;
@property (nonatomic, retain) CCSprite *spinner;

@property (nonatomic, retain) CCSprite *ribbon;
@property (nonatomic, retain) CCLabelTTF *ribbonLabel;
@property (nonatomic, retain) CCNode *rewardsBgd;
@property (nonatomic, retain) CCNode *rewardsView; // Created in file
@property (nonatomic, retain) CCSprite *stickerHead;

@property (nonatomic, retain) CCButton *shareButton;
@property (nonatomic, retain) CCButton *continueButton;
@property (nonatomic, retain) CCButton *doneButton;

@property (nonatomic, retain) CCLabelTTF *tipLabel;

@property (nonatomic, retain) UIScrollView *rewardsScrollView;
@property (nonatomic, retain) UIActivityIndicatorView *loadingSpinner;

- (void) updateForRewards:(NSArray *)rewards isWin:(BOOL)isWin;

- (void) spinnerOnDone;

@end

@interface BattleRewardNode : CCSprite

- (id) initWithReward:(Reward *)reward isForLoss:(BOOL)loss;

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
