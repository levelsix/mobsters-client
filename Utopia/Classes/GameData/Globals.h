//
//  Globals.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/29/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "Protocols.pb.h"
#import "UserData.h"
#import "Analytics.h"
#import "GameMap.h"
#import "FullEvent.h"
#import "GenViewController.h"
#import "StaticStructure.h"

#import "MSDate.h"

#define BUTTON_CLICKED_LEEWAY 30

#define LNLog(...) if ([Globals isLoggingEnabled]) NSLog(__VA_ARGS__)

#define FULL_SCREEN_APPEAR_ANIMATION_DURATION 0.4f
#define FULL_SCREEN_DISAPPEAR_ANIMATION_DURATION 0.7f

#define IAP_DEFAULTS_KEY @"Unresponded In Apps"

#define LAST_LEAGUE_SHOWN_DEFAULTS_KEY @"LastLeagueShownKey"

#define MUSIC_DEFAULTS_KEY @"MusicDefaultsKey"
#define SOUND_EFFECTS_DEFAULTS_KEY @"SoundEffectsDefaultsKey"
#define SHAKE_DEFAULTS_KEY @"ShakeDefaultsKey"

#define IAP_SUCCESS_NOTIFICATION @"IapSuccessNotification"
#define HEAL_WAIT_COMPLETE_NOTIFICATION @"HealWaitCompleteNotification"
#define HEAL_QUEUE_CHANGED_NOTIFICATION @"MonsterQueueChangedNotification"
#define ENHANCE_MONSTER_NOTIFICATION @"EnhanceMonsterNotification"
#define EVOLUTION_WAIT_COMPLETE_NOTIFICATION @"EvolutionWaitCompleteNotification"
#define EVOLUTION_CHANGED_NOTIFICATION @"EvolutionChangedNotification"
#define RESEARCH_WAIT_COMPLETE_NOTIFICATION @"ResearchWaitCompleteNotification"
#define RESEARCH_CHANGED_NOTIFICATION @"ResearchChangedNotification"
#define COMBINE_WAIT_COMPLETE_NOTIFICATION @"CombineWaitCompleteNotification"
#define MINI_JOB_CHANGED_NOTIFICATION @"MiniJobWaitCompleteNotification"
#define MONSTER_SOLD_COMPLETE_NOTIFICATION @"MonsterSoldNotification"
#define MONSTER_LOCK_CHANGED_NOTIFICATION @"MonsterLockChangedNotification"
#define GAMESTATE_UPDATE_NOTIFICATION @"GameStateUpdateNotification"
#define MY_TEAM_CHANGED_NOTIFICATION @"MyTeamChangedNotification"
#define GLOBAL_CHAT_RECEIVED_NOTIFICATION @"GlobalChatReceivedNotification"
#define CLAN_CHAT_RECEIVED_NOTIFICATION @"ClanChatReceivedNotification"
#define PRIVATE_CHAT_RECEIVED_NOTIFICATION @"PrivateChatReceivedNotification"
#define PRIVATE_CHAT_VIEWED_NOTIFICATION @"PrivateChatViewedNotification"
#define CLAN_CHAT_VIEWED_NOTIFICATION @"ClanChatViewedNotification"

#define RECEIVED_CLAN_HELP_NOTIFICATION @"ReceivedClanHelpNotification"
#define CLAN_HELPS_CHANGED_NOTIFICATION @"ClanHelpsChangedNotification"
#define CLAN_HELP_NOTIFICATION_KEY @"ClanHelpNotificationKey"
#define CLAN_AVENGINGS_CHANGED_NOTIFICATION @"ClanAvengingsChangedNotification"
#define CLAN_TEAM_DONATIONS_CHANGED_NOTIFICATION @"ClanTeamDonationsChangedNotification"
#define MY_CLAN_TEAM_DONATION_CHANGED_NOTIFICATION @"MyClanTeamDonationChangedNotification"

#define SPEEDUP_USED_NOTIFICATION @"SpeedupUsedNotification"
#define SPEEDUP_NOTIFICATION_KEY @"SpeedupNotificationKey"

