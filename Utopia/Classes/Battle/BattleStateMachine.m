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

- (void)addState:(TKState *)state
{
  if (![state isKindOfClass:[BattleState class]]) {
    [NSException raise:NSInvalidArgumentException format:@"Expected a `BattleState` object or `NSString` object specifying the name of a state, instead got a `%@` (%@)", [state class], state];
  }
  [super addState:state];
}

- (BOOL)fireEvent:(id)eventOrEventName userInfo:(NSDictionary *)userInfo error:(NSError *__autoreleasing *)error
{
  BattleState *lastState = (BattleState*)[self currentState];
  if ([super fireEvent:eventOrEventName userInfo:userInfo error:error])
  {
    [self.pastStates addObject:lastState];
    return YES;
  }
  return NO;
}

@end