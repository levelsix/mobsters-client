//
//  SkillControllerSplitOffDef.m
//  Utopia
//
//  Created by Rob Giusti on 2/23/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillControllerSplitOffDef.h"

@implementation SkillControllerSplitOffDef

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if (self.belongsToPlayer)
    return [self skillOffCalledWithTrigger:trigger execute:execute];
  else
    return [self skillDefCalledWithTrigger:trigger execute:execute];
}

- (BOOL) skillOffCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  return NO;
}

- (BOOL) skillDefCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  return NO;
}

@end
