//
//  SkillInsurance.m
//  Utopia
//
//  Created by Rob Giusti on 2/4/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillInsurance.h"
#import "NewBattleLayer.h"

@implementation SkillInsurance

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  _damageTakenMultiplier = .5;
}

- (void) setValue:(float)value forProperty:(NSString *)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"DAMAGE_TAKEN_MULTIPLIER"])
    _damageTakenMultiplier = value;
}

#pragma mark - Overrides

- (TickTrigger) tickTrigger
{
  return TickTriggerAfterOpponentTurn;
}

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeBuffInsurance), nil];
}

- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  if ([self isActive] && self.belongsToPlayer != player)
  {
    NSInteger unmodifiedDamage = damage;
    damage *= _damageTakenMultiplier;
    [self showSkillPopupMiniOverlay:[NSString stringWithFormat:@"%li DMG BLOCKED", (unmodifiedDamage - damage)]];
  }
  
  return damage;
}
@end