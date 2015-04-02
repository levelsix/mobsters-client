//
//  TileSprite.m
//  Utopia
//
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TileSprite.h"
#import <cocos2d/cocos2d.h>
#import "Globals.h"

#define IPHONE_5_TILE_SIZE 36
#define IPHONE_6_TILE_SIZE 42
#define IPHONE_6_PLUS_TILE_SIZE 47



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
  
  if (tile.bottomFallsOut)
    [self loadArrowSprite];
    
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
  
  if (_arrow)
  {
    [self removeChild:_arrow cleanup:YES];
    _arrow = nil;
  }
  
  NSString *resPrefix = [Globals isiPhone6] || [Globals isiPhone6Plus] ? @"6" : @"";
  
  // Check if this tile is not empty
  NSString* imageName;
  switch (_tileType)
  {
    case TileTypeJelly:
      imageName = @"boardgoo.png";
      break;
    case TileTypeMud:
      imageName = @"boardmud.png";
      break;
      
    default: break;
  }
  
  // Load image
  if (imageName)
  {
    _sprite = [CCSprite spriteWithImageNamed:[resPrefix stringByAppendingString:imageName]];
    _sprite.scale = 0.0;
    float finalScale = [Globals isiPhone6Plus] ? 1.1 : 1;
    [self addChild:_sprite];
    [_sprite runAction:[CCActionSequence actions:
                        [CCActionEaseOut actionWithAction:[CCActionScaleTo actionWithDuration:tileUpdateAnimDuration scale:finalScale]],
                        nil]];
  }
}

- (void) loadArrowSprite {
  if (!_arrow) {
    _arrow = [CCSprite spriteWithImageNamed:@"bringdownarrow@2x.png"];
    _arrow.scale = 0.0;
    [self addChild:_arrow];
    
    int tileSize = [Globals isiPhone6] ? IPHONE_6_TILE_SIZE : [Globals isiPhone6Plus] ? IPHONE_6_PLUS_TILE_SIZE : IPHONE_5_TILE_SIZE;
    _arrow.position = ccp(0, -tileSize/2);
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

- (void)updateArrowSprite:(BOOL)arrowsOn {
  if (_arrow)
    [_arrow runAction:[CCActionScaleTo actionWithDuration:tileUpdateAnimDuration scale:arrowsOn?1:0]];
}

@end
