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
#import "SoundEngine.h"

#define ENEMY_INDEX 1
#define ENEMY_TWO_INDEX 2
#define ENEMY_BOSS_INDEX 0

@implementation TutorialBattleOneLayer

- (id) initWithConstants:(StartupResponseProto_TutorialConstants *)constants enemyDamageDealt:(int)damage {
  if ((self = [super initWithConstants:constants])) {
    Globals *gl = [Globals sharedGlobals];
    
    UserMonster *um = [[UserMonster alloc] init];
    um.monsterId = constants.enemyMonsterId;
    um.level = 1;
    um.curHealth = [gl calculateMaxHealthForMonster:um];
    BattlePlayer *bp1 = [BattlePlayer playerWithMonster:um];
    bp1.speed = 0;
    
    um.monsterId = constants.enemyMonsterIdTwo;
    um.curHealth = [gl calculateMaxHealthForMonster:um];
    BattlePlayer *bp2 = [BattlePlayer playerWithMonster:um];
    bp2.minDamage = damage;
    bp2.maxDamage = damage;
    bp2.speed = 0;
    
    um.monsterId = constants.enemyBossMonsterId;
    um.curHealth = [gl calculateMaxHealthForMonster:um];
    BattlePlayer *bp3 = [BattlePlayer playerWithMonster:um];
    
    self.enemyTeam = [NSArray arrayWithObjects:bp3, bp1, bp2, nil];
    
    
    NSString *effect = @"sfx_muckerburg_hit_luchador.mp3";
    [[SoundEngine sharedSoundEngine] preloadEffect:effect];
    
    [self.lootBgd removeFromParent];
  }
  return self;
}

#pragma mark - Initial convo

- (void) initInitialSetup {
  NSMutableArray *mut = [NSMutableArray array];
  self.enemyTeamSprites = mut;
  for (BattlePlayer *bp in self.enemyTeam) {
    int idx = (int)[self.enemyTeam indexOfObject:bp];
    BattleSprite *bs = [[BattleSprite alloc] initWithPrefix:bp.spritePrefix nameString:bp.attrName rarity:bp.rarity animationType:bp.animationType isMySprite:NO verticalOffset:bp.verticalOffset];
    bs.battleLayer = self;
    bs.healthBar.color = [self.orbLayer.swipeLayer colorForSparkle:(OrbColor)bp.element];
    [self.bgdContainer addChild:bs z:-idx-2];
    
    bs.healthBar.percentage = ((float)bp.curHealth)/bp.maxHealth*100;
    bs.healthLabel.string = [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:bp.curHealth], [Globals commafyNumber:bp.maxHealth]];
    
    [mut addObject:bs];
    [self walkInEnemyTeamSpriteAtIndex:idx shouldRunIn:YES];
  }
}

