//
//  SkillThickSkin.m
//  Utopia
//
//  Created by Behrouz N. on 12/4/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillThickSkin.h"
#import "NewBattleLayer.h"
#import "Globals.h"

@implementation SkillThickSkin

#pragma mark - Initialization

-(void)setDefaultValues
{
  [super setDefaultValues];
  
  _bonusResistance = .15f;
  _damageAbsorbed = 0;
  _logoShown = NO;
}

-(void)setValue:(float)value forProperty:(NSString *)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"BONUS_RESISTANCE"])
    _bonusResistance = value;
}

#pragma mark - Overrides

-(NSInteger)modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  if (player != self.belongsToPlayer)
    LNLog(@"Thick Skin -- Skill invoked with damage %ld", (long)damage);
  
  _damageAbsorbed = 0;
  
  if ((player && !self.belongsToPlayer && [Globals elementForNotVeryEffective:self.enemy.element] != self.player.element) ||
      (!player && self.belongsToPlayer && [Globals elementForNotVeryEffective:self.player.element] != self.enemy.element))
  {
    _damageAbsorbed = damage * _bonusResistance;
    damage = MAX(damage - _damageAbsorbed, 0);
    LNLog(@"Thick Skin -- Skill reduced damage to %ld", (long)damage);
  }
  
  return damage;
}

-(BOOL)skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  // Do nothing, only show the splash at the beginning. Flag is for the case when you defeated the previous one, don't show the logo then.
  if (trigger == SkillTriggerPointEnemyAppeared && ! _logoShown)
  {
    if (execute)
    {
      [self showSkillPopupOverlay:YES withCompletion:^(){
        _logoShown = YES;
        [self performAfterDelay:.5f block:^{
          [self skillTriggerFinished];
        }];
      }];
    }
    return YES;
  }
  
  if ((trigger == SkillTriggerPointEnemyDealsDamage && self.belongsToPlayer) ||
      (trigger == SkillTriggerPointPlayerDealsDamage && !self.belongsToPlayer))
  {
    if (execute)
    {
      if (_damageAbsorbed > 0)
      {
        [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
        [self.battleLayer.orbLayer disallowInput];
        [self showDamageAbsorbed];
        
        _callbackParams = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:SKILL_CONTROLLER_USING_ABILITY_KEY];
      }
      else
        [self skillTriggerFinished];
    }
    return YES;
  }
  
  return NO;
}

#pragma mark - Skill logic

-(void)showDamageAbsorbed
{
  // Display logo
  CCSprite* logoSprite = [CCSprite spriteWithImageNamed:@"thickskinminilogo.png"];
  logoSprite.position = CGPointMake((self.enemySprite.position.x + self.playerSprite.position.x) * .5f + self.playerSprite.contentSize.width * .5f - 10.f,
                                    (self.playerSprite.position.y + self.enemySprite.position.y) * .5f + self.playerSprite.contentSize.height * .5f);
  logoSprite.scale = 0.f;
  [self.playerSprite.parent addChild:logoSprite z:50];
  
  // Display damage absorbed label
  CCLabelTTF* damageLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%ld DAMAGE BLOCKED", (long)_damageAbsorbed] fontName:@"GothamNarrow-Ultra" fontSize:12];
  damageLabel.position = ccp(logoSprite.spriteFrame.rect.size.width * .5f, -13.f);
  damageLabel.fontColor = [CCColor colorWithRed:255.f / 225.f green:232.f / 225.f blue:174.f / 225.f];
  damageLabel.outlineColor = [CCColor colorWithRed:148.f / 225.f green:46.f / 225.f blue:11.f / 225.f];
  [logoSprite addChild:damageLabel];
  
  // Animate both
  [logoSprite runAction:[CCActionSequence actions:
                         [CCActionDelay actionWithDuration:.3f],
                         [CCActionEaseBounceOut actionWithAction:[CCActionScaleTo actionWithDuration:.5f scale:1.f]],
                         [CCActionDelay actionWithDuration:.5f],
                         [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:.3f scale:0.f]],
                         [CCActionRemove action],
                         nil]];
  
  // Finish trigger execution
  [self performAfterDelay:.3f block:^{
    [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
    [self.battleLayer.orbLayer allowInput];
    [self skillTriggerFinished];
  }];
}

@end
