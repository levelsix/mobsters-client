//
//  SkillTakeAim.h
//  Utopia
//
//  Created by Rob Giusti on 1/29/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillControllerSpecialOrb.h"

@interface SkillTakeAim : SkillControllerSpecialOrb
{
  float _critChancePerOrb;
  float _critDamageMultiplier;
  
  float _playerCritChance;
  
  int _playerCritStacks;
}

@end
