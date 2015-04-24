//
//  BattleStateMachine.m
//  Utopia
//
//  Created by Rob Giusti on 4/9/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "BattleStateMachine.h"

@implementation BattleStateMachine

- (id)init
{
  self = [super init];
  self.pastStates = [NSMutableArray array];
  return self;
}

- (BattleState*)getCurrentBattleState{
  return (BattleState*)self.currentState;
}

- (void)addState:(TKState *)state
{
  if (![state isKindOfClass:[BattleState class]]) {
    [NSException raise:NSInvalidArgumentException format:@"Expected a `BattleState` object or `NSString` object specifying the name of a state, instead got a `%@` (%@)", [state class], state];
  }
  [super addState:state];
}

- (void)activate {
  [super activate];
  [self.currentBattleState restart];
}

- (BOOL)fireEvent:(id)eventOrEventName userInfo:(NSDictionary *)userInfo error:(NSError *__autoreleasing *)error
{
  BattleState *lastState = self.currentBattleState;
  if ([self canFireEvent:eventOrEventName])
  {
    if (lastState.combatReplayStepType != CombatReplayStepTypeBattleInitialization) {
      [lastState setIndex:(int)self.pastStates.count];
      [self.pastStates addObject:[lastState getStepProto]];
    }
    NSLog(@"Transitioning from %@ to %@", lastState.name, ((TKEvent*)(eventOrEventName)).destinationState.name);
    [super fireEvent:eventOrEventName userInfo:userInfo error:error];
    return YES;
  }
  NSLog(@"Transition failed for event: %@", eventOrEventName);
  return NO;
}

- (void)forceStateWithType:(CombatReplayStepType)stepType {
  BattleState *state;
  for (BattleState *bs in self.states)
    if (bs.combatReplayStepType == stepType)
      state = bs;
  [self forceState:state];
}

- (void) scheduleRecreated:(NSArray*)schedule startingIndex:(int)startingIndex {
  [self.currentBattleState scheduleRecreated:schedule startingIndex:startingIndex];
}

- (NSString *)description
{
  NSString *str = @"Battle: ";
  
  for (CombatReplayStepProto *step in self.pastStates){
    str = [str stringByAppendingString:step.description];
  }
  return str;
}

- (NSDictionary*) serialize
{
  NSMutableDictionary *data = [NSMutableDictionary dictionary];
  int i = 0;
  for (CombatReplayStepProto *step in self.pastStates) {
    NSString *datastring = [step.data base64EncodedStringWithOptions:0];
    if (!datastring)
      NSLog(@"Um what? %@", step.data);
    else
      [data setObject:datastring forKey:[NSString stringWithFormat:@"step%i", i++]];
  }
  [data setObject:@(i) forKey:@"numsteps"];
  return data;
}

- (void) deserialize:(NSDictionary*)data
{
  self.pastStates = [NSMutableArray array];
  int numSteps = [[data objectForKey:@"numsteps"] intValue];
  for (int i = 0; i < numSteps; i++) {
    NSData *stepData =  [[NSData alloc] initWithBase64EncodedData:[data objectForKey:[NSString stringWithFormat:@"step%i", i]] options:0];
    [self.pastStates addObject:[CombatReplayStepProto parseFromData:stepData]];
  }
}


@end