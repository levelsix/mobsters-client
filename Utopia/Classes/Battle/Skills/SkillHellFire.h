//
//  SkillHellFire.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/30/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerPassive.h"

@interface SkillHellFire : SkillControllerPassive
{
  // Properties
  NSInteger _numOrbsToSpawn;
  NSInteger _orbsSpawnCounter;
  float _fixedDamageReceived;
  
  // Temp
  BOOL _logoShown;
  NSInteger _orbsSpawned;
}

@end
