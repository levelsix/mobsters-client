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
#import "CCSoundAnimation.h"

#define ENEMY_INDEX 1
#define ENEMY_TWO_INDEX 2

@implementation TutorialBattleOneLayer

- (id) initWithConstants:(StartupResponseProto_TutorialConstants *)constants enemyDamageDealt:(int)damage {
  if ((self = [super initWithConstants:constants])) {
    Globals *gl = [Globals sharedGlobals];
    
    UserMonster *um = [[UserMonster alloc] init];
    um.monsterId = constants.enemyMonsterId;
    um.level = 1;
    um.curHealth = [gl calculateMaxHealthForMonster:um];
    BattlePlayer *bp1 = [BattlePlayer playerWithMonster:um];
    
    um.monsterId = constants.enemyMonsterIdTwo;
    um.curHealth = [gl calculateMaxHealthForMonster:um];
    BattlePlayer *bp2 = [BattlePlayer playerWithMonster:um];
    bp2.minDamage = damage;
    bp2.maxDamage = damage;
    
    
    um.monsterId = constants.enemyBossMonsterId;
    um.curHealth = [gl calculateMaxHealthForMonster:um];
    BattlePlayer *bp3 = [BattlePlayer playerWithMonster:um];
    
    self.enemyTeam = [NSArray arrayWithObjects:bp3, bp1, bp2, nil];
  }
  return self;
}

- (NSString *) bgdPrefix {
  return @"1";
}

#pragma mark - Initial convo

- (void) initInitialSetup {
  NSMutableArray *mut = [NSMutableArray array];
  for (BattlePlayer *bp in self.enemyTeam) {
    NSInteger idx = [self.enemyTeam indexOfObject:bp];
    BattleSprite *bs = [[BattleSprite alloc] initWithPrefix:bp.spritePrefix nameString:bp.name rarity:bp.rarity animationType:bp.animationType isMySprite:NO verticalOffset:bp.verticalOffset];
    bs.healthBar.color = [self.orbLayer colorForSparkle:(GemColorId)bp.element];
    [self.bgdContainer addChild:bs z:-idx];
    [self walkInEnemyTeamSprite:bs index:idx shouldRunIn:YES];
    
    bs.healthBar.percentage = ((float)bp.curHealth)/bp.maxHealth*100;
    bs.healthLabel.string = [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:bp.curHealth], [Globals commafyNumber:bp.maxHealth]];
    
    [mut addObject:bs];
  }
  self.enemyTeamSprites = mut;
}

- (void) walkInEnemyTeamSprite:(BattleSprite *)bs index:(int)idx shouldRunIn:(BOOL)shouldRunIn {
  bs.isFacingNear = YES;
  [bs stopWalking];
  
  CGPoint finalPos = ccpAdd(ENEMY_PLAYER_LOCATION, ccp(-9, -11));
  
  if (idx == ENEMY_INDEX) {
    finalPos = ccpAdd(finalPos, ccp(46, 3));
    bs.zOrder = 1;
  } else if (idx == ENEMY_TWO_INDEX) {
    finalPos = ccpAdd(finalPos, ccp(-7, 35));
  }
  
  CGPoint offsetPerScene = POINT_OFFSET_PER_SCENE;
  if (shouldRunIn) {
    CGPoint newPos = ccpAdd(finalPos, ccp(2*Y_MOVEMENT_FOR_NEW_SCENE*offsetPerScene.x/offsetPerScene.y, 2*Y_MOVEMENT_FOR_NEW_SCENE));
    
    bs.position = newPos;
    [bs beginWalking];
    CCActionSequence *seq = [CCActionSequence actions:
                             [CCActionDelay actionWithDuration:0.12*idx],
                             [CCActionMoveTo actionWithDuration:TIME_TO_SCROLL_PER_SCENE position:finalPos],
                             [CCActionCallFunc actionWithTarget:bs selector:@selector(stopWalking)], nil];
    [bs runAction:seq];
  } else {
    CGPoint newPos = ccpAdd(finalPos, ccp(Y_MOVEMENT_FOR_NEW_SCENE*offsetPerScene.x/offsetPerScene.y, Y_MOVEMENT_FOR_NEW_SCENE));
    
    bs.position = newPos;
    [bs runAction:[CCActionMoveTo actionWithDuration:TIME_TO_SCROLL_PER_SCENE position:finalPos]];
  }
}

