//
//  SkillCounterStrike.m
//  Utopia
//
//  Created by Robert Giusti on 1/21/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillCounterStrike.h"
#import "NewBattleLayer.h"

@implementation SkillCounterStrike

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _damage = 0;
  _chance = 0;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"DAMAGE"])
    _damage = value;
  else if ([property isEqualToString:@"CHANCE"])
    _chance = value;
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute {
  
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  
  if ([self isActive])
  {
    if ((trigger == SkillTriggerPointEndOfEnemyTurn && self.belongsToPlayer)
        || (trigger == SkillTriggerPointEndOfPlayerTurn && !self.belongsToPlayer)){
      if (execute){
        [self tickDuration];
        float rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
        if (rand < _chance){
          [self showSkillPopupOverlay:YES withCompletion:^(){
            [self beginCounterStrike];
          }];
        }
        else{
          return NO;
        }
      }
      return YES;
    }
  }
  
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
          [self resetDuration];
          [self resetOrbCounter];
          [self skillTriggerFinished];
        }];
      }
      return YES;
    }
  }
  
  return NO;
}

- (void) beginCounterStrike {
  
  [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
  [self.battleLayer.orbLayer disallowInput];
  
  // Perform attack animation
  if (self.belongsToPlayer)
    [self.playerSprite performFarAttackAnimationWithStrength:0.f
                                                 shouldEvade:NO
                                                       enemy:self.enemySprite
                                                      target:self
                                                    selector:@selector(dealDamage)
                                              animCompletion:nil];
  else
    [self.enemySprite performNearAttackAnimationWithEnemy:self.playerSprite
                                             shouldReturn:YES
                                              shouldEvade:NO
                                             shouldFlinch:YES
                                                   target:self
                                                 selector:@selector(dealDamage)
                                           animCompletion:nil];
}

- (void) dealDamage {
  [self.battleLayer dealDamage:_damage
               enemyIsAttacker:!self.belongsToPlayer
                  usingAbility:YES
                    withTarget:self
                  withSelector:@selector(endCounterStrike)];
  
  if (!self.belongsToPlayer)
  {
    [self.battleLayer setEnemyDamageDealt:(int)_damage];
    [self.battleLayer sendServerUpdatedValuesVerifyDamageDealt:NO];
  }
}

- (void) endCounterStrike {
  [self skillTriggerFinished];
}

@end