//
//  ScopelyAttributionWrapper.h
//  ScopelyAttributionWrapper
//
//  Created by Yuri Visser @ Scopely on 2014-06-05.
//  Copyright (c) 2014 Scopely. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface ScopelyAttributionWrapper : NSObject

// --- MAT --- >>>
/**
 Init MAT with default Scopely Advertiser ID & Conversion Key - should be called from didFinishLaunching or didFinishLaunchingWithOptions
 @param useIFA
 If IDFA should be enabled
 */
+(void) mat_initWithIFAEnabled : (Boolean)useIFA;

/**
 Init MAT with default Scopely Advertiser ID & Conversion Key - should be called from didFinishLaunching or didFinishLaunchingWithOptions
 @param advertiserId
 Provide advertiser id
 @param conversionKey
 Provide conversion key
 @param useIFA
 If IDFA should be enabled
 */
+(void) mat_initWithAdvertiserId : (NSString*)advertiserId andConversionKey:(NSString*)conversionKey enableIFA:(Boolean)useIFA;

+(void) mat_startSession;

/**
 Set a custom MAT user id, name and email
 @param userId
 Id of user
 @param userName
 Username
 @param userEmail
 User's email
 */
+(void) mat_setUserInfoForUserId : (NSString*)userId withNameUser:(NSString*)userName withEmail:(NSString*)userEmail;

/**
 Fire new_account_created MAT event
 */
+(void) mat_newAccountCreated;

/**
 Fire tutorial_complete MAT event
 */
+(void) mat_tutorialComplete;

/**
 Fire app_opens_002 MAT event
 */
+(void) mat_appOpen_002;

/**
 Fire app_opens_020 MAT event
 */
+(void) mat_appOpen_020;

/**
 Fire invites_fb MAT event
 */
+(void) mat_inviteFacebook;

/**
 Fire invites_sms MAT event
 */
+(void) mat_inviteSms;

/**
 Fire IAP MAT event
 */
+(void) mat_iapWithSKProduct : (SKProduct*)product forTransacton:(SKPaymentTransaction*)transaction;

+(void) mat_iapWithProdcutName : (NSString*)productName productId:(NSString*)prodId productPrice:(float)prodPrice purchasedQuantity:(int)qty revenueAmount:(float)revAmount currencyCode:(NSString*)currency;
// --- MAT --- <<<


// --- Adjust --- >>>
+(NSMutableDictionary*) adjustEventParams;

/**
 Init Adjust wtih provided app token
 @param appToken
 Scopely provided app token
 @param useSandbox
 To use sandob or production environment
 */
+(void) adjust_initWithApptoken : (NSString *)appToken usingSandboxMode:(bool)useSandbox;

/**
 Set a custom user id for Adjust
 @param userId
 User's id
 */
+(void) adjust_setUserId : (NSString*)userId;

/**
 Set a custom app version for Adjust
 @param customVersion
 Custom app version
 */
+(void) adjust_customVersion:(NSString *)customVersion;

/**
 Track an event (SetProps or SetUserID with Scopely provided event tokens)
 @param eventToken
 Token of event tro track
 */
+(void) adjust_trackEvent : (NSString*)eventToken;
// --- Adjust --- <<<

void setAdjustAttributes(bool useSandbox);
    
@end
