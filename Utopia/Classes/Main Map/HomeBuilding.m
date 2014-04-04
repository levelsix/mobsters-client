//
//  HomeBuilding.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/22/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "HomeBuilding.h"
#import "HomeMap.h"
#import "CCAnimation+SpriteLoading.h"
#import "GameState.h"
#import "Globals.h"
#import "CCSoundAnimation.h"
#import "SoundEngine.h"

@implementation HomeBuilding

- (id) initWithFile:(NSString *)file location:(CGRect)loc map:(HomeMap *)map {
  if ((self = [super initWithFile:file location:loc map:map])) {
    _homeMap = map;
    
    NSString *fileName = [NSString stringWithFormat:@"%dx%ddark.png", (int)loc.size.width, (int)loc.size.height];
    CCSprite *shadow = [CCSprite spriteWithImageNamed:fileName];
    [self addChild:shadow z:-1 name:SHADOW_TAG];
    shadow.anchorPoint = ccp(0.5, 0);
    
    fileName = [NSString stringWithFormat:@"%dx%dshadow.png", (int)loc.size.width, (int)loc.size.height];
    CCSprite *dark = [CCSprite spriteWithImageNamed:fileName];
    [shadow addChild:dark z:1];
    dark.position = ccp(shadow.contentSize.width/3, shadow.contentSize.height/2);
  }
  return self;
}

+ (id) buildingWithUserStruct:(UserStruct *)us map:(HomeMap *)map {
  StructureInfoProto_StructType type = us.staticStruct.structInfo.structType;
  Class buildingClass;
  switch (type) {
    case StructureInfoProto_StructTypeResourceGenerator:
      buildingClass = [ResourceGeneratorBuilding class];
      break;
      
    case StructureInfoProto_StructTypeHospital:
      buildingClass = [HospitalBuilding class];
      break;
      
    case StructureInfoProto_StructTypeResidence:
      buildingClass = [ResidenceBuilding class];
      break;
      
    case StructureInfoProto_StructTypeResourceStorage:
      buildingClass = [ResourceStorageBuilding class];
      break;
      
    case StructureInfoProto_StructTypeTownHall:
      buildingClass = [TownHallBuilding class];
      break;
      
    case StructureInfoProto_StructTypeLab:
      buildingClass = [LabBuilding class];
      break;
      
    case StructureInfoProto_StructTypeEvo:
      buildingClass = [EvoBuilding class];
      break;
      
    default:
      break;
  }
  
  return [[buildingClass alloc] initWithUserStruct:us map:map];
}

- (id) initWithUserStruct:(UserStruct *)userStruct map:(HomeMap *)map {
  StructureInfoProto *fsp = userStruct.staticStruct.structInfo;
  NSString *file = fsp.imgName;
  CGRect loc = CGRectMake(userStruct.coordinates.x, userStruct.coordinates.y, fsp.width, fsp.height);
  if ((self = [self initWithFile:file location:loc map:map])) {
    self.userStruct = userStruct;
    self.orientation = self.userStruct.orientation;
    
    [self adjustBuildingSprite];
  }
  return self;
}

- (void) adjustBuildingSprite {
  StructureInfoProto *fsp = self.userStruct.staticStruct.structInfo;
  self.verticalOffset = fsp.imgVerticalPixelOffset;
  [super adjustBuildingSprite];
}

- (BOOL) select {
  BOOL ret = [super select];
  _startMoveCoordinate = _location.origin;
  _startOrientation = self.orientation;
  [self displayMoveArrows];
  return ret;
}

- (void) unselect {
  [super unselect];
  if (!_isSetDown && !_isPurchasing) {
    [self cancelMove];
  }
  [self removeMoveArrows];
}

- (void) setIsConstructing:(BOOL)isConstructing {
  if (_isConstructing != isConstructing) {
    _isConstructing = isConstructing;
    if (isConstructing) {
      NSString *poles = self.location.size.width == 3 ? @"3x3poles.png" : @"4x4poles.png";
      CCSprite *sprite = [CCSprite spriteWithImageNamed:poles];
      sprite.anchorPoint = ccp(0.5, 0);
      sprite.position = ccp(self.contentSize.width/2, 1);
      [self addChild:sprite z:1 name:CONSTRUCTION_TAG];
    } else {
      // This means we just finished constructing, so reload the building sprite
      StructureInfoProto *fsp = self.userStruct.staticStruct.structInfo;
      [self setupBuildingSprite:fsp.imgName];
      
      [self removeChildByName:CONSTRUCTION_TAG cleanup:YES];
    }
  }
}

