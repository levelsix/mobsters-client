//
//  TangoSharingData.h
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

/** Represents the content that you want to share through Tango. Use with
    [TangoSharing share:handler:]. You may include one media attachment via the
    setMedia... methods.
    */
@interface TangoSharingData : NSObject

#pragma mark - Convenience constructors

/// Returns a TangoSharingData suitable for posting to the user's feed with the supplied link
/// and caption text. You may set other properties as required.
+ (id)dataForMyFeedWithLinkText:(NSString *)linkText captionText:(NSString *)captionText;

/// Returns a TangoSharingData suitable for sending a chat message to the supplied recipients
/// using the given caption and link text. You may set other properties as required.
+ (id)dataForChatWithRecipients:(NSSet *)recipients linkText:(NSString *)linkText
                    captionText:(NSString *)captionText;

/// Returns a TangoSharingData suitable for sending a message to the supplied group chats,
/// using the given caption and link text. You may set other properties as required.
+ (id)dataForChatWithGroups:(NSSet *)groupIds linkText:(NSString *)linkText
                captionText:(NSString *)captionText;

#pragma mark - Properties

/// Set the intended area you want your content to be displayed in Tango.
/// Currently, "my_feed", "chat_from_user", and "chat_from_app" are supported.
@property (nonatomic, copy) NSString *displayTarget;

/// Set the recipients you want to share the event with (for chat display target).
/// Recipients are identified by their Tango account IDs (NSString).
@property (nonatomic, copy) NSSet *recipients;

/// Set the chat groups you want to share the event with (for chat display target).
/// Groups are identified by their Tango group chat IDs (NSString). You may specify both
/// individual recipients and groups in a single request.
@property (nonatomic, copy) NSSet *groupIds;

/// Set to YES if you want users to be able to forward or repost your content.
/// Defaults to NO.
@property (nonatomic, assign) BOOL forwardable;

/// A short string describing the event, used in notifications and other parts of
/// Tango that do not fully display the content (optional). Do not include the
/// sender's name in the notification.
@property (nonatomic, copy) NSString *notificationText;

/// A string containing larger body text for the event you want to share.
/// Ex: "I got a score of 432, can you do better?"
@property (nonatomic, copy) NSString *captionText;

/// A string containing a short label that prompts the user to act on the event.
/// Ex: "Claim 3 tokens!" If this is not provided, a placeholder button will be used
/// instead.
@property (nonatomic, copy) NSString *linkText;

/// A string describing the intent of the content, ex: "invite", "brag", "gift", "content", etc.
@property (nonatomic, copy) NSString *intent;

/// Custom parameters to be passed back to your app via handleURL:withSourceApp: when a
/// user triggers the action for your shared event. Only first-tier NSString keys and values
/// will be extracted when your parameters are sent.
@property (nonatomic, copy) NSDictionary *userParameters;


#pragma mark - Media Attachment Methods

/// Attach a picture to share, from a UIImage.
- (void)setMediaImage:(UIImage *)image;

/// Attach a picture to share and a custom thumbnail, both from a UIImage.
- (void)setMediaImage:(UIImage *)image thumbnail:(UIImage *)thumbnail;

/// Attach media from a file on disk. The mime type is automatically retrieved.
- (void)setMediaFile:(NSURL *)fileURL;

/// Attach media and a custom thumbnail from a file on disk. The mime type is automatically retrieved.
- (void)setMediaFile:(NSURL *)fileURL thumbnailFile:(NSURL *)thumbFileURL;

/// Attach media and a custom thumbnail from web URLs (http). You must specify the mime types.
- (void)setMediaWebURL:(NSURL *)webURL mime:(NSString *)mime thumbURL:(NSURL *)thumbURL thumbMime:(NSString *)thumbMime;


#pragma mark - Property Getters

@property (nonatomic, strong, readonly) UIImage *mediaImage;
@property (nonatomic, copy,   readonly) NSURL *mediaURL;
@property (nonatomic, copy,   readonly) NSString *mediaMime;

@property (nonatomic, strong, readonly) UIImage *thumbnailImage;
@property (nonatomic, copy,   readonly) NSURL *thumbnailURL;
@property (nonatomic, copy,   readonly) NSString *thumbnailMime;

@end
