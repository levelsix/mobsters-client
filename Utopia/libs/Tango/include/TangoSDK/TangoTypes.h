//
//  TangoTypes.h
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


/// Identifiers for SDK-supported platforms. Use this in Actions for TangoMessaging,
/// and to identify supported platforms in a user's profile, etc. This enum is a
/// duplicated of tango_sdk/message.h, but is provided here to avoid the need to
/// compile as Objective-C++.
typedef enum {
  TangoSdkPlatformAny = 0,      ///< Deprecated. Renamed to TangoSdkPlatformFallback for clarity.

  TangoSdkPlatformFallback = 0, ///< The fallback for when the message must be displayed on an unsupported platform.
  TangoSdkPlatformIOS,          ///< Platform type for iOS devices.
  TangoSdkPlatformAndroid       ///< Platform type for Android devices.
} TangoSdkPlatform;

/// Identifiers for a TangoProfileEntry's gender.
typedef enum {
  TangoSdkGenderUnknown,    ///< Gender not set or not known.
  TangoSdkGenderMale,       ///< Gender is male.
  TangoSdkGenderFemale      ///< Gender is female.
} TangoSdkGender;