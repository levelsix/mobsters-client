//
//  SkillManager.m
//  Utopia
//
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillManager.h"
#import "StaticStructure.h"
#import "GameState.h"

@implementation SkillManager

SYNTHESIZE_SINGLETON_FOR_CLASS(SkillManager);

- (id) init
{
  self = [super init];
  if ( ! self )
    return nil;
  
  _playerColor = _enemyColor = OrbColorNone;
  _playerSkill = _enemySkill = SkillTypeNoSkill;
  
  return self;
}

#pragma mark - Setup

- (void) updatePlayer:(BattlePlayer*)player
{
  _player = player;
  _playerColor = OrbColorNone;
  _playerSkill = SkillTypeQuickAttack;   // MISHA: take it from player
  
  GameState* gs = [GameState sharedGameState];
  
  // Player skill
  if ( player )
  {
    if ( _playerSkill != SkillTypeNoSkill )
    {
      SkillProto* playerSkillProto = [gs.staticSkills objectForKey:[NSNumber numberWithInteger:_playerSkill]];
      _playerColor = (OrbColor)player.element;
      _playerSkillActivation = playerSkillProto.activationType;
      _playerSkillController = [SkillController skillWithProto:playerSkillProto andMobsterColor:_playerColor];
    }
  }
  else
    _playerSkillController = nil;
}

- (void) updateEnemy:(BattlePlayer*)enemy
{
  _enemy = enemy;
  _enemyColor = OrbColorNone;
  _enemySkill = SkillTypeNoSkill;   // MISHA: take it from enemy skill
  
  GameState* gs = [GameState sharedGameState];
  
  // Enemy skill
  if ( enemy )
  {
    if ( _enemySkill != SkillTypeNoSkill )
    {
      SkillProto* enemySkillProto = [gs.staticSkills objectForKey:[NSNumber numberWithInteger:_enemySkill]];
      _enemyColor = (OrbColor)enemy.element;
      _enemySkillActivation = enemySkillProto.activationType;
      _enemySkillController = [SkillController skillWithProto:enemySkillProto andMobsterColor:_enemyColor];
    }
  }
  else
    _enemySkillController = nil;
}

#pragma mark - External calls

- (void) orbDestroyed:(OrbColor)color
{
  if (_playerSkillController)
    [_playerSkillController orbDestroyed:color];
  if (_enemySkillController)
    [_enemySkillController orbDestroyed:color];
}

#pragma mark - Checks

- (BOOL) triggerSkillAfterTurn
{
  if (_playerSkillController)
  {
    if ( _playerSkillController.skillIsReady )
    {
      // MISHA: TRIGGER
      return YES;
    }
  }
  
  return NO;
}

@end
