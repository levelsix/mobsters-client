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
#import "SkillCakeDrop.h"

@implementation SkillManager

SYNTHESIZE_SINGLETON_FOR_CLASS(SkillManager);

- (id) init
{
  self = [super init];
  if ( ! self )
    return nil;
  
  _playerColor = _enemyColor = OrbColorNone;
  _playerSkillType = _enemySkillType = SkillTypeNoSkill;
  _cheatPlayerSkillType = _cheatEnemySkillType = SkillTypeNoSkill;
  
  return self;
}

#pragma mark - Setup

- (void) updatePlayerSkill
{
  // Major properties
  _player = _battleLayer.myPlayerObject;
  _playerColor = OrbColorNone;
  _playerSkillType = SkillTypeNoSkill;
  _playerSkillController = nil;
  
  if (! _player)
    return;
  
  // Skill data
  NSInteger skillId = _player.offensiveSkillId;
  //_cheatPlayerSkillType = SkillTypeQuickAttack;
  if (_cheatPlayerSkillType != SkillTypeNoSkill)
    skillId = [self skillIdForSkillType:_cheatPlayerSkillType];
  
  // Player skill
  if (skillId > 0)
  {
    GameState* gs = [GameState sharedGameState];
    SkillProto* playerSkillProto = [gs.staticSkills objectForKey:[NSNumber numberWithInteger:skillId]];
    if (! playerSkillProto)
    {
      NSLog(@"Skill prototype not found for skill num %d", _playerSkillType);
      return;
    }
    else
    {
      _playerSkillType = playerSkillProto.type;
      _playerColor = (OrbColor)_player.element;
      _playerSkillActivation = playerSkillProto.activationType;
      _playerSkillController = [SkillController skillWithProto:playerSkillProto andMobsterColor:_playerColor];
    }
  }
  
  // Deserialize if needed
  if (_playerSkillController && _playerSkillSerializedState)
  {
    [_playerSkillController deserialize:_playerSkillSerializedState];
    _playerSkillSerializedState = nil;
  }
}

- (void) updateEnemySkill
{
  // Reset turn counter when new enemy appears
  if (! _enemySkillSerializedState)
    _turnsCounter = 0;
  
  // Major properties
  _enemy = _battleLayer.enemyPlayerObject;
  _enemyColor = OrbColorNone;
  _enemySkillType = SkillTypeNoSkill;
  _enemySkillController = nil;
  
  if (!_enemy)
    return;
  
  // Skill data
  NSInteger skillId = _enemy.defensiveSkillId;
  //_cheatEnemySkillType = SkillTypeJelly; // Change it to override current skill
  if (_cheatEnemySkillType != SkillTypeNoSkill)
    skillId = [self skillIdForSkillType:_cheatEnemySkillType];
  
  // Enemy skill
  if (skillId > 0)
  {
    GameState* gs = [GameState sharedGameState];
    SkillProto* enemySkillProto = [gs.staticSkills objectForKey:[NSNumber numberWithInteger:skillId]];
    if ( ! enemySkillProto )
    {
      NSLog(@"Skill prototype not found for skill num %d", _enemySkillType);
      return;
    }
    else
    {
      _enemySkillType = enemySkillProto.type;
      _enemyColor = (OrbColor)_enemy.element;
      _enemySkillActivation = enemySkillProto.activationType;
      _enemySkillController = [SkillController skillWithProto:enemySkillProto andMobsterColor:_enemyColor];
    }
  }
  
  // Deserialize if needed
  if (_enemySkillController && _enemySkillSerializedState)
  {
    [_enemySkillController deserialize:_enemySkillSerializedState];
    _enemySkillSerializedState = nil;
  }
}

- (void) updateReferences
{
  _enemySprite = _battleLayer.currentEnemy;
  _playerSprite = _battleLayer.myPlayer;
  
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
  _playerSkillController = nil;
  _enemySkillController = nil;
  _skillIndicatorEnemy = _skillIndicatorPlayer = nil;
}

- (void) orbDestroyed:(OrbColor)color special:(SpecialOrbType)type
{
  if (_playerSkillController)
    [_playerSkillController orbDestroyed:color special:type];
  if (_enemySkillController)
    [_enemySkillController orbDestroyed:color special:type];
  if (_skillIndicatorPlayer)
    [_skillIndicatorPlayer update];
  if (_skillIndicatorEnemy)
    [_skillIndicatorEnemy update];
}

- (SpecialOrbType) generateSpecialOrb
{
  SpecialOrbType color = SpecialOrbTypeNone;
  
  if (_playerSkillController)
    color = [_playerSkillController generateSpecialOrb];
  
  if (color == SpecialOrbTypeNone)
    if (_enemySkillController)
      color = [_enemySkillController generateSpecialOrb];
  
  return color;
}

