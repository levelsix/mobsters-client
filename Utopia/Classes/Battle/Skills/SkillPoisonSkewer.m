//
//  SkillPoisonSkewer.m
//  Utopia
//
//  Created by Rob Giusti on 2/11/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillPoisonSkewer.h"
#import "NewBattleLayer.h"

@implementation SkillPoisonSkewer

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  _initialDamage = 10;
  _poisonChance = 1;
}

- (void) setValue:(float)value forProperty:(NSString *)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"INITIAL_DAMAGE"])
    _initialDamage = value;
  else if ( [property isEqualToString:@"POISON_CHANCE"])
    _poisonChance = value;
}

- (BOOL) onDurationStart
{
  [self dealQuickAttack];
  return YES;
}

- (BOOL) onDurationReset
{
  return [self onDurationStart];
}

- (int) quickAttackDamage
{
  return _initialDamage;
}

- (void) onFinishQuickAttack
{
  if ([self doesPoison])
  {
    [self poisonOpponent];
  }
  else
  {
    [self endDurationNow];
    [self skillTriggerFinished:YES];
  }
}

- (BOOL) doesPoison
{
  float rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
  return rand < _poisonChance;
}

@end