- (void) enemyJumpAndShoot {
  BattleSprite *bs = self.enemyTeamSprites[ENEMY_INDEX];
  [bs jumpNumTimes:1 completionTarget:self selector:@selector(enemyShoot)];
}

- (void) enemyShoot {
  BattleSprite *bs = self.enemyTeamSprites[ENEMY_INDEX];
  [bs performNearAttackAnimationWithEnemy:nil target:self selector:@selector(enemySecondJump)];
}

- (void) enemySecondJump {
  BattleSprite *bs = self.enemyTeamSprites[ENEMY_INDEX];
  [bs jumpNumTimes:1 completionTarget:self.delegate selector:@selector(enemyJumpedAndShot)];
}


- (void) enemyTwoLookAtEnemyAndWalkOut {
  BattleSprite *bs1 = self.enemyTeamSprites[ENEMY_INDEX];
  BattleSprite *bs2 = self.enemyTeamSprites[ENEMY_TWO_INDEX];
  [bs2 restoreStandingFrame:MapDirectionNearRight];
  
  CCAnimation *anim = bs2.attackAnimationN.copy;
  [anim addSoundEffect:@"sfx_muckerburg_hit_luchador.mp3" atIndex:2];
  
  [bs2 runAction:[CCActionSequence actions:
                  [CCActionDelay actionWithDuration:0.5f],
                  [CCSoundAnimate actionWithAnimation:anim],
                  [CCActionCallFunc actionWithTarget:self selector:@selector(enemyTwoAndBossRunOut)], nil]];
  
  [bs1 performFarFlinchAnimationWithDelay:0.8];
}

- (void) moveBattleSpriteToEnemyStartLocationAndCallSelector:(BattleSprite *)bs isComingFromTop:(BOOL)isFromTop {
  CGPoint startPos = bs.position;
  CGPoint finalPos = ENEMY_PLAYER_LOCATION;
  CGPoint myPos = MY_PLAYER_LOCATION;
  float slope = (myPos.y-finalPos.y)/(myPos.x-finalPos.x);
  float invSlope = -1.f/slope;
  float yIntersectionOfNewLine = startPos.y-invSlope*startPos.x;
  CGPoint midPos = ccpIntersectPoint(finalPos, myPos, startPos, ccp(0, yIntersectionOfNewLine));
  
  bs.position = startPos;
  [bs runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:0.5f],
    [CCActionCallBlock actionWithBlock:
     ^{
       if (!isFromTop) {
         [bs faceFarWithoutUpdate];
         [bs beginWalking];
         bs.sprite.flipX = NO;
       } else {
         [bs beginWalking];
         bs.sprite.flipX = YES;
       }
     }],
    [CCActionMoveTo actionWithDuration:ccpDistance(midPos, startPos)/MY_WALKING_SPEED*3 position:midPos],
    [CCActionCallBlock actionWithBlock:
     ^{
       [bs stopWalking];
       [bs faceNearWithoutUpdate];
       [bs beginWalking];
     }],
    [CCActionMoveTo actionWithDuration:ccpDistance(finalPos, midPos)/MY_WALKING_SPEED*3 position:finalPos],
    [CCActionCallBlock actionWithBlock:
     ^{
       [bs stopWalking];
       [bs setIsFacingNear:YES];
       
       [self enemiesRanOut];
     }],
    nil]];
}

