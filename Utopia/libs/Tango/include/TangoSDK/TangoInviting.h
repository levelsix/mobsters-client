//
//  TangoInviting.h
//  TangoSDK
//
// -*- ObjC -*-
// Copyright 2014, TangoMe Inc ("Tango").  The SDK provided herein includes
// software and other technology provided by Tango that is subject to copyright and
// other intellectual property protections. All rights reserved.  Use only in
// accordance with the Evaluation License Agreement provided to you by Tango.
//
// Please read Tango_SDK_Evaluation_License_agreement_v1-2.docx
//

#import <Foundation/Foundation.h>
#import <TangoSDK/TangoError.h>
#import <TangoSDK/TangoInvitingResponse.h>

/** Use this API to send invitations to other users, with the ability to provide rewards
    when the invitation is accepted. (The latter must be configured in provisioning data).
    */
@interface TangoInviting : NSObject

/// Fetch Tango profiles for users who can currently receive an invitation with the given resource id.
+ (void)fetchProfilesWithinLimitsForResourceId:(NSString *)resourceIdOrNil
                                       handler:(TangoInvitingFetchProfilesHandler)handler;

/// Send an invitation to Tango accounts, using the given resource id to provide rate-limiting and
/// rewards when the invitation is accepted.
+ (void)sendInvitationToRecipients:(NSArray *)recipientAccountIds
                        resourceId:(NSString *)resourceIdOrNil
                           handler:(TangoInvitingSendInvitationsHandler)handlerOrNil;

@end
