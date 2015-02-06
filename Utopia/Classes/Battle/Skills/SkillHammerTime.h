//
//  SkillHammerTime.h
//  Utopia
//
//  Created by Rob Giusti on 1/28/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillControllerActive.h"

@interface SkillHammerTime : SkillControllerActive
{
  // Properties
  float _chance;
  int _stunTurns;
  int _duration;
  
  // Counters
  int _stunTurnsLeft;
  int _skillTurnsLeft;
}

@end