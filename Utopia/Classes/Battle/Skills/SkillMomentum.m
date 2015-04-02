//
//  SkillMomentum.m
//  Utopia
//
//  Created by Mikhail Larionov on 9/22/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillMomentum.h"
#import "NewBattleLayer.h"

@implementation SkillMomentum

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  _damageMultiplier = 1.1;
  _sizeMultiplier = 1.1;
  _currentMultiplier = 1.0;
  _currentSizeMultiplier = 1.0;
  _sizeCap = 2.0;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"DAMAGE_MULTIPLIER"] )
    _damageMultiplier = value;
  if ( [property isEqualToString:@"SIZE_MULTIPLIER"] )
    _sizeMultiplier = value;
  if ( [property isEqualToString:@"SIZE_CAP"])
    _sizeCap = value;
  
}

#pragma mark - Overrides

- (BOOL)doesStack
{
  return YES;
}

- (BOOL) doesRefresh
{
  return YES;
}

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeBuffMomentum), nil];
}

- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  // If attacker is the skill owner
  if ([self isActive] && player == self.belongsToPlayer)
  {
    [self enqueueSkillPopupMiniOverlay:[NSString stringWithFormat:@"%.3gX DMG", (_damageMultiplier * _stacks)]];
    return (damage * _damageMultiplier * _stacks);
  }
  
  return damage;
}

- (void) restoreVisualsIfNeeded
{
  [self updateOwnerSprite];
  [super restoreVisualsIfNeeded];
}

- (BOOL) onDurationStart
{
  [self increaseMultiplier];
  [self addVisualEffects:NO];
  return YES;
}

- (BOOL) onDurationReset
{
  [self increaseMultiplier];
  [self resetVisualEffects];
  return YES;
}

- (BOOL) onDurationEnd
{
  _stacks = 0;
  [self resetSpriteSize];
  [self removeVisualEffects];
  return NO;
}

#pragma mark - Skill Logic

- (void) resetSpriteSize
{
  BattleSprite* owner = self.belongsToPlayer ? self.playerSprite : self.enemySprite;
  [owner runAction:[CCActionEaseBounceIn actionWithAction:
                           [CCActionEaseBounceOut actionWithAction:[CCActionScaleTo actionWithDuration:0.5 scale:1.0]]]];
}

- (void) updateOwnerSprite
{
  _currentSizeMultiplier = MIN(1 + _sizeMultiplier * _stacks, _sizeCap);
  if (_currentSizeMultiplier == 1.0)
    return;
  BattleSprite* owner = self.belongsToPlayer ? self.playerSprite : self.enemySprite;
  [owner runAction:[CCActionSequence actions:
                           [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:0.5 scale:_currentSizeMultiplier + 0.1]],
                           [CCActionEaseOut actionWithAction:[CCActionScaleTo actionWithDuration:0.2 scale:_currentSizeMultiplier]],
                           nil]];
}

- (void) increaseMultiplier
{
  // Size player and make him blue
  [self performSelector:@selector(updateOwnerSprite) withObject:nil afterDelay:0.3];
  
  // Finish trigger execution
  [self performAfterDelay:0.6 block:^{
    [self skillTriggerFinished:YES];
  }];
}

@end
