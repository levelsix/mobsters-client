//
//  SkillPoisonFire.m
//  Utopia
//
//  Created by Rob Giusti on 2/11/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillPoisonFire.h"
#import "NewBattleLayer.h"

@implementation SkillPoisonFire

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _initialDamage = 0;
  _poisonPercent = 0;
  _poisonDamage = 0;
  _poisonStacks = 0;
  _quickAttackStacks = 0;
}

- (void) setValue:(float)value forProperty:(NSString *)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"INITIAL_DAMAGE"])
    _initialDamage = value;
  if ( [property isEqualToString:@"MIN_DAMAGE"])
    _poisonDamage = value;
  else if ( [property isEqualToString:@"MIN_PERCENT"])
    _poisonPercent = value;
}

#pragma mark - Overrides

- (BOOL)cureStatusWithAntidote:(BattleItemProto*)antidote execute:(BOOL)execute
{
  if ([self isActive] && antidote.battleItemType == BattleItemTypePoisonAntidote)
  {
    if (execute)
    {
      [self endDurationNow];
      
      [self showAntidotePopupOverlay:antidote bottomText:@"Poison Removed"];
    }
    return YES;
  }
  return NO;
}

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeNerfPoison), nil];
}

- (SpecialOrbType)specialType
{
  return SpecialOrbTypePoisonFire;
}

- (SpecialOrbSpawnZone)spawnZone
{
  return SpecialOrbSpawnTop;
}

- (TickTrigger)tickTrigger
{
  return TickTriggerAfterOpponentTurn;
}

- (BOOL)affectsOwner
{
  return NO;
}

- (BOOL)keepColor
{
  return NO;
}

- (BOOL) tickDuration
{
  [super tickDuration];
  [self dealPoisonDamage];
  return YES;
}

- (void)showQuickAttackMiniLogo
{
  [self showSkillPopupMiniOverlay:[NSString stringWithFormat:@"%ld DMG & POISONED", (long)self.quickAttackDamage]];
}

- (int) poisonDamage
{
  int damage = (int)(MAX(_poisonDamage, _poisonPercent * self.opponentPlayer.maxHealth) * _poisonStacks);
  
  //Hide this here to make sure that the stacks get saved until
  //poison damage is calculated, since the skill will tick out of duration
  //before the last poison damage
  if (![self isActive])
    _poisonStacks = 0;
  
  return damage;
}

- (int) quickAttackDamage
{
  if (self.belongsToPlayer) return _initialDamage;
  return (int)(_initialDamage * _quickAttackStacks);
}

- (BOOL) doesRefresh
{
  return YES;
}

- (BOOL) activate
{
  if (self.belongsToPlayer)
  {
    _poisonStacks++;
    [self dealQuickAttack];
    return YES;
  }
  else
  {
    return [super activate];
  }
}

- (BOOL)onSpecialOrbCounterFinish:(NSInteger)numOrbs
{
  _poisonStacks += numOrbs;
  _quickAttackStacks = (int)numOrbs;
  [self dealQuickAttack];
  return YES;
}

- (void)onFinishQuickAttack
{
  [self resetDuration];
}

#pragma mark - Serialization

- (NSDictionary*) serialize
{
  NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
  [result setObject:@(_poisonStacks) forKey:@"poisonStacks"];
  
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (![super deserialize:dict])
    return NO;
  
  NSNumber* poisonStacks = [dict objectForKey:@"poisonStacks"];
  if (poisonStacks) _poisonStacks = [poisonStacks intValue];
  
  return YES;
}



@end
