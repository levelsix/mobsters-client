//
//  SkillControllerSpecialOrb.h
//  Utopia
//
//  Created by Rob Giusti on 2/23/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillControllerSplitOffDef.h"

typedef enum {
  SpecialOrbSpawnAnywhere = 0,
  SpecialOrbSpawnTop = 1,
  SpecialOrbSpawnColor = 2
} SpecialOrbSpawnZone;

@interface SkillControllerSpecialOrb : SkillControllerSplitOffDef
{
  NSInteger _orbsPerSpawn;
  NSInteger _maxOrbs;
  NSInteger _orbsSpawned;
}

- (SpecialOrbType) specialType;
- (SpecialOrbSpawnZone) spawnZone;
- (BOOL) keepColor;

- (BOOL) onSpecialOrbCounterFinish:(NSInteger)numOrbs;

- (void) spawnSpecialOrbs:(NSInteger)count withTarget:(id)target andSelector:(SEL)selector;
- (void) removeSpecialOrbs;
- (BOOL) checkSpecialOrbs;

@property (readonly) NSInteger orbSpawnCounter;

@end