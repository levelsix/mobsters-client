
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
#import "GameLayer.h"
#import "SoundEngine.h"
#import "GameState.h"
#import "CCLabelFX.h"

#define REORDER_START_Z 150

@implementation CCMoveByCustom
- (void) update: (ccTime) t {
	//Here we neglect to change something with a zero delta.
  if (_positionDelta.x == 0 && _positionDelta.y == 0) {
    // Do nothing
  } else if (_positionDelta.x == 0) {
		[_target setPosition: ccp( [(CCNode*)_target position].x, (_startPos.y + _positionDelta.y * t ) )];
	} else if (_positionDelta.y == 0) {
		[_target setPosition: ccp( (_startPos.x + _positionDelta.x * t ), [(CCNode*)_target position].y )];
	} else {
		[_target setPosition: ccp( (_startPos.x + _positionDelta.x * t ), (_startPos.y + _positionDelta.y * t ) )];
	}
}
@end

@implementation CCMoveToCustom
- (void) update: (ccTime) t {
	//Here we neglect to change something with a zero delta.
	if (_positionDelta.x == 0) {
		[_target setPosition: ccp( [(CCNode*)_target position].x, (_startPos.y + _positionDelta.y * t ) )];
	} else if (_positionDelta.y == 0) {
		[_target setPosition: ccp( (_startPos.x + _positionDelta.x * t ), [(CCNode*)_target position].y )];
	} else{
		[_target setPosition: ccp( (_startPos.x + _positionDelta.x * t ), (_startPos.y + _positionDelta.y * t ) )];
	}
}
@end

@implementation EnemyPopupView

@synthesize nameLabel, levelLabel, imageIcon, enemyView, allyView;

- (void) awakeFromNib {
  [self addSubview:allyView];
  allyView.frame = enemyView.frame;
}

@end

@implementation GameMap

@synthesize tileSizeInPoints;
@synthesize silverOnMap, goldOnMap;
@synthesize decLayer;

+(id) tiledMapWithTMXFile:(NSString*)tmxFile
{
	return [[self alloc] initWithTMXFile:tmxFile];
}

-(void) addChild:(CCNode *)node z:(NSInteger)z tag:(NSInteger)tag {
  if ([[node class] isSubclassOfClass:[MapSprite class]]) {
    [_mapSprites addObject:node];
  }
  [super addChild:node z:z tag:tag];
}

- (void) removeChild:(CCNode *)node cleanup:(BOOL)cleanup {
  if ([_mapSprites containsObject:node]) {
    [_mapSprites removeObject:node];
  }
  [super removeChild:node cleanup:cleanup];
}

-(id) initWithTMXFile:(NSString *)tmxFile {
  if ((self = [super initWithTMXFile:tmxFile])) {
    _mapSprites = [NSMutableArray array];
    
    // add UIPanGestureRecognizer
    UIPanGestureRecognizer *uig = [[UIPanGestureRecognizer alloc] init];
    uig.maximumNumberOfTouches = 1;
    CCGestureRecognizer *recognizer = [CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:uig target:self action:@selector(drag:node:)];
    [self addGestureRecognizer:recognizer];
    
    // add UIPinchGestureRecognizer
    recognizer = [CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[UIPinchGestureRecognizer alloc]init] target:self action:@selector(scale:node:)];
    [self addGestureRecognizer:recognizer];
    
    self.isTouchEnabled = YES;
    
    // add UITapGestureRecognizer
    recognizer = [CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[UITapGestureRecognizer alloc]init] target:self action:@selector(tap:node:)];
    [self addGestureRecognizer:recognizer];
    
    if (CC_CONTENT_SCALE_FACTOR() == 2) {
      tileSizeInPoints = CGSizeMake(self.tileSize.width/2, self.tileSize.height/2);
    } else {
      tileSizeInPoints = _tileSize;
    }
    
    [self createMyPlayer];
    
    // Add the decoration layer for clouds
    decLayer = [[DecorationLayer alloc] initWithSize:self.contentSize];
    [self addChild:self.decLayer z:2000];
    
    self.scale = DEFAULT_ZOOM;
  }
  return self;
}

- (void) createMyPlayer {
  // Do this so that tutorial classes can override
  _myPlayer = [[MyPlayer alloc] initWithLocation:CGRectMake(_mapSize.width/2, _mapSize.height/2, 1, 1) map:self];
  [self addChild:_myPlayer];
}

