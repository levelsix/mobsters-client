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

@implementation HomeBuilding

- (id) initWithFile:(NSString *)file location:(CGRect)loc map:(HomeMap *)map {
  if ((self = [super initWithFile:file location:loc map:map])) {
    _homeMap = map;
    [self placeBlock];
    
    self.baseScale = 1.f;
    
    NSString *fileName = [NSString stringWithFormat:@"%dx%ddark.png", (int)loc.size.width, (int)loc.size.height];
    CCSprite *shadow = [CCSprite spriteWithImageNamed:fileName];
    [self addChild:shadow z:-1 name:SHADOW_TAG];
    shadow.anchorPoint = ccp(0.5, 0);
    // Reassign the content size
    self.contentSize = self.contentSize;
  }
  return self;
}

- (void) setBaseScale:(float)baseScale {
  [super setBaseScale:baseScale];
  [(CCSprite *)[self getChildByName:CONSTRUCTION_TAG recursively:NO] setScale:baseScale];
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
  }
  return self;
}

- (void) setColor:(CCColor *)color {
  [super setColor:color];
  
  if (self.isConstructing) {
    [(CCSprite *)[self getChildByName:CONSTRUCTION_TAG recursively:NO] setColor:color];
  }
}

- (BOOL) select {
  BOOL ret = [super select];
  
  if (self.isConstructing) {
    CCAction *action = [self.buildingSprite getActionByTag:BOUNCE_ACTION_TAG];
    CCNode *constr = [self getChildByName:CONSTRUCTION_TAG recursively:NO];
    [constr runAction:[action copy]];
  }
  
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
  
  if (self.isConstructing) {
    CCNode *constr = [self getChildByName:CONSTRUCTION_TAG recursively:NO];
    [constr stopActionByTag:GLOW_ACTION_TAG];
  }
}

