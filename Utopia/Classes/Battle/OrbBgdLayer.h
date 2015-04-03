//
//  OrbBackgroundLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/15/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "BattleOrbLayout.h"

static const float darknessForTilesOpacity = 0.6f;
static const float darknessForTilesAnimDuration = 0.3f;

@interface OrbBgdLayer : CCNode
{
  __weak BattleOrbLayout* _layout;
  CGSize _gridSize;
  
  CCNode* _tilesLayerMain;
  CCNode* _tilesLayerBottom;
  CCNode* _tilesLayerTop;
  CCNode* _tilesLayerDarkness;
  
  CCNode *_borderNode;
}

- (id) initWithGridSize:(CGSize)gridSize layout:(BattleOrbLayout *)layout;

// In case we want a bgd without the border (i.e. the clipping node stencil)
- (void) assembleBorder;

- (void) updateForPuttyWithTile:(BattleTile *)tile;

- (void) updateTile:(BattleTile*)tile;
- (void) updateTile:(BattleTile*)tile keepLit:(BOOL)keepLit withTarget:(id)target andCallback:(SEL)callback;
- (void) updateArrowForTile:(BattleTile*)tile arrow:(BOOL)arrow;

- (void) turnTheLightsOn;
- (void) turnTheLightsOff;
- (void) turnTheLights:(BOOL)on instantly:(BOOL)instantly;

- (void) reloadTiles;

- (void) playVineExpansion:(NSString*)directionString onTile:(BattleTile*)tile withCompletion:(void(^)())withCompletion;

@end
