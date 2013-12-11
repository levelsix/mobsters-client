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

@implementation HomeBuilding

- (id) initWithFile:(NSString *)file location:(CGRect)loc map:(HomeMap *)map {
  if ((self = [super initWithFile:file location:loc map:map])) {
    _homeMap = map;
    [self placeBlock];
    
    self.baseScale = 0.75;
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

- (void) setColor:(ccColor3B)color {
  [super setColor:color];
  
  if (self.isConstructing) {
    [(CCSprite *)[self getChildByTag:CONSTRUCTION_TAG] setColor:color];
  }
}

- (BOOL) select {
  BOOL ret = [super select];
  
  if (self.isConstructing) {
    CCAction *action = [self.buildingSprite getActionByTag:BOUNCE_ACTION_TAG];
    CCNode *constr = [self getChildByTag:CONSTRUCTION_TAG];
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
    CCNode *constr = [self getChildByTag:CONSTRUCTION_TAG];
    [constr stopActionByTag:GLOW_ACTION_TAG];
  }
}

- (void) setIsConstructing:(BOOL)isConstructing {
  if (_isConstructing != isConstructing) {
    if (isConstructing) {
      self.buildingSprite.opacity = 0.f;
      _isConstructing = isConstructing;
      
      [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Construction.plist"];
      CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"Construction.png"];
      sprite.anchorPoint = ccp(0.462, 0.165);
      sprite.position = ccp(self.contentSize.width/2, -self.verticalOffset-2);
      [self addChild:sprite z:1 tag:CONSTRUCTION_TAG];
      
      CCAnimation *anim = [CCAnimation animationWithSpritePrefix:@"Construction" delay:1];
      CCSprite *spr = [CCSprite spriteWithSpriteFrame:[[anim.frames objectAtIndex:0] spriteFrame]];
      [spr runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim]]];
      [sprite addChild:spr];
      spr.position = ccp(sprite.contentSize.width/2, sprite.contentSize.height/2);
    } else {
      _isConstructing = isConstructing;
      self.buildingSprite.opacity = 255;
      [self removeChildByTag:CONSTRUCTION_TAG cleanup:YES];
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
  CCTMXLayer *meta = [_homeMap layerNamed:@"MetaLayer"];
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
  CCTMXLayer *meta = [_homeMap layerNamed:@"MetaLayer"];
  for (int i = 0; i < self.location.size.width; i++) {
    for (int j = 0; j < self.location.size.height; j++) {
      CGPoint tileCoord = ccp(_homeMap.mapSize.height-1-(self.location.origin.y+j),_homeMap.mapSize.width-1-(self.location.origin.x+i));
      [meta removeTileAt:tileCoord];
    }
  }
}

-(void) placeBlock {
  if (_isSetDown) {
    return;
  }
  
  CCSprite *sprite = (CCSprite *)[self getChildByTag:CONSTRUCTION_TAG];
  sprite = sprite ? sprite : self.buildingSprite;
  
  if ([_homeMap isBlockBuildable:self.location]) {
    sprite.opacity = 255;
    [_homeMap changeTiles:self.location toBuildable:NO];
    _isSetDown = YES;
    _startMoveCoordinate = _location.origin;
    _startOrientation = self.orientation;
  } else {
    sprite.opacity = 150;
  }
}

- (void) liftBlock {
  CCSprite *sprite = (CCSprite *)[self getChildByTag:CONSTRUCTION_TAG];
  sprite = sprite ? sprite : self.buildingSprite;
  
  if (self.isSetDown) {
    sprite.opacity = 150;
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

#define ARROW_LAYER_TAG 821
#define ARROW_FADE_DURATION 0.2f

- (void) displayMoveArrows {
  CCNode *o = [self getChildByTag:ARROW_LAYER_TAG];
  if (o) {
    [o stopAllActions];
    [o recursivelyApplyOpacity:255];
    return;
  }
  
  CCSprite *node = [CCSprite node];
  
  CCSprite *nr = [CCSprite spriteWithFile:@"arrowdown.png"];
  CCSprite *nl = [CCSprite spriteWithFile:@"arrowdown.png"];
  CCSprite *fr = [CCSprite spriteWithFile:@"arrowup.png"];
  CCSprite *fl = [CCSprite spriteWithFile:@"arrowup.png"];
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
  [node runAction:[RecursiveFadeTo actionWithDuration:ARROW_FADE_DURATION opacity:255]];
  
  [self addChild:node z:-1 tag:ARROW_LAYER_TAG];
}

- (void) removeMoveArrows {
  CCNode *node = [self getChildByTag:ARROW_LAYER_TAG];
  [node stopAllActions];
  [node runAction:[CCSequence actions:[RecursiveFadeTo actionWithDuration:ARROW_FADE_DURATION opacity:0],
                   [CCCallBlock actionWithBlock:^{[node removeFromParentAndCleanup:YES];}], nil]];
}

- (void) updateUpgradeBar {
  CCNode *n = [self getChildByTag:UPGRADING_TAG];
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
  CCSprite *spinner = [CCSprite spriteWithFile:@"buildingspinner.png"];
  
  NSString *str = self.userStruct.staticStruct.structInfo.level == 1 ? @"Building Complete!" : @"Building Upgraded!";
  CCLabelTTF *label = [CCLabelTTF labelWithString:str fontName:[Globals font] fontSize:22.f];
  [label setFontFillColor:ccc3(255, 200, 0) updateImage:NO];
  [label enableShadowWithOffset:CGSizeMake(0, -1) opacity:0.7f blur:0.f updateImage:YES];
  
  [self addChild:spinner z:-1];
  [self addChild:label];
  
  spinner.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
  label.position = ccp(self.contentSize.width/2, self.contentSize.height + 15);
  
  [spinner runAction:
   [CCSpawn actions:
    [CCFadeIn actionWithDuration:0.3f],
    [CCRotateBy actionWithDuration:5.f angle:360.f],
    [CCSequence actions:
     [CCDelayTime actionWithDuration:3.7f],
     [CCFadeOut actionWithDuration:1.3f],
     [CCCallBlock actionWithBlock:^{[spinner removeFromParentAndCleanup:YES];}],
     nil],
    nil]];
  
  label.scale = 0.3f;
  [label runAction:[CCSequence actions:
                    [CCSpawn actions:
                     [CCEaseElasticOut actionWithAction:[CCScaleTo actionWithDuration:1.2f scale:1]],
                     [CCSequence actions:
                      [CCDelayTime actionWithDuration:3.7f],
                      [CCFadeOut actionWithDuration:1.3f],
                      nil],
                     [CCMoveBy actionWithDuration:5.f position:ccp(0,35)],nil],
                    [CCCallBlock actionWithBlock:^{[label removeFromParentAndCleanup:YES];}], nil]];
}

@end

@implementation ResourceGeneratorBuilding

- (void) initializeRetrieveBubble {
  if (_retrieveBubble) {
    // Make sure to cleanup just in case
    [self removeChild:_retrieveBubble cleanup:YES];
  }
  _retrieveBubble = [CCSprite spriteWithFile:@"cashready.png"];
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

@end

@implementation ResourceStorageBuilding


@end

@implementation HospitalBuilding


@end

@implementation TownHallBuilding


@end

@implementation ResidenceBuilding


@end

@implementation ExpansionBoard

- (id) initWithExpansionBlock:(CGPoint)block location:(CGRect)location map:(GameMap *)map isExpanding:(BOOL)isExpanding {
  int blockSum = abs(block.x)+abs(block.y);
  NSString *file = [NSString stringWithFormat:@"sale%d.png", (blockSum%3)+1];
  if ((self = [super initWithFile:file location:location map:map])) {
    self.expandSpot = block;
    
    [self removeChildByTag:SHADOW_TAG];
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

- (BOOL) isPointInArea:(CGPoint)pt {
  pt = [_map convertToNodeSpace:pt];
  
  CGPoint tilePt = [_map convertCCPointToTilePoint:pt];
  return CGRectContainsPoint(self.location, tilePt);
}

- (void) beginExpanding {
  [self displayProgressBar];
  CCNode *n = [self getChildByTag:UPGRADING_TAG];
  n.position = ccpAdd(ccp(self.contentSize.width/2, self.contentSize.height/2), ccp(0, 5));
}

- (void) updateUpgradeBar {
  CCNode *n = [self getChildByTag:UPGRADING_TAG];
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