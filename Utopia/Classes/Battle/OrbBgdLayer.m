//
//  OrbBgdLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/15/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "OrbBgdLayer.h"
#import "cocos2d.h"
#import "TileSprite.h"
#import "NibUtils.h"
#import "Globals.h"
#import "CCAnimation+SpriteLoading.h"

#define IPHONE_5_TILE_SIZE 36
#define IPHONE_6_TILE_SIZE 42
#define IPHONE_6_PLUS_TILE_SIZE 47
//Note: iPad-retina uses IPHONE_5_TILE_SIZE

#define CORNER_SIZE_IPHONE 6
#define CORNER_SIZE_IPAD 12
#define BORDER_WIDTH 2

@implementation OrbBgdLayer

- (int) cornerSize {
  return [Globals isiPad] ? CORNER_SIZE_IPAD : CORNER_SIZE_IPHONE;
}

- (int) tileSize {
  int initialSize = [Globals isiPhone6] ? IPHONE_6_TILE_SIZE : [Globals isiPhone6Plus] ? IPHONE_6_PLUS_TILE_SIZE : IPHONE_5_TILE_SIZE;
  
  if (![Globals isiPad] && (_layout.numColumns == 9 || _layout.numRows == 9)) {
    initialSize = initialSize - 2 - [Globals isiPhone6Plus];
  }
  
  return initialSize;
}

- (id) initWithGridSize:(CGSize)gridSize layout:(BattleOrbLayout *)layout {
  self = [super init];
  if (! self)
    return nil;
  
  _layout = layout;
  _gridSize = gridSize;
  
  self.anchorPoint = ccp(0.5, 0.5);
  
  // Setup bottom, top and darkness tile layers
  _tilesLayerMain = [CCNode node];
  _tilesLayerBottom = [CCNode node];
  _tilesLayerTop = [CCNode node];
  _tilesLayerDarkness = [CCNode node];
  [self addChild:_tilesLayerMain z:0];
  [self addChild:_tilesLayerBottom z:1];  // z=2 is for OrbSwipeLayer
  [self addChild:_tilesLayerTop z:3];
  [self addChild:_tilesLayerDarkness z:4];
  
  [self reloadTiles];
  
  return self;
}

- (void) reloadTiles {
  [_tilesLayerMain removeAllChildren];
  [_tilesLayerBottom removeAllChildren];
  [_tilesLayerTop removeAllChildren];
  [_tilesLayerDarkness removeAllChildren];
  
  // Setup board background
  int tileSize = [self tileSize];
  for (int i = 0; i < _gridSize.width; i++) {
    for (int j = 0; j < _gridSize.height; j++) {
      BattleTile *tile = [_layout tileAtColumn:i row:j];
      
      [self createTileSprite:tile];
    }
  }
  
  if (_borderNode) {
    [_borderNode removeFromParent];
    [self assembleBorder];
  }
  
  self.contentSize = CGSizeMake(_gridSize.width*tileSize, _gridSize.height*tileSize);
}

- (CCSprite *) createTileSprite:(BattleTile *)tile {
  NSInteger i = tile.column, j = tile.row;
  int tileSize = [self tileSize];
  
  if (!tile.isHole) {
    NSString *fileName = (i+j)%2==0 ? @"lightboardsquare.png" : @"darkboardsquare.png";
    CCSprite *square = [CCSprite spriteWithImageNamed:fileName];
    
    [_tilesLayerMain addChild:square];
    square.position = ccp((i+0.5)*tileSize, (j+0.5)*tileSize);
    square.scale = tileSize;
    [self iPadScaleSprite:square];
    
    TileSprite* spriteTop = [TileSprite tileSpriteWithTile:tile depth:TileDepthTop];
    TileSprite* spriteBottom = [TileSprite tileSpriteWithTile:tile depth:TileDepthBottom];
    if (spriteTop)
    {
      spriteTop.position = ccp((i+0.5)*tileSize, (j+0.5)*tileSize);
      [_tilesLayerTop addChild:spriteTop z:1 name:tile.description];
    }
    if (spriteBottom)
    {
      spriteBottom.position = ccp((i+0.5)*tileSize, (j+0.5)*tileSize);
      [_tilesLayerBottom addChild:spriteBottom z:1 name:tile.description];
    }
    
    // Dark tile
    CCNodeColor *spriteDark = [CCNodeColor nodeWithColor:[CCColor colorWithCcColor4f:ccc4f(0, 0, 0, darknessForTilesOpacity)]
                                                   width:tileSize height:tileSize];
    spriteDark.position = ccp(i*tileSize, j*tileSize);
    [_tilesLayerDarkness addChild:spriteDark z:1 name:tile.description];
    
    return square;
  }
  
  return nil;
}

