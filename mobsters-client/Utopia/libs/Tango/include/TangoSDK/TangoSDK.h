//
//  TangoSDK.h
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


/*********************************************************************************
 *                                                                               *
 * TangoSDK.h is the topmost include file for the Tango SDK Objective-C binding. *
 * You generally only need to include this file to use all of the features in    *
 * the SDK. If you need help, please consult the SDK Documentation or send       *
 * e-mail to sdksupport@tango.me.                                                *
 *                                                                               *
 * #import <TangoSDK/TangoSDK.h>                                                 *
 *                                                                               *
 *********************************************************************************/


#ifndef __IPHONE_5_0
#warning "This library uses features only available in iOS SDK 5.0 and later."
#endif

#ifdef __OBJC__
  // Core
  #import "TangoTypes.h"
  #import "TangoSession.h"
  #import "TangoError.h"
  #import "TangoLaunchContext.h"

  // Profile API
  #import "TangoProfile.h"
  #import "TangoProfileResult.h"
  #import "TangoProfileEntry.h"

  // Messaging API
  #import "TangoMessaging.h"
  #import "TangoMessage.h"

  // Metrics API
  #import "TangoMetrics.h"
  #import "TangoMetric.h"
  #import "TangoMetricsGetRequest.h"
  #import "TangoMetricsSetRequest.h"

  // Leaderboard API
  #import "TangoLeaderboard.h"
  #import "TangoLeaderboardEntry.h"
  #import "TangoLeaderboardRequest.h"

  // Possessions API
  #import "TangoPossessions.h"
  #import "TangoPossession.h"
  #import "TangoPossessionResult.h"

  // Sharing API
  #import "TangoSharing.h"
  #import "TangoSharingData.h"

  // Tools
  #import "TangoTools.h"

#endif
