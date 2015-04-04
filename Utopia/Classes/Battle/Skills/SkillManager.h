//
//  SkillManager.h
//  Utopia
//
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "SkillController.h"
#import "SkillBattleIndicatorView.h"
#import "BattleHudView.h"

#define skillManager [SkillManager sharedInstance]

@interface SkillManager : NSObject
{
  // External objects
  __weak NewBattleLayer* _battleLayer;
  __weak BattlePlayer*   _player;
  __weak BattlePlayer*   _enemy;
  __weak BattleSprite*   _playerSprite;
  __weak BattleSprite*   _enemySprite;
  
  // Properties
  OrbColor            _playerColor;
  OrbColor            _enemyColor;
  SkillType           _playerSkillType;
  SkillType           _enemySkillType;
  SkillActivationType _playerSkillActivation;
  SkillActivationType _enemySkillActivation;
  
  // Skill controllers
  SkillController*  _playerSkillController;
  SkillController*  _enemySkillController;
  
  NSMutableArray*   _persistentSkillControllers; 
  
  // Skill indicators for UI
  SkillBattleIndicatorView* _skillIndicatorPlayer;
  SkillBattleIndicatorView* _skillIndicatorEnemy;
  
  // Serialization cache
  NSDictionary*     _playerSkillSerializedState;
  NSDictionary*     _enemySkillSerializedState;
  
  NSInteger         _turnsCounter;
  BOOL              _skillVisualsRestored;
}

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(SkillManager);

@property (assign, nonatomic) SkillType cheatEnemySkillType;  // If not SkillTypeNothing, overrides skills from protos
@property (assign, nonatomic) SkillType cheatPlayerSkillType;
@property (assign, nonatomic) NSInteger cheatEnemySkillId;    // If more or equal to zero, overrides skills from protos
@property (assign, nonatomic) NSInteger cheatPlayerSkillId;

// Core external calls
- (void) updateBattleLayer:(NewBattleLayer*)battleLayer;
- (void) orbDestroyed:(OrbColor)color special:(SpecialOrbType)type;
- (BOOL) generateSpecialOrb:(BattleOrb*)orb atColumn:(int)column row:(int)row;
- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player;
- (BOOL) playerWillEvade:(BOOL)player;
- (BOOL) playerWillMiss:(BOOL)player;
- (void) triggerSkills:(SkillTriggerPoint)trigger withCompletion:(SkillControllerBlock)completion;

// Serialization
- (NSDictionary*) serialize;
- (void) deserialize:(NSDictionary*)dict;

// Misc external calls
- (BOOL) shouldSpawnRibbonForPlayerSkill:(OrbColor)color;
- (BOOL) shouldSpawnRibbonForEnemySkill:(OrbColor)color;
- (SkillController *) enemySkillControler;
- (SkillController *) playerSkillControler;
- (SkillBattleIndicatorView *) enemySkillIndicatorView;
- (SkillBattleIndicatorView *) playerSkillIndicatorView;
- (CGPoint) playerSkillIndicatorPosition;
- (CGPoint) enemySkillIndicatorPosition;
- (BOOL) willEnemySkillTrigger:(SkillTriggerPoint)trigger;
- (BOOL) willPlayerSkillTrigger:(SkillTriggerPoint)trigger;
- (void) enableSkillButton:(BOOL)enable;
- (BOOL) cakeKidSchedule;
- (void) displaySkillCounterPopupForController:(SkillController*)controller withProto:(SkillProto*)proto atPosition:(CGPoint)pos;
- (void) pruneRepeatedSkills:(SkillController *)sameAsSkill;
- (void) flushPersistentSkills;
- (__weak NewBattleLayer*) battleLayer;
- (void) playDamageLogos;
- (BOOL) useAntidote:(BattleItemProto*)antidote execute:(BOOL)execute;

- (void) addSideEffectsToMonsterView:(MiniMonsterView*)monsterView forPlayer:(BattlePlayer*)player;
- (NSSet*) sideEffectsOnPlayer:(BattlePlayer*)player;


@end