- (void) cancelMove {
  [self clearMeta];
  [self liftBlock];
  self.orientation = _startOrientation;
  CGRect x = self.location;
  x.origin = _startMoveCoordinate;
  self.location = x;
  [self placeBlock:YES];
}

- (void) updateMeta {
  CCTiledMapLayer *meta = [_homeMap layerNamed:@"MetaLayer"];
  int red = _homeMap.redGid;
  int green = _homeMap.greenGid;
  for (int i = 0; i < self.location.size.width; i++) {
    for (int j = 0; j < self.location.size.height; j++) {
      // Transform to the map's coordinates
      CGPoint tileCoord = ccp(_homeMap.mapSize.height-1-(self.location.origin.y+j), _homeMap.mapSize.width-1-(self.location.origin.x+i));
      int tileGid = [meta tileGIDAt:tileCoord];
      if ([[[_homeMap.buildableData objectAtIndex:i+self.location.origin.x] objectAtIndex:j+self.location.origin.y] boolValue]) {
        if (tileGid != red) {
          [meta setTileGID:green at:tileCoord];
        }
      } else {
        if (tileGid != green) {
          [meta setTileGID:red at:tileCoord];
        }
      }
    }
  }
}

- (void) clearMeta {
  CCTiledMapLayer *meta = [_homeMap layerNamed:@"MetaLayer"];
  for (int i = 0; i < self.location.size.width; i++) {
    for (int j = 0; j < self.location.size.height; j++) {
      CGPoint tileCoord = ccp(_homeMap.mapSize.height-1-(self.location.origin.y+j),_homeMap.mapSize.width-1-(self.location.origin.x+i));
      if (tileCoord.x < meta.layerSize.width && tileCoord.x >= 0 &&
          tileCoord.y < meta.layerSize.height && tileCoord.y >= 0) {
        [meta removeTileAt:tileCoord];
      }
    }
  }
}

- (void) placeBlock:(BOOL)shouldPlaySound {
  if (_isSetDown) {
    return;
  }
  
  CCSprite *sprite = self.buildingSprite;
  
  if ([_homeMap isBlockBuildable:self.location]) {
    [self clearMeta];
    sprite.opacity = 1.f;
    [_homeMap changeTiles:self.location toBuildable:NO];
    _isSetDown = YES;
    _startMoveCoordinate = _location.origin;
    _startOrientation = self.orientation;
    
    if (shouldPlaySound) {
      [SoundEngine structDropped];
    }
  } else {
    sprite.opacity = 0.6f;
    
    if (shouldPlaySound) {
      [SoundEngine structCantPlace];
    }
  }
}

- (void) liftBlock {
  CCSprite *sprite = self.buildingSprite;
  
  if (self.isSetDown) {
    sprite.opacity = 0.6f;
    [_homeMap changeTiles:self.location toBuildable:YES];
  }
  self.isSetDown = NO;
}

- (void) locationAfterTouch: (CGPoint) touchLocation {
  // Subtract the touch location from the start location to find the distance moved
  CGPoint vector = ccpSub(touchLocation, _startTouchLocation);
  CGSize ts = _homeMap.tileSizeInPoints;
  if (abs(vector.x)+abs(2*vector.y) >= ts.width) {
    float angle = CC_RADIANS_TO_DEGREES(ccpToAngle(ccpSub(touchLocation, _startTouchLocation)));
    
    CGRect loc = self.location;
    CGRect oldLoc = self.location;
    // Adjust the location in the map to the correct angle
    if (angle >= 165 || angle <= -165) {
      loc.origin.x -= 1;
      loc.origin.y += 1;
    } else if (angle >= 120) {
      loc.origin.y += 1;
    } else if (angle >= 60) {
      loc.origin.x += 1;
      loc.origin.y += 1;
    } else if (angle >= 15) {
      loc.origin.x += 1;
    } else if (angle >= -15) {
      loc.origin.x += 1;
      loc.origin.y -= 1;
    } else if (angle >= -60) {
      loc.origin.y -= 1;
    } else if (angle >= -120) {
      loc.origin.y -= 1;
      loc.origin.x -= 1;
    } else if (angle >= -165) {
      loc.origin.x -= 1;
    }
    self.location = loc;
    int diffX = self.location.origin.x - oldLoc.origin.x;
    int diffY = self.location.origin.y - oldLoc.origin.y;
    _startTouchLocation.x += ts.width * (diffX-diffY)/2,
    _startTouchLocation.y += ts.height * (diffX+diffY)/2;
  }
}

