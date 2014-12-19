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

#define IPHONE_5_TILE_SIZE 36
#define IPHONE_6_TILE_SIZE 42
#define IPHONE_6_PLUS_TILE_SIZE 47

#define CORNER_SIZE 6
#define BORDER_WIDTH 2

@implementation OrbBgdLayer

- (int) tileSize {
  return [Globals isiPhone6] ? IPHONE_6_TILE_SIZE : [Globals isiPhone6Plus] ? IPHONE_6_PLUS_TILE_SIZE : IPHONE_5_TILE_SIZE;
}

- (id) initWithGridSize:(CGSize)gridSize layout:(BattleOrbLayout *)layout {
  self = [super init];
  if (! self)
    return nil;
  
  _layout = layout;
  _gridSize = gridSize;
  
  // Setup board background
  int tileSize = [self tileSize];
  for (int i = 0; i < gridSize.width; i++) {
    for (int j = 0; j < gridSize.height; j++) {
      BattleTile *tile = [layout tileAtColumn:i row:j];
      
      if (!tile.isHole) {
        NSString *fileName = (i+j)%2==0 ? @"lightboardsquare.png" : @"darkboardsquare.png";
        CCSprite *square = [CCSprite spriteWithImageNamed:fileName];
        
        [self addChild:square];
        square.position = ccp((i+0.5)*tileSize, (j+0.5)*tileSize);
        square.scale = tileSize;
      }
    }
  }
  
  self.contentSize = CGSizeMake(gridSize.width*tileSize, gridSize.height*tileSize);
  
  self.anchorPoint = ccp(0.5, 0.5);
  
  [self assembleBorder];
  
  // Setup bottom, top and darkness tile layers
  _tilesLayerBottom = [CCNode node];
  _tilesLayerTop = [CCNode node];
  _tilesLayerDarkness = [CCNode node];
  [self addChild:_tilesLayerBottom z:1];  // z=2 is for OrbSwipeLayer
  [self addChild:_tilesLayerTop z:3];
  [self addChild:_tilesLayerDarkness z:4];
  
  for (NSInteger col = 0; col < layout.numColumns; col++) {
    for (NSInteger row = 0; row < layout.numRows; row++) {
      
      // Top and bottom tiles
      BattleTile* tile = [layout tileAtColumn:col row:row];
      
      if (!tile.isHole) {
        TileSprite* spriteTop = [TileSprite tileSpriteWithTile:tile depth:TileDepthTop];
        TileSprite* spriteBottom = [TileSprite tileSpriteWithTile:tile depth:TileDepthBottom];
        if (spriteTop)
        {
          spriteTop.position = ccp((col+0.5)*tileSize, (row+0.5)*tileSize);
          [_tilesLayerTop addChild:spriteTop z:1 name:tile.description];
        }
        if (spriteBottom)
        {
          spriteBottom.position = ccp((col+0.5)*tileSize, (row+0.5)*tileSize);
          [_tilesLayerBottom addChild:spriteBottom z:1 name:tile.description];
        }
        
        // Dark tile
        CCNodeColor *spriteDark = [CCNodeColor nodeWithColor:[CCColor colorWithCcColor4f:ccc4f(0, 0, 0, darknessForTilesOpacity)]
                                                       width:tileSize height:tileSize];
        spriteDark.position = ccp(col*tileSize, row*tileSize);
        [_tilesLayerDarkness addChild:spriteDark z:1 name:tile.description];
      }
    }
  }
  
  return self;
}