- (void) setIsConstructing:(BOOL)isConstructing {
  if (_isConstructing != isConstructing) {
    if (isConstructing) {
      self.buildingSprite.visible = NO;
      _isConstructing = isConstructing;
      
      [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Construction.plist"];
      CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Construction.png"];
      sprite.anchorPoint = ccp(0.462, 0.165);
      sprite.position = ccp(self.contentSize.width/2, -self.verticalOffset-2);
      sprite.scale = self.baseScale;
      [self addChild:sprite z:1 name:CONSTRUCTION_TAG];
      
      CCAnimation *anim = [CCAnimation animationWithSpritePrefix:@"Construction" delay:1];
      CCSprite *spr = [CCSprite spriteWithSpriteFrame:[[anim.frames objectAtIndex:0] spriteFrame]];
      [spr runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:anim]]];
      [sprite addChild:spr];
      spr.position = ccp(sprite.contentSize.width/2, sprite.contentSize.height/2);
    } else {
      _isConstructing = isConstructing;
      self.buildingSprite.visible = YES;
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
  [self placeBlock];
}

-(void) updateMeta {
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

-(void) clearMeta {
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

-(void) placeBlock {
  if (_isSetDown) {
    return;
  }
  
  CCSprite *sprite = (CCSprite *)[self getChildByName:CONSTRUCTION_TAG recursively:NO];
  sprite = sprite ? sprite : self.buildingSprite;
  
  if ([_homeMap isBlockBuildable:self.location]) {
    sprite.opacity = 1.f;
    [_homeMap changeTiles:self.location toBuildable:NO];
    _isSetDown = YES;
    _startMoveCoordinate = _location.origin;
    _startOrientation = self.orientation;
  } else {
    sprite.opacity = 0.6f;
  }
}

- (void) liftBlock {
  CCSprite *sprite = (CCSprite *)[self getChildByName:CONSTRUCTION_TAG recursively:NO];
  sprite = sprite ? sprite : self.buildingSprite;
  
  if (self.isSetDown) {
    sprite.opacity = 0.6f;
    [_homeMap changeTiles:self.location toBuildable:YES];
  }
  self.isSetDown = NO;
}

-(void) locationAfterTouch: (CGPoint) touchLocation {
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
  node.position = ccp(self.contentSize.width/2, -self.verticalOffset);
  
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

- (void) updateUpgradeBar {
  CCNode *n = [self getChildByName:UPGRADING_TAG recursively:NO];
  if (n && [n isKindOfClass:[UpgradeProgressBar class]]) {
    UpgradeProgressBar *bar = (UpgradeProgressBar *)n;
    
    NSTimeInterval time = self.userStruct.timeLeftForBuildComplete;
    int totalTime = self.userStruct.staticStruct.structInfo.minutesToBuild*60;
    
    if (_percentage) {
      time = totalTime*(100.f-_percentage)/100.f;
    }
    
    [bar updateForSecsLeft:(int)time totalSecs:totalTime];
  }
}

- (void) displayUpgradeComplete {
  CCSprite *spinner = [CCSprite spriteWithImageNamed:@"buildingspinner.png"];
  
  NSString *str = self.userStruct.staticStruct.structInfo.level == 1 ? @"Building Complete!" : @"Building Upgraded!";
  CCLabelTTF *label = [CCLabelTTF labelWithString:str fontName:[Globals font] fontSize:22.f];
  [label setFontColor:[CCColor colorWithCcColor3b:ccc3(255, 200, 0)]];
  [label setShadowOffset:ccp(0, -1)];
  
  [self addChild:spinner z:-1];
  [self addChild:label];
  
  spinner.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
  label.position = ccp(self.contentSize.width/2, self.contentSize.height + 15);
  
  [spinner runAction:
   [CCActionSpawn actions:
    [CCActionFadeIn actionWithDuration:0.3f],
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

- (id) initWithUserStruct:(UserStruct *)userStruct map:(HomeMap *)map {
  StructureInfoProto *fsp = userStruct.staticStruct.structInfo;
  CGRect loc = CGRectMake(userStruct.coordinates.x, userStruct.coordinates.y, fsp.width, fsp.height);
  if ((self = [self initWithFile:nil location:loc map:map])) {
    self.userStruct = userStruct;
    
    ResourceGeneratorProto *res = (ResourceGeneratorProto *)userStruct.staticStruct;
    NSString *prefix = res.resourceType == ResourceTypeCash ? @"MPM" : @"OilDrill";
    float vertOffset = res.resourceType == ResourceTypeCash ? 18 : 23;
    float horizOffset = res.resourceType == ResourceTypeCash ? -3 : 0;
    float delay = res.resourceType == ResourceTypeCash ? 0.2 : 0.2;
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@.plist", prefix]];
    CCAnimation *anim = [CCAnimation animationWithSpritePrefix:prefix delay:delay];
    
    if (res.resourceType == ResourceTypeOil) {
      [anim repeatFrames:NSMakeRange(3,2) numTimes:5];
    }
    
    CCSprite *spr = [CCSprite spriteWithSpriteFrame:[anim.frames[0] spriteFrame]];
    [spr runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:anim]]];
    spr.anchorPoint = ccp(0.5, 0);
    spr.scale = self.baseScale;
    [self addChild:spr];
    self.buildingSprite = spr;
    spr.position = ccp(spr.contentSize.width/2+horizOffset, vertOffset+fsp.imgVerticalPixelOffset);
    self.contentSize = CGSizeMake(self.buildingSprite.contentSize.width, self.buildingSprite.contentSize.height+self.buildingSprite.position.y);
    self.baseScale = 0.75;
  }
  return self;
}

- (void) initializeRetrieveBubble {
  if (_retrieveBubble) {
    // Make sure to cleanup just in case
    [_retrieveBubble removeFromParent];
  }
  ResourceType type = ((ResourceGeneratorProto *)self.userStruct.staticStruct).resourceType;
  _retrieveBubble = [CCSprite spriteWithImageNamed:type == ResourceTypeCash ? @"cashready.png" : @"oilready.png"];
  [self addChild:_retrieveBubble];
  _retrieveBubble.position = ccp(self.contentSize.width/2,self.contentSize.height-OVER_HOME_BUILDING_MENU_OFFSET);
}

- (BOOL) select {
  if (self.retrievable) {
    [_homeMap retrieveFromBuilding:self];
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
  if (retrievable != _retrievable) {
    _retrievable = retrievable;
    
    if (retrievable) {
      if (!_retrieveBubble) {
        [self initializeRetrieveBubble];
      }
      _retrieveBubble.visible = YES;
    } else {
      _retrieveBubble.visible = NO;
    }
  }
}

- (void) setIsConstructing:(BOOL)isConstructing {
  [super setIsConstructing:isConstructing];
  self.retrievable = NO;
}

@end

@implementation ResourceStorageBuilding

- (id) initWithUserStruct:(UserStruct *)userStruct map:(HomeMap *)map {
  StructureInfoProto *fsp = userStruct.staticStruct.structInfo;
  CGRect loc = CGRectMake(userStruct.coordinates.x, userStruct.coordinates.y, fsp.width, fsp.height);
  if ((self = [self initWithFile:nil location:loc map:map])) {
    self.userStruct = userStruct;
    
    ResourceStorageProto *res = (ResourceStorageProto *)userStruct.staticStruct;
    NSString *prefix = res.resourceType == ResourceTypeCash ? @"CashStorage" : @"OilStorage";
    float vertOffset = res.resourceType == ResourceTypeCash ? 5 : 12;
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@.plist", prefix]];
    self.anim = [CCAnimation animationWithSpritePrefix:prefix delay:2.];
    
    CCSprite *spr = [CCSprite spriteWithSpriteFrame:[self.anim.frames[0] spriteFrame]];
    spr.anchorPoint = ccp(0.5, 0);
    spr.scale = self.baseScale;
    [self addChild:spr];
    self.buildingSprite = spr;
    self.contentSize = self.buildingSprite.contentSize;
    spr.position = ccp(spr.contentSize.width/2, vertOffset+fsp.imgVerticalPixelOffset);
  }
  return self;
}

- (void) setPercentage:(float)percentage {
  int mult = self.anim.frames.count-1;
  int imgNum = roundf(percentage*mult);
  CCSpriteFrame *frame = [self.anim.frames[imgNum] spriteFrame];
  [self.buildingSprite setSpriteFrame:frame];
}


@end

@implementation HospitalBuilding

- (id) initWithUserStruct:(UserStruct *)userStruct map:(HomeMap *)map {
  StructureInfoProto *fsp = userStruct.staticStruct.structInfo;
  CGRect loc = CGRectMake(userStruct.coordinates.x, userStruct.coordinates.y, fsp.width, fsp.height);
  if ((self = [self initWithFile:nil location:loc map:map])) {
    self.userStruct = userStruct;
    
    [self beginAnimatingWithMonsterId:0];
    [self stopAnimating];
  }
  return self;
}

- (void) beginAnimatingWithMonsterId:(int)monsterId {
  [self.monsterSprite removeFromParent];
  [self.buildingSprite removeFromParent];
  [self.tubeSprite removeFromParent];
  
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"HealingCenter.plist"];
  CCAnimation *anim = [CCAnimation animationWithSpritePrefix:@"HealingCenterBase" delay:0.1];
  [anim repeatFrames:NSMakeRange(0,1) numTimes:5];
  
  StructureInfoProto *fsp = [self.userStruct.staticStruct structInfo];
  CCSprite *spr = [CCSprite spriteWithSpriteFrame:[anim.frames[0] spriteFrame]];
  [spr runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:anim]]];
  spr.anchorPoint = ccp(0.5, 0);
  spr.position = ccp(spr.contentSize.width/2, 15+fsp.imgVerticalPixelOffset);
  spr.scale = self.baseScale;
  [self addChild:spr];
  self.buildingSprite = spr;
  self.contentSize = self.buildingSprite.contentSize;
  self.baseScale = 0.85;
  
  anim = [CCAnimation animationWithSpritePrefix:@"HealingCenterTube" delay:0.1];
  [anim repeatFrames:NSMakeRange(0,1) numTimes:5];
  spr = [CCSprite spriteWithSpriteFrame:[anim.frames[0] spriteFrame]];
  [spr runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:anim]]];
  spr.position = ccp(self.buildingSprite.contentSize.width/2, self.buildingSprite.contentSize.height/2);
  [self.buildingSprite addChild:spr z:2];
  self.tubeSprite = spr;
  
  if (monsterId) {
    GameState *gs = [GameState sharedGameState];
    MonsterProto *mp = [gs monsterWithId:monsterId];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@AttackNF.plist", mp.imagePrefix]];
    NSString *file = [NSString stringWithFormat:@"%@AttackN00.png", mp.imagePrefix];
    if ([[CCSpriteFrameCache sharedSpriteFrameCache] containsFrame:file]) {
      self.monsterSprite = [CCSprite spriteWithImageNamed:file];
      self.monsterSprite.anchorPoint = ccp(0.5, 0);
      self.monsterSprite.position = ccp(self.contentSize.width/2, 1);
      self.monsterSprite.scale = 0.8;
      self.monsterSprite.flipX = YES;
      [self.buildingSprite addChild:self.monsterSprite z:1];
    }
  }
}

- (void) stopAnimating {
  [self.monsterSprite removeFromParent];
  
  [self.buildingSprite stopAllActions];
  [self.tubeSprite stopAllActions];
  
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"HealingCenter.plist"];
  CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"HealingCenterBase00.png"];
  [self.buildingSprite setSpriteFrame:frame];
  frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"HealingCenterTube00.png"];
  [self.tubeSprite setSpriteFrame:frame];
}

