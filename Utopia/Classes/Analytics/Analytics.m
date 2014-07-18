//
//  Analytics.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/7/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "Analytics.h"
//#import "Apsalar.h"
#import "Globals.h"
#import "GameState.h"
#import <StoreKit/StoreKit.h>
//#import "Crittercism.h"
#import "Amplitude.h"
#import "TutorialController.h"

#import <MobileAppTracker/MobileAppTracker.h>
#import <Adjust.h>
#import "ScopelyAttributionWrapper.h"
#import <WithBuddiesAnalytics/WithBuddiesAnalytics.h>
#import <AdSupport/AdSupport.h>

#define MAT_ADVERTISER_ID    @"21754"
#define MAT_APP_KEY          @"f2f5c8b9c43496e4e0f988fa9f8827f4"
#define MAT_VERSION_KEY      @"MATVersionKey"

#define AMPLITUDE_KEY        @"4a7dcc75209c734285e4eae85142936b"

#ifdef MOBSTERS
#define TITAN_CLASS [WBAnalyticService class]
#define TITAN_API_KEY @"08db55ae-2d33-4de8-8dd3-18c07a350f8a"
#define ADJUST_APP_TOKEN     @"stfgmupd2vmn"
#define ADJUST_TRACKED_PROPS @"AdjustTrackedProps"
#else
#define TITAN_CLASS nil
#define TITAN_API_KEY nil
#define ADJUST_APP_TOKEN     @"53jsdw73785p"
#endif
#define AMPLITUDE_CLASS [Amplitude class]

#define S(a) [@(a) stringValue]

@implementation Analytics

static Class titanClass = nil;
static Class amplitudeClass = nil;

+ (void) setUpMobileAppTracker {
#ifdef MOBSTERS
  [ScopelyAttributionWrapper mat_initWithIFAEnabled:YES];
  [ScopelyAttributionWrapper mat_startSession];
#else
  [MobileAppTracker initializeWithMATAdvertiserId:MAT_ADVERTISER_ID
                                 MATConversionKey:MAT_APP_KEY];
  
  // Used to pass us the IFA, enabling highly accurate 1-to-1 attribution.
  // Required for many advertising networks.
  [MobileAppTracker setAppleAdvertisingIdentifier:[[ASIdentifierManager sharedManager] advertisingIdentifier]
                       advertisingTrackingEnabled:[[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]];
#endif
}

+ (void) setUpAdjust {
#ifdef DEBUG
  BOOL sandbox = YES;
#else
  BOOL sandbox = NO;
#endif
  
#ifdef MOBSTERS
  [ScopelyAttributionWrapper adjust_initWithApptoken:ADJUST_APP_TOKEN usingSandboxMode:sandbox];
  
  CFStringRef ver = CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey);
  [ScopelyAttributionWrapper adjust_customVersion:(__bridge NSString *)ver];
  
  [ScopelyAttributionWrapper adjust_trackEvent:@"jqrk7y"];
#else
  setAdjustAttributes(sandbox);
  [Adjust appDidLaunch:ADJUST_APP_TOKEN];
  [Adjust setLogLevel:AILogLevelInfo];
  [Adjust setEnvironment:sandbox ? AIEnvironmentSandbox : AIEnvironmentProduction];
#endif
}

+ (void) setupAmplitude {
  [amplitudeClass initializeApiKey:AMPLITUDE_KEY];
  [amplitudeClass setUserProperties:[ScopelyAttributionWrapper adjustEventParams]];
}

+ (void) setupTitan {
  [titanClass initializeWithApplicationKey:TITAN_API_KEY];
}

+ (void) initAnalytics {
  titanClass = TITAN_CLASS;
  amplitudeClass = AMPLITUDE_CLASS;
  
  [self setUpMobileAppTracker];
  [self setUpAdjust];
  [self setupAmplitude];
  [self setupTitan];
}

+ (void) event:(NSString *)event {
  [self event:event withArgs:nil];
}

+ (void) event:(NSString *)event withArgs:(NSDictionary *)args {
  [self event:event withArgs:args sendToTitan:NO];
}

+ (void) event:(NSString *)event withArgs:(NSDictionary *)args sendToTitan:(BOOL)toTitan {
  LNLog(@"Logging event %@ with args: %@", event, args);
  [amplitudeClass logEvent:event withEventProperties:args];
  
  if (toTitan) {
    if (!args) {
      args = [NSDictionary dictionary];
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:args];
    [dict setObject:event forKey:@"event"];
    
    [titanClass trackEvent:event type:WBAnalyticEventTypeGame parameters:args];
  }
}

+ (void) logRevenue:(NSNumber *)num {
  [amplitudeClass logRevenue:num];
}

#pragma mark - Tutorial stuff

+ (void) equipTutorialStep:(int)tutorialStep {
  [Analytics event:@"equip_tut_step" withArgs:@{@"step_num": @(tutorialStep)}];
}

