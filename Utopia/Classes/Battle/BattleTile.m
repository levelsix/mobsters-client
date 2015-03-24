//
//  RWTTile.m
//  CookieCrunch
//
//  Created by Matthijs on 26-02-14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "BattleTile.h"

@implementation BattleTile

-(id) initWithColumn:(NSInteger)column row:(NSInteger)row typeTop:(TileType)typeTop typeBottom:(TileType)typeBottom isHole:(BOOL)isHole canPassThrough:(BOOL)canPassThrough canSpawnOrbs:(BOOL)canSpawnOrbs shouldSpawnInitialSkill:(BOOL)shouldSpawnInitialSkill bottomFallsOut:(BOOL)bottomFallsOut
{
  self = [super init];
  if (! self)
    return nil;
  
  _column = column;
  _row = row;
  _typeTop = typeTop;
  _typeBottom = typeBottom;
  
  _isHole = isHole;
  _canPassThrough = canPassThrough;
  
  _canSpawnOrbs = canSpawnOrbs;
  
  _bottomFallsOut = bottomFallsOut;
  
  _shouldSpawnInitialSkill = shouldSpawnInitialSkill;
  
  return self;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%d-%d", (int)self.column, (int)self.row];
}

- (BOOL) allowsDamage
{
  if (_typeBottom == TileTypeJelly || _typeBottom == TileTypeMud)
    return NO;
  return YES;
}

- (void) orbRemoved
{
  if (_typeBottom == TileTypeJelly || _typeBottom == TileTypeMud)
    _typeBottom = TileTypeNormal;
}

- (BOOL) isBlocked {
  return self.isHole && !self.canPassThrough;
}

#define TILE_TOP_KEY      @"TileTopKey"
#define TILE_BOT_KEY      @"TileBotKey"
#define IS_HOLE_KEY       @"IsHoleKey"
#define PASS_THROUGH_KEY  @"PassThrough"
#define CAN_SPAWN_KEY     @"CanSpawnKey"
#define SPAWN_INIT_KEY    @"SpawnInitKey"

- (NSDictionary*) serialize
{
  NSMutableDictionary* info = [NSMutableDictionary dictionary];
  [info setObject:@(_typeTop) forKey:TILE_TOP_KEY];
  [info setObject:@(_typeBottom) forKey:TILE_BOT_KEY];
  [info setObject:@(_isHole) forKey:IS_HOLE_KEY];
  [info setObject:@(_canPassThrough) forKey:PASS_THROUGH_KEY];
  [info setObject:@(_canSpawnOrbs) forKey:CAN_SPAWN_KEY];
  [info setObject:@(_shouldSpawnInitialSkill) forKey:SPAWN_INIT_KEY];
  return info;
}

- (void) deserialize:(NSDictionary*)dic
{
  NSNumber* typeTop = [dic objectForKey:TILE_TOP_KEY];
  NSNumber* typeBot = [dic objectForKey:TILE_BOT_KEY];
  NSNumber* isHole = [dic objectForKey:IS_HOLE_KEY];
  NSNumber* canPass = [dic objectForKey:PASS_THROUGH_KEY];
  NSNumber* canSpawn = [dic objectForKey:CAN_SPAWN_KEY];
  NSNumber* spawnInitialSkill = [dic objectForKey:SPAWN_INIT_KEY];
  
  if (typeTop)
    _typeTop = (TileType)[typeTop integerValue];
  if (typeBot)
    _typeBottom = (TileType)[typeTop integerValue];
  if (isHole)
    _isHole = [isHole boolValue];
  if (canPass)
    _canPassThrough = [canPass boolValue];
  if (canSpawn)
    _canSpawnOrbs = [canSpawn boolValue];
  if (spawnInitialSkill)
    _shouldSpawnInitialSkill = [spawnInitialSkill boolValue];
  
}

@end
