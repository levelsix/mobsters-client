//
//  SkillFlameStrike.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/21/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerActive.h"

@interface SkillFlameStrike : SkillControllerActive
{
  // Properties
  int _numAffectedMoves;
  float _damageMultiplier;
  
  // Temp
  BOOL _skillActive;
  int _remainingMoves;
  BOOL _logoShown;
}

@end
