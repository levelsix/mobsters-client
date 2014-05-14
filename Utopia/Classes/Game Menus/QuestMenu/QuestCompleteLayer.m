//
//  QuestCompleteLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/8/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "QuestCompleteLayer.h"
#import "GameState.h"
#import "GameViewController.h"
#import "OutgoingEventController.h"

#define SPACING_PER_NODE 68.f

@implementation QuestRewardNode

- (id) initWithReward:(Reward *)reward {
  GameState *gs = [GameState sharedGameState];
  NSString *imgName = nil;
  NSString *labelName = nil;
  UIColor *color = nil;
  if (reward.type == RewardTypeMonster) {
    MonsterProto *mp = [gs monsterWithId:reward.monsterId];
    imgName = [Globals imageNameForRarity:mp.quality suffix:@"piece.png"];
    labelName = [Globals stringForRarity:mp.quality];
    color = [Globals colorForRarity:mp.quality];
  } else if (reward.type == RewardTypeSilver) {
    imgName = @"moneystack.png";
    labelName = [Globals cashStringForNumber:reward.silverAmount];
    color = [Globals greenColor];
  } else if (reward.type == RewardTypeOil) {
    imgName = @"oilicon.png";
    labelName = [Globals commafyNumber:reward.oilAmount];
    color = [Globals goldColor];
  } else if (reward.type == RewardTypeGold) {
    imgName = @"diamond.png";
    labelName = [Globals commafyNumber:reward.goldAmount];
    color = [Globals purplishPinkColor];
  } else if (reward.type == RewardTypeItem) {
    ItemProto *item = [gs itemForId:reward.itemId];
    imgName = item.imgName;
    labelName = item.name;
    color = [Globals creamColor];
  }
  
  if ((self = [super init])) {
    CCSprite *inside = [CCSprite spriteWithImageNamed:imgName];
    [self addChild:inside];
    inside.position = ccp(0, 9);
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:labelName fontName:@"GothamBlack" fontSize:13.f];
    label.color = [CCColor colorWithUIColor:color];
    [self addChild:label];
    label.position = ccp(0, -20);
  }
  return self;
}

@end

@implementation QuestCompleteLayer

- (void) didLoadFromCCB {
  [self.spinner runAction:
   [CCActionRepeatForever actionWithAction:
    [CCActionRotateBy actionWithDuration:4 angle:360.f]]];
  
  self.shareLabel.fontName = @"Aller-BoldItalic";
  self.questNameLabel.fontName = @"Gotham-UltraItalic";
  
  self.userInteractionEnabled = YES;
  self.bgdNode.zOrder = -2;
}

- (void) animateForQuest:(FullQuestProto *)fqp completion:(void (^)(void))completion {
  self.questNameLabel.string = [fqp.name uppercaseString];
  
  NSArray *rewards = [Reward createRewardsForQuest:fqp];
  if (rewards.count > 2) rewards = [rewards subarrayWithRange:NSMakeRange(0, 2)];
  
  for (int i = 0; i < rewards.count; i++) {
    QuestRewardNode *node = [[QuestRewardNode alloc] initWithReward:rewards[i]];
    node.position = ccp((2*i+1-(int)rewards.count)/2.f*SPACING_PER_NODE+self.rewardsBox.contentSize.width/2,
                        self.rewardsBox.contentSize.height/2);
    [self.rewardsBox addChild:node];
  }
  
  [self.shareNode recursivelyApplyOpacity:0];
  [self.continueButton recursivelyApplyOpacity:0];
  
  CCSprite *stencil = [CCSprite spriteWithImageNamed:@"prizesbg.png"];
  CCClippingNode *clip = [CCClippingNode clippingNodeWithStencil:stencil];
  clip.contentSize = stencil.contentSize;
  clip.alphaThreshold = 0.1;
  clip.anchorPoint = ccp(0.5, 0.5);
  clip.position = self.rewardsBgd.position;
  [self addChild:clip];
  stencil.position = ccp(clip.contentSize.width/2, clip.contentSize.height/2);
  
  [self.rewardsBgd removeFromParentAndCleanup:NO];
  [clip addChild:self.rewardsBgd];
  self.rewardsBgd.position = ccp(clip.contentSize.width/2, clip.contentSize.height*3/2);
  
  [self.spinner runAction:[CCActionRepeatForever actionWithAction:[CCActionRotateBy actionWithDuration:4.f angle:180]]];
  self.spinner.opacity = 0.f;
  
  self.questNameLabel.parent.zOrder = 1;
  
  _questId = fqp.questId;
  
  _completionBlock = completion;
}

- (void) completedAnimationSequenceNamed:(NSString *)name {
  [self.rewardsBgd runAction:
   [CCActionSequence actions:
    [CCActionMoveBy actionWithDuration:0.3 position:ccp(0, -self.rewardsBgd.contentSize.height)],
    [CCActionCallFunc actionWithTarget:self selector:@selector(animateBottomButtons)], nil]];
}

