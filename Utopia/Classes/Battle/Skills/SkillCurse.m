//
//  SkillCurse.m
//  Utopia
//  Description: Casts a status ailment on the enemy for X turns.
//  Enemy skill orb counter does not work while cursed.
//
//  Created by Rob Giusti on 2/4/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillCurse.h"
#import "NewBattleLayer.h"
#import "Globals.h"

@implementation SkillCurse

#pragma mark - Overrides

- (BOOL) affectsOwner
{
  return NO;
}

- (BOOL) shouldPersist
{
  return [self isActive];
}

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeNerfCurse), nil];
}

- (void) restoreVisualsIfNeeded
{
  if ([self isActive])
  {
    self.opponentPlayer.isCursed = YES;
  }
  
  [super restoreVisualsIfNeeded];
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if ([self isActive])
  {
    //Reset on new target
    if (execute)
    {
      if ((self.belongsToPlayer && trigger == SkillTriggerPointEnemyInitialized)
          || (!self.belongsToPlayer && trigger == SkillTriggerPointPlayerInitialized))
      {
        [self endDurationNow];
      }
      else if (trigger == SkillTriggerPointEndOfPlayerTurn)
      {
        [self tickDuration];
      }
    }
  }
  
  return NO;
}

#pragma mark - Skill Logic

- (BOOL) onDurationStart
{
  self.opponentPlayer.isCursed = YES;
  
  return [super onDurationStart];
}

- (BOOL) onDurationEnd
{
  [self removeCurse];
  return [super onDurationEnd];
}

- (void) removeCurse
{
  self.opponentPlayer.isCursed = NO;
}

@end
