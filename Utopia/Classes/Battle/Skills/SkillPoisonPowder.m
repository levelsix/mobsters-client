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
  _isPoisoned = false;
  _wasPoisoned = false;
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

- (BOOL) shouldPersist {
  return _isPoisoned || _wasPoisoned;
}

- (void) restoreVisualsIfNeeded {
  if (_isPoisoned) {
    [self addPoisonAnimations];
  }
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if (_isPoisoned)
  {
    if ((!self.belongsToPlayer && trigger == SkillTriggerPointEndOfPlayerTurn)
        || (self.belongsToPlayer && trigger == SkillTriggerPointEndOfEnemyTurn))
    {
      [self dealPoisonDamage];
      return YES;
    }
    //Reset on new target
    else if ((self.belongsToPlayer && trigger == SkillTriggerPointEnemyInitialized)
             || (!self.belongsToPlayer && trigger == SkillTriggerPointPlayerInitialized))
    {
      [self removePoison];
    }
  }
  else
  {
    if (_wasPoisoned && ((self.belongsToPlayer && trigger == SkillTriggerPointEnemyInitialized)
       || (!self.belongsToPlayer && trigger == SkillTriggerPointPlayerInitialized)))
    {
      [self poisonOpponent];
      _wasPoisoned = false;
    }
    else if ((self.activationType == SkillActivationTypeUserActivated && trigger == SkillTriggerPointManualActivation) ||
        (self.activationType == SkillActivationTypeAutoActivated && trigger == SkillTriggerPointEndOfPlayerMove))
    {
      if ([self skillIsReady])
      {
        if (execute)
        {
          [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
          [self.battleLayer.orbLayer disallowInput];
          [self showSkillPopupOverlay:YES withCompletion:^(){
            [self poisonOpponent];
          }];
        }
        return YES;
      }
    }
  }
  
  return NO;
}

- (void) poisonOpponent
{
  _isPoisoned = true;
  [self addPoisonAnimations];
  
  // Finish trigger execution
  [self performAfterDelay:0.3 block:^{
    [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
    [self.battleLayer.orbLayer allowInput];
    [self skillTriggerFinished];
  }];
}

- (void) addPoisonAnimations
{
  BattleSprite* opponent = self.belongsToPlayer ? self.enemySprite : self.playerSprite;
  
  //Make character blink purple
  [opponent.sprite stopActionByTag:1914];
  CCActionRepeatForever* action = [CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                           [CCActionTintTo actionWithDuration:1.5 color:[CCColor purpleColor]],
                                                                           [CCActionTintTo actionWithDuration:1.5 color:[CCColor whiteColor]],
                                                                           nil]];
  action.tag = 1914;
  [opponent.sprite runAction:action];
}

- (void) removePoison
{
  _isPoisoned = false;
  [self resetOrbCounter];
  [self endPoisonAnimations];
}

- (void) endPoisonAnimations
{
  BattleSprite* opponent = self.belongsToPlayer ? self.enemySprite : self.playerSprite;
  
  [opponent runAction:[CCActionEaseBounceIn actionWithAction:
                    [CCActionEaseBounceOut actionWithAction:[CCActionScaleTo actionWithDuration:0.5 scale:1.0]]]];
  [opponent.sprite stopActionByTag:1914];
  [opponent.sprite runAction:[CCActionTintTo actionWithDuration:0.3 color:[CCColor whiteColor]]];
}


- (void) dealPoisonDamage
{
  BattleSprite *poisonedSprite = self.belongsToPlayer ? self.enemySprite : self.playerSprite;
  
  
  if (self.belongsToPlayer)
  {
    [poisonedSprite performNearFlinchAnimationWithStrength:0 delay:0.4];
  }
  else
  {
    // Flinch
    [poisonedSprite performFarFlinchAnimationWithDelay:0.4];
  }
  
  // Flash red
  [poisonedSprite.sprite runAction:[CCActionSequence actions:
                                       [CCActionDelay actionWithDuration:0.3],
                                       [RecursiveTintTo actionWithDuration:0.2 color:[CCColor purpleColor]],
                                       [RecursiveTintTo actionWithDuration:0.2 color:[CCColor whiteColor]],
                                       nil]];
  
  // Skull and bones
  CCSprite* skull = [CCSprite spriteWithImageNamed:@"poisonplayer.png"];
  skull.position = ccp(20, poisonedSprite.contentSize.height/2);
  skull.scale = 0.01;
  skull.opacity = 0.0;
  [poisonedSprite addChild:skull z:10];
  [skull runAction:[CCActionSequence actions:
                    [CCActionSpawn actions:
                     [CCActionEaseElasticOut actionWithAction:[CCActionScaleTo actionWithDuration:0.3f scale:1]],
                     [CCActionFadeIn actionWithDuration:0.3f],
                     nil],
                    [CCActionCallFunc actionWithTarget:self selector:@selector(dealPoisonDamage2)],
                    [CCActionDelay actionWithDuration:0.5],
                    [CCActionEaseElasticIn actionWithAction:[CCActionScaleTo actionWithDuration:0.7f scale:0]],
                    [CCActionRemove action],
                    nil]];
}

- (void) dealPoisonDamage2
{
  int damage = MAX(_damage, _percent * (self.belongsToPlayer ? self.enemy.maxHealth : self.player.maxHealth));
  
  // Deal damage
  [self.battleLayer dealDamage:(int)damage enemyIsAttacker:!self.belongsToPlayer usingAbility:YES withTarget:self withSelector:@selector(dealPoisonDamage3)];
}

- (void) dealPoisonDamage3
{
  // Turn on the lights for the board and finish skill execution
//  [self performAfterDelay:1.3 block:^{
//    [self.battleLayer.orbLayer allowInput];
//    [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
//  }];
  [self skillTriggerFinished];
}



#pragma mark - Serialization

- (NSDictionary*) serialize
{
  NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
  [result setObject:@(_isPoisoned) forKey:@"isPoisoned"];
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (! [super deserialize:dict])
    return NO;
  
  NSNumber* isPoisoned = [dict objectForKey:@"isPoisoned"];
  if (isPoisoned)
    _wasPoisoned = [isPoisoned boolValue];
  
  return YES;
}

@end