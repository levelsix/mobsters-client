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
  _ragedNow = NO;
  _wasRaged = NO;
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
  return _ragedNow || _wasRaged;
}

- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  if (_ragedNow)
  {
    return damage * (player == self.belongsToPlayer ? _damageTakenMultiplier : _damageGivenMultiplier);
  }
  
  return damage;
}

- (void) restoreVisualsIfNeeded
{
  if (_ragedNow)
    [self addRageAnimations];
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  if ((self.belongsToPlayer && trigger == SkillTriggerPointEnemyInitialized)
      || (!self.belongsToPlayer && trigger == SkillTriggerPointPlayerInitialized))
  {
    if (_ragedNow)
    {
      [self endBloodRage];
    }
    else if (_wasRaged)
    {
      [self startBloodRage];
      _wasRaged = false;
    }
  }
  
  if (!_ragedNow)
  {
    if ((self.activationType == SkillActivationTypeUserActivated && trigger == SkillTriggerPointManualActivation) ||
        (self.activationType == SkillActivationTypeAutoActivated && trigger == SkillTriggerPointEndOfPlayerMove))
    {
      if ([self skillIsReady])
      {
        if (execute)
        {
          [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
          [self.battleLayer.orbLayer disallowInput];
          [self showSkillPopupOverlay:YES withCompletion:^(){
            [self startBloodRage];
          }];
        }
        return YES;
      }
    }
  }
  
  return NO;
}

#pragma mark - Skill Logic

- (void) startBloodRage
{
  _ragedNow = YES;
  [self addRageAnimations];
  
  [self performAfterDelay:0.3 block:^{
    [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
    [self.battleLayer.orbLayer allowInput];
    [self skillTriggerFinished:YES];
  }];
}

- (void) endBloodRage
{
  _ragedNow = NO;
  [self resetOrbCounter];
  [self removeRageAnimations];
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

#pragma mark - Serialization

- (NSDictionary*) serialize
{
  NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
  [result setObject:@(_ragedNow) forKey:@"ragedNow"];
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (! [super deserialize:dict])
    return NO;
  
  NSNumber* ragedNow = [dict objectForKey:@"ragedNow"];
  if (ragedNow)
    _wasRaged = [ragedNow boolValue];
  
  return YES;
}


@end
