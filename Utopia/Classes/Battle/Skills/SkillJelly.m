//
//  SkillJelly.m
//  Utopia
//
//  Created by Mikhail Larionov on 9/2/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillJelly.h"
#import "NewBattleLayer.h"

@implementation SkillJelly

#pragma mark - Initialization

- (void) setDefaultValues
{
  // Properties
  _initialCount = 1;
  _spawnCount = 1;
  _spawnTurns = 1;
  
  // Temporary variables
  _turnCounter = 0;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  if ( [property isEqualToString:@"SPAWN_TURNS"] )
    _spawnTurns = value;
  else if ( [property isEqualToString:@"SPAWN_COUNT"] )
    _spawnCount = value;
  else if ( [property isEqualToString:@"INITIAL_COUNT"] )
    _initialCount = value;
}

#pragma mark - Overrides

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger
{
  if (trigger == SkillTriggerPointEnemyAppeared)
  {
    [self spawnInitialJelly];
    [self skillTriggerFinished];
    return YES;
  }
  
  if (trigger == SkillTriggerPointStartOfEnemyTurn)
  {
    [self spawnNewJelly];
    [self skillTriggerFinished];
    return YES;
  }
  
  return NO;
}

#pragma mark - Skill logic

- (void) spawnRandomJelly
{
  // Find the tile
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  BattleTile* tile;
  NSInteger counter = 0;
  do {
    NSInteger row = arc4random() % layout.numRows;
    NSInteger col = arc4random() % layout.numColumns;
    tile = [layout tileAtColumn:col row:row];
    counter++;
  } while (tile.typeBottom != TileTypeNormal && counter < 10000);
  
  if (counter < 10000)
  {
    // Update model
    tile.typeBottom = TileTypeJelly;
  
    // Update visuals
    OrbBgdLayer* bgdLayer = self.battleLayer.orbLayer.bgdLayer;
    [bgdLayer updateTile:tile];
  }
}

- (void) spawnInitialJelly
{
  for (NSInteger n = 0; n < _initialCount; n++)
    [self spawnRandomJelly];
}

- (void) spawnNewJelly
{
  // Check for the turn
  if (_turnCounter < _spawnTurns - 1)
  {
    _turnCounter++;
    return;
  }
  
  // Spawn and reset turn counter
  for (NSInteger n = 0; n < _spawnCount; n++)
    [self spawnRandomJelly];
  _turnCounter = 0;
}

@end
