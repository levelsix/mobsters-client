//
//  SkillCakeDrop.h
//  Utopia
//
//  Created by Mikhail Larionov on 9/8/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerPassive.h"

@interface SkillCakeDrop : SkillControllerPassive
{
  // Properties
  NSInteger _minCakes;
  NSInteger _maxCakes;
  float     _initialSpeed;
  float     _speedMultiplier;
  float     _cakeChance;
}

@end
