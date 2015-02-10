//
//  SkillBlindingLight.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/26/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillBlindingLight.h"
#import "NewBattleLayer.h"
#import "Globals.h"

@implementation SkillBlindingLight

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _fixedDamageDone = 0;
  _missChance = 0.f;
  _logoShown = NO;
  _missed = NO;
}

- (void) setValue:(float)value forProperty:(NSString *)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"FIXED_DAMAGE_DONE"])
    _fixedDamageDone = value;
  if ([property isEqualToString:@"MISS_CHANCE"])
    _missChance = value;
}

#pragma mark - Overrides

- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  if (player != self.belongsToPlayer)
  {
    _missed = NO;
    if ([self isActive])
    {
      // Chance of missing
      float rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
      if (rand < _missChance)
      {
        damage = 0;
        _missed = YES;
        SkillLogStart(@"Blinding Light -- Skill caused a miss");
      }
      
      [self tickDuration];
    }
  }
  
  return damage;
}

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
  
  if ((trigger == SkillTriggerPointEnemyDealsDamage && self.belongsToPlayer)
      || (trigger == SkillTriggerPointPlayerDealsDamage && !self.belongsToPlayer))
  {
    if (execute)
    {
      if (_missed)
        [self showLogo:YES];
      
      [self performAfterDelay:.3f block:^{
        [self skillTriggerFinished];
      }];
    }
    return YES;
  }
  
  if ((trigger == SkillTriggerPointEnemyDefeated && self.belongsToPlayer)
      || (trigger == SkillTriggerPointPlayerInitialized && !self.belongsToPlayer))
  {
    if ([self isActive])
    {
      if (execute)
      {
        SkillLogStart(@"Blinding Light -- Skill deactivated");
        
        [self resetOrbCounter];
        [self endDurationNow];
        [self skillTriggerFinished];
      }
      return YES;
    }
  }
  
  return NO;
}

- (BOOL) onDurationStart
{
  [self makeSkillOwnerJumpWithTarget:self selector:@selector(beginOutOfTurnAttack)];
  return YES;
}

- (BOOL) onDurationReset
{
  [self makeSkillOwnerJumpWithTarget:self selector:@selector(beginOutOfTurnAttack)];
  return YES;
}

#pragma mark - Skill logic

- (void) beginOutOfTurnAttack
{
  [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
  [self.battleLayer.orbLayer disallowInput];
  
  [self showLogo:NO];
  
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
  [self.battleLayer dealDamage:_fixedDamageDone
               enemyIsAttacker:!self.belongsToPlayer
                  usingAbility:YES
                    withTarget:self
                  withSelector:@selector(endOutOfTurnAttack)];
  
  if (!self.belongsToPlayer)
  {
    [self.battleLayer setEnemyDamageDealt:(int)_fixedDamageDone];
    [self.battleLayer sendServerUpdatedValuesVerifyDamageDealt:NO];
  }
}

- (void) endOutOfTurnAttack
{
  [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
  [self.battleLayer.orbLayer allowInput];
  
  [self skillTriggerFinished];
}

- (void) showLogo:(BOOL)showMissedLabel
{
  // Display logo
  CCSprite* logoSprite = [CCSprite spriteWithImageNamed:[self.skillImageNamePrefix stringByAppendingString:kSkillMiniLogoImageNameSuffix]];
  logoSprite.position = CGPointMake((self.enemySprite.position.x + self.playerSprite.position.x) * .5f + self.playerSprite.contentSize.width * .5f - 10.f,
                                    (self.playerSprite.position.y + self.enemySprite.position.y) * .5f + self.playerSprite.contentSize.height * .5f);
  logoSprite.scale = 0.f;
  [self.playerSprite.parent addChild:logoSprite z:50];
  
  if (showMissedLabel)
  {
    // Display missed label
    CCLabelTTF* floatingLabel = [CCLabelTTF labelWithString:@"MISSED" fontName:@"GothamNarrow-Ultra" fontSize:12];
    floatingLabel.position = ccp(logoSprite.spriteFrame.rect.size.width * .5f, -13.f);
    floatingLabel.fontColor = [CCColor colorWithRed:255.f / 225.f green:44.f / 225.f blue:44.f / 225.f];
    floatingLabel.outlineColor = [CCColor whiteColor];
    floatingLabel.shadowOffset = ccp(0.f, -1.f);
    floatingLabel.shadowColor = [CCColor colorWithWhite:0.f alpha:.75f];
    floatingLabel.shadowBlurRadius = 2.f;
    [logoSprite addChild:floatingLabel];
  }
  
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
