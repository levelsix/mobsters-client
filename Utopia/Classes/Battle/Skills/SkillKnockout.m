//
//  SkillKnockout.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/27/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillKnockout.h"
#import "NewBattleLayer.h"
#import "Globals.h"

@implementation SkillKnockout

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _enemyHealthThreshold = 0;
  _fixedDamageDone = 0;
  _logoShown = NO;
}

- (void) setValue:(float)value forProperty:(NSString *)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"ENEMY_HP_THRESHOLD"])
    _enemyHealthThreshold = value;
  if ([property isEqualToString:@"FIXED_DAMAGE_DONE"])
    _fixedDamageDone = value;
}

#pragma mark - Overrides

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  // Do nothing, only show the splash at the beginning. Flag is for the case when you defeated the previous one, don't show the logo then.
  if (trigger == SkillTriggerPointEnemyAppeared && ! _logoShown)
  {
    if (execute)
    {
      _logoShown = YES;
      [self showSkillPopupOverlay:YES withCompletion:^(){
        [self performAfterDelay:.5f block:^{
          [self skillTriggerFinished];
        }];
      }];
    }
    return YES;
  }
  
  if (trigger == SkillTriggerPointEndOfPlayerMove && self.belongsToPlayer)
  {
    if ([self skillIsReady])
    {
      if (execute)
      {
        SkillLogStart(@"Knockout -- Skill activated");
        
        // Perform out of turn attack and either instantly kill the target or deal fixed damage
        [self makeSkillOwnerJumpWithTarget:self selector:@selector(beginOutOfTurnAttack)];
      }
      return YES;
    }
  }
  
  return NO;
}

#pragma mark - Skill logic

- (void) beginOutOfTurnAttack
{
  [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
  [self.battleLayer.orbLayer disallowInput];
  
  [self showLogo];
  
  const SEL selector = (self.enemy.curHealth < _enemyHealthThreshold) ? @selector(instantlyKillEnemy) : @selector(dealDamageToEnemy);

  // Perform attack animation
  [self.playerSprite performFarAttackAnimationWithStrength:0.f
                                               shouldEvade:NO
                                                     enemy:self.enemySprite
                                                    target:self
                                                  selector:selector
                                            animCompletion:nil];
}

- (void) dealDamageToEnemy
{
  [self.battleLayer dealDamage:_fixedDamageDone
               enemyIsAttacker:NO
                  usingAbility:YES
                    withTarget:self
                  withSelector:@selector(endOutOfTurnAttack)];
}

- (void) endOutOfTurnAttack
{
  [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
  [self.battleLayer.orbLayer allowInput];
  
  [self resetOrbCounter];
  [self skillTriggerFinished];
}

- (void) instantlyKillEnemy
{
  [self.battleLayer instantSetHealthForEnemey:YES
                                           to:0
                                   withTarget:self
                                  andSelector:@selector(endOutOfTurnAttack)];
}

- (void) showLogo
{
  // Display logo
  CCSprite* logoSprite = [CCSprite spriteWithImageNamed:[self.skillImageNamePrefix stringByAppendingString:kSkillMiniLogoImageNameSuffix]];
  logoSprite.position = CGPointMake((self.enemySprite.position.x + self.playerSprite.position.x) * .5f + self.playerSprite.contentSize.width * .5f - 10.f,
                                    (self.playerSprite.position.y + self.enemySprite.position.y) * .5f + self.playerSprite.contentSize.height * .5f);
  logoSprite.scale = 0.f;
  [self.playerSprite.parent addChild:logoSprite z:50];
  
  // Animate
  [logoSprite runAction:[CCActionSequence actions:
                         [CCActionDelay actionWithDuration:.3f],
                         [CCActionEaseBounceOut actionWithAction:[CCActionScaleTo actionWithDuration:.5f scale:1.f]],
                         [CCActionDelay actionWithDuration:.5f],
                         [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:.3f scale:0.f]],
                         [CCActionRemove action],
                         nil]];
}

@end
