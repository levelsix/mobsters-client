//
//  SkillMomentum.h
//  Utopia
//
//  Created by Mikhail Larionov on 9/22/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerActiveBuff.h"

@interface SkillMomentum : SkillControllerActiveBuff
{
  // Properties
  float _damageMultiplier;
  float _sizeMultiplier;
  float _sizeCap;

  // Counters
  float _currentMultiplier;
  float _currentSizeMultiplier;
}

@end
