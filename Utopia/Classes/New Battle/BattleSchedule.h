//
//  BattleSchedule.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/6/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BattlePlayer.h"

@interface BattleSchedule : NSObject {
  int _currentIndex;
}

@property (nonatomic, retain) NSArray *schedule;

// Player A should be your character
- (id) initWithBattlePlayerA:(BattlePlayer *)bpA battlePlayerB:(BattlePlayer *)bpB justSwapped:(BOOL)justSwapped;

// YES means player A gets to attack next
// NO means player B gets to attack next
- (BOOL) dequeueNextMove;

@end