- (void) assembleBorder {
  
  _borderNode = [CCNode node];
  [self addChild:_borderNode z:1];
  
  // Go out 1 more on bottom and right so that it will take care of outer edges on bot and right
  for (int i = 0; i < _gridSize.width+1; i++) {
    for (int j = -1; j < _gridSize.height; j++) {
      BattleTile *tiles[3][3];
      
      for (int a = i-1; a <= i+1; a++) {
        for (int b = j-1; b <= j+1; b++) {
          if (a >= 0 && a < _gridSize.width &&
              b >= 0 && b < _gridSize.height) {
            tiles[a-i+1][b-j+1] = [_layout tileAtColumn:a row:b];
          } else {
            tiles[a-i+1][b-j+1] = nil;
          }
        }
      }
      
      BOOL lHole  = !tiles[0][1] || tiles[0][1].isHole;
      BOOL mHole  = !tiles[1][1] || tiles[1][1].isHole;
      BOOL tlHole = !tiles[0][2] || tiles[0][2].isHole;
      BOOL tHole  = !tiles[1][2] || tiles[1][2].isHole;
      
      // Only process the left, top left, and top borders for general case. On bottom
      // and right most rows, process the rest of the edges and corners.
      
      // Left line exists if cur is hole and left is not, or vice versa. Same logic with top.
      BOOL leftLine = mHole != lHole;
      BOOL topLine = mHole != tHole;
      
      // For top left corner, there are 3 scenarios:
      // a) cur is hole: left, top left, and top are all not holes, use inner curve with color.
      // b) cur is not hole: left, top left, and top are all holes, use inner curve without color.
      // c) cur and top left are same, left and top are same. use some variation of a double sprite with color.
      // default) make the lines longer if they exist
      BOOL lCorner = lHole != tlHole && lHole != mHole && (lHole != tHole || lHole);
      BOOL tlCorner = tlHole != lHole && tlHole != tHole && (tlHole != mHole || tlHole);
      BOOL tCorner = tHole
      != tlHole && tHole != mHole && (tHole != lHole || tHole);
      BOOL mCorner = mHole != lHole && mHole != tHole && (mHole != tlHole || mHole);
      
      // If no corners, then we can stretch out the lines longer
      BOOL noCorners = !lCorner && !tlCorner && !tCorner && !mCorner;
      
      int tileSize = [self tileSize];
      CGPoint basePt = ccp(i*tileSize, j*tileSize);
      
      // Draw the lines
      if (leftLine) {
        CCSprite *leftBorder = [CCSprite spriteWithImageNamed:@"borderstraight.png"];
        
        float scale = tileSize - (noCorners ? 0 : [self cornerSize]);
        
        leftBorder.scaleY = scale;
        leftBorder.anchorPoint = ccp(!mHole, 0);
        leftBorder.position = ccpAdd(basePt, ccp(0, [self cornerSize]/2));
        [self iPadScaleSprite:leftBorder xRatio:1 yRatio:1.5];
        
        [_borderNode addChild:leftBorder];
      }
      
      if (topLine) {
        CCSprite *topBorder = [CCSprite spriteWithImageNamed:@"borderstraight.png"];
        
        float scale = tileSize - (noCorners ? 0 : [self cornerSize]);
        
        // Can't use the anchor point like above since we need to rotate and scale.. gets all screwy
        topBorder.scaleY = scale;
        topBorder.rotation = 90;
        topBorder.position = ccpAdd(basePt, ccp(tileSize-[self cornerSize]/2-scale/2, tileSize+(!mHole*2-1)*BORDER_WIDTH/2));
        [self iPadScaleSprite:topBorder xRatio:1 yRatio:1.5];
        
        [_borderNode addChild:topBorder];
      }
      
      CGPoint cornerPos = ccpAdd(basePt, ccp(0, tileSize));
      
      // Now draw the corners
      if (lCorner) {
        BOOL isColor = lHole;
        CCSprite *corner = [CCSprite spriteWithImageNamed:[self cornerImageNameForX:i-1 y:j useColor:isColor]];
        
        corner.position = isColor ? cornerPos : ccpAdd(cornerPos, ccp(BORDER_WIDTH, BORDER_WIDTH));
        corner.flipX = YES;
        corner.flipY = YES;
        corner.anchorPoint = ccp(1, 1);
        
        [_borderNode addChild:corner];
      }
      
      if (mCorner) {
        BOOL isColor = mHole;
        CCSprite *corner = [CCSprite spriteWithImageNamed:[self cornerImageNameForX:i y:j useColor:isColor]];
        
        corner.position = isColor ? cornerPos : ccpAdd(cornerPos, ccp(-BORDER_WIDTH, BORDER_WIDTH));
        corner.flipY = YES;
        corner.anchorPoint = ccp(0, 1);
        
        [_borderNode addChild:corner];
      }
      
      if (tCorner) {
        BOOL isColor = tHole;
        CCSprite *corner = [CCSprite spriteWithImageNamed:[self cornerImageNameForX:i y:j+1 useColor:isColor]];
        
        corner.position = isColor ? cornerPos : ccpAdd(cornerPos, ccp(-BORDER_WIDTH, -BORDER_WIDTH));
        corner.anchorPoint = ccp(0, 0);
        
        [_borderNode addChild:corner];
      }
      
      if (tlCorner) {
        BOOL isColor = tlHole;
        CCSprite *corner = [CCSprite spriteWithImageNamed:[self cornerImageNameForX:i-1 y:j+1 useColor:isColor]];
        
        corner.position = isColor ? cornerPos : ccpAdd(cornerPos, ccp(BORDER_WIDTH, -BORDER_WIDTH));
        corner.flipX = YES;
        corner.anchorPoint = ccp(1, 0);
        
        [_borderNode addChild:corner];
      }
    }
  }
}

