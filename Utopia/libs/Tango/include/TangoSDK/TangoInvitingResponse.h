//
//  TangoInvitingResponse.h
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
#import <TangoSDK/TangoProfileResult.h>

#pragma mark - Response Classes

/// Response container when fetching rate-limited profiles for TangoInviting.
@interface TangoInvitingFetchProfilesResponse : NSObject
/// An array of user profiles for users who can receive invitations.
@property (nonatomic, strong) TangoProfileResult *filteredProfiles;
@end


/// Response container when sending invitations to Tango users via TangoInviting.
@interface TangoInvitingSendInvitationsResponse : NSObject
/// An array of Tango account identifier strings for those that could not be sent invitations.
@property (nonatomic, strong) NSArray *failedAccountIds;
@end


#pragma mark - Handler Types

typedef void (^TangoInvitingFetchProfilesHandler)(TangoInvitingFetchProfilesResponse *response,
                                                  NSError *error);

typedef void (^TangoInvitingSendInvitationsHandler)(TangoInvitingSendInvitationsResponse *response,
                                                    NSError *error);
