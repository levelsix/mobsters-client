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
  SkillTriggerPointEnemyInitialized     = 1,
  SkillTriggerPointPlayerInitialized    = 2,
  SkillTriggerPointEnemyAppeared        = 3,  // There's no PlayerAppeared, because player appears when initialized
  SkillTriggerPointEnemyDefeated        = 4,
  SkillTriggerPointPlayerMobDefeated    = 5,
  SkillTriggerPointEndOfPlayerMove      = 6,
  SkillTriggerPointStartOfPlayerTurn    = 7,
  SkillTriggerPointStartOfEnemyTurn     = 8,
  SkillTriggerPointEnemyDealsDamage     = 9,
  SkillTriggerPointPlayerDealsDamage    = 10,
  SkillTriggerPointManualActivation     = 11,
  SkillTriggerPointEndOfPlayerTurn      = 12,
  SkillTriggerPointEndOfEnemyTurn       = 13,
  SkillTriggerPointEnemySkillActivated  = 14, // Active (orb activated) skills only
  SkillTriggerPointPlayerSkillActivated = 15  // Active (orb activated) skills only
  
} SkillTriggerPoint;

// Cheat codes (indices are taken from SkillType enum)
static NSString* const cheatCodesForSkills[] = {
  @"", @"reset", @"cake", @"goo", @"atk", @"bombs", @"shield", @"poison", @"rage", @"momentum", @"toughskin",
  @"critevade", @"shuffle", @"headshot", @"mud", @"lifesteal", @"counterstrike", @"flamestrike", @"confusion",
  @"staticfield", @"blindinglight", @"poisonpowder", @"skewer", @"knockout", @"shallowgrave", @"hammertime",
  @"bloodrage", @"takeaim", @"hellfire", @"energize", @"righthook", @"curse", @"insurance", @"flamebreak", @"pskew", @"pfire", @"chill"};

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
  SkillPopupOverlay*    _popupOverlay;
  NSString*             _popupBottomText;
  SkillPopupData*       _currentSkillPopup;
  
  SkillTriggerPoint     _currentTrigger;
  BOOL                  _executedInitialAction;
  BOOL                  _skillActivated;
  int                   _stacks;
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

@property (nonatomic) BattlePlayer  *userPlayer;
@property (nonatomic) BattlePlayer  *opponentPlayer;
@property (nonatomic) BattleSprite  *userSprite;
@property (nonatomic) BattleSprite  *opponentSprite;

@property (weak, nonatomic) NSString        *ownerUdid;

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
- (BOOL) skillOwnerWillMiss;
- (BOOL) skillOpponentWillMiss;
- (BOOL) triggerSkill:(SkillTriggerPoint)trigger withCompletion:(SkillControllerBlock)completion;
- (void) restoreVisualsIfNeeded;

// To be overriden by specific skills
- (BOOL) skillCalledWithTrigger:(SkillTriggerPoint)trigger execute:(BOOL)execute;
- (void) skillTriggerFinished;
- (void) skillTriggerFinishedActivated;
- (void) skillTriggerFinished:(BOOL)skillActivated;
- (void) setDefaultValues;
- (void) setValue:(float)value forProperty:(NSString*)property;
- (BOOL) shouldSpawnRibbon;
- (BOOL) shouldPersist;
- (NSSet*) sideEffects;
- (BOOL) targetsPlayer:(BattlePlayer*)player;

// Reusable poison effects
@property (readonly) int poisonDamage;
- (void) dealPoisonDamage;
- (void) onFinishPoisonDamage;

// Reusable quick attack effects
@property (readonly) int quickAttackDamage; //Override the getter to set value
- (void) showQuickAttackMiniLogo;
- (void) dealQuickAttack;
- (void) quickAttackDealDamage;
- (void) onFinishQuickAttack;

// Item stuff
- (BOOL) cureStatusWithAntidote:(BattleItemProto*)antidote execute:(BOOL)execute;

// To be called by inherited skills to show the overlay
- (void) showSkillPopupOverlay:(BOOL)jumpFirst withCompletion:(SkillPopupBlock)completion;
- (void) showSkillPopupMiniOverlay:(NSString*)bottomText;
- (void) showSkillPopupMiniOverlay:(BOOL)jumpFirst bottomText:(NSString*)bottomText withCompletion:(SkillPopupBlock)completion;
- (void) showSkillPopupAilmentOverlay:(NSString*)topText bottomText:(NSString*)bottomText;
- (void) showSkillPopupAilmentOverlay:(NSString*)topText bottomText:(NSString*)bottomText priority:(int)priority;
- (void) showSkillPopupAilmentOverlay:(BOOL)jumpFirst topText:(NSString*)topText bottomText:(NSString*)bottomText priority:(int)priority withCompletion:(SkillPopupBlock)completion;
- (void) showAntidotePopupOverlay:(BattleItemProto*)antidote bottomText:(NSString*)bottomText;
- (void) makeSkillOwnerJumpWithTarget:(id)target selector:(SEL)completion;
- (void) enqueueSkillPopup:(SkillPopupData*)skillPopupData;
- (int) skillStacks;

- (void) enqueueSkillPopupMiniOverlay:(NSString*)bottomText;
- (void) enqueueSkillPopupAilmentOverlay:(NSString*)topText bottomText:(NSString*)bottomText;
- (void) enqueueSkillPopupAilmentOverlay:(NSString*)topText bottomText:(NSString*)bottomText priority:(int)priority;
- (void) showCurrentSkillPopup;

// Serialization
- (NSDictionary*) serialize;
- (BOOL) deserialize:(NSDictionary*)dict;

// Side effects
- (void) addSkillSideEffectToSkillOwner:(SideEffectType)type turnsAffected:(NSInteger)numTurns;
- (void) addSkillSideEffectToOpponent:(SideEffectType)type turnsAffected:(NSInteger)numTurns;
- (void) addSkillSideEffectToSkillOwner:(SideEffectType)type turnsAffected:(NSInteger)numTurns turnsAreSkillOwners:(BOOL)turnsAreSkillOwners;
- (void) addSkillSideEffectToOpponent:(SideEffectType)type turnsAffected:(NSInteger)numTurns turnsAreSkillOwners:(BOOL)turnsAreSkillOwners;
- (void) removeSkillSideEffectFromSkillOwner:(SideEffectType)type;
- (void) removeSkillSideEffectFromOpponent:(SideEffectType)type;
- (void) resetAfftectedTurnsCount:(NSInteger)numTurns forSkillSideEffectOnSkillOwner:(SideEffectType)type;
- (void) resetAfftectedTurnsCount:(NSInteger)numTurns forSkillSideEffectOnOpponent:(SideEffectType)type;

// Helpers
- (void) preseedRandomization;
+ (NSInteger) specialsOnBoardCount:(SpecialOrbType)type layout:(BattleOrbLayout*)layout;
+ (NSInteger) specialTilesOnBoardCount:(TileType)type layout:(BattleOrbLayout*)layout;
- (NSInteger) specialsOnBoardCount:(SpecialOrbType)type;
- (NSInteger) specialTilesOnBoardCount:(TileType)type;

@end
