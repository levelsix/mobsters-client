//
//  SkillCritAndEvade.m
//  Utopia
//
//  Created by Behrouz N. on 12/9/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillCritAndEvade.h"
#import "NewBattleLayer.h"
#import "SkillManager.h"
#import "Globals.h"
#import "GameState.h"

@implementation SkillCritAndEvade

#pragma mark - Initialization

-(void)setDefaultValues
{
  [super setDefaultValues];
  
  _critChance = 0.f;
  _critMultiplier = 1.f;
  _evadeChance = 0.f;
  _missChance = 0.f;
  _sideEffectType = SideEffectTypeNoSideEffect;
  _evaded = NO;
  _missed = NO;
}

-(void)setValue:(float)value forProperty:(NSString *)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"CRIT_CHANCE"])
    _critChance = value;
  if ([property isEqualToString:@"CRIT_MULTIPLIER"])
    _critMultiplier = value;
  if ([property isEqualToString:@"EVADE_CHANCE"])
    _evadeChance = value;
  if ([property isEqualToString:@"MISS_CHANCE"])
    _missChance = value;
  if ([property isEqualToString:@"SKILL_SIDE_EFFECT_ID"])
  {
    NSDictionary* skillSideEffects = [GameState sharedGameState].staticSkillSideEffects;
    SkillSideEffectProto* proto = [skillSideEffects objectForKey:[NSNumber numberWithInteger:(int)value]];
    if (proto)
      _sideEffectType = proto.type;
  }
}

#pragma mark - Overrides

- (TickTrigger) tickTrigger
{
  return (_missChance > 0 || _critChance > 0) ? TickTriggerAfterUserTurn : TickTriggerAfterOpponentTurn;
}

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(_sideEffectType), nil];
}

-(BOOL)skillOwnerWillEvade
{
  // Last time defending an attack led to an evasion
  return _evaded;
}

-(BOOL)skillOwnerWillMiss
{
  return _missed;
}

-(NSInteger)modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  _evaded = NO;
  _missed = NO;
  
  if ([self isActive])
  {
    SkillLogStart(@"Crit and Evade -- %@ skill invoked from %@ with damage %ld",
                  self.belongsToPlayer ? @"PLAYER" : @"ENEMY",
                  player ? @"PLAYER" : @"ENEMY",
                  (long)damage);
    
    if (player == self.belongsToPlayer) // The character attacking has the skill
    {
      
      if (_missChance > 0 || _critChance > 0)
      {
        // Chance of missing
        float rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
        if (rand < _missChance)
        {
          damage = 0;
          _missed = YES;
          [self showDodged:YES];
          SkillLogStart(@"Crit and Evade -- Skill caused a miss");
        }
        else
        {
          // Chance of critical hit
          float rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
          if (rand < _critChance)
          {
            damage *= _critMultiplier;
            [self showCriticalHit];
            SkillLogStart(@"Crit and Evade -- Skill caused a critical hit, increasing damage to %ld", (long)damage);        }
        }
      }
    }
    else // The character defending has the skill
    {
      if (_evadeChance)
      {
        // Chance of evading
        float rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
        if (rand < _evadeChance)
        {
          damage = 0;
          _evaded = YES;
          [self showDodged:NO];
          SkillLogStart(@"Crit and Evade -- Skill caused an evade");
        }
      }
    }
  }
  
  return damage;
}

- (BOOL) ticksOnPlayerTurn
{
  return self.belongsToPlayer == (_missChance > 0 || _critChance > 0);
}

-(void)showCriticalHit
{
  [self showSkillPopupMiniOverlay:[NSString stringWithFormat:@"%.3gX ATK", _critMultiplier];
}

-(void)showDodged:(BOOL)missed
{
  [self showSkillPopupMiniOverlay:missed ? @"MISSED" : @"EVADED"];
}
@end
