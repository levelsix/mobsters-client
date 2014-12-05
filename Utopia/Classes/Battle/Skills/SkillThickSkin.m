//
//  SkillThickSkin.m
//  Utopia
//
//  Created by Behrouz N. on 12/4/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillThickSkin.h"
#import "Globals.h"

@implementation SkillThickSkin

#pragma mark - Initialization

-(void)setDefaultValues
{
  [super setDefaultValues];
  
  _bonusResistance = .15f;
}

-(void)setValue:(float)value forProperty:(NSString *)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"BONUS_RESISTANCE"])
    _bonusResistance = value;
}

#pragma mark - Overrides

-(NSInteger)modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  if (player != self.belongsToPlayer)
    LNLog(@"Thick Skin -- Skill invoked with damage %ld", (long)damage);
  
  if ((player && !self.belongsToPlayer && [Globals elementForNotVeryEffective:self.enemy.element] != self.player.element) ||
      (!player && self.belongsToPlayer && [Globals elementForNotVeryEffective:self.player.element] != self.enemy.element))
  {
    damage = MAX(damage - damage * _bonusResistance, 0);
    LNLog(@"Thick Skin -- Skill reduced damage to %ld", (long)damage);
  }
  
  return damage;
}

-(BOOL)skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if ((trigger == SkillTriggerPointEnemyDealsDamage && self.belongsToPlayer) ||
      (trigger == SkillTriggerPointPlayerDealsDamage && !self.belongsToPlayer))
  {
    if (execute)
    {
      [self skillTriggerFinished];
    }
    return YES;
  }
  
  return NO;
}

@end
