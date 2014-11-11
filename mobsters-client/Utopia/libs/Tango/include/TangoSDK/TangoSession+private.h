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


@interface TangoSession()
/* Tango Session State */
  @property (readwrite, assign) TangoSessionState sessionState;
  @property (nonatomic, assign) tango_sdk::Session *session;
  @property (nonatomic, strong) NSString *appID;
  @property (nonatomic, strong) NSString *urlScheme;
  @property (nonatomic, assign) dispatch_queue_t progressSerialQueue;
@end
