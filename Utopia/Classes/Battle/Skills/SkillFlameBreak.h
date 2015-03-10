//
//  SkillFlameBreak.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 2/4/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerSpecialOrb.h"

@interface SkillFlameBreak : SkillControllerSpecialOrb
{
  // Properties (general)
  float _maxDamage;
  NSInteger _maxStunTurns;
  
  // Temp
  int _damage;
  int _stunTurns;
  
  // Temp
  int _damageDone;
  int _damageReceived;
}

@end