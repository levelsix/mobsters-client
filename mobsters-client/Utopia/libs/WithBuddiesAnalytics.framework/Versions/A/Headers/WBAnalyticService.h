//
//  WBAnalyticService.h
//  WithBuddiesAnalytics
//
//  Created by odyth on 1/3/14.
//  Copyright (c) 2014 Scopely. All rights reserved.
//
#import <WithBuddiesBase/WithBuddiesBase.h>
#import <WithBuddiesAnalytics/WBAnalyticEventType.h>
#import <WithBuddiesAnalytics/WBAnalyticEventPriority.h>
#import <WithBuddiesAnalytics/WBAnalyticAdEventType.h>
#import <WithBuddiesAnalytics/WBAnalyticAdType.h>
#import <WithBuddiesAnalytics/WBAnalyticGender.h>

@class WBAnalyticSettings;
@class WBAnalyticDeviceInfo;
@interface WBAnalyticService : WBService

/*!
 *
 * @function initializeWithApplicationKey:
 *
 * @abstract
 * initializes the SDK with the default settings
 *
 * @param applicationKey key provided to you for your application
 */
+(void)initializeWithApplicationKey:(NSString *)applicationKey;

/*!
 *
 * @function initializeWithApplicationKey:settings
 *
 * @abstract
 * initializes the SDK with user supplied settings
 *
 * @param applicationKey key provided to you for your application
 * @param settings used to configure the SDK
 */
+(void)initializeWithApplicationKey:(NSString *)applicationKey settings:(WBAnalyticSettings *)settings;

/*!
 *
 * @function trackEvent:type:parameters:
 *
 * @abstract
 * tracks an event, priority defaults to WBAnalyticEventPriorityMedium
 *
 * @param event name of the event
 * @param eventType type of event
 * @param parameters optional parameters to track with the event.  parameters must be of the type NSString|NSNumber|NSDictionary|NSArray|NSDate|NSURL|NSNull|WBTimeSpan
 */
+(void)trackEvent:(NSString *)event type:(WBAnalyticEventType)eventType parameters:(NSDictionary *)parameters;
+(void)trackEvent:(NSString *)event type:(WBAnalyticEventType)eventType parameters:(NSDictionary *)parameters priority:(WBAnalyticEventPriority)priority;

/*!
 *
 * @function registerDeviceProperty:value:
 *
 * @abstract
 * coinvenince method for tracking WBAnalyticEventTypeDeviceProperty event types
 * 
 * @param propertyName name of the event
 * @param value optional value to track with event value must be of the type NSString|NSNumber|NSDictionary|NSArray|NSDate|NSURL|NSNull|WBTimeSpan
 */
+(void)registerDeviceProperty:(NSString *)propertyName value:(id)value;

/*!
 * @function unregisterDeviceProperty:
 *
 * @abstract
 * coinvenience method for tracking WBAnalyticEventTypeUnregisterDeviceProperty event types
 *
 * @param propertyName name of property to unregister
 */
+(void)unregisterDeviceProperty:(NSString *)propertyName;

/*!
 *
 * @function clearDeviceProperties
 *
 * @abstract
 * coinvenience method for tracking WBAnalyticEventTypeClearDeviceProperties event types
 */
+(void)clearDeviceProperties;

/*!
 * @function assignABTest:variant:
 *
 * @abstract
 * coinvenience method for tracking WBAnalyticEventTypeABTest event types
 *
 * @param test name of test to attach device to
 * @param variant that device is in
 * @param parameters - optional parameters to pass along with event
 */
+(void)assignABTest:(NSString *)test variant:(NSString *)variant parameters:(NSDictionary *)parameters;
+(void)assignABTest:(NSString *)test variant:(NSString *)variant;

/*!
 * @function setDeviceInfo:
 *
 * @abstract
 * sets device info.  use this method to attach lat, lng, age, gender, userId, and facebookId to a device
 *
 * @param deviceInfo updated device info
 */
+(void)setDeviceInfo:(WBAnalyticDeviceInfo *)deviceInfo;

/*!
 * @function deviceInfo
 *
 * @abstract
 * returns current device info
 */
+(WBAnalyticDeviceInfo *)deviceInfo;

/*!
 * @function flush
 *
 * @abstract
 * flushes the event queue
 */
+(void)flush;

/*!
 * @function clearEvents
 *
 * @abstract
 * clears all the events currently in the queue.  Does not clear events persisted to disk
 */
+(void)clearEvents;

@end

@interface WBAnalyticService (StandardEvents)

/*!
 * @function trackAppOpenWithLevel:extraParameters
 *
 * @abstract
 * tracks app open
 * 
 * @param level
 * players current level (optional)
 */
+(void)trackAppOpenWithLevel:(NSString*)level extraParameters:(NSDictionary*)extraParameters;
+(void)trackFteFlow:(NSInteger)step isComplete:(BOOL)isComplete skip:(BOOL)skip duration:(NSInteger)duration extraParams:(NSDictionary*)extraParams;
+(void)trackGameTransactions:(NSArray*)itemIds quantities:(NSArray *)quantities itemBalances:(NSArray*)itemBalances transactionType:(NSString*)transactionType context:(NSString*)context extraParams:(NSDictionary*)extraParams;
+(void)trackGameTransaction:(NSString*)itemId quantity:(NSNumber *)quantity itemBalance:(NSNumber*)itemBalance transactionType:(NSString*)transactionType context:(NSString*)context extraParams:(NSDictionary*)extraParams;
+(void)trackLevelUp:(NSString*) previousLevel newLevel:(NSString*)newLevel extraParams:(NSDictionary*)extraParams;
+(void)trackRegistration:(NSString*)email registrationType:(NSString*)registrationType error:(NSString *)error isNew:(NSNumber *)isNew extraParams:(NSDictionary*)extraParams;
+(void)trackPayment:(BOOL)success error:(NSString*)error amountLocal:(NSNumber*)amountLocal amountUS:(NSNumber*)amountUS localCurrencyName:(NSString*)localCurrencyName special:(NSString*)special specialId:(NSString*)specialId storeSku:(NSString*)storeSku gameSku:(NSString*)gameSku extraParams:(NSDictionary*)extraParams;
+(void)trackViral:(NSString*)viralType extraParams:(NSDictionary*)extraParams;
+(void)trackPromo:(NSString*)action type:(NSString*)type promoId:(NSString*)promoId extraParams:(NSDictionary*)extraParams;
+(void)trackAchievement:(NSString*)achievementId extraParams:(NSDictionary*)extraParams;
+(void)trackSocialConnect:(NSString*)connection firstName:(NSString*)firstName lastName:(NSString*)lastName gender:(WBAnalyticGender)gender birthDate:(NSDate*)birthDate extraParams:(NSDictionary*)extraParams;
+(void)trackAd:(WBAnalyticAdEventType)adEvent isBackFill:(BOOL)isBackFill failureReason:(NSString*)failureReason adNetwork:(NSString*)adNetwork adType:(WBAnalyticAdType)adType extraParams:(NSDictionary*)extraParams;
+(void)trackAdController:(WBAnalyticAdEventType)adEvent failureReason:(NSString*)failureReason adNetwork:(NSString*)adNetwork adType:(WBAnalyticAdType)adType extraParams:(NSDictionary*)extraParams;

@end
