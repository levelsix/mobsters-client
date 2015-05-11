//
//  SkillChill.m
//  Utopia
//
//  Created by Rob Giusti on 3/19/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillChill.h"
#import "NewBattleLayer.h"

@implementation SkillChill

- (void) setDefaultValues
{
  [super setDefaultValues];
  _turnsSkipped = 1;
  _offensiveDamageMultiplier = .67;
}

- (void) setValue:(float)value forProperty:(NSString *)property
{
  [super setValue:value forProperty:property];
  if ([property isEqualToString:@"MOVES_SKIPPED"])
    _turnsSkipped = value;
  if ([property isEqualToString:@"OFF_DAMAGE_MULTIPLIER"])
    _offensiveDamageMultiplier = value;
}

#pragma mark Overrides

- (BOOL)affectsOwner
{
  return NO;
}

- (BOOL)ticksOnUserDeath
{
  return YES;
}

- (TickTrigger)tickTrigger
{
  return TickTriggerAfterOpponentTurn;
}

- (NSSet *)sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeNerfChill), nil];
}

- (NSInteger)modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  if ([self isActive])
  {
    if (!player && self.belongsToPlayer)
    {
      [self showSkillPopupAilmentOverlay:@"CHILLED" bottomText:[NSString stringWithFormat:@"%.3gX DMG", _offensiveDamageMultiplier]];
      return damage * _offensiveDamageMultiplier;
    }
  }
  
  return damage;
}

- (BattleItemType)antidoteType
{
  return BattleItemTypeChillAntidote;
}

- (void)onCureStatus
{
  self.battleLayer.movesLeft += _turnsSkipped;
  self.opponentPlayer.isChilled = NO;
  [super onCureStatus];
}

- (BOOL)onDurationEnd
{
  self.opponentPlayer.isChilled = NO;
  return [super onDurationEnd];
}

- (void)restoreVisualsIfNeeded
{
  self.opponentPlayer.isChilled = [self isActive];
  return [super restoreVisualsIfNeeded];
}

- (NSString *)cureBottomText
{
  return @"Poison Removed";
}

#pragma mark Skill Logic

- (BOOL)activate
{
  self.opponentPlayer.isChilled = YES;
  if (!self.belongsToPlayer)
  {
    [self.battleLayer setMovesLeft:MAX(self.battleLayer.movesLeft - _turnsSkipped, 0) animated:YES];
  }
  return [super activate];
}

- (BOOL)skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if ([self isActive]
      && !self.belongsToPlayer && trigger == SkillTriggerPointStartOfPlayerTurn)
  {
    if (execute)
    {
      [self.battleLayer setMovesLeft:MAX(self.battleLayer.movesLeft - _turnsSkipped, 0) animated:YES];
      [self showSkillPopupAilmentOverlay:@"CHILLED" bottomText:[NSString stringWithFormat:@"%i MOVE LOST", _turnsSkipped]];
      [self skillTriggerFinished];
    }
    return YES;
  }
  
  return NO;
}


@end