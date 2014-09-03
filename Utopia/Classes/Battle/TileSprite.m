//
//  TileSprite.m
//  Utopia
//
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TileSprite.h"

@implementation TileSprite

+ (TileSprite*) tileSpriteWithTile:(BattleTile*)tile depth:(TileDepth)depth
{
  return [[TileSprite alloc] initWithTile:tile depth:depth];
}

- (id) initWithTile:(BattleTile*)tile depth:(TileDepth)depth
{
  // Super init
  self = [super init];
  if ( ! self )
    return nil;
  
  _tile = tile;
  _depth = depth;
  if (_depth == TileDepthTop)
    _tileType = tile.tileTypeTop;
  else
    _tileType = tile.tileTypeBottom;
  
  // Check if this tile is empty
  if (_tileType == TileTypeNormal)
    return nil;
  
  // Reload sprite
  [self reloadSprite];
  
  return self;
}

- (void) reloadSprite
{
  // Remove previous
  if (_sprite)
  {
    [_sprite removeFromParent];
    _sprite = nil;
  }
  
  // Check if this tile is not empty
  NSString* imageName;
  switch (_tileType)
  {
    case TileTypeJelly:
      imageName = @"jellypiece.png";
      break;
      
    default: break;
  }
  
  // Load image
  if (imageName)
  {
    _sprite = [CCSprite spriteWithImageNamed:imageName];
    [self addChild:_sprite];
  }
}

- (void) updateSprite
{
  TileType oldType = _tileType;
  if (_depth == TileDepthTop)
    _tileType = _tile.tileTypeTop;
  else
    _tileType = _tile.tileTypeBottom;
  
  if (oldType != _tileType)
    [self reloadSprite];
}

@end
