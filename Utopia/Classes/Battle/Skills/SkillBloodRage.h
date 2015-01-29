//
//  SkillBloodRage.h
//  Utopia
//
//  Created by Rob Giusti on 1/29/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillControllerActive.h"

@interface SkillBloodRage : SkillControllerActive
{
  // Properties
  float _damageGivenMultiplier;
  float _damageTakenMultiplier;
  
  // Counters
  BOOL _ragedNow;
  BOOL _wasRaged;
}

@end
