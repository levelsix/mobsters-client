//
//  MSDate.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/20/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSDate : NSObject

@property (nonatomic, retain) NSDate *underlyingDate;

- (NSComparisonResult) compare:(MSDate *)date;
- (BOOL) isEqualToDate:(MSDate *)date;

- (MSDate *) dateByAddingTimeInterval:(NSTimeInterval)timeInterval;
- (NSTimeInterval) timeIntervalSinceNow;
- (NSTimeInterval) timeIntervalSinceDate:(MSDate *)date;
- (NSTimeInterval) timeIntervalSince1970;

// This is the date with delta applied.
- (NSDate *) relativeNSDate;
// This is the actual date relative to phone's current date. (Should only really be used for local notifications.)
// i.e. if phone time is Jan 1 and server time is Jan 3, and this date represents Jan 4 in game time, this method
// will return Jan 2.
- (NSDate *) actualNSDate;

+ (MSDate *) date;
+ (MSDate *) dateWithTimeIntervalSinceNow:(NSTimeInterval)timeInterval;
+ (MSDate *) dateWithTimeIntervalSince1970:(NSTimeInterval)timeInterval;
+ (MSDate *) dateWithTimeInterval:(NSTimeInterval)timeInterval sinceDate:(MSDate *)date;
+ (void) setServerTime:(uint64_t)time;

@end
