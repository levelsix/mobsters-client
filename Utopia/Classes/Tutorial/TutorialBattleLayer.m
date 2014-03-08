//
//  TutorialBattleLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/3/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialBattleLayer.h"
#import "Globals.h"
#import "TutorialOrbLayer.h"

@implementation TutorialBattleOneLayer

- (id) initWithConstants:(StartupResponseProto_TutorialConstants *)constants {
  if ((self = [super initWithConstants:constants])) {
    Globals *gl = [Globals sharedGlobals];
    UserMonster *um = [[UserMonster alloc] init];
    um.userMonsterId = 1;
    um.monsterId = constants.enemyMonsterId;
    um.level = 1;
    um.curHealth = [gl calculateMaxHealthForMonster:um];
    BattlePlayer *bp = [BattlePlayer playerWithMonster:um];
    self.enemyTeam = [NSArray arrayWithObject:bp];
  }
  return self;
}

- (void) beginFirstMove {
  [super beginFirstMove];
  
  TutorialOrbLayer *orb = (TutorialOrbLayer *)self.orbLayer;
  [orb createOverlayAvoidingPositions:[NSArray arrayWithObjects:
                                       [NSValue valueWithCGPoint:ccp(1, 0)],
                                       [NSValue valueWithCGPoint:ccp(0, 1)],
                                       [NSValue valueWithCGPoint:ccp(1, 1)],
                                       [NSValue valueWithCGPoint:ccp(1, 2)], nil]
                       withForcedMove:[NSSet setWithObjects:
                                       [NSValue valueWithCGPoint:ccp(0, 1)],
                                       [NSValue valueWithCGPoint:ccp(1, 1)], nil]];
}

- (void) beginSecondMove {
  [super beginSecondMove];
  
  TutorialOrbLayer *orb = (TutorialOrbLayer *)self.orbLayer;
  [orb createOverlayAvoidingPositions:[NSArray arrayWithObjects:
                                       [NSValue valueWithCGPoint:ccp(2, 1)],
                                       [NSValue valueWithCGPoint:ccp(3, 2)],
                                       [NSValue valueWithCGPoint:ccp(3, 1)],
                                       [NSValue valueWithCGPoint:ccp(4, 1)], nil]
                       withForcedMove:[NSSet setWithObjects:
                                       [NSValue valueWithCGPoint:ccp(3, 1)],
                                       [NSValue valueWithCGPoint:ccp(3, 2)], nil]];
}

- (NSString *) presetLayoutFile {
  return @"TutorialBattle1Layout.txt";
}

@end

@implementation TutorialBattleTwoLayer

- (id) initWithConstants:(StartupResponseProto_TutorialConstants *)constants enemyDamageDealt:(int)damage {
  if ((self = [super initWithConstants:constants])) {
    Globals *gl = [Globals sharedGlobals];
    UserMonster *um = [[UserMonster alloc] init];
    um.userMonsterId = 1;
    um.monsterId = constants.enemyBossMonsterId;
    um.level = 1;
    um.curHealth = [gl calculateMaxHealthForMonster:um];
    BattlePlayer *bp = [BattlePlayer playerWithMonster:um];
    bp.minDamage = damage;
    bp.maxDamage = damage;
    bp.curHealth = 500;
    bp.maxHealth = 500;
    self.enemyTeam = [NSArray arrayWithObject:bp];
  }
  return self;
}

- (void) beginFirstMove {
  [super beginFirstMove];
  
  TutorialOrbLayer *orb = (TutorialOrbLayer *)self.orbLayer;
  [orb createOverlayAvoidingPositions:[NSArray arrayWithObjects:
                                       [NSValue valueWithCGPoint:ccp(2, 1)],
                                       [NSValue valueWithCGPoint:ccp(3, 2)],
                                       [NSValue valueWithCGPoint:ccp(3, 1)],
                                       [NSValue valueWithCGPoint:ccp(4, 1)],
                                       [NSValue valueWithCGPoint:ccp(5, 1)], nil]
                       withForcedMove:[NSSet setWithObjects:
                                       [NSValue valueWithCGPoint:ccp(3, 1)],
                                       [NSValue valueWithCGPoint:ccp(3, 2)], nil]];
}

- (void) beginSecondMove {
  [super beginSecondMove];
  
  TutorialOrbLayer *orb = (TutorialOrbLayer *)self.orbLayer;
  [orb createOverlayAvoidingPositions:[NSArray arrayWithObjects:
                                       [NSValue valueWithCGPoint:ccp(3, 2)],
                                       [NSValue valueWithCGPoint:ccp(3, 3)],
                                       [NSValue valueWithCGPoint:ccp(3, 4)],
                                       [NSValue valueWithCGPoint:ccp(3, 1)], nil]
                       withForcedMove:[NSSet setWithObjects:
                                       [NSValue valueWithCGPoint:ccp(3, 2)],
                                       [NSValue valueWithCGPoint:ccp(3, 1)], nil]];
}

