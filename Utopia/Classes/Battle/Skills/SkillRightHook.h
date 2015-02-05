//
//  SkillRightHook.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 2/3/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerActive.h"

@interface SkillRightHook : SkillControllerActive
{
  // Properties (defensive)
  NSInteger _numOrbsToSpawn;
  NSInteger _orbsSpawnCounter;
  float _fixedDamageReceived;
  
  // Properties (offensive)
  float _fixedDamageDone;
  
  // Properties (general)
  float _targetChanceToHitSelf;
  
  // Temp
  BOOL _logoShown;
  NSInteger _orbsSpawned;
  
  // Counters
  BOOL _skillActive;
  NSInteger _confusionTurns;
}

@end
