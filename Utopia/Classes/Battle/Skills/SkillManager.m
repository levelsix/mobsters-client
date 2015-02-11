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
#import "SkillControllerActive.h"

@implementation SkillManager

SYNTHESIZE_SINGLETON_FOR_CLASS(SkillManager);

- (id) init
{
  self = [super init];
  if ( ! self )
    return nil;
  
  _persistentSkillControllers = [[NSMutableArray alloc] init];
  
  _playerColor = _enemyColor = OrbColorNone;
  _playerSkillType = _enemySkillType = SkillTypeNoSkill;
  _cheatPlayerSkillType = _cheatEnemySkillType = SkillTypeNoSkill;
  _cheatEnemySkillId = _cheatPlayerSkillId = -1;
  
#ifdef DEBUG
  // Change it to override current skills for debug purposes
  //_cheatEnemySkillType = SkillTypeQuickAttack;
  //_cheatEnemySkillId = -1;
  //_cheatPlayerSkillType = SkillTypeQuickAttack;
  //_cheatPlayerSkillId = -1;
#endif
  
  _playerUsedAbility = NO;
  _enemyUsedAbility = NO;
  
  return self;
}

#pragma mark - Setup

- (void) updatePlayerSkill
{
  if (_playerSkillController && _playerSkillController.shouldPersist)
  {
    [_persistentSkillControllers addObject:_playerSkillController];
  }
  
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
  
  if (_enemySkillController && _enemySkillController.shouldPersist)
  {
    [_persistentSkillControllers addObject:_enemySkillController];
  }
  
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
  
  for (SkillController *perSkill in _persistentSkillControllers) {
    [self setDataForController:perSkill];
  }
}

- (void) setDataForController:(SkillController*)controller
{
  controller.battleLayer = _battleLayer;
  controller.player = _player;
  controller.playerSprite = _playerSprite;
  controller.enemy = _enemy;
  controller.enemySprite = _enemySprite;
  controller.belongsToPlayer = controller.belongsToPlayer || (controller == _playerSkillController);
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
  
  for (SkillController* persisSkill in _persistentSkillControllers) {
    result = [persisSkill modifyDamage:result forPlayer:player];
  }
  
  return result;
}

- (BOOL) playerWillEvade:(BOOL)player
{
  if (player && _playerSkillController)
    return [_playerSkillController skillOwnerWillEvade];
  if (!player && _enemySkillController)
    return [_enemySkillController skillOwnerWillEvade];
  
  return NO;
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
  
  /*
   * 12/11/14 - BN - All triggers should be sent to skills and skill controllers
   * should be responsible for implementing logic around various triggers
   *
  // Skip first skill attack for both player and enemy if it's right after enemy appearance
  if (trigger == SkillTriggerPointStartOfEnemyTurn && _turnsCounter == 0)
    shouldTriggerEnemySkill = NO;
  if (trigger == SkillTriggerPointStartOfPlayerTurn && _turnsCounter == 0)
    shouldTriggerPlayerSkill = NO;
   */
  
  // Skipp EnemyAppeared trigger except for the first time
  if (trigger == SkillTriggerPointEnemyAppeared && _turnsCounter != 0)
  {
    shouldTriggerEnemySkill = NO;
    shouldTriggerPlayerSkill = NO;
  }
  
  // Sequencing player and enemy skills in case both should be triggered
  SkillControllerBlock sequenceBlock = ^(BOOL triggered, id params) {
    if (triggered)
    {
      [self pruneRepeatedSkills:_playerSkillController];
    }
    BOOL enemySkillTriggered = FALSE;
    if (_enemy.curHealth > 0 || trigger == SkillTriggerPointEnemyDefeated)  // Call if still alive or cleanup trigger
      if (_enemySkillController && shouldTriggerEnemySkill)
      {
        [_enemySkillController triggerSkill:trigger withCompletion:^(BOOL triggered, id params) {
          if (triggered)
            [self pruneRepeatedSkills:_enemySkillController];
          [self triggerPersistentSkills:_persistentSkillControllers index:0 trigger:trigger triggered:triggered completion:completion params:params];
        }];
        enemySkillTriggered = TRUE;
      }
    
    if (!enemySkillTriggered)
      [self triggerPersistentSkills:_persistentSkillControllers index:0 trigger:trigger triggered:triggered completion:completion params:params];
  };
  
  // Triggering the player's skill with a sequence block or (if no player skill) the enemy's skill with a simple completion
  if (_playerSkillController && shouldTriggerPlayerSkill)
    [_playerSkillController triggerSkill:trigger withCompletion:sequenceBlock];
  else if (_enemySkillController && shouldTriggerEnemySkill)
    [_enemySkillController triggerSkill:trigger withCompletion:^(BOOL triggered, id params) {
      if (triggered)
        [self pruneRepeatedSkills:_enemySkillController];
      [self triggerPersistentSkills:_persistentSkillControllers index:0 trigger:trigger triggered:triggered completion:completion params:params];
    }];
  else
    [self triggerPersistentSkills:_persistentSkillControllers index:0 trigger:trigger triggered:NO completion:completion params:nil];
  
  [self prunePersistentSkillsForPersistence];
}

#pragma mark - Persistent Skils

- (void) triggerPersistentSkills:(NSMutableArray *)skills index:(int)index trigger:(SkillTriggerPoint)trigger triggered:(BOOL)outerTriggered completion:(SkillControllerBlock)completion params:(id)outerParams
{
  if (index >= skills.count)
  {
    [self prunePersistentSkillsForPersistence];
    completion(outerTriggered, outerParams);
  }
  else
  {
    [(SkillController *)skills[index] triggerSkill:trigger withCompletion:^(BOOL triggered, id params) {
      [self triggerPersistentSkills:skills index:(index+1) trigger:trigger triggered:triggered completion:completion params:params];
    }];
  }
}

