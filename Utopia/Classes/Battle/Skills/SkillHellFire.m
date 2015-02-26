//
//  SkillHellFire.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/30/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillHellFire.h"
#import "NewBattleLayer.h"

@implementation SkillHellFire

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _fixedDamageReceived = 0.f;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"FIXED_DAMAGE_RECEIVED"])
    _fixedDamageReceived = value;
}

#pragma mark - Overrides

- (SpecialOrbType)specialType
{
  return SpecialOrbTypeBullet;
}

- (SpecialOrbSpawnZone) spawnZone
{
  return SpecialOrbSpawnTop;
}

- (BOOL)keepColor
{
  return NO;
}

- (NSInteger) duration
{
  return self.belongsToPlayer ? [super duration] : -1;
}

- (BOOL) activate
{
  if (!self.belongsToPlayer)
  {
    [self resetDuration];
  }
  return [super activate];
}

- (int)quickAttackDamage
{
  return _fixedDamageReceived;
}

- (BOOL)onSpecialOrbCounterFinish:(NSInteger)numOrbs
{
  [self dealQuickAttack];
  [self endDurationNow];
  [self removeSpecialOrbs];
  return YES;
}

- (BOOL) skillDefCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillDefCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if ([self isActive])
  {
    if (trigger == SkillTriggerPointEndOfPlayerMove && [self specialsOnBoardCount:[self specialType]] == 0)
    {
      if (execute)
      {
        return [self endDurationNow];
      }
    }
  }
  
  return NO;
}

@end
