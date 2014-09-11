//
//  SkillController.h
//  Utopia
//
//  Created by Mikhail Larionov on 8/28/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Skill.pb.h"
#import "BattleOrb.h"
#import "BattlePlayer.h"
#import "BattleSprite.h"
#import "SkillPopupOverlay.h"

@class NewBattleLayer;

// Skill triggers
typedef enum {
  SkillTriggerPointEnemyInitialized   = 1,
  SkillTriggerPointPlayerInitialized  = 2,
  SkillTriggerPointEnemyAppeared      = 3,
  SkillTriggerPointEnemyDefeated      = 4,
  SkillTriggerPointEndOfPlayerMove    = 5,
  SkillTriggerPointStartOfPlayerTurn  = 6,
  SkillTriggerPointStartOfEnemyTurn   = 7
  
} SkillTriggerPoint;

// Cheat codes (indices are taken from SkillType enum)
static NSString* const cheatCodesForSkills[] = {@"", @"reset", @"cake", @"goo", @"atk"};

///////////////////////////////////////////////////////////////////////////
// SkillController interface
///////////////////////////////////////////////////////////////////////////

@interface SkillController : NSObject
{
  SkillControllerBlock  _callbackBlock;
  SkillControllerBlock  _callbackBlockForPopup;
  UIImageView*          _characterImage;
  SkillPopupOverlay*    _popupOverlay;
}

@property (readonly) SkillType            skillType;
@property (readonly) SkillActivationType  activationType;

@property (weak, nonatomic) NewBattleLayer  *battleLayer;
@property (weak, nonatomic) BattlePlayer    *player;
@property (weak, nonatomic) BattlePlayer    *enemy;
@property (weak, nonatomic) BattleSprite    *playerSprite;
@property (weak, nonatomic) BattleSprite    *enemySprite;

@property (assign, nonatomic) BOOL          belongsToPlayer;
@property (assign, nonatomic) BOOL          shouldExecuteInitialAction; // is set to NO if was serialized

@property (readonly) OrbColor orbColor;

- (id) initWithProto:(SkillProto*)proto andMobsterColor:(OrbColor)color;
+ (id) skillWithProto:(SkillProto*)proto andMobsterColor:(OrbColor)color; // Factory call, creates different skill types

// External callers
- (BOOL) skillIsReady;
- (void) orbDestroyed:(OrbColor)color special:(SpecialOrbType)type;
- (SpecialOrbType) generateSpecialOrb;
- (void) triggerSkill:(SkillTriggerPoint)trigger withCompletion:(SkillControllerBlock)completion;

// To be overriden by specific skills
- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger;
- (void) skillTriggerFinished;
- (void) setDefaultValues;
- (void) setValue:(float)value forProperty:(NSString*)property;

// To be called by inherited skills to show the overlay
- (void) showSkillPopupOverlay:(BOOL)jumpFirst withCompletion:(SkillControllerBlock)completion;
- (void) makeSkillOwnerJumpWithTarget:(id)target selector:(SEL)completion;

// Serialization
- (NSDictionary*) serialize;
- (BOOL) deserialize:(NSDictionary*)dict;

@end
