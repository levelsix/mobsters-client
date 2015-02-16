//
//  SkillKnockout.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/27/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerActive.h"

@interface SkillKnockout : SkillControllerActive
{
  // Properties (defensive)
  NSInteger _numOrbsToSpawn;
  NSInteger _orbsSpawnCounter;
  int _fixedDamageReceived;
  
  // Properties (offensive)
  int _fixedDamageDone;
  
  // Properties (general)
  int _enemyHealthThreshold;
  
  // Temp
  BOOL _logoShown;
  NSInteger _orbsSpawned;
  int _orbsConsumed;
}

@end
