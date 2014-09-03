//
//  RWTTile.m
//  CookieCrunch
//
//  Created by Matthijs on 26-02-14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "BattleTile.h"

@implementation BattleTile

-(id) initWithColumn:(NSInteger)column row:(NSInteger)row typeTop:(TileType)typeTop typeBottom:(TileType)typeBottom
{
  self = [super init];
  if (! self)
    return nil;
  
  _column = column;
  _row = row;
  _tileTypeTop = typeTop;
  _tileTypeBottom = typeBottom;
  
  return self;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%d-%d", (int)self.column, (int)self.row];
}

- (BOOL) allowsDamage
{
  if (_tileTypeBottom == TileTypeJelly)
    return NO;
  return YES;
}

- (void) orbRemoved
{
  if (_tileTypeBottom == TileTypeJelly)
    _tileTypeBottom = TileTypeNormal;
}

@end