+ (void) tutorialFbPopup {
  [Analytics event:@"tut_fb_popup"];
}

+ (void) tutorialFbPopupConnect {
  [Analytics event:@"tut_fb_popup_cnct"];
}

+ (void) tutorialFbPopupConnectSuccess {
  [Analytics event:@"tut_fb_popup_cnct_success"];
}

+ (void) tutorialFbPopupConnectFail {
  [Analytics event:@"tut_fb_popup_cnct_fail"];
}

+ (void) tutorialFbPopupConnectSkip {
  [Analytics event:@"tut_fb_popup_skip"];
}

+ (void) tutorialFbConfirmConnect {
  [Analytics event:@"tut_fb_cnfrm_cnct"];
}

+ (void) tutorialFbConfirmConnectSuccess {
  [Analytics event:@"tut_fb_cnfrm_cnct_success"];
}

+ (void) tutorialFbConfirmConnectFail {
  [Analytics event:@"tut_fb_cnfrm_cnct_fail"];
}

+ (void) tutorialFbConfirmSkip {
  [Analytics event:@"tut_fb_cnfrm_skip"];
}

+ (void) tutorialWaitingOnUserCreate {
  [Analytics event:@"tut_wait_for_user_create"];
}

+ (void) tutorialComplete {
  [ScopelyAttributionWrapper mat_tutorialComplete];
  [Analytics event:@"tut_complete"];
}

#pragma mark - Attribution stuff

+ (void) setUserId:(int)userId name:(NSString *)name email:(NSString *)email {
  NSString *uid = [NSString stringWithFormat:@"%d", userId];
  [ScopelyAttributionWrapper mat_setUserInfoForUserId:uid withNameUser:name withEmail:email];
  [ScopelyAttributionWrapper adjust_setUserId:uid];
  [ScopelyAttributionWrapper adjust_trackEvent:@"w0uwrh"];
  
  [Amplitude setUserId:uid];
  
  // At this point startup has completed
}

+ (void) newAccountCreated {
  [ScopelyAttributionWrapper mat_newAccountCreated];
}

+ (void) appOpen:(int)numTimesOpened {
  if (numTimesOpened == 2) {
    [ScopelyAttributionWrapper mat_appOpen_002];
  } else if (numTimesOpened == 20) {
    [ScopelyAttributionWrapper mat_appOpen_020];
  }
}

#pragma mark - Titan Standard Logs

static NSString *installTimeDefaultsKey = @"InstallTimeKey";

+ (void) checkInstall {
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
  NSDate *installTime = [def objectForKey:installTimeDefaultsKey];
  
  if (!installTime) {
    [Analytics event:@"install"];
    [titanClass trackEvent:@"install" type:WBAnalyticEventTypeGame parameters:nil];
    [def setObject:[NSDate date] forKey:installTimeDefaultsKey];
  }
}

static NSDate *timeSinceLastTutStep = nil;

+ (void) tutorialStep:(int)tutorialStep {
  NSDate *now = [NSDate date];
  double duration = ABS([timeSinceLastTutStep timeIntervalSinceDate:now]);
  timeSinceLastTutStep = now;
  
  BOOL isComplete = tutorialStep == TutorialStepComplete;
  
  [Analytics event:@"tut_step" withArgs:@{@"step_num": @(tutorialStep),
                                          @"duration": @(duration),
                                          @"is_complete:": @(isComplete)}];
  
  [titanClass trackFteFlow:tutorialStep isComplete:isComplete skip:NO duration:duration extraParams:nil];
}

+ (void) levelUpWithPrevLevel:(int)prevLevel curLevel:(int)curLevel {
  [Analytics event:@"level_up" withArgs:@{@"prev_level": @(prevLevel),
                                          @"cur_level": @(curLevel)}];
  
  [titanClass trackLevelUp:S(prevLevel) newLevel:S(curLevel) extraParams:nil];
}

+ (void) connectedToFacebookWithData:(NSDictionary *)fbData {
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  NSString *firstName = fbData[@"first_name"];
  NSString *lastName = fbData[@"last_name"];
  NSString *gender = fbData[@"gender"];
  NSString *birthday = fbData[@"birthday"];
  
  if (gender) dict[@"gender"] = gender;
  
  [titanClass trackSocialConnect:@"Facebook" firstName:firstName lastName:lastName birthDate:birthday extraParams:dict];
  
  if (firstName) dict[@"first_name"] = firstName;
  if (lastName) dict[@"last_name"] = lastName;
  if (birthday) dict[@"birthday"] = birthday;
  
  [Analytics event:@"fb_connect" withArgs:dict];
}

+ (void) inviteFacebook {
  [ScopelyAttributionWrapper mat_inviteFacebook];
  
  [Analytics event:@"fb_invite"];
  
  [titanClass trackViral:@"FacebookInvite" extraParams:nil];
}

