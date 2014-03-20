
//
//  GameMap.m
//  IsoMap
//
//  Created by Ashwin Kamath on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GameMap.h"
#import "Building.h"
#import "Globals.h"
#import "NibUtils.h"
#import "SoundEngine.h"
#import "GameState.h"
#import "MyTeamSprite.h"

#define REORDER_START_Z 150

#define MY_TEAM_TAG_BASE(d) [NSString stringWithFormat:@"MyTeam%lld", d]

@implementation GameMap

@synthesize tileSizeInPoints;
@synthesize silverOnMap, goldOnMap;

-(void) addChild:(CCNode *)node z:(NSInteger)z name:(NSString *)name {
  if ([[node class] isSubclassOfClass:[MapSprite class]]) {
    [_mapSprites addObject:node];
  }
  [super addChild:node z:z name:name];
}

- (void) removeChild:(CCNode *)node cleanup:(BOOL)cleanup {
  if ([_mapSprites containsObject:node]) {
    [_mapSprites removeObject:node];
  }
  [super removeChild:node cleanup:cleanup];
}

-(id) initWithFile:(NSString *)tmxFile {
  if ((self = [super initWithFile:tmxFile])) {
    _mapSprites = [NSMutableArray array];
    
    if ([CCDirector sharedDirector].contentScaleFactor == 2) {
      tileSizeInPoints = CGSizeMake(self.tileSize.width/2, self.tileSize.height/2);
    } else {
      tileSizeInPoints = _tileSize;
    }
    
    // Add the decoration layer for clouds
    //    decLayer = [[DecorationLayer alloc] initWithSize:self.contentSize];
    //    [self addChild:self.decLayer z:2000];
    
    self.scale = DEFAULT_ZOOM;
    
    _mapMovementDivisor = 1000.f;
  }
  return self;
}

- (void) loadGestureRecognizers {
  UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drag:)];
  pan.delegate = self;
  pan.maximumNumberOfTouches = 1;
  [[[CCDirector sharedDirector] view] addGestureRecognizer:pan];
  
  // add UIPinchGestureRecognizer
  UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
  pinch.delegate = self;
  [[[CCDirector sharedDirector] view] addGestureRecognizer:pinch];
  
  // add UITapGestureRecognizer
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
  tap.delegate = self;
  [[[CCDirector sharedDirector] view] addGestureRecognizer:tap];
  
  self.gestureRecognizers = @[pan, pinch, tap];
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
  return YES;
}

- (void) unloadGestureRecognizers {
  for (UIGestureRecognizer *gest in self.gestureRecognizers) {
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:gest];
  }
  self.gestureRecognizers = nil;
}

- (void) setVisible:(BOOL)visible {
  [super setVisible:visible];
  self.selected = nil;
}

- (void) setSelected:(SelectableSprite *)selected {
  [_selected unselect];
  
  if ([selected select]) {
    _selected = selected;
  } else {
    _selected = nil;
  }
}

- (void) setupTeamSprites {
  GameState *gs = [GameState sharedGameState];
  
  NSMutableArray *newArr = [NSMutableArray array];
  for (UserMonster *um in gs.allMonstersOnMyTeam) {
    if (um.isHealing || um.isEnhancing || um.isSacrificing) {
      continue;
    }
    
    NSString *name = MY_TEAM_TAG_BASE(um.userMonsterId);
    MyTeamSprite *ts = (MyTeamSprite *)[self getChildByName:name recursively:NO];
    
    if (!ts) {
      ts = [[MyTeamSprite alloc] initWithMonsterId:um.monsterId map:self];
      ts.name = name;
      [self addChild:ts];
    } else {
      // Remove it so it doesn't get deleted
      [self.myTeamSprites removeObject:ts];
    }
    
    [newArr addObject:ts];
  }
  
  // All reuses will be removed by this point
  for (MyTeamSprite *ts in self.myTeamSprites) {
    [ts removeFromParent];
  }
  self.myTeamSprites = newArr;
}

- (void) pickUpAllDrops {
  
}

#pragma mark - Reordering sprites

