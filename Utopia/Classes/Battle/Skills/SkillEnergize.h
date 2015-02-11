//
//  SkillEnergize.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 2/2/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillControllerActiveBuff.h"

@interface SkillEnergize : SkillControllerActiveBuff
{
  // Properties (general)
  float _speedIncrease;
  float _attackIncrease;
  
  // Properties (defensive)
  NSInteger _numOrbsToSpawn;
  NSInteger _orbsSpawnCounter;
  
  // Temp
  int _initialSpeed;
  NSInteger _orbsSpawned;
  BOOL _logoShown;
  
  // Counters
  float _curSpeedMultiplier;
  float _curAttackMultiplier;
}

@end
