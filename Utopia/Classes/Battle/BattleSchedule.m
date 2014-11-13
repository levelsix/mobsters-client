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

- (void) createScheduleForPlayerA:(int)speedA playerB:(int)speedB andOrder:(ScheduleFirstTurn)order
{
  NSMutableArray *sch = [NSMutableArray array];
  
  if (!speedA || !speedB) {
    [sch addObject:@YES];
    [sch addObject:@NO];
    
    LNLog(@"Cannot create proper schedule. Using default..");
  } else {
    int numInterleavings = MIN(speedA, speedB);
    
    // If its a swap, B always gets to go first
    BOOL firstAttackerIsA;
    switch (order)
    {
      case ScheduleFirstTurnPlayer: firstAttackerIsA = YES; break;
      case ScheduleFirstTurnEnemy: firstAttackerIsA = NO; break;
      case ScheduleFirstTurnRandom: firstAttackerIsA = [self chooseFirstAttackerWithSpeedA:speedA speedB:speedB]; break;
    }
    
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
  
  self.schedule = sch;
  
  if (order == ScheduleFirstTurnRandom)
  {
    self.currentIndex = arc4random() % self.schedule.count;
  }
  else if (order == ScheduleFirstTurnEnemy)
  {
    do {
      self.currentIndex = arc4random() % self.schedule.count;
    } while ([self.schedule[self.currentIndex] boolValue]);
  }
  else if (order == ScheduleFirstTurnPlayer)
  {
    self.currentIndex = 0;  // For the Cake Drop special case.
  }
  
  // Subtract 1 so it will be autoincremented in the next dequeue
  self.currentIndex--;
}

- (NSString *) description {
  NSMutableString *str = [NSMutableString stringWithFormat:@"Battle Schedule: "];
  for (int i = 0; i < self.schedule.count; i++) {
    NSNumber *n = self.schedule[i];
    if (((self.currentIndex+1) % self.schedule.count) == i) {
      [str appendFormat:@"(%@) ", n];
    } else {
      [str appendFormat:@"%@ ", n];
    }
  }
  return str;
}

- (id) initWithPlayerA:(int)speedA playerB:(int)speedB andOrder:(ScheduleFirstTurn)order {
  if ((self = [super init])) {
    
    [self createScheduleForPlayerA:speedA playerB:speedB andOrder:order];
  }
  return self;
}

- (id) initWithSequence:(NSArray *)sequence currentIndex:(int)currentIndex {
  if ((self = [super init])) {
    self.schedule = sequence;
    self.currentIndex = currentIndex;
  }
  return self;
}

- (BOOL) chooseFirstAttackerWithSpeedA:(int)speedA speedB:(int)speedB {
  int total = speedA + speedB;
  return (arc4random() % total) < speedA;
}

- (BOOL) dequeueNextMove {
  self.currentIndex = (self.currentIndex+1) % (self.schedule.count);
  self.numDequeued++;
  
  NSNumber *num = self.schedule[self.currentIndex];
  return [num boolValue];
}

- (BOOL) getNthMove:(int)n {
  int idx = (self.currentIndex+n+1) % (self.schedule.count);
  
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

- (BOOL) nextTurnIsPlayers
{
  return [self getNthMove:0];
}

@end
