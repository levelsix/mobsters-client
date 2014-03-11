//
//  TutorialMissionMap.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/2/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialMissionMap.h"
#import "GameState.h"

#define INITIAL_X self.mapSize.width-2
#define INITIAL_Y self.mapSize.height-1

#define FIRST_BUILDING_ENTER_X ms.location.origin.x+2.2
#define FIRST_BUILDING_ENTER_Y ms.location.origin.y-1.8
#define FIRST_ENEMY_CONFRONTATION_X FIRST_BUILDING_ENTER_X+1.6
#define FIRST_FRIEND_CONFRONTATION_X FIRST_BUILDING_ENTER_X-1.6

#define ENEMY_FIRST_RUN_OFF_Y ms.location.origin.y+6
#define FIRST_TWO_GUYS_Y_ABOVE FIRST_BUILDING_ENTER_Y+0.6
#define FIRST_TWO_GUYS_Y_BELOW FIRST_BUILDING_ENTER_Y-1.1

#define SECOND_BUILDING_RUN_X ms.location.origin.x-2.3
#define SECOND_BUILDING_ENTER_X ms.location.origin.x+1.5
#define SECOND_BUILDING_ENTER_Y ms.location.origin.y-1.8

#define ENEMY_SECOND_RUN_OFF_Y ms.location.origin.y+6
#define ENEMY_SECOND_RUN_OFF_X ms.location.origin.x+4
#define SECOND_ENEMY_CONFRONTATION_Y ms.location.origin.y+1.5
#define SECOND_FRIEND_CONFRONTATION_Y ms.location.origin.y-1.8
#define SECOND_TWO_GUYS_X_LEFT ms.location.origin.x-2.8
#define SECOND_TWO_GUYS_X_RIGHT ms.location.origin.x-1.2

#define YACHT_STAIR_START_POINT ccp(6.5, -1)
#define YACHT_STAIR_END_POINT ccp(5.8, -3.5)
#define YACHT_BOARD_POINT ccp(5.8, -5)


@implementation TutorialMissionMap

- (id) initWithTutorialConstants:(StartupResponseProto_TutorialConstants *)constants {
  LoadCityResponseProto_Builder *bldr = [LoadCityResponseProto builder];
  [bldr addAllCityElements:constants.cityOneElementsList];
  bldr.cityId = constants.cityId;
  if ((self = [super initWithProto:bldr.build])) {
    self.constants = constants;
    _mapMovementDivisor = 400.f;
    self.scale = 1.5f;
    
    [self.enemySprite restoreStandingFrame:MapDirectionNearRight];
    [self.enemySprite recursivelyApplyOpacity:0.f];
    self.enemySprite.location = CGRectMake(INITIAL_X, INITIAL_Y, 1, 1);
    [self moveToSprite:self.enemySprite animated:NO];
    
    self.boatSprite = [CCSprite spriteWithImageNamed:@"marksboat.png"];
    [self addChild:self.boatSprite];
    self.boatSprite.position = ccp(540, -40);
    
    self.cityId = -1;
  }
  return self;
}

#pragma mark - Create animated sprites on the fly

- (AnimatedSprite *) createSpriteWithId:(int)monsterId {
  GameState *gs = [GameState sharedGameState];
  MonsterProto *mp = [gs monsterWithId:monsterId];
  CGRect r = CGRectMake(0, 0, 1, 1);
  AnimatedSprite *as = [[AnimatedSprite alloc] initWithFile:mp.imagePrefix location:r map:self];
  as.constrainedToBoundary = NO;
  [as stopWalking];
  [self addChild:as];
  return as;
}

- (AnimatedSprite *) enemySprite {
  if (!_enemySprite) {
    self.enemySprite = [self createSpriteWithId:self.constants.enemyMonsterId];
  }
  return _enemySprite;
}

