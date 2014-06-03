//
//  QuestCompleteLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/8/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <cocos2d.h>
#import "Protocols.pb.h"
#import "RewardsView.h"
#import <cocos2d-ui.h>

@interface QuestRewardNode : CCNode

@end

@class QuestCompleteLayer;

@protocol QuestCompleteDelegate <NSObject>

- (void) questCompleteLayerCompleted:(QuestCompleteLayer *)questComplete withNewQuest:(FullQuestProto *)quest;

@end

@interface QuestCompleteLayer : CCNode <CCBAnimationManagerDelegate> {
  int _questId;
  void (^_completionBlock)(void);
  BOOL _clickedButton;
  BOOL _allowInput;
}

@property (nonatomic, retain) CCNode *spinner;
@property (nonatomic, retain) CCLabelTTF *shareLabel;
@property (nonatomic, retain) CCSprite *checkmark;
@property (nonatomic, retain) CCLabelTTF *questNameLabel;
@property (nonatomic, retain) CCNode *rewardsBox;

@property (nonatomic, retain) CCNode *bgdNode;
@property (nonatomic, retain) CCNode *rewardsBgd;
@property (nonatomic, retain) CCNode *shareNode;
@property (nonatomic, retain) CCButton *continueButton;

@property (nonatomic, retain) UIActivityIndicatorView *loadingSpinner;

@property (nonatomic, assign) id<QuestCompleteDelegate> delegate;

- (void) animateForQuest:(FullQuestProto *)fqp completion:(void (^)(void))completion;

@end