- (NSComparisonResult) compareMapSprite1:(MapSprite *)obj1 toMapSprite2:(MapSprite *)obj2 {
  // winner = sprite that is in front
  MapSprite *winner = nil;
  CGSize ms = [self mapSize];
  CGRect loc1 = obj1.location;
  CGRect loc2 = obj2.location;
  
  CGRect rx1 = loc1; rx1.origin.y = 0; rx1.size.height = ms.height;
  CGRect rx2 = loc2; rx2.origin.y = 0; rx2.size.height = ms.height;
  CGRect ry1 = loc1; ry1.origin.x = 0; ry1.size.width = ms.width;
  CGRect ry2 = loc2; ry2.origin.x = 0; ry2.size.width = ms.width;
  
  BOOL xIntersects = CGRectIntersectsRect(rx1, rx2);
  BOOL yIntersects = CGRectIntersectsRect(ry1, ry2);
  
  // If neither intersect, use sum of x and y
  // If one side intersects, use the other side to calculate
  // If both sides intersect, just choose side with shorter intesection and calculate
  if (!xIntersects && !yIntersects) {
    float sum1 = loc1.origin.x+loc1.origin.y;
    float sum2 = loc2.origin.x+loc2.origin.y;
    
    if (sum1 != sum2) {
      winner = sum1 < sum2 ? obj1 : obj2;
    }
  } else if (!xIntersects) {
    if (loc1.origin.x != loc2.origin.x) {
      winner = loc1.origin.x < loc2.origin.x ? obj1 : obj2;
    }
  } else if (!yIntersects) {
    if (loc1.origin.y != loc2.origin.y) {
      winner = loc1.origin.y < loc2.origin.y ? obj1 : obj2;
    }
  } else {
    // Choose smaller intersection
    CGRect intersection = CGRectIntersection(loc1, loc2);
    if (intersection.size.width > intersection.size.height) {
      if (loc1.origin.y != loc2.origin.y) {
        winner = loc1.origin.y < loc2.origin.y ? obj1 : obj2;
      }
    } else {
      if (loc1.origin.x != loc2.origin.x) {
        winner = loc1.origin.x < loc2.origin.x ? obj1 : obj2;
      }
    }
  }
  
  if (winner == obj1) {
    return NSOrderedDescending;
  } else if (winner == obj2) {
    return NSOrderedAscending;
  } else {
    return NSOrderedSame;
  }
}

- (void) doReorder {
  [_mapSprites sortUsingComparator:^NSComparisonResult(MapSprite *obj1, MapSprite *obj2) {
    return [self compareMapSprite1:obj1 toMapSprite2:obj2];
  }];
  
  for (int i = 0; i < [_mapSprites count]; i++) {
    MapSprite *child = [_mapSprites objectAtIndex:i];
    if (![child isExemptFromReorder]) {
      child.zOrder = i+REORDER_START_Z;
    }
  }
}

- (SelectableSprite *) selectableForPt:(CGPoint)pt {
  // Find sprite that has center closest to pt
  SelectableSprite *toRet = nil;
  float distToCenter = 320.f;
  for(MapSprite *spr in _mapSprites) {
    if (![spr isKindOfClass:[SelectableSprite class]]) {
      continue;
    }
    SelectableSprite *child = (SelectableSprite *)spr;
    if ([child hitTestWithWorldPos:pt] && child.visible && child.opacity > 0.f) {
      CGPoint center = ccp(child.contentSize.width/2, child.contentSize.height/2);
      float thisDistToCenter = ccpDistance(center, [child convertToNodeSpace:pt]);
      
      if (thisDistToCenter < distToCenter) {
        distToCenter = thisDistToCenter;
        toRet = child;
      }
    }
  }
  return toRet;
}

#pragma mark - Gesture Recognizers

