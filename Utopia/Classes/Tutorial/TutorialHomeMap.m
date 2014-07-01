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
#define PIER_JUMP_TALK_X_FROM_MID 0.75

@implementation TutorialHomeMap

- (id) initWithTutorialConstants:(StartupResponseProto_TutorialConstants *)constants {
  if ((self = [super init])) {
    self.constants = constants;
    
    self.scale = 1.2;
    
    // Move to bottom right
    CCSprite *s = [CCSprite node];
    s.position = [self convertTilePointToCCPoint:PIER_JUMP_LOCATION];
    [self moveToSprite:s animated:NO];
    
    self.myStructs = [NSMutableArray array];
    for (TutorialStructProto *str in self.constants.tutorialStructuresList) {
      UserStruct *us = [UserStruct userStructWithTutorialStructProto:str];
      if (us.staticStruct.structInfo.structType == StructureInfoProto_StructTypeMiniJob) {
        // Make the mini job center fixed
        us.structId = us.staticStructForNextLevel.structInfo.structId;
      }
      [self.myStructs addObject:us];
    }
    
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

#pragma mark - Tutorial sequence

- (void) landBoatOnShore {
  CGPoint midPos = BOAT_UNLOAD_POSITION;
  CGPoint ptOffset = POINT_OFFSET_PER_SCENE;
  CGPoint startPos = ccpAdd(midPos, ccpMult(ptOffset, 0.4f));
  CGPoint finalPos = ccpAdd(midPos, ccpMult(ptOffset, -0.5f));
  
  self.boatSprite = [CCSprite spriteWithImageNamed:@"marksboat.png"];
  [self addChild:self.boatSprite];
  self.boatSprite.position = startPos;
  
  [self.boatSprite runAction:
   [CCActionSequence actions:
    [CCActionMoveTo actionWithDuration:3.f position:midPos],
    [CCActionCallFunc actionWithTarget:self selector:@selector(jumpGuysOffBoat)],
    [CCActionMoveTo actionWithDuration:3.f position:finalPos],
    [CCActionCallFunc actionWithTarget:self.boatSprite selector:@selector(removeFromParent)],
    nil]];
}

- (void) jumpGuysOffBoat {
  [self jumpGuyOffBoat:self.markZSprite withDelay:0.1 endDist:-PIER_JUMP_TALK_X_FROM_MID selector:@selector(markReachedJumpTalkLocation)];
  [self jumpGuyOffBoat:self.friendSprite withDelay:0.4 endDist:PIER_JUMP_TALK_X_FROM_MID selector:@selector(friendReachedJumpTalkLocation)];
}

- (void) jumpGuyOffBoat:(AnimatedSprite *)as withDelay:(float)delay endDist:(float)endDist selector:(SEL)selector {
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
                               [NSValue valueWithCGPoint:ccp(jumpLoc.x+endDist, PIER_JUMP_TALK_Y)]];
       // Subtract delay so that zark runs in faster than friend
       [as walkToTileCoords:tileCoords completionTarget:self selector:selector speedMultiplier:1.5f-delay];
     }],
    nil]];
}

- (void) markReachedJumpTalkLocation {
  [self.markZSprite restoreStandingFrame:MapDirectionFarLeft];
}

- (void) friendReachedJumpTalkLocation {
  [self.friendSprite restoreStandingFrame:MapDirectionFarLeft];
  [self moveToSprite:self.markZSprite animated:YES];
  
  [self runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:0.2f],
    [CCActionCallBlock actionWithBlock:
     ^{
       [self.markZSprite restoreStandingFrame:MapDirectionFront];
       [self.delegate boatLanded];
     }], nil]];
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
  
//  if (botView == self.buildBotView) {
//    float angle = [Globals isLongiPhone] ? M_PI_2 : M_PI;
//    [Globals removeUIArrowFromViewRecursively:self.buildBotView];
//    [Globals createUIArrowForView:self.enterButton atAngle:angle];
//  } else if (botView == self.upgradeBotView) {
//    float angle = [Globals isLongiPhone] ? M_PI_2 : 0;
//    [Globals removeUIArrowFromViewRecursively:self.upgradeBotView];
//    [Globals createUIArrowForView:self.speedupButton atAngle:angle];
//  }
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

- (void) onEnter {
  [super onEnter];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
