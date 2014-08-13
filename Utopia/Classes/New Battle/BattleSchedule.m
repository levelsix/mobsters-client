//
//  BattleSchedule.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/6/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "BattleSchedule.h"

#import "Globals.h"

@implementation BattleSchedule

- (id) initWithBattlePlayerA:(BattlePlayer *)bpA battlePlayerB:(BattlePlayer *)bpB justSwapped:(BOOL)justSwapped {
  if ((self = [super init])) {
    NSMutableArray *sch = [NSMutableArray array];
    
    if (!bpA.speed || !bpB.speed) {
      [sch addObject:@YES];
      [sch addObject:@NO];
      
      LNLog(@"Cannot create proper schedule. Using default..");
    } else {
      int speedA = bpA.speed, speedB = bpB.speed;
      int numInterleavings = MIN(speedA, speedB);
      
      // If its a swap, B always gets to go first
      BOOL firstAttackerIsA = justSwapped ? NO : [self chooseFirstAttackerWithSpeedA:speedA speedB:speedB];
      int numBpA = 1, numBpB = 1;
      if (speedA < speedB) {
        numBpB = speedB/speedA;
      } else {
        numBpA = speedA/speedB;
      }
      
      // Add the initial interleaving
      // Whoever is first attacker will be placed into queue first
      for (int i = 0; i < numInterleavings; i++) {
        if (firstAttackerIsA) {
          for (int j = 0; j < numBpA; j++) {
            [sch addObject:@YES];
          }
          for (int j = 0; j < numBpB; j++) {
            [sch addObject:@NO];
          }
        } else {
          for (int j = 0; j < numBpB; j++) {
            [sch addObject:@NO];
          }
          for (int j = 0; j < numBpA; j++) {
            [sch addObject:@YES];
          }
        }
        
        speedA -= numBpA;
        speedB -= numBpB;
      }
      
      // Now we place the leftovers into the initial slots
      int numLeft = MAX(speedA, speedB);
      BOOL val = speedA ? YES : NO;
      BOOL firstAttkIsVal = speedA ? firstAttackerIsA : !firstAttackerIsA;
      int numToSkip = speedA ? numBpB : numBpA;
      
      if (numLeft) {
        // Choose the interleavings
        NSMutableArray *arr = [NSMutableArray array];
        for (int i = 0; i < numInterleavings; i++) {
          [arr addObject:@(i)];
        }
        [arr shuffle];
        NSArray *slots = [arr subarrayWithRange:NSMakeRange(0, numLeft)];
        slots = [slots sortedArrayUsingSelector:@selector(compare:)];
        
        for (NSNumber *num in slots.reverseObjectEnumerator) {
          int slot = num.intValue;
          int idx = slot * (numBpA + numBpB) + (firstAttkIsVal ? 0 : numToSkip);
          [sch insertObject:@(val) atIndex:idx];
        }
      }
    }
    
    NSMutableString *str = [NSMutableString stringWithFormat:@""];
    for (NSNumber *n in sch) {
      [str appendFormat:@"%@ ", n];
    }
    LNLog(@"Creating schedule with speedA: %d, speedB: %d, isSwap: %d", bpA.speed, bpB.speed, justSwapped);
    LNLog(@"%@", str);
    
    _currentIndex = -1;
    self.schedule = sch;
  }
  return self;
}

- (id) initWithSequence:(NSArray *)sequence currentIndex:(int)currentIndex {
  if ((self = [super init])) {
    self.schedule = sequence;
    _currentIndex = currentIndex;
  }
  return self;
}

- (BOOL) chooseFirstAttackerWithSpeedA:(int)speedA speedB:(int)speedB {
  int total = speedA + speedB;
  return (arc4random() % total) < speedA;
}

- (BOOL) dequeueNextMove {
  _currentIndex = (_currentIndex+1) % (self.schedule.count);
  
  NSNumber *num = self.schedule[_currentIndex];
  return [num boolValue];
}

- (BOOL) getNthMove:(int)n {
  int idx = (_currentIndex+n+1) % (self.schedule.count);
  
  NSNumber *num = self.schedule[idx];
  return [num boolValue];
}

- (NSArray *)getNextNMoves:(int)n {
  NSMutableArray *arr = [NSMutableArray array];
  for (int i = 0; i < n; i++) {
    [arr addObject:@([self getNthMove:i])];
  }
  return arr;
}

@end
