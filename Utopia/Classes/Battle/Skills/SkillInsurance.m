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

- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  if ([self isActive] && self.belongsToPlayer != player)
  {
    damage *= _damageTakenMultiplier;
    [self tickDuration];
  }
  
  return damage;
}

- (void) restoreVisualsIfNeeded
{
  if ([self isActive])
    [self addInsuranceAnimations];
}

#pragma mark - Skill Logic

- (BOOL) onDurationStart
{
  [self addInsuranceAnimations];
  return NO;
}

- (BOOL) onDurationEnd
{
  [super onDurationEnd];
  [self endInsuranceAnimations];
  return NO;
}

#pragma mark - Animations

- (void) addInsuranceAnimations
{
  BattleSprite* mySprite = self.belongsToPlayer ? self.playerSprite : self.enemySprite;
  
  //Make character blink gray
  [mySprite.sprite stopActionByTag:1914];
  CCActionRepeatForever* action = [CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                           [CCActionTintTo actionWithDuration:1.5 color:[CCColor grayColor]],
                                                                           [CCActionTintTo actionWithDuration:1.5 color:[CCColor whiteColor]],
                                                                           nil]];
  action.tag = 1914;
  [mySprite.sprite runAction:action];
}

- (void) endInsuranceAnimations
{
  BattleSprite* mySprite = self.belongsToPlayer ? self.playerSprite : self.enemySprite;
  
  [mySprite runAction:[CCActionEaseBounceIn actionWithAction:
                       [CCActionEaseBounceOut actionWithAction:[CCActionScaleTo actionWithDuration:0.5 scale:1.0]]]];
  [mySprite.sprite stopActionByTag:1914];
  [mySprite.sprite runAction:[CCActionTintTo actionWithDuration:0.3 color:[CCColor whiteColor]]];
}

@end