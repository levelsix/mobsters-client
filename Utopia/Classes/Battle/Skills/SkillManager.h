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
  
  // Skill indicators for UI
  SkillBattleIndicatorView* _skillIndicatorPlayer;
  SkillBattleIndicatorView* _skillIndicatorEnemy;
  
  // Serialization cache
  NSDictionary*     _playerSkillSerializedState;
  NSDictionary*     _enemySkillSerializedState;
  
  NSInteger         _turnsCounter;
}

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(SkillManager);

@property (assign, nonatomic) SkillType cheatEnemySkillType;  // If not SkillTypeNothing, overrides skills from protos
@property (assign, nonatomic) SkillType cheatPlayerSkillType;

// External calls
- (void) updateBattleLayer:(NewBattleLayer*)battleLayer;
- (void) orbDestroyed:(OrbColor)color special:(SpecialOrbType)type;
- (SpecialOrbType) generateSpecialOrb;
- (void) triggerSkills:(SkillTriggerPoint)trigger withCompletion:(SkillControllerBlock)completion;
- (BOOL) cakeKidSchedule;

// Serialization
- (NSDictionary*) serialize;
- (void) deserialize:(NSDictionary*)dict;

@end
