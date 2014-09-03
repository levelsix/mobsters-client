//
//  OrbBackgroundLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/15/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "BattleOrbLayout.h"

@interface OrbBgdLayer : CCNode
{
  CCNode* _tilesLayerBottom;
  CCNode* _tilesLayerTop;
}

- (id) initWithGridSize:(CGSize)gridSize layout:(BattleOrbLayout *)layout;

- (void) updateTile:(BattleTile*)tile;

@end