@end

@implementation TownHallBuilding

- (id) initWithUserStruct:(UserStruct *)userStruct map:(HomeMap *)map {
  if ((self = [super initWithUserStruct:userStruct map:map])) {
    StructureInfoProto *fsp = [userStruct.staticStruct structInfo];
    self.verticalOffset = 0;
    self.buildingSprite.position = ccpAdd(self.buildingSprite.position, ccp(-2, 5+fsp.imgVerticalPixelOffset));
  }
  return self;
}

@end

@implementation ResidenceBuilding

- (id) initWithUserStruct:(UserStruct *)userStruct map:(HomeMap *)map {
  if ((self = [super initWithUserStruct:userStruct map:map])) {
    StructureInfoProto *fsp = [userStruct.staticStruct structInfo];
    self.buildingSprite.position = ccpAdd(self.buildingSprite.position, ccp(0, 3+fsp.imgVerticalPixelOffset));
  }
  return self;
}

@end

@implementation LabBuilding

- (id) initWithUserStruct:(UserStruct *)userStruct map:(HomeMap *)map {
  if ((self = [super initWithUserStruct:userStruct map:map])) {
    StructureInfoProto *fsp = [userStruct.staticStruct structInfo];
    self.buildingSprite.position = ccpAdd(self.buildingSprite.position, ccp(0, fsp.imgVerticalPixelOffset));
    
    [self beginAnimating];
  }
  return self;
}