#define STRUCT_PURCHASED_NOTIFICATION @"StructPurchasedNotification"
#define STRUCT_COMPLETE_NOTIFICATION @"StructCompleteNotification"
#define OBSTACLE_REMOVAL_BEGAN_NOTIFICATION @"ObstaclePurchasedNotification"
#define OBSTACLE_COMPLETE_NOTIFICATION @"ObstacleCompleteNotification"

#define NEW_FB_INVITE_NOTIFICATION @"NewFbInviteNotification"
#define FB_INVITE_RESPONDED_NOTIFICATION @"FbInviteRespondedNotification"
#define NEW_BATTLE_HISTORY_NOTIFICATION @"NewBattleHistoryNotification"
#define BATTLE_HISTORY_VIEWED_NOTIFICATION @"BattleHistoryViewedNotification"
#define FB_INVITE_ACCEPTED_NOTIFICATION @"FbInviteAcceptedNotification"
#define FB_INCREASE_SLOTS_NOTIFICATION @"FbIncreaseSlotsNotification"
#define QUESTS_CHANGED_NOTIFICATION @"QuestsChangedNotification"
#define ACHIEVEMENTS_CHANGED_NOTIFICATION @"AchievementsChangedNotification"
#define MY_CLAN_MEMBERS_LIST_NOTIFICATION @"MyClanMembersListNotification"
#define CLAN_RAID_ATTACK_NOTIFICATION @"ClanRaidAttackNotification"
#define NEW_OBSTACLES_CREATED_NOTIFICATION @"NewObstaclesCreatedNotification"

#define STATIC_DATA_UPDATED_NOTIFICATION @"StaticDataUpdatedNotification"

#define ITEM_SELECT_OPENED_NOTIFICATION @"ItemSelectOpenedNotification"
#define ITEM_SELECT_CLOSED_NOTIFICATION @"ItemSelectClosedNotification"
#define ITEMS_CHANGED_NOTIFICATION @"ItemsChangedNotification"

#define BATTLE_ITEM_QUEUE_CHANGED_NOTIFICATION @"BattleItemQueueChangedNotification"
#define BATTLE_ITEM_REMOVED_NOTIFICATION @"BattleItemRemovedNotification"
#define BATTLE_ITEM_WAIT_COMPLETE_NOTIFICATION @"BattleItemWaitCompleteNotification"

#define MY_CLAN_MEMBERS_LIST_KEY @"MyMembersList"
#define CLAN_RAID_ATTACK_KEY @"ClanRaidAttackKey"
#define MUTED_PLAYERS_KEY @"MutedPlayersKey"

#define APP_OPEN_KEY @"AppOpenKey"

#define LOGGING_ENABLED_KEY @"LoggingEnabledKey"

#ifdef MOBSTERS
#define GAME_NAME @"Mob Squad"
#define GAME_ABBREV @"MS"
#define MONSTER_NAME @"Mobster"
#else
#define GAME_NAME @"Toon Squad"
#define GAME_ABBREV @"TS"
#define MONSTER_NAME @"Toon"
#endif

#define POINT_OFFSET_PER_SCENE ccp(512,360)
#define SLOPE_OF_ROAD (POINT_OFFSET_PER_SCENE.y/POINT_OFFSET_PER_SCENE.x)

#define FAT_KID_DUNGEON_LEVEL 5

#define SGN(A) ({ __typeof__(A) __a = (A); (0 < __a) - (__a < 0); })

@class BattlePlayer;

@interface Globals : NSObject

@property (nonatomic, assign) int minNameLength;
@property (nonatomic, assign) int maxNameLength;

@property (nonatomic, assign) float maxLevelForUser;

@property (nonatomic, assign) int maxLengthOfChatString;

@property (nonatomic, copy) NSString *appStoreLink;
@property (nonatomic, copy) NSString *reviewPageURL;
@property (nonatomic, assign) int levelToShowRateUsPopup;
@property (nonatomic, copy) NSString *reviewPageConfirmationMessage;

@property (nonatomic, assign) int fbConnectRewardDiamonds;

@property (nonatomic, retain) NSString *faqFileName;

@property (nonatomic, retain) MinimumUserProto *adminChatUser;

@property (nonatomic, assign) int numBeginnerSalesAllowed;
@property (nonatomic, assign) int defaultDaysBattleShieldIsActive;

