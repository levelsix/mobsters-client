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
#import "BattleHudView.h"
#import "SkillSideEffect.h"
#import "SkillProtoHelper.h"

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
  
  _skillPopupPlayer = [[SkillPopupOverlayController alloc] initWithBelongsToPlayer:YES];
  _skillPopupEnemy = [[SkillPopupOverlayController alloc] initWithBelongsToPlayer:NO];
  
#ifdef DEBUG
  // Change it to override current skills for debug purposes
  //_cheatEnemySkillType = SkillTypeQuickAttack;
  //_cheatEnemySkillId = -1;
  //_cheatPlayerSkillType = SkillTypeQuickAttack;
  //_cheatPlayerSkillId = -1;
#endif
  
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
      for (SkillController* skillController in _persistentSkillControllers) {
        if (skillController.ownerUdid == _player.userMonsterUuid)
        {
          _playerSkillController = skillController;
        }
      }
      if (!_playerSkillController)
        _playerSkillController = [SkillController skillWithProto:playerSkillProto andMobsterColor:_playerColor];
      else
        [_persistentSkillControllers removeObject:_playerSkillController];
    }
  }
  
  // Deserialize if needed
  if (_playerSkillController && _playerSkillSerializedState)
  {
    [_playerSkillController deserialize:_playerSkillSerializedState];
  }
  _playerSkillSerializedState = nil;
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
      for (SkillController* skillController in _persistentSkillControllers) {
        if (skillController.ownerUdid == _enemy.userMonsterUuid)
        {
          _enemySkillController = skillController;
        }
      }
      if (!_enemySkillController)
        _enemySkillController = [SkillController skillWithProto:enemySkillProto andMobsterColor:_enemyColor];
      else
        [_persistentSkillControllers removeObject:_enemySkillController];
    }
  }
  
  // Deserialize if needed
  if (_enemySkillController && _enemySkillSerializedState)
  {
    [_enemySkillController deserialize:_enemySkillSerializedState];
  }
  _enemySkillSerializedState = nil;

}

- (void) updateReferences
{
  _enemySprite = _battleLayer.mainView.currentEnemy;
  _playerSprite = _battleLayer.mainView.myPlayer;
  
  if (_enemySkillController)
  {
    [self setDataForController:_enemySkillController];
    _enemySkillController.ownerUdid = _enemy.userMonsterUuid;
    _enemySkillController.ownerMonsterId = _enemy.monsterId;
  }
  if (_playerSkillController)
  {
    [self setDataForController:_playerSkillController];
    _playerSkillController.ownerUdid = _player.userMonsterUuid;
    _playerSkillController.ownerMonsterId = _player.monsterId;
  }
  
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
  if (!controller.ownerMonsterImageName)
  {
    controller.ownerMonsterImageName = [(controller.belongsToPlayer ? _playerSprite.prefix : _enemySprite.prefix) stringByAppendingString:@"Character.png"];
  }
}

#pragma mark - External calls

- (void) updateBattleLayer:(NewBattleLayer*)battleLayer
{
  _battleLayer = battleLayer;
  _playerSkillController = nil;
  _enemySkillController = nil;
  _skillIndicatorEnemy = _skillIndicatorPlayer = nil;
  _skillPopupPlayer.battleLayer = battleLayer;
  _skillPopupEnemy.battleLayer = battleLayer;
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
  
  if (_playerSkillController && _player.curHealth > 0)
    generated = [_playerSkillController generateSpecialOrb:orb atColumn:column row:row];
  
  if (! generated)
    if (_enemySkillController && _enemy.curHealth > 0)
      generated = [_enemySkillController generateSpecialOrb:orb atColumn:column row:row];
  
  return generated;
}

- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player
{
  NSInteger result = damage;
  
  if (_playerSkillController) {
    result = [_playerSkillController modifyDamage:result forPlayer:player];
    if (result != damage)
        [self.battleLayer.battleStateMachine.currentBattleState addSkillStepForTriggerPoint:SkillTriggerPointModifyDamage skillId:(int)_playerSkillController.skillId belongsToPlayer:YES ownerMonsterId:_player.monsterId];
    damage = result;
  }
  
  if (_enemySkillController) {
    result = [_enemySkillController modifyDamage:result forPlayer:player];
    if (result != damage)
      [self.battleLayer.battleStateMachine.currentBattleState addSkillStepForTriggerPoint:SkillTriggerPointModifyDamage skillId:(int)_playerSkillController.skillId belongsToPlayer:NO ownerMonsterId:_enemy.monsterId];
    damage = result;
  }
  
  for (SkillController* persisSkill in _persistentSkillControllers) {
    result = [persisSkill modifyDamage:result forPlayer:player];
    if (result != damage)
      [self.battleLayer.battleStateMachine.currentBattleState addSkillStepForTriggerPoint:SkillTriggerPointModifyDamage skillId:(int)persisSkill.skillId belongsToPlayer:persisSkill.belongsToPlayer ownerMonsterId:(int)persisSkill.ownerMonsterId];
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

- (BOOL) playerWillMiss:(BOOL)player
{
  if (player)
  {
    return (_playerSkillController && [_playerSkillController skillOwnerWillMiss]) || (_enemySkillController && [_enemySkillController skillOpponentWillMiss]);
  }
  else
  {
    return (_enemySkillController && [_enemySkillController skillOwnerWillMiss]) || (_playerSkillController && [_playerSkillController skillOpponentWillMiss]);
  }
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
//  [_playerSkillController restoreVisualsIfNeeded];
    
    _skillVisualsRestored = NO;
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
//  [_enemySkillController restoreVisualsIfNeeded];
  }
  
  /*
   * 2/19/15 - BN - Moving restoreVisualsIfNeeded invokation to a bit later,
   * when battle schedule, character sprites, etc. have all been initialized
   */
  if (!_skillVisualsRestored && (trigger == SkillTriggerPointStartOfPlayerTurn ||
                                 trigger == SkillTriggerPointStartOfEnemyTurn))
  {
    [_playerSkillController restoreVisualsIfNeeded];
    [_enemySkillController restoreVisualsIfNeeded];
    
    _skillVisualsRestored = YES;
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
    BOOL enemySkillTriggered = FALSE;
    if (_enemy.curHealth > 0 || trigger == SkillTriggerPointEnemyDefeated)  // Call if still alive or cleanup trigger
      if (_enemySkillController && shouldTriggerEnemySkill)
      {
        [_enemySkillController triggerSkill:trigger withCompletion:^(BOOL triggered, id params) {
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
      //[_persistentSkillControllers removeObjectAtIndex:(NSUInteger)i];
      [[_persistentSkillControllers objectAtIndex:(NSUInteger)i] endDurationNow];
      [_persistentSkillControllers removeObjectAtIndex:i];
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
                                                  UI_DEVICE_IS_IPHONE_4 ? 85 : [_battleLayer.orbLayer convertToNodeSpace:[_battleLayer convertToWorldSpace:_enemySprite.position]].y + 5);
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
                                                   UI_DEVICE_IS_IPHONE_4 ? 40 : [_battleLayer.orbLayer convertToNodeSpace:[_battleLayer convertToWorldSpace:_playerSprite.position]].y + 5);
      [_skillIndicatorPlayer update];
      [_battleLayer.orbLayer addChild:_skillIndicatorPlayer z:-10];
    }
  }
}

#pragma mark - Logos

- (void) showSkillPopupOverlay:(BOOL)forPlayer jumpFirst:(BOOL)jumpFirst withData:(SkillPopupData*)data
{
  if (forPlayer)
    [_skillPopupPlayer enqueueSkillPopup:data];
  else
    [_skillPopupEnemy enqueueSkillPopup:data];
  
  if (jumpFirst)
  {
    if (forPlayer)
      [_playerSprite jumpNumTimes:2 completionTarget:_skillPopupPlayer selector:@selector(showCurrentSkillPopup)];
    else
      [_enemySprite jumpNumTimes:2 completionTarget:_skillPopupEnemy selector:@selector(showCurrentSkillPopup)];
  }
  else
  {
    [self showCurrentSkillPopup:forPlayer];
  }
}

- (void) enqueuePopupData:(SkillPopupData*)data forPlayer:(BOOL)forPlayer
{
  if (forPlayer)
    [_skillPopupPlayer enqueueSkillPopup:data];
  else
    [_skillPopupEnemy enqueueSkillPopup:data];
}

- (void) showItemPopupOverlay:(BattleItemProto*)item bottomText:(NSString*)bottomText
{
  [_skillPopupPlayer enqueueItemPopup:item bottomText:bottomText];
}

- (void) showCurrentSkillPopup:(BOOL)forPlayer
{
  if (forPlayer)
    [_skillPopupPlayer showCurrentSkillPopup];
  else
    [_skillPopupEnemy showCurrentSkillPopup];
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
  if (!_player.isCursed)
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
  if (!_enemy.isCursed)
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
  NSString *orbImage = nil, *orbCount = nil, *orbDesc = nil, *description = nil;
  
  if (controller == _playerSkillController) {
    description = [SkillProtoHelper offDescForSkill:proto];
  } else if (controller == _enemySkillController) {
    description = [SkillProtoHelper defDescForSkill:proto];
  }
  
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
  
  [_battleLayer.mainView.hudView.skillPopupView displayWithSkillName:proto.name
                                                description:description
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

- (__weak NewBattleLayer*) battleLayer
{
  return _battleLayer;
}

- (void) playDamageLogos
{
  [_skillPopupPlayer showCurrentSkillPopup];
  [_skillPopupEnemy showCurrentSkillPopup];
}

- (void)addSideEffectsToMonsterView:(MiniMonsterView *)monsterView forPlayer:(BattlePlayer *)player {
  if ([_playerSkillController targetsPlayer:player])
    [self addSideEffectsToMonsterView:monsterView fromSkill:_playerSkillController];
  
  if ([_enemySkillController targetsPlayer:player])
    [self addSideEffectsToMonsterView:monsterView fromSkill:_enemySkillController];
  
  for (SkillController *skill in _persistentSkillControllers)
    if ([skill targetsPlayer:player])
      [self addSideEffectsToMonsterView:monsterView fromSkill:skill];
}

- (void)addSideEffectsToMonsterView:(MiniMonsterView *)monsterView fromSkill:(SkillController *)skill {
  for (NSNumber *number in [skill sideEffects])
  {
    SideEffectType type = [number intValue];
    SkillSideEffectProto *proto = [Globals protoForSkillSideEffectType:type];
    if (proto) {
      SkillSideEffect *side = [SkillSideEffect sideEffectWithProto:proto invokingSkill:skill.skillId];
      if (side) {
        [monsterView displaySideEffectIcon:side.iconImageName withKey:side.name];
      }
    }
    
  }
}

- (NSSet*)sideEffectsOnPlayer:(BattlePlayer *)player {
  NSMutableSet *sides = [NSMutableSet set];
  
  if ([_playerSkillController targetsPlayer:player])
    [sides unionSet:[_playerSkillController sideEffects]];
  
  if ([_enemySkillController targetsPlayer:player])
    [sides unionSet:[_enemySkillController sideEffects]];
  
  for (SkillController *controller in _persistentSkillControllers)
    if ([controller targetsPlayer:player])
      [sides unionSet:[controller sideEffects]];
  
  return sides;
  
}

- (BOOL)useAntidote:(BattleItemProto*)antidote execute:(BOOL)execute
{
  BOOL temp = false;
  
  if (_enemySkillController) {
    temp = [_enemySkillController cureStatusWithAntidote:antidote execute:execute];
  }
  
  for (SkillController *skill in _persistentSkillControllers){
    if (!skill.belongsToPlayer){
      temp = [skill cureStatusWithAntidote:antidote execute:execute] || temp;
    }
  }
  
  return temp;
}

#pragma mark - Specials

- (BOOL) cakeKidSchedule
{
  return (_enemySkillController && [_enemySkillController isKindOfClass:[SkillCakeDrop class]]);
}


@end
