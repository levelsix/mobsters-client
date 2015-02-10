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
  
  _numAffectedMoves = 0;
  _damageMultiplier = 1.f;
  _skillActive = NO;
  _remainingMoves = 0;
  _logoShown = NO;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"NUM_AFFECTED_MOVES"])
    _numAffectedMoves = value;
  if ([property isEqualToString:@"DAMAGE_MULTIPLIER"])
    _damageMultiplier = value;
}

#pragma mark - Overrides

- (BOOL) generateSpecialOrb:(BattleOrb*)orb atColumn:(int)column row:(int)row
{
  if (_skillActive)
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
  
  if (trigger == SkillTriggerPointEnemyAppeared && !_logoShown)
  {
    if (execute)
    {
      _logoShown = YES;
      [self showSkillPopupOverlay:YES withCompletion:^(){
        [self performAfterDelay:.5f block:^{
          [self skillTriggerFinished];
        }];
      }];
    }
    return YES;
  }
  
  if (trigger == SkillTriggerPointEndOfPlayerMove && self.belongsToPlayer)
  {
    if (!_skillActive && [self skillIsReady])
    {
      if (execute)
      {
        _skillActive = YES;
        _remainingMoves = _numAffectedMoves;
        SkillLogStart(@"Flame Strike -- Skill activated");
        
        // Set damage multiplier on fire orbs
        [self setDamageMultiplierOnFireOrbs:floorf(_damageMultiplier)];
        
        [self skillTriggerFinished:YES];
      }
      return YES;
    }
    if (_skillActive)
    {
      if (execute)
      {
        SkillLogStart(@"Flame Strike -- %d moves remaining", _remainingMoves - 1);
        if (--_remainingMoves == 0)
        {
          _skillActive = NO;
          [self resetOrbCounter];
          SkillLogStart(@"Flame Strike -- Skill deactivated");
          
          // Reset damage multiplier on fire orbs
          [self setDamageMultiplierOnFireOrbs:1];
        }
        
        [self skillTriggerFinished];
      }
      return YES;
    }
  }
  
  if (trigger == SkillTriggerPointPlayerMobDefeated && self.belongsToPlayer)
  {
    if (_skillActive)
    {
      if (execute)
      {
        _skillActive = NO;
        [self resetOrbCounter];
        SkillLogStart(@"Flame Strike -- Skill deactivated");
        
        // Reset damage multiplier on fire orbs
        [self setDamageMultiplierOnFireOrbs:1];
        
        [self skillTriggerFinished];
      }
      return YES;
    }
  }
  
  return NO;
}

#pragma mark - Skill logic

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
  [result setObject:@(_skillActive) forKey:@"skillActive"];
  [result setObject:@(_remainingMoves) forKey:@"remainingMoves"];
  
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (![super deserialize:dict])
    return NO;
  
  NSNumber* skillActive = [dict objectForKey:@"skillActive"];
  if (skillActive) _skillActive = [skillActive boolValue];
  NSNumber* remainingMoves = [dict objectForKey:@"remainingMoves"];
  if (remainingMoves) _remainingMoves = [remainingMoves intValue];
  
  return YES;
}

@end
