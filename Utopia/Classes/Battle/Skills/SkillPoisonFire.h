//
//  SkillPoisonFire.h
//  Utopia
//
//  Created by Rob Giusti on 2/11/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillPoisonSkewer.h"

@interface SkillPoisonFire : SkillPoisonSkewer
{
  int _numOrbsSpawned;
  int _orbSpawnTurnCounter;
  
  int _poisonStacks;
  int _quickAttackStacks;
}

@end
