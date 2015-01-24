//
//  TangoGifting.h
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
#import <TangoSDK/TangoGiftingResponse.h>


/** Use this API to send and receive gifts using Tango services. Gifts are
    automatically persisted by Tango servers until you consume them. You can
    also filter friends to send gifts to based upon provisioned rate limiting.
    */
@interface TangoGifting : NSObject

/// Fetch all of the user's gifts (specific to your app) that have not already
/// been consumed.
+ (void)fetchGiftsWithHandler:(TangoGiftingFetchGiftsHandler)handler;

/// Consume gifts that have been fetched by providing an array of the gift IDs
/// as NSStrings. Gifts that have been consumed will no longer appear in calls
/// to fetchGiftsWithHandler:.
+ (void)consumeGifts:(NSArray *)giftIds handler:(TangoGiftingConsumeGiftsHandler)handlerOrNil;

/// Fetch the list of friends that you can send gifts to, with the given resource ID.
/// The result is the same as for [TangoProfile fetchMyCachedFriendsWithHandler:].
+ (void)fetchProfilesWithinLimitsForResourceId:(NSString *)resourceIdOrNil
                                       handler:(TangoGiftingFetchProfilesHandler)handler;

/// Send gifts to a list of recipients using the given resource ID to determine
/// rate limiting. The result may include a list of recipients who could not
/// receive the gift.
+ (void)sendGiftToRecipients:(NSArray *)recipientAccountIds
              withResourceId:(NSString *)resourceId
                     handler:(TangoGiftingSendGiftHandler)handlerOrNil;

@end
