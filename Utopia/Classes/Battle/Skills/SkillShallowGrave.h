//
//  SkillShallowGrave.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/27/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerActiveBuff.h"

@interface SkillShallowGrave : SkillControllerActiveBuff
{
  // Properties (both)
  int _minHPAllowed;
  
  // Properties (defensive)
  int _graveSpawnCount;
  
  // Temp
  BOOL _logoShown;
}

@end
