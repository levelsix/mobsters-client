//
//  SkillRightHook.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 2/3/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerSpecialOrb.h"

@interface SkillRightHook : SkillControllerSpecialOrb
{
  // Properties (defensive)
  float _fixedDamageReceived;
  
  // Properties (offensive)
  float _fixedDamageDone;
  
  // Properties (general)
  float _targetChanceToHitSelf;
}

@end