- (AnimatedSprite *) friendSprite {
  if (!_friendSprite) {
    self.friendSprite = [self createSpriteWithId:self.constants.startingMonsterId];
  }
  return _friendSprite;
}

- (AnimatedSprite *) enemyBossSprite {
  if (!_enemyBossSprite) {
    self.enemyBossSprite = [self createSpriteWithId:self.constants.enemyBossMonsterId];
  }
  return _enemyBossSprite;
}

- (AnimatedSprite *) markZSprite {
  if (!_markZSprite) {
    self.markZSprite = [self createSpriteWithId:self.constants.markZmonsterId];
  }
  return _markZSprite;
}

- (void) followSprite:(CCSprite *)ms {
  [self runAction:
   [CCActionRepeatForever actionWithAction:
    [CCActionSequence actions:
     [CCActionDelay actionWithDuration:0.005],
     [CCActionCallBlock actionWithBlock:
      ^{
        [self moveToSprite:ms animated:NO];
      }], nil]]];
}

#pragma mark - Tutorial Sequence

- (void) beginInitialChase {
  MapSprite *ms = [self assetWithId:self.constants.cityElementIdForFirstDungeon];
  [self.enemySprite runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:0.3f],
    [RecursiveFadeTo actionWithDuration:0.3f opacity:1.f],
    [CCActionDelay actionWithDuration:0.2f],
    [CCActionCallBlock actionWithBlock:
     ^{
       [self.enemySprite walkToTileCoord:ccp(INITIAL_X, FIRST_BUILDING_ENTER_Y) completionTarget:self selector:@selector(fadeInFriendSprite) speedMultiplier:2.f];
       [self followSprite:self.enemySprite];
     }],
    nil]];
}

- (void) fadeInFriendSprite {
  [self.enemySprite restoreStandingFrame:MapDirectionNearRight];
  [self stopAllActions];
  
  self.friendSprite.location = CGRectMake(INITIAL_X, INITIAL_Y, 1, 1);
  [self.friendSprite restoreStandingFrame:MapDirectionNearRight];
  
  [self.friendSprite recursivelyApplyOpacity:0.f];
  [self.friendSprite runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:0.8f],
    [RecursiveFadeTo actionWithDuration:0.2f opacity:1.f],
    [CCActionCallBlock actionWithBlock:
     ^{
       // Make friend jump
       [self.friendSprite jumpNumTimes:2 completionTarget:self.delegate selector:@selector(initialChaseComplete)];
     }],
    nil]];
  [self moveToSprite:self.friendSprite animated:YES];
}

- (void) enemyJump {
  [self moveToSprite:self.enemySprite animated:YES];
  [self.enemySprite restoreStandingFrame:MapDirectionFarLeft];
  [self.enemySprite runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:1.2f],
    [CCActionCallBlock actionWithBlock:
     ^{
       [self.enemySprite jumpNumTimes:1 completionTarget:self.delegate selector:@selector(enemyJumped)];
     }], nil]];
}

- (void) enemyRunIntoFirstBuilding {
  [self.enemySprite jumpNumTimes:1 completionTarget:self selector:@selector(enemyJumpFinishedRunIntoFirstBuilding)];
}

- (void) enemyJumpFinishedRunIntoFirstBuilding {
  MissionBuilding *ms = (MissionBuilding *)[self assetWithId:self.constants.cityElementIdForFirstDungeon];
  [self moveToSprite:self.enemySprite animated:YES];
  [self.enemySprite walkToTileCoord:ccp(FIRST_BUILDING_ENTER_X, FIRST_BUILDING_ENTER_Y) completionTarget:self selector:@selector(fadeOutEnemySprite) speedMultiplier:2.f];
}