- (void) beginAnimating {
  [self.buildingSprite removeFromParent];
  
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"ResearchLab.plist"];
  CCAnimation *anim = [CCAnimation animationWithSpritePrefix:@"ResearchLab" delay:0.1];
  
  StructureInfoProto *fsp = [self.userStruct.staticStruct structInfo];
  CCSprite *spr = [CCSprite spriteWithSpriteFrame:[anim.frames[0] spriteFrame]];
  [spr runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:anim]]];
  spr.anchorPoint = ccp(0.5, 0);
  spr.position = ccp(spr.contentSize.width/2-2, 15+fsp.imgVerticalPixelOffset);
  spr.scale = self.baseScale;
  [self addChild:spr];
  self.buildingSprite = spr;
  self.contentSize = self.buildingSprite.contentSize;
  self.baseScale = 0.85;
}

- (void) stopAnimating {
  [self.buildingSprite stopAllActions];
  
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"ResearchLab.plist"];
  CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"ResearchLab00.png"];
  [self.buildingSprite setSpriteFrame:frame];
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

//- (BOOL) select {
//  BOOL select = [super select];
//
//  [self.buildingSprite stopActionByTag:BOUNCE_ACTION_TAG];
//
//  return select;
//}

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

- (void) updateUpgradeBar {
  CCNode *n = [self getChildByName:UPGRADING_TAG recursively:NO];
  if (n && [n isKindOfClass:[UpgradeProgressBar class]]) {
    UpgradeProgressBar *bar = (UpgradeProgressBar *)n;
    Globals *gl = [Globals sharedGlobals];
    GameState *gs = [GameState sharedGameState];
    UserExpansion *ue = [gs getExpansionForX:self.expandSpot.x y:self.expandSpot.y];
    
    int totalTime = [gl calculateNumMinutesForNewExpansion]*60;
    NSTimeInterval time = [[NSDate dateWithTimeInterval:totalTime sinceDate:ue.lastExpandTime] timeIntervalSinceNow];
    
    if (_percentage) {
      time = totalTime*(100.f-_percentage)/100.f;
    }
    
    [bar updateForSecsLeft:(int)time totalSecs:totalTime];
  }
}

@end