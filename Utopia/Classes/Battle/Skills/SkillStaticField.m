//
//  SkillStaticField.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/26/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillStaticField.h"
#import "NewBattleLayer.h"
#import "Globals.h"

@implementation SkillStaticField

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _targetHPPercToDealAsDamage = 0.f;
  _logoShown = NO;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"TARGET_HP_PERC_AS_DAMAGE"])
    _targetHPPercToDealAsDamage = value;
}

#pragma mark - Overrides

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeBuffStaticField), nil];
}

- (void) restoreVisualsIfNeeded
{
  if ([self isActive])
  {
    [self addSkillSideEffectToSkillOwner:SideEffectTypeBuffStaticField turnsAffected:self.turnsLeft];
  }
}

- (int) quickAttackDamage
{
  return floorf((float)self.opponentPlayer.curHealth * _targetHPPercToDealAsDamage);
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if ([self isActive])
  {
    if (trigger == SkillTriggerPointStartOfPlayerTurn)
    {
      [self tickDuration];
    }
    
    if (self.userPlayer.curHealth > 0 &&
        ((trigger == SkillTriggerPointEnemySkillActivated && self.belongsToPlayer)
        || (trigger == SkillTriggerPointPlayerSkillActivated && !self.belongsToPlayer)))
    {
      if (execute)
      {
        SkillLogStart(@"Static Field -- Skill activated");
        
        [self.battleLayer.orbLayer.bgdLayer turnTheLightsOff];
        [self.battleLayer.orbLayer disallowInput];
        
        [self dealQuickAttack];
      }
      return YES;
    }
    
  }
  
  return NO;
}

- (BOOL) onDurationStart
{
  [self addSkillSideEffectToSkillOwner:SideEffectTypeBuffStaticField turnsAffected:self.turnsLeft];
  
  return NO;
}

- (BOOL) onDurationReset
{
  [self resetAfftectedTurnsCount:self.turnsLeft forSkillSideEffectOnSkillOwner:SideEffectTypeBuffStaticField];
  
  return [super onDurationStart];
}

- (BOOL) onDurationEnd
{
  [self removeSkillSideEffectFromSkillOwner:SideEffectTypeBuffStaticField];
  
  return [super onDurationEnd];
}

@end
