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
#import "BuildingButton.h"
#import "IAPHelper.h"

#define DARK_SHADOW_TAG @"DarkShadow"
#define CONSTR_FRAME_TAG @"ConstrFrame"

@implementation HomeBuilding

- (id) initWithFile:(NSString *)file location:(CGRect)loc map:(HomeMap *)map {
  if ((self = [super initWithFile:file location:loc map:map])) {
    _homeMap = map;
    
    if (loc.size.width == loc.size.height && loc.size.width > 0) {
      NSString *fileName = [NSString stringWithFormat:@"%dx%ddark.png", (int)loc.size.width, (int)loc.size.height];
      CCSprite *shadow = [CCSprite spriteWithImageNamed:fileName];
      [self addChild:shadow z:-1 name:SHADOW_TAG];
      shadow.anchorPoint = ccp(0.5, 0);
    }
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
      
    case StructureInfoProto_StructTypeMiniJob:
      buildingClass = [MiniJobCenterBuilding class];
      break;
      
    case StructureInfoProto_StructTypeTeamCenter:
      buildingClass = [TeamCenterBuilding class];
      break;
      
    case StructureInfoProto_StructTypeClan:
      buildingClass = [ClanHouseBuilding class];
      break;
      
    case StructureInfoProto_StructTypeMoneyTree:
      buildingClass = [MoneyTreeBuilding class];
      break;
      
    case StructureInfoProto_StructTypeBattleItemFactory:
      buildingClass = [ItemFactoryBuilding class];
      break;
      
    case StructureInfoProto_StructTypeResearchHouse:
      buildingClass = [ResearchBuilding class];
      break;
      
    case StructureInfoProto_StructTypeNoStruct:
    
      
    default:
      buildingClass = [HomeBuilding class];
      break;
  }
  
  return [[buildingClass alloc] initWithUserStruct:us map:map];
}

- (id) initWithUserStruct:(UserStruct *)userStruct map:(HomeMap *)map {
  StructureInfoProto *fsp = userStruct.isComplete || !userStruct.staticStruct.structInfo.predecessorStructId ? userStruct.staticStruct.structInfo : userStruct.staticStructForPrevLevel.structInfo;
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
  self.horizontalOffset = fsp.imgHorizontalPixelOffset;
  [super adjustBuildingSprite];
  
  CCNode *n = [self getChildByName:DARK_SHADOW_TAG recursively:YES];
  [n removeFromParent];
  if (fsp.hasShadowImgName) {
    CCNode *grass = [self getChildByName:SHADOW_TAG recursively:YES];
    CCSprite *shadow = [CCSprite spriteWithImageNamed:fsp.shadowImgName];
    [grass addChild:shadow z:1 name:DARK_SHADOW_TAG];
    shadow.scale = fsp.shadowScale;
    shadow.position = ccp(grass.contentSize.width/2+fsp.shadowHorizontalOfffset, grass.contentSize.height/2+fsp.shadowVerticalOffset);
  }
}

- (void) setColor:(CCColor *)color {
  [super setColor:color];
  [[self getChildByName:CONSTR_FRAME_TAG recursively:YES] recursivelyApplyColor:color];
}

- (BOOL) select {
  // Check if prereqs contain task
  Globals *gl = [Globals sharedGlobals];
  StructureInfoProto *fsp = self.userStruct.staticStructForNextLevel.structInfo;
  NSArray *incomplete = [gl incompletePrereqsForStructId:fsp.structId];
  
  PrereqProto *pre = nil;
  for (PrereqProto *p in incomplete) {
    if (p.prereqGameType == GameTypeTask) {
      pre = p;
    }
  }
  
  if (!pre) {
    BOOL ret = [super select];
    _startMoveCoordinate = _location.origin;
    _startOrientation = self.orientation;
    [self displayMoveArrows];
    [self displayBuildingInfo:YES];
    
    CCSprite *frame = (CCSprite *)[self getChildByName:CONSTR_FRAME_TAG recursively:YES];
    [frame stopActionByTag:BOUNCE_ACTION_TAG];
    
    CCAction *action = [self.buildingSprite getActionByTag:BOUNCE_ACTION_TAG];
    if (action) {
      [frame runAction:action.copy];
    }
    
    return ret;
  } else {
    GameState *gs = [GameState sharedGameState];
    TaskMapElementProto *elem = [gs mapElementWithTaskId:pre.prereqGameEntityId];
    FullTaskProto *ftp = [gs taskWithId:elem.taskId];
    [Globals addAlertNotification:[NSString stringWithFormat:@"Defeat Single Player Level %d \"%@\" to unlock the %@.", elem.mapElementId, ftp.name, fsp.name]];
    
    [SoundEngine generalButtonClick];
    
    return NO;
  }
}

- (void) unselect {
  [super unselect];
  if (!_isSetDown && !_isPurchasing) {
    [self cancelMove];
  }
  [self removeMoveArrows];
  [self removeBuildingInfo:YES];
}

