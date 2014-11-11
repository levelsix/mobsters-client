//
//  TangoMessage.h
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
#import "TangoActionMap.h"
#import "TangoMessageHandlers.h"

DEPRECATED_ATTRIBUTE
/** This class corresponds to the tango_sdk::Message class in the C++ layer. For a thorough
    explanation on all aspects of sending a Tango Message, please refer to that class's
    API reference for detailed information.
 
    @deprecated Use TangoSharingData and TangoSharing instead.
    */
@interface TangoMessage : NSObject

/// A short description for the message to be displayed as a summary. Do not include the
/// sender or recipient's name in the description.
@property (nonatomic, strong) NSString *descriptionText;

/// The multi-line main body text of the message.
@property (nonatomic, strong) NSString *messageText;

/// A map of actions to take when the user taps on the message, one per supported platform.
@property (nonatomic, strong) TangoActionMap *actionMap;

/// Metadata for uploaded content so that it can be manipulated if necessary on Tango's servers.
/// This is currently only used to adjust the orientation of a video.
@property (nonatomic, strong) NSDictionary *contentMetadata;

/// The handler that gets called when the message has been uploaded.
@property (nonatomic, assign) ContentUploadConversionHandler contentUploadConversionHandler;

/// The handler that gets called when progress has occurred.
@property (nonatomic, assign) MessageProgressHandler progressHandler;

/// The handler that gets called when the message has been sent.
@property (nonatomic, assign) MessageHandler resultHandler;

/** Set the thumbnail's URL.
    @param URL   The thumbnail's URL.
    */
- (void)setThumbnailWithURL:(NSURL *)URL;

/** Set the thumbnail's information.
    @param data   The thumbnail's data.
    @param mime   The thumbnail's MIME type.
    */
- (void)setThumbnailWithData:(NSData *)data mime:(NSString *)mime;

/** Set the content's information.
    @param data           The content's data.
    @param mime           The content's MIME type.
    @param actionPrompt   The action prompt users will see.
    */
- (void)setContentWithData:(NSData *)data mime:(NSString *)mime actionPrompt:(NSString *)actionPrompt;

/** Set the content's upload handler which can be used for chunked uploads.
    @param contentUploadHandler   The handler that fills the buffer with the content's bytes for asynchronous upload.
    @param mime                   The content's MIME type.
    @param contentLengthHint      The length of the data to upload.
    @param actionPrompt           The action prompt users will see.
    */
- (void)setContentWithUploadHandler:(AsyncUploadHandler)contentUploadHandler mime:(NSString *)mime
                         lengthHint:(NSUInteger)contentLengthHint actionPrompt:(NSString *)actionPrompt;

@end
