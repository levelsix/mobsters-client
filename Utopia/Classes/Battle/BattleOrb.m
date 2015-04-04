//
//  Utopia
//
//  Created by Ashwin Kamath on 2/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
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
  cp.turnCounter = self.turnCounter;
  cp.bombDamage = self.bombDamage;
  cp.cloudCounter = self.cloudCounter;
  cp.damageMultiplier = self.damageMultiplier;
  return cp;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@: color - %ld powerup - %ld special - %ld changeType = %ld square - (%ld,%ld)",
          [super description], (long)self.orbColor, (long)self.powerupType, (long)self.specialOrbType, (long)self.changeType, (long)self.column, (long)self.row];
}

- (BOOL) isMovable {
  return self.specialOrbType != SpecialOrbTypeCloud && !self.isLocked;
}

- (void) setSpecialOrbType:(SpecialOrbType)specialOrbType {
  _specialOrbType = specialOrbType;
  
  if (self.specialOrbType != SpecialOrbTypeNone) {
    _powerupType = PowerupTypeNone;
  }
  
  if (self.specialOrbType == SpecialOrbTypeCake   ||
      self.specialOrbType == SpecialOrbTypeCloud  ||
      self.specialOrbType == SpecialOrbTypeGrave  ||
      self.specialOrbType == SpecialOrbTypeBullet ||
      self.specialOrbType == SpecialOrbTypeSword  ||
      self.specialOrbType == SpecialOrbTypeBullet) {
    self.orbColor = OrbColorNone;
  }
}

#define POWERUP_KEY       @"PowerupKey"
#define GEM_COLOR_KEY     @"GemColorKey"
#define SPECIAL_TYPE_KEY  @"SpecialTypeKey"
#define TURN_COUNTER      @"TurnCounter"
#define BOMB_DAMAGE       @"BombDamage"
#define CLOUD_COUNTER     @"CloudCounter"
#define LOCKED_KEY        @"LockedKey"
#define VINES_KEY         @"VinesKey"
#define DAMAGE_MULTIPLIER @"DamageMultiplier"

- (NSDictionary*) serialize
{
  NSMutableDictionary* info = [NSMutableDictionary dictionary];
  [info setObject:@(_powerupType) forKey:POWERUP_KEY];
  [info setObject:@(_orbColor) forKey:GEM_COLOR_KEY];
  [info setObject:@(_specialOrbType) forKey:SPECIAL_TYPE_KEY];
  [info setObject:@(_turnCounter) forKey:TURN_COUNTER];
  [info setObject:@(_bombDamage) forKey:BOMB_DAMAGE];
  [info setObject:@(_cloudCounter) forKey:CLOUD_COUNTER];
  [info setObject:@(_isLocked) forKey:LOCKED_KEY];
  [info setObject:@(_isVines) forKey:VINES_KEY];
  [info setObject:@(_damageMultiplier) forKey:DAMAGE_MULTIPLIER];
  return info;
}

- (void) deserialize:(NSDictionary*)dic
{
  NSNumber* powerupType = [dic objectForKey:POWERUP_KEY];
  NSNumber* orbColor = [dic objectForKey:GEM_COLOR_KEY];
  NSNumber* specialOrbType = [dic objectForKey:SPECIAL_TYPE_KEY];
  NSNumber* turnCounter = [dic objectForKey:TURN_COUNTER];
  NSNumber* bombDamage = [dic objectForKey:BOMB_DAMAGE];
  NSNumber* cloudCounter = [dic objectForKey:CLOUD_COUNTER];
  NSNumber* isLocked = [dic objectForKey:LOCKED_KEY];
  NSNumber* isVines = [dic objectForKey:VINES_KEY];
  NSNumber* damageMultiplier = [dic objectForKey:DAMAGE_MULTIPLIER];
  
  if (powerupType)
    _powerupType = (PowerupType)[powerupType integerValue];
  if (orbColor)
    _orbColor = (OrbColor)[orbColor integerValue];
  if (specialOrbType)
    _specialOrbType = (SpecialOrbType)[specialOrbType integerValue];
  if (turnCounter)
    _turnCounter = [turnCounter integerValue];
  if (bombDamage)
    _bombDamage = [bombDamage integerValue];
  if (cloudCounter)
    _cloudCounter = [cloudCounter integerValue];
  if (isLocked)
    _isLocked = [isLocked boolValue];
  if (isVines)
    _isVines = [isVines boolValue];
  if (damageMultiplier)
    _damageMultiplier = [damageMultiplier integerValue];
}

@end
