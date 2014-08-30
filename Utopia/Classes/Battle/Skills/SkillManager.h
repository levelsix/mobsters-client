//
//  SkillManager.h
//  Utopia
//
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "BattlePlayer.h"
#import "SkillController.h"

#define skillManager [SkillManager sharedInstance]

@interface SkillManager : NSObject
{
  BattlePlayer*   _player;
  BattlePlayer*   _enemy;
  
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
- (void) updatePlayer:(BattlePlayer*)player;
- (void) updateEnemy:(BattlePlayer*)enemy;

// External calls
- (void) orbDestroyed:(OrbColor)color;

// Checks
- (BOOL) triggerSkillAfterMoveWithBlock:(SkillControllerBlock)block;

@end
