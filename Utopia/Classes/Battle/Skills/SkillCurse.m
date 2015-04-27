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
#import "MainBattleLayer.h"
#import "Globals.h"
#import "SkillManager.h"

@implementation SkillCurse

#pragma mark - Overrides

//Little trick to make it always tick after player turns
- (TickTrigger)tickTrigger
{
  return self.belongsToPlayer ? TickTriggerAfterUserTurn : TickTriggerAfterOpponentTurn;
}

- (BOOL) affectsOwner
{
  return NO;
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
    [(self.belongsToPlayer ? skillManager.enemySkillIndicatorView : skillManager.playerSkillIndicatorView) setCurse:YES];
  }
  
  [super restoreVisualsIfNeeded];
}

#pragma mark - Skill Logic

- (BOOL) onDurationStart
{
  self.opponentPlayer.isCursed = YES;
  
  [(self.belongsToPlayer ? skillManager.enemySkillIndicatorView : skillManager.playerSkillIndicatorView) setCurse:YES];
  
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
  [(self.belongsToPlayer ? skillManager.enemySkillIndicatorView : skillManager.playerSkillIndicatorView) setCurse:NO];
}

@end
