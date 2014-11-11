//
//  TangoActionMap.h
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
#import "TangoTypes.h"

DEPRECATED_ATTRIBUTE
/** TangoActionMap is an Objective-C wrapper around tango_sdk::PlatformToActionMap. Use this
    to specify actions that occur when the user taps on a message. Actions for a specific
    platform will override those set for PLATFORM_FALLBACK. actionURL and mimeType are required.
 
    @deprecated Use TangoSharingData and TangoSharing instead.
    */
@interface TangoActionMap : NSObject

/// Set the action for the given platform. Overrides previous settings for that platform.
/// Returns YES if the action was added to the map successfully, NO on failure. Inspect your
/// logs for details if there is a failure.
/// @param platform The platform you want to set an action URL for.
/// @param actionURL The action URL you want Tango to launch when the user taps on your message.
/// @param actionPromptOrNil The "link text" you want Tango to display in the message. (Optional).
/// @param mimeType The mime type of the content located at the actionURL. Specify a mime type
///                 prefixed by "image/" or "video/" if you want Tango to display picture or
///                 video content internally. Other mime types will cause the actionURL to be
///                 launched using the standard iOS system calls.
- (BOOL)setActionForPlatform:(TangoSdkPlatform)platform
                     withURL:(NSURL *)actionURL
                actionPrompt:(NSString *)actionPromptOrNil
                    mimeType:(NSString *)mimeType;

/// Remove an action for the given platform.
/// @param platform The platform that you want to remove from the action map.
- (void)removeActionForPlatform:(TangoSdkPlatform)platform;

@end
