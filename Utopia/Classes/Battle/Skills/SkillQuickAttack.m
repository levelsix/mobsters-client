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
    [self.playerSprite performFarAttackAnimationWithStrength:1.0 enemy:self.enemySprite target:self selector:@selector(dealQuickAttack1)];
  else
    [self.enemySprite performNearAttackAnimationWithEnemy:self.playerSprite shouldReturn:YES shouldFlinch:NO target:self selector:@selector(dealQuickAttack1)];
  
  // Show attack label
  /*_attackSprite = [CCSprite spriteWithImageNamed:@"cheapshotlogo.png"];
   _attackSprite.position = CGPointMake((self.enemySprite.position.x + self.playerSprite.position.x)/2 + self.playerSprite.contentSize.width/2 - 20, (self.playerSprite.position.y + self.enemySprite.position.y)/2 + self.playerSprite.contentSize.height/2);
   _attackSprite.scale = 0.0;
   [self.playerSprite.parent addChild:_attackSprite z:50];
  
  // Run animation
  [_attackSprite runAction:[CCActionSequence actions:
                            [CCActionDelay actionWithDuration:0.3],
                            [CCActionEaseBounceOut actionWithAction:[CCActionScaleTo actionWithDuration:0.5 scale:0.5]],
                            [CCActionDelay actionWithDuration:1.0],
                            [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:0.3 scale:0.0]],
                            [CCActionRemove action],
                            nil]];*/
}

- (void) dealQuickAttack1
{
  // Deal damage
  [self.battleLayer dealDamage:_damage enemyIsAttacker:(!self.belongsToPlayer) usingAbility:YES withTarget:self withSelector:@selector(dealQuickAttack2)];
}

- (void) dealQuickAttack2
{
  // Turn on the lights for the board and finish skill execution
  [self.battleLayer.orbLayer.bgdLayer performSelector:@selector(turnTheLightsOn) withObject:nil afterDelay:1.3];
  [self skillTriggerFinished];
}

@end
