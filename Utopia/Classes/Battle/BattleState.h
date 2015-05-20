//
//  BattleState.h
//  Utopia
//
//  Created by Rob Giusti on 4/9/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "TransitionKit.h"
#import "Replay.pb.h"
#import "BattleSwap.h"

//typedef enum CombatReplayStepType {
//  CombatReplayStepTypeBattleInitialization,
//  CombatReplayStepTypeSpawnEnemy,
//  CombatReplayStepTypeNextTurn,
//  CombatReplayStepTypePlayerTurn,
//  CombatReplayStepTypePlayerMove,
//  CombatReplayStepTypePlayerAttack,
//  CombatReplayStepTypeEnemyTurn,
//  CombatReplayStepTypePlayerSwap,
//  CombatReplayStepTypePlayerDeath,
//  CombatReplayStepTypePlayerRevive,
//  CombatReplayStepTypeEnemyDeath,
//  CombatReplayStepTypePlayerVictory
//  
//} CombatReplayStepType;

@interface BattleState : TKState

@property enum CombatReplayStepType combatReplayStepType;

@property CombatReplayStepProto_Builder* combatStepBuilder;

+ (instancetype)stateWithName:(NSString *)name andType:(CombatReplayStepType)type;

- (void) restart;

- (void) setIndex:(int)index;

- (void) addSkillStepForTriggerPoint:(int)skillId belongsToPlayer:(BOOL)belongsToPlayer ownerMonsterId:(int)ownerMonsterId;

- (void) addOrbSwap:(BattleSwap*)swap;
- (void) addOrbMoveAt:(uint)x1 y1:(uint)y1 x2:(uint)x2 y2:(uint)y2;
- (void) addTapAtX:(int)x andY:(int)y;
- (void) addVineAtX:(int)x andY:(int)y;
- (void) addToonSwap:(int)swapIndex;

- (void) addItemUse:(int)itemId;
- (void) addItemUse:(int)itemId xPos:(uint)xPos yPos:(uint)yPos;
- (void) addItemUse:(int)itemId x1:(uint)x1 y1:(uint)y1 x2:(uint)x2 y2:(uint)y2;

- (void) addDamage:(int)damageDone unmodifiedDamage:(int)unmodifiedDamage;
- (void) scheduleRecreated:(NSArray*)schedule startingIndex:(int)startingIndex;

- (CombatReplayStepProto*) getStepProto;

@end
