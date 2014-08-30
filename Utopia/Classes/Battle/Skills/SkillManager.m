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
  _playerSkillType = _enemySkillType = SkillTypeNoSkill;
  
  return self;
}

#pragma mark - Setup

- (void) updatePlayer:(BattlePlayer*)player
{
  _player = player;
  _playerColor = OrbColorNone;
  _playerSkillType = SkillTypeQuickAttack;   // MISHA: take it from player
  _playerSkillController = nil;
  
  GameState* gs = [GameState sharedGameState];
  
  // Player skill
  if ( player )
  {
    if ( _playerSkillType != SkillTypeNoSkill )
    {
      SkillProto* playerSkillProto = [gs.staticSkills objectForKey:[NSNumber numberWithInteger:_playerSkillType]];
      if ( ! playerSkillProto )
      {
        NSLog(@"Skill prototype not found for skill num %d", _playerSkillType);
        return;
      }
      else
      {
        _playerColor = (OrbColor)player.element;
        _playerSkillActivation = playerSkillProto.activationType;
        _playerSkillController = [SkillController skillWithProto:playerSkillProto andMobsterColor:_playerColor];
      }
    }
  }
}

- (void) updateEnemy:(BattlePlayer*)enemy
{
  _enemy = enemy;
  _enemyColor = OrbColorNone;
  _enemySkillType = SkillTypeNoSkill;   // MISHA: take it from enemy skill
  _enemySkillController = nil;
  
  GameState* gs = [GameState sharedGameState];
  
  // Enemy skill
  if ( enemy )
  {
    if ( _enemySkillType != SkillTypeNoSkill )
    {
      SkillProto* enemySkillProto = [gs.staticSkills objectForKey:[NSNumber numberWithInteger:_enemySkillType]];
      if ( ! enemySkillProto )
      {
        NSLog(@"Skill prototype not found for skill num %d", _enemySkillType);
        return;
      }
      else
      {
        _enemyColor = (OrbColor)enemy.element;
        _enemySkillActivation = enemySkillProto.activationType;
        _enemySkillController = [SkillController skillWithProto:enemySkillProto andMobsterColor:_enemyColor];
      }
    }
  }
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

- (BOOL) triggerSkillAfterMoveWithBlock:(SkillControllerBlock)block
{
  if (_playerSkillController)
  {
    if ( _playerSkillController.skillIsReady )
    {
      [_playerSkillController activateSkillWithBlock:block];
      return YES;
    }
  }
  
  block();
  return NO;
}

@end