- (void) setVisible:(BOOL)visible {
  [super setVisible:visible];
  self.selected = nil;
}

- (BOOL) mapSprite:(MapSprite *)front isInFrontOfMapSprite: (MapSprite *)back {
  if (front == back) {
    return YES;
  }
  
  // Prioritize flying
  if (front.isFlying && back.isFlying) {
    // Do nothing
  } else if (front.isFlying) {
    return YES;
  } else if (back.isFlying) {
    return NO;
  }
  
  CGRect frontLoc = front.location;
  CGRect backLoc = back.location;
  
  BOOL leftX = frontLoc.origin.x < backLoc.origin.x && frontLoc.origin.x+frontLoc.size.width <= backLoc.origin.x;
  BOOL rightX = frontLoc.origin.x >= backLoc.origin.x+backLoc.size.width && frontLoc.origin.x+frontLoc.size.width > backLoc.origin.x+backLoc.size.width;
  
  if (leftX || rightX) {
    return frontLoc.origin.x <= backLoc.origin.x;
  }
  
  BOOL leftY = frontLoc.origin.y < backLoc.origin.y && frontLoc.origin.y+frontLoc.size.height <= backLoc.origin.y;
  BOOL rightY = frontLoc.origin.y >= backLoc.origin.y+backLoc.size.height && frontLoc.origin.y+frontLoc.size.height > backLoc.origin.y+backLoc.size.height;
  
  if (leftY || rightY) {
    return frontLoc.origin.y <= backLoc.origin.y;
  }
  return front.position.y <= back.position.y;
}

- (void) pickUpAllDrops {
  
}

- (void) setSelected:(SelectableSprite *)selected {
  if (_selected != selected) {
    _selected.isSelected = NO;
    _selected = selected;
    _selected.isSelected = YES;
  }
}