- (void) tap:(UIGestureRecognizer*)recognizer
{
  CGPoint pt = [recognizer locationInView:recognizer.view];
  pt = [[CCDirector sharedDirector] convertToGL:pt];
  
  SelectableSprite *ss = [self selectableForPt:pt];
  self.selected = ss;
  
  if (ss == nil) {
    pt = [self convertToNodeSpace:pt];
    pt = [self convertCCPointToTilePoint:pt];
    CGPoint loc = CGPointMake(roundf(pt.x), roundf(pt.y));
    
    if (_myTeamSprites.count > 0) {
      MyTeamSprite *ms = [_myTeamSprites objectAtIndex:0];
      [ms moveToward:loc speedMultiplier:3.f completionTarget:ms selector:@selector(walk)];
    }
  }
}

- (void) drag:(UIGestureRecognizer*)recognizer
{
  // Now do drag motion
  UIPanGestureRecognizer* pan = (UIPanGestureRecognizer*)recognizer;
  
  if([recognizer state] == UIGestureRecognizerStateBegan ||
     [recognizer state] == UIGestureRecognizerStateChanged )
  {
    [self stopActionByTag:190];
    CGPoint translation = [pan translationInView:pan.view.superview];
    
    CGPoint delta = [self convertVectorToGL: translation];
    [self setPosition:ccpAdd(self.position, delta)];
    [pan setTranslation:CGPointZero inView:pan.view.superview];
  } else if ([recognizer state] == UIGestureRecognizerStateEnded) {
    CGPoint vel = [pan velocityInView:pan.view.superview];
    vel = [self convertVectorToGL: vel];
    
    float dist = ccpDistance(ccp(0,0), vel);
    if (dist < 500) {
      return;
    }
    
    vel.x /= 3;
    vel.y /= 3;
    id actionID = [CCActionMoveBy actionWithDuration:dist/1500 position:vel];
    CCActionEaseOut *action = [CCActionEaseOut actionWithAction:actionID];
    action.tag = 190;
    [self runAction:action];
  }
}

- (void) scale:(UIGestureRecognizer*)recognizer
{
  UIPinchGestureRecognizer* pinch = (UIPinchGestureRecognizer*)recognizer;
  
  // See if zoom should even be allowed
  float newScale = self.scale * pinch.scale;
  pinch.scale = 1.0f; // we just reset the scaling so we only wory about the delta
  if (newScale > MAX_ZOOM || newScale < MIN_ZOOM) {
    return;
  }
  
  CCDirector* director = [CCDirector sharedDirector];
  CGPoint pt = [recognizer locationInView:recognizer.view.superview];
  pt = [director convertToGL:pt];
  CGPoint beforeScale = [self convertToNodeSpace:pt];
  
  self.scale = newScale;
  CGPoint afterScale = [self convertToNodeSpace:pt];
  CGPoint diff = ccpSub(afterScale, beforeScale);
  
  self.position = ccpAdd(self.position, ccpMult(diff, self.scale));
}

- (CGPoint) clipPositionToBoundary:(CGPoint)position scale:(float)scale {
  // For y, make sure to account for anchor point being at bottom middle.
  CGPoint blPt = bottomLeftCorner;
  CGPoint trPt = topRightCorner;
  float minX = blPt.x;
  float minY = blPt.y;//+self.tileSizeInPoints.height/2;
  float maxX = trPt.x;
  float maxY = trPt.y;//+self.tileSizeInPoints.height/2;
  
  float x = MAX(MIN(-minX*scale, position.x), -maxX*scale + [[CCDirector sharedDirector] viewSize].width);
  float y = MAX(MIN(-minY*scale, position.y), -maxY*scale + [[CCDirector sharedDirector] viewSize].height);
  
  return ccp(x, y);
}

-(void) setPosition:(CGPoint)position {
  [super setPosition:[self clipPositionToBoundary:position scale:self.scale]];
}

- (void) setScale:(float)scale {
  CGPoint tr = topRightCorner;
  CGPoint bl = bottomLeftCorner;
  int newWidth = (tr.x-bl.x)*scale;
  int newHeight = (tr.y-bl.y)*scale;
  
  if (newWidth >= self.parent.contentSize.width && newHeight >= self.parent.contentSize.height) {
    [super setScale:scale];
  }
}

- (BOOL) hitTestWithWorldPos:(CGPoint)pt {
  // Whole screen is in area
  return YES;
}