+ (void) redeemedAchievement:(int)achievementId {
  [Analytics event:@"achievement" withArgs:@{@"achievement_id": @(achievementId)}];
  
  [titanClass trackAchievement:S(achievementId) extraParams:nil];
}

+ (void) iapWithSKProduct:(SKProduct *)product forTransacton:(SKPaymentTransaction *)transaction amountUS:(float)amountUS {
  if (!product) return;
  [ScopelyAttributionWrapper mat_iapWithSKProduct:product forTransacton:transaction];
  
  NSString* currencyCode = [product.priceLocale objectForKey:NSLocaleCurrencyCode];
  float unitPrice = [product.price floatValue];
  
  [Analytics event:@"iap_purchased" withArgs:@{@"amount_us": @(amountUS),
                                               @"amount_local": @(unitPrice),
                                               @"local_cur_code": currencyCode,
                                               @"store_sku": product.productIdentifier}];
  
  [Analytics logRevenue:@(amountUS)];
  
  [titanClass trackPayment:YES error:nil amountLocal:@(unitPrice) amountUS:@(amountUS) localCurrencyName:currencyCode special:nil specialId:nil storeSku:product.productIdentifier gameSku:nil extraParams:nil];
}

+ (void) iapFailedWithSKProduct:(SKProduct *)product error:(NSString *)error {
  if (!product) return;
  
  [Analytics event:@"iap_failed" withArgs:@{@"reason": error, @"store_sku": product.productIdentifier}];
  
  NSString* currencyCode = [product.priceLocale objectForKey:NSLocaleCurrencyCode];
  float unitPrice = [product.price floatValue];
  
  [titanClass trackPayment:NO error:error amountLocal:@(unitPrice) amountUS:@0 localCurrencyName:currencyCode special:nil specialId:nil storeSku:product.productIdentifier gameSku:nil extraParams:nil];
}

#pragma mark - Titan Game Specific Logs

+ (void) foundMatch:(NSString *)action {
  [self event:@"find_match" withArgs:@{@"type": action} sendToTitan:YES];
}

+ (void) openChat {
  [self event:@"open_chat" withArgs:nil sendToTitan:YES];
}

+ (void) createSquad:(NSString *)squadName {
  [self event:@"create_squad" withArgs:@{@"squad_name": squadName} sendToTitan:YES];
}

+ (void) joinSquad:(NSString *)squadName isRequestType:(BOOL)isRequestType {
  [self event:@"join_squad" withArgs:@{@"squad_name": squadName,
                                       @"type": isRequestType ? @"request" : @"free_to_join"} sendToTitan:YES];
}

+ (void) pveMatchEnd:(BOOL)won numEnemiesDefeated:(int)enemiesDefeated type:(NSString *)type mobsterIdsUsed:(NSArray *)mobsterIdsUsed numPiecesGained:(int)numPieces mobsterIdsGained:(NSArray *)mobsterIdsGained totalRounds:(int)totalRounds dungeonId:(int)dungeonId numContinues:(int)numContinues outcome:(NSString *)outcome {
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  dict[@"win"] = @(won);
  dict[@"enemies_defeated"] = @(enemiesDefeated);
  dict[@"type"] = type;
  dict[@"mobster_ids_used"] = mobsterIdsUsed;
  dict[@"num_pieces_gained"] = @(numPieces);
  dict[@"mobster_ids_gained"] = mobsterIdsGained;
  dict[@"rounds"] = @(totalRounds);
  dict[@"dungeon_id"] = @(dungeonId);
  dict[@"continue"] = @(numContinues);
  dict[@"outcome"] = outcome;
  
  [self event:@"pve_match_end" withArgs:dict sendToTitan:YES];
}

+ (void) pvpMatchEnd:(BOOL)won numEnemiesDefeated:(int)enemiesDefeated mobsterIdsUsed:(NSArray *)mobsterIdsUsed totalRounds:(int)totalRounds elo:(int)elo oppElo:(int)oppElo oppId:(int)oppId numContinues:(int)numContinues outcome:(NSString *)outcome league:(NSString *)league {
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  dict[@"win"] = @(won);
  dict[@"enemies_defeated"] = @(enemiesDefeated);
  dict[@"type"] = @"PVP";
  dict[@"mobster_ids_used"] = mobsterIdsUsed;
  dict[@"rounds"] = @(totalRounds);
  dict[@"elo"] = @(elo);
  dict[@"opp_elo"] = @(oppElo);
  dict[@"opp_id"] = @(oppId);
  dict[@"continue"] = @(numContinues);
  dict[@"outcome"] = outcome;
  dict[@"league"] = league;
  
  [self event:@"pvp_match_end" withArgs:dict sendToTitan:YES];
}

@end
