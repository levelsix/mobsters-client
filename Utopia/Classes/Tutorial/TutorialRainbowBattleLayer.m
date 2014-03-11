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
  
  TutorialOrbLayer *orb = (TutorialOrbLayer *)self.orbLayer;
  [orb createOverlayAvoidingPositions:[NSArray arrayWithObjects:
                                       [NSValue valueWithCGPoint:ccp(2, 1)],
                                       [NSValue valueWithCGPoint:ccp(3, 1)],
                                       [NSValue valueWithCGPoint:ccp(4, 1)],
                                       [NSValue valueWithCGPoint:ccp(5, 1)],
                                       [NSValue valueWithCGPoint:ccp(6, 1)],
                                       [NSValue valueWithCGPoint:ccp(4, 2)],nil]
                       withForcedMove:[NSSet setWithObjects:
                                       [NSValue valueWithCGPoint:ccp(4, 1)],
                                       [NSValue valueWithCGPoint:ccp(4, 2)], nil]];
}

- (void) beginSecondMove {
  [super beginSecondMove];
  
  TutorialOrbLayer *orb = (TutorialOrbLayer *)self.orbLayer;
  [orb createOverlayAvoidingPositions:[NSArray arrayWithObjects:
                                       [NSValue valueWithCGPoint:ccp(4, 1)],
                                       [NSValue valueWithCGPoint:ccp(4, 2)], nil]
                       withForcedMove:[NSSet setWithObjects:
                                       [NSValue valueWithCGPoint:ccp(4, 1)],
                                       [NSValue valueWithCGPoint:ccp(4, 2)], nil]];

}

- (NSString *) presetLayoutFile {
  return @"TutorialRainbowBattleLayout.txt";
}

@end