- (void) doReorder {
  for (int i = 1; i < [_mapSprites count]; i++) {
    MapSprite *toSort = [_mapSprites objectAtIndex:i];
    MapSprite *sorted = [_mapSprites objectAtIndex:i-1];
    if (![self mapSprite:toSort isInFrontOfMapSprite:sorted]) {
      int j;
      for (j = i-2; j >= 0; j--) {
        sorted = [_mapSprites objectAtIndex:j];
        if ([self mapSprite:toSort isInFrontOfMapSprite:sorted]) {
          break;
        }
      }
      
      [_mapSprites removeObjectAtIndex:i];
      [_mapSprites insertObject:toSort atIndex:j+1];
    }
  }
  
  for (int i = 0; i < [_mapSprites count]; i++) {
    MapSprite *child = [_mapSprites objectAtIndex:i];
    if (![child isExemptFromReorder]) {
      [self reorderChild:child z:i+REORDER_START_Z];
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
    if ([child isPointInArea:pt] && child.visible && child.opacity > 0.f) {
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

- (void) tap:(UIGestureRecognizer*)recognizer node:(CCNode*)node
{
  CGPoint pt = [recognizer locationInView:recognizer.view];
  pt = [[CCDirector sharedDirector] convertToGL:pt];
  
  if (_selected && ![_selected isPointInArea:pt]) {
    self.selected = nil;
  }
  
  SelectableSprite *ss = [self selectableForPt:pt];
  self.selected = ss;
  
  if (ss == nil) {
    pt = [self convertToNodeSpace:pt];
    pt = [self convertCCPointToTilePoint:pt];
    CGRect loc = CGRectMake(pt.x, pt.y, 1, 1);
    
    [_myPlayer moveToLocation:loc];
  }
}

- (void) drag:(UIGestureRecognizer*)recognizer node:(CCNode*)node
{
  // Now do drag motion
  UIPanGestureRecognizer* pan = (UIPanGestureRecognizer*)recognizer;
  
  if([recognizer state] == UIGestureRecognizerStateBegan ||
     [recognizer state] == UIGestureRecognizerStateChanged )
  {
    [node stopActionByTag:190];
    CGPoint translation = [pan translationInView:pan.view.superview];
    
    CGPoint delta = [self convertVectorToGL: translation];
    [node setPosition:ccpAdd(node.position, delta)];
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
    id actionID = [CCMoveBy actionWithDuration:dist/1500 position:vel];
    CCEaseOut *action = [CCEaseSineOut actionWithAction:actionID];
    action.tag = 190;
    [node runAction:action];
  }
}

- (void) scale:(UIGestureRecognizer*)recognizer node:(CCNode*)node
{
  UIPinchGestureRecognizer* pinch = (UIPinchGestureRecognizer*)recognizer;
  
  // See if zoom should even be allowed
  float newScale = node.scale * pinch.scale;
  pinch.scale = 1.0f; // we just reset the scaling so we only wory about the delta
  if (newScale > MAX_ZOOM || newScale < MIN_ZOOM) {
    return;
  }
  
  CCDirector* director = [CCDirector sharedDirector];
  CGPoint pt = [recognizer locationInView:recognizer.view.superview];
  pt = [director convertToGL:pt];
  CGPoint beforeScale = [node convertToNodeSpace:pt];
  
  node.scale = newScale;
  CGPoint afterScale = [node convertToNodeSpace:pt];
  CGPoint diff = ccpSub(afterScale, beforeScale);
  
  node.position = ccpAdd(node.position, ccpMult(diff, node.scale));
  
  [self.decLayer updateAllCloudOpacities];
}

-(void) setPosition:(CGPoint)position {
  // For y, make sure to account for anchor point being at bottom middle.
  CGPoint blPt = bottomLeftCorner;
  CGPoint trPt = topRightCorner;
  float minX = blPt.x;
  float minY = blPt.y;//+self.tileSizeInPoints.height/2;
  float maxX = trPt.x;
  float maxY = trPt.y;//+self.tileSizeInPoints.height/2;
  
  float x = MAX(MIN(-minX*self.scaleX, position.x), -maxX*self.scaleX + [[CCDirector sharedDirector] winSize].width);
  float y = MAX(MIN(-minY*self.scaleY, position.y), -maxY*self.scaleY + [[CCDirector sharedDirector] winSize].height);
  
  [super setPosition:ccp(x,y)];
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

- (BOOL) isPointInArea:(CGPoint)pt {
  // Whole screen is in area
  return YES;
}

- (void) layerWillDisappear {
  self.selected = nil;
}

-(CGPoint)convertVectorToGL:(CGPoint)uiPoint
{
  return ccp(uiPoint.x, -uiPoint.y);
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
      if ([[[_walkableData objectAtIndex:pt.x] objectAtIndex:pt.y] boolValue] == YES) {
        return ccp((int)pt.x, (int)pt.y);
      }
    }
    max--;
  }
  return point;
}

- (void) moveToCenterAnimated:(BOOL)animated {
  // move map to the center of the screen
  CGSize ms = [self mapSize];
  CGSize ts = [self tileSizeInPoints];
  CGSize size = [[CCDirector sharedDirector] winSize];
  
  float x = -ms.width*ts.width/2*_scaleX+size.width/2;
  float y = -ms.height*ts.height/2*_scaleY+size.height/2;
  CGPoint newPos = ccp(x,y);
  if (animated) {
    [self runAction:[CCMoveTo actionWithDuration:0.2f position:newPos]];
  } else {
    self.position = newPos;
  }
}

- (float) moveToSprite:(CCSprite *)spr animated:(BOOL)animated withOffset:(CGPoint)offset {
  float dur = 0.f;
  if (spr) {
    CGPoint pt = spr.position;
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    // Since all sprites have anchor point ccp(0.5,0) adjust accordingly
    float x = -pt.x*_scaleX+size.width/2;
    float y = (-pt.y-spr.contentSize.height*3/4)*_scaleY+size.height/2;
    CGPoint newPos = ccpAdd(offset,ccp(x,y));
    if (animated) {
      dur = ccpDistance(newPos, self.position)/1000.f;
      [self runAction:[CCEaseSineInOut actionWithAction:[CCMoveTo actionWithDuration:dur position:newPos]]];
    } else {
      self.position = newPos;
    }
  }
  return dur;
}

- (void) moveToSprite:(CCSprite *)spr animated:(BOOL)animated {
  [self moveToSprite:spr animated:animated withOffset:ccp(0,0)];
}

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

- (void) onExit {
  [super onExit];
  self.selected = nil;
}

@end
