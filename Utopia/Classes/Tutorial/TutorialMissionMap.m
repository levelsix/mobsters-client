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
#define ENEMY_CONFRONTATION_X FIRST_BUILDING_ENTER_X+1.6
#define FRIEND_CONFRONTATION_X FIRST_BUILDING_ENTER_X-1.6
#define ENEMY_FIRST_RUN_OFF_Y ms.location.origin.y+6
#define TWO_GUYS_Y_ABOVE 0.6
#define TWO_GUYS_Y_BELOW 1.1
#define SECOND_BUILDING_RUN_X ms.location.origin.x-2.3
#define SECOND_BUILDING_ENTER_X ms.location.origin.x+2
#define SECOND_BUILDING_ENTER_Y ms.location.origin.y-1.8
#define ENEMY_SECOND_RUN_OFF_Y ms.location.origin.y+2

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
  }
  return self;
}

#pragma mark - Create animated sprites on the fly

- (AnimatedSprite *) createSpriteWithId:(int)monsterId {
  GameState *gs = [GameState sharedGameState];
  MonsterProto *mp = [gs monsterWithId:monsterId];
  CGRect r = CGRectMake(0, 0, 1, 1);
  AnimatedSprite *as = [[AnimatedSprite alloc] initWithFile:mp.imagePrefix location:r map:self];
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

- (void) followSprite:(MapSprite *)ms {
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
       [self.friendSprite jumpNumTimes:1 completionTarget:self.delegate selector:@selector(initialChaseComplete)];
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
       [self.enemySprite jumpNumTimes:2 completionTarget:self.delegate selector:@selector(enemyJumped)];
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
  [self.enemySprite runAction:[RecursiveFadeTo actionWithDuration:0.3 opacity:0.f]];
  
  MissionBuilding *ms = (MissionBuilding *)[self assetWithId:self.constants.cityElementIdForFirstDungeon];
  [self.friendSprite walkToTileCoord:ccp(INITIAL_X, FIRST_BUILDING_ENTER_Y) completionTarget:self selector:@selector(friendWalkedToFirstBuilding) speedMultiplier:2.f];
}

- (void) friendWalkedToFirstBuilding {
  // Move enemy sprite away so that it doesn't grab touches
  self.enemySprite.position = ccp(0,0);
  
  float delay = 0.3f;
  [self.friendSprite runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:delay],
    [CCActionCallBlock actionWithBlock:^{ [self.friendSprite restoreStandingFrame:MapDirectionFarLeft]; }],
    [CCActionDelay actionWithDuration:delay],
    [CCActionCallBlock actionWithBlock:^{ [self.friendSprite restoreStandingFrame:MapDirectionNearRight]; }],
    [CCActionDelay actionWithDuration:delay],
    [CCActionCallBlock actionWithBlock:^{ [self.friendSprite restoreStandingFrame:MapDirectionNearLeft]; }],
    nil]];
}

- (void) friendFinishedLookingAround {
  [self.friendSprite restoreStandingFrame:MapDirectionNearLeft];
  [self.delegate enemyRanIntoFirstBuilding];
}

- (void) displayArrowOverFirstBuilding {
  MissionBuilding *ms = (MissionBuilding *)[self assetWithId:self.constants.cityElementIdForFirstDungeon];
  [ms displayArrow];
  [self moveToSprite:ms animated:YES withOffset:ccp(0, -38)];
  
  self.clickableAssetId = self.constants.cityElementIdForFirstDungeon;
}

- (void) performCurrentTask:(id)sender {
  self.clickableAssetId = 0;
  self.selected = nil;
  
  MissionBuilding *ms = (MissionBuilding *)[self assetWithId:self.constants.cityElementIdForFirstDungeon];
  [self.friendSprite walkToTileCoord:ccp(FIRST_BUILDING_ENTER_X, FIRST_BUILDING_ENTER_Y) completionTarget:self selector:@selector(fadeOutFriendSprite) speedMultiplier:2.f];
}

- (void) fadeOutFriendSprite {
  CGPoint pt = ccp(self.friendSprite.location.origin.x, self.friendSprite.location.origin.y+1.f);
  [self.friendSprite walkToTileCoord:pt completionTarget:self.delegate selector:@selector(friendEnteredFirstBuilding) speedMultiplier:1.f];
  [self.friendSprite runAction:[RecursiveFadeTo actionWithDuration:0.3 opacity:0.f]];
}

- (void) beginSecondConfrontation {
  [self.enemySprite recursivelyApplyOpacity:1.f];
  [self.friendSprite recursivelyApplyOpacity:1.f];
  
  [self.enemySprite restoreStandingFrame:MapDirectionNearLeft];
  [self.friendSprite restoreStandingFrame:MapDirectionFarRight];
  
  MissionBuilding *ms = (MissionBuilding *)[self assetWithId:self.constants.cityElementIdForFirstDungeon];
  self.enemySprite.location = CGRectMake(ENEMY_CONFRONTATION_X, FIRST_BUILDING_ENTER_Y, 1, 1);
  self.friendSprite.location = CGRectMake(FRIEND_CONFRONTATION_X, FIRST_BUILDING_ENTER_Y, 1, 1);
  
  [self moveToSprite:self.friendSprite animated:NO withOffset:ccp(-20, -18)];
}

- (void) runOutEnemy {
  [self.enemySprite jumpNumTimes:2 completionTarget:self selector:@selector(enemyJumpFinishedRunOut)];
}

