//
//  SkillBloodRage.m
//  Utopia
//  Description: Enemy gets [X]% increased attack damage, but takes [Y]% more damage.
//
//  Created by Rob Giusti on 1/29/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillBloodRage.h"
#import "NewBattleLayer.h"

@implementation SkillBloodRage

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  _damageGivenMultiplier = 1.25;
  _damageTakenMultiplier = 1.5;
}

- (void) setValue:(float)value forProperty:(NSString *)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"DAMAGE_GIVEN_MULTIPLIER"])
    _damageGivenMultiplier = value;
  else if ( [property isEqualToString:@"DAMAGE_TAKEN_MULTIPLIER"])
    _damageTakenMultiplier = value;
}

#pragma mark - Overrides

- (BOOL) shouldPersist
{
  return [self isActive];
}

- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  if ([self isActive])
  {
    if (self.belongsToPlayer == player)
    {
      [self tickDuration];
      return damage * _damageTakenMultiplier;
    }
    else
    {
      return damage * _damageGivenMultiplier;
    }
  }
  
  return damage;
}

- (void) restoreVisualsIfNeeded
{
  if ([self isActive])
    [self addRageAnimations];
}

#pragma mark - Skill Logic

- (BOOL) onDurationStart
{
  [self addRageAnimations];
  
  [self performAfterDelay:0.3 block:^{
    [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
    [self.battleLayer.orbLayer allowInput];
    [self skillTriggerFinished:YES];
  }];
  
  return YES;
}

- (BOOL) onDurationEnd
{
  [self removeRageAnimations];
  
  return NO;
}

#pragma mark - Animations

- (void) addRageAnimations
{
  BattleSprite* opponent = self.belongsToPlayer ? self.enemySprite : self.playerSprite;
  
  //Make character blink orange
  [opponent.sprite stopActionByTag:1914];
  CCActionRepeatForever* action = [CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                           [CCActionTintTo actionWithDuration:1.5 color:[CCColor orangeColor]],
                                                                           [CCActionTintTo actionWithDuration:1.5 color:[CCColor whiteColor]],
                                                                           nil]];
  action.tag = 1914;
  [opponent.sprite runAction:action];
}

- (void) removeRageAnimations
{
  BattleSprite* opponent = self.belongsToPlayer ? self.enemySprite : self.playerSprite;
  
  [opponent runAction:[CCActionEaseBounceIn actionWithAction:
                       [CCActionEaseBounceOut actionWithAction:[CCActionScaleTo actionWithDuration:0.5 scale:1.0]]]];
  [opponent.sprite stopActionByTag:1914];
  [opponent.sprite runAction:[CCActionTintTo actionWithDuration:0.3 color:[CCColor whiteColor]]];
}

@end
