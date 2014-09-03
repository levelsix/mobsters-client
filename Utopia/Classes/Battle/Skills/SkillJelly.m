//
//  SkillJelly.m
//  Utopia
//
//  Created by Mikhail Larionov on 9/2/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillJelly.h"

@implementation SkillJelly

- (void) setDefaultValuesForProperties
{
  _initialCount = 1;
  _spawnCount = 1;
  _spawnTurns = 1;
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

@end
