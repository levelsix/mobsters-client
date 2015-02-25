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

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeBuffInsurance), nil];
}

- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  if ([self isActive] && self.belongsToPlayer != player)
  {
    damage *= _damageTakenMultiplier;
    [self showSkillPopupMiniOverlay:NO
                         bottomText:[NSString stringWithFormat:@"%.3gX ATK", _damageTakenMultiplier]
                     withCompletion:^{}];
    [self tickDuration];
  }
  
  return damage;
}
@end