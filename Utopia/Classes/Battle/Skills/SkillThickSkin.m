//
//  SkillThickSkin.m
//  Utopia
//
//  Created by Behrouz N. on 12/4/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillThickSkin.h"
#import "NewBattleLayer.h"
#import "Globals.h"
#import "SkillManager.h"

@implementation SkillThickSkin

#pragma mark - Initialization

-(void)setDefaultValues
{
  [super setDefaultValues];
  
  _bonusResistance = 0.f;
  _damageAbsorbed = 0;
}

-(void)setValue:(float)value forProperty:(NSString *)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"BONUS_RESISTANCE"])
    _bonusResistance = value;
}

#pragma mark - Overrides

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeBuffThickSkin), nil];
}

-(NSInteger)modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  if ([self isActive] && player != self.belongsToPlayer)
  {
    SkillLogStart(@"Thick Skin -- %@ skill invoked from %@ with damage %ld",
                  self.belongsToPlayer ? @"PLAYER" : @"ENEMY",
                  player ? @"PLAYER" : @"ENEMY",
                  (long)damage);
    
    _damageAbsorbed = 0;
    
    if ((player && !self.belongsToPlayer && [Globals elementForNotVeryEffective:self.enemy.element] != self.player.element) ||
        (!player && self.belongsToPlayer && [Globals elementForNotVeryEffective:self.player.element] != self.enemy.element))
    {
      _damageAbsorbed = damage * _bonusResistance;
      damage = MAX(damage - _damageAbsorbed, 0);
      [self showDamageAbsorbed];
      SkillLogStart(@"Thick Skin -- Skill reduced damage to %ld", (long)damage);
    }
  }
  
  return damage;
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if ((self.belongsToPlayer && trigger == SkillTriggerPointEndOfEnemyTurn)
      || (!self.belongsToPlayer && trigger == SkillTriggerPointEndOfPlayerTurn))
  {
    if (execute)
    {
      [self tickDuration];
    }
  }
  
  return NO;
}

#pragma mark - Skill logic

-(void)showDamageAbsorbed
{
  if (_damageAbsorbed > 0)
  {
    [self showSkillPopupMiniOverlay:NO
                         bottomText:[NSString stringWithFormat:@"%ld DMG BLOCKED", (long)_damageAbsorbed]
                     withCompletion:^{}];
  }
}

@end