- (NSString *)cornerImageNameForX:(int)x y:(int)y useColor:(BOOL)color {
  if (color) {
    return (x+y)%2==1 ? @"borderroundedlight.png" : @"borderroundeddark.png";
  } else {
    return @"borderrounded.png";
  }
}

- (TileSprite*) spriteForTile:(BattleTile *)tile depth:(TileDepth)depth{
  if (depth == TileDepthTop)
    return (TileSprite*)[_tilesLayerTop getChildByName:tile.description recursively:NO];
  else
    return (TileSprite*)[_tilesLayerBottom getChildByName:tile.description recursively:NO];
}

#pragma mark - Putty

- (void) updateForPuttyWithTile:(BattleTile *)tile {
  [self createTileSprite:tile];
  [self turnTheLightForTile:tile on:YES instantly:YES];
  
  if (_borderNode) {
    [_borderNode removeFromParent];
    [self assembleBorder];
  }
}

#pragma mark Tiles updating and darkness

- (void) updateTileInternal:(BattleTile *)tile
{
  TileSprite* spriteTop = [self spriteForTile:tile depth:TileDepthTop];
  if (spriteTop)
    [spriteTop updateSprite];
  TileSprite* spriteBottom = [self spriteForTile:tile depth:TileDepthBottom];
  if (spriteBottom)
    [spriteBottom updateSprite];
}

- (void) updateTile:(BattleTile*)tile
{
  return [self updateTile:tile keepLit:NO withTarget:nil andCallback:nil];
}