@property (nonatomic, assign) float minutesPerGem;
@property (nonatomic, assign) int pvpRequiredMinLvl;
@property (nonatomic, assign) float gemsPerResource;
@property (nonatomic, assign) float continueBattleGemCostMultiplier;

@property (nonatomic, assign) int beginAvengingTimeLimitMins;
@property (nonatomic, assign) int requestClanToAvengeTimeLimitMins;
@property (nonatomic, assign) int defendingMsgCharLimit;

@property (nonatomic, assign) BOOL addAllFbFriends;
@property (nonatomic, assign) BOOL facebookSecondPopup;

@property (nonatomic, assign) int maxObstacles;
@property (nonatomic, assign) int minutesPerObstacle;

@property (nonatomic, assign) float battleRunAwayBasePercent;
@property (nonatomic, assign) float battleRunAwayIncrement;

@property (nonatomic, assign) int maxMinutesForFreeSpeedUp;

@property (nonatomic, retain) StartupResponseProto_StartupConstants_MiniTutorialConstants *miniTutorialConstants;

@property (nonatomic, retain) NSArray *speedupConstants;
@property (nonatomic, retain) NSArray *resourceConversionConstants;

@property (nonatomic, assign) BOOL displayRarity;

@property (nonatomic, assign) int taskIdOfFirstSkill;
@property (nonatomic, assign) int taskIdForUpgradeTutorial;

@property (nonatomic, assign) int minsToResolicitTeamDonation;

@property (nonatomic, assign) BOOL ignorePrerequisites;
@property (nonatomic, assign) BOOL ignoreTeamCheck;

// Monster Constants
@property (nonatomic, assign) int maxTeamSize;
@property (nonatomic, assign) int baseInventorySize;
@property (nonatomic, assign) float cashPerHealthPoint;
@property (nonatomic, assign) float elementalStrength;
@property (nonatomic, assign) float elementalWeakness;
@property (nonatomic, assign) float oilPerMonsterLevel;

// Map Constants
@property (nonatomic, strong) NSString *mapSectionImagePrefix;
@property (nonatomic, assign) int mapNumberOfSections;
@property (nonatomic, assign) float mapSectionHeight;
@property (nonatomic, assign) float mapTotalWidth;
@property (nonatomic, assign) float mapTotalHeight;

// Norm struct constants
@property (nonatomic, assign) int maxRepeatedNormStructs;

// Clan constants
@property (nonatomic, assign) int coinPriceToCreateClan;
@property (nonatomic, assign) int maxCharLengthForClanName;
@property (nonatomic, assign) int maxCharLengthForClanDescription;
@property (nonatomic, assign) int maxCharLengthForClanTag;
@property (nonatomic, assign) int maxClanSize;
@property (nonatomic, retain) NSArray *clanRewardAchievementIds;

// Clan Help constants
@property (nonatomic, retain) StartupResponseProto_StartupConstants_ClanHelpConstants *healClanHelpConstants;
@property (nonatomic, retain) StartupResponseProto_StartupConstants_ClanHelpConstants *evolveClanHelpConstants;
@property (nonatomic, retain) StartupResponseProto_StartupConstants_ClanHelpConstants *miniJobClanHelpConstants;
@property (nonatomic, retain) StartupResponseProto_StartupConstants_ClanHelpConstants *buildingClanHelpConstants;
@property (nonatomic, retain) StartupResponseProto_StartupConstants_ClanHelpConstants *enhanceClanHelpConstants;
@property (nonatomic, retain) StartupResponseProto_StartupConstants_ClanHelpConstants *battleItemClanHelpConstants;
@property (nonatomic, retain) StartupResponseProto_StartupConstants_ClanHelpConstants *researchClanHelpConstants;

// Tournament Constants
@property (nonatomic, assign) int tournamentWinsWeight;
@property (nonatomic, assign) int tournamentLossesWeight;
@property (nonatomic, assign) int tournamentFleesWeight;
@property (nonatomic, assign) int tournamentNumHrsToDisplayAfterEnd;

@property (nonatomic, retain) NSDictionary *productIdsToPackages;
@property (nonatomic, retain) NSArray *iapPackages;

@property (nonatomic, retain) NSMutableDictionary *imageCache;
@property (retain) NSMutableDictionary *imageViewsWaitingForDownloading;

