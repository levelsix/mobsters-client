//
//  BattleState.h
//  Utopia
//
//  Created by Rob Giusti on 4/9/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "TransitionKit.h"

typedef enum CombatReplayStepType {
  CombatReplayStepTypeBattleInitialization,
  CombatReplayStepTypeSpawnEnemy,
  CombatReplayStepTypeNextTurn,
  CombatReplayStepTypePlayerTurn,
  CombatReplayStepTypePlayerMove,
  CombatReplayStepTypePlayerAttack,
  CombatReplayStepTypeEnemyTurn,
  CombatReplayStepTypePlayerSwap,
  CombatReplayStepTypePlayerDeath,
  CombatReplayStepTypePlayerRevive,
  CombatReplayStepTypeEnemyDeath,
  CombatReplayStepTypePlayerVictory
  
} CombatReplayStepType;

@interface BattleState : TKState

@property enum CombatReplayStepType combatReplayStepType;

+ (instancetype)stateWithName:(NSString *)name andType:(CombatReplayStepType)type;

@end