- (CGPoint) convertVectorToGL:(CGPoint)uiPoint
{
  return ccp(uiPoint.x, -uiPoint.y);
}

#pragma mark - Walkable methods

- (BOOL) isTileCoordWalkable:(CGPoint)pt {
  pt.x = floorf(pt.x); pt.y = floorf(pt.y);
  if (pt.x < _walkableData.count && pt.x >= 0) {
    NSArray *row = [_walkableData objectAtIndex:pt.x];
    if (pt.y < row.count && pt.y >= 0) {
      NSNumber *val = [row objectAtIndex:pt.y];
      return val.boolValue == YES;
    }
  }
  return NO;
}

- (CGPoint) randomWalkablePosition {
  int i = 0;
  while (i < 50) {
    int x = arc4random() % (int)self.mapSize.width;
    int y = arc4random() % (int)self.mapSize.height;
    NSNumber *num = [[_walkableData objectAtIndex:x] objectAtIndex:y];
    if (num.boolValue == YES) {
      // Make sure it is not too close to another sprite
      BOOL acceptable = YES;
      for (CCNode *child in self.children) {
        if ([child isKindOfClass:[CharacterSprite class]]) {
          CharacterSprite *cs = (CharacterSprite *)child;
          int xDiff = ABS(cs.location.origin.x-x);
          int yDiff = ABS(cs.location.origin.y-y);
          if (xDiff <= 2 && yDiff <= 2) {
            acceptable = NO;
            break;
          }
        }
      }
      
      if (acceptable) {
        return CGPointMake(x, y);
      }
    }
    i++;
  }
  return ccp(0,0);
}

- (CGPoint) nextWalkablePositionFromPoint:(CGPoint)point prevPoint:(CGPoint)prevPt {
  CGPoint diff = ccpSub(point, prevPt);
  if (diff.y > 0.5f) {
    diff = ccp(0, 1);
  } else if (diff.y < -0.5f) {
    diff = ccp(0, -1);
  } else if (diff.x > 0.5f) {
    diff = ccp(1, 0);
  } else {
    // Use some default :/ in case stuck
    diff = ccp(-1, 0);
  }
  
  CGPoint straight = ccpAdd(point, diff);
  CGPoint left = ccpAdd(point, ccpRotateByAngle(diff, ccp(0,0), M_PI_2));
  CGPoint right = ccpAdd(point, ccpRotateByAngle(diff, ccp(0,0), -M_PI_2));
  CGPoint back = ccpSub(point, diff);
  
  CGPoint pts[4] = {straight, right, left, back};
  int width = _mapSize.width;
  int height = _mapSize.height;
  
  // Don't let it infinite loop in case its stuck
  int max = 50;
  while (max > 0) {
    // 75% chance to go straight, 10% chance to turn (for each way), 5% chance to go back
    int x = arc4random() % 100;
    if (x <= 75) x = 0;
    else if (x <= 85) x = 1;
    else if (x <= 95) x = 2;
    else x = 3;
    
    CGPoint pt = pts[x];
    if (pt.x >= 0 && pt.x < width && pt.y >= 0 && pt.y < height) {
      if ([self isTileCoordWalkable:pt]) {
        return ccp((int)pt.x, (int)pt.y);
      }
    }
    max--;
  }
  return point;
}