- (void) displayBuildingInfo:(BOOL)animate {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *buildingButtons = [NSMutableArray array];
  
  UserStruct *us = self.userStruct;
  StructureInfoProto *fsp = us.staticStruct.structInfo;
  StructureInfoProto *nextFsp = us.staticStructForNextLevel.structInfo;
  
  BOOL isUpgradableBuilding = fsp.predecessorStructId || fsp.successorStructId;
  if (fsp.structType != StructureInfoProto_StructTypeMoneyTree) {
    [self displayBuildingTitle:fsp.name subtitle:isUpgradableBuilding ? (fsp.level ? [NSString stringWithFormat:@"LVL %d", fsp.level] : @"Broken") : @"" animate:animate];
  } else {
    [self displayBuildingTitle:fsp.name subtitle:us.isExpired ? @"Expired" : [Globals convertTimeToSingleLongString:[us timeTillExpiry]] animate:animate];
  }

  // SPECIAL CASE.. Money Tree
  BOOL continueNormally = YES;
  if (fsp.structType == StructureInfoProto_StructTypeMoneyTree && us.isExpired) {
    MoneyTreeProto *mtp = (MoneyTreeProto *)us.staticStruct;
    
    IAPHelper *iap = [IAPHelper sharedIAPHelper];
    SKProduct *prod = [iap productForIdentifier:mtp.iapProductId];
    NSString *price = [iap priceForProduct:prod];
    [buildingButtons addObject:[BuildingButton buttonFixWithIAPString:price]];
    
    continueNormally = NO;
  }
  
  if (continueNormally) {
    if (us.isComplete) {
      if (fsp.successorStructId) {
        if (fsp.level == 0) {
          [buildingButtons addObject:[BuildingButton buttonFixWithResourceType:nextFsp.buildResourceType cost:nextFsp.buildCost]];
        } else {
          [buildingButtons addObject:[BuildingButton buttonUpgradeWithResourceType:nextFsp.buildResourceType cost:nextFsp.buildCost]];
        }
      } else {
        [buildingButtons addObject:[BuildingButton buttonInfo]];
      }
    } else {
      int timeLeft = [_homeMap timeLeftForConstructionBuildingOrObstacle:self];
      int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
      BOOL canGetHelp = [gs canAskForClanHelp] && [gs.clanHelpUtil getNumClanHelpsForType:GameActionTypeUpgradeStruct userDataUuid:us.userStructUuid] < 0;
      
      if (gemCost && canGetHelp) {
        [buildingButtons addObject:[BuildingButton buttonClanHelp]];
      } else {
        [buildingButtons addObject:[BuildingButton buttonSpeedup:!gemCost]];
      }
    }
    
    if (fsp.level > 1 || (us.isComplete && fsp.level == 1)) {
      switch (fsp.structType) {
        case StructureInfoProto_StructTypeResidence:
          [buildingButtons addObject:[BuildingButton buttonBonusSlots]];
          [buildingButtons addObject:[BuildingButton buttonSell]];
          break;
          
        case StructureInfoProto_StructTypeHospital:
          [buildingButtons addObject:[BuildingButton buttonHeal]];
          break;
          
        case StructureInfoProto_StructTypeEvo:
          [buildingButtons addObject:[BuildingButton buttonEvolve]];
          break;
          
        case StructureInfoProto_StructTypeResearchHouse:
          [buildingButtons addObject:[BuildingButton buttonResearch]];
          break;
          
        case StructureInfoProto_StructTypeLab:
          [buildingButtons addObject:[BuildingButton buttonEnhance]];
          break;
          
        case StructureInfoProto_StructTypeMiniJob:
          [buildingButtons addObject:[BuildingButton buttonMiniJobs]];
          break;
          
        case StructureInfoProto_StructTypeTeamCenter:
          [buildingButtons addObject:[BuildingButton buttonTeam]];
          break;
          
        case StructureInfoProto_StructTypeClan:
          [buildingButtons addObject:[BuildingButton buttonJoinClan]];
          break;
          
        case StructureInfoProto_StructTypePvpBoard:
          [buildingButtons addObject:[BuildingButton buttonPvPBoard]];
          break;
          
        case StructureInfoProto_StructTypeBattleItemFactory:
          [buildingButtons addObject:[BuildingButton buttonItemFactory]];
          break;
          
        default:
          break;
      }
    }
  }
  
  [self displayBuildingButtons:buildingButtons targetSelector:@selector(buildingButtonTapped:) animate:animate];
}

- (void) removeBuildingInfo:(BOOL)animate {
  [self removeBuildingButtons:animate];
  [self removeBuildingTitle:animate];
}

- (void) buildingButtonTapped:(BuildingButton*)sender {
  // Create a fake button to carry the message up the chain
  MapBotViewButton* button = [[MapBotViewButton alloc] init];
  button.config = sender.buttonConfig;
  [_homeMap mapBotViewButtonSelected:button];
}

- (void) setIsConstructing:(BOOL)isConstructing {
  if (_isConstructing != isConstructing) {
    _isConstructing = isConstructing;
    if (isConstructing) {
      BOOL smallSquare = self.location.size.width == 3;
      NSString *poles = smallSquare ? @"3x3poles.png" : @"4x4poles.png";
      CCSprite *pole = [CCSprite spriteWithImageNamed:poles];
      pole.anchorPoint = ccp(0.5, 0);
      pole.position = ccp(self.contentSize.width/2, 1);
      [self addChild:pole z:1 name:CONSTRUCTION_TAG];
      
      if (!self.userStruct.staticStruct.structInfo.predecessorStructId) {
        self.buildingSprite.visible = NO;
        [self getChildByName:DARK_SHADOW_TAG recursively:YES].visible = NO;
        NSString *frame = smallSquare ? @"3x3buildingframe.png" : @"4x4buildingframe.png";
        CCSprite *sprite = [CCSprite spriteWithImageNamed:frame];
        sprite.anchorPoint = ccp(0.5, 0);
        [pole addChild:sprite z:-1 name:CONSTR_FRAME_TAG];
        
        int horizOffset = smallSquare ? -4 : -1;
        int vertOffset = smallSquare ? 12 : 16;
        sprite.position = ccp(self.contentSize.width/2+horizOffset, vertOffset);
      }
    } else {
      // This means we just finished constructing, so reload the building sprite
      StructureInfoProto *fsp = self.userStruct.staticStruct.structInfo;
      [self setupBuildingSprite:fsp.imgName];
      
      [self removeChildByName:CONSTRUCTION_TAG cleanup:YES];
    }
  }
}

#pragma mark - Moving building

- (BOOL) canMove {
  return self.userStruct.staticStruct.structInfo.level > 0;
}

- (void) cancelMove {
  if ([self canMove]) {
    [self clearMeta];
    [self liftBlock];
    self.orientation = _startOrientation;
    CGRect x = self.location;
    x.origin = _startMoveCoordinate;
    self.location = x;
    [self placeBlock:YES];
  }
}

