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

#define BUTTON_CLICKED_LEEWAY 30

#define LNLog(...) CCLOG(__VA_ARGS__)

#define FULL_SCREEN_APPEAR_ANIMATION_DURATION 0.4f
#define FULL_SCREEN_DISAPPEAR_ANIMATION_DURATION 0.7f

#define IAP_DEFAULTS_KEY @"Unresponded In Apps"

#define MUSIC_DEFAULTS_KEY @"MusicDefaultsKey"
#define SOUND_EFFECTS_DEFAULTS_KEY @"SoundEffectsDefaultsKey"
#define SHAKE_DEFAULTS_KEY @"ShakeDefaultsKey"

#define IAP_SUCCESS_NOTIFICATION @"IapSuccessNotification"
#define HEAL_WAIT_COMPLETE_NOTIFICATION @"HealWaitCompleteNotification"
#define MONSTER_QUEUE_CHANGED_NOTIFICATION @"MonsterQueueChangedNotification"
#define ENHANCE_WAIT_COMPLETE_NOTIFICATION @"EnhanceWaitCompleteNotification"
#define EVOLUTION_WAIT_COMPLETE_NOTIFICATION @"EvolutionWaitCompleteNotification"
#define COMBINE_WAIT_COMPLETE_NOTIFICATION @"CombineWaitCompleteNotification"
#define MONSTER_SOLD_COMPLETE_NOTIFICATION @"MonsterSoldNotification"
#define GAMESTATE_UPDATE_NOTIFICATION @"GameStateUpdateNotification"
#define MY_TEAM_CHANGED_NOTIFICATION @"MyTeamChangedNotification"
#define CHAT_RECEIVED_NOTIFICATION @"ChatReceivedNotification"
#define NEW_FB_INVITE_NOTIFICATION @"NewFbInviteNotification"
#define FB_INVITE_RESPONDED_NOTIFICATION @"FbInviteRespondedNotification"
#define FB_INVITE_ACCEPTED_NOTIFICATION @"FbInviteAcceptedNotification"
#define FB_INCREASE_SLOTS_NOTIFICATION @"FbIncreaseSlotsNotification"
#define QUESTS_CHANGED_NOTIFICATION @"QuestsChangedNotification"
#define MY_CLAN_MEMBERS_LIST_NOTIFICATION @"MyClanMembersListNotification"
#define CLAN_RAID_ATTACK_NOTIFICATION @"ClanRaidAttackNotification"
#define NEW_OBSTACLES_CREATED_NOTIFICATION @"NewObstaclesCreatedNotification"

#define MY_CLAN_MEMBERS_LIST_KEY @"MyMembersList"
#define CLAN_RAID_ATTACK_KEY @"ClanRaidAttackKey"


#ifdef LEGENDS_OF_CHAOS
#define GAME_NAME @"Legends of Chaos"
#define GAME_ABBREV @"LoC"
#else
#define GAME_NAME @"Mob Squad"
#define GAME_ABBREV @"MS"
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

// Norm struct constants
@property (nonatomic, assign) int maxRepeatedNormStructs;

// Clan constants
@property (nonatomic, assign) int coinPriceToCreateClan;
@property (nonatomic, assign) int maxCharLengthForClanName;
@property (nonatomic, assign) int maxCharLengthForClanDescription;
@property (nonatomic, assign) int maxCharLengthForClanTag;

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
+ (NSString *) convertTimeToLongString:(int)secs;

+ (void) downloadAllFilesForSpritePrefixes:(NSArray *)spritePrefixes completion:(void (^)(void))completed;

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

+ (UIColor *) colorForRarity:(MonsterProto_MonsterQuality)rarity;
+ (NSString *) stringForRarity:(MonsterProto_MonsterQuality)rarity;
+ (NSString *) shortenedStringForRarity:(MonsterProto_MonsterQuality)rarity;
+ (NSString *) imageNameForRarity:(MonsterProto_MonsterQuality)rarity suffix:(NSString *)str;
+ (NSString *) stringForElement:(MonsterProto_MonsterElement)element;
+ (NSString *) imageNameForElement:(MonsterProto_MonsterElement)element suffix:(NSString *)str;
+ (UIColor *) colorForElementOnDarkBackground:(MonsterProto_MonsterElement)element;
+ (UIColor *) colorForElementOnLightBackground:(MonsterProto_MonsterElement)element;

