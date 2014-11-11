//
//  SkillPoison.h
//  Utopia
//
//  Created by Mikhail Larionov on 9/18/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerPassive.h"

@interface SkillPoison : SkillControllerPassive
{
  // Properties
  NSInteger _orbDamage;
  
  // Counters
  NSInteger _tempDamageDealt;
}

@end
