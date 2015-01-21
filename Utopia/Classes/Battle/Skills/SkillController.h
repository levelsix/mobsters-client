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

typedef void(^SkillControllerBlock)(BOOL triggered, id params);

@class NewBattleLayer;

// Skill triggers
typedef enum {
  SkillTriggerPointEnemyInitialized   = 1,
  SkillTriggerPointPlayerInitialized  = 2,
  SkillTriggerPointEnemyAppeared      = 3,  // There's no PlayerAppeared, because player appears when initialized
  SkillTriggerPointEnemyDefeated      = 4,
  SkillTriggerPointPlayerMobDefeated  = 5,
  SkillTriggerPointEndOfPlayerMove    = 6,
  SkillTriggerPointStartOfPlayerTurn  = 7,
  SkillTriggerPointStartOfEnemyTurn   = 8,
  SkillTriggerPointEnemyDealsDamage   = 9,
  SkillTriggerPointPlayerDealsDamage  = 10,
  SkillTriggerPointManualActivation   = 11,
  SkillTriggerPointEndOfPlayerTurn    = 12,
  SkillTriggerPointEndOfEnemyTurn     = 13
  
} SkillTriggerPoint;

// Cheat codes (indices are taken from SkillType enum)
static NSString* const cheatCodesForSkills[] = {
  @"", @"reset", @"cake", @"goo", @"atk", @"bombs", @"shield", @"poison", @"rage",
  @"momentum", @"toughskin", @"critevade", @"shuffle", @"headshot", @"mud", @"lifesteal", @"counterstrike"};

static NSString* const kSkillIconImageNameSuffix = @"icon.png";
static NSString* const kSkillLogoImageNameSuffix = @"logo.png";
static NSString* const kSkillMiniLogoImageNameSuffix = @"minilogo.png";

///////////////////////////////////////////////////////////////////////////
// SkillController interface
///////////////////////////////////////////////////////////////////////////

@interface SkillController : NSObject
{
  SkillControllerBlock  _callbackBlock;
  NSDictionary*         _callbackParams;
  SkillPopupBlock       _callbackBlockForPopup;
  UIImageView*          _characterImage;
  SkillPopupOverlay*    _popupOverlay;
  
  SkillTriggerPoint     _currentTrigger;
  BOOL                  _executedInitialAction;
}

@property (readonly) SkillType            skillType;
@property (readonly) SkillActivationType  activationType;
@property (readonly) NSInteger            skillId;
@property (readonly) NSString*            skillImageNamePrefix;

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
- (void) orbDestroyed:(OrbColor)color special:(SpecialOrbType)type;
- (BOOL) generateSpecialOrb:(BattleOrb*)orb atColumn:(int)column row:(int)row;
- (NSInteger) modifyDamage:(NSInteger)damage forPlayer:(BOOL)player;
- (BOOL) skillOwnerWillEvade;
- (BOOL) triggerSkill:(SkillTriggerPoint)trigger withCompletion:(SkillControllerBlock)completion;
- (void) restoreVisualsIfNeeded;

// To be overriden by specific skills
- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute;
- (void) skillTriggerFinished;
- (void) setDefaultValues;
- (void) setValue:(float)value forProperty:(NSString*)property;
- (BOOL) shouldSpawnRibbon;

// To be called by inherited skills to show the overlay
- (void) showSkillPopupOverlay:(BOOL)jumpFirst withCompletion:(SkillPopupBlock)completion;
- (void) makeSkillOwnerJumpWithTarget:(id)target selector:(SEL)completion;

// Serialization
- (NSDictionary*) serialize;
- (BOOL) deserialize:(NSDictionary*)dict;

// Helpers
- (void) preseedRandomization;
+ (NSInteger) specialsOnBoardCount:(SpecialOrbType)type layout:(BattleOrbLayout*)layout;
+ (NSInteger) specialTilesOnBoardCount:(TileType)type layout:(BattleOrbLayout*)layout;
- (NSInteger) specialsOnBoardCount:(SpecialOrbType)type;
- (NSInteger) specialTilesOnBoardCount:(TileType)type;

@end
