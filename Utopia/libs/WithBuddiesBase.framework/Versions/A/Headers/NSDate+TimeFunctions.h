//
//  NSDate+TimeFunctions.h
//  WithBuddiesCore
//
//  Created by justin stofle on 4/17/12.
//  Copyright (c) 2012 WithBuddies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (TimeFunctions)

/// returns true if self has elapsed
-(BOOL)hasElapsed;

/// returns time interval from current date until self
-(NSTimeInterval)timeUntil;

/** returns a formatted time until self
 *  returns:
 *      "expired" - if self has elapsed
 *      "less than a minute" - if timeUntil is less than a minute
 *      "%d minute/s" - if timeUntil is less than an hour
 *      "%d hour/s" - if timeUntil is less than a day
 *      "%d day/s" - if timeUntil is greater than or equal to a day
 */
-(NSString *)formattedTimeUntil;

/** returns a formatted date until self
 *  parameters: 
 *      (NSInteger)granularity - how many units you want to see starting from days to seconds. bounded to range [0, 4]
 *  returns:
 *      "expired" - if self has elapsed
 *      "%d day/s, %d hour/s, %d minute/s, %d seconds/s" - starts from the first non-zero value and granularity units
 */
- (NSString *)formattedTimeUntilWithGranularity:(NSInteger)granularity;

/** returns a formatted date until self
 *  returns:
 *      "%02d:%02d:%02d left" - hours, minutes, seconds until self
 */
-(NSString *)timeLeft;

/// returns time interval from current date since self
-(NSTimeInterval)timeSince;

/** returns a formatted time since self
 *  returns:
 *      "less than a minute" - if timeSince is less than a minute ago
 *      "%d minute/s ago" - if timeSince is less than an hour ago
 *      "%d hour/s ago" - if timeSince is less than a day ago
 *      "%d day/s ago" - if timeSince is less than two weeks ago
 *      "more than 2 weeks ago" - if timeSince is more than or equal to two weeks ago
 */
-(NSString *)formattedTimeSince;

/**
 * @abstract
 * Considers two NSDate objects equal if they're no more than 0.0001 seconds apart.
 *
 * @discussion
 * Two dates created from the same data can have slightly different distances from the Unix epoch,
 * For example: date 1 = 425976600, date 2 = 425976600.00000298
 */
-(BOOL)isRoughlyEqualToDate:(NSDate*)comparableDate;

@end
