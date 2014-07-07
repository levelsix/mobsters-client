//
//  TutorialHomeMap.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/5/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialHomeMap.h"
#import "Globals.h"
#import "GameState.h"

#define BOAT_UNLOAD_POSITION ccp(765, 80)

#define PIER_JUMP_LOCATION ccp(13.2, -1.5)
#define PIER_JUMP_TALK_Y 0.5
#define PIER_JUMP_TALK_X_FROM_MID 1.5
#define PIER_JUMP_TALK_Y_FROM_MID 2

#define INITIAL_GUIDE_LOCATION ccpAdd(PIER_JUMP_LOCATION, ccp(0, 6.5))
#define HIDE_GUIDE_LOCATION ccpAdd(INITIAL_GUIDE_LOCATION, ccp(4.5, 0))
#define FRIEND_ENTER_LOCATION ccpAdd(INITIAL_GUIDE_LOCATION, ccp(0, 3))
#define FRIEND_ENTER_END_LOCATION ccpAdd(INITIAL_GUIDE_LOCATION, ccp(0, 1))
#define FRIEND_BATTLE_RUN_LOCATION ccpAdd(INITIAL_GUIDE_LOCATION, ccp(0, -1))
#define POST_BATTLE_FRIENDS_X_FROM_MID 0.75

@implementation TutorialHomeMap

- (id) initWithTutorialConstants:(StartupResponseProto_TutorialConstants *)constants {
  if ((self = [super init])) {
    self.constants = constants;
    
    self.scale = 1.2;
    
    self.myStructs = [NSMutableArray array];
    for (TutorialStructProto *str in self.constants.tutorialStructuresList) {
      UserStruct *us = [UserStruct userStructWithTutorialStructProto:str];
      if (us.staticStruct.structInfo.structType == StructureInfoProto_StructTypeMiniJob) {
        // Make the mini job center fixed
        us.structId = us.staticStructForNextLevel.structInfo.structId;
      }
      [self.myStructs addObject:us];
    }
    
    self.boatSprite = [CCSprite spriteWithImageNamed:@"marksboat.png"];
    [self addChild:self.boatSprite z:2000];
    
    [self moveToCenterAnimated:NO];
    
    _mapMovementDivisor = 300.f;
    
    self.cityId = -1;
  }
  return self;
}

- (NSArray *) myStructsList {
  return self.myStructs;
}

- (HospitalBuilding *) hospital {
  for (CCNode *n in self.children) {
    if ([n isKindOfClass:[HospitalBuilding class]]) {
      return (HospitalBuilding *)n;
    }
  }
  return nil;
}

- (ResourceGeneratorBuilding *) oilDrill {
  for (CCNode *n in self.children) {
    if ([n isKindOfClass:[ResourceGeneratorBuilding class]]) {
      ResourceGeneratorBuilding *res = (ResourceGeneratorBuilding *)n;
      if (((ResourceGeneratorProto *)res.userStruct.staticStruct).resourceType == ResourceTypeOil) {
        return res;
      }
    }
  }
  return nil;
}

#pragma mark - Create animated sprites on the fly

- (AnimatedSprite *) createSpriteWithId:(int)monsterId {
  AnimatedSprite *as = [[AnimatedSprite alloc] initWithMonsterId:monsterId map:self];
  as.constrainedToBoundary = NO;
  [as stopWalking];
  [self addChild:as];
  return as;
}

- (AnimatedSprite *) friendSprite {
  if (!_friendSprite) {
    self.friendSprite = [self createSpriteWithId:self.constants.startingMonsterId];
  }
  return _friendSprite;
}

- (AnimatedSprite *) guideSprite {
  if (!_guideSprite) {
    self.guideSprite = [self createSpriteWithId:self.constants.guideMonsterId];
  }
  return _guideSprite;
}

- (AnimatedSprite *) markZSprite {
  if (!_markZSprite) {
    self.markZSprite = [self createSpriteWithId:self.constants.markZmonsterId];
  }
  return _markZSprite;
}

- (AnimatedSprite *) enemy1Sprite {
  if (!_enemy1Sprite) {
    self.enemy1Sprite = [self createSpriteWithId:self.constants.enemyMonsterId];
  }
  return _enemy1Sprite;
}

- (AnimatedSprite *) enemy2Sprite {
  if (!_enemy2Sprite) {
    self.enemy2Sprite = [self createSpriteWithId:self.constants.enemyMonsterIdTwo];
  }
  return _enemy2Sprite;
}

