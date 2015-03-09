//
//  SkillFlameBreak.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 2/4/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerActive.h"

@interface SkillFlameBreak : SkillControllerActive
{
  // Properties (general)
  float _maxDamage;
  NSInteger _maxStunTurns;
  
  // Properties (defensive)
  NSInteger _numOrbsToSpawn;
  NSInteger _orbsSpawnCounter;
  
  // Temp
  BOOL _logoShown;
  NSInteger _orbsSpawned;
  int _damageDone;
  int _damageReceived;
}

@end