#define ARROW_LAYER_TAG @"Arrow"
#define ARROW_FADE_DURATION 0.2f

- (void) displayMoveArrows {
  CCNode *o = [self getChildByName:ARROW_LAYER_TAG recursively:NO];
  if (o) {
    // This means it was reclicked
    [o stopAllActions];
    [o recursivelyApplyOpacity:1.f];
    return;
  }
  
  CCSprite *node = [CCSprite node];
  
  CCSprite *nr = [CCSprite spriteWithImageNamed:@"arrowdown.png"];
  CCSprite *nl = [CCSprite spriteWithImageNamed:@"arrowdown.png"];
  CCSprite *fr = [CCSprite spriteWithImageNamed:@"arrowup.png"];
  CCSprite *fl = [CCSprite spriteWithImageNamed:@"arrowup.png"];
  nr.flipX = YES;
  fr.flipX = YES;
  
  // Set anchor points so adjusting to tiles will be easy
  nr.anchorPoint = ccp(0,1);
  nl.anchorPoint = ccp(1,1);
  fr.anchorPoint = ccp(0,0);
  fl.anchorPoint = ccp(1,0);
  
  CGRect r = self.location;
  CGPoint relativeTo = [_map convertTilePointToCCPoint:r.origin];
  nr.position = ccpSub([_map convertTilePointToCCPoint:ccp(CGRectGetMidX(r), CGRectGetMinY(r))], relativeTo);
  nl.position = ccpSub([_map convertTilePointToCCPoint:ccp(CGRectGetMinX(r), CGRectGetMidY(r))], relativeTo);
  fr.position = ccpSub([_map convertTilePointToCCPoint:ccp(CGRectGetMaxX(r), CGRectGetMidY(r))], relativeTo);
  fl.position = ccpSub([_map convertTilePointToCCPoint:ccp(CGRectGetMidX(r), CGRectGetMaxY(r))], relativeTo);
  
  [node addChild:nr];
  [node addChild:nl];
  [node addChild:fr];
  [node addChild:fl];
  node.position = ccp(self.contentSize.width/2, 0);
  
  [node recursivelyApplyOpacity:0];
  [node runAction:[RecursiveFadeTo actionWithDuration:ARROW_FADE_DURATION opacity:1.f]];
  
  [self addChild:node z:-1 name:ARROW_LAYER_TAG];
}

- (void) removeMoveArrows {
  CCNode *node = [self getChildByName:ARROW_LAYER_TAG recursively:NO];
  [node stopAllActions];
  [node runAction:[CCActionSequence actions:[RecursiveFadeTo actionWithDuration:ARROW_FADE_DURATION opacity:0],
                   [CCActionCallBlock actionWithBlock:^{[node removeFromParentAndCleanup:YES];}], nil]];
}

- (void) updateProgressBar {
  CCNode *n = [self getChildByName:UPGRADING_TAG recursively:NO];
  if (n && [n isKindOfClass:[UpgradeProgressBar class]]) {
    UpgradeProgressBar *bar = (UpgradeProgressBar *)n;
    
    NSTimeInterval time = self.userStruct.timeLeftForBuildComplete;
    int totalTime = self.userStruct.staticStruct.structInfo.minutesToBuild*60;
    
    if (_percentage) {
      time = totalTime*(1.f-_percentage);
    }
    
    [bar updateForSecsLeft:time totalSecs:totalTime];
  }
}