- (void) walkInEnemyTeamSpriteAtIndex:(int)idx shouldRunIn:(BOOL)shouldRunIn {
  BattleSprite *bs = self.enemyTeamSprites[idx];
  bs.isFacingNear = YES;
  [bs stopWalking];
  
  CGPoint finalPos = ccpAdd(ENEMY_PLAYER_LOCATION, ccp(-9, -11));
  
  if (idx == ENEMY_INDEX) {
    finalPos = ccpAdd(finalPos, ccp(46, 3));
    bs.zOrder = -1;
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
  [bs jumpNumTimes:2 completionTarget:self.delegate selector:@selector(enemyJumpedAndShot)];
}

- (void) enemyShoot {
  BattleSprite *bs = self.enemyTeamSprites[ENEMY_INDEX];
  [bs performNearAttackAnimationWithEnemy:nil shouldReturn:YES shouldEvade:NO shouldFlinch:YES
                                   target:self selector:@selector(enemySecondJump) animCompletion:nil];
}

- (void) enemySecondJump {
  BattleSprite *bs = self.enemyTeamSprites[ENEMY_INDEX];
  [bs jumpNumTimes:1 completionTarget:self.delegate selector:@selector(enemyJumpedAndShot)];
}

- (void) enemyTwoLookAtEnemy {
  BattleSprite *bs2 = self.enemyTeamSprites[ENEMY_TWO_INDEX];
  [bs2 restoreStandingFrame:MapDirectionNearRight];
}

- (void) enemyTwoAttackEnemy {
  [self enemyTwoAttackEnemyWithTarget:self.delegate selector:@selector(enemyTwoHitEnemy)];
}

- (void) enemyTwoAttackEnemyWithTarget:(id)target selector:(SEL)selector {
  BattleSprite *bs1 = self.enemyTeamSprites[ENEMY_INDEX];
  BattleSprite *bs2 = self.enemyTeamSprites[ENEMY_TWO_INDEX];
  
  [bs2 restoreStandingFrame:MapDirectionNearRight];
  
  CCAnimation *anim = bs2.attackAnimationN.copy;
  anim.delayPerUnit = anim.delayPerUnit*2/3;
  [anim addSoundEffect:@"sfx_muckerburg_hit_luchador.mp3" atIndex:2];
  
  float delay = 0.01f;
  [bs2 runAction:[CCActionSequence actions:
                  [CCActionDelay actionWithDuration:delay],
                  [CCSoundAnimate actionWithAnimation:anim],
                  [CCActionCallFunc actionWithTarget:target selector:selector], nil]];
  
  [bs1 performFarFlinchAnimationWithDelay:delay+0.3];
}

- (void) enemyBossStomp {
  BattleSprite *boss = self.enemyTeamSprites[ENEMY_BOSS_INDEX];
  [boss restoreStandingFrame:MapDirectionFarRight];
  
  [self runAction:[CCActionSequence actions:
                   [CCActionDelay actionWithDuration:0.5],
                   [CCActionCallFunc actionWithTarget:self selector:@selector(enemyBossDoStomp)], nil]];
  
}

- (void) enemyBossDoStomp {
  BattleSprite *boss = self.enemyTeamSprites[ENEMY_BOSS_INDEX];
  [boss jumpNumTimes:1 timePerJump:0.37 height:24 completionTarget:self selector:@selector(enemyMinionsJump)];
}

- (void) enemyMinionsJump {
  BattleSprite *bs1 = self.enemyTeamSprites[ENEMY_INDEX];
  BattleSprite *bs2 = self.enemyTeamSprites[ENEMY_TWO_INDEX];
  
  [self shakeScreenWithIntensity:1.f];
  
  [bs1 restoreStandingFrame:MapDirectionNearLeft];
  [bs2 restoreStandingFrame:MapDirectionNearLeft];

  [self runAction:[CCActionSequence actions:
                   [CCActionDelay actionWithDuration:0.1],
                   [CCActionCallBlock actionWithBlock:
                    ^{
                      [bs2 jumpNumTimes:1 timePerJump:0.15 height:10 completionTarget:nil selector:nil];
                    }], nil]];
  
  [self runAction:[CCActionSequence actions:
                   [CCActionDelay actionWithDuration:0.15],
                   [CCActionCallBlock actionWithBlock:
                    ^{
                      [bs1 jumpNumTimes:1 timePerJump:0.15 height:10 completionTarget:self.delegate selector:@selector(enemyBossStomped)];
                    }], nil]];
}

- (void) moveBattleSprite:(BattleSprite *)bs toEnemyStartLocationAndCallSelector:(SEL)sel isComingFromTop:(BOOL)isFromTop {
  CGPoint startPos = bs.position;
  CGPoint finalPos = ENEMY_PLAYER_LOCATION;
  CGPoint myPos = MY_PLAYER_LOCATION;
  float slope = (myPos.y-finalPos.y)/(myPos.x-finalPos.x);
  float invSlope = -1.f/slope;
  float yIntersectionOfNewLine = startPos.y-invSlope*startPos.x;
  CGPoint midPos = ccpIntersectPoint(finalPos, myPos, startPos, ccp(0, yIntersectionOfNewLine));
  
  CCAction *selAction = sel ? [CCActionCallFunc actionWithTarget:self selector:sel] : nil;
  
  bs.position = startPos;
  [bs runAction:
   [CCActionSequence actions:
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
     }],
    selAction,
    nil]];
}

