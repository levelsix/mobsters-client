//
//  TileSprite.m
//  Utopia
//
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TileSprite.h"
#import <cocos2d/cocos2d.h>

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
    _tileType = tile.typeTop;
  else
    _tileType = tile.typeBottom;
  
  // Reload sprite
  [self reloadSprite];
  
  return self;
}

- (void) reloadSprite
{
  // Remove previous
  if (_sprite)
  {
    [_sprite runAction:[CCActionSequence actions:
                              [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:tileUpdateAnimDuration scale:0.0]],
                              [CCActionRemove action],
                              nil]];
  }
  
  // Check if this tile is not empty
  NSString* imageName;
  switch (_tileType)
  {
    case TileTypeJelly:
      imageName = @"boardgoo.png";
      break;
      
    default: break;
  }
  
  // Load image
  if (imageName)
  {
    _sprite = [CCSprite spriteWithImageNamed:imageName];
    _sprite.scale = 0.0;
    [self addChild:_sprite];
    [_sprite runAction:[CCActionSequence actions:
                        [CCActionEaseOut actionWithAction:[CCActionScaleTo actionWithDuration:tileUpdateAnimDuration scale:1.0]],
                        nil]];
  }
}

- (void) updateSprite
{
  TileType oldType = _tileType;
  if (_depth == TileDepthTop)
    _tileType = _tile.typeTop;
  else
    _tileType = _tile.typeBottom;
  
  if (oldType != _tileType)
    [self reloadSprite];
}

@end
