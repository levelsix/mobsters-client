//
//  MiniTutorialBattleLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/10/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MiniTutorialBattleLayer.h"
#import "Globals.h"

@implementation MiniTutorialBattleLayer

- (void) beginFirstMove {
  [self.orbLayer.bgdLayer turnTheLights:YES instantly:YES];
  _allowTurnBegin = YES;
  [self beginMyTurn];
}

- (void) beginSecondMove {
  [self.orbLayer.bgdLayer turnTheLights:YES instantly:YES];
  [self.orbLayer allowInput];
}

- (void) beginThirdMove {
  [self.orbLayer.bgdLayer turnTheLights:YES instantly:YES];
  [self.orbLayer allowInput];
}

- (void) allowMove {
  if (_movesLeft <= 0) {
    _allowTurnBegin = YES;
    [self beginMyTurn];
  } else {
    [self.orbLayer.bgdLayer turnTheLightsOn];
  }
  [self.orbLayer allowInput];
}

- (NSString *) presetLayoutFile {
  return nil;
}

#pragma mark - Overwritten methods

- (void) initOrbLayer {
  TutorialOrbLayer *ol = [[TutorialOrbLayer alloc] initWithGridSize:self.gridSize numColors:6 presetLayoutFile:[self presetLayoutFile]];
  [self addChild:ol z:2];
  ol.delegate = self;
  self.orbLayer = ol;
}

- (CGPoint) myPlayerLocation {
  return ccpAdd(MY_PLAYER_LOCATION, ccpMult(POINT_OFFSET_PER_SCENE, 0.08));
}

- (void) beginMyTurn {
  if (_allowTurnBegin) {
    _allowTurnBegin = NO;
    [super beginMyTurn];
    
    self.hudView.swapView.hidden = self.swappableTeamSlot == 0;
    [self.hudView removeSwapButton];
  }
}

- (void) beginEnemyTurn:(float)delay {
  [super beginEnemyTurn:delay];
  self.enemyDamageDealt = MIN(self.enemyDamageDealt, self.myPlayerObject.curHealth-1);
}

- (void) displayWaveNumber {
  // Do nothing
}

- (void) reachedNextScene {
  if (!_hasStarted) {
    [super reachedNextScene];
  } else {
    [self.myPlayer stopWalking];
    if ([self.delegate respondsToSelector:@selector(battleLayerReachedEnemy)]) {
      [self.delegate battleLayerReachedEnemy];
    }
  }
}

- (void) moveBegan {
  [super moveBegan];
  [self.delegate moveMade];
}

- (void) checkIfAnyMovesLeft {
  if (_movesLeft == 0) {
    [self myTurnEnded];
  } else {
    [self.orbLayer.bgdLayer turnTheLightsOff];
    _myDamageForThisTurn = 0;
    if ([self.delegate respondsToSelector:@selector(moveFinished)]) {
      [self.delegate moveFinished];
    }
  }
}

- (void) checkMyHealth {
  [self sendServerUpdatedValues];
  [self.delegate turnFinished];
}

- (void) youWon {
  [super youWon];
  [self checkQuests];
  
  NSInteger c = self.endView.rewardsView.children.count;
  [self runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:2.4+0.5*c],
    [CCActionCallBlock actionWithBlock:
     ^{
       CCSprite *spr = [CCSprite spriteWithImageNamed:@"arrow.png"];
       [self.endView.doneButton addChild:spr];
       spr.position = ccp(self.endView.doneButton.contentSize.width+spr.contentSize.width/2+5, self.endView.doneButton.contentSize.height/2);
       [spr runAction:[CCActionFadeIn actionWithDuration:0.4]];
       [Globals animateCCArrow:spr atAngle:M_PI];
     }], nil]];
}

- (void) winExitClicked:(id)sender {
  [super winExitClicked:sender];
  
  // Don't let it wait for the end dungeon response
  if ([self canSkipResponseWait]) {
    [self exitFinal];
  }
}

- (BOOL) canSkipResponseWait {
  return YES;
}

- (void) deployBattleSprite:(BattlePlayer *)bp {
  if (!_hasStarted || bp.slotNum == self.swappableTeamSlot) {
    [super deployBattleSprite:bp];
    self.swappableTeamSlot = 0;
  }
}

- (void) cancelDeploy:(id)sender {
  // Do nothing
}

- (void) shareClicked:(id)sender {
  // Do nothing
}

- (void) manageClicked:(id)sender {
  // Do nothing
}

- (CGSize) gridSize {
  return CGSizeMake(6, 6);
}

@end
