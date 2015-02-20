//
//  SkillDamage.m
//  Utopia
//
//  Created by Mikhail Larionov on 8/28/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillQuickAttack.h"
#import "NewBattleLayer.h"

@implementation SkillQuickAttack

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  _damage = 1;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"DAMAGE"] )
    _damage = value;
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
          [self dealQuickAttack];
        }];
      }
      return YES;
    }
  }
  
  return NO;
}

#pragma mark - Skill logic

- (void) dealQuickAttack
{
  // Perform attack animation
  if (self.belongsToPlayer)
    [self.playerSprite performFarAttackAnimationWithStrength:0.f shouldEvade:NO enemy:self.enemySprite
                                                      target:self selector:@selector(dealQuickAttack1) animCompletion:nil];
  else
    [self.enemySprite performNearAttackAnimationWithEnemy:self.playerSprite shouldReturn:YES shouldEvade:NO shouldFlinch:YES
                                                   target:self selector:@selector(dealQuickAttack1) animCompletion:nil];
}

- (void) dealQuickAttack1
{
  // Deal damage
  [self.battleLayer dealDamage:_damage enemyIsAttacker:(!self.belongsToPlayer) usingAbility:YES withTarget:self withSelector:@selector(dealQuickAttack2)];
  
  if (!self.belongsToPlayer) {
    [self.battleLayer sendServerUpdatedValuesVerifyDamageDealt:NO];
  }
}

- (void) dealQuickAttack2
{
  // Turn on the lights for the board and finish skill execution
//  [self performAfterDelay:1.3 block:^{
//    [self.battleLayer.orbLayer allowInput];
//    [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
//  }];
  [self resetOrbCounter];
  [self skillTriggerFinished:YES];
}

@end