- (void) updateMeta {
  if ([self canMove]) {
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
    
    if (_isSelected) {
      [self displayBuildingInfo:YES];
    }
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
  if ([self canMove]) {
    CCSprite *sprite = self.buildingSprite;
    
    if (self.isSetDown) {
      sprite.opacity = 0.6f;
      [_homeMap changeTiles:self.location toBuildable:YES];
      
      if (_isSelected) {
        [self removeBuildingInfo:YES];
      }
    }
    self.isSetDown = NO;
  }
}

- (void) locationAfterTouch: (CGPoint) touchLocation {
  if ([self canMove]) {
    // Subtract the touch location from the start location to find the distance moved
    CGPoint vector = ccpSub(touchLocation, _startTouchLocation);
    CGSize ts = _homeMap.tileSize;
    if (ABS(vector.x)+ABS(2*vector.y) >= ts.width) {
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
}

#define ARROW_LAYER_TAG @"Arrow"
#define ARROW_FADE_DURATION 0.2f

- (void) displayMoveArrows {
  if ([self canMove]) {
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
    float inset = 0.18;
    nr.position = ccpSub([_map convertTilePointToCCPoint:ccp(CGRectGetMidX(r), CGRectGetMinY(r)+inset)], relativeTo);
    nl.position = ccpSub([_map convertTilePointToCCPoint:ccp(CGRectGetMinX(r)+inset, CGRectGetMidY(r))], relativeTo);
    fr.position = ccpSub([_map convertTilePointToCCPoint:ccp(CGRectGetMaxX(r)-inset, CGRectGetMidY(r))], relativeTo);
    fl.position = ccpSub([_map convertTilePointToCCPoint:ccp(CGRectGetMidX(r), CGRectGetMaxY(r)-inset)], relativeTo);
    
    [node addChild:nr];
    [node addChild:nl];
    [node addChild:fr];
    [node addChild:fl];
    node.position = ccp(self.contentSize.width/2, 0);
    
    [node recursivelyApplyOpacity:0];
    [node runAction:[RecursiveFadeTo actionWithDuration:ARROW_FADE_DURATION opacity:1.f]];
    
    [self addChild:node z:-1 name:ARROW_LAYER_TAG];
  }
}

- (void) removeMoveArrows {
  CCNode *node = [self getChildByName:ARROW_LAYER_TAG recursively:NO];
  [node stopAllActions];
  [node runAction:[CCActionSequence actions:[RecursiveFadeTo actionWithDuration:ARROW_FADE_DURATION opacity:0],
                   [CCActionCallBlock actionWithBlock:^{[node removeFromParentAndCleanup:YES];}], nil]];
}

#pragma mark - Upgrade

- (BOOL) isFreeSpeedup {
  Globals *gl = [Globals sharedGlobals];
  int gemCost = [gl calculateGemSpeedupCostForTimeLeft:self.userStruct.timeLeftForBuildComplete allowFreeSpeedup:YES];
  return gemCost == 0;
}

- (NSString *) progressBarPrefix {
  if (![self isFreeSpeedup]) {
    return @"obtimeryellow";
  } else {
    return @"obtimerpurple";
  }
}

- (void) updateProgressBar {
  UpgradeProgressBar *n = self.progressBar;
  // Check the prefix
  NSString *prefix = [self progressBarPrefix];
  if (_percentage || [n.prefix isEqualToString:prefix]) {
    UpgradeProgressBar *bar = (UpgradeProgressBar *)n;
    
    Globals *gl = [Globals sharedGlobals];
    NSTimeInterval time = self.userStruct.timeLeftForBuildComplete;
    int totalTime = [gl calculateSecondsToBuild:self.userStruct.staticStruct.structInfo];
    
    if (_percentage) {
      time = totalTime*(1.f-_percentage);
    }
    
    [bar updateForSecsLeft:time totalSecs:totalTime];
    
    if ([self isFreeSpeedup]) {
      [self.progressBar animateFreeLabel];
    }
  } else {
    [self displayProgressBar];
  }
}

- (void) displayUpgradeComplete {
  CCSprite *spinner = [CCSprite spriteWithImageNamed:@"spinnertest.png"];
  //spinner.blendFunc = (ccBlendFunc){GL_SRC_ALPHA, GL_ONE};
  spinner.blendMode = [CCBlendMode blendModeWithOptions:@{CCBlendFuncSrcColor: @(GL_SRC_ALPHA), CCBlendFuncDstColor: @(GL_ONE)}];
  
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
  if ([self isMemberOfClass:[ResourceGeneratorBuilding class]]) {
    [self.buildingSprite removeFromParent];
    
    fileName = fileName.stringByDeletingPathExtension;
    
    NSString *spritesheetName = [NSString stringWithFormat:@"%@.plist", fileName];
    [Globals checkAndLoadSpriteSheet:spritesheetName completion:^(BOOL success) {
      if (success) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:spritesheetName];
        CCAnimation *anim = [CCAnimation animationWithSpritePrefix:fileName delay:0.2];
        
        //userstruct is null on startup
        ResourceGeneratorProto *res = (ResourceGeneratorProto *)self.userStruct.staticStruct;
        if (res.resourceType == ResourceTypeOil) {
          //    [anim repeatFrames:NSMakeRange(3,2) numTimes:5];
          anim.delayPerUnit = 0.1;
        }
        
        if (anim.frames.count) {
          CCSprite *spr = [CCSprite spriteWithSpriteFrame:[anim.frames[0] spriteFrame]];
          [spr runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:anim]]];
          [self addChild:spr];
          self.buildingSprite = spr;
        }
        
        [self adjustBuildingSprite];
      }
    }];
  } else {
    [super setupBuildingSprite:fileName];
  }
}

- (void) adjustBuildingSprite {
  [super adjustBuildingSprite];
  
  // Reload the retrieve bubble
  if (_retrieveBubble) {
    [self initializeRetrieveBubble];
  }
}

- (void) initializeRetrieveBubble {
  GameState *gs = [GameState sharedGameState];
  ResourceType type = ((ResourceGeneratorProto *)self.userStruct.staticStruct).resourceType;
  NSString *res = type == ResourceTypeCash ? @"cash" : @"oil";
  int amount = type == ResourceTypeCash ? gs.cash : gs.oil;
  int max = type == ResourceTypeCash ? gs.maxCash : gs.maxOil;
  NSString *end = amount >= max ? @"overflow" : @"ready";
  float pxlOffset = type == ResourceTypeCash ? 10 : 16;
  
  NSString *fileName = [NSString stringWithFormat:@"%@%@.png", res, end];
  
  if (!_retrieveBubble || ![_retrieveBubble.name isEqualToString:fileName]) {
    // Make sure to cleanup just in case
    [_retrieveBubble removeFromParent];
    
    _retrieveBubble = [CCButton buttonWithTitle:nil spriteFrame:[CCSpriteFrame frameWithImageNamed:fileName] highlightedSpriteFrame:nil disabledSpriteFrame:nil];
    [_retrieveBubble setTarget:self selector:@selector(select)];
    [self addChild:_retrieveBubble z:1 name:fileName];
    _retrieveBubble.anchorPoint = ccp(0.5, 0);
    _retrieveBubble.position = ccp(self.contentSize.width/2,self.contentSize.height-pxlOffset);
  }
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
  _retrievable = retrievable;
  
  if (retrievable) {
    // do this to refresh if
    BOOL shouldFade = _retrieveBubble == nil;
    [self initializeRetrieveBubble];
    if (shouldFade) {
      _retrieveBubble.opacity = 0.f;
      [_retrieveBubble runAction:[RecursiveFadeTo actionWithDuration:0.3f opacity:1.f]];
    }
  } else {
    [_retrieveBubble runAction:
     [CCActionSequence actions:
      [RecursiveFadeTo actionWithDuration:0.3f opacity:0.f],
      [CCActionRemove action], nil]];
    _retrieveBubble = nil;
  }
}

