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
    if ([self isActive] && !self.userPlayer.isStunned)
    {
      [self enqueueSkillPopupMiniOverlay:[NSString stringWithFormat:@"%.3gX DMG", _damageMultiplier]];
      return damage * _damageMultiplier;
    }
  
  return damage;
}

#pragma mark - Skill logic

- (void) addVisualEffects:(BOOL)skillTriggerFinished
{
  // Size player and make him blue
  [self.userSprite runAction:[CCActionEaseBounceIn actionWithAction:[CCActionScaleTo actionWithDuration:0.3 scale:1.25]]];
  
  [self.userSprite.sprite stopActionByTag:1914];
  CCActionRepeatForever* action = [CCActionRepeatForever actionWithAction:[CCActionSequence actions:
                                                                           [CCActionTintTo actionWithDuration:0.5 color:[CCColor cyanColor]],
                                                                           [CCActionTintTo actionWithDuration:0.5 color:[CCColor whiteColor]],
                                                                           nil]];
  action.tag = 1914;
  [self.userSprite.sprite runAction:action];
  
  [super addVisualEffects:NO];
  
  if (skillTriggerFinished)
    [self performBlockAfterDelay:0.3 block:^{
      [self skillTriggerFinished:YES];
    }];
}

- (void) removeVisualEffects
{
  // Back to original size and color
  [self.userSprite runAction:[CCActionEaseBounceIn actionWithAction:[CCActionEaseBounceOut actionWithAction:[CCActionScaleTo actionWithDuration:0.5 scale:1.0]]]];
  
  [self.userSprite.sprite stopActionByTag:1914];
  [self.userSprite.sprite runAction:[CCActionTintTo actionWithDuration:0.3 color:[CCColor whiteColor]]];
  
  [super removeVisualEffects];
}
@end
