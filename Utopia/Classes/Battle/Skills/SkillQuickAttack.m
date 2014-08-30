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

- (void) callbackForAnimation
{
  [self.battleLayer dealDamage:50 enemyIsAttacker:NO withTarget:self withSelector:@selector(skillExecutionFinished)];
  // MISHA: TODO damage from proto and add animation
}

- (void) skillExecutionStarted
{
  [self.playerSprite performFarAttackAnimationWithStrength:1.0 enemy:self.enemySprite target:self selector:@selector(callbackForAnimation)];
}


@end
