//
//  SkillControllerSplitOffDef.h
//  Utopia
//
//  Created by Rob Giusti on 2/23/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillControllerActiveBuff.h"

@interface SkillControllerSplitOffDef : SkillControllerActiveBuff

- (BOOL) skillOffCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute;
- (BOOL) skillDefCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute;

@end