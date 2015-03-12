//
//  SkillRightHook.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 2/3/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillRightHook.h"
#import "NewBattleLayer.h"

@implementation SkillRightHook

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _fixedDamageDone = 0.f;
  _fixedDamageReceived = 0.f;
  _targetChanceToHitSelf = 0.f;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"FIXED_DAMAGE_DONE"])
    _fixedDamageDone = value;
  if ([property isEqualToString:@"FIXED_DAMAGE_RECEIVED"])
    _fixedDamageReceived = value;
  if ([property isEqualToString:@"TARGET_CHANCE_TO_HIT_SELF"])
    _targetChanceToHitSelf = value;
}

#pragma mark - Overrides

- (SpecialOrbType)specialType
{
  return SpecialOrbTypeGlove;
}

- (BOOL) affectsOwner
{
  return NO;
}

- (int)quickAttackDamage
{
  return self.belongsToPlayer ? _fixedDamageDone : _fixedDamageReceived;
}

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeNerfConfusion), nil];
}

- (BOOL)skillIsReady
{
  return [super skillIsReady] && (self.belongsToPlayer || _orbsSpawned == 0);
}

- (TickTrigger)tickTrigger
{
  return TickTriggerAfterOpponentTurn;
}

- (void)onAllSpecialsDestroyed
{
  [self resetOrbCounter];
}

- (BOOL)onSpecialOrbCounterFinish:(NSInteger)numOrbs
{
  [self dealQuickAttack];
  return YES;
}

- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  if (player && !self.belongsToPlayer)
  {
    if ([self isActive])
    {
      // Chance of player hitting self
      float rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
      if (rand < _targetChanceToHitSelf)
      {
        // Tell NewBattleLayer that enemy will be confused on his next turn
        self.player.isConfused = YES;
      }
    }
  }
  
  return damage;
}

- (BOOL)skillOffCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillOffCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if (trigger == SkillTriggerPointStartOfEnemyTurn)
  {
    if ([self isActive])
    {
      if (execute)
      {
        // Chance of enemy hitting self
        float rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
        if (rand < _targetChanceToHitSelf)
        {
          // Tell NewBattleLayer that enemy will be confused on his next turn
          self.enemy.isConfused = YES;
        }
        
        [self skillTriggerFinished];
      }
      return YES;
    }
  }
  
  return NO;
}

- (BOOL)activate
{
  [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
  [self.battleLayer.orbLayer disallowInput];
  
  // Perform attack animation
  if (self.belongsToPlayer)
  {
    [self dealQuickAttack];
    return YES;
  }
  return [super activate];
}

#pragma mark - Skill logic

- (void) onFinishQuickAttack
{
  [self resetDuration];
}

- (void) showLogo
{
  [self showSkillPopupMiniOverlay:@"CONFUSED"];
}
@end
