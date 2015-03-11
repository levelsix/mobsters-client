//
//  SkillKnockout.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/27/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerSpecialOrb.h"

@interface SkillKnockout : SkillControllerSpecialOrb
{
  // Properties (defensive)
  int _fixedDamageReceived;
  
  // Properties (offensive)
  int _fixedDamageDone;
  
  // Properties (general)
  int _enemyHealthThreshold;
  
  // Temp
  int _orbsConsumed;
}

@end
