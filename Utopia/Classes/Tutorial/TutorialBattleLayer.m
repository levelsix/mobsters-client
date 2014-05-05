//
//  TutorialBattleLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/3/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialBattleLayer.h"
#import "Globals.h"
#import "TutorialOrbLayer.h"

@implementation TutorialBattleOneLayer

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

- (void) dealDamage:(int)damageDone enemyIsAttacker:(BOOL)enemyIsAttacker withSelector:(SEL)selector {
  if (!enemyIsAttacker) {
    // Make sure he kills
    damageDone = MAX(damageDone, self.enemyPlayerObject.curHealth+7);
  }
  
  [super dealDamage:damageDone enemyIsAttacker:enemyIsAttacker withSelector:selector];
}

- (NSString *) presetLayoutFile {
  return @"TutorialBattle1Layout.txt";
}

@end

@implementation TutorialBattleTwoLayer

- (id) initWithConstants:(StartupResponseProto_TutorialConstants *)constants enemyDamageDealt:(int)damage {
  if ((self = [super initWithConstants:constants])) {
    Globals *gl = [Globals sharedGlobals];
    UserMonster *um = [[UserMonster alloc] init];
    um.userMonsterId = 1;
    um.monsterId = constants.enemyBossMonsterId;
    um.level = 1;
    um.curHealth = [gl calculateMaxHealthForMonster:um];
    BattlePlayer *bp = [BattlePlayer playerWithMonster:um];
    bp.minDamage = damage;
    bp.maxDamage = damage;
    bp.curHealth = 500;
    bp.maxHealth = 500;
    self.enemyTeam = [NSArray arrayWithObject:bp];
  }
  return self;
}

- (void) beginFirstMove {
  [super beginFirstMove];
  
  [self.orbLayer createOverlayAvoidingPositions:[NSArray arrayWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(2, 1)],
                                                 [NSValue valueWithCGPoint:ccp(3, 1)],
                                                 [NSValue valueWithCGPoint:ccp(4, 1)],
                                                 [NSValue valueWithCGPoint:ccp(5, 1)],
                                                 [NSValue valueWithCGPoint:ccp(3, 2)], nil]
                                 withForcedMove:[NSArray arrayWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(3, 1)],
                                                 [NSValue valueWithCGPoint:ccp(3, 2)], nil]];
}

- (void) beginSecondMove {
  [super beginSecondMove];
  
  [self.orbLayer createOverlayAvoidingPositions:[NSArray arrayWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(3, 1)],
                                                 [NSValue valueWithCGPoint:ccp(3, 2)],
                                                 [NSValue valueWithCGPoint:ccp(3, 3)],
                                                 [NSValue valueWithCGPoint:ccp(3, 4)], nil]
                                 withForcedMove:[NSArray arrayWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(3, 2)],
                                                 [NSValue valueWithCGPoint:ccp(3, 1)], nil]];
}

- (void) dealDamage:(int)damageDone enemyIsAttacker:(BOOL)enemyIsAttacker withSelector:(SEL)selector {
  if (!enemyIsAttacker) {
    // Make sure first guy does not kill, second guy kills
    if (self.myPlayerObject.slotNum == 1) {
      damageDone = MIN(damageDone, self.enemyPlayerObject.curHealth*0.9);
    } else if (self.myPlayerObject.slotNum == 2) {
      damageDone = MAX(damageDone, self.enemyPlayerObject.curHealth*1.1);
    }
  }
  
  [super dealDamage:damageDone enemyIsAttacker:enemyIsAttacker withSelector:selector];
}

- (void) swapToMark {
  _orbCount = 0;
  self.swappableTeamSlot = 2;
  [self displaySwapButton];
  
  [self runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:0.3f],
    [CCActionCallBlock actionWithBlock:
     ^{
       [Globals createUIArrowForView:self.swapView atAngle:0];
     }], nil]];
}

- (void) displayDeployViewAndIsCancellable:(BOOL)cancel {
  [super displayDeployViewAndIsCancellable:cancel];
  
  [Globals removeUIArrowFromViewRecursively:self.swapView.superview];
  
  [self runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:0.3f],
    [CCActionCallBlock actionWithBlock:
     ^{
       BattleDeployCardView *card = self.deployView.cardViews[1];
       [Globals createUIArrowForView:card atAngle:M_PI_2];
     }], nil]];
}

- (void) deployBattleSprite:(BattlePlayer *)bp {
  if (!self.myPlayer || bp.slotNum == self.swappableTeamSlot) {
    [super deployBattleSprite:bp];
    [self.delegate swappedToMark];
    [Globals removeUIArrowFromViewRecursively:self.deployView];
  }
}

- (NSString *) presetLayoutFile {
  return @"TutorialBattle2Layout.txt";
}

@end

@implementation TutorialBattleLayer

- (id) initWithConstants:(StartupResponseProto_TutorialConstants *)constants {
  Globals *gl = [Globals sharedGlobals];
  UserMonster *um1 = [[UserMonster alloc] init];
  um1.userMonsterId = 1;
  um1.monsterId = constants.startingMonsterId;
  um1.level = 1;
  um1.curHealth = [gl calculateMaxHealthForMonster:um1];
  um1.teamSlot = 1;
  
  UserMonster *um2 = [[UserMonster alloc] init];
  um2.userMonsterId = 2;
  um2.monsterId = constants.markZmonsterId;
  um2.level = 15;
  um2.curHealth = [gl calculateMaxHealthForMonster:um2];
  um2.teamSlot = 2;
  NSArray *myMons = [NSArray arrayWithObjects:um1, um2, nil];
  if ((self = [super initWithMyUserMonsters:myMons puzzleIsOnLeft:NO])) {
    self.constants = constants;
    
    [self.forfeitButton removeFromSuperview];
    [self.elementButton removeFromSuperview];
    [self.elementView removeFromSuperview];
    
    BattlePlayer *mark = self.myTeam[1];
    float mult = 50;
    mark.fireDamage = mult-10;
    mark.waterDamage = mult+10;
    mark.earthDamage = mult+4;
    mark.lightDamage = mult+2;
    mark.nightDamage = mult-3;
    mark.rockDamage = mult-12;
    mark.curHealth = 450;
    mark.maxHealth = 450;
  }
  return self;
}

#pragma mark - Overwritten methods

- (void) sendServerUpdatedValues {
  // Do nothing
}

- (void) youWon {
  [self makeMyPlayerWalkOutWithBlock:^{
    [self.delegate battleComplete:nil];
  }];
}

- (void) displayEffectivenessForAttackerElement:(Element)atkElement defenderElement:(Element)defElement position:(CGPoint)position {
  // Do nothing
}

@end
