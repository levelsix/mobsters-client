//
//  SkillSkewer
//  Utopia
//
//  Created by Rob Giusti on 1/26/15
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillSkewer.h"
#import "NewBattleLayer.h"

@implementation SkillSkewer

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  _lowDamage = 1;
  _highDamage = 10;
  _chance = 1;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"LOW_DAMAGE"] )
    _lowDamage = value;
  else if ( [property isEqualToString:@"HIGH_DAMAGE"] )
    _highDamage = value;
  else if ( [property isEqualToString:@"CHANCE"] )
    _chance = value;
}

#pragma mark - Overrides

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if (trigger == SkillTriggerPointEndOfPlayerMove)
  {
    if ([self skillIsReady])
    {
      if (execute)
      {
        [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
        [self.battleLayer.orbLayer disallowInput];
        [self showSkillPopupOverlay:YES withCompletion:^(){
          [self dealSkewer];
        }];
      }
      return YES;
    }
  }
  
  return NO;
}

#pragma mark - Skill logic

- (void) dealSkewer
{
  // Perform attack animation
  if (self.belongsToPlayer)
    [self.playerSprite performFarAttackAnimationWithStrength:0.f shouldEvade:NO enemy:self.enemySprite
                                                      target:self selector:@selector(dealSkewer1) animCompletion:nil];
  else
    [self.enemySprite performNearAttackAnimationWithEnemy:self.playerSprite shouldReturn:YES shouldEvade:NO shouldFlinch:YES
                                                   target:self selector:@selector(dealSkewer1) animCompletion:nil];
}

- (int) pickDamage
{
  float rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
  if (rand < _chance){
    return _highDamage;
  }
  return _lowDamage;
}

- (void) dealSkewer1
{
  // Deal damage
  [self.battleLayer dealDamage:[self pickDamage] enemyIsAttacker:(!self.belongsToPlayer) usingAbility:YES withTarget:self withSelector:@selector(dealSkewer2)];
  
  if (!self.belongsToPlayer) {
    [self.battleLayer sendServerUpdatedValuesVerifyDamageDealt:NO];
  }
}

- (void) dealSkewer2
{
  [self resetOrbCounter];
  [self skillTriggerFinished];
}

@end