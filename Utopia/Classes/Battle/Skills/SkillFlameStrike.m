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
  _logoShown = NO;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"DAMAGE_MULTIPLIER"])
    _damageMultiplier = value;
}

#pragma mark - Overrides

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
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if ([self isActive])
  {
    if (trigger == SkillTriggerPointEndOfPlayerTurn && self.belongsToPlayer)
    {
      if (execute)
      {
        [self tickDuration];
        [self skillTriggerFinished];
      }
      return YES;
    }
    
    if (trigger == SkillTriggerPointPlayerMobDefeated && self.belongsToPlayer)
    {
      if (execute)
      {
        [self endDurationNow];
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

@end