- (void) triggerSkills:(SkillTriggerPoint)trigger withCompletion:(SkillControllerBlock)completion
{
  //block(); // Uncomment these lines to totally disable skills.
  //return;
  
  // Used to skip first attack (initial actions for deserizalized copies are skipped within SkillController itself)
  BOOL shouldTriggerEnemySkill = YES;
  
  // Update enemy, part 1
  if (trigger == SkillTriggerPointEnemyInitialized)
  {
    [self updateEnemySkill];
    [self updateReferences];
  }
  
  // Update enemy, part 2
  if (trigger == SkillTriggerPointEnemyAppeared)
  {
    [self createEnemySkillIndicator];
    [self updateReferences];
  }
  
  // Update player
  if (trigger == SkillTriggerPointPlayerInitialized)
  {
    [self updatePlayerSkill];
    [self updateReferences];
    [self createPlayerSkillIndicator];
  }
  
  // Remove enemy indicator if enemy was defeated
  //if (trigger == SkillTriggerPointEnemyDefeated)
  //  [self removeEnemySkillIndicator];
  
  // Skip first skill attack for an enemy
  if (trigger == SkillTriggerPointStartOfEnemyTurn && _turnsCounter == 0)
    shouldTriggerEnemySkill = NO;
  if (trigger == SkillTriggerPointEnemyAppeared && _turnsCounter != 0)
    shouldTriggerEnemySkill = NO;
  
  // Wrapping indicators update into the block
  SkillControllerBlock newBlock = ^(BOOL triggered) {
    
    // Update indicators
    if (_skillIndicatorPlayer)
      [_skillIndicatorPlayer update];
    if (_skillIndicatorEnemy)
      [_skillIndicatorEnemy update];
    
    // Execute the completion block
    completion(triggered);
    
    // Count turns
    if (trigger == SkillTriggerPointStartOfEnemyTurn || trigger == SkillTriggerPointStartOfPlayerTurn)
      _turnsCounter++;
  };
  
  // Sequencing player and enemy skills in case both will be triggered by this call
  SkillControllerBlock sequenceBlock = ^(BOOL triggered) {
    BOOL enemySkillTriggered = FALSE;
    if (_enemy.curHealth > 0 || trigger == SkillTriggerPointEnemyDefeated)  // Alive or cleanup trigger
      if (_enemySkillController && shouldTriggerEnemySkill)
      {
        [_enemySkillController triggerSkill:trigger withCompletion:newBlock];
        enemySkillTriggered = TRUE;
      }
    
    if (!enemySkillTriggered)
      newBlock(triggered);
  };
  
  // Triggering the player's skill with a complex block or (if no player skill) the enemy's with a simple
  
  if (_playerSkillController)
    [_playerSkillController triggerSkill:trigger withCompletion:sequenceBlock];
  else if (_enemySkillController && shouldTriggerEnemySkill)
    [_enemySkillController triggerSkill:trigger withCompletion:newBlock];
  else
    newBlock(NO);
}

- (BOOL) cakeKidSchedule
{
  return (_enemySkillController && [_enemySkillController isKindOfClass:[SkillCakeDrop class]]);
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
      _skillIndicatorEnemy.position = CGPointMake(_skillIndicatorEnemy.contentSize.width/2, 150 + (UI_DEVICE_IS_IPHONE_4 ? -74 : 0));
      [_skillIndicatorEnemy update];
      [_battleLayer.orbLayer addChild:_skillIndicatorEnemy z:-10];
      [_skillIndicatorEnemy appear:existedBefore];
    }
  }
}

/*- (void) removeEnemySkillIndicator
{
  if (_skillIndicatorEnemy)
    [_skillIndicatorEnemy disappear];
}*/

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

#pragma mark - Serialization

- (NSDictionary*) serialize
{
  NSMutableDictionary* result = [NSMutableDictionary dictionary];
  if (_playerSkillController)
      [result setObject:[_playerSkillController serialize] forKey:@"playerSkill"];
  if (_enemySkillController)
    [result setObject:[_enemySkillController serialize] forKey:@"enemySkill"];
  [result setObject:@(_turnsCounter) forKey:@"turnsCounter"];
  return result;
}

- (void) deserialize:(NSDictionary*)dict
{
  if (! dict)
    return;
  
  _playerSkillSerializedState = [dict objectForKey:@"playerSkill"];
  _enemySkillSerializedState = [dict objectForKey:@"enemySkill"];
  NSNumber* turnsCounter = [dict objectForKey:@"turnsCounter"];
  if (turnsCounter)
    _turnsCounter = [turnsCounter integerValue];
}

#pragma mark - Misc

// Returns first skill found with that skill type
- (NSInteger) skillIdForSkillType:(SkillType)type
{
  GameState* gs = [GameState sharedGameState];
  for (SkillProto* skill in gs.staticSkills.allValues)
    if (skill.type == type)
      return skill.skillId;
  return 0;
}

- (BOOL) shouldSpawnRibbonForPlayerSkill:(OrbColor)color
{
  if (_playerSkillController)
    if (_skillIndicatorPlayer)
      if (_playerSkillController.activationType != SkillActivationTypePassive)
        if (_playerSkillController.orbColor == color)
          return YES;
  return NO;
}

- (BOOL) shouldSpawnRibbonForEnemySkill:(OrbColor)color
{
  if (_enemySkillController)
    if (_skillIndicatorEnemy)
      if (_enemySkillController.activationType != SkillActivationTypePassive)
        if (_enemySkillController.orbColor == color)
          return YES;
  return NO;
}

- (CGPoint) playerSkillPosition
{
  return ccpAdd(_skillIndicatorPlayer.position, ccp(0, _skillIndicatorPlayer.contentSize.height/2));
}

- (CGPoint) enemySkillPosition
{
  return ccpAdd(_skillIndicatorEnemy.position, ccp(0, _skillIndicatorEnemy.contentSize.height/2));
}

- (BOOL) willEnemySkillTrigger:(SkillTriggerPoint)trigger
{
  if (_enemySkillController)
    return [_enemySkillController skillCalledWithTrigger:trigger execute:NO];
  return NO;
}

- (BOOL) willPlayerSkillTrigger:(SkillTriggerPoint)trigger
{
  if (_playerSkillController)
    return [_playerSkillController skillCalledWithTrigger:trigger execute:NO];
  return NO;
}

@end