- (void) displayUpgradeComplete {
  CCSprite *spinner = [CCSprite spriteWithImageNamed:@"spinnertest.png"];
  spinner.blendFunc = (ccBlendFunc){GL_SRC_ALPHA, GL_ONE};
  
  NSString *str = self.userStruct.staticStruct.structInfo.level == 1 ? @"buildingcomplete.png" : @"buildingupgraded.png";
  CCSprite *label = [CCSprite spriteWithImageNamed:str];
  
  [self addChild:spinner z:-1];
  [self addChild:label];
  
  spinner.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
  label.position = ccp(self.contentSize.width/2, self.contentSize.height-3);
  
  spinner.opacity = 0.f;
  [spinner runAction:
   [CCActionSpawn actions:
    [CCActionFadeTo actionWithDuration:0.3f opacity:0.75f],
    [CCActionRotateBy actionWithDuration:5.f angle:360.f],
    [CCActionSequence actions:
     [CCActionDelay actionWithDuration:3.7f],
     [CCActionFadeOut actionWithDuration:1.3f],
     [CCActionCallBlock actionWithBlock:^{[spinner removeFromParentAndCleanup:YES];}],
     nil],
    nil]];
  
  label.scale = 0.3f;
  [label runAction:[CCActionSequence actions:
                    [CCActionSpawn actions:
                     [CCActionEaseElasticOut actionWithAction:[CCActionScaleTo actionWithDuration:1.2f scale:1]],
                     [CCActionSequence actions:
                      [CCActionDelay actionWithDuration:3.7f],
                      [CCActionFadeOut actionWithDuration:1.3f],
                      nil],
                     [CCActionMoveBy actionWithDuration:5.f position:ccp(0,35)],nil],
                    [CCActionCallBlock actionWithBlock:^{[label removeFromParentAndCleanup:YES];}], nil]];
}

@end

@implementation ResourceGeneratorBuilding

- (void) setupBuildingSprite:(NSString *)fileName {
  [self.buildingSprite removeFromParent];
  
  fileName = fileName.stringByDeletingPathExtension;
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@.plist", fileName]];
  CCAnimation *anim = [CCAnimation animationWithSpritePrefix:fileName delay:0.2];
  
  ResourceGeneratorProto *res = (ResourceGeneratorProto *)self.userStruct.staticStruct;
  if (res.resourceType == ResourceTypeOil) {
    //    [anim repeatFrames:NSMakeRange(3,2) numTimes:5];
    anim.delayPerUnit = 0.1;
  }
  
  CCSprite *spr = [CCSprite spriteWithSpriteFrame:[anim.frames[0] spriteFrame]];
  [spr runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:anim]]];
  [self addChild:spr];
  self.buildingSprite = spr;
  
  self.baseScale = 0.75;
  
  [self adjustBuildingSprite];
}

- (void) initializeRetrieveBubble {
  if (_retrieveBubble) {
    // Make sure to cleanup just in case
    [_retrieveBubble removeFromParent];
  }
  GameState *gs = [GameState sharedGameState];
  ResourceType type = ((ResourceGeneratorProto *)self.userStruct.staticStruct).resourceType;
  NSString *res = type == ResourceTypeCash ? @"cash" : @"oil";
  int amount = type == ResourceTypeCash ? gs.silver : gs.oil;
  int max = type == ResourceTypeCash ? gs.maxCash : gs.maxOil;
  NSString *end = amount >= max ? @"overflow" : @"ready";
  
  _retrieveBubble = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"%@%@.png", res, end]];
  [self addChild:_retrieveBubble];
  _retrieveBubble.anchorPoint = ccp(0.5, 0);
  _retrieveBubble.position = ccp(self.contentSize.width/2,self.contentSize.height-OVER_HOME_BUILDING_MENU_OFFSET);
}

- (BOOL) select {
  if (self.retrievable) {
    [_homeMap retrieveFromBuilding:self];
    
    ResourceGeneratorProto *res = (ResourceGeneratorProto *)self.userStruct.staticStruct;
    if (res.resourceType == ResourceTypeCash) {
      [SoundEngine structCollectCash];
    } else if (res.resourceType == ResourceTypeOil) {
      [SoundEngine structCollectOil];
    }
    
    return NO;
  } else {
    return [super select];
  }
}

- (void) unselect {
  [super unselect];
  if (self.userStruct.isComplete && _percentage == 0) {
    [self removeProgressBar];
  }
}

- (void) setRetrievable:(BOOL)retrievable {
  _retrievable = retrievable;
  
  if (retrievable) {
    BOOL shouldFade = _retrieveBubble == nil;
    [self initializeRetrieveBubble];
    if (shouldFade) {
      _retrieveBubble.opacity = 0.f;
      [_retrieveBubble runAction:[CCActionFadeTo actionWithDuration:0.3f opacity:1.f]];
    }
  } else {
    [_retrieveBubble runAction:
     [CCActionSequence actions:
      [CCActionFadeTo actionWithDuration:0.3f opacity:0.f],
      [CCActionRemove action], nil]];
    _retrieveBubble = nil;
  }
}