- (AnimatedSprite *) enemyBossSprite {
  if (!_enemyBossSprite) {
    self.enemyBossSprite = [self createSpriteWithId:self.constants.enemyBossMonsterId];
  }
  return _enemyBossSprite;
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

#pragma mark - Tutorial sequence

- (void) centerOnGuide {
  [self.guideSprite restoreStandingFrame:MapDirectionNearRight];
  self.guideSprite.location = CGRectMake(INITIAL_GUIDE_LOCATION.x, INITIAL_GUIDE_LOCATION.y, 1, 1);
  [self moveToSprite:self.guideSprite animated:NO];
}

- (void) landBoatOnShore {
  CGPoint midPos = BOAT_UNLOAD_POSITION;
  CGPoint ptOffset = POINT_OFFSET_PER_SCENE;
  CGPoint startPos = ccpAdd(midPos, ccpMult(ptOffset, 0.4f));
  
  self.boatSprite.position = startPos;
  
  [self.boatSprite runAction:
   [CCActionSequence actions:
    [CCActionMoveTo actionWithDuration:3.f position:midPos],
    [CCActionCallFunc actionWithTarget:self selector:@selector(jumpGuysOffBoat)],
    nil]];
  
  // Move to bottom right
  CCSprite *s = [CCSprite node];
  s.position = [self convertTilePointToCCPoint:PIER_JUMP_LOCATION];
  [self moveToSprite:s animated:YES];
}

- (void) jumpGuysOffBoat {
  [self jumpGuyOffBoat:self.enemy1Sprite withDelay:0.1 endDelta:ccp(-PIER_JUMP_TALK_X_FROM_MID, 0) selector:@selector(faceSpriteFarLeft:)];
  [self jumpGuyOffBoat:self.enemy2Sprite withDelay:0.4 endDelta:ccp(PIER_JUMP_TALK_X_FROM_MID, 0) selector:@selector(faceSpriteFarLeft:)];
  [self jumpGuyOffBoat:self.enemyBossSprite withDelay:0.7 endDelta:ccp(0, PIER_JUMP_TALK_Y_FROM_MID) selector:@selector(enemyBossReachedJumpTalkLocation)];
}

- (void) jumpGuyOffBoat:(AnimatedSprite *)as withDelay:(float)delay endDelta:(CGPoint)endDelta selector:(SEL)selector {
  [as restoreStandingFrame:MapDirectionFarRight];
  [as recursivelyApplyOpacity:0.f];
  [as runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:delay],
    [CCActionCallBlock actionWithBlock:
     ^{
       [as runAction:
        [CCActionSequence actions:
         [RecursiveFadeTo actionWithDuration:0.1f opacity:1.f], nil]];
       
       [as jumpNumTimes:1 timePerJump:0.4f completionTarget:nil selector:nil];
       
       CGPoint jumpLoc = PIER_JUMP_LOCATION;
       as.location = CGRectMake(jumpLoc.x, jumpLoc.y-4, 1, 1);
       NSArray *tileCoords = @[[NSValue valueWithCGPoint:jumpLoc], [NSValue valueWithCGPoint:ccp(jumpLoc.x, PIER_JUMP_TALK_Y)],
                               [NSValue valueWithCGPoint:ccp(jumpLoc.x+endDelta.x, PIER_JUMP_TALK_Y+endDelta.y)]];
       // Subtract delay so that zark runs in faster than friend
       [as walkToTileCoords:tileCoords completionTarget:self selector:selector speedMultiplier:1.5f];
     }],
    nil]];
}

- (void) faceSpriteFarLeft:(AnimatedSprite *)anim {
  [anim restoreStandingFrame:MapDirectionFarLeft];
}

- (void) enemyBossReachedJumpTalkLocation {
  [self faceSpriteFarLeft:self.enemyBossSprite];
  [self moveToSprite:self.enemyBossSprite animated:YES];
  [self.delegate boatLanded];
}

- (void) enemyTwoJump {
  [self.enemy2Sprite jumpNumTimes:2 completionTarget:self.delegate selector:@selector(enemyTwoJumped)];
}

- (void) guideHideBehindObstacle {
  [self.guideSprite jumpNumTimes:1 completionTarget:self selector:@selector(guideRunToObstacle)];
}

- (void) guideRunToObstacle {
  [self.guideSprite walkToTileCoord:HIDE_GUIDE_LOCATION completionTarget:self selector:@selector(guideReachedObstacle) speedMultiplier:1.5f];
}

- (void) guideReachedObstacle {
  [self.guideSprite restoreStandingFrame:MapDirectionNearRight];
  [self.delegate guideReachedHideLocation];
}

