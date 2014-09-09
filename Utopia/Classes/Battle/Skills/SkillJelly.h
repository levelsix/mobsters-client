//
//  SkillJelly.h
//  Utopia
//
//  Created by Mikhail Larionov on 9/2/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerPassive.h"

@interface SkillJelly : SkillControllerPassive
{
  // Properties
  NSInteger _spawnTurns;
  NSInteger _spawnCount;
  NSInteger _initialCount;
  
  // Counters
  NSInteger _turnCounter;
  
  // Temporary variable used for batching
  NSInteger _spawnCounter;
}

@end