- (void) fadeOutEnemySprite {
  CGPoint pt = ccp(self.enemySprite.location.origin.x, self.enemySprite.location.origin.y+1.f);
  [self.enemySprite walkToTileCoord:pt completionTarget:self.enemySprite selector:@selector(stopWalking) speedMultiplier:1.f];
  [self.enemySprite runAction:[RecursiveFadeTo actionWithDuration:0.25 opacity:0.f]];
  
  MissionBuilding *ms = (MissionBuilding *)[self assetWithId:self.constants.cityElementIdForFirstDungeon];
  [self.friendSprite walkToTileCoord:ccp(INITIAL_X, FIRST_BUILDING_ENTER_Y) completionTarget:self selector:@selector(friendWalkedToFirstBuilding) speedMultiplier:2.f];
}

- (void) friendWalkedToFirstBuilding {
  // Move enemy sprite away so that it doesn't grab touches
  self.enemySprite.position = ccp(0,0);
  
  [self.friendSprite restoreStandingFrame:MapDirectionNearRight];
  float delay = 0.4f;
  [self.friendSprite runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:delay],
    [CCActionCallBlock actionWithBlock:^{ [self.friendSprite restoreStandingFrame:MapDirectionFarLeft]; }],
    [CCActionDelay actionWithDuration:delay],
    [CCActionCallBlock actionWithBlock:^{ [self.friendSprite restoreStandingFrame:MapDirectionNearRight]; }],
    [CCActionDelay actionWithDuration:delay],
    [CCActionCallBlock actionWithBlock:^{ [self.friendSprite restoreStandingFrame:MapDirectionFarRight]; }],
    [CCActionDelay actionWithDuration:delay],
    [CCActionCallBlock actionWithBlock:^{ [self.friendSprite restoreStandingFrame:MapDirectionNearLeft]; }],
    [CCActionCallFunc actionWithTarget:self.delegate selector:@selector(enemyRanIntoFirstBuilding)],
    nil]];
}

- (void) displayArrowOverFirstBuilding {
  MissionBuilding *ms = (MissionBuilding *)[self assetWithId:self.constants.cityElementIdForFirstDungeon];
  [ms displayArrow];
  [self moveToSprite:ms animated:YES withOffset:ccp(0, -38)];
  
  self.clickableAssetId = self.constants.cityElementIdForFirstDungeon;
}

- (void) performCurrentTask:(id)sender {
  if (self.clickableAssetId == self.constants.cityElementIdForFirstDungeon) {
    MissionBuilding *ms = (MissionBuilding *)[self assetWithId:self.constants.cityElementIdForFirstDungeon];
    [self.friendSprite walkToTileCoord:ccp(FIRST_BUILDING_ENTER_X, FIRST_BUILDING_ENTER_Y) completionTarget:self selector:@selector(fadeOutFriendSprite) speedMultiplier:2.f];
  } else {
    [self.delegate enteredThirdBuilding];
  }
  
  self.clickableAssetId = 0;
  self.selected = nil;
  [Globals removeUIArrowFromViewRecursively:self.missionBotView];
}

- (void) fadeOutFriendSprite {
  CGPoint pt = ccp(self.friendSprite.location.origin.x, self.friendSprite.location.origin.y+1.f);
  [self.friendSprite walkToTileCoord:pt completionTarget:self.delegate selector:@selector(friendEnteredFirstBuilding) speedMultiplier:1.f];
  [self.friendSprite runAction:[RecursiveFadeTo actionWithDuration:0.25 opacity:0.f]];
}

- (void) beginSecondConfrontation {
  [self.enemySprite restoreStandingFrame:MapDirectionNearLeft];
  [self.friendSprite restoreStandingFrame:MapDirectionFarRight];
  
  [self.enemySprite recursivelyApplyOpacity:1.f];
  [self.friendSprite recursivelyApplyOpacity:1.f];
  
  MissionBuilding *ms = (MissionBuilding *)[self assetWithId:self.constants.cityElementIdForFirstDungeon];
  self.enemySprite.location = CGRectMake(FIRST_ENEMY_CONFRONTATION_X, FIRST_BUILDING_ENTER_Y, 1, 1);
  self.friendSprite.location = CGRectMake(FIRST_FRIEND_CONFRONTATION_X, FIRST_BUILDING_ENTER_Y, 1, 1);
  
  [self moveToSprite:self.friendSprite animated:NO];
}

