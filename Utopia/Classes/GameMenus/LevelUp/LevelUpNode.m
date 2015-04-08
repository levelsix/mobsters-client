//
//  LevelUpNode.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/25/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "LevelUpNode.h"
#import "GameState.h"

@implementation LevelUpNode

- (void) animateWithCompletionBlock:(dispatch_block_t)completion {
  [[[CCDirector sharedDirector] runningScene] addChild:self];
  self.position = ccp(self.parent.contentSize.width/2-self.contentSize.width/2, self.parent.contentSize.height/2-self.contentSize.height/2);
  
  _completion = completion;
}

- (void) didLoadFromCCB {
  GameState *gs = [GameState sharedGameState];
  self.levelLabel.string = [Globals commafyNumber:gs.level];
  //self.spinner.blendFunc = (ccBlendFunc){GL_SRC_ALPHA, GL_ONE};
  self.spinner.blendMode = [CCBlendMode blendModeWithOptions:@{CCBlendFuncSrcColor: @(GL_SRC_ALPHA), CCBlendFuncDstColor: @(GL_ONE)}];
}

- (void) completedAnimationSequenceNamed:(NSString *)name {
  [self removeFromParent];
  
  if (_completion) {
    _completion();
    _completion = nil;
  }
}

- (void) endAbruptly {
  [self completedAnimationSequenceNamed:nil];
}

- (NotificationPriority) priority {
  return NotificationPriorityRegular;
}

- (NotificationLocationType) locationType {
  return NotificationLocationTypeFullScreen;
}

@end
