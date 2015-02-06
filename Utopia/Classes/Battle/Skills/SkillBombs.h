//
//  SkillBombs.h
//  Utopia
//
//  Created by Mikhail Larionov on 9/16/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerActive.h"

@interface SkillBombs : SkillControllerActive
{
  // Properties
  NSInteger _bombsPerActivation;
  NSInteger _maxBombs;
  NSInteger _bombCounter;
  NSInteger _bombDamage;
  
  // Counters
  NSInteger _turnCounter;
}

+ (void) updateBombs:(NewBattleLayer*)battleLayer withCompletion:(SkillControllerBlock)completion;

@end
