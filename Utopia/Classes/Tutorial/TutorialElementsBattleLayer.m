//
//  TutorialElementsBattleLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/8/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialElementsBattleLayer.h"
#import "TutorialOrbLayer.h"
#import "Globals.h"

@implementation TutorialElementsBattleLayer

- (void) initOrbLayer {
  [super initOrbLayer];
  
  BattlePlayer *bp = [self firstMyPlayer];
  MonsterProto_MonsterElement strongElem = bp.element;
  MonsterProto_MonsterElement strongSwap = MonsterProto_MonsterElementFire;
  MonsterProto_MonsterElement weakElem = [Globals elementForNotVeryEffective:bp.element];
  MonsterProto_MonsterElement weakSwap = MonsterProto_MonsterElementWater;
  
  BOOL useThirdElem = NO;
  MonsterProto_MonsterElement thirdElem = 0;
  MonsterProto_MonsterElement thirdSwap = MonsterProto_MonsterElementGrass;
  if (strongElem == weakSwap) {
    thirdElem = strongSwap;
    useThirdElem = YES;
  } else if (weakElem == strongSwap) {
    thirdElem = weakSwap;
    useThirdElem = YES;
  }
  
  for (int i = 0; i < self.orbLayer.presetOrbs.count; i++) {
    NSMutableArray *row = self.orbLayer.presetOrbs[i];
    for (int j = 0; j < row.count; j++) {
      MonsterProto_MonsterElement val = [row[j] intValue];
      MonsterProto_MonsterElement newColor = val;
      if (val == strongSwap) {
        newColor = strongElem;
      } else if (val == weakSwap) {
        newColor = weakElem;
      } else if (useThirdElem) {
        if (val == thirdSwap) {
          newColor = thirdElem;
        }
      } else {
        if (val == strongElem) {
          newColor = strongSwap;
        } else if (val == weakElem) {
          newColor = weakSwap;
        }
      }
      
      [row replaceObjectAtIndex:j withObject:@(newColor)];
    }
    [self.orbLayer.presetOrbIndices replaceObjectAtIndex:i withObject:@(0)];
  }
  [self.orbLayer initBoard];
}

- (void) beginFirstMove {
  [super beginFirstMove];
  
  [self.orbLayer createOverlayAvoidingPositions:[NSArray arrayWithObjects:
                                       [NSValue valueWithCGPoint:ccp(2, 1)],
                                       [NSValue valueWithCGPoint:ccp(3, 1)],
                                       [NSValue valueWithCGPoint:ccp(4, 1)],
                                       [NSValue valueWithCGPoint:ccp(3, 2)], nil]
                       withForcedMove:[NSSet setWithObjects:
                                       [NSValue valueWithCGPoint:ccp(3, 1)],
                                       [NSValue valueWithCGPoint:ccp(3, 2)], nil]];
}

- (void) beginSecondMove {
  [super beginSecondMove];
  
  [self.orbLayer createOverlayAvoidingPositions:[NSArray arrayWithObjects:
                                       [NSValue valueWithCGPoint:ccp(5, 1)],
                                       [NSValue valueWithCGPoint:ccp(6, 1)],
                                       [NSValue valueWithCGPoint:ccp(7, 1)],
                                       [NSValue valueWithCGPoint:ccp(5, 2)], nil]
                       withForcedMove:[NSSet setWithObjects:
                                       [NSValue valueWithCGPoint:ccp(5, 2)],
                                       [NSValue valueWithCGPoint:ccp(5, 1)], nil]];
}

- (NSString *) presetLayoutFile {
  return @"TutorialElementsBattleLayout.txt";
}

@end
