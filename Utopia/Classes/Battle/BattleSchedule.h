//
//  BattleSchedule.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/6/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BattlePlayer.h"

typedef enum
{
  ScheduleFirstTurnPlayer = 0,
  ScheduleFirstTurnEnemy  = 1,
  ScheduleFirstTurnRandom = 2
} ScheduleFirstTurn;

@interface BattleSchedule : NSObject

@property (nonatomic, retain) NSArray *schedule;

@property (nonatomic, assign) int currentIndex;

// Player A should be your character
- (id) initWithPlayerA:(int)speedA playerB:(int)speedB andOrder:(ScheduleFirstTurn)order;
- (id) initWithSequence:(NSArray *)sequence currentIndex:(int)currentIndex;

// YES means player A gets to attack next
// NO means player B gets to attack next
- (BOOL) dequeueNextMove;

- (NSArray *)getNextNMoves:(int)n;
- (BOOL)getNthMove:(int)n;

// Used by skillManager for Cake Drop schedule reset
- (void) createScheduleForPlayerA:(int)speedA playerB:(int)speedB andOrder:(ScheduleFirstTurn)order;

@end
