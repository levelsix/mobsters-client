//
//  SkillShuffle.m
//  Utopia
//
//  Created by Behrouz N. on 12/11/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillShuffle.h"
#import "NewBattleLayer.h"

@implementation SkillShuffle

#pragma mark - Initialization

-(void)setDefaultValues
{
  [super setDefaultValues];
  
  _logoShown = NO;
}

#pragma mark - Overrides

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
      
      _lastTriggerPoint = trigger;
      _firstEnemyTurn = [self.battleLayer isFirstEnemy];
    }
    return YES;
  }
  
  if (trigger == SkillTriggerPointStartOfPlayerTurn && !self.belongsToPlayer)
  {
    _firstEnemyTurn = NO;
  }
  
  if ((trigger == SkillTriggerPointStartOfPlayerTurn && self.belongsToPlayer) ||
      (trigger == SkillTriggerPointStartOfEnemyTurn && !self.belongsToPlayer))
  {
    if (execute)
    {
      if (!_firstEnemyTurn && // No need to run the skill at the very first turn of the battle
          (self.belongsToPlayer || (!self.belongsToPlayer && // If enemey has multiple consecutive turns, only shuffle on the first turn
                                    _lastTriggerPoint != SkillTriggerPointStartOfEnemyTurn &&
                                    _lastTriggerPoint != SkillTriggerPointEnemyDealsDamage)))
      {
        [self makeSkillOwnerJumpWithTarget:self selector:@selector(shuffleBoard)];
      }
      else
        [self skillTriggerFinished];
      
      _lastTriggerPoint = trigger;
      _firstEnemyTurn = NO;
    }
    return YES;
  }
  
  if (execute)
    _lastTriggerPoint = trigger;
  
  return NO;
}

-(void)shuffleBoard
{
  [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
  [self.battleLayer.orbLayer disallowInput];
  [self.battleLayer.orbLayer shuffleWithCompletion:^{
    [self.battleLayer.orbLayer.bgdLayer turnTheLightsOn];
    [self.battleLayer.orbLayer allowInput];
    [self skillTriggerFinished];
  }];
}

@end
