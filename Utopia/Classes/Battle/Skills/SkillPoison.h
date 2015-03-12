//
//  SkillPoison.h
//  Utopia
//
//  Created by Mikhail Larionov on 9/18/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerSpecialOrb.h"

@interface SkillPoison : SkillControllerSpecialOrb
{
  // Properties
  NSInteger _orbDamage;
  
  // Counters
  int _tempDamageDealt;
}

@end