- (void) assembleBorder {
  
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
      BOOL lCorner = lHole != tlHole && lHole != mHole;
      BOOL tlCorner = tlHole != lHole && tlHole != tHole;
      BOOL tCorner = tHole != tlHole && tHole != mHole;
      BOOL mCorner = mHole != lHole && mHole != tHole;
      
      // If no corners, then we can stretch out the lines longer
      BOOL noCorners = !lCorner && !tlCorner && !tCorner && !mCorner;
      
      int tileSize = [self tileSize];
      CGPoint basePt = ccp(i*tileSize, j*tileSize);
      
      NSLog(@"(%d, %d): lc:%d, tlc:%d, tc:%d, mc:%d, lh:%d, mh:%d, tlh:%d, th:%d", i, j, lCorner, tlCorner, tCorner, mCorner, lHole, mHole, tlHole, tHole);
      
      int z = 1;
      
      // Draw the lines
      if (leftLine) {
        CCSprite *leftBorder = [CCSprite spriteWithImageNamed:@"borderstraight.png"];
        
        float scale = tileSize - (noCorners ? 0 : CORNER_SIZE);
        
        leftBorder.scaleY = scale;
        leftBorder.anchorPoint = ccp(!mHole, 0);
        leftBorder.position = ccpAdd(basePt, ccp(0, CORNER_SIZE/2));
        
        [self addChild:leftBorder z:z];
      }
      
      if (topLine) {
        CCSprite *topBorder = [CCSprite spriteWithImageNamed:@"borderstraight.png"];
        
        float scale = tileSize - (noCorners ? 0 : CORNER_SIZE);
        
        // Can't use the anchor point like above since we need to rotate and scale.. gets all screwy
        topBorder.scaleY = scale;
        topBorder.rotation = 90;
        topBorder.position = ccpAdd(basePt, ccp(tileSize-CORNER_SIZE/2-scale/2, tileSize+(!mHole*2-1)*BORDER_WIDTH/2));
        
        [self addChild:topBorder z:z];
      }
      
      CGPoint cornerPos = ccpAdd(basePt, ccp(0, tileSize));
      
      // Now draw the corners
      if (lCorner) {
        BOOL isColor = lHole;
        CCSprite *corner = [CCSprite spriteWithImageNamed:[self cornerImageNameForX:i y:j useColor:isColor]];
        
        corner.position = isColor ? cornerPos : ccpAdd(cornerPos, ccp(BORDER_WIDTH, BORDER_WIDTH));
        corner.flipX = YES;
        corner.flipY = YES;
        corner.anchorPoint = ccp(1, 1);
        
        [self addChild:corner];
      }
      
      if (mCorner) {
        BOOL isColor = mHole;
        CCSprite *corner = [CCSprite spriteWithImageNamed:[self cornerImageNameForX:i y:j useColor:isColor]];
        
        corner.position = isColor ? cornerPos : ccpAdd(cornerPos, ccp(-BORDER_WIDTH, BORDER_WIDTH));
        corner.flipY = YES;
        corner.anchorPoint = ccp(0, 1);
        
        [self addChild:corner];
      }
      
      if (tCorner) {
        BOOL isColor = tHole;
        CCSprite *corner = [CCSprite spriteWithImageNamed:[self cornerImageNameForX:i y:j useColor:isColor]];
        
        corner.position = isColor ? cornerPos : ccpAdd(cornerPos, ccp(-BORDER_WIDTH, -BORDER_WIDTH));
        corner.anchorPoint = ccp(0, 0);
        
        [self addChild:corner];
      }
      
      if (tlCorner) {
        BOOL isColor = tlHole;
        CCSprite *corner = [CCSprite spriteWithImageNamed:[self cornerImageNameForX:i y:j useColor:isColor]];
        
        corner.position = isColor ? cornerPos : ccpAdd(cornerPos, ccp(BORDER_WIDTH, -BORDER_WIDTH));
        corner.flipX = YES;
        corner.anchorPoint = ccp(1, 0);
        
        [self addChild:corner];
      }
    }
  }
}

- (NSString *)cornerImageNameForX:(int)x y:(int)y useColor:(BOOL)color {
  if (color) {
    return (x+y)%2==0 ? @"borderroundedlight.png" : @"borderroundeddark.png";
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

@end
