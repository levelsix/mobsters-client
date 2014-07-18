//
//  WBTimeSpan.h
//  WithBuddiesCore
//
//  Created by odyth on 7/17/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <WithBuddiesBase/WBObject.h>

@interface WBTimeSpan : WBObject

+(WBTimeSpan *)maxValue;
+(WBTimeSpan *)minValue;
+(WBTimeSpan *)fromTicks:(int64_t)ticks;
+(WBTimeSpan *)timeSpanWithTimeInterval:(NSTimeInterval)timeInterval;
+(WBTimeSpan *)timeSpanWithHours:(int)hours minutes:(int)minutes seconds:(int)seconds;
+(WBTimeSpan *)timeSpanWithDay:(int)days hours:(int)hours minutes:(int)minutes seconds:(int)seconds;
+(WBTimeSpan *)timeSpanWithDay:(int)days hours:(int)hours minutes:(int)minutes seconds:(int)seconds milliseconds:(int)milliseconds;
/// {days}?d {hours}?h {minutes}?m {seconds}?s, all units are optional but only the 2 largest units are included, eg 2d 34s
+(NSString *)daysHoursMinutesSecondsStringFromTimeInterval:(NSTimeInterval)interval;

-(int)days;
-(int)hours;
-(int)minutes;
-(int)seconds;
-(int)milliseconds;
-(int64_t)ticks;
-(double)totalDays;
-(double)totalHours;
-(double)totalMinutes;
-(double)totalSeconds;
-(double)totalMilliseconds;
-(NSTimeInterval)timeInterval;
-(WBTimeSpan *)addTimeSpan:(WBTimeSpan *)timeSpan;
-(WBTimeSpan *)addTicks:(int64_t)ticks;
-(NSString *)daysHoursMinutesSecondsString;

@end

@interface NSString (TimeSpanValue)

/**
 *  @abstract Will parse [days.]hours:minutes[:seconds[.ff]]
 *
 *  @discussion
 *      examples
 *      5:35             5 minutes, 35 seconds
 *      1:05:35          1 hour, 5 minutes, 35 seconds
 *      1.12:00          1 day, 12 hours
 *      1:23.456         1 minute, 23 seconds, 456 miliseconds
 *      2.06:31:24       2 days, 6 hrs, 31 min, 24 sec
 *      3.18:24:35.010   3 days, 18 hrs, 24 min, 35 sec, 10 millis
 *
 *  @return A WBTimeSpan representing the string, parsed as [days.]hours:minutes[:seconds[.fractional]].
 */
-(WBTimeSpan *)timeSpanValue;

@end