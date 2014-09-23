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

- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  // If attacker is the skill owner
  if (player == self.belongsToPlayer)
    return damage * _currentMultiplier;
  
  return damage;
}

- (void) restoreVisualsIfNeeded
{
  [self updateOwnerSprite];
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  // Do nothing, only show the splash at the beginning
  if (trigger == SkillTriggerPointEnemyAppeared)
  {
    if (execute)
    {
      [self showSkillPopupOverlay:YES withCompletion:^(){
        [self skillTriggerFinished];
      }];
    }
    return YES;
  }
  
  // Show splash while increasing size 
  if ((trigger == SkillTriggerPointStartOfPlayerTurn && self.belongsToPlayer) ||
      (trigger == SkillTriggerPointStartOfEnemyTurn && ! self.belongsToPlayer) )
  {
    if (execute)
      [self increaseMultiplier];
    return YES;
  }
  
  return NO;
}

#pragma mark - Skill Logic

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
  [self updateOwnerSprite];
  
  // Finish trigger execution
  [self performAfterDelay:0.3 block:^{
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