- (void) setIsConstructing:(BOOL)isConstructing {
  [super setIsConstructing:isConstructing];
  
  if (isConstructing) {
    self.retrievable = NO;
  }
}

@end

@implementation MoneyTreeBuilding

- (NSString *) fileNameForUserStruct:(UserStruct *)userStruct {
  StructureInfoProto *fsp = userStruct.staticStruct.structInfo;
  NSString *file = fsp.imgName;
  
  if (userStruct.isExpired) {
    NSString *extension = file.pathExtension;
    file = file.stringByDeletingPathExtension;
    file = [NSString stringWithFormat:@"%@dead.%@",file, extension];
  }
  
  return file;
}

- (void) setupBuildingSprite:(NSString *)fileName {
  if ([fileName rangeOfString:@"dead"].length > 0) {
    [super setupBuildingSprite:fileName];
  } else {
    [self.buildingSprite removeFromParent];
    
    fileName = fileName.stringByDeletingPathExtension;
    
    NSString *spritesheetName = [NSString stringWithFormat:@"%@.plist", fileName];
    [Globals checkAndLoadSpriteSheet:spritesheetName completion:^(BOOL success) {
      if (success) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:spritesheetName];
        
        float delay = 0.1;
        
        CCAnimation *hole = [CCAnimation animationWithSpritePrefix:[fileName stringByAppendingString:@"Hole"] delay:delay];
        
        if (hole.frames.count) {
          CCSprite *spr = [CCSprite spriteWithSpriteFrame:[hole.frames[0] spriteFrame]];
          _holeAnim = hole;
          [self addChild:spr];
          self.buildingSprite = spr;
          _holeSprite = spr;
        }
        
        CCAnimation *drill = [CCAnimation animationWithSpritePrefix:[fileName stringByAppendingString:@"Drill"] delay:delay];
        
        if (drill.frames.count) {
          CCSprite *spr = [CCSprite spriteWithSpriteFrame:[drill.frames[0] spriteFrame]];
          _drillAnim = drill;
          [self.buildingSprite addChild:spr];
          spr.position = ccp(self.buildingSprite.contentSize.width/2, self.buildingSprite.contentSize.height/2+3);
          _drillSprite = spr;
        }
        
        CCAnimation *base = [CCAnimation animationWithSpritePrefix:[fileName stringByAppendingString:@"Base"] delay:delay];
        
        if (base.frames.count) {
          CCSprite *spr = [CCSprite spriteWithSpriteFrame:[base.frames[0] spriteFrame]];
          _baseAnim = base;
          [self.buildingSprite addChild:spr];
          spr.position = ccp(self.buildingSprite.contentSize.width/2, self.buildingSprite.contentSize.height/2);
          _baseSprite = spr;
        }
        
        //_smoke = [CCParticleSystem particleWithFile:@"gemsmoke.plist"];
        //_smoke.scale = 0.5f;
        //_smoke.position = ccp(self.buildingSprite.contentSize.width/2, 14);
        //[_smoke stopSystem];
        //[self.buildingSprite addChild:_smoke];
        
        [self adjustBuildingSprite];
        
        [self animateDrill];
      }
    }];
  }
}

#define MONEY_TREE_ANIM_TAG 999

- (void) beginAnimationsInReverse:(BOOL)reverse {
  CCAnimation *hole = reverse ? _holeAnim.reversedAnimation : _holeAnim;
  CCAnimation *drill = reverse ? _drillAnim.reversedAnimation : _drillAnim;
  CCAnimation *base = reverse ? _baseAnim.reversedAnimation : _baseAnim;
  
  CCActionRepeatForever *repeat = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:hole]];
  repeat.tag = MONEY_TREE_ANIM_TAG;
  [_holeSprite runAction:repeat];
  
  repeat = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:drill]];
  repeat.tag = MONEY_TREE_ANIM_TAG;
  [_drillSprite runAction:repeat];
  
  repeat = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:base]];
  repeat.tag = MONEY_TREE_ANIM_TAG;
  [_baseSprite runAction:repeat];
}

- (void) stopAnimations {
  [_holeSprite stopActionByTag:MONEY_TREE_ANIM_TAG];
  [_drillSprite stopActionByTag:MONEY_TREE_ANIM_TAG];
  [_baseSprite stopActionByTag:MONEY_TREE_ANIM_TAG];
}

- (void) animateDrill {
  [self beginAnimationsInReverse:NO];
  
  CGPoint origPos = _drillSprite.position;
  CGPoint botPos = ccpAdd(origPos, ccp(0, -10));
  
  // Shake anim
  NSMutableArray *moves = [NSMutableArray array];
  int numTimes = 60;
  for (int i = 0; i < numTimes; i++) {
    int signX = arc4random() % 2 ? 1 : -1;
    int signY = arc4random() % 2 ? 1 : -1;
    CGPoint pt = ccp(drand48()*0.7*signX, drand48()*0.7*signY);
    CCActionMoveTo *move = [CCActionMoveTo actionWithDuration:0.03f position:ccpAdd(pt, botPos)];
    [moves addObject:move];
  }
  CCActionMoveTo *move = [CCActionMoveTo actionWithDuration:0.03f position:botPos];
  [moves addObject:move];
  
  CCActionSequence *seq = [CCActionSequence actionWithArray:moves];
  
  [_drillSprite runAction:[CCActionSequence actions:
                           [CCActionMoveTo actionWithDuration:3.f position:botPos],
                           [CCActionCallFunc actionWithTarget:self selector:@selector(stopAnimations)],
                           [CCActionCallBlock actionWithBlock:
                            ^{
                              [_smoke resetSystem];
                            }],
                           seq,
                           [CCActionCallBlock actionWithBlock:
                            ^{
                              [_smoke stopSystem];
                              [self beginAnimationsInReverse:YES];
                            }],
                           [CCActionMoveTo actionWithDuration:3.f position:origPos],
                           [CCActionCallFunc actionWithTarget:self selector:@selector(stopAnimations)],
                           [CCActionDelay actionWithDuration:1.],
                           [CCActionCallFunc actionWithTarget:self selector:@selector(animateDrill)], nil]];
}

