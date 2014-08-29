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
@property (readonly) SkillType playerSkill;
@property (readonly) SkillType enemySkill;
@property (readonly) SkillActivationType playerSkillActivation;
@property (readonly) SkillActivationType enemySkillActivation;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(SkillManager);

// Setup
- (void) updatePlayer:(BattlePlayer*)player;
- (void) updateEnemy:(BattlePlayer*)enemy;

// External calls
- (void) orbDestroyed:(OrbColor)color;

// Checks
- (BOOL) triggerSkillAfterTurn;

@end