@property (nonatomic, retain) NSMutableDictionary *animatingSpriteOffsets;

@property (nonatomic, retain) StartupResponseProto_StartupConstants_DownloadableNibConstants *downloadableNibConstants;

+ (Globals *) sharedGlobals;
+ (void) purgeSingleton;

+ (void) registerUserForPushNotifications;

- (void) updateInAppPurchases;
- (void) updateConstants:(StartupResponseProto_StartupConstants *)constants;
- (InAppPurchasePackageProto *) starterPackIapPackage;
- (InAppPurchasePackageProto *) moneyTreeIapPackage;

+ (NSString *) font;
+ (int) fontSize;

+ (CGSize)screenSize;

+ (NSString *) convertTimeToString:(int)secs withDays:(BOOL)withDays;
+ (NSString *) convertTimeToShortString:(int)secs;
+ (NSString *) convertTimeToShortString:(int)secs withAllDenominations:(BOOL)allDenom;
+ (NSString *) convertTimeToShorterString:(int)secs;
+ (NSString *) convertTimeToLongString:(int)secs;
+ (NSString *) convertTimeToMediumString:(int)secs;
+ (NSString *) convertTimeToSingleLongString:(int)secs;

+ (void) downloadAllFilesForSpritePrefixes:(NSArray *)spritePrefixes completion:(void (^)(void))completed;
+ (void) downloadAllAssetsForSkillSideEffects:(NSSet*)skillSideEffects completion:(void (^)(void))completed;

+ (NSString *) pathToFile:(NSString *)fileName useiPhone6Prefix:(BOOL)prefix;
+ (BOOL) isFileDownloaded:(NSString *)fileName useiPhone6Prefix:(BOOL)prefix;
+ (NSString *) downloadFile:(NSString *)fileName useiPhone6Prefix:(BOOL)prefix;
+ (void) checkAndLoadFile:(NSString *)fileName useiPhone6Prefix:(BOOL)prefix completion:(void (^)(BOOL success))completion;
+ (void) checkAndLoadSpriteSheet:(NSString *)fileName completion:(void (^)(BOOL success))completion;
+ (void) checkAndLoadFiles:(NSArray *)fileNames completion:(void (^)(BOOL success))completion;
+ (NSBundle *) bundleNamed:(NSString *)bundleName;
+ (NSString*) getDoubleResolutionImage:(NSString*)path useiPhone6Prefix:(BOOL)prefix;
+ (UIImage *) imageNamed:(NSString *)path;
+ (UIImage *) imageNamed:(NSString *)path useiPhone6Prefix:(BOOL)prefix;
+ (void) imageNamed:(NSString *)imageName withView:(UIView *)view maskedColor:(UIColor *)color indicator:(UIActivityIndicatorViewStyle)indicatorStyle clearImageDuringDownload:(BOOL)clear;
+ (void) imageNamed:(NSString *)imageName withView:(UIView *)view greyscale:(BOOL)greyscale indicator: (UIActivityIndicatorViewStyle)indicatorStyle clearImageDuringDownload:(BOOL)clear;
+ (void) imageNamedWithiPhone6Prefix:(NSString *)imageName withView:(UIView *)view maskedColor:(UIColor *)color indicator:(UIActivityIndicatorViewStyle)indicatorStyle clearImageDuringDownload:(BOOL)clear;
+ (void) imageNamedWithiPhone6Prefix:(NSString *)imageName withView:(UIView *)view greyscale:(BOOL)greyscale indicator: (UIActivityIndicatorViewStyle)indicatorStyle clearImageDuringDownload:(BOOL)clear;
+ (void) imageNamed:(NSString *)imageName toReplaceSprite:(CCSprite *)s;
+ (void) imageNamed:(NSString *)imageName toReplaceSprite:(CCSprite *)s completion:(void(^)(BOOL success))completion;

+ (UIColor *) colorForRarity:(Quality)rarity;
+ (NSString *) stringForRarity:(Quality)rarity;
+ (NSString *) shortenedStringForRarity:(Quality)rarity;
+ (NSString *) imageNameForRarity:(Quality)rarity suffix:(NSString *)str;
+ (NSString *) stringForElement:(Element)element;
+ (NSString *) imageNameForElement:(Element)element suffix:(NSString *)str;
+ (UIColor *) colorForElementOnDarkBackground:(Element)element;
+ (UIColor *) colorForElementOnLightBackground:(Element)element;

