//
//  TangoSession.h
//  TangoSDK
//
// -*- ObjC -*-
// Copyright 2012-2013, TangoMe Inc ("Tango").  The SDK provided herein includes 
// software and other technology provided by Tango that is subject to copyright and 
// other intellectual property protections. All rights reserved.  Use only in 
// accordance with the Evaluation License Agreement provided to you by Tango.
// 
// Please read Tango_SDK_Evaluation_License_agreement_v1-2.docx
//

#import <Foundation/Foundation.h>


//Forward reference
@class TangoSession;
@class TangoLaunchContext;


/** These are the result type codes for HandleURLResult. You check the code to determine
    what parameters you need to extract from the result object, if any. See TangoHandleURLResult.
    */
typedef enum {
  /// The URL was invalid or there was an internal error.
  TangoHandleURLResultTypeError = 0,
  /// The SDK handled the URL and there was no useful data for your app.
  TangoHandleURLResultTypeNoActionNeeded = 1,
  /// You must process a URL that has been stripped of any SDK-related information. Do
  /// not just use the URL that you passed into handleURL: because it may have been a wrapper
  /// containing the URL you are actually interested in. URLs for messages sent via
  /// sendMessage:toRecipients: [TangoMessaging.h] will also show up under this type.
  TangoHandleURLResultTypeUserUrl = 2,
  /// Your app was asked to handle a tap on a message sent by sendGiftMessageToRecipients:...
  TangoHandleURLResultTypeEventGiftMessageReceived = 3,
  /// Your app was asked to handle a tap on a message/post sent by TangoSharing.
  TangoHandleURLResultTypeSharedDataReceived = 4,
	/// The SDK received a URL that it could parse but it does not understand the encoded
  /// action. It's possible that you've received a URL that can only be understood by a newer
  /// version of the SDK. (You might ask the user to upgrade your app).
  TangoHandleURLResultTypeUnknownAction = 5,
} TangoHandleURLResultType;

// Keys to index into HandleURLResult.parameters:
extern NSString * const kTangoHandleUrlResultUserUrlKey;  ///< For TangoHandleURLResultTypeUserUrl
extern NSString * const kTangoHandleUrlResultGiftTypeKey; ///< For TangoHandleURLResultTypeEventGiftMessageReceived
extern NSString * const kTangoHandleUrlResultGiftIdKey;   ///< For TangoHandleURLResultTypeEventGiftMessageReceived


/** HandleURLResult holds data returned by -[TangoSession handleURL:withSourceApplication:].
    You should inspect the type code to determine the keys you should use with "sdkParameters" to
    retrieve any data relevant to your application. Custom parameters that you pass from the
    sender SDK app are delivered through "userParameters". All keys are instances of NSString.
    */
@interface TangoHandleURLResult : NSObject

/// Type code representing what actions you need to take. See TangoHandleURLResultType.
@property(nonatomic, readonly) TangoHandleURLResultType type;

/// Parameters dictionary containing Tango-provided data that might be pertinent to your application.
/// See the kTangoHandleUrlResult<*>Key constants above.
/// Keys and values are NSString unless otherwise documented.
@property(nonatomic, readonly) NSDictionary *sdkParameters;

/// Parameters dictionary containing custom data you passed from share().
/// The keys and values are user-defined NSStrings.
@property(nonatomic, readonly) NSDictionary *userParameters;

@end


/**
 Authentication handler. This block is called when Tango Authentication is done.
 */
typedef void (^AuthenticationHandler)(
                                      TangoSession* session,
                                      NSError* error
                                      );

/**
 Access token handler.
 */
typedef void (^AccessTokenHandler)(
                                   TangoSession* session,
                                   NSString* accessToken,
                                   NSError* error
                                   );


/**
 Advertisement handler.
 */
typedef void (^AdvertisementHandler)(
                                     TangoSession* session,
                                     NSDictionary* advertisement,
                                     NSError* error
                                     );

/*
 * Constants used by NSNotificationCenter for Tango session notification
 */

/*! NSNotificationCenter name indicating that a new active session was set */
extern NSString *const TangoSessionCreatedTangoSessionNotification;

/*! NSNotificationCenter name indicating thatd an active session was unset */
extern NSString *const TangoSessionAuthenticatedTangoSessionNotification;

/*! NSNotificationCenter name indicating that the active session is open */
extern NSString *const TangoSessionAuthenticationErrorTangoSessionNotification;

/*! NSNotificationCenter name indicating that event is posted */
extern NSString *const TangoSessionEventPostedTangoSessionNotification;


/** The TangoSession is used primarily to initialize the Tango SDK and authenticate with Tango.
    After that it can be used to access a few utility functions, but primary SDK operations are
    conducted through the other SDK classes (TangoSharing, TangoMessage, TangoMetrics, and so on).
 
    The session can be in one of three states:
    Created:        Starting state after instantiation.
    Initialized:    You've called one of the sessionInitialize methods and successfully initialized
                    the SDK.
    Authenticated:  You've successfully authenticated with Tango.
    */
