//
//  TangoMessage+private.h
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

/// @cond INTERNAL

#import "TangoMessage.h"

/** @internal
    Private inteface
    */
@interface TangoMessage ()

@property (nonatomic, strong) NSURL *thumbnailURL;
@property (nonatomic, strong) NSData *thumbnailData;
@property (nonatomic, strong) NSString *thumbnailMime;

@property (nonatomic, strong) NSData *contentData;
@property (nonatomic, strong) NSString *contentMime;
@property (nonatomic, strong) NSString *contentActionPrompt;

@property (nonatomic, assign) NSUInteger contentLengthHint;
@property (nonatomic, assign) AsyncUploadHandler contentUploadHandler;

@end

/// @endcond

