//
//  SkillCritAndEvade.h
//  Utopia
//
//  Created by Behrouz N. on 12/9/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerActiveBuff.h"

@interface SkillCritAndEvade : SkillControllerActiveBuff
{
  // Properties
  float _critChance;
  float _critMultiplier;
  float _evadeChance;
  float _missChance;
  SideEffectType _sideEffectType;
  
  // Temp
  BOOL _logoShown;
  BOOL _criticalHit;
  BOOL _evaded;
  BOOL _missed;
}

@end
