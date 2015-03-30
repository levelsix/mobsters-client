//
//  SkillFlameBreak.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 2/4/15.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillFlameBreak.h"
#import "NewBattleLayer.h"
#import "Globals.h"

@implementation SkillFlameBreak

#pragma mark - Initialization

- (void) setDefaultValues
{
  [super setDefaultValues];
  
  _maxDamage = 0.f;
  _maxStunTurns = 0;
  _damage = 0;
  _stunTurns = 0;
}

- (void) setValue:(float)value forProperty:(NSString*)property
{
  [super setValue:value forProperty:property];
  
  if ([property isEqualToString:@"RAND_DAMAGE_UPPER_LIMIT"])
    _maxDamage = value;
  if ([property isEqualToString:@"STUN_TURNS_UPPER_LIMIT"])
    _maxStunTurns = value;
}

#pragma mark - Overrides

- (BOOL) affectsOwner
{
  return NO;
}

- (BOOL)keepColor
{
  return NO;
}

- (SpecialOrbSpawnZone)spawnZone
{
  return SpecialOrbSpawnTop;
}

- (int)quickAttackDamage
{
  return _damage;
}

- (NSInteger)duration
{
  return _stunTurns;
}

- (SpecialOrbType)specialType
{
  return SpecialOrbTypeSword;
}

- (TickTrigger)tickTrigger
{
  return TickTriggerAfterOpponentTurn;
}

- (NSSet*) sideEffects
{
  return [NSSet setWithObjects:@(SideEffectTypeNerfStun), nil];
}

- (void)onAllSpecialsDestroyed
{
  [self resetOrbCounter];
  [super onAllSpecialsDestroyed];
}

- (BOOL)activate
{
  if (self.belongsToPlayer)
  {
    [self calculateValues];
    [self dealQuickAttack];
    return YES;
  }
  return [super activate];
}

- (void)showQuickAttackMiniLogo
{
  [self showSkillPopupMiniOverlay:[NSString stringWithFormat:@"%i DMG + %i TURNS / STUNNED", _damage, _stunTurns]];
}

- (BOOL)onSpecialOrbCounterFinish:(NSInteger)numOrbs
{
  [self calculateValues];
  [self dealQuickAttack];
  return YES;
}

- (BOOL) onDurationEnd
{
  self.opponentPlayer.isStunned = NO;
  _orbsSpawned = 0;
  return [super onDurationEnd];
}

#pragma mark - Skill logic

- (void) calculateValues
{
  _damage = arc4random_uniform((int)_maxDamage - 1) +1;
  _stunTurns = _maxStunTurns - (floorf(_maxStunTurns * ((float)_damage / _maxDamage)));
}

- (void)onFinishQuickAttack
{
  [self stunOpponent];
}

//Enemy activations will end the player's turn on their own,
//so only let these functions finish the skill trigger
//if it's the player's skill
- (BOOL) onDurationStart
{
  [self addVisualEffects:self.belongsToPlayer];
  return self.belongsToPlayer;
}

- (void) stunOpponent
{
  SkillLogStart(@"Flame Break -- Skill caused opponent to stun for %ld turns", (long)_turnsLeft);
  
  if (_stunTurns == 0)
  {
    [self skillTriggerFinished:self.belongsToPlayer];
    [self resetOrbCounter];
    _orbsSpawned = 0;
    return;
  }
  
  self.opponentPlayer.isStunned = YES;
  
  if (!self.belongsToPlayer)
  {
    // Being stunned while in the middle of a turn
    // causes the player's turn to end immediately
    [self.battleLayer endMyTurnAfterDelay:.5f];
  }
  
  // Finish trigger execution
  [self performAfterDelay:.3f block:^{
    [self performAfterDelay:self.userSprite.animationType == MonsterProto_AnimationTypeMelee ? .5 : 0 block:^{
      [self resetDuration];
    }];
  }];
}

@end