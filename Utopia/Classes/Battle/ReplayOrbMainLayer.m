//
//  ReplayOrbMainLayer.m
//  Utopia
//
//  Created by Rob Giusti on 4/30/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+PerformBlockAfterDelay.h"
#import "ReplayOrbMainLayer.h"
#import "ReplayBattleOrbLayout.h"

@implementation ReplayOrbMainLayer

- (void) setupHand {
  self.handSprite = [CCSprite spriteWithImageNamed:@"hand.png"];
  self.handSprite.anchorPoint = ccp(0.065, 0.735);
  self.handSprite.rotation = 30;
}

- (id)initWithLayoutProto:(BoardLayoutProto *)proto andHistory:(NSArray *)orbHistory {
  ReplayBattleOrbLayout *layout = [[ReplayBattleOrbLayout alloc] initWithBoardLayout:proto andOrbHistory:orbHistory];
  if (self = [self initWithGridSize:CGSizeMake(layout.numColumns, layout.numRows) numColors:layout.numColors layout:layout]) {
    [self setupHand];
  }
  return self;
}

- (id)initWithGridSize:(CGSize)gridSize numColors:(int)numColors andHistory:(NSArray *)orbHistory {
  ReplayBattleOrbLayout *layout = [[ReplayBattleOrbLayout alloc] initWithGridSize:gridSize numColors:numColors andOrbHistory:orbHistory];
  if (self = [self initWithGridSize:gridSize numColors:numColors layout:layout]) {
    [self setupHand];
  }
  return self;
}

- (id)initWithGridSize:(CGSize)gridSize userBoardObstacles:(NSArray *)userBoardObstacles andHistory:(NSArray*)orbHistory {
  ReplayBattleOrbLayout *layout = [[ReplayBattleOrbLayout alloc] initWithGridSize:gridSize userBoardObstacles:userBoardObstacles andHistory:orbHistory];
  if (self = [self initWithGridSize:gridSize numColors:layout.numColors layout:layout]){
    [self setupHand];
  }
  return self;
}

- (void) tapDownOnSpace:(int)x spaceY:(int)y {
  BattleOrb* orb = [self.layout orbAtColumn:x row:y];
  BattleTile* tile = [self.layout tileAtColumn:x row:y];
  [self tapDownOnOrb:orb tile:tile];
}

- (void) moveHandBetweenOrbs:(CGPoint)startOrb endPoint:(CGPoint)endPoint withCompletion:(void (^)())completion {
  BattleOrb *gem1 = [self.layout orbAtColumn:startOrb.x row:startOrb.y];
  BattleOrb *gem2 = [self.layout orbAtColumn:endPoint.x row:endPoint.y];
  
  CGPoint startPos = [self.swipeLayer pointForColumn:gem1.column row:gem1.row];
  CGPoint endPos = [self.swipeLayer pointForColumn:gem2.column row:gem2.row];
  
  self.handSprite.position = startPos;
  [self addChild:self.handSprite z:101];
  
  self.handSprite.opacity = 0.f;
  CCActionMoveBy *move = [CCActionEaseIn actionWithAction:[CCActionMoveBy actionWithDuration:0.3f position:ccpSub(endPos, startPos)] rate:2.f];
  [self.handSprite runAction:
    [CCActionSequence actions:
     [CCActionFadeIn actionWithDuration:0.1f],
     [CCActionDelay actionWithDuration:0.2f],
     [CCActionCallBlock actionWithBlock:^{
      [self performBlockAfterDelay:0.15f block:^{
        completion();
      }];
     }],
     move,
     [CCActionDelay actionWithDuration:0.1f],
     [CCActionFadeOut actionWithDuration:0.3f],
     [CCActionCallBlock actionWithBlock:^{
      [self.handSprite removeFromParent];
    }],
     nil]];
}

- (void)checkVines {
  if ([self.delegate hasVinePos]) {
    CGPoint vinePos = [self.delegate getVinePos];
    BattleOrb *orb = [self.layout orbAtColumn:vinePos.x row:vinePos.y];
    [self spawnVinesOnOrb:orb];
  }
}

@end