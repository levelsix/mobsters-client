//
//  TangoGroupsResponse.h
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

/// Represents an individual group chat that the user is participating in.
@interface TangoGroupChat : NSObject
/// The name of the group chat.
@property (nonatomic, copy, readonly) NSString *groupName;
/// The group ID that you can use to send messages to the group chat.
@property (nonatomic, copy, readonly) NSString *groupId;
/// The profile photo URL of the last user to post to the group.
@property (nonatomic, strong, readonly) NSURL *lastUserProfilePhotoURL;
/// Whether or not the last poser profile photo is a placeholder.
@property (nonatomic, assign, readonly) BOOL lastUserProfilePhotoIsPlaceholder;
/// The name of the last user to post to the group.
@property (nonatomic, copy, readonly) NSString *lastUserName;
/// The text of the last message posted to the group.
@property (nonatomic, copy, readonly) NSString *lastMessageText;
/// The timestamp of the last message posted to the group.
@property (nonatomic, strong, readonly) NSDate *lastMessageTimestamp;
/// The number of Tango users in the group chat, including the sender.
@property (nonatomic, assign, readonly) NSInteger count;
@end


#pragma mark - Response Classes

/// Response object returned when fetching the user's recent group chats.
@interface TangoGroupsFetchRecentGroupChatsResponse : NSObject
/// An array of group chats that the user is participating in.
@property (nonatomic, readonly) NSArray *groupChats;
@end

#pragma mark - Handler Types

typedef void (^TangoGroupsFetchRecentGroupChatsHandler)
    (TangoGroupsFetchRecentGroupChatsResponse *response, NSError *error);