- (void) friendEnterScene {
  [self.friendSprite runAction:
   [CCActionSequence actions:
    [RecursiveFadeTo actionWithDuration:0.1f opacity:1.f], nil]];
  self.friendSprite.location = CGRectMake(FRIEND_ENTER_LOCATION.x, FRIEND_ENTER_LOCATION.y, 1, 1);
  [self.friendSprite walkToTileCoord:FRIEND_ENTER_END_LOCATION completionTarget:self selector:@selector(friendEntered) speedMultiplier:1.5f];
}

- (void) friendEntered {
  [self.friendSprite restoreStandingFrame:MapDirectionNearRight];
  [self.delegate friendEntered];
}

- (void) friendRunForBattleEnter {
  [self.friendSprite walkToTileCoord:FRIEND_BATTLE_RUN_LOCATION completionTarget:nil selector:nil speedMultiplier:1.5f];
}

- (void) beginPostBattleConfrontation {
  [self.enemy1Sprite recursivelyApplyOpacity:1.f];
  [self.enemy2Sprite recursivelyApplyOpacity:1.f];
  [self.enemyBossSprite recursivelyApplyOpacity:1.f];
  [self.friendSprite recursivelyApplyOpacity:1.f];
  [self.guideSprite recursivelyApplyOpacity:1.f];
  [self.markZSprite recursivelyApplyOpacity:1.f];
  
  [self.enemy1Sprite restoreStandingFrame:MapDirectionFarLeft];
  [self.enemy2Sprite restoreStandingFrame:MapDirectionFarLeft];
  [self.enemyBossSprite restoreStandingFrame:MapDirectionFarLeft];
  [self.friendSprite restoreStandingFrame:MapDirectionNearRight];
  [self.guideSprite restoreStandingFrame:MapDirectionNearRight];
  [self.markZSprite restoreStandingFrame:MapDirectionNearRight];
  
  CGPoint enemyBaseLoc = ccp(PIER_JUMP_LOCATION.x, PIER_JUMP_TALK_Y);
  self.enemy1Sprite.location = CGRectMake(enemyBaseLoc.x-PIER_JUMP_TALK_X_FROM_MID, enemyBaseLoc.y, 1, 1);
  self.enemy2Sprite.location = CGRectMake(enemyBaseLoc.x+PIER_JUMP_TALK_X_FROM_MID, enemyBaseLoc.y, 1, 1);
  self.enemyBossSprite.location = CGRectMake(enemyBaseLoc.x, enemyBaseLoc.y+PIER_JUMP_TALK_Y_FROM_MID, 1, 1);
  
  CGPoint friendBaseLoc = INITIAL_GUIDE_LOCATION;
  self.friendSprite.location = CGRectMake(friendBaseLoc.x+POST_BATTLE_FRIENDS_X_FROM_MID, friendBaseLoc.y, 1, 1);
  self.markZSprite.location = CGRectMake(friendBaseLoc.x-POST_BATTLE_FRIENDS_X_FROM_MID, friendBaseLoc.y, 1, 1);
  self.guideSprite.location = CGRectMake(HIDE_GUIDE_LOCATION.x, HIDE_GUIDE_LOCATION.y, 1, 1);
  
  self.boatSprite.position = BOAT_UNLOAD_POSITION;
  
  [self moveToSprite:self.enemyBossSprite animated:NO withOffset:ccp(20, -24)];
}

- (void) walkOutEnemyTeam {
  [self jumpGuyOnBoat:self.enemyBossSprite withDelay:0.1];
  [self jumpGuyOnBoat:self.enemy2Sprite withDelay:0.7];
  [self jumpGuyOnBoat:self.enemy1Sprite withDelay:1.2];
}

- (void) jumpGuyOnBoat:(AnimatedSprite *)as withDelay:(float)delay {
  [as runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:delay],
    [CCActionCallBlock actionWithBlock:
     ^{
       CGPoint jumpLoc = PIER_JUMP_LOCATION;
       jumpLoc.y -= 2;
       NSArray *tileCoords = @[[NSValue valueWithCGPoint:ccp(jumpLoc.x, PIER_JUMP_TALK_Y)],
                               [NSValue valueWithCGPoint:jumpLoc]];
       // Subtract delay so that zark runs in faster than friend
       [as walkToTileCoords:tileCoords completionTarget:self selector:@selector(jumpAnimatedSpriteOntoBoat:) speedMultiplier:1.5f];
     }],
    nil]];
}

- (void) jumpAnimatedSpriteOntoBoat:(AnimatedSprite *)as {
  [as jumpNumTimes:1 timePerJump:0.4f completionTarget:nil selector:nil];
  
  CGPoint jumpLoc = PIER_JUMP_LOCATION;
  jumpLoc.y -= 4;
  [as walkToTileCoord:jumpLoc completionTarget:self selector:@selector(animatedSpriteReachedBoat:) speedMultiplier:1.5f];
  [as runAction:
   [CCActionSequence actions:
    [RecursiveFadeTo actionWithDuration:0.4f opacity:0.f], nil]];
}