- (void) setIsConstructing:(BOOL)isConstructing {
  [super setIsConstructing:isConstructing];
  self.retrievable = NO;
}

@end

@implementation ResourceStorageBuilding

- (void) setupBuildingSprite:(NSString *)fileName {
  [self.buildingSprite removeFromParent];
  
  fileName = fileName.stringByDeletingPathExtension;
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@.plist", fileName]];
  self.anim = [CCAnimation animationWithSpritePrefix:fileName delay:2.];
  
  self.buildingSprite = [CCSprite spriteWithSpriteFrame:[self.anim.frames[0] spriteFrame]];
  [self addChild:self.buildingSprite];
  
  [self adjustBuildingSprite];
}

- (void) setPercentage:(float)percentage {
  NSInteger mult = self.anim.frames.count-1;
  int imgNum = roundf(percentage*mult);
  CCSpriteFrame *frame = [self.anim.frames[imgNum] spriteFrame];
  [self.buildingSprite setSpriteFrame:frame];
}


@end

@implementation HospitalBuilding

- (void) setupBuildingSprite:(NSString *)fileName {
  fileName = fileName.stringByDeletingPathExtension;
  
  [self.buildingSprite removeFromParent];
  
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@.plist", fileName]];
  CCAnimation *anim = [CCAnimation animationWithSpritePrefix:[NSString stringWithFormat:@"%@Base", fileName] delay:0.1];
  [anim repeatFrames:NSMakeRange(0,1) numTimes:5];
  self.baseAnimation = anim;
  
  self.buildingSprite = [CCSprite spriteWithSpriteFrame:[anim.frames[0] spriteFrame]];
  [self addChild:self.buildingSprite];
  
  anim = [CCAnimation animationWithSpritePrefix:[NSString stringWithFormat:@"%@Tube", fileName] delay:0.1];
  [anim repeatFrames:NSMakeRange(0,1) numTimes:5];
  self.tubeAnimation = anim;
  
  self.tubeSprite = [CCSprite spriteWithSpriteFrame:[anim.frames[0] spriteFrame]];
  self.tubeSprite.position = ccp(self.buildingSprite.contentSize.width/2, self.buildingSprite.contentSize.height/2);
  [self.buildingSprite addChild:self.tubeSprite z:2];
  
  self.baseScale = 0.85;
  [self adjustBuildingSprite];
  
  if (_healingItem) {
    [self beginAnimatingWithHealingItem:_healingItem];
  }
}

- (void) beginAnimatingWithHealingItem:(UserMonsterHealingItem *)hi {
  [self stopAnimating];
  [self.monsterSprite removeFromParent];
  
  [self.buildingSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:self.baseAnimation]]];
  [self.tubeSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:self.tubeAnimation]]];
  
  if (hi) {
    GameState *gs = [GameState sharedGameState];
    UserMonster *um = [gs myMonsterWithUserMonsterId:hi.userMonsterId];
    MonsterProto *mp = [gs monsterWithId:um.monsterId];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@AttackNF.plist", mp.imagePrefix]];
    NSString *file = [NSString stringWithFormat:@"%@AttackN00.png", mp.imagePrefix];
    if ([[CCSpriteFrameCache sharedSpriteFrameCache] containsFrame:file]) {
      self.monsterSprite = [CCSprite spriteWithImageNamed:file];
      self.monsterSprite.anchorPoint = ccp(0.5, 0);
      self.monsterSprite.scale = 0.8;
      self.monsterSprite.position = ccpAdd(ccp(self.buildingSprite.contentSize.width/2, 1), ccp(0, mp.verticalPixelOffset));
      self.monsterSprite.flipX = YES;
      [self.buildingSprite addChild:self.monsterSprite z:1];
    }
    
    [self displayProgressBar];
  }
  
  _healingItem = hi;
}

