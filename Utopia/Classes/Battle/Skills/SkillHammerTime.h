//
//  SkillHammerTime.h
//  Utopia
//
//  Created by Rob Giusti on 1/28/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillControllerPassive.h"

@interface SkillHammerTime : SkillControllerPassive
{
  // Properties
  float _chance;
  int _stunTurns;
  
  // Counters
  int _turnsLeft;
}

@end