- (id) initWithUserStruct:(UserStruct *)userStruct map:(HomeMap *)map {
  StructureInfoProto *fsp = userStruct.staticStruct.structInfo;
  CGRect loc = CGRectMake(userStruct.coordinates.x, userStruct.coordinates.y, fsp.width, fsp.height);
  if ((self = [self initWithFile:[self fileNameForUserStruct:userStruct] location:loc map:map])) {
    self.userStruct = userStruct;
    self.orientation = self.userStruct.orientation;
    
    [self adjustBuildingSprite];
  }
  return self;
}

- (void) initializeRetrieveBubble {
  float pxlOffset = 11;
  
  NSString *fileName = @"gemready.png";
  
  if (!_retrieveBubble || ![_retrieveBubble.name isEqualToString:fileName]) {
    // Make sure to cleanup just in case
    [_retrieveBubble removeFromParent];
    
    _retrieveBubble = [CCButton buttonWithTitle:nil spriteFrame:[CCSpriteFrame frameWithImageNamed:fileName] highlightedSpriteFrame:nil disabledSpriteFrame:nil];
    [_retrieveBubble setTarget:self selector:@selector(select)];
    [self addChild:_retrieveBubble z:1 name:fileName];
    _retrieveBubble.anchorPoint = ccp(0.5, 0);
    _retrieveBubble.position = ccp(self.contentSize.width/2,self.contentSize.height-pxlOffset);
  }
}

- (BOOL) select {
  if (self.retrievable) {
    [_homeMap retrieveFromMoneyTree:self];
    
    return NO;
  } else {
    return [super select];
  }
}

@end

@implementation ResourceStorageBuilding

- (void) setupBuildingSprite:(NSString *)fileName {
  [self.buildingSprite removeFromParent];
  self.buildingSprite = nil;
  
  fileName = fileName.stringByDeletingPathExtension;
  
  NSString *spritesheetName = [NSString stringWithFormat:@"%@.plist", fileName];
  [Globals checkAndLoadSpriteSheet:spritesheetName completion:^(BOOL success) {
    if (success) {
      [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:spritesheetName];
      self.anim = [CCAnimation animationWithSpritePrefix:fileName delay:2.];
      
      self.buildingSprite = [CCSprite spriteWithSpriteFrame:[self.anim.frames[0] spriteFrame]];
      [self addChild:self.buildingSprite];
      
      [self adjustBuildingSprite];
    }
  }];
}

- (void) setPercentage:(float)percentage {
  percentage = clampf(percentage, 0.f, 1.f);
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
  self.buildingSprite = nil;
  
  NSString *spritesheetName = [NSString stringWithFormat:@"%@.plist", fileName];
  [Globals checkAndLoadSpriteSheet:spritesheetName completion:^(BOOL success) {
    if (success) {
      [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:spritesheetName];
      CCAnimation *anim = [CCAnimation animationWithSpritePrefix:[NSString stringWithFormat:@"%@Base", fileName] delay:0.1];
      [anim repeatFrames:NSMakeRange(0,1) numTimes:5];
      self.baseAnimation = anim;
      
      if (anim.frames.count) {
        self.buildingSprite = [CCSprite spriteWithSpriteFrame:[anim.frames[0] spriteFrame]];
        [self addChild:self.buildingSprite];
      }
      
      anim = [CCAnimation animationWithSpritePrefix:[NSString stringWithFormat:@"%@Tube", fileName] delay:0.1];
      [anim repeatFrames:NSMakeRange(0,1) numTimes:5];
      self.tubeAnimation = anim;
      
      if (anim.frames.count) {
        self.tubeSprite = [CCSprite spriteWithSpriteFrame:[anim.frames[0] spriteFrame]];
        self.tubeSprite.position = ccp(self.buildingSprite.contentSize.width/2, self.buildingSprite.contentSize.height/2);
        [self.buildingSprite addChild:self.tubeSprite z:2];
      }
      
      [self adjustBuildingSprite];
      
      if (_healingItem) {
        [self beginAnimatingWithHealingItem:_healingItem];
      }
    }
  }];
}

- (void) beginAnimatingWithHealingItem:(UserMonsterHealingItem *)hi {
  [self stopAnimating];
  [self.monsterSprite removeFromParent];
  self.monsterSprite = nil;
  
  [self.buildingSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:self.baseAnimation]]];
  [self.tubeSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:self.tubeAnimation]]];
  
  _healingItem = hi;
  if (hi) {
    GameState *gs = [GameState sharedGameState];
    UserMonster *um = [gs myMonsterWithUserMonsterUuid:hi.userMonsterUuid];
    MonsterProto *mp = [gs monsterWithId:um.monsterId];
    
    NSString *spritesheetName = [NSString stringWithFormat:@"%@AttackNF.plist", mp.imagePrefix];
    [Globals checkAndLoadSpriteSheet:spritesheetName completion:^(BOOL success) {
      if (success && _healingItem == hi) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:spritesheetName];
        NSString *file = [NSString stringWithFormat:@"%@AttackN00.png", mp.imagePrefix];
        if ([[CCSpriteFrameCache sharedSpriteFrameCache] containsFrame:file]) {
          // Re-remove monster sprite just in case
          [self.monsterSprite removeFromParent];
          
          self.monsterSprite = [CCSprite spriteWithImageNamed:file];
          self.monsterSprite.anchorPoint = ccp(0.5, 0);
          self.monsterSprite.scale = 0.8;
          self.monsterSprite.position = ccpAdd(ccp(self.buildingSprite.contentSize.width/2, -5), ccp(0, mp.verticalPixelOffset));
          self.monsterSprite.flipX = YES;
          [self.buildingSprite addChild:self.monsterSprite z:1];
        }
      }
    }];
    
    [self displayProgressBar];
  }
}

