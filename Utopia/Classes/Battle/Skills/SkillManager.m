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
#import "SkillBombs.h"

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
  _cheatEnemySkillId = _cheatPlayerSkillId = -1;
  
#ifdef DEBUG
  // Change it to override current skills for debug purposes
  //_cheatEnemySkillType = SkillTypeQuickAttack;
  //_cheatPlayerSkillType = SkillTypeQuickAttack;
#endif
  
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
  if (_cheatPlayerSkillType != SkillTypeNoSkill)
    skillId = [self skillIdForSkillType:_cheatPlayerSkillType];
  if (_cheatPlayerSkillId >= 0)
    skillId = _cheatPlayerSkillId;
  
  // Player skill
  if (skillId > 0)
  {
    GameState* gs = [GameState sharedGameState];
    SkillProto* playerSkillProto = [gs.staticSkills objectForKey:[NSNumber numberWithInteger:skillId]];
    if (! playerSkillProto)
    {
      NSLog(@"Skill prototype not found for skill num %d", (int)_playerSkillType);
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
  if (_cheatEnemySkillType != SkillTypeNoSkill)
    skillId = [self skillIdForSkillType:_cheatEnemySkillType];
  if (_cheatEnemySkillId >= 0)
    skillId = _cheatEnemySkillId;
  
  // Enemy skill
  if (skillId > 0)
  {
    GameState* gs = [GameState sharedGameState];
    SkillProto* enemySkillProto = [gs.staticSkills objectForKey:[NSNumber numberWithInteger:skillId]];
    if ( ! enemySkillProto )
    {
      NSLog(@"Skill prototype not found for skill num %d", (int)_enemySkillType);
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

- (BOOL) generateSpecialOrb:(BattleOrb*)orb atColumn:(int)column row:(int)row
{
  BOOL generated = NO;
  
  if (_playerSkillController)
    generated = [_playerSkillController generateSpecialOrb:orb atColumn:column row:row];
  
  if (! generated)
    if (_enemySkillController)
      generated = [_enemySkillController generateSpecialOrb:orb atColumn:column row:row];
  
  return generated;
}

- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  NSInteger result = damage;
  
  if (_playerSkillController)
    result = [_playerSkillController modifyDamage:result forPlayer:player];
  
  if (_enemySkillController)
    result = [_enemySkillController modifyDamage:result forPlayer:player];
  
  return result;
}

- (void) triggerSkills:(SkillTriggerPoint)trigger withCompletion:(SkillControllerBlock)completion
{
  //completion(NO); // Uncomment these lines to totally disable skills.
  //return;
  
  // Wrapping indicators update into the block
  SkillControllerBlock newBlock = ^(BOOL triggered, id params) {
    
    // Update indicators
    if (_skillIndicatorPlayer)
      [_skillIndicatorPlayer update];
    if (_skillIndicatorEnemy)
      [_skillIndicatorEnemy update];
    
    // Execute the completion block
    completion(triggered, params);
    
    // Count turns
    if (trigger == SkillTriggerPointStartOfEnemyTurn || trigger == SkillTriggerPointStartOfPlayerTurn)
      _turnsCounter++;
  };
  
  // Update specials if needed and only then trigger skill
  if (trigger == SkillTriggerPointEndOfPlayerMove)
  {
    [self updateSpecialsWithCompletion:^(BOOL triggered, id params) {
      [self triggerSkillsInternal:trigger withCompletion:newBlock];
    }];
  }
  else
    [self triggerSkillsInternal:trigger withCompletion:newBlock];
}

- (void) triggerSkillsInternal:(SkillTriggerPoint)trigger withCompletion:(SkillControllerBlock)completion
{
  // Used to skip first attack (initial actions for deserizalized copies are skipped within SkillController itself)
  BOOL shouldTriggerEnemySkill = YES;
  BOOL shouldTriggerPlayerSkill = YES;
  
  // Initialize player skill, update indicator and restore skill visuals
  if (trigger == SkillTriggerPointPlayerInitialized)
  {
    [self updatePlayerSkill];
    [self updateReferences];
    [self createPlayerSkillIndicator];
    [_playerSkillController restoreVisualsIfNeeded];
  }
  
  // Initialize enemy skill
  if (trigger == SkillTriggerPointEnemyInitialized)
  {
    [self updateEnemySkill];
    [self updateReferences];
  }
  
  // Update enemy skill indicator and restore skill visuals
  if (trigger == SkillTriggerPointEnemyAppeared)// && _turnsCounter == 0)
  {
    [self createEnemySkillIndicator];
    [self updateReferences];  // To update reference to enemy sprite which is not initialized when it's called for the first time few lines above
    [_enemySkillController restoreVisualsIfNeeded];
  }
  
  // Skip first skill attack for both player and enemy if it's right after enemy appearance
  if (trigger == SkillTriggerPointStartOfEnemyTurn && _turnsCounter == 0)
    shouldTriggerEnemySkill = NO;
  if (trigger == SkillTriggerPointStartOfPlayerTurn && _turnsCounter == 0)
    shouldTriggerPlayerSkill = NO;
  
  // Skipp EnemyAppeared trigger except for the first time
  if (trigger == SkillTriggerPointEnemyAppeared && _turnsCounter != 0)
  {
    shouldTriggerEnemySkill = NO;
    shouldTriggerPlayerSkill = NO;
  }
  
  // Sequencing player and enemy skills in case both should be triggered
  SkillControllerBlock sequenceBlock = ^(BOOL triggered, id params) {
    BOOL enemySkillTriggered = FALSE;
    if (_enemy.curHealth > 0 || trigger == SkillTriggerPointEnemyDefeated)  // Call if still alive or cleanup trigger
      if (_enemySkillController && shouldTriggerEnemySkill)
      {
        [_enemySkillController triggerSkill:trigger withCompletion:completion];
        enemySkillTriggered = TRUE;
      }
    
    if (!enemySkillTriggered)
      completion(triggered, params);
  };
  
  // Triggering the player's skill with a sequence block or (if no player skill) the enemy's skill with a simple completion
  if (_playerSkillController && shouldTriggerPlayerSkill)
    [_playerSkillController triggerSkill:trigger withCompletion:sequenceBlock];
  else if (_enemySkillController && shouldTriggerEnemySkill)
    [_enemySkillController triggerSkill:trigger withCompletion:completion];
  else
    completion(NO, nil);
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
      if (_playerSkillController.orbColor == color)
        if ([_playerSkillController shouldSpawnRibbon])
          return YES;
  return NO;
}

- (BOOL) shouldSpawnRibbonForEnemySkill:(OrbColor)color
{
  if (_enemySkillController)
    if (_skillIndicatorEnemy)
      if (_enemySkillController.orbColor == color)
        if ([_enemySkillController shouldSpawnRibbon])
          return YES;
  return NO;
}

- (CGPoint) playerSkillIndicatorPosition
{
  return ccpAdd(_skillIndicatorPlayer.position, ccp(0, _skillIndicatorPlayer.contentSize.height/2));
}

- (CGPoint) enemySkillIndicatorPosition
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

- (void) enableSkillButton:(BOOL)enable
{
  [_skillIndicatorPlayer enableSkillButton:enable];
}

#pragma mark - Specials

- (BOOL) cakeKidSchedule
{
  return (_enemySkillController && [_enemySkillController isKindOfClass:[SkillCakeDrop class]]);
}

- (void) updateSpecialsWithCompletion:(SkillControllerBlock)completion
{
  [SkillBombs updateBombs:_battleLayer withCompletion:completion];
}


@end
