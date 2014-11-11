//
//  TangoJSONSerialization.h
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

/** Provides a standard interface for serializing an object to a JSON string, used
    in several SDK classes.
    */
@protocol TangoJSONSerialization <NSObject>
@required

/// Implement this and return a JSON string representation of the object.
@property (nonatomic, readonly) NSString *jsonString;

@end
