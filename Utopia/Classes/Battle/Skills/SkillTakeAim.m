//
//  SkillTakeAim.m
//  Utopia
//  Description: Targets are thrown on the attackers board. Each target grants 25% critical strike on attack (stackable.) Targets defused via match (like bombs away!).
//
//  Created by Rob Giusti on 1/29/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillTakeAim.h"
#import "NewBattleLayer.h"
#import "SoundEngine.h"
#import "Globals.h"

@implementation SkillTakeAim

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  _critChancePerOrb = 0.25;
  _critDamageMultiplier = 2;
  
  _playerCritStacks = 0;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"CHANCE_PER_ORB"])
    _critChancePerOrb = value;
  else if ([property isEqualToString:@"CRIT_DAMAGE_MULTIPLIER"])
    _critDamageMultiplier = value;
  else if ([property isEqualToString:@"PLAYER_CRIT_CHANCE"])
    _playerCritChance = value;
}

#pragma mark - Overrides

- (SpecialOrbType)specialType
{
  return SpecialOrbTypeTakeAim;
}

- (BOOL) doesRefresh
{
  return YES;
}

- (BOOL) activate
{
  if (self.belongsToPlayer)
  {
    _playerCritStacks++;
  }
  return [super activate];
}

- (BOOL)onDurationEnd
{
  if (self.belongsToPlayer)
  {
    _playerCritStacks = 0;
  }
  return [super onDurationEnd];
}

- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  _orbsSpawned = (int)[self specialsOnBoardCount:SpecialOrbTypeTakeAim];
  if (!player && !self.belongsToPlayer && _orbsSpawned)
  {
    float rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
    if (rand < _orbsSpawned * _critChancePerOrb)
    {
      [self showCriticalHit];
      damage = damage * _critDamageMultiplier;
    }
  }
  else if (player && self.belongsToPlayer && [self isActive])
  {
    float rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
    if (rand < (_playerCritChance * _playerCritStacks))
    {
      [self showCriticalHit];
      damage = damage * _critDamageMultiplier;
    }
    [self tickDuration];
  }
  
  return damage;
}

#pragma mark - Skill Logic

-(void)showCriticalHit
{
  [self showSkillPopupMiniOverlay:[NSString stringWithFormat:@"%.3gX DMG", _critDamageMultiplier]];
}

#pragma mark - Serialization

- (NSDictionary*) serialize
{
  NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
  [result setObject:@(_playerCritStacks) forKey:@"playerCritStacks"];
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (! [super deserialize:dict])
    return NO;
  
  NSNumber* playerCritStacks = [dict objectForKey:@"playerCritStacks"];
  if (playerCritStacks)
    _playerCritStacks = [playerCritStacks floatValue];
  
  return YES;
}

@end