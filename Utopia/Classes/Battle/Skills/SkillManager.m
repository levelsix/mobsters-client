//
//  SkillManager.m
//  Utopia
//
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillManager.h"
#import "StaticStructure.h"
#import "GameState.h"
#import "NewBattleLayer.h"

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

- (void) updateBattleLayer:(NewBattleLayer*)battleLayer
{
  _battleLayer = battleLayer;
}

- (void) updatePlayer:(BattlePlayer*)player andSprite:(BattleSprite*)playerSprite
{
  _player = player;
  _playerSprite = playerSprite;
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
        [self setDataForController:_playerSkillController];
      }
    }
  }
}

- (void) updateEnemy:(BattlePlayer*)enemy andSprite:(BattleSprite *)enemySprite
{
  _enemy = enemy;
  _enemySprite = enemySprite;
  _enemyColor = OrbColorNone;
  _enemySkillType = SkillTypeJelly;   // MISHA: take it from enemy skill
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
        [self setDataForController:_enemySkillController];
      }
    }
  }
}

- (void) setDataForController:(SkillController*)controller
{
  controller.battleLayer = _battleLayer;
  controller.player = _player;
  controller.playerSprite = _playerSprite;
  controller.enemy = _enemy;
  controller.enemySprite = _enemySprite;
}

#pragma mark - External calls

- (void) orbDestroyed:(OrbColor)color
{
  if (_playerSkillController)
    [_playerSkillController orbDestroyed:color];
  if (_enemySkillController)
    [_enemySkillController orbDestroyed:color];
}

- (void) triggerSkillsWithBlock:(SkillControllerBlock)block andTrigger:(SkillTriggerPoint)trigger
{
#ifndef MOBSTERS
  block(NO);
#endif
  
  // Sequencing player and enemy skills in case both will be triggered by this call
  SkillControllerBlock newBlock = ^(BOOL enemyKilled) {
    BOOL enemySkillTriggered = FALSE;
    if (! enemyKilled)
      if (_enemySkillController)
      {
        [_enemySkillController triggerSkillWithBlock:block andTrigger:trigger];
        enemySkillTriggered = TRUE;
      }
    
    if (!enemySkillTriggered)
      block(enemyKilled);
  };
  
  // Triggering player with complex block or enemy with a simple
  if (_playerSkillController)
    [_playerSkillController triggerSkillWithBlock:newBlock andTrigger:trigger];
  else if (_enemySkillController)
    [_enemySkillController triggerSkillWithBlock:block andTrigger:trigger];
}

@end
