//
//  SkillJelly.m
//  Utopia
//
//  Created by Mikhail Larionov on 9/2/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillJelly.h"
#import "NewBattleLayer.h"

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 * DEPRECATION WARNING
 *
 * For now there are no plans to use this skill in the near
 * future, so the code has not been updated with the recent
 * changes to skills (orb-activated, duration, logo, etc.)
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

@implementation SkillJelly

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  _initialCount = 1;
  _spawnCount = 1;
  _spawnTurns = 1;
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

- (id) initWithProto:(SkillProto*)proto andMobsterColor:(OrbColor)color
{
  self = [super initWithProto:proto andMobsterColor:color];
  if ( ! self )
    return nil;
  
  _turnCounter = 0;
  
  return self;
}

#pragma mark - Overrides

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if (trigger == SkillTriggerPointEnemyAppeared)
  {
    if (execute)
    {
      [self showSkillPopupOverlay:YES withCompletion:^{
        [self spawnInitialJelly];
      }];
    }
    return YES;
  }
  
  if (trigger == SkillTriggerPointStartOfEnemyTurn)
  {
    // Check for the turn
    if (_turnCounter == 0 || _turnCounter < _spawnTurns - 1)
    {
      if (execute)
        _turnCounter++;
      return NO;
    }
    else // Jumping owner and jelly spawning
    {
      if (execute)
        [self makeSkillOwnerJumpWithTarget:self selector:@selector(spawnNewJelly)];
    }
    
    return YES;
  }
  
  return NO;
}

- (void) skillTriggerFinished
{
  if (_currentTrigger == SkillTriggerPointStartOfEnemyTurn) // This is to let jellies update before we'll proceed
  {
    [self performBlockAfterDelay:0.7 block:^{
      [super skillTriggerFinished];
    }];
  }
  else
    [super skillTriggerFinished];
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
    BOOL keepLit;
    if (_currentTrigger == SkillTriggerPointStartOfEnemyTurn)
      keepLit = NO;
    else
      keepLit = [self.battleLayer.battleSchedule nextTurnIsPlayers];
    [bgdLayer updateTile:tile keepLit:keepLit withTarget:self andCallback:callback];
  }
  else
    if (callback)
      SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(
      [self performSelector:callback]; );
}

- (void) spawnNextBatch
{
  // Calculating seed for pseudo-random generation (so upon deserialization pattern will be the same)
  [self preseedRandomization];
  
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
  [self performSelector:@selector(spawnNextBatch) withObject:nil afterDelay:0.5];
}

- (void) spawnNewJelly
{
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
