//
//  ReplayBattleLayer.m
//  Utopia
//
//  Created by Rob Giusti on 4/27/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ReplayBattleLayer.h"
#import "GameState.h"

#define DELAY_KEY @"DELAY"
#define SWAP_TOON_KEY @"SWAP_TOON"

@implementation ReplayBattleLayer

- (void)initWithReplay:(CombatReplayProto *)replay {
  _replay = replay;
}

- (void) buildEnemyTeam {
  GameState *gs = [GameState sharedGameState];
  
  NSMutableArray *defendingTeam = [NSMutableArray array];
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
//    [self startMyMove];
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