- (void) walkOutEnemyAtIndex:(int)idx speedMultiplier:(float)speedMultiplier target:(id)target selector:(SEL)selector {
  BattleSprite *bs = self.enemyTeamSprites[idx];
  CGPoint startPos = bs.position;
  CGPoint ptOffset = POINT_OFFSET_PER_SCENE;
  float startY = self.contentSize.height+20;
  float yDelta = startPos.y-startY;
  CGPoint endPos = ccp(startPos.x-yDelta*ptOffset.x/ptOffset.y, startY);
  
  bs.isFacingNear = NO;
  [bs beginWalking];
  [bs runAction:
   [CCActionSequence actions:
    [CCActionMoveTo actionWithDuration:ccpDistance(startPos, endPos)/MY_WALKING_SPEED/speedMultiplier position:endPos],
    [CCActionCallFunc actionWithTarget:target selector:selector], nil]];
}

- (void) enemiesRanOut {
  [self.delegate enemiesRanOut];
}

- (void) enemyTwoAndBossRunOut {
  [self walkOutEnemyAtIndex:ENEMY_BOSS_INDEX speedMultiplier:0.75f target:nil selector:nil];
  
  [self moveBattleSprite:self.enemyTeamSprites[ENEMY_INDEX] toEnemyStartLocationAndCallSelector:nil isComingFromTop:NO];
  
  BattleSprite *bs2 = self.enemyTeamSprites[ENEMY_TWO_INDEX];
  float amt = 0.05;
  CGPoint startPos = ccpAdd(ENEMY_PLAYER_LOCATION, ccp(POINT_OFFSET_PER_SCENE.x*-amt, POINT_OFFSET_PER_SCENE.y*amt));
  [self runAction:[CCActionSequence actions:
                   [CCActionDelay actionWithDuration:0.2],
                   [CCActionCallBlock actionWithBlock:
                    ^{
                      [self walkOutEnemyAtIndex:ENEMY_TWO_INDEX speedMultiplier:0.75f target:nil selector:nil];
                    }],
                   [CCActionDelay actionWithDuration:2.f],
                   [CCActionCallBlock actionWithBlock:
                    ^{
                      [bs2 stopWalking];
                      [bs2 stopAllActions];
                      bs2.isFacingNear = YES;
                      [bs2 beginWalking];
                      [bs2 runAction:
                       [CCActionSequence actions:
                        [CCActionMoveTo actionWithDuration:ccpDistance(startPos, bs2.position)/MY_WALKING_SPEED/1.5f position:startPos],
                        [CCActionCallFunc actionWithTarget:self selector:@selector(enemyTwoAttackEnemyAndRunOut)], nil]];
                    }],
                   nil]];
}

- (void) enemyTwoAttackEnemyAndRunOut {
  BattleSprite *bs = self.enemyTeamSprites[ENEMY_TWO_INDEX];
  [bs stopWalking];
  [bs restoreStandingFrame:MapDirectionNearRight];
  [self runAction:[CCActionSequence actions:
                   [CCActionDelay actionWithDuration:1.f],
                   [CCActionCallBlock actionWithBlock:
                    ^{
                      [self enemyTwoAttackEnemyWithTarget:self selector:@selector(enemyTwoRunOut)];
                    }], nil]];
}

- (void) enemyTwoRunOut {
  [self walkOutEnemyAtIndex:ENEMY_TWO_INDEX speedMultiplier:2.f target:self selector:@selector(moveEnemyToStartLocation)];
}

- (void) moveEnemyToStartLocation {
  self.enemyPlayerObject = self.enemyTeam[ENEMY_INDEX];
  self.currentEnemy = self.enemyTeamSprites[ENEMY_INDEX];
  [self moveBattleSprite:self.currentEnemy toEnemyStartLocationAndCallSelector:@selector(enemiesRanOut) isComingFromTop:NO];
  _curStage = ENEMY_INDEX;
  [self scheduleOnce:@selector(displayOrbLayer) delay:0.5];
}

