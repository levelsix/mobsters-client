//
//  TileSprite.h
//  Utopia
//
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <CCSprite.h>
#import "BattleTile.h"

static const float tileUpdateAnimDuration = 0.3f;

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

@property (nonatomic, strong, readonly) CCSprite* arrow;

+ (TileSprite*) tileSpriteWithTile:(BattleTile*)tile depth:(TileDepth)depth;

- (void) updateSprite;

- (void) updateArrowSprite:(BOOL)arrowsOn;

@end