- (void) displayProgressBar {
  [super displayProgressBar];
  
  if (_healingItem) {
    MiniMonsterViewSprite *spr = [MiniMonsterViewSprite spriteWithMonsterId:_healingItem.userMonster.monsterId];
    [self.progressBar addChild:spr];
    spr.position = ccp(-spr.contentSize.width/2-4.f, self.progressBar.contentSize.height/2+1.f);
  }
}

- (void) stopAnimating {
  [self.monsterSprite removeFromParent];
  
  [self.buildingSprite stopAllActions];
  [self.tubeSprite stopAllActions];
  
  if (self.baseAnimation.frames.count) {
    [self.buildingSprite setSpriteFrame:[self.baseAnimation.frames[0] spriteFrame]];
    [self.tubeSprite setSpriteFrame:[self.tubeAnimation.frames[0] spriteFrame]];
  }
  
  if (!self.isConstructing) {
    [self removeProgressBar];
  }
  _healingItem = nil;
}

- (BOOL) isFreeSpeedup {
  if (_healingItem) {
    // Check the entire healing queue to see if it can be sped up for free
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    HospitalQueue *hq = [gs hospitalQueueForUserHospitalStructUuid:self.userStruct.userStructUuid];
    int timeLeft = hq.queueEndTime.timeIntervalSinceNow;
    int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
    return gemCost == 0;
  } else {
    return [super isFreeSpeedup];
  }
}

- (NSString *) progressBarPrefix {
  if (_healingItem) {
    if (![self isFreeSpeedup]) {
      return @"obtimergreen";
    } else {
      return @"obtimerpurple";
    }
  } else {
    return [super progressBarPrefix];
  }
}

- (void) updateProgressBar {
  if (_healingItem) {
    UpgradeProgressBar *bar = self.progressBar;
    
    // Check the prefix
    NSString *prefix = [self progressBarPrefix];
    if ([bar.prefix isEqualToString:prefix]) {
      NSTimeInterval time = _healingItem.endTime.timeIntervalSinceNow;
      [bar updateTimeLabel:time];
      [bar updateForPercentage:_healingItem.currentPercentage];
      
      if ([self isFreeSpeedup]) {
        [self.progressBar animateFreeLabel];
      }
    } else {
      [self displayProgressBar];
    }
  } else {
    [super updateProgressBar];
  }
}

@end

@implementation ItemFactoryBuilding

- (void) setupBuildingSprite:(NSString *)fileName {
  fileName = fileName.stringByDeletingPathExtension;
  
  [self.buildingSprite removeFromParent];
  self.buildingSprite = nil;
  
  NSString *spritesheetName = [NSString stringWithFormat:@"%@.plist", fileName];
  [Globals checkAndLoadSpriteSheet:spritesheetName completion:^(BOOL success) {
    if (success) {
      [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:spritesheetName];
      
      self.buildingSprite = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"%@Base00.png", fileName]];
      [self addChild:self.buildingSprite];
      
      CCAnimation *anim = [CCAnimation animationWithSpritePrefix:[NSString stringWithFormat:@"%@Roof", fileName] delay:0.1];
      [anim repeatFrames:NSMakeRange(0,1) numTimes:5];
      self.spriteAnimation = anim;
      
      if (anim.frames.count) {
        self.animSprite = [CCSprite spriteWithSpriteFrame:[anim.frames[0] spriteFrame]];
        self.animSprite.position = ccp(self.buildingSprite.contentSize.width/2, self.buildingSprite.contentSize.height/2);
        [self.buildingSprite addChild:self.animSprite z:2];
      }
      
      [self adjustBuildingSprite];
      
      if (_battleItemQueueObject) {
        [self beginAnimatingWithBattleItemQueueObject:_battleItemQueueObject];
      }
    }
  }];
}

- (void) beginAnimatingWithBattleItemQueueObject:(BattleItemQueueObject *)hi {
  [self stopAnimating];
  
  [self.animSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:self.spriteAnimation]]];
  
  _battleItemQueueObject = hi;
  if (hi) {
    [self displayProgressBar];
    
    MiniMonsterViewSprite *spr = [MiniMonsterViewSprite spriteWithElement:ElementWater imageName:_battleItemQueueObject.staticBattleItem.imgName];
    [self.progressBar addChild:spr];
    spr.position = ccp(-spr.contentSize.width/2-4.f, self.progressBar.contentSize.height/2+1.f);
  }
}

- (void) stopAnimating {
  [self.animSprite stopAllActions];
  
  if (self.spriteAnimation.frames.count) {
    [self.animSprite setSpriteFrame:[self.spriteAnimation.frames[0] spriteFrame]];
  }
  
  if (!self.isConstructing) {
    [self removeProgressBar];
  }
  _battleItemQueueObject = nil;
}

- (BOOL) isFreeSpeedup {
  if (_battleItemQueueObject) {
    // Check the entire healing queue to see if it can be sped up for free
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    BattleItemQueue *hq = gs.battleItemUtil.battleItemQueue;
    int timeLeft = hq.queueEndTime.timeIntervalSinceNow;
    int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
    return gemCost == 0;
  } else {
    return [super isFreeSpeedup];
  }
}

- (NSString *) progressBarPrefix {
  if (_battleItemQueueObject) {
    if (![self isFreeSpeedup]) {
      return @"obtimergreen";
    } else {
      return @"obtimerpurple";
    }
  } else {
    return [super progressBarPrefix];
  }
}

- (void) updateProgressBar {
  if (_battleItemQueueObject) {
    UpgradeProgressBar *bar = self.progressBar;
    
    // Check the prefix
    NSString *prefix = [self progressBarPrefix];
    if ([bar.prefix isEqualToString:prefix]) {
      NSTimeInterval time = _battleItemQueueObject.expectedEndTime.timeIntervalSinceNow;
      [bar updateTimeLabel:time];
      [bar updateForPercentage:1.f-time/_battleItemQueueObject.totalSecondsToComplete];
      
      if ([self isFreeSpeedup]) {
        [self.progressBar animateFreeLabel];
      }
    } else {
      [self displayProgressBar];
    }
  } else {
    [super updateProgressBar];
  }
}

@end

@implementation TownHallBuilding

@end

@implementation ResidenceBuilding

@end

@implementation ClanHouseBuilding

@end

@implementation LabBuilding

