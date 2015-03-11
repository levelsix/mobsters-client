//
//  SkillEnergize.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 2/2/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillControllerSpecialOrb.h"

@interface SkillEnergize : SkillControllerSpecialOrb
{
  // Properties (general)
  float _speedIncrease;
  float _attackIncrease;
  
  // Temp
  int _initialSpeed;
  
  // Counters
  float _curSpeedMultiplier;
  float _curAttackMultiplier;
}

@end
