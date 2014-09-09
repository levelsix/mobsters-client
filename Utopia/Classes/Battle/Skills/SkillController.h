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
  SkillTriggerPointEnemyAppeared    = 1,
  SkillTriggerPointEnemyDefeated    = 2,
  SkillTriggerPointPlayerAppeared   = 3,
  SkillTriggerPointEndOfPlayerMove  = 4,
  SkillTriggerPointStartOfPlayerTurn = 5,
  SkillTriggerPointStartOfEnemyTurn = 6
  
} SkillTriggerPoint;

// Cheat codes (indices are taken from SkillType enum)
static NSString* const cheatCodesForSkills[] = {@"", @"reset", @"cake", @"goo", @"atk"};

///////////////////////////////////////////////////////////////////////////
// SkillController interface
///////////////////////////////////////////////////////////////////////////

@interface SkillController : NSObject
{
  SkillControllerBlock  _callbackBlock;
}

@property (readonly) SkillType            skillType;
@property (readonly) SkillActivationType  activationType;

@property (weak, nonatomic) NewBattleLayer  *battleLayer;
@property (weak, nonatomic) BattlePlayer    *player;
@property (weak, nonatomic) BattlePlayer    *enemy;
@property (weak, nonatomic) BattleSprite    *playerSprite;
@property (weak, nonatomic) BattleSprite    *enemySprite;

@property (assign, nonatomic) BOOL          belongsToPlayer;

@property (readonly) OrbColor orbColor;

- (id) initWithProto:(SkillProto*)proto andMobsterColor:(OrbColor)color;
+ (id) skillWithProto:(SkillProto*)proto andMobsterColor:(OrbColor)color; // Factory call, creates different skill types

// External callers
- (BOOL) skillIsReady;
- (void) orbDestroyed:(OrbColor)color;
- (SpecialOrbType) generateSpecialOrb;
- (void) triggerSkill:(SkillTriggerPoint)trigger withCompletion:(SkillControllerBlock)completion;

// To be overriden by specific skills
- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger;
- (void) skillTriggerFinished;
- (void) setDefaultValues;
- (void) setValue:(float)value forProperty:(NSString*)property;

// To be called by inherited skills to show the overlay
- (void) showSkillPopupOverlayWithCompletion:(SkillControllerBlock)completion;
- (void) makeSkillOwnerJumpWithTarget:(id)target selector:(SEL)completion;

// Serialization
- (NSDictionary*) serialize;
- (BOOL) deserialize:(NSDictionary*)dict;

@end
