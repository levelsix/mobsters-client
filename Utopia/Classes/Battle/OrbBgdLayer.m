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

@implementation OrbBgdLayer

- (id) initWithGridSize:(CGSize)gridSize layout:(BattleOrbLayout *)layout {
  self = [super init];
  if (! self)
    return nil;
  
  // Setup board background
  CCSprite *square;
  for (int i = 0; i < gridSize.width; i++) {
    for (int j = 0; j < gridSize.height; j++) {
      NSString *fileName = (i+j)%2==0 ? @"lightboardsquare.png" : @"darkboardsquare.png";
      square = [CCSprite spriteWithImageNamed:fileName];
      
      [self addChild:square];
      square.position = ccp((i+0.5)*square.contentSize.width, (j+0.5)*square.contentSize.height);
      
      self.contentSize = CGSizeMake(square.position.x+square.contentSize.width/2, square.position.y+square.contentSize.height/2);
    }
  }
  
  self.anchorPoint = ccp(0.5, 0.5);
    
  [self assembleBorder];
  
  // Setup bottom and top tile layers
  _tilesLayerBottom = [CCNode node];
  _tilesLayerTop = [CCNode node];
  [self addChild:_tilesLayerBottom z:1];  // z=2 is for OrbSwipeLayer
  [self addChild:_tilesLayerTop z:3];
  
  for (NSInteger col = 0; col < layout.numColumns; col++)
    for (NSInteger row = 0; row < layout.numRows; row++) {
      BattleTile* tile = [layout tileAtColumn:col row:row];
      TileSprite* spriteTop = [TileSprite tileSpriteWithTile:tile depth:TileDepthTop];
      TileSprite* spriteBottom = [TileSprite tileSpriteWithTile:tile depth:TileDepthBottom];
      if (spriteTop)
      {
        [_tilesLayerTop addChild:spriteTop z:1 name:tile.description];
        spriteTop.position = ccp((col+0.5)*square.contentSize.width, (row+0.5)*square.contentSize.height);
      }
      if (spriteBottom)
      {
        [_tilesLayerBottom addChild:spriteBottom z:1 name:tile.description];
        spriteBottom.position = ccp((col+0.5)*square.contentSize.width, (row+0.5)*square.contentSize.height);
      }
    }
  
  return self;
}

- (void) assembleBorder {
  CCSprite *leftBorder = [CCSprite spriteWithImageNamed:@"borderstraight.png"];
  CCSprite *rightBorder = [CCSprite spriteWithImageNamed:@"borderstraight.png"];
  CCSprite *botBorder = [CCSprite spriteWithImageNamed:@"borderstraight.png"];
  CCSprite *topBorder = [CCSprite spriteWithImageNamed:@"borderstraight.png"];
  CCSprite *blCorner = [CCSprite spriteWithImageNamed:@"borderrounded.png"];
  CCSprite *brCorner = [CCSprite spriteWithImageNamed:@"borderrounded.png"];
  CCSprite *tlCorner = [CCSprite spriteWithImageNamed:@"borderrounded.png"];
  CCSprite *trCorner = [CCSprite spriteWithImageNamed:@"borderrounded.png"];
  
  float borderWidth = leftBorder.contentSize.width;
  CGSize cornerSize = blCorner.contentSize;
  
  blCorner.position = ccp(-borderWidth, -borderWidth);
  blCorner.anchorPoint = ccp(0, 0);
  
  brCorner.position = ccp(_contentSize.width+borderWidth, -borderWidth);
  brCorner.flipX = YES;
  brCorner.anchorPoint = ccp(1, 0);
  
  tlCorner.position = ccp(-borderWidth, _contentSize.height+borderWidth);
  tlCorner.flipY = YES;
  tlCorner.anchorPoint = ccp(0, 1);
  
  trCorner.position = ccp(_contentSize.width+borderWidth, _contentSize.height+borderWidth);
  trCorner.flipX = YES;
  trCorner.flipY = YES;
  trCorner.anchorPoint = ccp(1, 1);
  
  float borderScaleX = _contentSize.width-2*(cornerSize.width-borderWidth);
  float borderScaleY = _contentSize.height-2*(cornerSize.height-borderWidth);
  leftBorder.scaleY = borderScaleY; leftBorder.anchorPoint = ccp(1, 0.5);
  rightBorder.scaleY = borderScaleY; rightBorder.anchorPoint = ccp(0, 0.5);
  botBorder.scaleY = borderScaleX; botBorder.rotation = 90; botBorder.anchorPoint = ccp(0, 0.5);
  topBorder.scaleY = borderScaleX; topBorder.rotation = 90; topBorder.anchorPoint = ccp(1, 0.5);
  
  leftBorder.position = ccp(0, self.contentSize.height/2);
  rightBorder.position = ccp(self.contentSize.width, self.contentSize.height/2);
  botBorder.position = ccp(self.contentSize.width/2, 0);
  topBorder.position = ccp(self.contentSize.width/2, self.contentSize.height);
  
  int z = 0;
  int z2 = 100;
  [self addChild:leftBorder z:z];
  [self addChild:rightBorder z:z];
  [self addChild:botBorder z:z];
  [self addChild:topBorder z:z];
  [self addChild:blCorner z:z2];
  [self addChild:brCorner z:z2];
  [self addChild:tlCorner z:z2];
  [self addChild:trCorner z:z2];
}

- (TileSprite*) spriteForTile:(BattleTile *)tile depth:(TileDepth)depth{
  if (depth == TileDepthTop)
    return (TileSprite*)[_tilesLayerTop getChildByName:tile.description recursively:NO];
  else
    return (TileSprite*)[_tilesLayerBottom getChildByName:tile.description recursively:NO];
}

- (void) updateTile:(BattleTile*)tile
{
  TileSprite* spriteTop = [self spriteForTile:tile depth:TileDepthTop];
  if (spriteTop)
    [spriteTop updateSprite];
  TileSprite* spriteBottom = [self spriteForTile:tile depth:TileDepthBottom];
  if (spriteBottom)
    [spriteBottom updateSprite];
}

@end
