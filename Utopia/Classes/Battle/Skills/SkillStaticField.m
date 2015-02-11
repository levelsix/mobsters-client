//
//  SkillStaticField.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/26/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillStaticField.h"
#import "NewBattleLayer.h"
#import "Globals.h"

@implementation SkillStaticField

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _targetHPPercToDealAsDamage = 0.f;
  _logoShown = NO;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"TARGET_HP_PERC_AS_DAMAGE"])
    _targetHPPercToDealAsDamage = value;
}

#pragma mark - Overrides

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if ([self isActive])
  {
    if (trigger == SkillTriggerPointStartOfPlayerTurn)
    {
      [self tickDuration];
    }
    
    if ((trigger == SkillTriggerPointEnemySkillActivated && self.belongsToPlayer)
        || (trigger == SkillTriggerPointPlayerSkillActivated && !self.belongsToPlayer))
    {
      if (execute)
      {
        SkillLogStart(@"Static Field -- Skill activated");
        
        [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
        [self.battleLayer.orbLayer disallowInput];
        
        [self showLogo];
        
        [self makeSkillOwnerJumpWithTarget:self selector:@selector(beginCounterAttack)];
      }
      return YES;
    }
    
  }
  
  return NO;
}

#pragma mark - Skill logic

- (void) beginCounterAttack
{
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

- (void) dealDamage
{
  BattlePlayer* opponent = self.belongsToPlayer ? self.battleLayer.enemyPlayerObject : self.battleLayer.myPlayerObject;
  int damage = floorf((float)opponent.curHealth * _targetHPPercToDealAsDamage);
  
  [self.battleLayer dealDamage:damage
               enemyIsAttacker:!self.belongsToPlayer
                  usingAbility:YES
                    withTarget:self
                  withSelector:@selector(endCounterAttack)];
  
  if (!self.belongsToPlayer)
  {
    [self.battleLayer setEnemyDamageDealt:(int)damage];
    [self.battleLayer sendServerUpdatedValuesVerifyDamageDealt:NO];
  }
}

- (void) endCounterAttack
{
  [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
  [self.battleLayer.orbLayer allowInput];
  [self skillTriggerFinished];
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
