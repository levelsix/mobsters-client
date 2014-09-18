//
//  SkillShield.h
//  Utopia
//
//  Created by Mikhail Larionov on 9/17/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerActive.h"

@interface SkillShield : SkillControllerActive
{
  // Properties
  NSInteger _shieldHp;
  
  // Counters
  NSInteger _currentShieldHp;
  
  // Sprites
  CCSprite* _backSprite;
  CCSprite* _frontSprite;
  CCSprite* _glowSprite;
  
  NSInteger _tempDamageDealt;
}

@end
