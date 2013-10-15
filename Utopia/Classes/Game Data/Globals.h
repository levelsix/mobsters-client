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

#define BUTTON_CLICKED_LEEWAY 30

#define LNLog(...) CCLOG(__VA_ARGS__)

#define FULL_SCREEN_APPEAR_ANIMATION_DURATION 0.4f
#define FULL_SCREEN_DISAPPEAR_ANIMATION_DURATION 0.7f

#define IAP_DEFAULTS_KEY @"Unresponded In Apps"

#define MUSIC_DEFAULTS_KEY @"MusicDefaultsKey"
#define SOUND_EFFECTS_DEFAULTS_KEY @"SoundEffectsDefaultsKey"
#define SHAKE_DEFAULTS_KEY @"ShakeDefaultsKey"

#define IAP_SUCCESS_NOTIFICATION @"IapSuccessNotification"

#ifdef LEGENDS_OF_CHAOS
#define GAME_NAME @"Legends of Chaos"
#define GAME_ABBREV @"LoC"
#else
#define GAME_NAME @"Age of Chaos"
#define GAME_ABBREV @"AoC"
#endif

#define POINT_OFFSET_PER_SCENE ccp(512,360)

@interface Globals : NSObject

@property (nonatomic, assign) int minNameLength;
@property (nonatomic, assign) int maxNameLength;

@property (nonatomic, assign) float maxLevelForUser;

@property (nonatomic, assign) int maxLengthOfChatString;

@property (nonatomic, copy) NSString *reviewPageURL;
@property (nonatomic, assign) int levelToShowRateUsPopup;
@property (nonatomic, copy) NSString *reviewPageConfirmationMessage;

@property (nonatomic, assign) int fbConnectRewardDiamonds;

@property (nonatomic, retain) NSString *faqFileName;

@property (nonatomic, retain) MinimumUserProto *adminChatUser;

@property (nonatomic, assign) int numBeginnerSalesAllowed;
@property (nonatomic, assign) int defaultDaysBattleShieldIsActive;

// Norm struct constants
@property (nonatomic, assign) int maxRepeatedNormStructs;
@property (nonatomic, assign) float minutesToUpgradeForNormStructMultiplier;
@property (nonatomic, assign) float incomeFromNormStructMultiplier;
@property (nonatomic, assign) float upgradeStructCoinCostExponentBase;
@property (nonatomic, assign) float upgradeStructDiamondCostExponentBase;
@property (nonatomic, assign) float diamondCostForInstantUpgradeMultiplier;

// Clan constants
@property (nonatomic, assign) int diamondPriceToCreateClan;
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

+ (NSString *)convertTimeToString:(int)secs withDays:(BOOL)withDays;
+ (NSString *) convertTimeToShortString:(int)secs;

+ (UIImage *) imageNamed:(NSString *)path;
+ (NSString *) imageNameForConstructionWithSize:(CGSize)size;
+ (UIImage *) imageForStruct:(int)structId;
+ (NSString *) imageNameForStruct:(int)structId;
+ (NSString *) pathToFile:(NSString *)fileName;
+ (NSBundle *) bundleNamed:(NSString *)bundleName;
+ (void) asyncDownloadBundles;
+ (void) loadImageForStruct:(int)structId toView:(UIImageView *)view masked:(BOOL)mask indicator:(UIActivityIndicatorViewStyle)indicator;
+ (void) imageNamed:(NSString *)imageName withView:(UIView *)view maskedColor:(UIColor *)color indicator:(UIActivityIndicatorViewStyle)indicatorStyle clearImageDuringDownload:(BOOL)clear;
+ (void) imageNamed:(NSString *)imageName toReplaceSprite:(CCSprite *)s;

+ (UIColor *) colorForRarity:(MonsterProto_MonsterQuality)rarity;
+ (NSString *) stringForRarity:(MonsterProto_MonsterQuality)rarity;
+ (NSString *) shortenedStringForRarity:(MonsterProto_MonsterQuality)rarity;

+ (NSString *) stringForTimeSinceNow:(NSDate *)date shortened:(BOOL)shortened ;

+ (NSString *) nameForDialogueSpeaker:(DialogueProto_SpeechSegmentProto_DialogueSpeaker)speaker;
+ (NSString *) imageNameForDialogueSpeaker:(DialogueProto_SpeechSegmentProto_DialogueSpeaker)speaker;