- (void) runOutEnemy {
  [self.enemySprite jumpNumTimes:1 completionTarget:self selector:@selector(enemyJumpFinishedRunOut)];
}

- (void) enemyJumpFinishedRunOut {
  MissionBuilding *ms = (MissionBuilding *)[self assetWithId:self.constants.cityElementIdForFirstDungeon];
  NSArray *tileCoords = @[[NSValue valueWithCGPoint:ccp(INITIAL_X, FIRST_BUILDING_ENTER_Y)], [NSValue valueWithCGPoint:ccp(INITIAL_X, ENEMY_FIRST_RUN_OFF_Y)]];
  [self.enemySprite walkToTileCoords:tileCoords completionTarget:self.delegate selector:@selector(enemyRanOffMap) speedMultiplier:2.f];
}

- (void) enemyComeInWithBoss {
  MissionBuilding *ms = (MissionBuilding *)[self assetWithId:self.constants.cityElementIdForFirstDungeon];
  NSArray *tileCoords = @[[NSValue valueWithCGPoint:ccp(INITIAL_X, FIRST_TWO_GUYS_Y_ABOVE)], [NSValue valueWithCGPoint:ccp(FIRST_ENEMY_CONFRONTATION_X, FIRST_TWO_GUYS_Y_ABOVE)]];
  [self.enemySprite walkToTileCoords:tileCoords completionTarget:self selector:@selector(enemySpriteStopRunning) speedMultiplier:2.f];
  
  self.enemyBossSprite.location = CGRectMake(INITIAL_X, ENEMY_FIRST_RUN_OFF_Y+2, 1, 1);
  tileCoords = @[[NSValue valueWithCGPoint:ccp(INITIAL_X, FIRST_TWO_GUYS_Y_BELOW)], [NSValue valueWithCGPoint:ccp(FIRST_ENEMY_CONFRONTATION_X, FIRST_TWO_GUYS_Y_BELOW)]];
  [self.enemyBossSprite walkToTileCoords:tileCoords completionTarget:self selector:@selector(enemyBossReachedConfrontation) speedMultiplier:2.f];
}

- (void) enemySpriteStopRunning {
  [self.enemySprite restoreStandingFrame:MapDirectionNearLeft];
}

- (void) enemyBossReachedConfrontation {
  [self.enemyBossSprite restoreStandingFrame:MapDirectionNearLeft];
  [self.delegate enemyArrivedWithBoss];
}

- (void) friendWalkUpToBoss {
  [self followSprite:self.friendSprite];
  CGPoint finalPos = ccp(self.enemyBossSprite.location.origin.x-1.8, self.enemyBossSprite.location.origin.y);
  NSArray *tileCoords = @[[NSValue valueWithCGPoint:ccp(finalPos.x, self.friendSprite.location.origin.y)], [NSValue valueWithCGPoint:finalPos]];
  [self.friendSprite walkToTileCoords:tileCoords completionTarget:self selector:@selector(friendJumpAfterReachingBoss) speedMultiplier:2.f];
}

- (void) friendJumpAfterReachingBoss {
  [self stopAllActions];
  
  [self.friendSprite restoreStandingFrame:MapDirectionFarRight];
  
  [self.friendSprite runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:1.f],
    [CCActionCallBlock actionWithBlock:
     ^{
       [self.friendSprite jumpNumTimes:2 completionTarget:self.delegate selector:@selector(friendWalkedUpToBoss)];
     }],
    nil]];
}

- (void) enemyTurnToBoss {
  [self.enemySprite restoreStandingFrame:MapDirectionNearRight];
}

- (void) beginChaseIntoSecondBuilding {
  [self followSprite:self.friendSprite];
  [self firstStutter];
}

