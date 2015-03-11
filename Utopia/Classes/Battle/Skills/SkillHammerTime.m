//
//  SkillHammerTime.m
//  Utopia
//  Description: [chance] to stun enemy for [turns].
//
//  Created by Rob Giusti on 1/28/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillHammerTime.h"
#import "NewBattleLayer.h"
#import "Globals.h"

@implementation SkillHammerTime

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  _chance = .25;
  _stunTurns = 1;
  _stunTurnsLeft = 0;
}

- (void) setValue:(float)value forProperty:(NSString *)property
{
  [super setValue:value forProperty:property];
  if ( [property isEqualToString:@"CHANCE"])
    _chance = value;
  else if ( [property isEqualToString:@"STUN_TURNS"])
    _stunTurns = value;
}

#pragma mark - Overrides

- (BOOL) shouldPersist
{
  return _stunTurnsLeft > 0;
}

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeBuffHammerTime), @(SideEffectTypeNerfStun), nil];
}

- (void) restoreVisualsIfNeeded
{
  if (self.opponentPlayer.isStunned)
  {
    [self addStunAnimations];
  }
  [super restoreVisualsIfNeeded];
}

- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute
{
  if ([super skillCalledWithTrigger:trigger execute:execute])
    return YES;
  
  //At the end of the turn, diminish stun stacks
  if ((self.belongsToPlayer && trigger == SkillTriggerPointEndOfEnemyTurn) ||
      (!self.belongsToPlayer && trigger == SkillTriggerPointEndOfPlayerTurn))
  {
    if (_stunTurnsLeft>0)
    {
      _stunTurnsLeft--;
      if (_stunTurnsLeft == 0)
        [self endStun];
    }
  }
  
  //If the character dies before the stun runs up, make sure the stun doesn't persist
  if (_stunTurnsLeft>0 && ((self.belongsToPlayer && trigger == SkillTriggerPointEnemyDefeated)
                           || (!self.belongsToPlayer && trigger == SkillTriggerPointPlayerInitialized)))
  {
    [self endStun];
  }
  
  if ([self isActive])
  {
    //Note: You can refresh a stun!
    if ((self.belongsToPlayer && trigger == SkillTriggerPointPlayerDealsDamage) ||
             (!self.belongsToPlayer && trigger == SkillTriggerPointEnemyDealsDamage))
    {
      if (execute)
      {
        float rand = (float)arc4random_uniform(RAND_MAX) / (float)RAND_MAX;
        if (rand < _chance){
          [self stunOpponent];
        }
      }
      return YES;
    }
  }
  
  return NO;
}

- (void) stunOpponent
{
  self.opponentPlayer.isStunned = YES;
  
  const BOOL alreadyStunned = _stunTurnsLeft > 0;
  _stunTurnsLeft = _stunTurns;
  if (alreadyStunned)
    [self resetAfftectedTurnsCount:_stunTurnsLeft forSkillSideEffectOnOpponent:SideEffectTypeNerfStun];
  else
    [self addStunAnimations];
  
  // Finish trigger execution
  [self performAfterDelay:0.3 block:^{
    [self skillTriggerFinished];
  }];
}

- (void) addStunAnimations
{
  [self addSkillSideEffectToOpponent:SideEffectTypeNerfStun turnsAffected:_stunTurnsLeft];
}

- (void) endStun
{
  self.opponentPlayer.isStunned = NO;
  
  _stunTurnsLeft = 0;
  [self endStunAnimations];
}

- (void) endStunAnimations
{
  [self removeSkillSideEffectFromOpponent:SideEffectTypeNerfStun];
}

#pragma mark - Serialization

- (NSDictionary*) serialize
{
  NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:[super serialize]];
  [result setObject:@(_stunTurnsLeft) forKey:@"stunTurnsLeft"];
  return result;
}

- (BOOL) deserialize:(NSDictionary*)dict
{
  if (! [super deserialize:dict])
    return NO;
  
  NSNumber* stunTurnsLeft = [dict objectForKey:@"stunTurnsLeft"];
  if (stunTurnsLeft)
    _stunTurnsLeft = [stunTurnsLeft intValue];
  
  return YES;
}

@end