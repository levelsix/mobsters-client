//
//  SkillPoisonPowder.m
//  Utopia
//  Description: Once activated, opponent takes [X] damage each turn
//
//  Created by Rob Giusti on 1/27/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillPoisonPowder.h"
#import "NewBattleLayer.h"
#import "Globals.h"

@implementation SkillPoisonPowder

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  _damage = 10;
  _percent = 0;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"MIN_DAMAGE"])
    _damage = value;
  else if ( [property isEqualToString:@"MIN_PERCENT"])
    _percent = value;
}

#pragma mark - Overrides

- (TickTrigger)tickTrigger
{
  return TickTriggerAfterOpponentTurn;
}

- (BOOL)affectsOwner
{
  return NO;
}

- (BOOL) shouldPersist {
  return [self isActive];
}

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeNerfPoison), nil];
}

- (BOOL) tickDuration
{
  [self dealPoisonDamage];
  [super tickDuration];
  return YES;
}

- (int) poisonDamage
{
  return MAX(_damage, _percent * (self.belongsToPlayer ? self.enemy.maxHealth : self.player.maxHealth));
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if ([self isActive])
  {
    //Reset on new target
    if ((self.belongsToPlayer && trigger == SkillTriggerPointEnemyInitialized)
             || (!self.belongsToPlayer && trigger == SkillTriggerPointPlayerInitialized))
    {
      [self endDurationNow];
    }
  }
  
  return NO;
}

@end