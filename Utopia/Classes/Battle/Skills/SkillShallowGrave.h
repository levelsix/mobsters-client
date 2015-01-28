//
//  SkillShallowGrave.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/27/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerActive.h"

@interface SkillShallowGrave : SkillControllerActive
{
  // Properties (both)
  int _minHPAllowed;
  
  // Properties (offensive)
  int _numTurnsToRemainActive;
  
  // Properties (defensive)
  int _graveSpawnCount;
  
  // Temp
  BOOL _logoShown;
  
  // Counters
  BOOL _skillActive;
  int _turnsLeft;
}

@end
