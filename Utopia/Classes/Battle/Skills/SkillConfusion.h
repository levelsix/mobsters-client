//
//  SkillConfusion.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/22/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerActive.h"

@interface SkillConfusion : SkillControllerActive
{
  // Properties
  float _chanceToHitSelf;
  
  // Temp
  BOOL _skillActive;
  BOOL _logoShown;
}

@end
