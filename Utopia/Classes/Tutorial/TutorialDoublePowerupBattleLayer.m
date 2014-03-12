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
                                                 [NSValue valueWithCGPoint:ccp(3, 0)],
                                                 [NSValue valueWithCGPoint:ccp(4, 0)],
                                                 [NSValue valueWithCGPoint:ccp(5, 0)],
                                                 [NSValue valueWithCGPoint:ccp(6, 0)],
                                                 [NSValue valueWithCGPoint:ccp(7, 0)],
                                                 [NSValue valueWithCGPoint:ccp(5, 1)], nil]
                                 withForcedMove:[NSSet setWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(5, 1)],
                                                 [NSValue valueWithCGPoint:ccp(5, 0)], nil]];
}

- (void) beginSecondMove {
  [super beginSecondMove];
  
  [self.orbLayer createOverlayAvoidingPositions:[NSArray arrayWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(4, 0)],
                                                 [NSValue valueWithCGPoint:ccp(4, 1)],
                                                 [NSValue valueWithCGPoint:ccp(4, 2)],
                                                 [NSValue valueWithCGPoint:ccp(4, 3)],
                                                 [NSValue valueWithCGPoint:ccp(5, 1)], nil]
                                 withForcedMove:[NSSet setWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(4, 1)],
                                                 [NSValue valueWithCGPoint:ccp(5, 1)], nil]];
}

- (void) beginThirdMove {
  [super beginThirdMove];
  
  [self.orbLayer createOverlayAvoidingPositions:[NSArray arrayWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(4, 0)],
                                                 [NSValue valueWithCGPoint:ccp(5, 0)], nil]
                                 withForcedMove:[NSSet setWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(4, 0)],
                                                 [NSValue valueWithCGPoint:ccp(5, 0)], nil]];
}

- (NSString *) presetLayoutFile {
  return @"TutorialDoublePowerupLayout.txt";
}

@end
