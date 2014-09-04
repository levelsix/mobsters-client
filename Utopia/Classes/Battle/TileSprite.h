//
//  TileSprite.h
//  Utopia
//
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <CCSprite.h>
#import "BattleTile.h"

typedef enum {
  TileDepthTop,
  TileDepthBottom
} TileDepth;

@interface TileSprite : CCNode
{
  BattleTile* _tile;
  TileType    _tileType;
}

@property (nonatomic, strong, readonly) CCSprite* sprite;
@property (nonatomic, assign, readonly) TileDepth depth;

+ (TileSprite*) tileSpriteWithTile:(BattleTile*)tile depth:(TileDepth)depth;

- (void) updateSprite;

@end
