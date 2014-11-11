//
//  TangoLeaderboard.h
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

@class TangoLeaderboardRequest; // See TangoLeaderboardRequest.h

/** This represents the result of a leaderboard fetch operation, providing convenient ways to
    access the entries and determine the current user's position in the results.
    */
@interface TangoLeaderboardResult : NSObject

/// An array representing ranked leaderboard entries.
@property (nonatomic, readonly) NSArray * entries;
/// The current user's position in the entries array.
@property (nonatomic, readonly) NSInteger myPosition;

@end

typedef void (^LeaderboardResultHandler)(TangoLeaderboardResult * result, NSError * error);

/** Deprecated. The handler used once the leaderboard metrics have been fetched. The handler
    will run on the global queue. Used in deprecated method [TangoLeaderboard fetch:withHandler:].
    @param  metrics      An array of the TangoLeaderboardEntry results.
    @param  error        The error object, with an error code of 0 on success.
 */
typedef void (^LeaderboardHandler)(NSArray *entries, NSError *error);


/** Use this class to perform the actual send or fetch operations for leaderboards, together with
    TangoLeaderboardResult and TangoLeaderboardRequest.
    */
@interface TangoLeaderboard : NSObject

/** Fetch the leaderboard metrics for the specified parameters and sorting order.
    @param  request   Specifies the metrics that should be sent.
    @param  handler   The handler that gets executed once the asynchronous request is completed.
 */
+ (void)sendRequest:(TangoLeaderboardRequest *)request withHandler:(LeaderboardResultHandler)handler;


/** Deprecated. Use +[TangoLeaderboard sendRequest:withHandler] instead.    
    Fetch the leaderboard metrics for the specified parameters and sorting order.

    @param  request   Specifies the metrics that should be fetched for the request.
    @param  handler   The handler that gets executed once the asynchronous request is completed.
 */
+ (void)fetch:(TangoLeaderboardRequest *)request withHandler:(LeaderboardHandler)handler __attribute__((deprecated));

@end
