//
//  SkillKnockout.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/27/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillKnockout.h"
#import "NewBattleLayer.h"
#import "Globals.h"

@implementation SkillKnockout

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _fixedDamageDone = 0;
  _fixedDamageReceived = 0;
  _enemyHealthThreshold = 0;
  _orbsConsumed = 0;
}

- (void) setValue:(float)value forProperty:(NSString *)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"ENEMY_HP_THRESHOLD"])
    _enemyHealthThreshold = value;
  else if ([property isEqualToString:@"FIXED_DAMAGE_DONE"])
    _fixedDamageDone = value;
  else if ([property isEqualToString:@"FIXED_DAMAGE_RECEIVED"])
    _fixedDamageReceived = value;
}

#pragma mark - Overrides

- (SpecialOrbType)specialType
{
  return SpecialOrbTypeFryingPan;
}

- (int) quickAttackDamage
{
  return self.belongsToPlayer ? _fixedDamageDone : _fixedDamageReceived;
}

- (BOOL) doesRefresh
{
  return YES;
}

- (void)onAllSpecialsDestroyed
{
  [self resetOrbCounter];
}

- (BOOL) activate
{
  if (self.belongsToPlayer)
  {
    [self dealQuickAttack];
    return YES;
  }
  return [super activate];
}

- (BOOL)onSpecialOrbCounterFinish:(NSInteger)numOrbs
{
  [self dealQuickAttack];
  return YES;
}

#pragma mark - Skill logic

- (void)quickAttackDealDamage
{
  if (self.opponentPlayer.curHealth < _enemyHealthThreshold)
  {
    [self instantlyKillEnemy];
  }
  else
  {
    [super quickAttackDealDamage];
  }
}

- (void) instantlyKillEnemy
{
  [self.battleLayer instantSetHealthForEnemy:self.belongsToPlayer
                                          to:0
                                  withTarget:self
                                 andSelector:@selector(onFinishQuickAttack)];
}

- (void) onFinishQuickAttack
{
  [self skillTriggerFinished:self.belongsToPlayer];
}

@end
