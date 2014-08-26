//
//  TangoLaunchContext
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

/** TangoLaunchContext has been deprecated and will be removed. It was never supported. */

__attribute__ ((deprecated))
@interface TangoLaunchContext : NSObject

@property (nonatomic, readonly) NSString *intent;

@property (nonatomic, readonly) NSArray *conversationParticipants;

- (TangoLaunchContext *)initWithIntent:(NSString *)intent conversationParticipants:(NSArray *)participants;

@end
