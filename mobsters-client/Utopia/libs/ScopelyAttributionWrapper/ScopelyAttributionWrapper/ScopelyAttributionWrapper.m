//
//  ScopelyAttributionWrapper.m
//  ScopelyAttributionWrapper
//
//  Created by Yuri Visser @ Scopely on 2014-06-05.
//  Copyright (c) 2014 Scopely. All rights reserved.
//

#import "ScopelyAttributionWrapper.h"
#import <MobileAppTracker/MobileAppTracker.h>
#import <AdSupport/AdSupport.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "Adjust.h"
#import <StoreKit/StoreKit.h>

@implementation ScopelyAttributionWrapper

//#########################################################################
// --- MAT --- >>>
static NSString* ADVERTISER_ID = @"1835";
static NSString* CONVERSION_KEY = @"c0fcfa638c9984a2c18ee4af12617857";

+(void) mat_initWithIFAEnabled : (Boolean)useIFA
{
    [ScopelyAttributionWrapper mat_initWithAdvertiserId:ADVERTISER_ID andConversionKey:CONVERSION_KEY enableIFA:useIFA];
}

+(void) mat_initWithAdvertiserId : (NSString*)advertiserId andConversionKey:(NSString*)conversionKey enableIFA:(Boolean)useIFA
{
//    [MobileAppTracker setDelegate:self];
    
    //TODO - set NO for production
#ifdef DEBUG
    [MobileAppTracker setDebugMode:NO];
    //[MobileAppTracker setAllowDuplicateRequests:YES];
#else
    [MobileAppTracker setDebugMode:NO];
#endif
    
    //initialize with advertiser id & conversion key
    [MobileAppTracker initializeWithMATAdvertiserId:advertiserId
                                   MATConversionKey:conversionKey];
    
    [MobileAppTracker setAppleAdvertisingIdentifier:[[ASIdentifierManager sharedManager] advertisingIdentifier]
                          advertisingTrackingEnabled:useIFA];
    
    [MobileAppTracker setShouldAutoGenerateAppleVendorIdentifier:useIFA];
}

/**
 Use to explicitly track sessions
 */
+(void) mat_startSession
{
    [MobileAppTracker measureSession];
}

+(void) mat_setUserInfoForUserId : (NSString*)userId withNameUser:(NSString*)userName withEmail:(NSString*)userEmail
{
    [MobileAppTracker setUserId:userId];
    [MobileAppTracker setUserName:userName];
    [MobileAppTracker setUserEmail:userEmail];
}

+(void) mat_newAccountCreated
{
    [MobileAppTracker measureAction:@"new_account_created"];
}

+(void) mat_tutorialComplete
{
    [MobileAppTracker measureAction:@"tutorial_complete"];
}

+(void) mat_appOpen_002
{
    [MobileAppTracker measureAction:@"app_opens_002"];
}

+(void) mat_appOpen_020
{
    [MobileAppTracker measureAction:@"app_opens_020"];
}

+(void) mat_inviteFacebook
{
    [MobileAppTracker measureAction:@"invites_fb"];
}

+(void) mat_inviteSms
{
    [MobileAppTracker measureAction:@"invites_sms"];
}

+(void) mat_iapWithSKProduct : (SKProduct*)product forTransacton:(SKPaymentTransaction*)transaction
{
    // default tracking event name
    NSString *eventName = @"IAP";
    
    // assign the currency code extracted from the transaction
    NSString* currencyCode = [product.priceLocale objectForKey:NSLocaleCurrencyCode];
    
    if(nil != product)
    {
        // extract transaction product quantity
        int quantity = (int)transaction.payment.quantity;
        
        // extract unit price of the product
        float unitPrice = [product.price floatValue];
        
        // assign revenue generated from the current product
        float revenue = unitPrice * quantity;

        // create MAT tracking event item
        MATEventItem *eventItem = [MATEventItem eventItemWithName:product.localizedTitle unitPrice:unitPrice quantity:quantity revenue:revenue attribute1:@"attr1" attribute2:@"attr2" attribute3:@"attr3" attribute4:@"attr4" attribute5:@"attr5"];
        
        NSArray *arrEventItems = @[ eventItem ];
        
        if(transaction.transactionState == SKPaymentTransactionStatePurchased) {
            // track the purchase transaction event
            [MobileAppTracker measureAction:eventName
                                 eventItems:arrEventItems
                                referenceId:transaction.transactionIdentifier
                              revenueAmount:revenue
                               currencyCode:currencyCode
            ];
            
            NSLog(@"Transaction event tracked: %@", eventName);
        }
    }
}

