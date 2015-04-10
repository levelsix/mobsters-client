//
//  BattleStateMachine.h
//  Utopia
//
//  Created by Rob Giusti on 4/9/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "TransitionKit.h"
#import "BattleState.h"

@interface BattleStateMachine : TKStateMachine

@property NSMutableArray *pastStates;

@end
