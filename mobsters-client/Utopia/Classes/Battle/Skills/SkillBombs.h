//
//  SkillBombs.h
//  Utopia
//
//  Created by Mikhail Larionov on 9/16/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerPassive.h"

@interface SkillBombs : SkillControllerPassive
{
  // Properties
  NSInteger _minBombs;
  NSInteger _maxBombs;
  NSInteger _initialBombs;
  NSInteger _bombCounter;
  NSInteger _bombDamage;
  float     _bombChance;
}

+ (void) updateBombs:(NewBattleLayer*)battleLayer withCompletion:(SkillControllerBlock)completion;

@end