- (void) prunePersistentSkillsForPersistence
{
  for (int i = ((int)_persistentSkillControllers.count)-1; i >= 0; i--) {
    if (![(SkillController*)_persistentSkillControllers[i] shouldPersist]) {
      [_persistentSkillControllers removeObjectAtIndex:(NSUInteger)i];
    }
  }
}

- (void) pruneRepeatedSkills:(SkillController *)sameAsSkill
{
  SkillController *skill;
  for (int i = ((int)_persistentSkillControllers.count)-1; i >= 0; i--) {
    skill = (SkillController*)_persistentSkillControllers[i];
    if ([skill class] == [sameAsSkill class]
        && skill.belongsToPlayer == sameAsSkill.belongsToPlayer) {
      [_persistentSkillControllers removeObjectAtIndex:(NSUInteger)i];
    }
  }
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
      _skillIndicatorEnemy.position = CGPointMake(_skillIndicatorEnemy.contentSize.width/2 - 10,
                                                  UI_DEVICE_IS_IPHONE_4 ? 85 : [_battleLayer.orbLayer convertToNodeSpace:[_battleLayer convertToWorldSpace:_battleLayer.currentEnemy.position]].y + 5);
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
      _skillIndicatorPlayer.position = CGPointMake(-_skillIndicatorPlayer.contentSize.width/2 - 10,
                                                   UI_DEVICE_IS_IPHONE_4 ? 40 : [_battleLayer.orbLayer convertToNodeSpace:[_battleLayer convertToWorldSpace:_battleLayer.myPlayer.position]].y + 5);
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
  [self serializePersistentSkills:result];
  return result;
}

- (void) serializePersistentSkills:(NSMutableDictionary *)result
{
  int i;
  SkillController *skillController;
  for (i =0; i < _persistentSkillControllers.count; i++) {
    skillController = (SkillController*)_persistentSkillControllers[i];
    [result setObject:[skillController serialize]
               forKey:[NSString stringWithFormat:@"persistentSkill%i", i]];
    
  }
  [result setObject:@(i) forKey:@"persistentSkillCount"];
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
  [self deserializePersistentSkills:dict];
}

- (void) deserializePersistentSkills:(NSDictionary*)dict
{
  int persistentSkillCount = [[dict objectForKey:@"persistentSkillCount"] intValue];
  GameState *gs = [GameState sharedGameState];
  NSDictionary *skillState;
  SkillController *skill;
  SkillProto *proto;
  OrbColor color;
  for (int i = 0; i < persistentSkillCount; i++) {
    skillState = [dict objectForKey:[NSString stringWithFormat:@"persistentSkill%i", i]];
    proto = [gs.staticSkills objectForKey:[skillState objectForKey:@"skillId"]];
    color = [[skillState objectForKey:@"color"] intValue];
    skill = [SkillController skillWithProto:proto andMobsterColor:color];
    [skill deserialize:skillState];
    [_persistentSkillControllers addObject:skill];
  }
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
    if (_playerSkillController.activationType != SkillActivationTypePassive)
      if (_skillIndicatorPlayer)
        if (_playerSkillController.orbColor == color)
          if ([_playerSkillController shouldSpawnRibbon])
            return YES;
  return NO;
}

- (BOOL) shouldSpawnRibbonForEnemySkill:(OrbColor)color
{
  if (_enemySkillController)
    if (_enemySkillController.activationType != SkillActivationTypePassive)
      if (_skillIndicatorEnemy)
        if (_enemySkillController.orbColor == color)
          if ([_enemySkillController shouldSpawnRibbon])
            return YES;
  return NO;
}

- (SkillController *) enemySkillControler {
  return _enemySkillController;
}
- (SkillController *) playerSkillControler {
  return _playerSkillController;
}

- (SkillBattleIndicatorView *) enemySkillIndicatorView
{
  return _skillIndicatorEnemy;
}

- (SkillBattleIndicatorView *) playerSkillIndicatorView
{
  return _skillIndicatorPlayer;
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

- (void) displaySkillCounterPopupForController:(SkillController*)controller withProto:(SkillProto*)proto atPosition:(CGPoint)pos
{
  NSString *bgName = [NSString stringWithFormat:@"%@.png", [Globals imageNameForElement:(Element)controller.orbColor suffix:@"skilldescription"]];
  NSString *orbImage = nil, *orbCount = nil, *orbDesc = nil;
  
  /*
  if ([controller isKindOfClass:[SkillControllerActive class]])
  {
    SkillControllerActive* activeController = (SkillControllerActive*)controller;
    orbCount = [NSString stringWithFormat:@"%d/%d", (int)(activeController.orbRequirement - activeController.orbCounter), (int)activeController.orbRequirement];
    orbImage = [NSString stringWithFormat:@"%@.png", [Globals imageNameForElement:(Element)controller.orbColor suffix:@"orb"]];
  }
  else
    orbDesc = @"PASSIVE";
   */
  
  [_battleLayer.hudView.skillPopupView displayWithSkillName:proto.name
                                                description:proto.description
                                               counterLabel:orbCount
                                             orbDescription:orbDesc
                                            backgroundImage:bgName
                                                   orbImage:orbImage
                                                 atPosition:pos];
}

- (void) flushPersistentSkills
{
  [_persistentSkillControllers removeAllObjects];
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
