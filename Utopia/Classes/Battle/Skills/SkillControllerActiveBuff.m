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

- (BOOL)shouldPersist
{
  return [_targets count] > 0;
}

- (id) initWithProto:(SkillProto *)proto andMobsterColor:(OrbColor)color
{
  self = [super initWithProto:proto andMobsterColor:color];
  if (!self)
    return nil;
  
  if (proto.skillEffectDuration)
    _duration = proto.skillEffectDuration;
  
  _targets = [[NSMutableDictionary alloc] init];
  
  return self;
}

- (BOOL) isActive
{
  return self.turnsLeft != 0;
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

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  if ([self isActive])
  {
    //End skills when the user dies
    if ([self expiresOnDeath] && ([self affectsOwner] &&
                                  ((self.belongsToPlayer && trigger == SkillTriggerPointPlayerMobDefeated) ||
                                   (!self.belongsToPlayer && trigger == SkillTriggerPointEnemyDefeated))))
    {
      if (execute)
      {
        if (![self endDurationNow])
          [self skillTriggerFinished];
      }
      return YES;
    }
    
    //End skills on opponents when opponents are defeated
    if ([self expiresOnDeath] && (![self affectsOwner] &&
                                  ((self.belongsToPlayer && trigger == SkillTriggerPointEnemyDefeated) ||
                                   (!self.belongsToPlayer && trigger == SkillTriggerPointPlayerMobDefeated))))
    {
      if (execute)
      {
        if (![self doesRefresh])
          [self resetOrbCounter];
        if (![self endDurationNow])
          [self skillTriggerFinished];
      }
      return YES;
    }
    
    if (self.userPlayer.curHealth > 0 &&
        (([self tickTrigger] == TickTriggerAfterUserTurn &&
        ((self.belongsToPlayer && (trigger == SkillTriggerPointEndOfPlayerTurn || trigger == SkillTriggerPointEnemyDefeated))
         || (!self.belongsToPlayer && (trigger == SkillTriggerPointEndOfEnemyTurn || trigger == SkillTriggerPointPlayerMobDefeated))))
      ||([self tickTrigger] == TickTriggerAfterOpponentTurn &&
        ((!self.belongsToPlayer && (trigger == SkillTriggerPointEndOfPlayerTurn || trigger == SkillTriggerPointEnemyDefeated)) ||
         (self.belongsToPlayer && (trigger == SkillTriggerPointEndOfEnemyTurn || trigger == SkillTriggerPointPlayerMobDefeated))))))
    {
      if (execute)
      {
        BOOL holdSkillTrigger = [self tickDuration];
        if (!holdSkillTrigger)
          [self skillTriggerFinished];
      }
      return YES;
    }
  }
  
  //When mobsters are changed/swapped, check to see if this skill should reapply
  if (([self affectsOwner] == self.belongsToPlayer && trigger == SkillTriggerPointPlayerInitialized)
      || ([self affectsOwner] != self.belongsToPlayer && trigger == SkillTriggerPointEnemyInitialized))
  {
    if (![self doesRefresh])
    {
      if (execute)
      {
        if ([self isActive])
        {
          self.orbCounter = 0;
          [self restoreVisualsIfNeeded];
        }
        else
        {
          if (self.orbCounter == 0)
            self.orbCounter = self.orbRequirement;
        }
        [self skillTriggerFinished];

      }
      return YES;
    }
  }
 
  return NO;
}

#pragma mark - Class Functions

- (TickTrigger) tickTrigger
{
  return TickTriggerAfterUserTurn;
}

- (BOOL) resetDuration
{
  NSInteger tempOldTurns = self.turnsLeft;
  self.turnsLeft = self.duration;
  
  if (tempOldTurns == 0)
    return [self onDurationStart];
  else
    return [self onDurationReset];
}

- (BOOL) tickDuration
{
  if (self.turnsLeft > 0)
    self.turnsLeft--;
  if (self.turnsLeft == 0)
    return [self onDurationEnd];
  return NO;
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
  _stacks = 0;
  [self removeVisualEffects];
  if (![self doesRefresh])
    [self resetOrbCounter];
  return NO;
}

- (BOOL) endDurationNow
{
  if (self.turnsLeft != 0)
  {
    self.turnsLeft = 0;
    return [self onDurationEnd];
  }
  return NO;
}

- (BOOL) affectsOwner
{
  return YES;
}

- (BOOL) expiresOnDeath
{
  return YES;
}

- (void) addVisualEffects:(BOOL)finishSkillTrigger
{
  for (NSNumber *sideEff in [self sideEffects])
  {
    SideEffectType sideType = [sideEff intValue];
    if ([self affectsOwner])
      [self addSkillSideEffectToSkillOwner:sideType turnsAffected:self.turnsLeft turnsAreSkillOwners:[self tickTrigger] == TickTriggerAfterUserTurn];
    else
      [self addSkillSideEffectToOpponent:sideType turnsAffected:self.turnsLeft turnsAreSkillOwners:[self tickTrigger] == TickTriggerAfterUserTurn];
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

- (BOOL)targetsPlayer:(BattlePlayer *)player
{
  return [_targets objectForKey:player.userMonsterUuid] != nil;
}

- (NSString*) currentTargetId
{
  if ([self affectsOwner])
    return self.userPlayer.userMonsterUuid;
  else
    return self.opponentPlayer.userMonsterUuid;
}

- (NSInteger)turnsLeft
{
  if ([_targets objectForKey:[self currentTargetId]])
    return [[_targets objectForKey:[self currentTargetId]] integerValue];
  return 0;
}

- (void) setTurnsLeft:(NSInteger)turnsLeft
{
  if (turnsLeft == 0)
    [_targets removeObjectForKey:[self currentTargetId]];
  else
    [_targets setObject:@(turnsLeft) forKey:[self currentTargetId]];
}

- (void)onCureStatus
{
  [self endDurationNow];
}

- (BOOL)cureStatusWithAntidote:(BattleItemProto*)antidote execute:(BOOL)execute
{
  if ([self isActive] && antidote.battleItemType == [self antidoteType])
  {
    if (execute)
    {
      [self performAfterDelay:.8f block:^{
        [self.opponentSprite playStatusAntidoteEffect];
        [self performAfterDelay:.9f block:^{
          [self onCureStatus];
          [self.battleLayer moveComplete];
        }];
      }];
      [self showAntidotePopupOverlay:antidote bottomText:[self cureBottomText]];
    }
    return YES;
  }
  return NO;
}

#pragma mark - Serialization

- (NSDictionary*) serialize
{
  NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
  
  [result setObject:@([_targets count]) forKey:@"targetNum"];
  int i = 0;
  for (id key in _targets)
  {
    [result setObject:key forKey:[NSString stringWithFormat:@"key%i", i]];
    [result setObject:[_targets objectForKey:key] forKey:[NSString stringWithFormat:@"value%i", i]];
    i++;
  }
  
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (! [super deserialize:dict])
    return NO;

  int numTargets = [[dict objectForKey:@"targetNum"] intValue];
  
  for (int i = 0; i < numTargets; i++) {
    [_targets
     setObject:@([[dict objectForKey:[NSString stringWithFormat:@"value%i", i]] intValue])
     forKey:[dict objectForKey:[NSString stringWithFormat:@"key%i", i]]];
  }
  
  return YES;
}

@end