- (void) walkOutEnemiesNotAtIndex:(int)idx {
  self.currentEnemy = self.enemyTeamSprites[idx];
  self.enemyPlayerObject = self.enemyTeam[idx];
  for (BattleSprite *bs in self.enemyTeamSprites) {
    CGPoint startPos = bs.position;
    CGPoint ptOffset = POINT_OFFSET_PER_SCENE;
    if (bs == self.currentEnemy) {
      [self moveBattleSpriteToEnemyStartLocationAndCallSelector:bs isComingFromTop:idx == ENEMY_TWO_INDEX];
    } else {
      float startX = self.contentSize.width+self.myPlayer.contentSize.width;
      float xDelta = startPos.x-startX;
      CGPoint endPos = ccp(startX, startPos.y-xDelta*ptOffset.y/ptOffset.x);
      
      bs.isFacingNear = NO;
      [bs beginWalking];
      [bs runAction:
       [CCActionSequence actions:
        [CCActionMoveTo actionWithDuration:ccpDistance(startPos, endPos)/MY_WALKING_SPEED position:endPos], nil]];
    }
  }
  
  _curStage = idx;
}

- (void) enemiesRanOut {
  [self.delegate enemiesRanOut];
}

- (void) enemyTwoAndBossRunOut {
  [self walkOutEnemiesNotAtIndex:ENEMY_INDEX];
  [self displayOrbLayer];
}

- (void) makeEnemyTwoAndBossRunIn {
  for (int i = 0; i < self.enemyTeamSprites.count; i++) {
    if (i != ENEMY_INDEX) {
      [self walkInEnemyTeamSprite:self.enemyTeamSprites[i] index:i shouldRunIn:NO];
    }
  }
}

- (void) enemyBossWalkOut {
  [self walkOutEnemiesNotAtIndex:ENEMY_TWO_INDEX];
}

- (float) damageMultiplierIsEnemyAttacker:(BOOL)isEnemy {
  return 1.f;
}



//- (void) reachedNextScene {
//  if (!_hasStarted) {
//    [self.myPlayer beginWalking];
//    [self.bgdLayer scrollToNewScene];
//    [self initInitialSetup];
//    _hasStarted = YES;
//  } else {
//    [super reachedNextScene];
//  }
//}

- (void) moveToNextEnemy {
  if (_curStage < ENEMY_TWO_INDEX) {
    [self.myPlayer beginWalking];
    [self.bgdLayer scrollToNewScene];
    if (_curStage < 0) {
      [self initInitialSetup];
    } else if (_curStage == ENEMY_INDEX) {
      [self makeEnemyTwoAndBossRunIn];
    }
  } else {
    [self youWon];
  }
}

- (void) displayOrbLayer {
  // Don't show orb layer right at the start
  if (_hasStarted) {
    [super displayOrbLayer];
  }
}

- (void) sendServerDungeonProgress {
  // Do nothing
}



#pragma mark - Actual battle

- (void) beginFirstMove {
  [super beginFirstMove];
  
  [self.orbLayer createOverlayAvoidingPositions:[NSArray arrayWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(3, 1)],
                                                 [NSValue valueWithCGPoint:ccp(3, 2)],
                                                 [NSValue valueWithCGPoint:ccp(3, 3)],
                                                 [NSValue valueWithCGPoint:ccp(4, 2)], nil]
                                 withForcedMove:[NSArray arrayWithObjects:
                                                 [NSValue valueWithCGPoint:ccp(3, 2)],
                                                 [NSValue valueWithCGPoint:ccp(4, 2)], nil]];
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
    if (_curStage == ENEMY_INDEX) {
      // Make sure he kills
      damageDone = MAX(damageDone, self.enemyPlayerObject.curHealth+7);
    } else if (_curStage == ENEMY_TWO_INDEX) {
      // Make sure first guy does not kill, second guy kills
      if (self.myPlayerObject.slotNum == 1) {
        damageDone = MIN(damageDone, self.enemyPlayerObject.curHealth*0.9);
      } else if (self.myPlayerObject.slotNum == 2) {
        damageDone = MAX(damageDone, self.enemyPlayerObject.curHealth*1.1);
      }
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
