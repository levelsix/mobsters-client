//
//  TangoProfile.h
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

@class TangoProfile; // See below.
@class TangoProfileResult; // See TangoProfileResult.h

/// Profile handler. This block is called with Tango API Profile results.
typedef void (^TangoProfileResponseHandler)(
  TangoProfileResult* profileResult,
  NSError* error
);


/// Profile handler. This block is called with Tango API Profile results.
typedef void (^ProfileHandler)(
          TangoProfile* profile,
          TangoProfileResult* profileResult,
          NSError* error
        );


/** TangoProfile is the interface for both the My Profile and Get Contacts APIs in the Objective-C
    binding.
    */
@interface TangoProfile : NSObject

#pragma mark Asynchronous calls

/** Retrieves the user's profile.
    The SDK calls the handler block with a TangoProfileResult that contains the user's profile.
    */
+ (void)fetchMyProfileWithHandler:(TangoProfileResponseHandler) handler;

/** Retrieves an array containing profiles for the user's friends.
    The SDK calls the handler block with a TangoProfileResult object with an array of the friends' profiles.
    While this method is not deprecated, you should usually call #fetchMyCachedFriendsWithHandler: instead.
    */
+ (void)fetchMyFriendsProfilesWithHandler:(TangoProfileResponseHandler) handler;

/** Retrieves an array containing profiles for the cached user's friends.
    The SDK calls the handler block with a TangoProfileResult object with an array of the friends' profiles.
    */
+ (void)fetchMyCachedFriendsWithHandler:(TangoProfileResponseHandler) handler;


#pragma mark Synchronous calls

/** Retrieves the user's profile.
    The SDK returns a TangoProfileResult object that contains the user's profile.
    This is the synchronous version of #fetchMyProfileWithHandler:.
    NOTE: This function will block the current thread until completion.
    */
+ (TangoProfileResult*)fetchMyProfile:(NSError**)error;

/** Retrieves an array containing profiles for the user's friends.
    The SDK returns a TangoProfileResult object with an array of the friends' profiles.
    This is the synchronous version of #fetchMyFriendsProfilesWithHandler:.
    NOTE: This function will block the current thread until completion.
    */
+ (TangoProfileResult*)fetchMyFriendsProfiles:(NSError**)error;

/** Retrieves an array containing profiles for the user's friends.
    The SDK returns a TangoProfileResult object with an array of the friends' profiles.
    This is the synchronous version of #fetchMyCachedFriendsWithHandler:.
    NOTE: This function will block the current thread until completion.
    */
+ (TangoProfileResult*)fetchMyCachedFriends:(NSError**)error;


#pragma mark - Deprecated APIs

/** @deprecated Use #fetchMyProfileWithHandler: instead.
 
    Retrieves the user's profile.
    The SDK calls the handler block with a TangoProfileResult that contains the user's profile.
    */
- (void)getMyProfileWithHandler:(ProfileHandler) handler DEPRECATED_ATTRIBUTE;

/** @deprecated Use #fetchMyFriendsProfilesWithHandler: instead.
 
    Retrieves an array containing profiles for the user's friends.
    The SDK calls the handler block with a TangoProfileResult object with an array of the friends' profiles.
    */
- (void)getMyFriendsProfilesWithHandler:(ProfileHandler) handler DEPRECATED_ATTRIBUTE;

/** @deprecated Use #fetchMyCachedFriendsWithHandler: instead.
 
    Retrieves an array containing cached profiles for the user's friends.
    The SDK calls the handler block with a TangoProfileResult object with an array of the cached friends' profiles.
    */
- (void)getMyCachedFriendsWithHandler:(ProfileHandler) handler DEPRECATED_ATTRIBUTE;

/** @deprecated Use #fetchMyProfile: instead.
 
    Retrieves the user's profile.
    The SDK returns a TangoProfileResult object that contains the user's profile.
    This is the synchronous version of getMyProfileWithHandler.
    NOTE: This function will block the current thread until completion.
    */
- (TangoProfileResult*)getMyProfile:(NSError**) error DEPRECATED_ATTRIBUTE;

/** @deprecated Use #fetchMyFriendsProfiles: instead.
 
    Retrieves an array containing profiles for the user's friends.
    The SDK returns a TangoProfileResult object with an array of the friends' profiles.
    This is the synchronous versoin of #getMyFriendsProfilesWithHandler:.
    NOTE: This function will block the current thread until completion.
    */
- (TangoProfileResult*)getMyFriendsProfiles:(NSError**) error DEPRECATED_ATTRIBUTE;

/** @deprecated Use #fetchMyCachedFriends: instead.
 
    Retrieves an array containing profiles for the user's cached friends.
    The SDK returns a TangoProfileResult object with an array of the friends' profiles.
    This is the synchronous version of #getMyCachedFriendsWithHandler:.
    NOTE: This function will block the current thread until completion.
    */
- (TangoProfileResult*)getMyCachedFriends:(NSError**) error DEPRECATED_ATTRIBUTE;

@end
