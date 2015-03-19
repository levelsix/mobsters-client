//
//  SkillChill.m
//  Utopia
//
//  Created by Rob Giusti on 3/19/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillChill.h"
#import "NewBattleLayer.h"

@implementation SkillChill

- (void) setDefaultValues
{
  [super setDefaultValues];
  _turnsSkipped = 1;
  _offensiveDamageMultiplier = .67;
}

- (void) setValue:(float)value forProperty:(NSString *)property
{
  [super setValue:value forProperty:property];
  if ([property isEqualToString:@"MOVES_SKIPPED"])
    _turnsSkipped = value;
  if ([property isEqualToString:@"OFF_DAMAGE_MULTIPLIER"])
    _offensiveDamageMultiplier = value;
}

#pragma mark Overrides

- (BOOL)affectsOwner
{
  return NO;
}

- (TickTrigger)tickTrigger
{
  return TickTriggerAfterOpponentTurn;
}

- (NSSet *)sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeBuffThickSkin), nil];
}

- (NSInteger)modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  if ([self isActive])
  {
    if (!player && self.belongsToPlayer)
    {
      [self showSkillPopupAilmentOverlay:@"CHILLED" bottomText:[NSString stringWithFormat:@"%.3gX DMG", _offensiveDamageMultiplier]];
      return damage * _offensiveDamageMultiplier;
    }
  }
  
  return damage;
}

#pragma mark Skill Logic

- (BOOL)activate
{
  if (!self.belongsToPlayer)
  {
    self.battleLayer.movesLeft = MIN(self.battleLayer.movesLeft - _turnsSkipped, 0);
  }
  return [super activate];
}

- (BOOL)skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if ([self isActive]
      && !self.belongsToPlayer && trigger == SkillTriggerPointStartOfPlayerTurn)
  {
    if (execute)
      self.battleLayer.movesLeft = MIN(self.battleLayer.movesLeft - _turnsSkipped, 0);
    return YES;
  }
  
  return NO;
}


@end