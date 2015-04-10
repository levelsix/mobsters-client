//
//  BattleState.m
//  Utopia
//
//  Created by Rob Giusti on 4/9/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "BattleState.h"


@implementation BattleState

+ (instancetype)stateWithName:(NSString *)name andType:(CombatReplayStepType)type
{
  BattleState *state = [self stateWithName:name];
  state.combatReplayStepType = type;
  return state;
}

@end