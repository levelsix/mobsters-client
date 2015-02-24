//
//  SkillControllerActiveBuff.m
//  Utopia
//
//  Created by Rob Giusti on 2/6/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "NewBattleLayer.h"
#import "SkillControllerActiveBuff.h"

@implementation SkillControllerActiveBuff

#pragma mark - Overrides

- (id) initWithProto:(SkillProto *)proto andMobsterColor:(OrbColor)color
{
  self = [super initWithProto:proto andMobsterColor:color];
  if (!self)
    return nil;
  
  if (proto.skillEffectDuration)
    _duration = proto.skillEffectDuration;
  _turnsLeft = 0;
  
  return self;
  
}

- (BOOL) isActive
{
  return _turnsLeft != 0;
}

- (BOOL) activate
{
  return [self resetDuration];
}

- (void) restoreVisualsIfNeeded
{
  if ([self isActive])
    [self addVisualEffects:NO];
}

#pragma mark - Class Functions

- (NSInteger) getDuration
{
  return _duration;
}

- (BOOL) resetDuration
{
  NSInteger tempOldTurns = _turnsLeft;
  _turnsLeft = [self getDuration];
  
  if (tempOldTurns == 0)
    return [self onDurationStart];
  else
    return [self onDurationReset];
}

- (void) tickDuration
{
  if (_turnsLeft > 0)
    _turnsLeft--;
  if (_turnsLeft == 0)
    [self onDurationEnd];
}

- (BOOL) onDurationStart
{
  [self addVisualEffects:YES];
  return YES;
}

- (BOOL) onDurationReset
{
  [self resetVisualEffects];
  [self skillTriggerFinished:YES];
  return YES;
}

- (BOOL) onDurationEnd
{
  [self removeVisualEffects];
  if (![self doesRefresh])
    [self resetOrbCounter];
  return NO;
}

- (void) endDurationNow
{
  if (_turnsLeft != 0)
  {
    _turnsLeft = 0;
    [self onDurationEnd];
  }
}

- (BOOL) affectsOwner
{
  return YES;
}

- (void) addVisualEffects:(BOOL)finishSkillTrigger
{
  for (NSNumber *sideEff in [self sideEffects])
  {
    SideEffectType sideType = [sideEff intValue];
    if ([self affectsOwner])
      [self addSkillSideEffectToSkillOwner:sideType turnsAffected:self.turnsLeft];
    else
      [self addSkillSideEffectToOpponent:sideType turnsAffected:self.turnsLeft];
  }
  
  if (finishSkillTrigger)
    [self skillTriggerFinished:YES];
}

- (void) resetVisualEffects
{
  for (NSNumber *sideEff in [self sideEffects])
  {
    SideEffectType sideType = [sideEff intValue];
    if ([self affectsOwner])
      [self resetAfftectedTurnsCount:self.turnsLeft forSkillSideEffectOnSkillOwner:sideType];
    else
      [self resetAfftectedTurnsCount:self.turnsLeft forSkillSideEffectOnOpponent:sideType];
  }
}

- (void) removeVisualEffects
{
  for (NSNumber *sideEff in [self sideEffects])
  {
    SideEffectType sideType = [sideEff intValue];
    if ([self affectsOwner])
      [self removeSkillSideEffectFromSkillOwner:sideType];
    else
      [self removeSkillSideEffectFromOpponent:sideType];
  }
}

#pragma mark - Serialization

- (NSDictionary*) serialize
{
  NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
  [result setObject:@(_turnsLeft) forKey:@"turnsLeft"];
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (! [super deserialize:dict])
    return NO;
  
  NSNumber* turnsLeft = [dict objectForKey:@"turnsLeft"];
  if (turnsLeft)
    _turnsLeft = [turnsLeft integerValue];
  
  return YES;
}

@end