- (void) enemyJumpFinishedRunOut {
  MissionBuilding *ms = (MissionBuilding *)[self assetWithId:self.constants.cityElementIdForFirstDungeon];
  NSArray *tileCoords = @[[NSValue valueWithCGPoint:ccp(INITIAL_X, FIRST_BUILDING_ENTER_Y)], [NSValue valueWithCGPoint:ccp(INITIAL_X, ENEMY_FIRST_RUN_OFF_Y)]];
  [self.enemySprite walkToTileCoords:tileCoords completionTarget:self.delegate selector:@selector(enemyRanOffMap) speedMultiplier:2.f];
}

- (void) enemyComeInWithBoss {
  MissionBuilding *ms = (MissionBuilding *)[self assetWithId:self.constants.cityElementIdForFirstDungeon];
  NSArray *tileCoords = @[[NSValue valueWithCGPoint:ccp(INITIAL_X, FIRST_BUILDING_ENTER_Y+TWO_GUYS_Y_ABOVE)], [NSValue valueWithCGPoint:ccp(ENEMY_CONFRONTATION_X, FIRST_BUILDING_ENTER_Y+0.3)]];
  [self.enemySprite walkToTileCoords:tileCoords completionTarget:self selector:@selector(enemySpriteStopRunning) speedMultiplier:2.f];
  
  self.enemyBossSprite.location = CGRectMake(INITIAL_X, ENEMY_FIRST_RUN_OFF_Y+2, 1, 1);
  tileCoords = @[[NSValue valueWithCGPoint:ccp(INITIAL_X, FIRST_BUILDING_ENTER_Y-TWO_GUYS_Y_BELOW)], [NSValue valueWithCGPoint:ccp(ENEMY_CONFRONTATION_X, FIRST_BUILDING_ENTER_Y-TWO_GUYS_Y_BELOW)]];
  [self.enemyBossSprite walkToTileCoords:tileCoords completionTarget:self selector:@selector(enemyBossReachedConfrontation) speedMultiplier:2.f];
}

- (void) enemySpriteStopRunning {
  [self.enemySprite restoreStandingFrame:MapDirectionNearLeft];
}

- (void) enemyBossReachedConfrontation {
  [self.enemyBossSprite restoreStandingFrame:MapDirectionNearLeft];
  [self.delegate enemyArrivedWithBoss];
}

- (void) beginChaseIntoSecondBuilding {
  [self runIntoSecondBuildingAnimatedSprite:self.friendSprite withDelay:0.f];
  [self runIntoSecondBuildingAnimatedSprite:self.enemySprite withDelay:0.5f];
  [self runIntoSecondBuildingAnimatedSprite:self.enemyBossSprite withDelay:0.5f];
  [self followSprite:self.friendSprite];
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
  [as runAction:[RecursiveFadeTo actionWithDuration:0.3 opacity:0.f]];
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
  
  [self.enemySprite restoreStandingFrame:MapDirectionNearLeft];
  [self.enemyBossSprite restoreStandingFrame:MapDirectionNearLeft];
  [self.friendSprite restoreStandingFrame:MapDirectionFarRight];
  [self.markZSprite restoreStandingFrame:MapDirectionFarRight];
  
  MissionBuilding *ms = (MissionBuilding *)[self assetWithId:self.constants.cityElementIdForSecondDungeon];
  self.enemySprite.location = CGRectMake(ENEMY_CONFRONTATION_X, FIRST_BUILDING_ENTER_Y+TWO_GUYS_Y_ABOVE, 1, 1);
  self.enemyBossSprite.location = CGRectMake(ENEMY_CONFRONTATION_X, FIRST_BUILDING_ENTER_Y-TWO_GUYS_Y_BELOW, 1, 1);
  self.friendSprite.location = CGRectMake(FRIEND_CONFRONTATION_X, FIRST_BUILDING_ENTER_Y+TWO_GUYS_Y_ABOVE, 1, 1);
  self.markZSprite.location = CGRectMake(FRIEND_CONFRONTATION_X, FIRST_BUILDING_ENTER_Y-TWO_GUYS_Y_BELOW, 1, 1);
  
  [self moveToSprite:self.friendSprite animated:NO withOffset:ccp(-20, -18)];
}

- (void) runOutEnemyBoss {
  MissionBuilding *ms = (MissionBuilding *)[self assetWithId:self.constants.cityElementIdForSecondDungeon];
  NSArray *tileCoords = @[[NSValue valueWithCGPoint:ccp(INITIAL_X, self.enemySprite.location.origin.y)], [NSValue valueWithCGPoint:ccp(INITIAL_X, ENEMY_SECOND_RUN_OFF_Y)]];
  [self.enemySprite walkToTileCoords:tileCoords completionTarget:self.enemySprite selector:@selector(stopWalking) speedMultiplier:2.f];
  
  tileCoords = @[[NSValue valueWithCGPoint:ccp(INITIAL_X, self.enemyBossSprite.location.origin.y)], [NSValue valueWithCGPoint:ccp(INITIAL_X, ENEMY_SECOND_RUN_OFF_Y)]];
  [self.enemyBossSprite walkToTileCoords:tileCoords completionTarget:self selector:@selector(enemyBossLeftScene) speedMultiplier:2.f];
}

- (void) enemyBossLeftScene {
  [self.delegate enemyBossRanOffMap];
}

- (void) moveToYacht {
  
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
  if ([ss.name isEqualToString:[NSString stringWithFormat:ASSET_TAG, self.clickableAssetId]]) {
    [ss removeArrowAnimated:YES];
    return ss;
  }
  return nil;
}

- (void) setSelected:(SelectableSprite *)selected {
  if ([self.selected.name isEqualToString:[NSString stringWithFormat:ASSET_TAG, self.clickableAssetId]]) {
    return;
  }
  [super setSelected:selected];
}

//- (void) drag:(UIGestureRecognizer *)recognizer {
//  // Do nothing
//}
//
//- (void) scale:(UIGestureRecognizer *)recognizer {
//  // Do nothing
//}

@end