+ (void) adjustFontSizeForSize:(int)size withUIView:(UIView *)somethingWithText;
+ (void) adjustFontSizeForSize:(int)size withUIViews:(UIView *)field1, ... NS_REQUIRES_NIL_TERMINATION;
+ (void) adjustFontSizeForUIViewWithDefaultSize:(UIView *)somethingWithText;
+ (void) adjustFontSizeForUIViewsWithDefaultSize:(UIView *)field1, ... NS_REQUIRES_NIL_TERMINATION;
+ (void) adjustFontSizeForUILabel:(UILabel *)label;
+ (void) adjustFontSizeForUILabels:(UILabel *)field1, ... NS_REQUIRES_NIL_TERMINATION;
+ (void) adjustFontSizeForCCLabelTTF:(CCLabelTTF *)label size:(int)size;
+ (void) adjustFontSizeForSize:(int)size CCLabelTTFs:(CCLabelTTF *)field1, ... NS_REQUIRES_NIL_TERMINATION;

+ (NSString *) cashStringForNumber:(int)n;
+ (NSString *) commafyNumber:(int) n;

+ (void) setFrameForView:(UIView *)view forPoint:(CGPoint)pt;
+ (void) popupMessage: (NSString *)msg;
+ (void) bounceView:(UIView *)view;
+ (void) bounceView:(UIView *)view fadeInBgdView: (UIView *)bgdView;
+ (void) bounceView:(UIView *)view fadeInBgdView:(UIView *)bgdView completion:(void (^)(BOOL))completed;
+ (void) popOutView:(UIView *)view fadeOutBgdView:(UIView *)bgdView completion:(void (^)(void))completed;
+ (UIImage*) maskImage:(UIImage *)image withColor:(UIColor *)color;
+ (void) shakeView:(UIView *)view duration:(float)duration offset:(int)offset;
+ (void) displayUIView:(UIView *)view;
+ (void) displayUIViewWithoutAdjustment:(UIView *)view;

+ (UIColor *)creamColor;
+ (UIColor *)goldColor;
+ (UIColor *)greenColor;
+ (UIColor *)orangeColor;
+ (UIColor *)redColor;
+ (UIColor *)blueColor;
+ (UIColor *)purpleColor;

+ (GameMap *) mapForQuest:(FullQuestProto *)fqp;
+ (NSString *) bazaarQuestGiverName;
+ (NSString *) homeQuestGiverName;

+ (void) animateUIArrow:(UIView *)arrow atAngle:(float)angle;
+ (void) animateCCArrow:(CCNode *)arrow atAngle:(float)angle;

- (BOOL) validateUserName:(NSString *)name;

+ (NSString *) fullNameWithName:(NSString *)name clanTag:(NSString *)tag;

+ (void) checkRateUsPopup;

+ (UIColor *) colorForColorProto:(ColorProto *)cp;

+ (BOOL) userHasBeginnerShield:(uint64_t)createTime hasActiveShield:(BOOL)hasActiveShield;

// Formulas
- (int) calculateIncomeForUserStruct:(UserStruct *)us;
- (int) calculateIncomeForUserStructAfterLevelUp:(UserStruct *)us;
- (int) calculateStructSilverSellCost:(UserStruct *)us;
- (int) calculateStructGoldSellCost:(UserStruct *)us;
- (int) calculateUpgradeCost:(UserStruct *)us;
- (int) calculateDiamondCostForInstaUpgrade:(UserStruct *)us timeLeft:(int)timeLeft;
- (int) calculateMinutesToUpgrade:(UserStruct *)us;

- (int) calculateNumMinutesForNewExpansion;
- (int) calculateGoldCostToSpeedUpExpansionTimeLeft:(int)seconds;
- (int) calculateSilverCostForNewExpansion;

// Enhancement formulas
- (float) calculatePercentOfLevel:(int)percentage;
- (int) calculateEnhancementLevel:(int)percentage;
- (int) calculateEnhancementPercentageToNextLevel:(int)percentage;
- (int) calculateEnhancementPercentageIncrease:(UserMonster *)enhancingMonster feeders:(NSArray *)feeders;
- (int) calculateEnhancementPercentageIncrease:(UserMonster *)enhancingMonster feeder:(UserMonster *)feeder;
- (int) calculateSilverCostForEnhancement:(UserMonster *)enhancingMonster feeders:(NSArray *)feeders;

+ (void) adjustViewForCentering:(UIView *)view withLabel:(UILabel *)label;

- (InAppPurchasePackageProto *) packageForProductId:(NSString *)pid;

@end

@interface CCNode (RecursiveOpacity)

- (void) recursivelyApplyOpacity:(GLubyte)opacity;

@end

@interface RecursiveFadeTo : CCFadeTo

@end

@interface NSMutableArray (Shuffling)

- (void)shuffle;

@end
