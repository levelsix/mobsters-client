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

# pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _damage = 0;
  _chance = 1;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"DAMAGE"])
    _damage = value;
  else if ([property isEqualToString:@"CHANCE"])
    _chance = value;
}

# pragma mark - Overrides

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeBuffCounterStrike), nil];
}

- (void) restoreVisualsIfNeeded
{
  if ([self isActive])
  {
    [self addSkillSideEffectToSkillOwner:SideEffectTypeBuffCounterStrike turnsAffected:self.turnsLeft];
  }
}

- (BOOL) onDurationStart
{
  [self addSkillSideEffectToSkillOwner:SideEffectTypeBuffCounterStrike turnsAffected:self.turnsLeft];
  
  return [super onDurationStart];
}

- (BOOL) onDurationReset
{
  [self resetAfftectedTurnsCount:self.turnsLeft forSkillSideEffectOnSkillOwner:SideEffectTypeBuffCounterStrike];
  
  return NO;
}

- (BOOL) onDurationEnd
{
  [self removeSkillSideEffectFromSkillOwner:SideEffectTypeBuffCounterStrike];
  
  return [super onDurationEnd];
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
          [self beginCounterStrike];
        }
        else{
          return NO;
        }
      }
      return YES;
    }
  }
  
  return NO;
}

#pragma mark - Skill Logic

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