//
//  TangoGiftingResponse.h
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


/// Represents an individual gift entry sent to your user.
@interface TangoGift : NSObject
/// The account id of the user who sent the gift.
@property (nonatomic, copy) NSString *senderAccountId;
/// The time the gift was sent.
@property (nonatomic, strong) NSDate *timeSent;
/// Your custom identifier for the gift (aka gift type).
@property (nonatomic, copy) NSString *giftType;
/// Tango gift identifier.
@property (nonatomic, copy) NSString *giftId;
@end


#pragma mark - Response Classes

/// Response object returned when fetching the user's current gifts.
@interface TangoGiftingFetchGiftsResponse : NSObject
/// An array of TangoGift objects representing the gifts your user has been sent.
@property (nonatomic, strong) NSArray *gifts;
@end


/// Response object returned when consuming the user's gifts.
/// No data is passed back at this time, so this response object is just a placeholder.
/// Make sure to check the error code in the NSError object returned in your
/// TangoGiftingConsumeGiftsHandler. It should be TANGO_SDK_SUCCESS.
@interface TangoGiftingConsumeGiftsResponse : NSObject
@end


/// Response object returned when fetching a list of the user's friends to whom you
/// can send a gift, filtered for rate limiting. This uses the same data structure
/// as TangoProfile.
@interface TangoGiftingFetchProfilesResponse : NSObject
/// An array of user profiles for users who can receive gifts.
@property (nonatomic, strong) TangoProfileResult *filteredProfiles;
@end


/// Response object returned when sending a gift to the user's friends. A list of
/// failedAccountIds may be provided if gifts could not be sent to certain friends.
@interface TangoGiftingSendGiftResponse : NSObject
/// An array of Tango account identifier strings for those that could not be sent gifts.
@property (nonatomic, copy) NSArray *failedAccountIds;
@end


#pragma mark - Handler Types

typedef void (^TangoGiftingFetchGiftsHandler)(TangoGiftingFetchGiftsResponse *response,
                                              NSError *error);

typedef void (^TangoGiftingConsumeGiftsHandler)(TangoGiftingConsumeGiftsResponse *response,
                                                NSError *error);

typedef void (^TangoGiftingFetchProfilesHandler)(TangoGiftingFetchProfilesResponse *response,
                                                 NSError *error);

typedef void (^TangoGiftingSendGiftHandler)(TangoGiftingSendGiftResponse *response, NSError *error);
