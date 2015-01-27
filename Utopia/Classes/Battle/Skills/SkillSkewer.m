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
    [self.playerSprite performFarAttackAnimationWithStrength:0.f shouldEvade:NO enemy:self.enemySprite target:self selector:@selector(dealSkewer1)];
  else
    [self.enemySprite performNearAttackAnimationWithEnemy:self.playerSprite shouldReturn:YES shouldEvade:NO shouldFlinch:YES target:self selector:@selector(dealSkewer1)];
}

- (int) pickDamage
{
  if (((double)arc4random()/0x100000000) < _chance){
    return _lowDamage;
  }
  return _highDamage;
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
  // Turn on the lights for the board and finish skill execution
  //  [self performAfterDelay:1.3 block:^{
  //    [self.battleLayer.orbLayer allowInput];
  //    [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
  //  }];
  [self resetOrbCounter];
  [self skillTriggerFinished];
}

@end