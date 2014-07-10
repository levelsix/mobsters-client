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

#define LNLog(...) NSLog(__VA_ARGS__)

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
#define ENHANCE_WAIT_COMPLETE_NOTIFICATION @"EnhanceWaitCompleteNotification"
#define ENHANCE_QUEUE_CHANGED_NOTIFICATION @"EnhanceQueueChangedNotification"
#define EVOLUTION_WAIT_COMPLETE_NOTIFICATION @"EvolutionWaitCompleteNotification"
#define EVOLUTION_CHANGED_NOTIFICATION @"EvolutionChangedNotification"
#define COMBINE_WAIT_COMPLETE_NOTIFICATION @"CombineWaitCompleteNotification"
#define MINI_JOB_WAIT_COMPLETE_NOTIFICATION @"MiniJobWaitCompleteNotification"
#define MONSTER_SOLD_COMPLETE_NOTIFICATION @"MonsterSoldNotification"
#define GAMESTATE_UPDATE_NOTIFICATION @"GameStateUpdateNotification"
#define MY_TEAM_CHANGED_NOTIFICATION @"MyTeamChangedNotification"
#define GLOBAL_CHAT_RECEIVED_NOTIFICATION @"GlobalChatReceivedNotification"
#define CLAN_CHAT_RECEIVED_NOTIFICATION @"ClanChatReceivedNotification"
#define PRIVATE_CHAT_RECEIVED_NOTIFICATION @"PrivateChatReceivedNotification"
#define PRIVATE_CHAT_VIEWED_NOTIFICATION @"PrivateChatViewedNotification"
#define CLAN_CHAT_VIEWED_NOTIFICATION @"ClanChatViewedNotification"
#define STRUCT_PURCHASED_NOTIFICATION @"StructPurchasedNotification"
#define STRUCT_COMPLETE_NOTIFICATION @"StructCompleteNotification"

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

#define MY_CLAN_MEMBERS_LIST_KEY @"MyMembersList"
#define CLAN_RAID_ATTACK_KEY @"ClanRaidAttackKey"
#define MUTED_PLAYERS_KEY @"MutedPlayersKey"

#ifdef LEGENDS_OF_CHAOS
#define GAME_NAME @"Legends of Chaos"
#define GAME_ABBREV @"LoC"
#else
#define GAME_NAME @"Toon Squad"
#define GAME_ABBREV @"TS"
#define MONSTER_NAME @"Toon"
#endif

#define POINT_OFFSET_PER_SCENE ccp(512,360)
#define SLOPE_OF_ROAD POINT_OFFSET_PER_SCENE.y/POINT_OFFSET_PER_SCENE.x

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

@property (nonatomic, assign) BOOL addAllFbFriends;

@property (nonatomic, assign) int maxObstacles;
@property (nonatomic, assign) int minutesPerObstacle;

@property (nonatomic, retain) StartupResponseProto_StartupConstants_MiniTutorialConstants *miniTutorialConstants;

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

- (void) updateInAppPurchases;
- (void) updateConstants:(StartupResponseProto_StartupConstants *)constants;

+ (NSString *) font;
+ (int) fontSize;

+ (NSString *) convertTimeToString:(int)secs withDays:(BOOL)withDays;
+ (NSString *) convertTimeToShortString:(int)secs;
+ (NSString *) convertTimeToShorterString:(int)secs;
+ (NSString *) convertTimeToLongString:(int)secs;

+ (void) downloadAllFilesForSpritePrefixes:(NSArray *)spritePrefixes completion:(void (^)(void))completed;
+ (void) downloadFile:(NSString *)file completion:(void (^)(void))completed;

+ (UIImage *) imageNamed:(NSString *)path;
+ (NSString *) imageNameForConstructionWithSize:(CGSize)size;
+ (UIImage *) imageForStruct:(int)structId;
+ (NSString *) imageNameForStruct:(int)structId;
+ (NSString *) pathToFile:(NSString *)fileName;
+ (BOOL) isFileDownloaded:(NSString *)fileName;
+ (NSBundle *) bundleNamed:(NSString *)bundleName;
+ (void) asyncDownloadBundles;
+ (void) loadImageForStruct:(int)structId toView:(UIImageView *)view masked:(BOOL)mask indicator:(UIActivityIndicatorViewStyle)indicator;
+ (void) imageNamed:(NSString *)imageName withView:(UIView *)view maskedColor:(UIColor *)color indicator:(UIActivityIndicatorViewStyle)indicatorStyle clearImageDuringDownload:(BOOL)clear;
+ (void) imageNamed:(NSString *)imageName withView:(UIView *)view greyscale:(BOOL)greyscale indicator: (UIActivityIndicatorViewStyle)indicatorStyle clearImageDuringDownload:(BOOL)clear;
+ (void) imageNamed:(NSString *)imageName toReplaceSprite:(CCSprite *)s;

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

+ (NSArray *) convertCurrentTeamToArray:(UserCurrentMonsterTeamProto *)team;
+ (NSDictionary *) convertUserTeamArrayToDictionary:(NSArray *)array;

