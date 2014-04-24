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

- (void) didLoadFromCCB {
  GameState *gs = [GameState sharedGameState];
  self.levelLabel.string = [Globals commafyNumber:gs.level];
  self.spinner.blendFunc = (ccBlendFunc){GL_SRC_ALPHA, GL_ONE};
}

- (void) completedAnimationSequenceNamed:(NSString *)name {
  [self removeFromParent];
}

@end
