//
//  SkillEnergize.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 2/2/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillControllerActive.h"

@interface SkillEnergize : SkillControllerActive
{
  // Properties
  float _speedIncrease;
  float _attackIncrease;
  
  // Temp
  int _initialSpeed;
  BOOL _logoShown;
  
  // Counters
  float _curSpeedMultiplier;
  float _curAttackMultiplier;
}

@end