- (void) makeEnemyTwoAndBossRunIn {
  for (int i = 0; i < self.enemyTeamSprites.count; i++) {
    if (i != ENEMY_INDEX) {
      [self walkInEnemyTeamSpriteAtIndex:i shouldRunIn:NO];
    }
  }
}

- (void) enemyBossWalkOut {
  BattleSprite *bs = self.enemyTeamSprites[ENEMY_TWO_INDEX];
  [bs jumpNumTimes:2 completionTarget:self selector:@selector(moveEnemyTwoToStartLocation)];
}

- (void) moveEnemyTwoToStartLocation {
  [self walkOutEnemyAtIndex:ENEMY_BOSS_INDEX speedMultiplier:1.f target:nil selector:nil];
  self.enemyPlayerObject = self.enemyTeam[ENEMY_TWO_INDEX];
  self.currentEnemy = self.enemyTeamSprites[ENEMY_TWO_INDEX];
  [self moveBattleSprite:self.currentEnemy toEnemyStartLocationAndCallSelector:@selector(enemiesRanOut) isComingFromTop:YES];
  _curStage = ENEMY_TWO_INDEX;
}

- (float) damageMultiplierIsEnemyAttacker:(BOOL)isEnemy {
  return 1.f;
}

- (void) friendKneel {
  [self.myPlayer restoreStandingFrame:MapDirectionKneel];
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

- (void) beginNextTurn {
  _displayedWaveNumber = YES;
  _reachedNextScene = YES;
  [super beginNextTurn];
}

- (void) processNextTurn:(float)delay
{
  [super processNextTurn:0.3];
}

#pragma mark - Actual battle

- (void) beginFirstMove {
  if (_curStage == ENEMY_INDEX) {
    [self.orbLayer createOverlayAvoidingPositions:[NSArray arrayWithObjects:
                                                   [NSValue valueWithCGPoint:ccp(3, 1)],
                                                   [NSValue valueWithCGPoint:ccp(3, 2)],
                                                   [NSValue valueWithCGPoint:ccp(3, 3)],
                                                   [NSValue valueWithCGPoint:ccp(2, 2)], nil]
                                   withForcedMove:[NSArray arrayWithObjects:
                                                   [NSValue valueWithCGPoint:ccp(3, 2)],
                                                   [NSValue valueWithCGPoint:ccp(2, 2)], nil]];
  } else if (_curStage == ENEMY_TWO_INDEX) {
    [self.orbLayer createOverlayAvoidingPositions:[NSArray arrayWithObjects:
                                                   [NSValue valueWithCGPoint:ccp(2, 4)],
                                                   [NSValue valueWithCGPoint:ccp(3, 4)],
                                                   [NSValue valueWithCGPoint:ccp(4, 4)],
                                                   [NSValue valueWithCGPoint:ccp(5, 4)],
                                                   [NSValue valueWithCGPoint:ccp(4, 5)],nil]
                                   withForcedMove:[NSArray arrayWithObjects:
                                                   [NSValue valueWithCGPoint:ccp(4, 4)],
                                                   [NSValue valueWithCGPoint:ccp(4, 5)], nil]];
  }
  
  [super beginFirstMove];
}

- (void) beginSecondMove {
  if (_curStage == ENEMY_INDEX) {
    [self.orbLayer createOverlayAvoidingPositions:[NSArray arrayWithObjects:
                                                   [NSValue valueWithCGPoint:ccp(3, 2)],
                                                   [NSValue valueWithCGPoint:ccp(3, 3)],
                                                   [NSValue valueWithCGPoint:ccp(3, 4)],
                                                   [NSValue valueWithCGPoint:ccp(3, 1)], nil]
                                   withForcedMove:[NSArray arrayWithObjects:
                                                   [NSValue valueWithCGPoint:ccp(3, 3)],
                                                   [NSValue valueWithCGPoint:ccp(3, 4)], nil]];
  } else if (_curStage == ENEMY_TWO_INDEX) {
    [self.orbLayer createOverlayAvoidingPositions:[NSArray arrayWithObjects:
                                                   [NSValue valueWithCGPoint:ccp(3, 3)],
                                                   [NSValue valueWithCGPoint:ccp(4, 3)],
                                                   [NSValue valueWithCGPoint:ccp(5, 3)],
                                                   [NSValue valueWithCGPoint:ccp(4, 4)], nil]
                                   withForcedMove:[NSArray arrayWithObjects:
                                                   [NSValue valueWithCGPoint:ccp(4, 3)],
                                                   [NSValue valueWithCGPoint:ccp(4, 4)], nil]];
  }
  
  [super beginSecondMove];
}

- (void) dealDamage:(int)damageDone enemyIsAttacker:(BOOL)enemyIsAttacker usingAbility:(BOOL)usingAbility withTarget:(id)target withSelector:(SEL)selector {
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
  
  [super dealDamage:damageDone enemyIsAttacker:enemyIsAttacker usingAbility:usingAbility withTarget:target withSelector:selector];
}

- (void) swapToMark {
  _orbCount = 0;
  self.swappableTeamSlot = 2;
  self.hudView.swapView.hidden = NO;
  [self.hudView displaySwapButton];
  
  [self runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:0.3f],
    [CCActionCallBlock actionWithBlock:
     ^{
       [Globals createUIArrowForView:self.hudView.swapView atAngle:0];
     }], nil]];
}

