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
#import "SkillManager.h"

@implementation SkillThickSkin

#pragma mark - Initialization

-(void)setDefaultValues
{
  [super setDefaultValues];
  
  _bonusResistance = 0.f;
  _damageAbsorbed = 0;
}

-(void)setValue:(float)value forProperty:(NSString *)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"BONUS_RESISTANCE"])
    _bonusResistance = value;
}

#pragma mark - Overrides

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeBuffThickSkin), nil];
}

- (void) restoreVisualsIfNeeded
{
  if ([self isActive])
  {
    [self addSkillSideEffectToSkillOwner:SideEffectTypeBuffThickSkin turnsAffected:self.turnsLeft];
  }
}

-(NSInteger)modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  if ([self isActive] && player != self.belongsToPlayer)
  {
    SkillLogStart(@"Thick Skin -- %@ skill invoked from %@ with damage %ld",
                  self.belongsToPlayer ? @"PLAYER" : @"ENEMY",
                  player ? @"PLAYER" : @"ENEMY",
                  (long)damage);
    
    _damageAbsorbed = 0;
    
    if ((player && !self.belongsToPlayer && [Globals elementForNotVeryEffective:self.enemy.element] != self.player.element) ||
        (!player && self.belongsToPlayer && [Globals elementForNotVeryEffective:self.player.element] != self.enemy.element))
    {
      _damageAbsorbed = damage * _bonusResistance;
      damage = MAX(damage - _damageAbsorbed, 0);
      [self showDamageAbsorbed];
      SkillLogStart(@"Thick Skin -- Skill reduced damage to %ld", (long)damage);
    }
  }
  
  return damage;
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if ((self.belongsToPlayer && trigger == SkillTriggerPointEndOfEnemyTurn)
      || (!self.belongsToPlayer && trigger == SkillTriggerPointEndOfPlayerTurn))
  {
    if (execute)
    {
      [self tickDuration];
    }
  }
  
  return NO;
}

- (BOOL) onDurationStart
{
  [self addSkillSideEffectToSkillOwner:SideEffectTypeBuffThickSkin turnsAffected:self.turnsLeft];
  
  return NO;
}

- (BOOL) onDurationReset
{
  [self resetAfftectedTurnsCount:self.turnsLeft forSkillSideEffectOnSkillOwner:SideEffectTypeBuffThickSkin];
  
  return [super onDurationStart];
}

- (BOOL) onDurationEnd
{
  [self removeSkillSideEffectFromSkillOwner:SideEffectTypeBuffThickSkin];
  
  return [super onDurationEnd];
}

#pragma mark - Skill logic

-(void)showDamageAbsorbed
{
  if (_damageAbsorbed > 0)
  {
    [self showSkillPopupMiniOverlay:NO
                         bottomText:[NSString stringWithFormat:@"%ld DMG BLOCKED", (long)_damageAbsorbed]
                     withCompletion:^{}];
  }
  
  /*
  // Display logo
  CCSprite* logoSprite = [CCSprite spriteWithImageNamed:[self.skillImageNamePrefix stringByAppendingString:kSkillMiniLogoImageNameSuffix]];
  logoSprite.position = CGPointMake((self.enemySprite.position.x + self.playerSprite.position.x) * .5f + self.playerSprite.contentSize.width * .5f - 10.f,
                                    (self.playerSprite.position.y + self.enemySprite.position.y) * .5f + self.playerSprite.contentSize.height * .5f);
  logoSprite.scale = 0.f;
  [self.playerSprite.parent addChild:logoSprite z:50];
  
  // Display damage absorbed label
  CCLabelTTF* floatingLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%ld DAMAGE BLOCKED", (long)_damageAbsorbed] fontName:@"GothamNarrow-Ultra" fontSize:12];
  floatingLabel.position = ccp(logoSprite.spriteFrame.rect.size.width * .5f, -13.f);
  floatingLabel.fontColor = [CCColor colorWithRed:255.f / 225.f green:232.f / 225.f blue:174.f / 225.f];
  floatingLabel.outlineColor = [CCColor colorWithRed:148.f / 225.f green:46.f / 225.f blue:11.f / 225.f];
  floatingLabel.shadowOffset = ccp(0.f, -1.f);
  floatingLabel.shadowColor = [CCColor colorWithWhite:0.f alpha:.75f];
  floatingLabel.shadowBlurRadius = 2.f;
  [logoSprite addChild:floatingLabel];
  
  // Animate both
  [logoSprite runAction:[CCActionSequence actions:
                         [CCActionDelay actionWithDuration:.3f],
                         [CCActionEaseBounceOut actionWithAction:[CCActionScaleTo actionWithDuration:.5f scale:1.f]],
                         [CCActionDelay actionWithDuration:.5f],
                         [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:.3f scale:0.f]],
                         [CCActionRemove action],
                         nil]];
   */
}

@end
