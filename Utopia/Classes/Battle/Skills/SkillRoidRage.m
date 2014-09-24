//
//  SkillRoidRage.m
//  Utopia
//
//  Created by Mikhail Larionov on 9/22/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillRoidRage.h"
#import "NewBattleLayer.h"

@implementation SkillRoidRage

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  _damageMultiplier = 1.5;
  _sizeMultiplier = 1.1;
  _enragedNow = NO;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"DAMAGE_MULTIPLIER"] )
    _damageMultiplier = value;
  if ( [property isEqualToString:@"SIZE_MULTIPLIER"] )
    _sizeMultiplier = value;
}

#pragma mark - Overrides

- (void) orbDestroyed:(OrbColor)color special:(SpecialOrbType)type
{
  if (_enragedNow)
    return;
  else
    [super orbDestroyed:color special:type];
}

- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  // If attacker is the skill owner and he's enraged, modify
  if (player == self.belongsToPlayer)
    if (_enragedNow)
    {
      _enragedNow = NO;
      [self performSelector:@selector(removeEnrageAnimations) withObject:nil afterDelay:2.0];
      return damage * _damageMultiplier;
    }
  
  return damage;
}

- (void) restoreVisualsIfNeeded
{
  if (_enragedNow)
    [self addEnrageAnimations];
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  //if (trigger == SkillTriggerPointEndOfPlayerMove)
  if (trigger == SkillTriggerPointManualActivation)
  {
    if ([self skillIsReady])
    {
      if (execute)
      {
        [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
        [self.battleLayer.orbLayer disallowInput];
        [self showSkillPopupOverlay:YES withCompletion:^(){
          [self becomeEnraged];
        }];
      }
      return YES;
    }
  }
  
  return NO;
}

#pragma mark - Skill logic

- (void) addEnrageAnimations
{
  // Size player and make him blue
  [self.playerSprite runAction:[CCActionEaseBounceIn actionWithAction:[CCActionScaleTo actionWithDuration:0.3 scale:1.25]]];
  CCActionRepeatForever* action = [CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                           [CCActionTintTo actionWithDuration:0.5 color:[CCColor cyanColor]],
                                                                           [CCActionTintTo actionWithDuration:0.5 color:[CCColor whiteColor]],
                                                                           nil]];
  action.tag = 1914;
  [self.playerSprite.sprite runAction:action];
}

- (void) removeEnrageAnimations
{
  [self.playerSprite runAction:[CCActionEaseBounceIn actionWithAction:
                                                        [CCActionEaseBounceOut actionWithAction:[CCActionScaleTo actionWithDuration:0.5 scale:1.0]]]];
  [self.playerSprite.sprite stopActionByTag:1914];
  [self.playerSprite.sprite runAction:[CCActionTintTo actionWithDuration:0.3 color:[CCColor whiteColor]]];
}

- (void) becomeEnraged
{
  // Show attack label
  CCSprite* increaseSprite = [CCSprite spriteWithImageNamed:@"150percentatk.png"];
  increaseSprite.position = CGPointMake((self.enemySprite.position.x + self.playerSprite.position.x)/2 + self.playerSprite.contentSize.width/2 - 20, (self.playerSprite.position.y + self.enemySprite.position.y)/2 + self.playerSprite.contentSize.height/2);
  increaseSprite.scale = 0.0;
  [self.playerSprite.parent addChild:increaseSprite z:50];
  
  // Run animation
  [increaseSprite runAction:[CCActionSequence actions:
        [CCActionDelay actionWithDuration:0.3],
        [CCActionEaseBounceOut actionWithAction:[CCActionScaleTo actionWithDuration:0.5 scale:1.0]],
        [CCActionDelay actionWithDuration:0.5],
        [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:0.3 scale:0.0]],
        [CCActionRemove action],
        nil]];
  
  _enragedNow = YES;
  
  // Animations
  [self addEnrageAnimations];
  
  // Finish trigger execution
  [self resetOrbCounter];
  [self performAfterDelay:0.3 block:^{
    [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
    [self.battleLayer.orbLayer allowInput];
    [self skillTriggerFinished];
  }];
}

#pragma mark - Serialization

- (NSDictionary*) serialize
{
  NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
  [result setObject:@(_enragedNow) forKey:@"enragedNow"];
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (! [super deserialize:dict])
    return NO;
  
  NSNumber* enragedNow = [dict objectForKey:@"enragedNow"];
  if (enragedNow)
    _enragedNow = [enragedNow boolValue];
  
  return YES;
}

@end