- (void) firstStutter {
  [self stutterWithSelector:@selector(secondStutter)];
}

- (void) secondStutter {
  [self.enemyBossSprite restoreStandingFrame:MapDirectionNearLeft];
  
  [self runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:0.5f],
    [CCActionCallBlock actionWithBlock:
     ^{
       [self stutterWithSelector:@selector(runToSecondBuilding)];
     }],
    nil]];
}

- (void) stutterWithSelector:(SEL)selector {
  [self.enemySprite restoreStandingFrame:MapDirectionNearLeft];
  [self.friendSprite walkToTileCoord:ccp(self.friendSprite.location.origin.x-1, self.friendSprite.location.origin.y) completionTarget:self selector:@selector(friendFaceFarRight) speedMultiplier:2.f];
  [self.enemyBossSprite runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:0.3f],
    [CCActionCallBlock actionWithBlock:
     ^{
       [self.enemyBossSprite walkToTileCoord:ccp(self.enemyBossSprite.location.origin.x-1, self.friendSprite.location.origin.y) completionTarget:self selector:selector speedMultiplier:2.f];
     }],
    nil]];
}

- (void) friendFaceFarRight {
  [self.friendSprite restoreStandingFrame:MapDirectionFarRight];
}

- (void) runToSecondBuilding {
  [self.enemyBossSprite restoreStandingFrame:MapDirectionNearLeft];

  [self runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:0.5f],
    [CCActionCallBlock actionWithBlock:
     ^{
       [self runIntoSecondBuildingAnimatedSprite:self.friendSprite withDelay:0.f];
       [self runIntoSecondBuildingAnimatedSprite:self.enemySprite withDelay:0.8f];
       [self runIntoSecondBuildingAnimatedSprite:self.enemyBossSprite withDelay:0.8f];
     }], nil]];
}

- (void) runIntoSecondBuildingAnimatedSprite:(AnimatedSprite *)as withDelay:(float)delay {
  MissionBuilding *ms = (MissionBuilding *)[self assetWithId:self.constants.cityElementIdForSecondDungeon];
  NSArray *tileCoords = @[[NSValue valueWithCGPoint:ccp(SECOND_BUILDING_RUN_X, as.location.origin.y)],
                          [NSValue valueWithCGPoint:ccp(SECOND_BUILDING_RUN_X, SECOND_BUILDING_ENTER_Y)],
                          [NSValue valueWithCGPoint:ccp(SECOND_BUILDING_ENTER_X, SECOND_BUILDING_ENTER_Y)]];
  [as runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:delay],
    [CCActionCallBlock actionWithBlock:
     ^{
       [as walkToTileCoords:tileCoords completionTarget:self selector:@selector(animatedSpriteEnterSecondBuilding:) speedMultiplier:2.f];
     }],
    nil]];
}

- (void) animatedSpriteEnterSecondBuilding:(AnimatedSprite *)as {
  CGPoint pt = ccp(as.location.origin.x, as.location.origin.y+1.f);
  [as walkToTileCoord:pt completionTarget:self selector:@selector(animatedSpriteEnteredSecondBuilding:) speedMultiplier:1.f];
  [as runAction:[RecursiveFadeTo actionWithDuration:0.25 opacity:0.f]];
}

- (void) animatedSpriteEnteredSecondBuilding:(AnimatedSprite *)as {
  [as stopWalking];
  
  if (as == self.enemySprite) {
    [self.delegate everyoneEnteredSecondBuilding];
    [self stopAllActions];
  }
}

