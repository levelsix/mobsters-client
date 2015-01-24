//
//  TangoSession+private.h
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

#import <tango_sdk/session.h>

#import "TangoSession.h"

/**
  Tango Session life cycle states
*/
typedef enum {
  TangoSessionStateCreated              = 0,
  TangoSessionStateInitialized          = 1,
  TangoSessionStateAuthenticated        = 2,
}TangoSessionState;


/**
  Response handler. This block is called by all Tango SDK response callback
*/
typedef void (^SDKResponseHandler)(NSString* result, NSError* error);

/// Internal convenience function to check validity of the SDK session.
extern BOOL CheckSdkSessionReady(SDKResponseHandler handler, const char *func_name);

/// Internal convenience function to create a tango_sdk::session suitable context pointer
/// from an Objective-C callback block.
extern void * SdkHandlerToContext(SDKResponseHandler handler);

/// Call an SDK handler that was wrapped into an SDK context pointer, returning ownership of the
/// block to ARC.
extern void CallSdkHandlerFromContext(void *context, NSString *json, NSError *error);

/// Return an autoreleased NSError with the matching error code.
extern NSError * SdkError(ErrorCode code);

@interface TangoSession()
/* Tango Session State */
  @property (readwrite, assign) TangoSessionState sessionState;
  @property (nonatomic, assign) tango_sdk::Session *session;
  @property (nonatomic, strong) NSString *appID;
  @property (nonatomic, strong) NSString *urlScheme;
  @property (nonatomic, assign) dispatch_queue_t progressSerialQueue;
@end
