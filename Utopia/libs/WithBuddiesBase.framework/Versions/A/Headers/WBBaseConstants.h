//
//  WBConstants.h
//  WithBuddiesBase
//
//  Created by odyth on 9/23/13.
//  Copyright (c) 2013 scopely. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef TEST
#define WBAssert(condition, desc, ...)
#else
#define WBAssert(condition, desc, ...) NSAssert(condition, desc, ##__VA_ARGS__)
#endif

#define DO_PRAGMA(x) _Pragma (#x)
#ifdef DEBUG
#define CoreWarning(s) DO_PRAGMA(message ("message " #s))
#else
#define CoreWarning(s) DO_PRAGMA(message ("message " #s)) ______
#endif

#define DegreesToRadians(angle)   ((angle) / 180.0 * M_PI)
#define RadiansToDegress(radians) ((radians) * (180.0 / M_PI))
#define ColorValue(rgb) (float)rgb/255.0f
#define Color(r,g,b,a) [UIColor colorWithRed:ColorValue(r) green:ColorValue(g) blue:ColorValue(b) alpha:a]

#define WBLocalizedErrorWithComment(key, defaultValue, comment) \
[[NSBundle mainBundle] localizedStringForKey:(key) value:(defaultValue) table:@"Errors"]

#define WBLocalizedError(key, defaultValue) \
[[NSBundle mainBundle] localizedStringForKey:(key) value:(defaultValue) table:@"Errors"]

#define WBLocalizedString(key, defaultValue, comment) \
[[NSBundle mainBundle] localizedStringForKey:(key) value:(defaultValue) table:nil]

#define CHARACTERS          @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
#define CHARACTERS_NUMBERS  [CHARACTERS stringByAppendingString:@"1234567890"]

#define REQUEST_MODE requestMode:(WBRequestMode)requestMode

extern NSString *const WBBaseSDKDomain;

extern const int WBPlatform;

//Settings keys
extern NSString *const WBSettingMaintenanceEndpoint;
extern NSString *const WBSettingCurrencyName;
extern NSString *const WBSettingCurrencyNameSingular;
extern NSString *const WBSettingInviteHeader;
extern NSString *const WBSettingFacebookClientToken;
extern NSString *const WBSettingFacebookDisplayName;
extern NSString *const WBSettingFacebookAppId;
extern NSString *const WBSettingTutorialTypeForNewGameMenu;
extern NSString *const WBSettingPaidAppStoreUrl;
extern NSString *const WBSettingLatePushNotificationRegistrationType;
extern NSString *const WBSettingAppNameDisplay;
extern NSString *const WBSettingAppNameShort;
extern NSString *const WBSettingAppIdentifier;
extern NSString *const WBSettingHasAchievements;
extern NSString *const WBSettingLocalPlayDisabled;
extern NSString *const WBSettingSinglePlayerEnabled;
extern NSString *const WBSettingRemoveAdsIapSku;
extern NSString *const WBSettingDelayLogin;
extern NSString *const WBSettingTutorialDisabled;
extern NSString *const WBSettingNUFDisabled;
extern NSString *const WBSettingPhantomGamesEnabled;
extern NSString *const WBSettingFreeTournamentCommodityKey;
extern NSString *const WBSettingLoginVersion;
extern NSString *const WBSettingMainMenuInventory;
extern NSString *const WBSettingStatsResetEnabled;

//server zones
extern NSString *const WBServerZoneGameProductionKey;
extern NSString *const WBServerZoneUserProductionKey;
extern NSString *const WBServerZoneBatchProduction;
extern NSString *const WBServerZoneStagingKey;
extern NSString *const WBServerZoneDevelopKey;

//bundle settings
extern NSString *const WBBundleSettingFBUrlSuffix;
extern NSString *const WBBundleSettingAppName;
extern NSString *const WBBundleSettingAppBundle;
extern NSString *const WBBundleSettingAppBundleEnum;
extern NSString *const WBBundleSettingAppId;
extern NSString *const WBBundleSettingAppStoreUrl;
extern NSString *const WBBundleSettingAppVersion;
extern NSString *const WBBundleSettingBundleVersion;
extern NSString *const WBBundleSettingBundleIdentifier;
extern NSString *const WBBundleSettingBuildNumber;
extern NSString *const WBBundleSettingBundleDisplayName;
