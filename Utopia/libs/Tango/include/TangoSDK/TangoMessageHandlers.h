//
//  TangoMessageHandlers.h
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

/// Result handler for message send. Error code is 0 on success.
typedef void (^MessageHandler)(NSError *error);

/// Progress handler for message send. Only applicable when uploading data.
typedef void (^MessageProgressHandler)(NSUInteger bytesSent);

/// Handler to fill buffer with bytes for asynchronous upload. Return one of the READ_ values
/// below, or the number of bytes read. Once you mark reading finished, the handler will be called
/// one last time with a NULL buffer to indicate that it is safe to clean up.
typedef ssize_t (^AsyncUploadHandler)(unsigned char *buffer, size_t bufferSize);

/// Return value for AsyncUploadHandler when all bytes have been read successfully.
extern const ssize_t TANGO_SDK_READ_FINISHED;
/// Return value for AsyncUploadHandler when there was an error.
extern const ssize_t TANGO_SDK_READ_FAILED;

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
/// Converter to go from content upload results to a TangoActionMap if you need to open
/// uploaded content in your own app instead of Tango, or massage the URLs in some fashion.
/// Use the keys below to index into the dictionary.
typedef TangoActionMap * (^ContentUploadConversionHandler)(NSDictionary *contentDetails);
#pragma GCC diagnostic pop

// Keys for ContentUploadConversionHandler
extern NSString * kContentURLKey; ///< ContentUploadConversionHandler key for main content URL.
extern NSString * kContentThumbnailURLKey; ///< ContentUploadConversionHandler key for thumbnail URL.
extern NSString * kContentMimeType; ///< ContentUploadConversionHandler key for main content mime.
extern NSString * kContentThumbnailMimeTypeKey; ///< ContentUploadConversionHandler key for thumbnail mime.
