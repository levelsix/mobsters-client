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
                                       [NSValue valueWithCGPoint:ccp(1, 0)],
                                       [NSValue valueWithCGPoint:ccp(0, 1)],
                                       [NSValue valueWithCGPoint:ccp(1, 1)],
                                       [NSValue valueWithCGPoint:ccp(1, 2)], nil]
                       withForcedMove:[NSSet setWithObjects:
                                       [NSValue valueWithCGPoint:ccp(0, 1)],
                                       [NSValue valueWithCGPoint:ccp(1, 1)], nil]];
}

- (void) beginSecondMove {
  [super beginSecondMove];
  
  [self.orbLayer createOverlayAvoidingPositions:[NSArray arrayWithObjects:
                                       [NSValue valueWithCGPoint:ccp(2, 1)],
                                       [NSValue valueWithCGPoint:ccp(3, 2)],
                                       [NSValue valueWithCGPoint:ccp(3, 1)],
                                       [NSValue valueWithCGPoint:ccp(4, 1)], nil]
                       withForcedMove:[NSSet setWithObjects:
                                       [NSValue valueWithCGPoint:ccp(3, 1)],
                                       [NSValue valueWithCGPoint:ccp(3, 2)], nil]];
}

- (CGSize) gridSize {
  return CGSizeMake(6, 6);
}

- (NSString *) presetLayoutFile {
  return @"TutorialBattle1Layout.txt";
}

@end