- (void) updateTile:(BattleTile*)tile keepLit:(BOOL)keepLit withTarget:(id)target andCallback:(SEL)callback
{
  if ([self isTileDarkened:tile])
  {
    [self turnTheLightForTile:tile on:YES instantly:NO];
    [self performAfterDelay:0.5 block:^{
      [self updateTileInternal:tile];
      [self performAfterDelay:keepLit?0.0:0.3 block:^{
        if (! keepLit)
          [self turnTheLightForTile:tile on:NO instantly:NO];
        if (target && callback)
          [target performSelector:callback withObject:nil afterDelay:darknessForTilesAnimDuration];
      }];
    }];
  }
  else
  {
    [self updateTileInternal:tile];
    if (target && callback)
      [target performSelector:callback withObject:nil afterDelay:tileUpdateAnimDuration];
  }
}

- (void)updateArrowForTile:(BattleTile *)tile arrow:(BOOL)arrow{
  [[self spriteForTile:tile depth:TileDepthTop] updateArrowSprite:arrow];
}

- (void) turnTheLightsOn
{
  [self turnTheLights:YES instantly:NO];
}

- (void) turnTheLightsOff
{
  [self turnTheLights:NO instantly:NO];
}

- (BOOL) isTileDarkened:(BattleTile*)tile
{
  CCNodeColor* darkTile = (CCNodeColor*)[_tilesLayerDarkness getChildByName:tile.description recursively:NO];
  if (darkTile.opacity == darknessForTilesOpacity)
    return YES;
  return NO;
}

- (void) turnTheLightForTile:(BattleTile*)tile on:(BOOL)on instantly:(BOOL)instantly
{
  CCNodeColor* darkTile = (CCNodeColor*)[_tilesLayerDarkness getChildByName:tile.description recursively:NO];
  if (!on)
    [darkTile stopAllActions];
  if (instantly)
  {
    if (on)
      darkTile.opacity = 0.0;
    else
      darkTile.opacity = darknessForTilesOpacity;
  }
  else
  {
    if (on)
      [darkTile runAction:[CCActionFadeTo actionWithDuration:darknessForTilesAnimDuration opacity:0.0]];
    else
      [darkTile runAction:[CCActionFadeTo actionWithDuration:darknessForTilesAnimDuration opacity:darknessForTilesOpacity]];
  }
}

- (void) turnTheLights:(BOOL)on instantly:(BOOL)instantly
{
  for (NSInteger col = 0; col < _layout.numColumns; col++)
    for (NSInteger row = 0; row < _layout.numRows; row++) {
      BattleTile* tile = [_layout tileAtColumn:col row:row];
      [self turnTheLightForTile:tile on:on instantly:instantly];
    }
}

- (void) playVineExpansion:(NSString*)directionString onTile:(BattleTile*)tile withCompletion:(void(^)())withCompletion {
  //Make sure that animation is in cache
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"Vines%@.plist", directionString]];
  
  CCSprite *vineArm = [CCSprite node];
  [[self spriteForTile:tile depth:TileDepthTop] addChild:vineArm z:1.f];
  CCAnimation *anim = [CCAnimation animationWithSpritePrefix:[NSString stringWithFormat:@"Vines%@", directionString] delay:.05f];
  
  [vineArm runAction:[CCActionSequence actions:
                      [CCActionAnimate actionWithAnimation:anim],
                      [CCActionCallBlock actionWithBlock:^{
                          withCompletion();
                        }],
                      [CCActionDelay actionWithDuration:.5f],
                      [CCActionAnimate actionWithAnimation:anim.reversedAnimation],
                      [CCActionRemove action],
                      nil]];
}

#pragma mark - Util

- (void) iPadScaleSprite:(CCSprite*)sprite {
  [self iPadScaleSprite:sprite ratio:1.5];
}

- (void) iPadScaleSprite:(CCSprite*)sprite ratio:(float)ratio {
  [self iPadScaleSprite:sprite xRatio:ratio yRatio:ratio];
}

- (void) iPadScaleSprite:(CCSprite*)sprite xRatio:(float)xRatio yRatio:(float)yRatio {
  if ([Globals isiPad]) {
    sprite.scaleX *= xRatio;
    sprite.scaleY *= yRatio;
  }
}

@end