- (void) swapToMark {
  _orbCount = 0;
  self.swappableTeamSlot = 2;
  [self displaySwapButton];
  
  [self runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:0.3f],
    [CCActionCallBlock actionWithBlock:
     ^{
       [Globals createUIArrowForView:self.swapView atAngle:0];
     }], nil]];
}

- (void) displayDeployViewAndIsCancellable:(BOOL)cancel {
  [super displayDeployViewAndIsCancellable:cancel];
  
  [Globals removeUIArrowFromViewRecursively:self.swapView.superview];
  
  [self runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:0.3f],
    [CCActionCallBlock actionWithBlock:
     ^{
       BattleDeployCardView *card = self.deployView.cardViews[1];
       [Globals createUIArrowForView:card atAngle:M_PI_2];
     }], nil]];
}

- (void) deployBattleSprite:(BattlePlayer *)bp {
  if (bp.slotNum == self.swappableTeamSlot) {
    [super deployBattleSprite:bp];
    [self.delegate swappedToMark];
    [Globals removeUIArrowFromViewRecursively:self.deployView];
  }
}

- (NSString *) presetLayoutFile {
  return @"TutorialBattle2Layout.txt";
}

@end

@implementation TutorialBattleLayer

- (id) initWithConstants:(StartupResponseProto_TutorialConstants *)constants {
  Globals *gl = [Globals sharedGlobals];
  UserMonster *um1 = [[UserMonster alloc] init];
  um1.userMonsterId = 1;
  um1.monsterId = constants.startingMonsterId;
  um1.level = 1;
  um1.curHealth = [gl calculateMaxHealthForMonster:um1];
  um1.teamSlot = 1;
  
  UserMonster *um2 = [[UserMonster alloc] init];
  um2.userMonsterId = 2;
  um2.monsterId = constants.markZmonsterId;
  um2.level = 15;
  um2.curHealth = [gl calculateMaxHealthForMonster:um2];
  um2.teamSlot = 2;
  NSArray *myMons = [NSArray arrayWithObjects:um1, um2, nil];
  if ((self = [super initWithMyUserMonsters:myMons puzzleIsOnLeft:NO])) {
    self.constants = constants;
    
    [self.forfeitButton removeFromSuperview];
    
    self.swappableTeamSlot = 1;
    
    BattlePlayer *mark = self.myTeam[1];
    float mult = 50;
    mark.fireDamage = mult-10;
    mark.waterDamage = mult+10;
    mark.earthDamage = mult+4;
    mark.lightDamage = mult+2;
    mark.nightDamage = mult-3;
    mark.rockDamage = mult-12;
    mark.curHealth = 450;
    mark.maxHealth = 450;
  }
  return self;
}

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
  [self allowMove];
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

#pragma mark - Overwritten methods

- (NSString *) presetLayoutFile {
  return nil;
}

- (CGSize) gridSize {
  return CGSizeMake(6, 6);
}

- (void) initOrbLayer {
  TutorialOrbLayer *ol = [[TutorialOrbLayer alloc] initWithContentSize:self.orbBgdLayer.contentSize gridSize:self.gridSize numColors:6 presetLayoutFile:[self presetLayoutFile]];
  [self.orbBgdLayer addChild:ol z:2];
  ol.delegate = self;
  self.orbLayer = ol;
}

- (void) sendServerUpdatedValues {
  // Do nothing
}

- (void) displayWaveNumber {
  // Do nothing
}

- (void) displaySwapButton {
  if (self.swappableTeamSlot) {
    [super displaySwapButton];
  }
}

- (void) deployBattleSprite:(BattlePlayer *)bp {
  if (bp.slotNum == self.swappableTeamSlot) {
    [super deployBattleSprite:bp];
    self.swappableTeamSlot = 0;
  }
}

- (void) cancelDeploy:(id)sender {
  // Do nothing
}

- (void) begin {
  [super begin];
  [self displayOrbLayer];
}

- (void) beginMyTurn {
  if (_allowTurnBegin) {
    _allowTurnBegin = NO;
    [super beginMyTurn];
  }
}

- (void) reachedNextScene {
  if (!_hasStarted) {
    [self moveToNextEnemy];
    _hasStarted = YES;
  } else {
    [self.myPlayer stopWalking];
    [self.delegate battleLayerReachedEnemy];
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
    [self.delegate moveFinished];
  }
}

- (void) checkMyHealth {
  [self.delegate turnFinished];
}

- (void) youWon {
  [self makeMyPlayerWalkOut];
  [self runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:0.4f],
    [CCActionCallBlock actionWithBlock:
     ^{
       [self.delegate battleComplete:nil];
     }],
    nil]];
}

@end
