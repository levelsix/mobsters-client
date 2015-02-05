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
  _duration = 1;
  _turnsLeft = 0;
}

- (void) setValue:(float)value forProperty:(NSString *)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"DAMAGE_TAKEN_MULTIPLIER"])
    _damageTakenMultiplier = value;
  else if ( [property isEqualToString:@"TURN_DURATION"])
    _duration = value;
}

#pragma mark - Overrides

- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  if (_turnsLeft > 0 && self.belongsToPlayer != player)
  {
    damage *= _damageTakenMultiplier;
    _turnsLeft--;
    if (_turnsLeft == 0)
      [self endInsurance];
  }
  
  return damage;
}

- (void) restoreVisualsIfNeeded
{
  if (_turnsLeft > 0)
    [self addInsuranceAnimations];
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if (_turnsLeft == 0)
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
            [self startInsurance];
          }];
        }
        return YES;
      }
    }
  }
  
  return NO;
}

#pragma mark - Skill Logic

- (void) startInsurance
{
  _turnsLeft = _duration;
  
  [self addInsuranceAnimations];
  
  [self performAfterDelay:0.3 block:^{
    [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
    [self.battleLayer.orbLayer allowInput];
    [self skillTriggerFinished];
  }];
}

- (void) endInsurance
{
  _turnsLeft = 0;
  
  [self resetOrbCounter];
  [self endInsuranceAnimations];
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

#pragma mark - Serialization

- (NSDictionary*) serialize
{
  NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
  [result setObject:@(_turnsLeft) forKey:@"turnsLeft"];
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (! [super deserialize:dict])
    return NO;
  
  NSNumber* turnsLeft = [dict objectForKey:@"turnsLeft"];
  if (turnsLeft)
    _turnsLeft = [turnsLeft intValue];
  
  return YES;
}

@end