- (void) beginThirdConfrontation {
  [self.enemySprite recursivelyApplyOpacity:1.f];
  [self.enemyBossSprite recursivelyApplyOpacity:1.f];
  [self.friendSprite recursivelyApplyOpacity:1.f];
  [self.markZSprite recursivelyApplyOpacity:1.f];
  
  [self.enemySprite restoreStandingFrame:MapDirectionNearRight];
  [self.enemyBossSprite restoreStandingFrame:MapDirectionNearRight];
  [self.friendSprite restoreStandingFrame:MapDirectionFarLeft];
  [self.markZSprite restoreStandingFrame:MapDirectionFarLeft];
  
  MissionBuilding *ms = (MissionBuilding *)[self assetWithId:self.constants.cityElementIdForSecondDungeon];
  self.enemySprite.location = CGRectMake(SECOND_TWO_GUYS_X_RIGHT, SECOND_ENEMY_CONFRONTATION_Y, 1, 1);
  self.enemyBossSprite.location = CGRectMake(SECOND_TWO_GUYS_X_LEFT, SECOND_ENEMY_CONFRONTATION_Y, 1, 1);
  self.friendSprite.location = CGRectMake(SECOND_TWO_GUYS_X_RIGHT, SECOND_FRIEND_CONFRONTATION_Y, 1, 1);
  self.markZSprite.location = CGRectMake(SECOND_TWO_GUYS_X_LEFT, SECOND_FRIEND_CONFRONTATION_Y, 1, 1);
  
  [self moveToSprite:self.friendSprite animated:NO withOffset:ccp(20, -24)];
}

- (void) runOutEnemyBoss {
  MissionBuilding *ms = (MissionBuilding *)[self assetWithId:self.constants.cityElementIdForSecondDungeon];
  NSArray *tileCoords = @[[NSValue valueWithCGPoint:ccp(self.enemySprite.location.origin.x, ENEMY_SECOND_RUN_OFF_Y)], [NSValue valueWithCGPoint:ccp(ENEMY_SECOND_RUN_OFF_X, ENEMY_SECOND_RUN_OFF_Y)]];
  [self.enemySprite walkToTileCoords:tileCoords completionTarget:self.enemySprite selector:@selector(stopWalking) speedMultiplier:2.f];
  
  tileCoords = @[[NSValue valueWithCGPoint:ccp(self.enemyBossSprite.location.origin.x, ENEMY_SECOND_RUN_OFF_Y)], [NSValue valueWithCGPoint:ccp(ENEMY_SECOND_RUN_OFF_X, ENEMY_SECOND_RUN_OFF_Y)]];
  [self.enemyBossSprite walkToTileCoords:tileCoords completionTarget:self selector:@selector(enemyBossLeftScene) speedMultiplier:2.f];
}

- (void) enemyBossLeftScene {
  [self.delegate enemyBossRanOffMap];
}

- (void) markLooksAtYou {
  [self.markZSprite restoreStandingFrame:MapDirectionFront];
}

- (void) moveToYacht {
  [self.friendSprite restoreStandingFrame:MapDirectionNearLeft];
  [self.markZSprite restoreStandingFrame:MapDirectionFarRight];
  
  [self.markZSprite runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:0.7],
    [CCActionCallBlock actionWithBlock:
     ^{
       [self.markZSprite jumpNumTimes:1 completionTarget:nil selector:nil];
     }],
    nil]];
  [self.friendSprite runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:0.85],
    [CCActionCallBlock actionWithBlock:
     ^{
       [self.friendSprite jumpNumTimes:1 completionTarget:self selector:@selector(walkToYacht)];
     }],
    nil]];
  
  [self moveToSprite:self.markZSprite animated:YES];
}

