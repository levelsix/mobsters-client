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

- (id) initWithConstants:(StartupResponseProto_TutorialConstants *)constants {
  if ((self = [super initWithConstants:constants])) {
    Globals *gl = [Globals sharedGlobals];
    UserMonster *um = [[UserMonster alloc] init];
    um.userMonsterId = 1;
    um.monsterId = constants.enemyMonsterId;
    um.level = 1;
    um.curHealth = [gl calculateMaxHealthForMonster:um];
    BattlePlayer *bp = [BattlePlayer playerWithMonster:um];
    self.enemyTeam = [NSArray arrayWithObject:bp];
  }
  return self;
}

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

- (CGSize) gridSize {
  return CGSizeMake(8, 8);
}

- (NSString *) presetLayoutFile {
  return @"TutorialElementsBattleLayout.txt";
}

@end
