//
//  Building.m
//  IsoMap
//
//  Created by Ashwin Kamath on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Building.h"
#import "GameLayer.h"
#import "GameMap.h"
#import "HomeMap.h"
#import "GameState.h"
#import "Globals.h"
#import "HomeBuildingMenus.h"
#import "CCAnimation+SpriteLoading.h"

#define CONSTRUCTION_TAG 49

@implementation Building

@synthesize orientation;
@synthesize verticalOffset;

- (void) setOrientation:(StructOrientation)o {
  orientation = o % 2;
  switch (orientation) {
    case StructOrientationPosition1:
      self.flipX = NO;
      break;
      
    case StructOrientationPosition2:
      self.flipX = YES;
      break;
      
    default:
      break;
  }
}

- (void) setLocation:(CGRect)location {
  [super setLocation:location];
  self.position = ccpAdd(self.position, ccp(0,self.verticalOffset));
}

- (void) setVerticalOffset:(float)v {
  if (v != verticalOffset) {
    verticalOffset = v;
    self.location = self.location;
  }
}

#define UPGRADING_TAG 123

- (void) displayProgressBar {
  if (![self getChildByTag:UPGRADING_TAG]) {
    UpgradeProgressBar *upgrIcon = [[UpgradeProgressBar alloc] initBar];
    [self addChild:upgrIcon z:1 tag:UPGRADING_TAG];
    upgrIcon.position = ccp(self.contentSize.width/2, self.contentSize.height);
    [self schedule:@selector(updateUpgradeBar) interval:1.f];
    
    _percentage = 0;
    [self updateUpgradeBar];
  }
}

- (void) updateUpgradeBar {
  
}

- (void) removeProgressBar {
  [self removeChildByTag:UPGRADING_TAG cleanup:YES];
  [self unschedule:@selector(updateUpgradeBar)];
}

- (void) instaFinishUpgradeWithCompletionBlock:(void(^)(void))completed {
  CCNode *n = [self getChildByTag:UPGRADING_TAG];
  if (n && [n isKindOfClass:[UpgradeProgressBar class]]) {
    UpgradeProgressBar *u = (UpgradeProgressBar *)n;
    [self unschedule:@selector(updateUpgradeBar)];
    
    float interval = 1;
    float timestep = 0.02;
    _percentage = u.progressBar.percentage;
    int numTimes = (100-_percentage)/interval;
    CCCallBlock *b = [CCCallBlock actionWithBlock:^{
      _percentage += interval;
      [self updateUpgradeBar];
    }];
    CCSequence *cycle = [CCSequence actions:b, [CCDelayTime actionWithDuration:timestep], nil];
    CCRepeat *r = [CCRepeat actionWithAction:cycle times:numTimes];
    [u runAction:
     [CCSequence actions:
      r,
      [CCCallBlock actionWithBlock:
       ^{
         _percentage = 100;
         [self updateUpgradeBar];
         
         [self removeProgressBar];
         if (completed) {
           completed();
         }
       }],
      nil]];
  }
}

@end

@implementation HomeBuilding

@synthesize startTouchLocation = _startTouchLocation;
@synthesize isSetDown = _isSetDown;
@synthesize isConstructing = _isConstructing;

+ (id) homeWithFile: (NSString *) file location: (CGRect) loc map: (HomeMap *) map {
  return [[self alloc] initWithFile:file location:loc map:map];
}

- (id) initWithFile: (NSString *) file location: (CGRect)loc map: (HomeMap *) map {
  if ((self = [super initWithFile:file location:loc map:map])) {
    _homeMap = map;
    [self placeBlock];
    
  }
  return self;
}

- (void) setIsSelected:(BOOL)isSelected {
  [super setIsSelected:isSelected];
  if (isSelected) {
    _startMoveCoordinate = _location.origin;
    _startOrientation = self.orientation;
    [self displayMoveArrows];
  } else {
    if (!_isSetDown && !_isPurchasing) {
      [self cancelMove];
    }
    [self removeMoveArrows];
  }
}

- (void) setOpacity:(GLubyte)opacity {
  if (_isConstructing) {
    CCSprite *sprite = (CCSprite *)[self getChildByTag:CONSTRUCTION_TAG];
    sprite.opacity = opacity;
  } else {
    [super setOpacity:opacity];
  }
}

