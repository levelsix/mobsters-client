//
//  SkillTakeAim.h
//  Utopia
//
//  Created by Rob Giusti on 1/29/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillControllerActiveBuff.h"

@interface SkillTakeAim : SkillControllerActiveBuff
{
  NSInteger _numOrbsToSpawn;
  NSInteger _maxOrbs;
  
  float _critChancePerOrb;
  float _critDamageMultiplier;
  
  float _playerCritChance;
  
  NSInteger _orbsSpawned;
}

@end
