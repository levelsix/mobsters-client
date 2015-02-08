//
//  StageCompleteNode.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/9/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <cocos2d.h>
#import <cocos2d-ui.h>
#import "Protocols.pb.h"
#import "HudNotificationController.h"

@class QuestCompleteLayer;

@protocol StageCompleteDelegate <NSObject>

- (void) stageCompleteNodeBegan;
- (void) stageCompleteNodeCompleted;

@end

@interface StageCompleteNode : CCNode <CCBAnimationManagerDelegate, TopBarNotification> {
  void (^_completionBlock)(void);
  BOOL _clickedButton;
  BOOL _allowInput;
}

@property (nonatomic, retain) CCNode *spinner;
@property (nonatomic, retain) CCLabelTTF *shareLabel;
@property (nonatomic, retain) CCSprite *checkmark;
@property (nonatomic, retain) CCLabelTTF *stageNameLabel;
@property (nonatomic, retain) CCNode *rewardsBox;

@property (nonatomic, retain) CCNode *bgdNode;
@property (nonatomic, retain) CCNode *rewardsBgd;
@property (nonatomic, retain) CCNode *shareNode;
@property (nonatomic, retain) CCButton *continueButton;

@property (nonatomic, assign) id<StageCompleteDelegate> delegate;

- (void) setSectionName:(NSString *)sectionName itemId:(int)itemId;

@end