- (void) animatedSpriteReachedBoat:(AnimatedSprite *)as {
  [as removeFromParent];
  
  if (as == self.enemy1Sprite) {
    CGPoint ptOffset = POINT_OFFSET_PER_SCENE;
    CGPoint midPos = BOAT_UNLOAD_POSITION;
    CGPoint finalPos = ccpAdd(midPos, ccpMult(ptOffset, -0.5f));
    
    [self.boatSprite runAction:
     [CCActionSequence actions:
      [CCActionMoveTo actionWithDuration:3.f position:finalPos],
      [CCActionRemove action], nil]];
      
    [self.delegate enemyTeamWalkedOut];
  }
}

- (void) moveFriendsOffBuildableMap {
  CGPoint baseLoc = ccp(PIER_JUMP_LOCATION.x, PIER_JUMP_TALK_Y);
  self.markZSprite.location = CGRectMake(baseLoc.x-PIER_JUMP_TALK_X_FROM_MID, baseLoc.y, 1, 1);
  self.friendSprite.location = CGRectMake(baseLoc.x, baseLoc.y, 1, 1);
  self.guideSprite.location = CGRectMake(baseLoc.x+PIER_JUMP_TALK_X_FROM_MID, baseLoc.y, 1, 1);
  
  [self.markZSprite restoreStandingFrame:MapDirectionFarLeft];
  [self.friendSprite restoreStandingFrame:MapDirectionFarLeft];
  [self.guideSprite restoreStandingFrame:MapDirectionFarLeft];
}



- (void) friendFaceMark {
  [self.friendSprite restoreStandingFrame:MapDirectionNearLeft];
  [self.markZSprite restoreStandingFrame:MapDirectionFarRight];
}

- (void) markFaceFriendAndBack {
  [self.markZSprite restoreStandingFrame:MapDirectionFront];
  [self.delegate markFacedFriendAndBack];
}

- (void) walkToHospitalAndEnter {
  [self markReachedHospitalLocation];
  [self friendReachedHospitalLocation];
  [self allowHospitalClick];
}

- (void) walkToHospital {
  HospitalBuilding *hosp = [self hospital];
  
  [self.markZSprite walkToTileCoord:ccp(self.markZSprite.location.origin.x, hosp.location.origin.y-1) completionTarget:self selector:@selector(markReachedHospitalLocation) speedMultiplier:2.f];
  
  [self runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:0.5f],
    [CCActionCallBlock actionWithBlock:
     ^{
       [self.friendSprite walkToTileCoord:ccp(self.friendSprite.location.origin.x, hosp.location.origin.y-1) completionTarget:self selector:@selector(friendReachedHospitalLocation) speedMultiplier:2.f];
     }], nil]];
  [self followSprite:self.markZSprite];
}

- (void) markReachedHospitalLocation {
  [self.markZSprite restoreStandingFrame:MapDirectionFarLeft];
}

- (void) friendReachedHospitalLocation {
  [self.friendSprite restoreStandingFrame:MapDirectionFarLeft];
}

- (void) allowHospitalClick {
  [self stopAllActions];
  HospitalBuilding *hospital = [self hospital];
  [self moveToSprite:hospital animated:YES withOffset:ccp(0, -50)];
  [hospital displayArrow];
  
  self.clickableUserStructId = hospital.userStruct.userStructId;
}

- (void) enterClicked:(id)sender {
  self.clickableUserStructId = 0;
  self.selected = nil;
  [self.delegate enterHospitalClicked];
}

- (void) zoomOutMap {
  HospitalBuilding *hospital = [self hospital];
  [self moveToSprite:hospital animated:YES withOffset:ccp(0, -50) scale:1.f];
}

- (void) speedupPurchasedBuilding {
  self.clickableUserStructId = ((HomeBuilding *)_constrBuilding).userStruct.userStructId;
}

- (void) moveToOilDrill {
  [self moveToSprite:[self oilDrill] animated:YES];
}

- (void) panToMark {
  [self moveToSprite:self.markZSprite animated:YES withOffset:ccp(0,0) scale:1.6f];
  [self.markZSprite restoreStandingFrame:MapDirectionFront];
}

- (void) friendFaceForward {
  [self.friendSprite restoreStandingFrame:MapDirectionFront];
}

#pragma mark - Overwritten methods

- (void) createBoat {
  // Do nothing
}

