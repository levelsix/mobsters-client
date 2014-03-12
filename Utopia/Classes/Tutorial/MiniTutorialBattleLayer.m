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
  [self.noInputLayer stopAllActions];
  self.noInputLayer.opacity = 0.f;
  _allowTurnBegin = YES;
  [self beginMyTurn];
}

- (void) beginSecondMove {
  [self.noInputLayer stopAllActions];
  self.noInputLayer.opacity = 0.f;
  [self.orbLayer allowInput];
}

- (void) beginThirdMove {
  [self.noInputLayer stopAllActions];
  self.noInputLayer.opacity = 0.f;
  [self.orbLayer allowInput];
}

- (void) allowMove {
  if (_movesLeft <= 0) {
    _allowTurnBegin = YES;
    [self beginMyTurn];
  } else {
    [self removeNoInputLayer];
  }
  [self.orbLayer allowInput];
}

- (NSString *) presetLayoutFile {
  return nil;
}

#pragma mark - Overwritten methods

- (void) initOrbLayer {
  TutorialOrbLayer *ol = [[TutorialOrbLayer alloc] initWithContentSize:self.orbBgdLayer.contentSize gridSize:self.gridSize numColors:6 presetLayoutFile:[self presetLayoutFile]];
  [self.orbBgdLayer addChild:ol z:2];
  ol.delegate = self;
  self.orbLayer = ol;
}

- (void) beginMyTurn {
  if (_allowTurnBegin) {
    _allowTurnBegin = NO;
    [super beginMyTurn];
  }
}

- (void) beginEnemyTurn {
  [super beginEnemyTurn];
  _enemyDamageDealt = MIN(_enemyDamageDealt, self.myPlayerObject.curHealth-1);
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
    [self displayNoInputLayer];
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
  
  CCSprite *spr = [CCSprite spriteWithImageNamed:@"arrow.png"];
  [self.wonView.doneButton addChild:spr];
  spr.position = ccp(self.wonView.doneButton.contentSize.width+spr.contentSize.width/2+5, self.wonView.doneButton.contentSize.height/2);
  [Globals animateCCArrow:spr atAngle:M_PI];
}

- (void) displaySwapButton {
  if (self.swappableTeamSlot) {
    [super displaySwapButton];
  }
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

@end
