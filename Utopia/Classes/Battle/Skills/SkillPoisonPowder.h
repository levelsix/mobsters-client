//
//  SkillPoisonPowder.h
//  Utopia
//
//  Created by Rob Giusti on 1/27/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillControllerActive.h"

@interface SkillPoisonPowder : SkillControllerActive
{
    // Properties
    float _damage;
    float _percent;
    
    // Counters
    BOOL _isPoisoned;
}

@end
