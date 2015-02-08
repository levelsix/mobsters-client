//
//  PvpRankUpNode.m
//  Utopia
//
//  Created by Ashwin Kamath on 9/16/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PvpRankUpNode.h"

#import "UserData.h"
#import "QuestCompleteLayer.h"
#import "Globals.h"
#import "GameState.h"

@implementation PvpRankUpNode

- (void) didLoadFromCCB {
  [self.spinner runAction:
   [CCActionRepeatForever actionWithAction:
    [CCActionRotateBy actionWithDuration:4 angle:360.f]]];
  
  self.shareLabel.fontName = @"Aller-BoldItalic";
  self.stageNameLabel.fontName = @"Gotham-UltraItalic";
  
  self.userInteractionEnabled = YES;
  self.bgdNode.zOrder = -2;
}

- (void) setSectionName:(NSString *)sectionName itemId:(int)itemId {
  self.stageNameLabel.string = [sectionName uppercaseString];
  
  Reward *reward = [[Reward alloc] initWithItemId:itemId quantity:1];
  
  QuestRewardNode *node = [[QuestRewardNode alloc] initWithReward:reward];
  node.position = ccp(self.rewardsBox.contentSize.width/2, self.rewardsBox.contentSize.height/2);
  [self.rewardsBox addChild:node];
}

- (void) animateWithCompletionBlock:(dispatch_block_t)completion {
  [[[CCDirector sharedDirector] runningScene] addChild:self];
  self.anchorPoint = ccp(0.5, 0.5);
  self.position = ccp(self.parent.contentSize.width/2, self.parent.contentSize.height/2);
  
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
  
  self.stageNameLabel.parent.zOrder = 1;
  
  _completionBlock = completion;
}

- (void) completedAnimationSequenceNamed:(NSString *)name {
  _allowInput = YES;
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
  //lines.blendFunc = (ccBlendFunc){GL_SRC_ALPHA, GL_ONE};
  lines.blendMode = [CCBlendMode blendModeWithOptions:@{CCBlendFuncSrcColor: @(GL_SRC_ALPHA), CCBlendFuncDstColor: @(GL_ONE)}];
  lines.position = ccp(0, clip.contentSize.height/2);
  
  [lines runAction:
   [CCActionSequence actions:
    [CCActionEaseIn actionWithAction:[CCActionMoveTo actionWithDuration:0.45f position:ccp(clip.contentSize.width, clip.contentSize.height/2)]
                                rate:2.f],
    [CCActionCallBlock actionWithBlock:^{ [clip removeFromParent]; }], nil]];
  
  [self.stageNameLabel.parent addChild:clip];
  self.stageNameLabel.zOrder = 1;
}

- (void) checkmarkClicked:(id)sender {
  if (_allowInput) {
    self.checkmark.visible = !self.checkmark.visible;
  }
}

- (void) continueClicked:(id)sender {
  if (!_clickedButton && _allowInput) {
    _clickedButton = YES;
    
    [self end];
  }
}

- (void) end {
  [self.spinner removeFromParent];
  [self runAction:
   [CCActionSequence actions:
    [RecursiveFadeTo actionWithDuration:0.5 opacity:0.f],
    [CCActionCallBlock actionWithBlock:
     ^{
       [self.delegate pvpRankNodeCompleted];
       
       if (_completionBlock)
         _completionBlock();
     }],
    [CCActionRemove action], nil]];
}

- (void) endAbruptly {
  [self end];
}

- (NotificationPriority) priority {
  return NotificationPriorityFirst;
}

- (NotificationLocationType) locationType {
  return NotificationLocationTypeFullScreen;
}

@end