- (void) littleUpgradeClicked:(id)sender {
  // Do nothing
}

- (void) cancelMoveClicked:(id)sender {
  // Do nothing
}

- (NSArray *) reloadObstacles {
  NSArray *obstacles = self.constants.tutorialObstaclesList;
  NSMutableArray *sprites = [NSMutableArray array];
  
  for (MinimumObstacleProto *ob in obstacles) {
    UserObstacle *uo = [[UserObstacle alloc] init];
    uo.obstacleId = ob.obstacleId;
    uo.orientation = ob.orientation;
    uo.coordinates = ccp(ob.coordinate.x, ob.coordinate.y);
    
    ObstacleSprite *os = [[ObstacleSprite alloc] initWithObstacle:uo map:self];
    [self addChild:os];
    
    [sprites addObject:os];
  }
  return sprites;
}

- (SelectableSprite *) selectableForPt:(CGPoint)pt {
  SelectableSprite *ss = [super selectableForPt:pt];
  if ([ss.name isEqualToString:STRUCT_TAG(self.clickableUserStructId)]) {
    [ss removeArrowAnimated:YES];
    return ss;
  }
  return nil;
}

- (void) setSelected:(SelectableSprite *)selected {
  if (self.selected != selected && [self.selected.name isEqualToString:STRUCT_TAG(self.clickableUserStructId)]) {
    return;
  }
  [super setSelected:selected];
  
  if (selected != _purchBuilding) {
    _canMove = NO;
  }
}

- (void) updateMapBotView:(MapBotView *)botView {
  [super updateMapBotView:botView];
  
  [Globals removeUIArrowFromViewRecursively:botView];
  [Globals createUIArrowForView:botView.animateViews.lastObject atAngle:0];
}

- (UserStruct *) sendPurchaseStruct:(BOOL)allowGems {
  HomeBuilding *homeBuilding = (HomeBuilding *)self.selected;
  
  UserStruct *us = [[UserStruct alloc] init];
  us.userStructId = _purchStructId;
  us.structId = _purchStructId;
  us.purchaseTime = [MSDate date];
  us.orientation = StructOrientationPosition1;
  us.coordinates = homeBuilding.location.origin;
  us.lastRetrieved = [MSDate date];
  [self.myStructs addObject:us];
  
  self.clickableUserStructId = _purchStructId;
  
  return us;
}

- (void) purchaseBuildingAllowGems:(BOOL)allowGems {
  [super purchaseBuildingAllowGems:allowGems];
  [self moveToSprite:_constrBuilding animated:YES];
  
  HomeBuilding *hb = (HomeBuilding *)_constrBuilding;
  int cashCost = 0, oilCost = 0;
  StructureInfoProto *fsp = hb.userStruct.staticStruct.structInfo;
  if (fsp.buildResourceType == ResourceTypeCash) {
    cashCost = fsp.buildCost;
  } else if (fsp.buildResourceType == ResourceTypeOil) {
    oilCost = fsp.buildCost;
  }
  [self.delegate purchasedBuildingWasSetDown:hb.userStruct.structId coordinate:hb.location.origin cashCost:cashCost oilCost:oilCost];
}

- (IBAction)finishNowClicked:(id)sender {
  [self speedUpBuilding];
}

- (void) sendNormStructComplete:(UserStruct *)us {
  us.isComplete = YES;
  [self.delegate buildingWasSpedUp:0];
  self.clickableUserStructId = 0;
}

- (void) sendSpeedupBuilding:(UserStruct *)us {
  Globals *gl = [Globals sharedGlobals];
  int timeLeft = us.timeLeftForBuildComplete;
  int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
  us.isComplete = YES;
  [self.delegate buildingWasSpedUp:gemCost];
  self.clickableUserStructId = 0;
  self.bottomOptionView = nil;
}

- (void) reselectCurrentSelection {
  if ([self.selected.name isEqualToString:STRUCT_TAG(self.clickableUserStructId)]) {
    [super reselectCurrentSelection];
  } else {
    self.selected = nil;
    [self.delegate buildingWasCompleted];
  }
}

- (void) drag:(UIGestureRecognizer *)recognizer {
  if (_canMove) {
    [super drag:recognizer];
  }
}

- (void) tap:(UIGestureRecognizer *)recognizer {
  if (self.clickableUserStructId) {
    [super tap:recognizer];
  }
}

- (void) scale:(UIGestureRecognizer *)recognizer {
  // Do nothing
}

- (void) setupTeamSprites {
  // Do nothing
}

- (void) reloadBubblesOnMiscBuildings {
  // Do nothing
}

- (void) onEnter {
  [super onEnter];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
