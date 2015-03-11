//
//  SkillSkewer.h
//  Utopia
//
//  Created by Robert Giusti on 1/26/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SkillQuickAttack.h"

@interface SkillSkewer : SkillQuickAttack
{
  // Properties
  float       _lowDamage;
  float       _highDamage;
  float       _chance;
}

@end
