//
//  ReplayBattleLayer.m
//  Utopia
//
//  Created by Rob Giusti on 4/27/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ReplayBattleLayer.h"
#import "GameState.h"
#import "GenericPopupController.h"
#import "ReplayOrbMainLayer.h"

#define DELAY_KEY @"DELAY"
#define SWAP_TOON_KEY @"SWAP_TOON"

@implementation ReplayBattleLayer

- (id) initWithReplay:(CombatReplayProto *)replay {
  _replay = replay;
  
  NSMutableArray *myteam = [NSMutableArray array];
  for (CombatReplayMonsterSnapshot *crms in replay.playerTeamList) {
    UserMonster *um = [UserMonster userMonsterWithReplayMonsterSnapshotProto:crms];
    [myteam addObject:um];
  }
  
  CGSize boardSize = CGSizeMake(replay.board.width, replay.board.height);
  
  if ((self = [super initWithMyUserMonsters:myteam puzzleIsOnLeft:NO gridSize:boardSize bgdPrefix:replay.groundImgPrefix layoutProto:replay.board]))
  {
    _combatSteps = [NSMutableArray array];
    for (CombatReplayStepProto *crsp in replay.stepsList) {
      [_combatSteps addObject:crsp];
    }
  }
  
  [self buildEnemyTeam];
  [self downloadAllImages];
  
  return self;
}

- (void)initOrbLayer {
  ReplayOrbMainLayer *ol = [[ReplayOrbMainLayer alloc] initWithLayoutProto:_replay.board andHistory:_replay.orbsList];
  
  [self addChild:ol z:2];
  ol.delegate = self;
  self.orbLayer = ol;
}

- (void) buildEnemyTeam {
  
  NSMutableArray *defendingTeam = [NSMutableArray array];
  for (CombatReplayMonsterSnapshot *crms in _replay.enemyTeamList) {
    UserMonster *um = [UserMonster userMonsterWithReplayMonsterSnapshotProto:crms];
    BattlePlayer *bp = [BattlePlayer playerWithMonster:um];
    [defendingTeam addObject:bp];
  }
  self.enemyTeam = defendingTeam;
  
}

- (void) downloadAllImages {
  NSMutableSet *imagePrefixes = [NSMutableSet set];
  NSMutableSet *sideEffects = [NSMutableSet set];
  
  for (BattlePlayer *bp in self.myTeam) {
    if (bp.spritePrefix)
      [imagePrefixes addObject:bp.spritePrefix];
    [sideEffects addObjectsFromArray:[Globals skillSideEffectProtosForBattlePlayer:bp enemy:NO]];
  }
  
  for (BattlePlayer *bp in self.enemyTeam) {
    if (bp.spritePrefix)
      [imagePrefixes addObject:bp.spritePrefix];
    [sideEffects addObjectsFromArray:[Globals skillSideEffectProtosForBattlePlayer:bp enemy:YES]];
  }
  
  _isDownloading = YES;
  [Globals downloadAllFilesForSpritePrefixes:imagePrefixes.allObjects completion:^{
    [Globals downloadAllAssetsForSkillSideEffects:sideEffects completion:^{
      _isDownloading = NO;
    }];
  }];
}

- (void)reachedNextScene {
  if (!_hasStarted) {
    if (!self.enemyTeam.count || _isDownloading) {
      _numTimesNotResponded++;
      if (_isDownloading || _numTimesNotResponded < 10) {
        if (_isDownloading && _numTimesNotResponded % 4 == 0) {
          [self.mainView.myPlayer initiateSpeechBubbleWithText:@"Hmm.. Enemies are calibrating."];
        }
        
        [self.mainView.myPlayer beginWalking];
        [self.mainView.bgdLayer scrollToNewScene];
      } else {
        [self.mainView.myPlayer stopWalking];
        [GenericPopupController displayNotificationViewWithText:@"The enemies seem to have been scared off. Tap okay to return outside." title:@"Something Went Wrong" okayButton:@"Okay" target:self selector:@selector(exitFinal)];
      }
    } else {
      [self fireEvent:loadingCompleteEvent userInfo:nil error:nil];
      _hasStarted = YES;
    }
  } else {
    [super reachedNextScene];
  }
}

- (void)fireEvent:(TKEvent *)event userInfo:(NSDictionary *)userInfo error:(NSError *__autoreleasing *)error {
  if ([self.battleStateMachine canFireEvent:event])
    [self startNextStep];
}

- (CombatReplayStepProto *)getCurrStep {
  if (_combatSteps.count)
    return _combatSteps[0];
  @throw [NSException exceptionWithName:@"Out of Steps Exception" reason:@"Attempting to grab info from the current step after the list has been exhausted" userInfo:nil];
  return nil;
}

- (void)startMyMove {
  if (self.currStep.hasItemId) {
#warning Rob -- Item replay starts here
  } else if (self.currStep.hasMovePos1 && self.currStep.hasMovePos2) {
    CGPoint pointA = [self splitPosInt:self.getCurrStep.movePos1];
    CGPoint pointB = [self splitPosInt:self.getCurrStep.movePos2];
    BattleOrb *orbA = [self.orbLayer.layout orbAtColumn:pointA.x row:pointA.y];
    BattleOrb *orbB = [self.orbLayer.layout orbAtColumn:pointB.x row:pointB.y];
    BattleSwap *swap = [[BattleSwap alloc] init];
    swap.orbA = orbA;
    swap.orbB = orbB;
    [self.orbLayer checkSwap:swap];
  } else {
    @throw [NSException exceptionWithName:@"Bad Move" reason:@"Not sufficient move data in current step to recreate move" userInfo:nil];
  }
}

