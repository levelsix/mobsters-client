//
//  SkillEnergize.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 2/2/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillEnergize.h"
#import "NewBattleLayer.h"
#import "Globals.h"

@implementation SkillEnergize

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _speedIncrease = 0.f;
  _attackIncrease = 0.f;
  _curSpeedMultiplier = 1.f;
  _curAttackMultiplier = 1.f;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"SPEED_INCREASE_PERC"])
    _speedIncrease = value;
  if ([property isEqualToString:@"ATTACK_INCREASE_PERC"])
    _attackIncrease = value;
}

#pragma mark - Overrides

- (SpecialOrbType)specialType
{
  return SpecialOrbTypeBattery;
}

- (SpecialOrbSpawnZone)spawnZone
{
  return SpecialOrbSpawnTop;
}

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeBuffEnergize), nil];
}

- (BOOL) doesRefresh
{
  return YES;
}

- (BOOL)doesStack
{
  return self.belongsToPlayer;
}

- (BOOL)keepColor
{
  return NO;
}

- (int)skillStacks
{
  if (self.belongsToPlayer)
  {
    return [super skillStacks];
  }
  return 0;
}

- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  if ([self isActive])
  {
    if (player == self.belongsToPlayer)
    {
      SkillLogStart(@"Energize -- Multiplying damage by %.2f", _curAttackMultiplier);
      
      [self showSkillPopupMiniOverlay:[NSString stringWithFormat:@"%.3gX DMG", _curAttackMultiplier]];
      
      return damage * _curAttackMultiplier;
    }
  }
  
  return damage;
}

- (BOOL)onSpecialOrbCounterFinish:(NSInteger)numOrbs
{
  _curSpeedMultiplier += _speedIncrease * numOrbs;
  _curAttackMultiplier += _attackIncrease * numOrbs;
  _stacks += numOrbs;
  
  [self showSkillPopupMiniOverlay:[NSString stringWithFormat:@"+%.3gX ATK / +%.3gX SPD", (_attackIncrease * numOrbs), (_speedIncrease * numOrbs)]];
  
  [self updateSkillOwnerSpeed];
  
  [self performAfterDelay:.3 block:^{
    [self resetDuration];
  }];
  
  return YES;
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if ((trigger == SkillTriggerPointPlayerInitialized && self.belongsToPlayer) ||
      (trigger == SkillTriggerPointEnemyInitialized && !self.belongsToPlayer))
  {
    if (execute)
    {
      _initialSpeed = self.userPlayer.speed;
      
      SkillLogStart(@"Energize -- Inital speed is %d", _initialSpeed);
      
      if ([self isActive] && _curSpeedMultiplier > 1.f)
      {
        // Restore speed if coming back to a battle after leaving midway
        [self updateSkillOwnerSpeed];
      }
      
      [self skillTriggerFinished];
    }
    return YES;
  }
  
  return NO;
}

#pragma mark - Skill logic

- (BOOL) activate
{
  if (self.belongsToPlayer)
  {
    _curSpeedMultiplier += _speedIncrease;
    _curAttackMultiplier += _attackIncrease;
    return [self resetDuration];
  }
  return [super activate];
}

- (BOOL) onDurationEnd
{
  SkillLogStart(@"Energize -- Skill deactivated");
  
  _curSpeedMultiplier = 1.f;
  _curAttackMultiplier = 1.f;
  [self updateSkillOwnerSpeed];
  
  return [super onDurationEnd];
}

- (void) updateSkillOwnerSpeed
{
  BattlePlayer* bp = self.belongsToPlayer ? self.player : self.enemy;
  bp.speed = _initialSpeed * _curSpeedMultiplier;
  
  SkillLogStart(@"Energize -- Setting speed to %d", bp.speed);
  
  // Recalculate battle schedule based on new speeds
  [self.battleLayer.battleSchedule createScheduleForPlayerA:self.player.speed
                                                    playerB:self.enemy.speed
                                                   andOrder:ScheduleFirstTurnRandom];
  [self.battleLayer setShouldDisplayNewSchedule:YES];
}

- (void) showAttackMultiplier
{
  [self showSkillPopupMiniOverlay:[NSString stringWithFormat:@"%.3gX ATK", _curAttackMultiplier]];
}

#pragma mark - Serialization

- (NSDictionary*) serialize
{
  NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
  [result setObject:@(_curSpeedMultiplier) forKey:@"curSpeedMultiplier"];
  [result setObject:@(_curAttackMultiplier) forKey:@"curAttackMultiplier"];
  
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (![super deserialize:dict])
    return NO;
  
  NSNumber* curSpeedMultiplier = [dict objectForKey:@"curSpeedMultiplier"];
  if (curSpeedMultiplier) _curSpeedMultiplier = [curSpeedMultiplier floatValue];
  NSNumber* curAttackMultiplier = [dict objectForKey:@"curAttackMultiplier"];
  if (curAttackMultiplier) _curAttackMultiplier = [curAttackMultiplier floatValue];
  
  return YES;
}

@end
