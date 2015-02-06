//
//  SkillMomentum.h
//  Utopia
//
//  Created by Mikhail Larionov on 9/22/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerActive.h"

@interface SkillMomentum : SkillControllerActive
{
  // Properties
  float _damageMultiplier;
  float _sizeMultiplier;

  // Counters
  float _currentMultiplier;
  float _currentSizeMultiplier;
  
  // Temp
  BOOL  _logoShown;
}

@end
