//
//  TangoProfileEntry.h
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
#import <UIKit/UIKit.h>
#import "TangoTypes.h"

/** The handler used once the profile image has been fetched. The handler will
    run on the global queue.
    
    @param image  The profile image, or nil if the image could not be fetched.
    */
typedef void (^ProfileEntryFetchImageHandler)(UIImage *image);


/** This interface encapsulates a Profile entry. It is a wrapper to the actual
    profile entry with accessors to common data.
 
    You may use the property-based accessors for keys added up to the SDK
    release you have installed. If you need access to a value that was added
    after your SDK release, you can use objectForKey: or the Objective-C
    keyed subscript operator to retrieve the data.
    */
@interface TangoProfileEntry : NSObject <NSFastEnumeration>

/// The user's first name.
@property(readonly) NSString* firstName;
/// The user's last name.
@property(readonly) NSString* lastName;
/// The user's full name. (Convenience accessor).
@property(readonly) NSString* fullName;
/// The user's profile (Tango) ID.
@property(readonly) NSString* profileID;
/// Whether or not the user has your app.
@property(readonly) BOOL      hasTheApp;
/// The URL for the user's profile picture.
@property(readonly) NSString* profilePictureURL;
/// YES if the profile picture is a placeholder.
@property(readonly) BOOL      profilePictureIsPlaceholder;
/// Returns the user's profile picture if it is available from the cache. If not,
/// you should call fetchProfilePictureWithHandler: to retrieve the image asynchronously.
@property(readonly) UIImage* cachedProfilePicture;
/// A set of NSNumbers wrapping TangoSdkPlatform values for devices the user has.
@property(readonly) NSSet*    supportedPlatforms;
/// The user's profile status.
@property(readonly) NSString* status;
/// The user's gender.
@property(readonly) TangoSdkGender gender;

/// Returns YES if the user has a device matching the platform.
- (BOOL)userSupportsPlatform:(TangoSdkPlatform)platform;

/** Fetch the user's profile picture asynchronously. After this succeeds, the profile
    picture will be cached and you should be able to retrieve it via cachedProfilePicture
    until the data is evicted from the cache. Recommended usage:
    
    UIImage *picture = profile.cachedProfilePicture;
    if(picture == nil) {
      [profile fetchProfilePictureWithHandler:^(UIImage *pic) { // ... };
    }
    
    Don't forget to post back to main thread when setting your image on a view.
    The handler runs on the global concurrent queue.
    
    @param handler A handler to call once the profile's image has been fetched.
    */
- (void)fetchProfilePictureWithHandler:(ProfileEntryFetchImageHandler)handler;

/// Returns an object from the JSON response for the user's profile, matching key.
- (id)objectForKey:(NSString *)key;
- (id)objectForKeyedSubscript:(NSString *)key;

@end