+ (MonsterProto_MonsterElement) elementForSuperEffective:(MonsterProto_MonsterElement)element;
+ (MonsterProto_MonsterElement) elementForNotVeryEffective:(MonsterProto_MonsterElement)element;

+ (NSString *) stringForTimeSinceNow:(MSDate *)date shortened:(BOOL)shortened ;

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
+ (NSString *) commafyNumber:(float) n;

+ (void) calculateDifferencesBetweenOldArray:(NSArray *)oArr newArray:(NSArray *)nArr removalIps:(NSMutableArray *)removals additionIps:(NSMutableArray *)additions section:(int)section;

+ (void) setFrameForView:(UIView *)view forPoint:(CGPoint)pt;
+ (void) popupMessage: (NSString *)msg;
+ (void) addAlertNotification:(NSString *)msg;

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

+ (BOOL) checkEnteringDungeonWithTarget:(id)target selector:(SEL)selector;

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

- (BOOL) validateUserName:(NSString *)name;

+ (NSString *) fullNameWithName:(NSString *)name clanTag:(NSString *)tag;

- (void) openAppStoreLink;
+ (void) checkRateUsPopup;

+ (UIColor *) colorForColorProto:(ColorProto *)cp;

+ (BOOL) userHasBeginnerShield:(uint64_t)createTime hasActiveShield:(BOOL)hasActiveShield;

+(NSString*) getDoubleResolutionImage:(NSString*)path;

// Formulas
- (int) calculateGemSpeedupCostForTimeLeft:(int)timeLeft;
- (int) calculateGemConversionForResourceType:(ResourceType)type amount:(int)amount;
- (int) calculateGemCostToHealTeamDuringBattle:(NSArray *)team;

- (int) calculateMaxQuantityOfStructId:(int)structId withTownHall:(TownHallProto *)thp;
- (int) calculateNextTownHallLevelForQuantityIncreaseForStructId:(int)structId;
- (int) calculateCurrentQuantityOfStructId:(int)structId structs:(NSArray *)structs;

- (int) calculateNumMinutesForNewExpansion;
- (int) calculateSilverCostForNewExpansion;
- (NSString *) expansionPhraseForExpandSpot:(CGPoint)pt;

// Monster formulas
- (int) calculateTotalDamageForMonster:(UserMonster *)um;
- (int) calculateElementalDamageForMonster:(UserMonster *)um element:(MonsterProto_MonsterElement)element;
- (int) calculateMaxHealthForMonster:(UserMonster *)um;
- (int) calculateCostToHealMonster:(UserMonster *)um;
- (float) calculateDamageMultiplierForAttackElement:(MonsterProto_MonsterElement)aElement defenseElement:(MonsterProto_MonsterElement)dElement;

// Enhancement formulas
- (int) calculateOilCostForEnhancement:(EnhancementItem *)baseMonster feeder:(EnhancementItem *)feeder;
- (int) calculateSecondsForEnhancement:(EnhancementItem *)baseMonster feeder:(EnhancementItem *)feeder;
- (int) calculateTimeLeftForEnhancement:(UserEnhancement *)ue;
- (int) calculateExperienceIncrease:(UserEnhancement *)ue;
- (int) calculateExperienceIncrease:(EnhancementItem *)baseMonster feeder:(EnhancementItem *)feeder;
- (float) calculateLevelForMonster:(int)monsterId experience:(int)experience;

+ (void) adjustViewForCentering:(UIView *)view withLabel:(UILabel *)label;
+ (void) adjustView:(UIView *)view withLabel:(UILabel *)label forXAnchor:(float)xAnchor;

- (InAppPurchasePackageProto *) packageForProductId:(NSString *)pid;

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
