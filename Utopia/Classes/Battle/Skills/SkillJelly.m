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
  [super setDefaultValues];
  _initialCount = 1;
  _spawnCount = 1;
  _spawnTurns = 1;
  
  // Counters
  _turnCounter = 0;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
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
    [self showSkillPopupOverlayWithCompletion:^{
      [self spawnInitialJelly];
    }];
    return YES;
  }
  
  if (trigger == SkillTriggerPointStartOfEnemyTurn)
  {
    [self spawnNewJelly];
    return YES;
  }
  
  return NO;
}

#pragma mark - Skill logic

- (void) spawnRandomJellyWithCallback:(SEL)callback
{
  // Find the tile
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  BattleTile* tile;
  NSInteger counter = 0;
  do {
    NSInteger row = rand() % layout.numRows;  // Rand here is calculated using the seed from spawnNextBatch
    NSInteger col = rand() % layout.numColumns;
    tile = [layout tileAtColumn:col row:row];
    counter++;
  } while (tile.typeBottom != TileTypeNormal && counter < 10000);
  
  // Counter of 10k means there're no empty tiles
  if (counter < 10000)
  {
    // Update model
    tile.typeBottom = TileTypeJelly;
  
    // Update visuals
    OrbBgdLayer* bgdLayer = self.battleLayer.orbLayer.bgdLayer;
    [bgdLayer updateTile:tile withTarget:self andCallback:callback];
  }
}

- (void) spawnNextBatch
{
  // Calculating seed for pseudo-random generation (so upon deserialization pattern will be the same)
  NSInteger seed = 0;
  for (NSInteger n = 0; n < self.battleLayer.orbLayer.layout.numColumns; n++)
    for (NSInteger m = 0; m < self.battleLayer.orbLayer.layout.numRows; m++)
      seed += [self.battleLayer.orbLayer.layout orbAtColumn:n row:m].orbColor;
  srand(seed);
  
  NSInteger counter = 500;  // Change it to enable batching, now it's disabled. Counter reflects the batch size (say, 3)
  if ( _spawnCounter < counter )
    counter = _spawnCounter;
  _spawnCounter -= counter;
  for (NSInteger n = 0; n < counter; n++)
  {
    SEL callback = nil;
    if (n == counter - 1) // last item from the batch
    {
      if (_spawnCounter == 0) // last batch
        callback = @selector(skillTriggerFinished);
      else
        callback = @selector(spawnNextBatch);
    }
    [self spawnRandomJellyWithCallback:callback];
  }
}

- (void) spawnInitialJelly
{
  // Spawn initial jelly skills
  _spawnCounter = _initialCount;
  [self spawnNextBatch];
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
  _spawnCounter = _spawnCount;
  _turnCounter = 0;
  [self spawnNextBatch];
}

#pragma mark - Serialization

- (NSDictionary*) serialize
{
  NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
  [result setObject:@(_turnCounter) forKey:@"turnCounter"];
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (! [super deserialize:dict])
    return NO;
  
  NSNumber* turnCounter = [dict objectForKey:@"turnCounter"];
  if (turnCounter)
    _turnCounter = [turnCounter integerValue];
  
  return YES;
}


@end