- (void) walkToYacht {
  NSArray *baseCoords = @[[NSValue valueWithCGPoint:YACHT_STAIR_START_POINT], [NSValue valueWithCGPoint:YACHT_STAIR_END_POINT], [NSValue valueWithCGPoint:YACHT_BOARD_POINT]];
  
  NSArray *tileCoords = [@[[NSValue valueWithCGPoint:ccp(YACHT_STAIR_START_POINT.x, self.friendSprite.location.origin.y)]] arrayByAddingObjectsFromArray:baseCoords];
  [self.friendSprite walkToTileCoords:tileCoords completionTarget:self selector:@selector(animatedSpriteReachedYacht:) speedMultiplier:1.7f];
  
  tileCoords = [@[[NSValue valueWithCGPoint:ccp(YACHT_STAIR_START_POINT.x, self.markZSprite.location.origin.y)]] arrayByAddingObjectsFromArray:baseCoords];
  [self.markZSprite walkToTileCoords:tileCoords completionTarget:self selector:@selector(animatedSpriteReachedYacht:) speedMultiplier:1.7f];
  
  [self followSprite:self.markZSprite];
}

- (void) animatedSpriteReachedYacht:(AnimatedSprite *)as {
  [self stopAllActions];
  [as restoreStandingFrame:MapDirectionNearLeft];
  [as runAction:[CCActionSequence actions:
                 [CCActionDelay actionWithDuration:0.3],
                 [RecursiveFadeTo actionWithDuration:0.2 opacity:0.f],
                 [CCActionCallBlock actionWithBlock:
                  ^{
                    if (as == self.friendSprite) {
                      [self floatBoatOffScreen];
                    }
                  }],
                 nil]];
  
  [as jumpNumTimes:1 timePerJump:0.4f completionTarget:nil selector:nil];
  [as walkToTileCoord:ccp(as.location.origin.x-2.5, as.location.origin.y) completionTarget:nil selector:nil speedMultiplier:1.7f];
}

- (void) floatBoatOffScreen {
  CGPoint ptOffset = POINT_OFFSET_PER_SCENE;
  [self.boatSprite runAction:
   [CCActionSequence actions:
    [CCActionMoveBy actionWithDuration:2.5f position:ccpMult(ptOffset, -0.19)],
    [CCActionCallFunc actionWithTarget:self.delegate selector:@selector(yachtWentOffScene)], nil]];
}

- (void) moveToThirdBuilding {
  Globals *gl = [Globals sharedGlobals];
  int assetId = gl.miniTutorialConstants.rainbowTutorialAssetId;
  self.scale = 1.1f;
  MapSprite *ms = [self assetWithId:assetId];
  [self moveToSprite:ms animated:NO];
}

- (void) displayArrowOverThirdBuilding {
  Globals *gl = [Globals sharedGlobals];
  int assetId = gl.miniTutorialConstants.rainbowTutorialAssetId;
  MissionBuilding *ms = (MissionBuilding *)[self assetWithId:assetId];
  
  [self moveToSprite:ms animated:YES withOffset:ccp(0, -38)];
  [ms displayArrow];
  
  self.clickableAssetId = assetId;
}

#pragma mark - Overwritten methods

- (void) setAllLocksAndArrowsForBuildings {
  for (CCNode *n in self.children) {
    if ([n conformsToProtocol:@protocol(TaskElement)]) {
      id<TaskElement> asset = (id<TaskElement>)n;
      asset.isLocked = NO;
      [asset removeArrowAnimated:NO];
    }
  }
}

- (SelectableSprite *) selectableForPt:(CGPoint)pt {
  SelectableSprite *ss = [super selectableForPt:pt];
  if (ss == [self assetWithId:self.clickableAssetId]) {
    [ss removeArrowAnimated:YES];
    return ss;
  }
  return nil;
}

- (void) setSelected:(SelectableSprite *)selected {
  if (self.selected == [self assetWithId:self.clickableAssetId]) {
    return;
  }
  [super setSelected:selected];
}

- (void) updateMapBotView:(MapBotView *)botView {
  [super updateMapBotView:botView];
  float angle = [Globals isLongiPhone] ? M_PI_2 : M_PI;
  [Globals createUIArrowForView:self.enterButton atAngle:angle];
}

- (void) drag:(UIGestureRecognizer *)recognizer {
  // Do nothing
}

- (void) scale:(UIGestureRecognizer *)recognizer {
  // Do nothing
}

@end
