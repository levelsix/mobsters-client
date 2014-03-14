//
//  TutorialDoublePowerupBattleLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/11/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialDoublePowerupBattleLayer.h"

@implementation TutorialDoublePowerupBattleLayer

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
                                                 [NSValue valueWithCGPoint:ccp(2, 2)],
                                                 [NSValue valueWithCGPoint:ccp(3, 2)],
                                                 [NSValue valueWithCGPoint:ccp(4, 2)],
                                                 [NSValue valueWithCGPoint:ccp(5, 2)],
                                                 [NSValue valueWithCGPoint:ccp(4, 3)], nil]
                                 withForcedMove:[NSArray arrayWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(4, 2)],
                                                 [NSValue valueWithCGPoint:ccp(4, 3)], nil]];
}

- (void) beginThirdMove {
  [super beginThirdMove];
  
  [self.orbLayer createOverlayAvoidingPositions:[NSArray arrayWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(3, 2)],
                                                 [NSValue valueWithCGPoint:ccp(4, 2)], nil]
                                 withForcedMove:[NSArray arrayWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(4, 2)],
                                                 [NSValue valueWithCGPoint:ccp(3, 2)], nil]];
}

- (NSString *) presetLayoutFile {
  return @"TutorialDoublePowerupLayout.txt";
}

@end
