//
//  SkillPoisonPowder.m
//  Utopia
//  Description: Once activated, opponent takes [X] damage each turn
//
//  Created by Rob Giusti on 1/27/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillPoisonPowder.h"
#import "NewBattleLayer.h"
#import "Globals.h"

@implementation SkillPoisonPowder

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  _damage = 10;
  _percent = 0;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"MIN_DAMAGE"])
    _damage = value;
  else if ( [property isEqualToString:@"MIN_PERCENT"])
    _percent = value;
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

- (TickTrigger)tickTrigger
{
  return TickTriggerAfterOpponentTurn;
}

- (BOOL)affectsOwner
{
  return NO;
}

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeNerfPoison), nil];
}

- (BOOL) tickDuration
{
  [self dealPoisonDamage];
  [super tickDuration];
  return YES;
}

- (int) poisonDamage
{
  return MAX(_damage, _percent * self.opponentPlayer.maxHealth);
}

@end