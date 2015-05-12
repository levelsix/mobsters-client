//
//  SkillBloodRage.m
//  Utopia
//  Description: Enemy gets [X]% increased attack damage, but takes [Y]% more damage.
//
//  Created by Rob Giusti on 1/29/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillBloodRage.h"
#import "NewBattleLayer.h"

@implementation SkillBloodRage

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  _damageGivenMultiplier = 1.25;
  _damageTakenMultiplier = 1.5;
}

- (void) setValue:(float)value forProperty:(NSString *)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"DAMAGE_GIVEN_MULTIPLIER"])
    _damageGivenMultiplier = value;
  else if ( [property isEqualToString:@"DAMAGE_TAKEN_MULTIPLIER"])
    _damageTakenMultiplier = value;
}

#pragma mark - Overrides

- (BOOL) affectsOwner
{
  return NO;
}

- (TickTrigger) tickTrigger
{
  return TickTriggerAfterOpponentTurn;
}

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeNerfBloodRage), nil];
}

- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  if ([self isActive])
  {
    if (self.belongsToPlayer == player) //Remember that this is flip-flopped from Roid Rage, since the opponent is getting the effects of the skill!
    {
      [self enqueueSkillPopupAilmentOverlay:@"BLOOD RAGE"
                           bottomText:[NSString stringWithFormat:@"%.3gX DMG RECIEVED", _damageTakenMultiplier]];
      return damage * _damageTakenMultiplier;
    }
    else if (!self.opponentPlayer.isStunned)
    {
      [self enqueueSkillPopupAilmentOverlay:@"BLOOD RAGE"
                              bottomText:[NSString stringWithFormat:@"%.3gX DMG", _damageGivenMultiplier]];
      return damage * _damageGivenMultiplier;
    }
  }
  
  return damage;
}
@end
