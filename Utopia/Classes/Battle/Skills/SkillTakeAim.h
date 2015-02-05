//
//  SkillTakeAim.h
//  Utopia
//
//  Created by Rob Giusti on 1/29/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillControllerActive.h"

@interface SkillTakeAim : SkillControllerActive
{
  NSInteger _numOrbsToSpawn;
  NSInteger _maxOrbs;
  
  float _critChancePerOrb;
  float _critDamageMultiplier;
  
  NSInteger _orbsSpawned;
}

@end
