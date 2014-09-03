//
//  SkillManager.h
//  Utopia
//
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "SkillController.h"

#define skillManager [SkillManager sharedInstance]

@interface SkillManager : NSObject
{
  NewBattleLayer* _battleLayer;
  
  BattlePlayer*   _player;
  BattlePlayer*   _enemy;
  BattleSprite*   _playerSprite;
  BattleSprite*   _enemySprite;
  
  SkillController* _playerSkillController;
  SkillController* _enemySkillController;
}

@property (readonly) OrbColor playerColor;
@property (readonly) OrbColor enemyColor;
@property (readonly) SkillType playerSkillType;
@property (readonly) SkillType enemySkillType;
@property (readonly) SkillActivationType playerSkillActivation;
@property (readonly) SkillActivationType enemySkillActivation;

@property (readonly) SkillController *playerSkillController;
@property (readonly) SkillController *enemySkillController;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(SkillManager);

// Setup
- (void) updateBattleLayer:(NewBattleLayer*)battleLayer;
- (void) updatePlayer:(BattlePlayer*)player andSprite:(BattleSprite*)playerSprite;
- (void) updateEnemy:(BattlePlayer*)enemy andSprite:(BattleSprite*)enemySprite;

// External calls
- (void) orbDestroyed:(OrbColor)color;
- (void) triggerSkillsWithBlock:(SkillControllerBlock)block andTrigger:(SkillTriggerPoint)trigger;

@end
