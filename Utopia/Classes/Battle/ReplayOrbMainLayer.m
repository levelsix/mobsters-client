//
//  ReplayOrbMainLayer.m
//  Utopia
//
//  Created by Rob Giusti on 4/30/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReplayOrbMainLayer.h"
#import "ReplayBattleOrbLayout.h"

@implementation ReplayOrbMainLayer

- (id)initWithLayoutProto:(BoardLayoutProto *)proto andHistory:(NSArray *)orbHistory {
  ReplayBattleOrbLayout *layout = [[ReplayBattleOrbLayout alloc] initWithBoardLayout:proto andOrbHistory:orbHistory];
  return [self initWithGridSize:CGSizeMake(layout.numColumns, layout.numRows) numColors:layout.numColors layout:layout];
}

- (id)initWithGridSize:(CGSize)gridSize numColors:(int)numColors andHistory:(NSArray *)orbHistory {
  ReplayBattleOrbLayout *layout = [[ReplayBattleOrbLayout alloc] initWithGridSize:gridSize numColors:numColors andOrbHistory:orbHistory];
  return [self initWithGridSize:gridSize numColors:numColors layout:layout];
}

- (id)initWithGridSize:(CGSize)gridSize userBoardObstacles:(NSArray *)userBoardObstacles andHistory:(NSArray*)orbHistory {
  ReplayBattleOrbLayout *layout = [[ReplayBattleOrbLayout alloc] initWithGridSize:gridSize userBoardObstacles:userBoardObstacles andHistory:orbHistory];
  return [self initWithGridSize:gridSize numColors:layout.numColors layout:layout];
}

- (void) tapDownOnSpace:(int)x spaceY:(int)y {
  BattleOrb* orb = [self.layout orbAtColumn:x row:y];
  BattleTile* tile = [self.layout tileAtColumn:x row:y];
  [self tapDownOnOrb:orb tile:tile];
}

@end