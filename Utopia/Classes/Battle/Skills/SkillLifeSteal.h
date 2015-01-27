//
//  SkillLifeSteal.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/20/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerPassive.h"

@interface SkillLifeSteal : SkillControllerPassive
{
  // Properties (general)
  NSInteger _numOrbsToSpawn;
  float _lifeStealAmount;
  
  // Temp
  BOOL _logoShown;
  NSInteger _orbsSpawned;
}

@end