- (NSArray *) walkableAdjacentTilesCoordForTileCoord:(CGPoint)tileCoord
{
	NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:4];
  
	// Top
	CGPoint p = CGPointMake(tileCoord.x, tileCoord.y - 1);
	if ([self isTileCoordWalkable:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
	}
  
	// Left
	p = CGPointMake(tileCoord.x - 1, tileCoord.y);
	if ([self isTileCoordWalkable:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
	}
  
	// Bottom
	p = CGPointMake(tileCoord.x, tileCoord.y + 1);
	if ([self isTileCoordWalkable:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
	}
  
	// Right
	p = CGPointMake(tileCoord.x + 1, tileCoord.y);
	if ([self isTileCoordWalkable:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
	}
  
  // Top Left
	p = CGPointMake(tileCoord.x - 1, tileCoord.y - 1);
	if ([self isTileCoordWalkable:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
	}
  
	// Bottom Left
	p = CGPointMake(tileCoord.x - 1, tileCoord.y + 1);
	if ([self isTileCoordWalkable:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
	}
  
	// Top Right
	p = CGPointMake(tileCoord.x + 1, tileCoord.y - 1);
	if ([self isTileCoordWalkable:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
	}
  
	// Bottom Right
	p = CGPointMake(tileCoord.x + 1, tileCoord.y + 1);
	if ([self isTileCoordWalkable:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
	}
  
	return [NSArray arrayWithArray:tmp];
}

#pragma mark - Move to sprite methods

#define MAP_MOVE_ACTION_TAG 1020

- (void) moveToCenterAnimated:(BOOL)animated {
  // move map to the center of the screen
  CGSize ms = [self mapSize];
  CGSize ts = [self tileSizeInPoints];
  CGSize size = [[CCDirector sharedDirector] viewSize];
  
  float x = -ms.width*ts.width/2*_scaleX+size.width/2;
  float y = -ms.height*ts.height/2*_scaleY+size.height/2;
  CGPoint newPos = ccp(x,y);
  if (animated) {
    CCAction *a = [CCActionMoveTo actionWithDuration:0.2f position:newPos];
    a.tag = MAP_MOVE_ACTION_TAG;
    [self stopActionByTag:a.tag];
    [self runAction:a];
  } else {
    self.position = newPos;
  }
}

- (float) moveToSprite:(CCSprite *)spr animated:(BOOL)animated withOffset:(CGPoint)offset scale:(float)scale {
  float dur = 0.f;
  if (spr) {
    CGPoint pt = spr.position;
    CGSize size = [[CCDirector sharedDirector] viewSize];
    
    // Since all sprites have anchor point ccp(0.5,0) adjust accordingly
    float x = -pt.x*scale+size.width/2;
    float y = (-pt.y-spr.contentSize.height*0.5)*scale+size.height/2;
    CGPoint newPos = [self clipPositionToBoundary:ccpAdd(offset,ccp(x,y)) scale:scale];
    if (animated) {
      dur = ccpDistance(newPos, self.position)/_mapMovementDivisor;
      CCAction *a = [CCActionEaseInOut actionWithAction:
                      [CCActionSpawn actions:
                       [CCActionScaleTo actionWithDuration:dur scale:scale],
                       [CCActionMoveTo actionWithDuration:dur position:newPos], nil]];
      a.tag = MAP_MOVE_ACTION_TAG;
      [self stopActionByTag:a.tag];
      [self runAction:a];
    } else {
      self.scale = scale;
      self.position = newPos;
    }
  }
  return dur;
}

- (float) moveToSprite:(CCSprite *)spr animated:(BOOL)animated withOffset:(CGPoint)offset {
  return [self moveToSprite:spr animated:animated withOffset:offset scale:self.scale];
}

- (float) moveToSprite:(CCSprite *)spr animated:(BOOL)animated {
  return [self moveToSprite:spr animated:animated withOffset:ccp(0,0)];
}

#pragma mark - Converting points

- (CGPoint) convertTilePointToCCPoint:(CGPoint)pt {
  CGSize ms = _mapSize;
  CGSize ts = tileSizeInPoints;
  return ccp( ms.width * ts.width/2.f + ts.width * (pt.x-pt.y)/2.f,
             ts.height * (pt.y+pt.x)/2.f);
}

- (CGPoint) convertCCPointToTilePoint:(CGPoint)pt {
  CGSize ms = _mapSize;
  CGSize ts = tileSizeInPoints;
  float a = (pt.x - ms.width*ts.width/2.f)/ts.width;
  float b = pt.y/ts.height;
  float x = a+b;
  float y = b-a;
  return ccp(x,y);
}

- (void) onEnter {
  [super onEnter];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupTeamSprites) name:MY_TEAM_CHANGED_NOTIFICATION object:nil];
  [self setupTeamSprites];
  
  [self loadGestureRecognizers];
}

- (void) onExit {
  self.selected = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  [self unloadGestureRecognizers];
  [super onExit];
}

@end