+(void) mat_iapWithProdcutName : (NSString*)productName productId:(NSString*)prodId productPrice:(float)prodPrice purchasedQuantity:(int)qty revenueAmount:(float)revAmount currencyCode:(NSString*)currency
{
    // default tracking event name
    NSString *eventName = @"IAP";
    
    MATEventItem* eventItem = [MATEventItem eventItemWithName:productName unitPrice:prodPrice quantity:prodPrice revenue:revAmount];
    
    [MobileAppTracker measureAction:eventName eventItems:@[eventItem] referenceId:prodId revenueAmount:revAmount currencyCode:currency];
}

/*
#pragma mark - MobileAppTrackerDelegate Methods
// MAT tracking request success callback
void mobileAppTrackerDidSucceedWithData(id data)
{
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"MAT.success: %@", response);
}

// MAT tracking request failure callback
void mobileAppTrackerDidFailWithError(NSError* error)
{
    NSLog(@"MAT.failure: %@", error);
}
*/
// --- MAT --- <<<
//#########################################################################


//#########################################################################
// --- Adjust --- >>>
static bool adjustInitialized = NO;
static NSMutableDictionary* dict = nil;

+(NSMutableDictionary*) adjustEventParams
{
    if(dict == nil) {
        static dispatch_once_t oncePredicate;
        
        dispatch_once(&oncePredicate, ^{
            dict = [NSMutableDictionary dictionary];
        });
    }
    return dict;
}

void setAdjustAttributes(bool useSandbox)
{
    //app_version - we go ahead and set this, but this can be changed if a cutom version is set with adjust_customVersion()
    [[ScopelyAttributionWrapper adjustEventParams] setObject:urlEncodeString([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]) forKey:@"app_version"];
    
    //device_brand
    [[ScopelyAttributionWrapper adjustEventParams] setObject:@"apple" forKey:@"device_brand"];
    
    //device_carrier
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    NSString* carrierName = urlEncodeString([[netinfo subscriberCellularProvider] carrierName]);
    if(carrierName != nil) {
        [[ScopelyAttributionWrapper adjustEventParams] setObject:urlEncodeString(carrierName) forKey:@"device_carrier"];
    }
    else {
        NSLog(@"device carrier not found");
    }
    
    //device_model
    [[ScopelyAttributionWrapper adjustEventParams] setObject:urlEncodeString([[UIDevice currentDevice] systemName]) forKey:@"device_model"];
    
    //os
    [[ScopelyAttributionWrapper adjustEventParams] setObject:@"ios" forKey:@"os"];
    
    //package_name
    [[ScopelyAttributionWrapper adjustEventParams] setObject:urlEncodeString([[NSBundle mainBundle] bundleIdentifier]) forKey:@"package_name"];
    
    //sandbox
    [[ScopelyAttributionWrapper adjustEventParams] setObject:useSandbox ? @"True" : @"False" forKey:@"sandbox"];
}

static NSString* urlEncodeString(NSString* nonEncodedString)
{
//    return nonEncodedString;
    return [nonEncodedString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
}

//static void printAttributes()
//{
//    for(id key in [ScopelyAttributionWrapper adjustEventParams]) {
//        NSLog(@"adjustEventParams - %@: %@ \n", key, [[ScopelyAttributionWrapper adjustEventParams] objectForKey:key]);
//    }
//}

+(void) adjust_initWithApptoken : (NSString *)appToken usingSandboxMode:(bool)useSandbox
{
    setAdjustAttributes(useSandbox);
    
    //init adjust
    [Adjust appDidLaunch:appToken];
    
    //set log level
#ifdef DEBUG
    [Adjust setLogLevel:AILogLevelInfo];
#else
    [Adjust setLogLevel:AILogLevelError];
#endif
    
    //use sandbox YES/NO
    if(useSandbox) {
        [Adjust setEnvironment:AIEnvironmentSandbox];
    }
    else {
        [Adjust setEnvironment:AIEnvironmentProduction];
    }
    
    adjustInitialized = YES;
}

+(void) adjust_setUserId:(NSString *)userId
{
    //user_id
    [[ScopelyAttributionWrapper adjustEventParams] setObject:userId forKey:@"user_id"];
}

+(void) adjust_customVersion:(NSString *)customVersion
{
    //app_version
    [[ScopelyAttributionWrapper adjustEventParams] setObject:customVersion forKey:@"app_version"];
}

+(void) adjust_trackEvent : (NSString*)eventToken
{
    if(adjustInitialized) {
        //printAttributes();
        [Adjust trackEvent:eventToken withParameters:[ScopelyAttributionWrapper adjustEventParams]];
    }
}
// --- Adjust --- <<<
//#########################################################################

@end
