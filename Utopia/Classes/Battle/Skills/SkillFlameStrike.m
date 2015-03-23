//
//  SkillFlameStrike.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/21/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillFlameStrike.h"
#import "NewBattleLayer.h"
#import "Globals.h"

@implementation SkillFlameStrike

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _damageMultiplier = 1.f;
  _tempDamageGained = 0;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"DAMAGE_MULTIPLIER"])
    _damageMultiplier = value;
}

#pragma mark - Overrides

- (void)orbDestroyed:(OrbColor)color special:(SpecialOrbType)type
{
  if ([self isActive] && color == OrbColorFire)
  {
    _tempDamageGained += self.userPlayer.fireDamage * (_damageMultiplier);
  }
  [super orbDestroyed:color special:type];
}

- (BOOL) generateSpecialOrb:(BattleOrb*)orb atColumn:(int)column row:(int)row
{
  if ([self isActive])
  {
    if (orb.specialOrbType == SpecialOrbTypeNone &&
        orb.powerupType < PowerupTypeAllOfOneColor &&
        orb.orbColor == OrbColorFire)
    {
      orb.damageMultiplier = floorf(_damageMultiplier);
      return YES;
    }
  }
  
  return NO;
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if (trigger == SkillTriggerPointPlayerInitialized)
  {
    if ([self isActive])
    {
      [self setDamageMultiplierOnFireOrbs:floorf(_damageMultiplier)];
    }
    else
    {
      [self setDamageMultiplierOnFireOrbs:1];
    }
  }
  
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if ([self isActive])
  {
    if (trigger == SkillTriggerPointPlayerDealsDamage && self.belongsToPlayer && _tempDamageGained > 0)
    {
      if (execute)
      {
        [self showSkillPopupMiniOverlay:[NSString stringWithFormat:@"%i FIRE DAMAGE", _tempDamageGained]];
        _tempDamageGained = 0;
        [self skillTriggerFinished];
      }
      return YES;
    }
  }
  
  return NO;
}

#pragma mark - Skill logic

- (BOOL) onDurationStart
{
  SkillLogStart(@"Flame Strike -- Skill activated");
  
  // Set damage multiplier on fire orbs
  [self setDamageMultiplierOnFireOrbs:floorf(_damageMultiplier)];
  
  return [super onDurationStart];
}

- (BOOL) onDurationEnd
{
  SkillLogStart(@"Flame Strike -- Skill deactivated");
  
  // Reset damage multiplier on fire orbs
  [self setDamageMultiplierOnFireOrbs:1];
  
  return [super onDurationEnd];
}

- (void) setDamageMultiplierOnFireOrbs:(int)multiplier
{
  BattleOrbLayout* layout = self.battleLayer.orbLayer.layout;
  OrbSwipeLayer* layer = self.battleLayer.orbLayer.swipeLayer;
  for (NSInteger column = 0; column < layout.numColumns; ++column)
    for (NSInteger row = 0; row < layout.numRows; ++row)
    {
      BattleOrb* orb = [layout orbAtColumn:column row:row];
      if (orb.specialOrbType == SpecialOrbTypeNone &&
          orb.powerupType < PowerupTypeAllOfOneColor &&
          orb.orbColor == OrbColorFire)
      {
        orb.damageMultiplier = multiplier;
        
        OrbSprite* orbSprite = [layer spriteForOrb:orb];
        [orbSprite reloadSprite:YES];
      }
    }
}

#pragma mark - Serialization

- (NSDictionary*) serialize
{
  NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
  [result setObject:@(_tempDamageGained) forKey:@"damage"];
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (! [super deserialize:dict])
    return NO;
  
  NSNumber* damage = [dict objectForKey:@"damage"];
  if (damage)
    _tempDamageGained = [damage floatValue];
  
  return YES;
}

@end
