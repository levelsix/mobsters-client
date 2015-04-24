//
//  BattleStateMachine.h
//  Utopia
//
//  Created by Rob Giusti on 4/9/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "TransitionKit.h"
#import "BattleState.h"
#import "BattleSchedule.h"

@interface BattleStateMachine : TKStateMachine <BattleScheduleDelegate>

@property NSMutableArray *pastStates;

@property (nonatomic, readonly, getter = getCurrentBattleState) BattleState *currentBattleState;

- (BattleState*) getCurrentBattleState;

- (NSDictionary*) serialize;
- (void) deserialize:(NSDictionary*)data;

@end