//- (id) initWithUserStruct:(UserStruct *)userStruct map:(HomeMap *)map {
//  if ((self = [super initWithUserStruct:userStruct map:map])) {
//    [self beginAnimating];
//  }
//  return self;
//}
//
//- (void) setupBuildingSprite:(NSString *)fileName {
//  [self.buildingSprite removeFromParent];
//
//  fileName = fileName.stringByDeletingPathExtension;
//  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@.plist", fileName]];
//  self.anim = [CCAnimation animationWithSpritePrefix:fileName delay:0.1];
//
//  self.buildingSprite = [CCSprite spriteWithSpriteFrame:[self.anim.frames[0] spriteFrame]];
//  [self addChild:self.buildingSprite];
//
//  [self adjustBuildingSprite];
//}
//

- (void) beginAnimatingWithEnhancement:(UserEnhancement *)ue {
  [self stopAnimating];
  
  _enhancement = ue;
  //[self.buildingSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:self.anim]]];
  if (ue.feeders.count) {
    [self displayProgressBar];
    
    EnhancementItem *ei = ue.baseMonster;
    int monsterId = ei.userMonster.monsterId;
    if (monsterId) {
      MiniMonsterViewSprite *spr = [MiniMonsterViewSprite spriteWithMonsterId:ei.userMonster.monsterId];
      [self.progressBar addChild:spr];
      spr.position = ccp(-spr.contentSize.width/2-4.f, self.progressBar.contentSize.height/2+1.f);
    }
  }
}

- (void) stopAnimating {
  _enhancement = nil;
  //  [self.buildingSprite stopAllActions];
  //  [self.buildingSprite setSpriteFrame:[self.anim.frames[0] spriteFrame]];
  
  if (!self.isConstructing) {
    [self removeProgressBar];
  }
}

- (BOOL) isFreeSpeedup {
  if (self.isConstructing) {
    return [super isFreeSpeedup];
  } else {
    Globals *gl = [Globals sharedGlobals];
    NSTimeInterval timeLeft = _enhancement.expectedEndTime.timeIntervalSinceNow;
    int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
    return gemCost == 0;
  }
}

- (NSString *) progressBarPrefix {
  if (self.isConstructing) {
    return [super progressBarPrefix];
  } else {
    if (![self isFreeSpeedup]) {
      return @"obtimergreen";
    } else {
      return @"obtimerpurple";
    }
  }
}

- (void) updateProgressBar {
  if (self.isConstructing) {
    [super updateProgressBar];
  } else {
    UpgradeProgressBar *bar = self.progressBar;
    
    // Check the prefix
    NSString *prefix = [self progressBarPrefix];
    if ([bar.prefix isEqualToString:prefix]) {
      NSTimeInterval time = _enhancement.expectedEndTime.timeIntervalSinceNow;
      NSTimeInterval totalSecs = [_enhancement totalSeconds];
      [self.progressBar updateForSecsLeft:time totalSecs:totalSecs];
      
      if ([self isFreeSpeedup]) {
        [self.progressBar animateFreeLabel];
      }
    } else {
      [self displayProgressBar];
    }
  }
}

@end

@implementation EvoBuilding

- (void) beginAnimatingWithEvolution:(UserEvolution *)ue {
  [self stopAnimating];
  _evolution = ue;
  //[self.buildingSprite runAction:[CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:self.anim]]];
  
  if (ue) {
    [self displayProgressBar];
    
    MiniMonsterViewSprite *spr = [MiniMonsterViewSprite spriteWithMonsterId:_evolution.evoItem.userMonster1.monsterId];
    [self.progressBar addChild:spr];
    spr.position = ccp(-spr.contentSize.width/2-4.f, self.progressBar.contentSize.height/2+1.f);
  }
}

- (void) stopAnimating {
  //  [self.buildingSprite stopAllActions];
  
  if (!self.isConstructing) {
    [self removeProgressBar];
  }
  
  _evolution = nil;
}

- (BOOL) isFreeSpeedup {
  if (self.isConstructing) {
    return [super isFreeSpeedup];
  } else {
    Globals *gl = [Globals sharedGlobals];
    NSTimeInterval timeLeft = _evolution.endTime.timeIntervalSinceNow;
    int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
    return gemCost == 0;
  }
}

- (NSString *) progressBarPrefix {
  if (self.isConstructing) {
    return [super progressBarPrefix];
  } else {
    if (![self isFreeSpeedup]) {
      return @"obtimergreen";
    } else {
      return @"obtimerpurple";
    }
  }
}

- (void) updateProgressBar {
  if (self.isConstructing) {
    [super updateProgressBar];
  } else {
    UpgradeProgressBar *bar = self.progressBar;
    
    // Check the prefix
    NSString *prefix = [self progressBarPrefix];
    if ([bar.prefix isEqualToString:prefix]) {
      NSTimeInterval time = _evolution.endTime.timeIntervalSinceNow;
      NSTimeInterval totalSecs = [_evolution.endTime timeIntervalSinceDate:_evolution.startTime];
      [self.progressBar updateForSecsLeft:time totalSecs:totalSecs];
      
      if ([self isFreeSpeedup]) {
        [self.progressBar animateFreeLabel];
      }
    } else {
      [self displayProgressBar];
    }
  }
}

@end

@implementation ResearchBuilding

- (void) beginAnimatingWithUserResearch:(UserResearch *)userResearch {
  [self stopAnimating];
  
  _userResearch = userResearch;
  
  if (userResearch) {
    [self displayProgressBar];
    
    MiniResearchViewSprite *spr = [MiniResearchViewSprite spriteWithResearchProto:_userResearch.staticResearch];
    [self.progressBar addChild:spr];
    spr.position = ccp(-spr.contentSize.width/2-2.f, self.progressBar.contentSize.height/2+1.f);
  }
}

- (void) stopAnimating {
  _userResearch = nil;
  
  if (!self.isConstructing) {
    [self removeProgressBar];
  }
}

- (BOOL) isFreeSpeedup {
  if (self.isConstructing) {
    return [super isFreeSpeedup];
  } else {
    Globals *gl = [Globals sharedGlobals];
    NSTimeInterval timeLeft = _userResearch.tentativeCompletionDate.timeIntervalSinceNow;
    int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
    return gemCost == 0;
  }
}