- (void) stopAnimating {
  [self.monsterSprite removeFromParent];
  
  [self.buildingSprite stopAllActions];
  [self.tubeSprite stopAllActions];
  
  [self.buildingSprite setSpriteFrame:[self.baseAnimation.frames[0] spriteFrame]];
  [self.tubeSprite setSpriteFrame:[self.tubeAnimation.frames[0] spriteFrame]];
  
  if (!self.isConstructing) {
    [self removeProgressBar];
  }
  _healingItem = nil;
}

- (NSString *) progressBarPrefix {
  if (self.isConstructing) {
    return [super progressBarPrefix];
  } else {
    return @"healing";
  }
}

- (void) displayProgressBar {
  [self removeProgressBar];
  [super displayProgressBar];
}

- (void) updateProgressBar {
  if (self.isConstructing) {
    [super updateProgressBar];
  } else {
    CCNode *n = [self getChildByName:UPGRADING_TAG recursively:NO];
    if (n && [n isKindOfClass:[UpgradeProgressBar class]]) {
      UpgradeProgressBar *bar = (UpgradeProgressBar *)n;
      
      NSTimeInterval time = _healingItem.endTime.timeIntervalSinceNow;
      [bar updateTimeLabel:time];
      [bar updateForPercentage:_healingItem.currentPercentage];
    }
  }
}

@end

@implementation TownHallBuilding

@end

@implementation ResidenceBuilding

@end

@implementation LabBuilding

- (id) initWithUserStruct:(UserStruct *)userStruct map:(HomeMap *)map {
  if ((self = [super initWithUserStruct:userStruct map:map])) {
    [self beginAnimating];
  }
  return self;
}

- (void) setupBuildingSprite:(NSString *)fileName {
  [self.buildingSprite removeFromParent];
  
  fileName = fileName.stringByDeletingPathExtension;
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@.plist", fileName]];
  self.anim = [CCAnimation animationWithSpritePrefix:fileName delay:0.1];
  
  self.buildingSprite = [CCSprite spriteWithSpriteFrame:[self.anim.frames[0] spriteFrame]];
  [self addChild:self.buildingSprite];
  
  [self adjustBuildingSprite];
}

- (void) beginAnimating {
  [self stopAnimating];
  [self.buildingSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:self.anim]]];
}

- (void) stopAnimating {
  [self.buildingSprite stopAllActions];
  [self.buildingSprite setSpriteFrame:[self.anim.frames[0] spriteFrame]];
}

@end

@implementation EvoBuilding

@end

@implementation ExpansionBoard

- (id) initWithExpansionBlock:(CGPoint)block location:(CGRect)location map:(GameMap *)map isExpanding:(BOOL)isExpanding {
  int blockSum = abs(block.x)+abs(block.y);
  NSString *file = [NSString stringWithFormat:@"sale%d.png", (blockSum%3)+1];
  if ((self = [super initWithFile:file location:location map:map])) {
    self.expandSpot = block;
    
    [self removeChildByName:SHADOW_TAG cleanup:YES];
  }
  return self;
}

- (BOOL) hitTestWithWorldPos:(CGPoint)pt {
  pt = [_map convertToNodeSpace:pt];
  
  CGPoint tilePt = [_map convertCCPointToTilePoint:pt];
  return CGRectContainsPoint(self.location, tilePt);
}

- (void) beginExpanding {
  [self displayProgressBar];
  CCNode *n = [self getChildByName:UPGRADING_TAG recursively:NO];
  n.position = ccpAdd(ccp(self.contentSize.width/2, self.contentSize.height/2), ccp(0, 5));
}

- (void) updateProgressBar {
  CCNode *n = [self getChildByName:UPGRADING_TAG recursively:NO];
  if (n && [n isKindOfClass:[UpgradeProgressBar class]]) {
    UpgradeProgressBar *bar = (UpgradeProgressBar *)n;
    Globals *gl = [Globals sharedGlobals];
    GameState *gs = [GameState sharedGameState];
    UserExpansion *ue = [gs getExpansionForX:self.expandSpot.x y:self.expandSpot.y];
    
    int totalTime = [gl calculateNumMinutesForNewExpansion]*60;
    NSTimeInterval time = [[MSDate dateWithTimeInterval:totalTime sinceDate:ue.lastExpandTime] timeIntervalSinceNow];
    
    if (_percentage) {
      time = totalTime*(1.f-_percentage);
    }
    
    [bar updateForSecsLeft:time totalSecs:totalTime];
  }
}

@end