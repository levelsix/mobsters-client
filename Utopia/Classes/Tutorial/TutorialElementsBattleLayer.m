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

- (void) beginFirstMove {
  [super beginFirstMove];
  
  TutorialOrbLayer *orb = (TutorialOrbLayer *)self.orbLayer;
  [orb createOverlayAvoidingPositions:[NSArray arrayWithObjects:
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
  
  TutorialOrbLayer *orb = (TutorialOrbLayer *)self.orbLayer;
  [orb createOverlayAvoidingPositions:[NSArray arrayWithObjects:
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
