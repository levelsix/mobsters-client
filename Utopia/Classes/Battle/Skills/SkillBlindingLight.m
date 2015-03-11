//
//  SkillBlindingLight.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/26/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillBlindingLight.h"
#import "NewBattleLayer.h"
#import "Globals.h"

@implementation SkillBlindingLight

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _fixedDamageDone = 0;
  _missChance = 0.f;
  _missed = NO;
}

- (void) setValue:(float)value forProperty:(NSString *)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"FIXED_DAMAGE_DONE"])
    _fixedDamageDone = value;
  if ([property isEqualToString:@"MISS_CHANCE"])
    _missChance = value;
}

#pragma mark - Overrides

- (BOOL) affectsOwner
{
  return NO;
}

- (BOOL) doesRefresh
{
  return YES;
}

- (TickTrigger) tickTrigger
{
  return TickTriggerAfterOpponentTurn;
}

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeNerfBlindingLight), nil];
}

- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  if (player != self.belongsToPlayer)
  {
    _missed = NO;
    if ([self isActive])
    {
      // Chance of missing
      float rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
      if (rand < _missChance)
      {
        damage = 0;
        _missed = YES;
        [self showSkillPopupMiniOverlay:NO
                             bottomText:@"MISSED"
                         withCompletion:^{}];
        SkillLogStart(@"Blinding Light -- Skill caused a miss");
      }
    }
  }
  
  return damage;
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if ([self isActive])
  {
    if (_missed && ((trigger == SkillTriggerPointEnemyDealsDamage && self.belongsToPlayer)
        || (trigger == SkillTriggerPointPlayerDealsDamage && !self.belongsToPlayer)))
    {
      if (execute)
      {
        [self performAfterDelay:.3f block:^{
          [self skillTriggerFinished];
        }];
      }
      return YES;
    }
  }
  
  return NO;
}

- (int) quickAttackDamage
{
  return _fixedDamageDone;
}

- (BOOL) activate
{
  [self dealQuickAttack];
  return YES;
}

//Overriden to make [super activate] wait until the attack is finished, which will start the visual effects then
- (void) onFinishQuickAttack
{
  [super activate];
}

@end