- (CGPoint) splitPosInt:(uint32_t)pos {
  return CGPointMake((pos<<24)>>24, pos>>16);
}

- (void) startNextStep {
  [_combatSteps removeObjectAtIndex:0];
  [self.battleStateMachine forceStateWithType:self.currStep.type];
}

//Override this, so that we can put state transitions where they normally wouldn't be
- (void) setupStateMachine {
  self.battleStateMachine = [BattleStateMachine new];
  
  BattleState *initialState = [BattleState stateWithName:@"Initial Load" andType:CombatReplayStepTypeBattleInitialization];
  
  BattleState *spawnEnemyState = [BattleState stateWithName:@"Spawn Enemy" andType:CombatReplayStepTypeSpawnEnemy];
  [spawnEnemyState setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
    [self moveToNextEnemy];
  }];
  
  BattleState *playerSwapState = [BattleState stateWithName:@"Swap Player" andType:CombatReplayStepTypePlayerSwap];
  [playerSwapState setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
    [self deployBattleSprite:transition.userInfo[SWAP_TOON_KEY]];
  }];
  
  BattleState *playerTurn = [BattleState stateWithName:@"Player Turn" andType:CombatReplayStepTypePlayerTurn];
  [playerTurn setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
    [self beginMyTurn];
  }];
  
  BattleState *playerMove = [BattleState stateWithName:@"Player Move" andType:CombatReplayStepTypePlayerMove];
  [playerMove setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
    [self startMyMove];
  }];
  
  BattleState *playerAttack = [BattleState stateWithName:@"Player Attack" andType:CombatReplayStepTypePlayerAttack];
  [playerAttack setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
//    _myDamageDealt = self.battleStateMachine.currentBattleState
//    [self doMyAttackAnimation];
//    [self.battleStateMachine.currentBattleState addDamage:_myDamageDealt];
  }];
  
  BattleState *enemyTurn = [BattleState stateWithName:@"Enemy Attack" andType:CombatReplayStepTypeEnemyTurn];
  [enemyTurn setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
    [self beginEnemyTurn:[transition.userInfo[DELAY_KEY] floatValue]];
  }];
  
  BattleState *playerVictory = [BattleState stateWithName:@"Player Victory" andType:CombatReplayStepTypePlayerVictory];
  [playerVictory setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
    [self youWon];
  }];
  
  BattleState *playerDeath = [BattleState stateWithName:@"Player Death" andType:CombatReplayStepTypePlayerDeath];
  [playerDeath setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
    [self currentMyPlayerDied];
  }];
  
  BattleState *playerRevive = [BattleState stateWithName:@"Player Revive" andType:CombatReplayStepTypePlayerRevive];
  [playerRevive setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
    [self continueConfirmed];
  }];
  
  [self.battleStateMachine addStates:@[initialState, spawnEnemyState, playerSwapState, playerTurn, playerMove, playerAttack, enemyTurn, playerVictory, playerDeath, playerRevive]];
  
  loadingCompleteEvent = [TKEvent eventWithName:@"Loading complete" transitioningFromStates:@[initialState] toState:spawnEnemyState];
  nextEnemyEvent = [TKEvent eventWithName:@"Spawn Next Enemy" transitioningFromStates:@[ enemyTurn, playerAttack, playerMove ] toState:spawnEnemyState];
  playerSwapEvent = [TKEvent eventWithName:@"Do Swap Players" transitioningFromStates:@[playerTurn, playerDeath, playerMove, playerRevive] toState:playerSwapState];
  playerTurnEvent = [TKEvent eventWithName:@"Player Turn Start" transitioningFromStates:@[initialState, playerSwapState, spawnEnemyState, playerAttack, enemyTurn] toState:playerTurn];
  playerMoveEvent = [TKEvent eventWithName:@"Player Move Start" transitioningFromStates:@[playerTurn, playerMove] toState:playerMove];
  playerAttackEvent = [TKEvent eventWithName:@"Player Attack Start" transitioningFromStates:@[playerTurn, playerMove] toState:playerAttack];
  enemyTurnEvent = [TKEvent eventWithName:@"Enemy Turn Start" transitioningFromStates:@[initialState, playerAttack, enemyTurn, spawnEnemyState, playerSwapState] toState:enemyTurn];
  playerVictoryEvent = [TKEvent eventWithName:@"Player Win Event" transitioningFromStates:@[playerAttack, playerMove, enemyTurn] toState:playerVictory];
  playerDeathEvent = [TKEvent eventWithName:@"Player Death Event" transitioningFromStates:@[playerAttack, playerMove, enemyTurn] toState:playerDeath];
  playerReviveEvent = [TKEvent eventWithName:@"Player Revive Event" transitioningFromStates:@[playerDeath] toState:playerRevive];
  
  [self.battleStateMachine addEvents:@[loadingCompleteEvent, nextEnemyEvent, playerSwapEvent, playerTurnEvent, playerMoveEvent, playerAttackEvent, enemyTurnEvent, playerVictoryEvent, playerDeathEvent, playerReviveEvent]];
  
  self.battleStateMachine.initialState = initialState;
  
  [self.battleStateMachine activate];

}

@end