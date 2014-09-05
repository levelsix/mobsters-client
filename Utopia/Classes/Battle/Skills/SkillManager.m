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

- (void) updatePlayer
{
  _player = _battleLayer.myPlayerObject;
  _playerSprite = _battleLayer.myPlayer;
  _playerColor = OrbColorNone;
  _playerSkillType = SkillTypeNoSkill;//SkillTypeQuickAttack;   // MISHA: take it from player
  _playerSkillController = nil;
  
  GameState* gs = [GameState sharedGameState];
  
  // Player skill
  if ( _player )
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
        _playerColor = (OrbColor)_player.element;
        _playerSkillActivation = playerSkillProto.activationType;
        _playerSkillController = [SkillController skillWithProto:playerSkillProto andMobsterColor:_playerColor];
      }
    }
  }
  
  if (_enemySkillController)
    [self setDataForController:_enemySkillController];
  if (_playerSkillController)
    [self setDataForController:_playerSkillController];
}

- (void) updateEnemy
{
  _enemy = _battleLayer.enemyPlayerObject;
  _enemySprite = _battleLayer.currentEnemy;
  _enemyColor = OrbColorNone;
  _enemySkillType = SkillTypeNoSkill;//SkillTypeJelly;   // MISHA: take it from enemy skill
  _enemySkillController = nil;
  
  GameState* gs = [GameState sharedGameState];
  
  // Enemy skill
  if ( _enemy )
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
        _enemyColor = (OrbColor)_enemy.element;
        _enemySkillActivation = enemySkillProto.activationType;
        _enemySkillController = [SkillController skillWithProto:enemySkillProto andMobsterColor:_enemyColor];
      }
    }
  }
  
  if (_enemySkillController)
    [self setDataForController:_enemySkillController];
  if (_playerSkillController)
    [self setDataForController:_playerSkillController];
}

- (void) setDataForController:(SkillController*)controller
{
  controller.battleLayer = _battleLayer;
  controller.player = _player;
  controller.playerSprite = _playerSprite;
  controller.enemy = _enemy;
  controller.enemySprite = _enemySprite;
  controller.belongsToPlayer = (controller == _playerSkillController);
}

#pragma mark - External calls

- (void) updateBattleLayer:(NewBattleLayer*)battleLayer
{
  _battleLayer = battleLayer;
}

- (void) orbDestroyed:(OrbColor)color
{
#ifndef MOBSTERS
  return;
#endif

  if (_playerSkillController)
    [_playerSkillController orbDestroyed:color];
  if (_enemySkillController)
    [_enemySkillController orbDestroyed:color];
  if (_skillIndicatorPlayer)
    [_skillIndicatorPlayer update];
  if (_skillIndicatorEnemy)
    [_skillIndicatorEnemy update];
}

- (void) triggerSkillsWithBlock:(SkillControllerBlock)block andTrigger:(SkillTriggerPoint)trigger
{
#ifndef MOBSTERS
  block(NO);
#endif
  
  // Update enemy skill indicator
  if (trigger == SkillTriggerPointEnemyAppeared)
  {
    [skillManager updateEnemy];
    [self createEnemySkillIndicator];
  }
  if (trigger == SkillTriggerPointEnemyDefeated)
    [self removeEnemySkillIndicator];
  
  // Update player skill indicator
  if (trigger == SkillTriggerPointPlayerAppeared)
  {
    [self updatePlayer];
    [self createPlayerSkillIndicator];
  }
  
  // Wrapping indicators update into the block
  SkillControllerBlock newBlock = ^() {
    if (_skillIndicatorPlayer)
      [_skillIndicatorPlayer update];
    if (_skillIndicatorEnemy)
      [_skillIndicatorEnemy update];
    block();
  };
  
  // Sequencing player and enemy skills in case both will be triggered by this call
  SkillControllerBlock sequenceBlock = ^() {
    BOOL enemySkillTriggered = FALSE;
    if (_enemy.curHealth > 0)
      if (_enemySkillController)
      {
        [_enemySkillController triggerSkillWithBlock:newBlock andTrigger:trigger];
        enemySkillTriggered = TRUE;
      }
    
    if (!enemySkillTriggered)
      block();
  };
  
  // Triggering the player's skill with a complex block or (if no player skill) the enemy's with a simple
  if (_playerSkillController)
    [_playerSkillController triggerSkillWithBlock:sequenceBlock andTrigger:trigger];
  else if (_enemySkillController)
    [_enemySkillController triggerSkillWithBlock:newBlock andTrigger:trigger];
  else
    block();
}

#pragma mark - UI

- (void) createEnemySkillIndicator
{
  if (_enemySkillType != SkillTypeNoSkill)
  {
    BOOL existedBefore = (_skillIndicatorEnemy != nil && _skillIndicatorEnemy.parent);
    if ( existedBefore )
      [_skillIndicatorEnemy removeFromParent];
    _skillIndicatorEnemy = [[SkillBattleIndicatorView alloc] initWithSkillController:_enemySkillController enemy:YES];
    if (_skillIndicatorEnemy)
    {
      _skillIndicatorEnemy.position = CGPointMake(_skillIndicatorEnemy.contentSize.width/2, 150 + (UI_DEVICE_IS_IPHONE_4 ? 45 : 0));
      [_skillIndicatorEnemy update];
      [_battleLayer.orbLayer addChild:_skillIndicatorEnemy z:-10];
      [_skillIndicatorEnemy appear:existedBefore];
    }
  }
}

- (void) removeEnemySkillIndicator
{
  if (_skillIndicatorEnemy)
    [_skillIndicatorEnemy disappear];
}

- (void) createPlayerSkillIndicator
{
  if (_skillIndicatorPlayer)
    [_skillIndicatorPlayer removeFromParentAndCleanup:YES];

  if (_playerSkillType != SkillTypeNoSkill)
  {
    _skillIndicatorPlayer = [[SkillBattleIndicatorView alloc] initWithSkillController:_playerSkillController enemy:NO];
    if (_skillIndicatorPlayer)
    {
      _skillIndicatorPlayer.position = CGPointMake(-_skillIndicatorPlayer.contentSize.width/2, 38);
      [_skillIndicatorPlayer update];
      [_battleLayer.orbLayer addChild:_skillIndicatorPlayer z:-10];
    }
  }
}

@end
