//
//  SkillBlindingLight.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/26/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerActive.h"

@interface SkillBlindingLight : SkillControllerActive
{
  // Properties
  int _fixedDamageDone;
  float _missChance;
  
  // Temp
  BOOL _logoShown;
  BOOL _skillActive;
  BOOL _missed;
}

@end
