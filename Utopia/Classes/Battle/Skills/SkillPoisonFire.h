//
//  SkillPoisonFire.h
//  Utopia
//
//  Created by Rob Giusti on 2/11/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillControllerSpecialOrb.h"

@interface SkillPoisonFire : SkillControllerSpecialOrb
{
  int _poisonStacks;
  int _quickAttackStacks;
  int _initialDamage;
  int _poisonDamage;
  int _poisonPercent;
}

@end
