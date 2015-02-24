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

#pragma mark - Skill logic

- (void) addVisualEffects
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
  
  [self performAfterDelay:0.3 block:^{
    [self skillTriggerFinished:YES];
  }];
}

- (void) removeVisualEffects
{
  BattleSprite* owner = self.belongsToPlayer ? self.playerSprite : self.enemySprite;
  
  // Back to original size and color
  [owner.sprite runAction:[CCActionEaseBounceIn actionWithAction:[CCActionEaseBounceOut actionWithAction:[CCActionScaleTo actionWithDuration:0.5 scale:1.0]]]];
  [owner.sprite stopActionByTag:1914];
  [owner.sprite runAction:[CCActionTintTo actionWithDuration:0.3 color:[CCColor whiteColor]]];
  
  
}
@end