+ (Element) elementForSuperEffective:(Element)element;
+ (Element) elementForNotVeryEffective:(Element)element;

+ (NSString *) stringForTimeSinceNow:(MSDate *)date shortened:(BOOL)shortened;
+ (NSString *) stringForClanStatus:(UserClanStatus)status;
+ (NSString *) stringForResourceType:(ResourceType)res;

+ (NSString *) stringOfCurDate;

+ (NSArray *) convertCurrentTeamToArray:(UserCurrentMonsterTeamProto *)team;
+ (NSDictionary *) convertUserTeamArrayToDictionary:(NSArray *)array;

+ (SkillSideEffectProto*) protoForSkillSideEffectType:(SideEffectType)type;
+ (NSArray*) skillSideEffectProtosForBattlePlayer:(BattlePlayer*)bp enemy:(BOOL)enemy;

+ (void) adjustFontSizeForSize:(int)size withUIView:(UIView *)somethingWithText;
+ (void) adjustFontSizeForSize:(int)size withUIViews:(UIView *)field1, ... NS_REQUIRES_NIL_TERMINATION;
+ (void) adjustFontSizeForUIViewWithDefaultSize:(UIView *)somethingWithText;
+ (void) adjustFontSizeForUIViewsWithDefaultSize:(UIView *)field1, ... NS_REQUIRES_NIL_TERMINATION;
+ (void) adjustFontSizeForUILabel:(UILabel *)label;
+ (void) adjustFontSizeForUILabels:(UILabel *)field1, ... NS_REQUIRES_NIL_TERMINATION;
+ (void) adjustFontSizeForCCLabelTTF:(CCLabelTTF *)label size:(int)size;
+ (void) adjustFontSizeForSize:(int)size CCLabelTTFs:(CCLabelTTF *)field1, ... NS_REQUIRES_NIL_TERMINATION;

+ (NSString *) userConfimredPushNotificationsKey;
+ (NSString *) cashStringForNumber:(int)n;
+ (NSString *) commafyNumber:(float)n;
+ (NSString *) shortenNumber:(int)num;
+ (NSString *) qualifierStringForNumber:(int)rank;

+ (void) calculateDifferencesBetweenOldArray:(NSArray *)oArr newArray:(NSArray *)nArr removalIps:(NSMutableArray *)removals additionIps:(NSMutableArray *)additions section:(int)section;
+ (void) calculateDifferencesBetweenOldArray:(NSArray *)oArr newArray:(NSArray *)nArr removalIps:(NSMutableArray *)removals additionIps:(NSMutableArray *)additions movedIps:(NSMutableDictionary *)moves section:(int)section;

+ (void) setFrameForView:(UIView *)view forPoint:(CGPoint)pt;
+ (void) popupMessage: (NSString *)msg;
+ (void) addAlertNotification:(NSString *)msg;
+ (void) addAlertNotification:(NSString *)msg isImmediate:(BOOL)isImmediate;
+ (void) addGreenAlertNotification:(NSString *)msg;
+ (void) addGreenAlertNotification:(NSString *)msg isImmediate:(BOOL)isImmediate;
+ (void) addPurpleAlertNotification:(NSString *)msg isImmediate:(BOOL)isImmediate;
+ (void) addOrangeAlertNotification:(NSString *)msg isImmediate:(BOOL)isImmediate;
+ (void) addBlueAlertNotification:(NSString *)msg;
+ (void) addPrivateMessageNotification:(NSArray *)messages;

