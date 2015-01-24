//
//  TangoGroups.h
//  TangoSDK
//
// -*- ObjC -*-
// Copyright 2014, TangoMe Inc ("Tango").  The SDK provided herein includes
// software and other technology provided by Tango that is subject to copyright and
// other intellectual property protections. All rights reserved.  Use only in
// accordance with the Evaluation License Agreement provided to you by Tango.
//
// Please read Tango_SDK_Evaluation_License_agreement_v1-2.docx
//

#import <Foundation/Foundation.h>
#import <TangoSDK/TangoError.h>
#import <TangoSDK/TangoGroupsResponse.h>


/** Interact with Tango Group Chats.
    */
@interface TangoGroups : NSObject

/// Fetch the list of the user's recent group chats. See TangoGroupsResponse.h for
/// information about the result structure. To send a message to a group chat, use
/// TangoSharing.
+ (void)fetchRecentGroupChatsWithHandler:(TangoGroupsFetchRecentGroupChatsHandler)handler;

@end
