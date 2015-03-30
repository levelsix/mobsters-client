//
//  SkillHeadshot.m
//  Utopia
//
//  Created by Behrouz N. on 12/11/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillHeadshot.h"
#import "NewBattleLayer.h"
#import "SoundEngine.h"

@implementation SkillHeadshot

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _fixedDamageReceived = 0.f;
  _fixedDamageDone = 0.f;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"FIXED_DAMAGE_RECEIVED"])
    _fixedDamageReceived = value;
  if ([property isEqualToString:@"FIXED_DAMAGE_DONE"])
    _fixedDamageDone = value;
}

#pragma mark - Overrides

- (SpecialOrbType)specialType
{
  return SpecialOrbTypeHeadshot;
}

- (int) quickAttackDamage
{
  return self.belongsToPlayer ? _fixedDamageDone : _fixedDamageReceived;
}

- (BOOL)skillIsReady
{
  return [super skillIsReady] && (self.belongsToPlayer || [self specialsOnBoardCount:[self specialType]] == 0);
}

- (NSInteger)orbSpawnCounter
{
  return self.belongsToPlayer ? 0 : [super orbSpawnCounter];
}

- (void)onAllSpecialsDestroyed
{
  [self resetOrbCounter];
  [super onAllSpecialsDestroyed];
}

- (BOOL)skillOffCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillOffCalledWithTrigger:trigger execute:execute])
    return YES;
  
  // Player matched and removed all headshot orbs; time for a quick attack
  if (trigger == SkillTriggerPointEndOfPlayerMove && self.belongsToPlayer)
  {
    if (execute)
    {
      if (_orbsSpawned > 0)
      {
        _orbsSpawned = [self specialsOnBoardCount:SpecialOrbTypeHeadshot];
        if (_orbsSpawned == 0)
        {
          [self dealQuickAttack];
        }
        else
          [self skillTriggerFinished];
        return YES;
      }
    }
  }
  
  return NO;
}

- (BOOL)onSpecialOrbCounterFinish:(NSInteger)numOrbs
{
  [self dealQuickAttack];
  return YES;
}

- (void)onFinishQuickAttack
{
  [self resetOrbCounter];
  [super onFinishQuickAttack];
}

- (BOOL)activate
{
  if (self.belongsToPlayer)
  {
    [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
    [self.battleLayer.orbLayer disallowInput];
    
    _orbsSpawned = [self specialsOnBoardCount:[self specialType]];
    
    NSInteger orbsToSpawn = MIN(_orbsPerSpawn, _maxOrbs - _orbsSpawned);
    
    if ([self checkSpecialOrbs])
      [self spawnSpecialOrbs:orbsToSpawn withTarget:nil andSelector:nil];
    else
      [self spawnSpecialOrbs:orbsToSpawn withTarget:self andSelector:@selector(skillTriggerFinishedActivated)];
    
    if ([self doesRefresh])
      [self resetOrbCounter];
    
    return YES;
  }
  return [super activate];
}

@end
