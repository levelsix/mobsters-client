//
//  TutorialBasicComboBattleLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/11/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialBasicComboBattleLayer.h"

@implementation TutorialBasicComboBattleLayer

- (void) beginFirstMove {
  [super beginFirstMove];
  
  [self.orbLayer createOverlayAvoidingPositions:[NSArray arrayWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(3, 1)],
                                                 [NSValue valueWithCGPoint:ccp(3, 2)],
                                                 [NSValue valueWithCGPoint:ccp(3, 3)],
                                                 [NSValue valueWithCGPoint:ccp(4, 2)], nil]
                                 withForcedMove:[NSArray arrayWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(4, 2)],
                                                 [NSValue valueWithCGPoint:ccp(3, 2)], nil]];
}

- (void) beginSecondMove {
  [super beginSecondMove];
  
  [self.orbLayer createOverlayAvoidingPositions:[NSArray arrayWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(3, 2)],
                                                 [NSValue valueWithCGPoint:ccp(3, 3)],
                                                 [NSValue valueWithCGPoint:ccp(3, 4)],
                                                 [NSValue valueWithCGPoint:ccp(3, 1)], nil]
                                 withForcedMove:[NSArray arrayWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(3, 3)],
                                                 [NSValue valueWithCGPoint:ccp(3, 4)], nil]];
}

- (CGSize) gridSize {
  return CGSizeMake(6, 6);
}

- (NSString *) presetLayoutFile {
  return @"TutorialBattle1Layout.txt";
}

@end
