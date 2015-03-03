//
//  SkillRoidRage.m
//  Utopia
//
//  Created by Mikhail Larionov on 9/22/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillRoidRage.h"
#import "NewBattleLayer.h"

@implementation SkillRoidRage

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  _damageMultiplier = 1.5;
  _sizeMultiplier = 1.1;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"DAMAGE_MULTIPLIER"] )
    _damageMultiplier = value;
  if ( [property isEqualToString:@"SIZE_MULTIPLIER"] )
    _sizeMultiplier = value;
}

#pragma mark - Overrides

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeBuffRoidRage), nil];
}

- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  // If attacker is the skill owner and he's enraged, modify
  if (player == self.belongsToPlayer)
    if ([self isActive])
    {
      [self tickDuration];
      [self showSkillPopupMiniOverlay:NO
                           bottomText:[NSString stringWithFormat:@"%.3gX ATK", _damageMultiplier]
                       withCompletion:^{}];
      return damage * _damageMultiplier;
    }
  
  return damage;
}

- (void) restoreVisualsIfNeeded
{
  if ([self isActive])
    [self addEnrageAnimations];
}

- (BOOL) onDurationStart
{
  [self becomeEnraged];
  return YES;
}

- (BOOL) onDurationReset
{
  [self resetAfftectedTurnsCount:self.turnsLeft forSkillSideEffectOnSkillOwner:SideEffectTypeBuffRoidRage];
  return NO;
}

- (BOOL) onDurationEnd
{
  [self performAfterDelay:2.0 block:^(void){
    [self removeEnrageAnimations];
  }];
  return [super onDurationEnd];
}

#pragma mark - Skill logic

- (void) addEnrageAnimations
{
  BattleSprite* owner = self.belongsToPlayer ? self.playerSprite : self.enemySprite;
  
  // Size player and make him blue
  [owner.sprite runAction:[CCActionEaseBounceIn actionWithAction:[CCActionScaleTo actionWithDuration:0.3 scale:1.15]]];
  [owner.sprite stopActionByTag:1914];
  CCActionRepeatForever* action = [CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                           [CCActionTintTo actionWithDuration:0.5 color:[CCColor cyanColor]],
                                                                           [CCActionTintTo actionWithDuration:0.5 color:[CCColor whiteColor]],
                                                                           nil]];
  action.tag = 1914;
  [owner.sprite runAction:action];
  
  [self addSkillSideEffectToSkillOwner:SideEffectTypeBuffRoidRage turnsAffected:self.turnsLeft];
}

- (void) removeEnrageAnimations
{
  BattleSprite* owner = self.belongsToPlayer ? self.playerSprite : self.enemySprite;
  
  // Back to original size and color
  [owner.sprite runAction:[CCActionEaseBounceIn actionWithAction:[CCActionEaseBounceOut actionWithAction:[CCActionScaleTo actionWithDuration:0.5 scale:1.0]]]];
  [owner.sprite stopActionByTag:1914];
  [owner.sprite runAction:[CCActionTintTo actionWithDuration:0.3 color:[CCColor whiteColor]]];
  
  [self removeSkillSideEffectFromSkillOwner:SideEffectTypeBuffRoidRage];
}

- (void) becomeEnraged
{
  // Show attack label
  CCSprite* increaseSprite = [CCSprite spriteWithImageNamed:@"150percentatk.png"];
  increaseSprite.position = CGPointMake((self.enemySprite.position.x + self.playerSprite.position.x)/2 + self.playerSprite.contentSize.width/2 - 20, (self.playerSprite.position.y + self.enemySprite.position.y)/2 + self.playerSprite.contentSize.height/2);
  increaseSprite.scale = 0.0;
  [self.playerSprite.parent addChild:increaseSprite z:50];
  
  // Run animation
  [increaseSprite runAction:[CCActionSequence actions:
        [CCActionDelay actionWithDuration:0.3],
        [CCActionEaseBounceOut actionWithAction:[CCActionScaleTo actionWithDuration:0.5 scale:1.0]],
        [CCActionDelay actionWithDuration:0.5],
        [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:0.3 scale:0.0]],
        [CCActionRemove action],
        nil]];
  
  // Animations
  [self addEnrageAnimations];
  
  // Finish trigger execution
  [self performAfterDelay:0.3 block:^{
    [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
    [self.battleLayer.orbLayer allowInput];
    [self skillTriggerFinished:YES];
  }];
}
@end
