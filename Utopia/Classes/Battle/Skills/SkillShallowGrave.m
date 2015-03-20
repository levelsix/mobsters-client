//
//  SkillShallowGrave.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 1/27/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillShallowGrave.h"
#import "NewBattleLayer.h"
#import "Globals.h"

@implementation SkillShallowGrave

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _minHPAllowed = 0;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"MIN_HP_ALLOWED"])
    _minHPAllowed = value;
}

#pragma mark - Overrides

- (TickTrigger)tickTrigger
{
  return TickTriggerAfterOpponentTurn;
}

- (SpecialOrbType) specialType
{
  return SpecialOrbTypeGrave;
}

- (BOOL)keepColor
{
  return NO;
}

- (SpecialOrbSpawnZone)spawnZone
{
  return SpecialOrbSpawnTop;
}

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeBuffShallowGrave), nil];
}

- (void)onAllSpecialsDestroyed
{
  [self endDurationNow];
  [self resetOrbCounter];
}

- (void) restoreVisualsIfNeeded
{
  if ([self isActive])
  {
    SkillLogStart(@"Shallow Grave -- Skill activated");
    
//    [self addDefensiveShieldForUser];
  }
  
  [super restoreVisualsIfNeeded];
}

- (NSInteger) duration
{
  // Defensive variation of Shallow Grave will remain active
  // for as longs there are grave orbs on the board
  return self.belongsToPlayer ? [super duration] : -1;
}

- (BOOL)activate
{
  if (!self.belongsToPlayer)
  {
    [self addVisualEffects:NO];
//    [self addDefensiveShieldForUser];
    self.turnsLeft = -1;
  }
  
  return [super activate];
}

- (NSInteger)modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  if ([self isActive] && self.belongsToPlayer != player)
  {
    if (self.userPlayer.curHealth - damage < _minHPAllowed)
    {
      damage = self.userPlayer.curHealth - _minHPAllowed;
      
      [self showSkillPopupMiniOverlay:@"DEATH AVOIDED"];
    }
  }
  
  return damage;
}

#pragma mark - Skill logic

- (void) addDefensiveShieldForUser
{
  // Do not allow user's health to fall below a certain
  // threshold while active
  self.userPlayer.minHealth = _minHPAllowed;
}

- (void) removeDefensiveShieldFromUser
{
  self.userPlayer.minHealth = 0;
}

- (BOOL) onDurationStart
{
  SkillLogStart(@"Shallow Grave -- Skill activated");
  
  [self addDefensiveShieldForUser];
  
  return [super onDurationStart];
}

- (BOOL) onDurationReset
{
  SkillLogStart(@"Shallow Grave -- Skill activated");
  [self addDefensiveShieldForUser];
  
  return [super onDurationReset];
}

- (BOOL) onDurationEnd
{
  SkillLogStart(@"Shallow Grave -- Skill deactivated");
  
  [self removeDefensiveShieldFromUser];
  
  return [super onDurationEnd];
}

@end
