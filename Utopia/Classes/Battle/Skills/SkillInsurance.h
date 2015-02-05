//
//  SkillInsurance.h
//  Utopia
//
//  Created by Rob Giusti on 2/4/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillControllerActive.h"

@interface SkillInsurance : SkillControllerActive
{
  float _damageTakenMultiplier;
  int _duration;
  
  int _turnsLeft;
}

@end