+ (void) bounceView:(UIView *)view;
+ (void) bounceView:(UIView *)view fromScale:(float)fScale toScale:(float)tScale duration:(float)duration;
+ (void) bounceView:(UIView *)view fadeInBgdView: (UIView *)bgdView;
+ (void) bounceView:(UIView *)view fadeInBgdView:(UIView *)bgdView anchorPoint:(CGPoint)anchorPoint;
+ (void) bounceView:(UIView *)view fadeInBgdView:(UIView *)bgdView anchorPoint:(CGPoint)anchorPoint completion:(void (^)(BOOL))completed;
+ (void) bounceView:(UIView *)view fadeInBgdView:(UIView *)bgdView completion:(void (^)(BOOL))completed;
+ (void) popOutView:(UIView *)view fadeOutBgdView:(UIView *)bgdView completion:(void (^)(void))completed;
+ (void) shrinkView:(UIView *)view fadeOutBgdView:(UIView *)bgdView completion:(void (^)(void))completed;
+ (UIImage *) snapShotView:(UIView *)view;
+ (UIImage *) maskImage:(UIImage *)image withColor:(UIColor *)color;
+ (UIImage *) maskImage:(UIImage *)image withAlphaCutoff:(CGFloat)alphaCutoff adjustForScreenContentScale:(BOOL)adjust;
+ (UIImage *) maskImageFromView:(UIView *)view withAlphaCutoff:(CGFloat)alphaCutoff;
+ (UIImage *) greyScaleImageWithBaseImage:(UIImage *)image;
+ (void) shakeView:(UIView *)view duration:(float)duration offset:(int)offset;
+ (void) displayUIView:(UIView *)view;
+ (CGPoint) convertPointToWindowCoordinates:(CGPoint)point fromViewCoordinates:(UIView *)view;
+ (CGPoint) convertPointFromWindowCoordinates:(CGPoint)point toViewCoordinates:(UIView *)view;
+ (void) alignSubviewsToPixelsBoundaries:(UIView*)view;
+ (void) setAnchorPoint:(CGPoint)anchorPoint onView:(UIView*)view;

+ (NSString *) urlStringForFacebookId:(NSString *)uid;

+ (BOOL) checkEnteringDungeon;
+ (BOOL) checkEnteringDungeonWithTarget:(id)target noTeamSelector:(SEL)noTeamSelector inventoryFullSelector:(SEL)inventoryFullSelector;

+ (BOOL) isSmallestiPhone;
+ (BOOL) isiPhone5orSmaller;
+ (BOOL) isiPhone6;
+ (BOOL) isiPhone6Plus;

+ (UIColor *)creamColor;
+ (UIColor *)goldColor;
+ (UIColor *)greenColor;
+ (UIColor *)orangeColor;
+ (UIColor *)redColor;
+ (UIColor *)lightRedColor;
+ (UIColor *)blueColor;
+ (UIColor *)purpleColor;
+ (UIColor *)purplishPinkColor;
+ (UIColor *)yellowColor;
+ (UIColor *)greyishTanColor;

+ (NSString *) bazaarQuestGiverName;
+ (NSString *) homeQuestGiverName;

+ (void) animateUIArrow:(UIView *)arrow atAngle:(float)angle;
+ (void) createUIArrowForView:(UIView *)view atAngle:(float)angle;
+ (void) createUIArrowForView:(UIView *)view atAngle:(float)angle inSuperview:(UIView *)sv;
+ (void) removeUIArrowFromViewRecursively:(UIView *)view;
+ (void) animateCCArrow:(CCNode *)arrow atAngle:(float)angle;

+ (void) animateStartView:(UIView *)startView toEndView:(UIView *)endView fakeStartView:(UIView *)fakeStart fakeEndView:(UIView *)fakeEnd;
+ (void) animateStartView:(UIView *)startView toEndView:(UIView *)endView fakeStartView:(UIView *)fakeStart fakeEndView:(UIView *)fakeEnd hideStartView:(BOOL)hideStartView hideEndView:(BOOL)hideEndView completion:(dispatch_block_t)completion;

- (BOOL) validateUserName:(NSString *)name;

+ (NSString *) fullNameWithName:(NSString *)name clanTag:(NSString *)tag;

- (void) openAppStoreLink;
+ (void) checkRateUsPopup;

+ (UIColor *) colorForColorProto:(ColorProto *)cp;

+ (NSString *) getRandomTipFromFile:(NSString *)file;

+ (BOOL) shouldShowFatKidDungeon;

// Formulas
- (float) convertToOverallPercentFromPercentDecrease:(float)perc;