//- (CGSize) contentSize {
//  CCNode *spr = [self getChildByTag:CONSTRUCTION_TAG];
//  if (spr) {
//    return spr.contentSize;
//  }
//  return [super contentSize];
//}

- (void) setIsConstructing:(BOOL)isConstructing {
  if (_isConstructing != isConstructing) {
    if (isConstructing) {
      [self setOpacity:1];
      _isConstructing = isConstructing;
      
//      [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Construction.plist"];
//      CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"Construction.png"];
//      sprite.anchorPoint = ccp(0.462, 0.165);
//      sprite.position = ccp(self.contentSize.width/2, -self.verticalOffset-2);
//      [self addChild:sprite z:1 tag:CONSTRUCTION_TAG];
//      
//      CCAnimation *anim = [CCAnimation animationWithSpritePrefix:@"Construction" delay:1];
//      CCSprite *spr = [CCSprite spriteWithSpriteFrame:[[anim.frames objectAtIndex:0] spriteFrame]];
//      [spr runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:anim]]];
//      [sprite addChild:spr];
//      spr.position = ccp(sprite.contentSize.width/2, sprite.contentSize.height/2);
    } else {
      _isConstructing = isConstructing;
      self.opacity = 255;
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
  sprite = sprite ? sprite : self;
  
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
  sprite = sprite ? sprite : self;
  
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

@end

@implementation MoneyBuilding

@synthesize userStruct = _userStruct;
@synthesize retrievable = _retrievable;
@synthesize timer = _timer;

- (void) initializeRetrieveBubble {
  if (_retrieveBubble) {
    // Make sure to cleanup just in case
    [self removeChild:_retrieveBubble cleanup:YES];
  }
  _retrieveBubble = [CCSprite spriteWithFile:@"silverover.png"];
  [self addChild:_retrieveBubble];
  _retrieveBubble.position = ccp(self.contentSize.width/2,self.contentSize.height-OVER_HOME_BUILDING_MENU_OFFSET);
}

- (void) setIsSelected:(BOOL)isSelected {
  [super setIsSelected:isSelected];
  if (self.userStruct.state == kWaitingForIncome || self.userStruct.state == kRetrieving) {
    if (isSelected) {
      [self displayProgressBar];
    } else {
      [self removeProgressBar];
    }
  }
}

- (void) setUserStruct:(UserStruct *)userStruct {
  if (_userStruct != userStruct) {
    _userStruct = userStruct;
    
    // Re-set location
    if (userStruct) {
      FullStructureProto *fsp = [[GameState sharedGameState] structWithId:userStruct.structId];
      self.verticalOffset = fsp.imgVerticalPixelOffset;
    }
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

- (void) updateUpgradeBar {
  CCNode *n = [self getChildByTag:UPGRADING_TAG];
  if (n && [n isKindOfClass:[UpgradeProgressBar class]]) {
    UpgradeProgressBar *bar = (UpgradeProgressBar *)n;
    Globals *gl = [Globals sharedGlobals];
    FullStructureProto *fsp = [[GameState sharedGameState] structWithId:self.userStruct.structId];
    
    NSTimeInterval time = 0.f;
    int totalTime = 1;
    switch (self.userStruct.state) {
      case kUpgrading:
        totalTime = [gl calculateMinutesToUpgrade:self.userStruct]*60;
        time = [[NSDate dateWithTimeInterval:totalTime sinceDate:self.userStruct.lastUpgradeTime] timeIntervalSinceNow];
        break;
        
      case kBuilding:
        totalTime = fsp.minutesToBuild*60;
        time = [[NSDate dateWithTimeInterval:totalTime sinceDate:self.userStruct.purchaseTime] timeIntervalSinceNow];
        break;
        
      case kWaitingForIncome:
        totalTime = fsp.minutesToGain*60;
        time = [[NSDate dateWithTimeInterval:totalTime sinceDate:self.userStruct.lastRetrieved] timeIntervalSinceNow];
        
      default:
        break;
    }
    
    if (_percentage) {
      time = totalTime*(100.f-_percentage)/100.f;
    }
    
    [bar updateForSecsLeft:(int)time totalSecs:totalTime];
  }
}

- (void) displayUpgradeComplete {
  CCSprite *spinner = [CCSprite spriteWithFile:@"buildingspinner.png"];
  CCLabelTTF *label = [CCLabelTTF labelWithString:@"Building Upgraded!" fontName:[Globals font] fontSize:22.f];
  
  [self addChild:spinner z:-1];
  [self addChild:label];
  
  spinner.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
  label.position = ccp(self.contentSize.width/2, self.contentSize.height + 10);
  
  label.color = ccc3(255, 200, 0);
  
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

- (void) setTimer:(NSTimer *)timer {
  if (_timer != timer) {
    [_timer invalidate];
    _timer = timer;
  }
}

- (void) createTimerForCurrentState {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:self.userStruct.structId];
  Globals *gl = [Globals sharedGlobals];
  
  UserStructState st = self.userStruct.state;
  NSTimeInterval time;
  SEL selector = nil;
  switch (st) {
    case kUpgrading:
      time = [[NSDate dateWithTimeInterval:[gl calculateMinutesToUpgrade:self.userStruct]*60 sinceDate:self.userStruct.lastUpgradeTime] timeIntervalSinceNow];
      selector = @selector(upgradeComplete:);
      break;
      
    case kBuilding:
      time = [[NSDate dateWithTimeInterval:fsp.minutesToBuild*60 sinceDate:self.userStruct.purchaseTime] timeIntervalSinceNow];
      selector = @selector(buildComplete:);
      break;
      
    case kWaitingForIncome:
      time = [[NSDate dateWithTimeInterval:fsp.minutesToGain*60 sinceDate:self.userStruct.lastRetrieved] timeIntervalSinceNow];
      selector = @selector(waitForIncomeComplete:);
      break;
      
    case kRetrieving:
      self.retrievable = YES;
      break;
      
    default:
      break;
  }
  
  if (selector) {
    self.timer = [NSTimer timerWithTimeInterval:time target:_homeMap selector:selector userInfo:self repeats:NO];
  } else {
    self.timer = nil;
  }
}

- (void) dealloc {
  self.timer = nil;
}

@end

@implementation MissionBuilding

@synthesize ftp, numTimesActedForTask, numTimesActedForQuest, name, partOfQuest;

- (void) setIsSelected:(BOOL)isSelected {
  [super setIsSelected:isSelected];
  if (isSelected) {
    [Analytics taskViewed:ftp.taskId];
  } else {
    [Analytics taskClosed:ftp.taskId];
  }
}

@end

@implementation ExpansionBoard

- (id) initWithExpansionBlock:(CGPoint)block location:(CGRect)location map:(GameMap *)map isExpanding:(BOOL)isExpanding {
  int blockSum = abs(block.x)+abs(block.y);
  NSString *file = blockSum == 2 ? @"leftrightexpand.png" : @"wide.png";
  if ((self = [super initWithFile:file location:location map:map])) {
    if (block.y == 0 || (block.x == 1 && block.y == -1)) {
      self.flipX = YES;
    } else if (block.x == -1 && block.y == -1) {
      self.flipY = YES;
      self.color = ccc3(0, 0, 0);
    }
    self.expandSpot = block;
  }
  return self;
}

- (BOOL) isExemptFromReorder {
  return YES;
}

- (BOOL) isPointInArea:(CGPoint)pt {
  pt = [_map convertToNodeSpace:pt];
  
  CGPoint tilePt = [_map convertCCPointToTilePoint:pt];
  return CGRectContainsPoint(self.location, tilePt);
}

- (void) beginExpanding {
  CGPoint pt =  ccp(CENTER_TILE_X-1, CENTER_TILE_Y-1);
  pt.x += self.expandSpot.x*(EXPANSION_MID_SQUARE_SIZE/2+EXPANSION_ROAD_SIZE+EXPANSION_BLOCK_SIZE/2);
  pt.y += self.expandSpot.y*(EXPANSION_MID_SQUARE_SIZE/2+EXPANSION_ROAD_SIZE+EXPANSION_BLOCK_SIZE/2);
  pt = [_map convertTilePointToCCPoint:pt];
  pt = [self convertToNodeSpace:[_map convertToWorldSpace:pt]];
  CCSprite *s = [CCSprite spriteWithFile:@"expand.png"];
  [self addChild:s];
  s.anchorPoint = ccp(0.7, 0);
  s.position = pt;//ccp(self.contentSize.width/2-12, self.contentSize.height/2+6);
  
  [self displayProgressBar];
  CCNode *n = [self getChildByTag:UPGRADING_TAG];
  n.position = ccpAdd(s.position, ccp(0, s.contentSize.height-5));
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