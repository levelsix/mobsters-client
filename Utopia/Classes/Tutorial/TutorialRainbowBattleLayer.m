//
//  TutorialRainbowBattleLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/10/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialRainbowBattleLayer.h"

@implementation TutorialRainbowBattleLayer

- (void) beginFirstMove {
  [super beginFirstMove];
  
  [self.orbLayer createOverlayAvoidingPositions:[NSArray arrayWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(1, 3)],
                                                 [NSValue valueWithCGPoint:ccp(2, 3)],
                                                 [NSValue valueWithCGPoint:ccp(3, 3)],
                                                 [NSValue valueWithCGPoint:ccp(4, 3)],
                                                 [NSValue valueWithCGPoint:ccp(5, 3)],
                                                 [NSValue valueWithCGPoint:ccp(3, 4)], nil]
                                 withForcedMove:[NSArray arrayWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(3, 3)],
                                                 [NSValue valueWithCGPoint:ccp(3, 4)], nil]];
}

- (void) beginSecondMove {
  [super beginSecondMove];
  
  [self.orbLayer createOverlayAvoidingPositions:[NSArray arrayWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(3, 3)],
                                                 [NSValue valueWithCGPoint:ccp(3, 4)], nil]
                                 withForcedMove:[NSArray arrayWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(3, 4)],
                                                 [NSValue valueWithCGPoint:ccp(3, 3)], nil]];
}

- (NSString *) presetLayoutFile {
  return @"TutorialRainbowBattleLayout.txt";
}

@end