@interface TangoSession : NSObject

#pragma mark - Initialization

/** Retrieve a reference to the singleton TangoSession instance.
    */
+ (TangoSession*)sharedSession;

/** Initialize the shared Tango Session using parameters from the application bundle.
    Returns YES if the SDK was initialized successfully, otherwise it returns NO.
*/
+ (BOOL)sessionInitialize;

/** Uninitialize the shared Tango Session in preparation for shutdown.
    */
+ (void)sessionUninitialize;

/** Initialize the shared TangoSession programmatically, using the provided parameters. If any of
    the values are nil, the data for those values will be retrieved from the application bundle.
    Returns YES if SDK initialization was successful, otherwise NO.
    */
+ (BOOL)sessionInitializeWithAppID:(NSString*)appID withUrlScheme:(NSString*)urlScheme;


#pragma mark - Utility

/** Returns a human-readable version string for the Tango SDK.
  */
+ (NSString *)sdkVersion;

/** Take the user to the Tango App Store page so that they can install or upgrade to the latest
    version. No prompt will be shown to the user beforehand.
    */
- (void)installTango;

/** Use this to determine if Tango is installed on the user's device.
    Returns YES if Tango is installed, NO otherwise.
    */
@property(readonly) BOOL tangoIsInstalled;

/** Detect if the user's installed version of Tango has SDK support.
    Returns YES if Tango is installed and supports SDK integration,
    NO otherwise.
    */
@property(readonly) BOOL tangoHasSdkSupport;

/** The session was initialized successfully and is ready to perform authentication.
    */
@property(readonly) BOOL isInitialized;

/** The session was authenticated successfully and is ready to use.
    */
@property(readonly) BOOL isAuthenticated;

/** Returns a human-readable environment name that the SDK was built against (production/partnerdev).
    */
@property(readonly) NSString *sdkEnvironment;



#pragma mark - URL Handling

/** Pass a URL to the Tango SDK for processing. You should call this each time iOS presents you
    with a URL, and check the return value instead of trying to process the URL yourself. For example,
    call this when your application delegate's application:openURL:sourceApplication:annotation:
    method is triggered. See TangoHandleURLResult above, for information about how to interpret
    the result data. You should never inspect the raw URL that the system gives you. Instead,
    retrieve the URL from TangoHandleURLResult.sdkParameters if the type code indicates that you
    should do so.
 
    This method is part of the authentication process, so you need to have it set up before you
    can use the Tango SDK, in practice.
    */
- (TangoHandleURLResult *)handleURL:(NSURL *)url withSourceApp:(NSString *)sourceApp;



#pragma mark - Authentication

/** Authenticate with Tango. Your callback handler will be triggered on the global queue
    once a response is available.
    */
- (void) authenticateWithHandler:(AuthenticationHandler) handler;

/** Cancels any pending authentication requests and clears the data related to the user account
    from local storage.
    */
- (void) resetAuthenticationWithHandler:(AuthenticationHandler) handler;



#pragma mark - SSO Access Tokens

/** Asynchronously retrieve an access token that you can use with Tango SSO (server to server
    operations).
    */

- (void) accessTokenWithHandler:(AccessTokenHandler) handler;

/** Synchronously retrieve an access token to use with Tango SSO (server to server operations).
    Note that this function blocks until an access token is generated, so you should not call
    it directly from your UI code.
    */
- (NSString*) accessToken:(NSError **)pError;



#pragma mark - Advertisements

/** Get an advertisement asynchronously. The dictionary takes the following form:
    {
      "banner"  : "http://sdk.tango.me/assets2/Tango/Ext_Ads_V4.jpg",
      "link"    : "http://install.tango.net?id=xyz&source=sdk"
    }
    */
- (void) advertisementWithHandler:(AdvertisementHandler)handler;

/** Get an advertisement synchronously. See [TangoSession advertisementWithHandler:] for the
    dictionary keys.
    */
- (NSDictionary *) advertisement:(NSError **)pError;



#pragma mark - Deprecated Functionality

/// @deprecated TangoLaunchContext was never fully implemented and will be removed.
@property(nonatomic, readonly) TangoLaunchContext *launchContext DEPRECATED_ATTRIBUTE;

/// @deprecated Use #handleURL:withSourceApp: instead.
- (BOOL)handleURL:(NSURL*)url withSourceApplication:(NSString*) sourceApplication DEPRECATED_ATTRIBUTE;

/// @deprecated Use #handleURL:withSourceApp: instead.
- (BOOL)handleURL:(NSURL*)url withSourceApplication:(NSString*)sourceApplication
          userUrl:(NSString**) userUrl DEPRECATED_ATTRIBUTE;

@end