- (int) calculateGemSpeedupCostForTimeLeft:(int)timeLeft allowFreeSpeedup:(BOOL)free;
- (int) calculateGemConversionForResourceType:(ResourceType)type amount:(int)amount;
- (int) calculateTotalResourcesForResourceType:(ResourceType)type itemIdsToQuantity:(NSDictionary *)itemIdsToQuantity;
- (int) calculateGemCostToHealTeamDuringBattle:(NSArray *)team;
- (int) calculateTeamCostForTeam:(NSArray *)team;
- (BOOL) currentBattleReadyTeamHasCostFor:(UserMonster *)um;
- (int) evoChamberLevelToEvolveMonster:(int)monsterId;

- (int) calculateSecondsToCreateBattleItem:(BattleItemProto *)bip;
- (int) calculateCostToCreateBattleItem:(BattleItemProto *)bip;

- (BOOL) isPrerequisiteComplete:(PrereqProto *)prereq;
- (NSArray *) incompletePrereqsForStructId:(int)structId;
- (BOOL) satisfiesPrereqsForStructId:(int)structId;

- (int) baseStructIdForStructId:(int)structId;
- (int) calculateMaxQuantityOfStructId:(int)structId;
- (int) calculateMaxQuantityOfStructId:(int)structId withTownHall:(TownHallProto *)thp;
- (TownHallProto *) calculateNextTownHallForQuantityIncreaseForStructId:(int)structId;
- (int) calculateNumberOfUnpurchasedStructs;
- (int) calculateCurrentQuantityOfStructId:(int)structId structs:(NSArray *)structs;

- (int) calculateNumMinutesForNewExpansion;
- (int) calculateSilverCostForNewExpansion;
- (NSString *) expansionPhraseForExpandSpot:(CGPoint)pt;

// Monster formulas
- (int) calculateTotalDamageForMonster:(UserMonster *)um;
- (int) calculateElementalDamageForMonster:(UserMonster *)um element:(Element)element;
- (int) calculateMaxHealthForMonster:(UserMonster *)um;
- (int) calculateSpeedForMonster:(UserMonster *)um;
- (int) calculateCostToHealMonster:(UserMonster *)um;
- (float) calculateBaseSecondsToHealMonster:(UserMonster *)um;
- (float) calculateDamageMultiplierForAttackElement:(Element)aElement defenseElement:(Element)dElement;

// Enhancement formulas
- (int) calculateOilCostForNewMonsterWithEnhancement:(UserEnhancement *)ue feeder:(EnhancementItem *)feeder;
- (int) calculateTotalOilCostForEnhancement:(UserEnhancement *)ue;
- (int) calculateSecondsForEnhancement:(EnhancementItem *)baseMonster feeder:(EnhancementItem *)feeder;
- (int) calculateExperienceIncrease:(UserEnhancement *)ue;
- (int) calculateExperienceIncrease:(EnhancementItem *)baseMonster feeder:(EnhancementItem *)feeder;
- (float) calculateLevelForMonster:(int)monsterId experience:(float)experience;
- (int) calculateExperienceRequiredForMonster:(int)monsterId level:(int)level;

+ (void) adjustViewForCentering:(UIView *)view withLabel:(UILabel *)label;
+ (void) adjustView:(UIView *)view withLabel:(UILabel *)label forXAnchor:(float)xAnchor;

- (InAppPurchasePackageProto *) packageForProductId:(NSString *)pid;

- (void) muteUserUuid:(NSString *)userUuid;
- (BOOL) isUserUuidMuted:(NSString *)userUuid;
- (void) unmuteAllPlayers;

+ (void) turnOnLogging;
+ (void) toggleLogging;
+ (BOOL) isLoggingEnabled;

@end

@interface CCNode (RecursiveOpacity)

- (void) recursivelyApplyOpacity:(CGFloat)opacity;
- (void) recursivelyApplyColor:(CCColor *)color;

@end

@interface RecursiveFadeTo : CCActionFadeTo

@end

@interface RecursiveTintTo : CCActionTintTo

@end

@interface NSMutableArray (ShufflingAndCloning)

- (void) shuffle;
- (id) clone;
- (NSArray *)reversedArray;

@end

@interface CCActionEaseRate (BaseRate)

- (CCActionInterval *) initWithAction:(CCActionInterval *)action;

@end

@interface CCNode (UIImage)

- (UIImage *) UIImage;

@end

@interface PBArray (NSArrayCreation)

- (NSArray *) toNSArray;

@end
