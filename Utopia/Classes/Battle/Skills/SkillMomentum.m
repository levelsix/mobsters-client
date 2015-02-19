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
  _logoShown = NO;
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
  if (player == self.belongsToPlayer)
  {
    return damage * _currentMultiplier;
  }
  
  return damage;
}

- (void) restoreVisualsIfNeeded
{
  [self updateOwnerSprite];
  
  if ([self isActive])
  {
    BattleSprite *bs = self.belongsToPlayer ? self.playerSprite : self.enemySprite;
    [bs addSkillSideEffect:SideEffectTypeBuffMomentum];
  }
}

- (BOOL) onDurationReset
{
  [self increaseMultiplier];
  
  return YES;
}

- (BOOL) onDurationStart
{
  [self increaseMultiplier];
  
  BattleSprite *bs = self.belongsToPlayer ? self.playerSprite : self.enemySprite;
  [bs addSkillSideEffect:SideEffectTypeBuffMomentum];
  
  return [super onDurationStart];
}

- (BOOL) onDurationEnd
{
  _currentMultiplier = 1.0;
  _currentSizeMultiplier = 1.0;
  [self resetSpriteSize];
  
  BattleSprite *bs = self.belongsToPlayer ? self.playerSprite : self.enemySprite;
  [bs removeSkillSideEffect:SideEffectTypeBuffMomentum];
  
  return NO;
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  // Do nothing, only show the splash at the beginning. Flag is for the case when you defeated the previous one, don't show the logo then.
//  if (trigger == SkillTriggerPointEnemyAppeared && ! _logoShown)
//  {
//    if (execute)
//    {
//      _logoShown = YES;
//      [self showSkillPopupOverlay:YES withCompletion:^(){
//        [self skillTriggerFinished];
//      }];
//    }
//    return YES;
//  }
  
  if ((trigger == SkillTriggerPointStartOfPlayerTurn && self.belongsToPlayer) ||
      (trigger == SkillTriggerPointStartOfEnemyTurn && ! self.belongsToPlayer) )
  {
    if ([self isActive])
    {
      [self tickDuration];
    }
  }
  
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
  if (_currentSizeMultiplier == 1.0)
    return;
  BattleSprite* sprite = self.belongsToPlayer ? self.playerSprite : self.enemySprite;
  [sprite runAction:[CCActionSequence actions:
                     [CCActionEaseIn actionWithAction:[CCActionScaleTo actionWithDuration:0.5 scale:_currentSizeMultiplier + 0.1]],
                     [CCActionEaseOut actionWithAction:[CCActionScaleTo actionWithDuration:0.2 scale:_currentSizeMultiplier]],
                     nil]];
}

- (void) increaseMultiplier
{
  // Increase multiplier
  _currentMultiplier *= _damageMultiplier;
  _currentSizeMultiplier *= _sizeMultiplier;
  
  // Size player and make him blue
  [self performSelector:@selector(updateOwnerSprite) withObject:nil afterDelay:0.3];
  
  // Finish trigger execution
  [self performAfterDelay:0.6 block:^{
    [self skillTriggerFinished];
  }];
}

#pragma mark - Serialization

- (NSDictionary*) serialize
{
  NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
  [result setObject:@(_currentMultiplier) forKey:@"currentMultiplier"];
  [result setObject:@(_currentSizeMultiplier) forKey:@"currentSizeMultiplier"];
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (! [super deserialize:dict])
    return NO;
  
  NSNumber* damageMultiplier = [dict objectForKey:@"currentMultiplier"];
  if (damageMultiplier)
    _currentMultiplier = [damageMultiplier floatValue];
  NSNumber* sizeMultiplier = [dict objectForKey:@"currentSizeMultiplier"];
  if (sizeMultiplier)
    _currentSizeMultiplier = [sizeMultiplier floatValue];
  
  return YES;
}

@end
