//
//  BattleSchedule.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/6/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BattlePlayer.h"

@interface BattleSchedule : NSObject

@property (nonatomic, retain) NSArray *schedule;

@property (nonatomic, assign) int currentIndex;

// Player A should be your character
- (id) initWithBattlePlayerA:(BattlePlayer *)bpA battlePlayerB:(BattlePlayer *)bpB justSwapped:(BOOL)justSwapped;
- (id) initWithSequence:(NSArray *)sequence currentIndex:(int)currentIndex;

// YES means player A gets to attack next
// NO means player B gets to attack next
- (BOOL) dequeueNextMove;

- (NSArray *)getNextNMoves:(int)n;
- (BOOL)getNthMove:(int)n;

@end
