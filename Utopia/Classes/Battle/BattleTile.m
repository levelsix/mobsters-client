//
//  RWTTile.m
//  CookieCrunch
//
//  Created by Matthijs on 26-02-14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "BattleTile.h"

@implementation BattleTile

-(id) initWithColumn:(NSInteger)column row:(NSInteger)row typeTop:(TileType)typeTop typeBottom:(TileType)typeBottom isHole:(BOOL)isHole canPassThrough:(BOOL)canPassThrough canSpawnOrbs:(BOOL)canSpawnOrbs shouldSpawnInitialSkill:(BOOL)shouldSpawnInitialSkill
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

@end
