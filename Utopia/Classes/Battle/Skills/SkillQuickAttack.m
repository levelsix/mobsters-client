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

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger
{
  if (trigger == SkillTriggerPointEndOfPlayerMove)
  {
    if ([self skillIsReady])
    {
      [self showSkillPopupOverlayWithCompletion:^{
        [self dealQuickAttack];
      }];
      return YES;
    }
  }
  
  return NO;
}

#pragma mark - Skill logic

- (void) dealQuickAttack
{
  // Perform attack animation
  [self.playerSprite performFarAttackAnimationWithStrength:1.0 enemy:self.enemySprite target:self selector:@selector(callbackForAnimation)];
  
  // Show attack label
  _attackSprite = [CCSprite spriteWithImageNamed:@"quickattacktext.png"];
  _attackSprite.position = CGPointMake((self.enemySprite.position.x + self.playerSprite.position.x)/2 + self.playerSprite.contentSize.width/2 - 20, (self.playerSprite.position.y + self.enemySprite.position.y)/2 + self.playerSprite.contentSize.height/2);
  _attackSprite.scale = 0.0;
  [self.playerSprite.parent addChild:_attackSprite z:50];
  
  // Run animation
  [_attackSprite runAction:[CCActionSequence actions:
                            [CCActionDelay actionWithDuration:0.3],
                            [CCActionEaseBounceOut actionWithAction:[CCActionScaleTo actionWithDuration:0.5 scale:1.0]],
                            [CCActionDelay actionWithDuration:1.0],
                            [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:0.3 scale:0.0]],
                            [CCActionRemove action],
                            nil]];
}

- (void) callbackForAnimation
{
  // Deal damage
  [self.battleLayer dealDamage:_damage enemyIsAttacker:NO usingAbility:YES withTarget:self withSelector:@selector(skillTriggerFinished)];
}

@end
