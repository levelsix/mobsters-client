//
//  TangoLeaderboardEntry.h
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

@class TangoProfileEntry;


/** Represents an entry in a leaderboard, complete with a reference to that user's profile
    information, and the metrics you requested.
    */
@interface TangoLeaderboardEntry : NSObject

/// The profile that owns this Leaderboard entry.
@property (nonatomic, strong) TangoProfileEntry *profile;

/// The computed metrics for this Leaderboard entry.
@property (nonatomic, strong) NSArray *metrics;

/** Create a new leaderboard entry.
    @param  profile  The profile that owns this Leaderboard entry.
    @param  metrics  The computed metrics for this Leaderboard entry.
 */
+ (TangoLeaderboardEntry *)leaderboardEntryWithProfile:(TangoProfileEntry *)profile metrics:(NSArray *)metrics;

@end
