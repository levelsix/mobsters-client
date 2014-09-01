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

- (void) setDefaultValuesForProperties
{
  _damage = 1;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  if ( [property isEqualToString:@"DAMAGE"] )
    _damage = value;
}

- (void) callbackForAnimation
{
  // Deal damage
  [self.battleLayer dealDamage:_damage enemyIsAttacker:NO withTarget:self withSelector:@selector(skillExecutionFinished)];
}

- (void) skillExecutionStarted
{
  // Perform attack animation
  [self.playerSprite performFarAttackAnimationWithStrength:1.0 enemy:self.enemySprite target:self selector:@selector(callbackForAnimation)];
  
  // Show attack label
  _attackSprite = [CCSprite spriteWithImageNamed:@"quickattacktext.png"];
  _attackSprite.position = CGPointMake((self.playerSprite.position.x - self.enemySprite.position.x)/2 + 40,
                                     (self.playerSprite.position.y - self.enemySprite.position.y)/2 + 40);  // ASHWIN - question
  _attackSprite.scale = 0.0;
  [self.playerSprite addChild:_attackSprite z:50];
  
  // ASHWIN - question - why not @2x (bad quality) and how to run two actions at once?
  [_attackSprite runAction:[CCActionSequence actions:
                        [CCActionDelay actionWithDuration:0.3],
                        [CCActionEaseBounceOut actionWithAction:[CCActionScaleTo actionWithDuration:0.5 scale:1.0]],
                        [CCActionDelay actionWithDuration:1.0],
                        [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:0.3 scale:0.0]],
                        [CCActionCallBlock actionWithBlock:
                         ^{
                           // Remove sprite
                           [_attackSprite removeFromParentAndCleanup:YES];    // ASHWIN - question is it ok to do that
                         }],
                        nil]];
}

@end