+ (void) adjustFontSizeForSize:(int)size withUIView:(UIView *)somethingWithText;
+ (void) adjustFontSizeForSize:(int)size withUIViews:(UIView *)field1, ... NS_REQUIRES_NIL_TERMINATION;
+ (void) adjustFontSizeForUIViewWithDefaultSize:(UIView *)somethingWithText;
+ (void) adjustFontSizeForUIViewsWithDefaultSize:(UIView *)field1, ... NS_REQUIRES_NIL_TERMINATION;
+ (void) adjustFontSizeForUILabel:(UILabel *)label;
+ (void) adjustFontSizeForUILabels:(UILabel *)field1, ... NS_REQUIRES_NIL_TERMINATION;
+ (void) adjustFontSizeForCCLabelTTF:(CCLabelTTF *)label size:(int)size;
+ (void) adjustFontSizeForSize:(int)size CCLabelTTFs:(CCLabelTTF *)field1, ... NS_REQUIRES_NIL_TERMINATION;

+ (NSString *) cashStringForNumber:(int)n;
+ (NSString *) commafyNumber:(float)n;
+ (NSString *) qualifierStringForNumber:(int)rank;

+ (void) calculateDifferencesBetweenOldArray:(NSArray *)oArr newArray:(NSArray *)nArr removalIps:(NSMutableArray *)removals additionIps:(NSMutableArray *)additions section:(int)section;
+ (void) calculateDifferencesBetweenOldArray:(NSArray *)oArr newArray:(NSArray *)nArr removalIps:(NSMutableArray *)removals additionIps:(NSMutableArray *)additions movedIps:(NSMutableDictionary *)moves section:(int)section;

+ (void) setFrameForView:(UIView *)view forPoint:(CGPoint)pt;
+ (void) popupMessage: (NSString *)msg;
+ (void) addAlertNotification:(NSString *)msg;
+ (void) addGreenAlertNotification:(NSString *)msg;

+ (void) bounceView:(UIView *)view;
+ (void) bounceView:(UIView *)view fadeInBgdView: (UIView *)bgdView;
+ (void) bounceView:(UIView *)view fadeInBgdView:(UIView *)bgdView completion:(void (^)(BOOL))completed;
+ (void) popOutView:(UIView *)view fadeOutBgdView:(UIView *)bgdView completion:(void (^)(void))completed;
+ (UIImage *) snapShotView:(UIView *)view;
+ (UIImage *) maskImage:(UIImage *)image withColor:(UIColor *)color;
+ (UIImage *) greyScaleImageWithBaseImage:(UIImage *)image;
+ (void) shakeView:(UIView *)view duration:(float)duration offset:(int)offset;
+ (void) displayUIView:(UIView *)view;

+ (NSString *) urlStringForFacebookId:(NSString *)uid;

+ (BOOL) checkEnteringDungeon;
+ (BOOL) checkEnteringDungeonWithTarget:(id)target noTeamSelector:(SEL)noTeamSelector inventoryFullSelector:(SEL)inventoryFullSelector;

+ (BOOL)isLongiPhone;

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
+ (void) removeUIArrowFromViewRecursively:(UIView *)view;
+ (void) animateCCArrow:(CCNode *)arrow atAngle:(float)angle;

+ (void) animateStartView:(UIView *)startView toEndView:(UIView *)endView fakeStartView:(UIView *)fakeStart fakeEndView:(UIView *)fakeEnd;

- (BOOL) validateUserName:(NSString *)name;

+ (NSString *) fullNameWithName:(NSString *)name clanTag:(NSString *)tag;

- (void) openAppStoreLink;
+ (void) checkRateUsPopup;

+ (UIColor *) colorForColorProto:(ColorProto *)cp;

+(NSString*) getDoubleResolutionImage:(NSString*)path;

// Formulas
- (int) calculateGemSpeedupCostForTimeLeft:(int)timeLeft;
- (int) calculateGemConversionForResourceType:(ResourceType)type amount:(int)amount;
- (int) calculateGemCostToHealTeamDuringBattle:(NSArray *)team;

- (int) calculateMaxQuantityOfStructId:(int)structId withTownHall:(TownHallProto *)thp;
- (int) calculateNextTownHallLevelForQuantityIncreaseForStructId:(int)structId;
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
- (float) calculateDamageMultiplierForAttackElement:(Element)aElement defenseElement:(Element)dElement;

// Enhancement formulas
- (int) calculateOilCostForEnhancement:(UserEnhancement *)ue feeder:(EnhancementItem *)feeder;
- (int) calculateSecondsForEnhancement:(EnhancementItem *)baseMonster feeder:(EnhancementItem *)feeder;
- (int) calculateTimeLeftForEnhancement:(UserEnhancement *)ue;
- (int) calculateExperienceIncrease:(UserEnhancement *)ue;
- (int) calculateExperienceIncrease:(EnhancementItem *)baseMonster feeder:(EnhancementItem *)feeder;
- (float) calculateLevelForMonster:(int)monsterId experience:(float)experience;
- (int) calculateExperienceRequiredForMonster:(int)monsterId level:(int)level;

+ (void) adjustViewForCentering:(UIView *)view withLabel:(UILabel *)label;
+ (void) adjustView:(UIView *)view withLabel:(UILabel *)label forXAnchor:(float)xAnchor;

- (InAppPurchasePackageProto *) packageForProductId:(NSString *)pid;

- (void) muteUserId:(int)userId;
- (BOOL) isUserIdMuted:(int)userId;
- (void) unmuteAllPlayers;

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
