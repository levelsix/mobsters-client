//
//  SkillHeadshot.h
//  Utopia
//
//  Created by Behrouz N. on 12/11/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerActive.h"

@interface SkillHeadshot : SkillControllerActive
{
  // Properties (general)
  NSInteger _numOrbsToSpawn;
  
  // Properties (defensive)
  NSInteger _orbsSpawnCounter;
  float _fixedDamageReceived;
  
  // Properties (offensive)
  float _fixedDamageDone;
  
  // Temp
  BOOL _logoShown;
  NSInteger _orbsSpawned;
}

@end
