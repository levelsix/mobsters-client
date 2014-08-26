//
//  TangoSharing.h
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
#import <TangoSDK/TangoError.h>
#import <TangoSDK/TangoSharingData.h>

/// Result handler for TangoSharing. See error_codes.h for possible error codes.
typedef void (^TangoSharingHandler)(NSError *error);


/** API for sharing content via different display targets in Tango. Use with
    TangoSharingData to send messages or post to a user's feed.
    */
@interface TangoSharing : NSObject

/** Asynchronously share some content through Tango, based on the TangoSharingData
    instance that you provide. To determine if the content was sent successfully, check
    the error code returned to your callback handler for TANGO_SDK_SUCCESS.
    */
+ (void)share:(TangoSharingData *)shareData handler:(TangoSharingHandler)handlerOrNil;

@end
