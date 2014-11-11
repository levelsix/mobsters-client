//
//  TangoMessaging.h
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
#import "TangoMessageHandlers.h"
#import "TangoMessage.h"

/// Key to set video orientation in contentMetadata when sending a message.
extern NSString * kContentMetadataRotationKey;

DEPRECATED_ATTRIBUTE
/** TangoMessaging is the interface for both the Advanced and Simple Messaging APIs in the
    Objective-C wrapper. The Simple Messaging methods are sendInviteMessage*, sendBragMessage*,
    and sendGiftMessage*. Use #sendMessage:toRecipients: if you need to work with the Advanced API.
 
    @deprecated Use TangoSharing instead.
    */
@interface TangoMessaging : NSObject

#pragma mark - Advanced Messaging API

/** Send a message to a list of recipients. You must specify at least either a thumbnail URL or text.
    This is the primary entry point for the advanced messaging API. See TangoMessage.
 
    @deprecated Use TangoSharing instead.
 
    @param message              The message object to send.
    @param accountIdentifiers   The array of account IDs that the message will be sent to.
    */
+ (void)sendMessage:(TangoMessage *)message toRecipients:(NSArray *)accountIdentifiers;


#pragma mark - Utility Methods

/** Compute rotation value (as a string) for a video at a given URL. Use this when specifying
    content metadata in Advanced Messaging, so that your video can be rotated properly for display.
 
    @deprecated Use TangoSharing instead.
    */
+ (NSString *)rotationForVideoAtURL:(NSURL *)url;


#pragma mark - Simple Messaging

/** Send a simple invitation message to a list of recipients. If you are trying to convey a "brag"
    event, you should use sendBragMessageToRecipients:... instead.
 
    @deprecated Use TangoSharing instead.
 
    @param accountIdentifiers   Array of Tango account IDs to send the message to.
    @param notificationText     The text to display in the push notification and summary for
                                the message.
    @param linkText             The text to display in the message link. (aka action prompt).
    @param handlerOrNULL        A handler block to check for success/failure.
    */
+ (void)sendInviteMessageToRecipients:(NSArray *)accountIdentifiers
                     notificationText:(NSString *)notificationText
                             linkText:(NSString *)linkText
                        resultHandler:(MessageHandler)handlerOrNULL;

/** Send a simple brag message to a list of recipients. See sendInviteMessageToRecipients:...
    for parameter details. This method behaves exactly the same, but use this if the intent of
    the message is to brag (ex: new high score) rather than to invite the user.
 
    @deprecated Use TangoSharing instead.
    */
+ (void)sendBragMessageToRecipients:(NSArray *)accountIdentifiers
                   notificationText:(NSString *)notificationText
                           linkText:(NSString *)linkText
                      resultHandler:(MessageHandler)handlerOrNULL;

/** Send a simple gift message to a list of recipients with a custom gift parameter that you can
    use to pass information back to your app in TangoSession's handleURL:. Gifts are automatically
    de-duplicated by the SDK based upon an automatically generated gift id, but you are responsibile
    for providing your own security mechanism in the giftType parameter.
 
    @deprecated Use TangoSharing instead.
 
    @param accountIdentifiers   See sendInviteMessageToRecipients:...
    @param notificationText     See sendInviteMessageToRecipients:...
    @param linkText             See sendInviteMessageToRecipients:...
    @param giftType             Custom gift "type" string that you can use to identify the kind of
                                gift, on the receiving end. You may include special characters, ex:
                                "item=1294&qty=25&color=red". The string is encoded for transport
                                by the SDK, so you could conceivably use any data format you wish.
    @param handlerOrNULL        See sendInviteMessageToRecipients:...
    */
+ (void)sendGiftMessageToRecipients:(NSArray *)accountIdentifiers
                   notificationText:(NSString *)notificationText
                           linkText:(NSString *)linkText
                           giftType:(NSString *)giftType
                      resultHandler:(MessageHandler)handlerOrNULL;

#pragma mark - Older Advanced Messaging

/** Send a message to a list of recipients. You must specify at least one of thumbnailURL or text.
 
    @deprecated Use TangoSharing instead.
 
    @param accountIdentifiers   An array of ciphered Tango Account IDs that identify the recipients
                                of the message. You must specify at least one.
    @param descriptionText      A required string that is shown to identify the message to the
                                recipient in push notifications sent to their device, and also in
                                the their conversation summary list.
    @param thumbnailUrlOrNil    An optional URL for a thumbnail to display in the message.
    @param actionsOrNil         An optional TangoActionMap, specifying message actions.
    @param messageTextOrNil     An optional string for text to display in the message.
    @param handlerOrNULL        An optional result handler to determine if the message was
                                sent successfully.
    */
+ (void)sendMessageToRecipients:(NSArray *)accountIdentifiers
                withDescription:(NSString *)descriptionText
                   thumbnailURL:(NSURL *)thumbnailURLOrNil
                        actions:(TangoActionMap *)actionsOrNil
                           text:(NSString *)messageTextOrNil
                  resultHandler:(MessageHandler)handlerOrNULL;

/** Send a message to a list of recipients, where you wish to upload a thumbnail to the Tango
    content servers, but specify custom actions for the message instead of "content" to open.
    If you do not need to upload any data, you should use
    #sendMessageToRecipients:withDescription:thumbnailURL:actions:text:resultHandler:.
 
    @deprecated Use TangoSharing instead.
    */
+ (void)sendMessageToRecipients:(NSArray *)accountIdentifiers
                withDescription:(NSString *)descriptionText
              thumbnailMimeType:(NSString *)thumbnailMimeType
                  thumbnailData:(NSData *)thumbnailDataOrNil
                        actions:(TangoActionMap *)actionsOrNil
                           text:(NSString *)messageTextOrNil
                progressHandler:(MessageProgressHandler)progressHandlerOrNULL
                  resultHandler:(MessageHandler)handlerOrNULL;

/** Send a message to a list of recipients, where you wish to upload "content", with an optional
    thumbnail, which you also may choose to upload. You cannot specify custom actions when you
    want to include "content". Use only one of contentData: or contentHandler:. Mime types are
    required for any case where you are uploading data.
    
    If you need to open uploaded content in your own application (instead of the browser or Tango
    itself), you can use conversion_handler to massage the URLs into a TangoActionMap that will be
    used instead of the auto-generated one.

    Support for contentHandler is not finished yet. See tango_sdk::message.h.
 
    @deprecated Use TangoSharing instead.
    */
+ (void)sendMessageToRecipients:(NSArray *)accountIdentifiers
                withDescription:(NSString *)descriptionText
                   thumbnailURL:(NSURL *)thumbnailURLOrNil
              thumbnailMimeType:(NSString *)thumbnailMimeTypeOrNil
                  thumbnailData:(NSData *)thumbnailDataOrNil
                contentMimeType:(NSString *)contentMimeTypeOrNil
                    contentData:(NSData *)contentDataOrNil
                 contentHandler:(AsyncUploadHandler)contentHandlerOrNil
              contentLengthHint:(NSUInteger)contentLengthHint
                contentMetadata:(NSDictionary *)contentMetadataOrNil
            contentActionPrompt:(NSString *)actionPrompt
 contentUploadConversionHandler:(ContentUploadConversionHandler)conversionHandler
                           text:(NSString *)messageTextOrNil
                progressHandler:(MessageProgressHandler)progressHandlerOrNULL
                  resultHandler:(MessageHandler)handlerOrNULL;

@end