- (void) animateBottomButtons {
  float duration = 0.3;
  
  int amtToMove = 30;
  self.shareNode.position = ccpAdd(self.shareNode.position, ccp(-amtToMove, 0));
  [self.shareNode runAction:
   [CCActionSpawn actions:
    [CCActionMoveBy actionWithDuration:duration position:ccp(amtToMove, 0)],
    [RecursiveFadeTo actionWithDuration:duration opacity:1.f], nil]];
  
  self.continueButton.position = ccpAdd(self.continueButton.position, ccp(amtToMove, 0));
  [self.continueButton runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:duration],
    [CCActionSpawn actions:
     [CCActionMoveBy actionWithDuration:duration position:ccp(-amtToMove, 0)],
     [RecursiveFadeTo actionWithDuration:duration opacity:1.f], nil], nil]];
  
  [self runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:duration*2],
    [CCActionCallFunc actionWithTarget:self selector:@selector(showQuestGlowSlide)], nil]];
  
  [self.spinner runAction:[CCActionFadeTo actionWithDuration:0.3 opacity:0.4f]];
  
  //CCParticleSystem *ps = [CCParticleSystem particleWithFile:@"questcompleteball.plist"];
  //ps.position = self.spinner.position;
  //[self addChild:ps z:-1];
}

- (void) showQuestGlowSlide {
  CCSprite *stencil = [CCSprite spriteWithImageNamed:@"questnameribbonmask.png"];
  CCClippingNode *clip = [CCClippingNode clippingNodeWithStencil:stencil];
  clip.contentSize = stencil.contentSize;
  stencil.position = ccp(stencil.contentSize.width/2, stencil.contentSize.height/2);
  clip.alphaThreshold = 0.5;
  
  CCSprite *lines = [CCSprite spriteWithImageNamed:@"questlines.png"];
  [clip addChild:lines];
  lines.blendFunc = (ccBlendFunc){GL_SRC_ALPHA, GL_ONE};
  lines.position = ccp(0, clip.contentSize.height/2);
  
  [lines runAction:
   [CCActionSequence actions:
    [CCActionEaseIn actionWithAction:[CCActionMoveTo actionWithDuration:0.45f position:ccp(clip.contentSize.width, clip.contentSize.height/2)]
                                rate:2.f],
    [CCActionCallBlock actionWithBlock:^{ [clip removeFromParent]; }], nil]];
  
  [self.questNameLabel.parent addChild:clip];
  self.questNameLabel.zOrder = 1;
}

- (void) checkmarkClicked:(id)sender {
  self.checkmark.visible = !self.checkmark.visible;
}

- (void) continueClicked:(id)sender {
  if (!_clickedButton) {
    _clickedButton = YES;
    
    [[OutgoingEventController sharedOutgoingEventController] redeemQuest:_questId delegate:self];
    
    self.continueButton.title = @"";
    CGPoint center = [self.continueButton.parent convertToWorldSpace:self.continueButton.position];
    self.loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.loadingSpinner startAnimating];
    [Globals displayUIView:self.loadingSpinner];
    self.loadingSpinner.center = [[CCDirector sharedDirector] convertToUI:center];
  }
}

- (void) fakeClose {
  [self removeFromParent];
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *arr = gs.inProgressIncompleteQuests.allValues.mutableCopy;
  [arr shuffle];
  [[GameViewController baseController] questComplete:arr[0]];
}

- (void) onExitTransitionDidStart {
  [self.loadingSpinner removeFromSuperview];
  [super onExitTransitionDidStart];
}

- (void) closeWithBlock:(void (^)(void))completion {
  [self.loadingSpinner removeFromSuperview];
  [self runAction:
   [CCActionSequence actions:
    [RecursiveFadeTo actionWithDuration:0.5 opacity:0.f],
    [CCActionCallBlock actionWithBlock:
     ^{
       if (completion) completion();
     }],
    [CCActionRemove action], nil]];
}

#pragma mark - Redeem quest delegate

- (void) handleQuestRedeemResponseProto:(FullEvent *)fe {
  QuestRedeemResponseProto *proto = (QuestRedeemResponseProto *)fe.event;
  
  FullQuestProto *quest = nil;
  for (FullQuestProto *fqp in proto.newlyAvailableQuestsList) {
    if (fqp.hasAcceptDialogue) {
      quest = fqp;
      break;
    }
  }
  
  [self closeWithBlock:^{
    [self.delegate questCompleteLayerCompleted:self withNewQuest:quest];
    
    if (_completionBlock) {
      _completionBlock();
    }
  }];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:QUESTS_CHANGED_NOTIFICATION object:nil];
  
  [QuestUtil checkAllDonateQuests];
}

@end
