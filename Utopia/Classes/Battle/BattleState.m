//
//  BattleState.m
//  Utopia
//
//  Created by Rob Giusti on 4/9/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "BattleState.h"
#import "BattleSwap.h"
#import "BattleOrb.h"

@implementation BattleState

+ (instancetype)stateWithName:(NSString *)name andType:(CombatReplayStepType)type
{
  BattleState *state = [BattleState new];
  state.name = name;
  state.combatReplayStepType = type;
  [state setWillEnterStateBlock:^(TKState *state, TKTransition *transition) {
    [((BattleState*)state) restart];
  }];
  
  return state;
}

- (void) restart {
  if (!self.combatStepBuilder)
    self.combatStepBuilder = [CombatReplayStepProto builder];
  
  [self.combatStepBuilder clear];
  self.combatStepBuilder.type = self.combatReplayStepType;
}

- (void) setIndex:(int)index {
  [self.combatStepBuilder setStepIndex:index];
}

#pragma mark Skill recording

- (void) addSkillStepForTriggerPoint:(SkillTriggerPoint)triggerPoint skillId:(int)skillId belongsToPlayer:(BOOL)belongsToPlayer ownerMonsterId:(int)ownerMonsterId {
  [self.combatStepBuilder addSkills:[[[[[[CombatReplaySkillStepProto builder]
                                                     setTriggerPoint:triggerPoint]
                                                    setSkillId:skillId]
                                                   setBelongsToPlayer:belongsToPlayer]
                                                  setOwnerMonsterId:ownerMonsterId]
                                                 build]];
}

#pragma mark Moves and Item use recording

- (void) addOrbSwap:(BattleSwap*)swap {
  [self addOrbMoveAt:(uint)swap.orbA.column y1:(uint)swap.orbA.row x2:(uint)swap.orbB.column y2:(uint)swap.orbB.row];
}

- (void) addOrbMoveAt:(uint)x1 y1:(uint)y1 x2:(uint)x2 y2:(uint)y2 {
  self.combatStepBuilder.movePos1 = [self combineInts:x1 int2:y1];
  self.combatStepBuilder.movePos2 = [self combineInts:x2 int2:y2];
}

- (void) addItemUse:(int)itemId {
  self.combatStepBuilder.itemId = itemId;
}

- (void) addItemUse:(int)itemId xPos:(uint)xPos yPos:(uint)yPos {
  [self addItemUse:itemId];
  self.combatStepBuilder.movePos1 = [self combineInts:xPos int2:yPos];
}

- (void) addItemUse:(int)itemId x1:(uint)x1 y1:(uint)y1 x2:(uint)x2 y2:(uint)y2 {
  [self addItemUse:itemId];
  [self addOrbMoveAt:x1 y1:y1 x2:x2 y2:y2];
}

- (void) addDamage:(int)damageDone unmodifiedDamage:(int)unmodifiedDamage {
  self.combatStepBuilder.modifiedDamage = damageDone;
  self.combatStepBuilder.unmodifiedDamage = unmodifiedDamage;
}

//Puts the second int into the high 16 bits of the first int and returns.
//If either int has a value >
- (uint) combineInts:(uint)int1 int2:(uint)int2 {
  
  return ((int1<<24)>>24) | (int2<<16);
}

- (void) scheduleRecreated:(NSArray*)schedule startingIndex:(int)startingIndex {
  NSMutableArray *playerTurns = [NSMutableArray array];
  for (int i = 0; i < schedule.count; i++)
    if ([schedule[i] boolValue])
        [playerTurns addObject:@(i)];
  
  self.combatStepBuilder.schedule = [[[[[CombatReplayScheduleProto builder]
                                        setTotalTurns:(int)schedule.count]
                                       addAllPlayerTurns:playerTurns]
                                      setStartingTurn:startingIndex]
                                     build];
}

- (CombatReplayStepProto*) getStepProto {
  return [self.combatStepBuilder build];
}

@end