- (void) displayDeployViewAndIsCancellable:(BOOL)cancel {
  [super displayDeployViewAndIsCancellable:cancel];
  
  [Globals removeUIArrowFromViewRecursively:self.hudView.swapView.superview];
  
  [self runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:0.3f],
    [CCActionCallBlock actionWithBlock:
     ^{
       BattleDeployCardView *card = self.hudView.deployView.cardViews[1];
       [Globals createUIArrowForView:card.superview atAngle:M_PI_2];
     }], nil]];
}

- (void) deployBattleSprite:(BattlePlayer *)bp {
  if (!self.myPlayer || bp.slotNum == self.swappableTeamSlot) {
    [super deployBattleSprite:bp];
    
    // Make sure zark is the next attacker in the schedule. There will only be 2 values so dequeue if he's not.
    if (![[self.battleSchedule getNextNMoves:1][0] boolValue]) {
      [self.battleSchedule dequeueNextMove];
    }
    
    [self.delegate swappedToMark];
    [Globals removeUIArrowFromViewRecursively:self.hudView.deployView];
  }
}

- (NSString *) presetLayoutFile {
  return @"TutorialBattle1Layout.txt";
}

@end

@implementation TutorialBattleLayer

- (id) initWithConstants:(StartupResponseProto_TutorialConstants *)constants {
  Globals *gl = [Globals sharedGlobals];
  UserMonster *um1 = [[UserMonster alloc] init];
  um1.userMonsterUuid = @"1";
  um1.monsterId = constants.startingMonsterId;
  um1.level = 1;
  um1.curHealth = [gl calculateMaxHealthForMonster:um1];
  um1.teamSlot = 1;
  
  UserMonster *um2 = [[UserMonster alloc] init];
  um2.userMonsterUuid = @"2";
  um2.monsterId = constants.markZmonsterId;
  um2.level = 15;
  um2.curHealth = [gl calculateMaxHealthForMonster:um2];
  um2.teamSlot = 2;
  NSArray *myMons = [NSArray arrayWithObjects:um1, um2, nil];
  if ((self = [super initWithMyUserMonsters:myMons puzzleIsOnLeft:NO gridSize:CGSizeMake(6, 6)])) {
    self.constants = constants;
  
    
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

- (void) loadHudView {
  [super loadHudView];
  [self.hudView.battleScheduleView removeFromSuperview];
  [self.hudView.bottomView removeFromSuperview];
  [self.hudView.elementButton removeFromSuperview];
  [self.hudView.elementView removeFromSuperview];
}

- (void) sendServerUpdatedValuesVerifyDamageDealt:(BOOL)verify {
  // Do nothing
}

- (void) saveCurrentStateWithForceFlush:(BOOL) flush {
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

- (void) begin {
  [self deployBattleSprite:[self firstMyPlayer]];
}

@end
