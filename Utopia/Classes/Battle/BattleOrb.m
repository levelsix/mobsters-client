//
//  RWTCookie.m
//  CookieCrunch
//
//  Created by Matthijs on 25-02-14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "BattleOrb.h"

@implementation BattleOrb

- (id) copy {
  BattleOrb *cp = [[BattleOrb alloc] init];
  cp.column = self.column;
  cp.row = self.row;
  cp.orbColor = self.orbColor;
  cp.specialOrbType = self.specialOrbType;
  cp.powerupType = self.powerupType;
  cp.bombCounter = self.bombCounter;
  cp.bombDamage = self.bombDamage;
  cp.headshotCounter = self.headshotCounter;
  cp.damageMultiplier = self.damageMultiplier;
  return cp;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@: type - %ld powerup - %ld square - (%ld,%ld)", [super description], (long)self.orbColor, (long)self.powerupType, (long)self.column, (long)self.row];
}

#define POWERUP_KEY       @"PowerupKey"
#define GEM_COLOR_KEY     @"GemColorKey"
#define SPECIAL_TYPE_KEY  @"SpecialTypeKey"
#define BOMB_COUNTER      @"BombCounter"
#define BOMB_DAMAGE       @"BombDamage"
#define HEADSHOT_COUNTER  @"HeadshotCounter"
#define DAMAGE_MULTIPLIER @"DamageMultiplier"

- (NSDictionary*) serialize
{
  NSMutableDictionary* info = [NSMutableDictionary dictionary];
  [info setObject:@(_powerupType) forKey:POWERUP_KEY];
  [info setObject:@(_orbColor) forKey:GEM_COLOR_KEY];
  [info setObject:@(_specialOrbType) forKey:SPECIAL_TYPE_KEY];
  [info setObject:@(_bombCounter) forKey:BOMB_COUNTER];
  [info setObject:@(_bombDamage) forKey:BOMB_DAMAGE];
  [info setObject:@(_headshotCounter) forKey:HEADSHOT_COUNTER];
  [info setObject:@(_damageMultiplier) forKey:DAMAGE_MULTIPLIER];
  return info;
}

- (void) deserialize:(NSDictionary*)dic
{
  NSNumber* powerupType = [dic objectForKey:POWERUP_KEY];
  NSNumber* orbColor = [dic objectForKey:GEM_COLOR_KEY];
  NSNumber* specialOrbType = [dic objectForKey:SPECIAL_TYPE_KEY];
  NSNumber* bombCounter = [dic objectForKey:BOMB_COUNTER];
  NSNumber* bombDamage = [dic objectForKey:BOMB_DAMAGE];
  NSNumber* headshotCounter = [dic objectForKey:HEADSHOT_COUNTER];
  NSNumber* damageMultiplier = [dic objectForKey:DAMAGE_MULTIPLIER];
  
  if (powerupType)
    _powerupType = (PowerupType)[powerupType integerValue];
  if (orbColor)
    _orbColor = (OrbColor)[orbColor integerValue];
  if (specialOrbType)
    _specialOrbType = (SpecialOrbType)[specialOrbType integerValue];
  if (bombCounter)
    _bombCounter = [bombCounter integerValue];
  if (bombDamage)
    _bombDamage = [bombDamage integerValue];
  if (headshotCounter)
    _headshotCounter = [headshotCounter integerValue];
  if (damageMultiplier)
    _damageMultiplier = [damageMultiplier integerValue];
}

@end
