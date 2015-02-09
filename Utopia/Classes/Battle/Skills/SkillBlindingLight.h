//
//  SkillBlindingLight.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/26/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerActiveBuff.h"

@interface SkillBlindingLight : SkillControllerActiveBuff
{
  // Properties
  int _fixedDamageDone;
  float _missChance;
  
  // Temp
  BOOL _logoShown;
  BOOL _missed;
}

@end
