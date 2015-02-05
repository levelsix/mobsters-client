//
//  SkillKnockout.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/27/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerActive.h"

@interface SkillKnockout : SkillControllerActive
{
  // Properties
  int _enemyHealthThreshold;
  int _fixedDamageDone;
  
  // Temp
  BOOL _logoShown;
}

@end