- (NSString *) progressBarPrefix {
  if (self.isConstructing) {
    return [super progressBarPrefix];
  } else {
    if (![self isFreeSpeedup]) {
      return @"obtimergreen";
    } else {
      return @"obtimerpurple";
    }
  }
}

- (void) updateProgressBar {
  if (self.isConstructing) {
    [super updateProgressBar];
  } else {
    UpgradeProgressBar *bar = self.progressBar;
    
    // Check the prefix
    NSString *prefix = [self progressBarPrefix];
    if ([bar.prefix isEqualToString:prefix]) {
      Globals *gl = [Globals sharedGlobals];
      
      NSTimeInterval time = _userResearch.tentativeCompletionDate.timeIntervalSinceNow;
      NSTimeInterval totalSecs = [gl calculateSecondsToResearch:_userResearch.staticResearch];
      [self.progressBar updateForSecsLeft:time totalSecs:totalSecs];
      
      if ([self isFreeSpeedup]) {
        [self.progressBar animateFreeLabel];
      }
    } else {
      [self displayProgressBar];
    }
  }
}

@end

@implementation MiniJobCenterBuilding

//- (BOOL) canMove {
//  return NO;
//}

- (void) updateForActiveMiniJob:(UserMiniJob *)activeMiniJob {
  if (self.isConstructing) {
    return;
  }
  
  self.activeMiniJob = activeMiniJob;
  
  [self.statusSprite removeFromParent];
  self.statusSprite = nil;
  
  [self removeProgressBar];
  
  // This should pretty much never be called for the arrow anymore, since we are using bubbles now
  // So, only the displayProgressBar call is practical.
  CCSprite *arrow = nil;
  if (activeMiniJob.timeCompleted) {
    arrow = [CCSprite spriteWithImageNamed:@"mjdone.png"];
  } else if (activeMiniJob.timeStarted) {
    [self displayProgressBar];
  } else if (activeMiniJob) {
    arrow = [CCSprite spriteWithImageNamed:@"mjnew.png"];
  }
  
  if (arrow) {
    self.statusSprite = [CCSprite spriteWithImageNamed:@"dockshadow.png"];
    [self.statusSprite addChild:arrow];
    arrow.anchorPoint = ccp(0.5, 0);
    arrow.position = ccp(self.statusSprite.contentSize.width/2, self.statusSprite.contentSize.height/2);
    
    [self addChild:self.statusSprite z:5];
    self.statusSprite.anchorPoint = ccp(0.5, 0);
    self.statusSprite.position = ccp(self.contentSize.width/2-2, self.contentSize.height/2-10);
    
    [arrow runAction:
     [CCActionRepeatForever actionWithAction:
      [CCActionSequence actions:
       [CCActionJumpBy actionWithDuration:0.7 position:ccp(0,0) height:10.f jumps:1], nil]]];
  }
}

- (void) setIsConstructing:(BOOL)isConstructing {
  if (!isConstructing) {
    [super setIsConstructing:isConstructing];
    [self updateForActiveMiniJob:self.activeMiniJob];
  } else {
    [self.statusSprite removeFromParent];
    self.statusSprite = nil;
    _isConstructing = isConstructing;
  }
}

- (BOOL) isFreeSpeedup {
  if (self.isConstructing) {
    return [super isFreeSpeedup];
  } else {
    Globals *gl = [Globals sharedGlobals];
    MSDate *endDate = self.activeMiniJob.tentativeCompletionDate;
    NSTimeInterval timeLeft = endDate.timeIntervalSinceNow;
    int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
    return gemCost == 0;
  }
}

- (NSString *) progressBarPrefix {
  if (self.isConstructing) {
    return [super progressBarPrefix];
  } else {
    if (![self isFreeSpeedup]) {
      return @"obtimergreen";
    } else {
      return @"obtimerpurple";
    }
  }
}

- (void) updateProgressBar {
  if (self.isConstructing) {
    [super updateProgressBar];
  } else {
    UpgradeProgressBar *bar = self.progressBar;
    
    // Check the prefix
    NSString *prefix = [self progressBarPrefix];
    if ([bar.prefix isEqualToString:prefix]) {
      float dur = self.activeMiniJob.durationSeconds;
      MSDate *endDate = self.activeMiniJob.tentativeCompletionDate;
      [bar updateForSecsLeft:endDate.timeIntervalSinceNow totalSecs:dur];
      
      if ([self isFreeSpeedup]) {
        [self.progressBar animateFreeLabel];
      }
    } else {
      [self displayProgressBar];
    }
  }
}

- (void) displayProgressBar {
  [super displayProgressBar];
  
  CCNode *n = self.progressBar;
  
  // Since we're not using pier anymore, this isn't necessary
  //  n.position = ccp(self.contentSize.width/2, self.contentSize.height/2+15);
  
  if (!self.isConstructing && self.activeMiniJob) {
    NSString *rarityStr = [@"battle" stringByAppendingString:[Globals imageNameForRarity:self.activeMiniJob.miniJob.quality suffix:@"tag.png"]];
    CCSprite *rarityTag = [CCSprite spriteWithImageNamed:rarityStr];
    [n addChild:rarityTag];
    rarityTag.position = ccp(n.contentSize.width/2-2, n.contentSize.height+rarityTag.contentSize.height/2+10);
  }
}

//- (void) setBubbleType:(BuildingBubbleType)bubbleType withNum:(int)num {
//  [super setBubbleType:bubbleType withNum:num];
//  _bubble.position = ccp(self.contentSize.width/2-3, self.contentSize.height/2+3);
//}

//- (BOOL) isExemptFromReorder {
//  return YES;
//}

@end

@implementation TeamCenterBuilding

- (void) setupBuildingSprite:(NSString *)fileName {
  [self.buildingSprite removeFromParent];
  
  fileName = fileName.stringByDeletingPathExtension;
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@.plist", fileName]];
  self.anim = [CCAnimation animationWithSpritePrefix:fileName delay:2.];
  
  self.buildingSprite = [CCSprite spriteWithSpriteFrame:[self.anim.frames[0] spriteFrame]];
  [self addChild:self.buildingSprite];
  
  [self adjustBuildingSprite];
}

- (void) setNumEquipped:(int)num {
  int imgNum = clampf(num, 0, self.anim.frames.count-1);
  CCSpriteFrame *frame = [self.anim.frames[imgNum] spriteFrame];
  [self.buildingSprite setSpriteFrame:frame];
}

@end
