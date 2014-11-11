//
//  DateFormatter.h
//  YachtWithFriendsPaid
//
//  Created by justin stofle on 4/9/11.
//  Copyright 2011 Justin Stofle. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol  WBGameProtocol;
@interface WBDateFormatter : NSObject


@property (nonatomic, strong) NSDateFormatter *longDateTime;
@property (nonatomic, strong) NSDateFormatter *utcDateTime;
@property (nonatomic, strong) NSDateFormatter *iso8601WithTimezoneTime;

-(NSString *)utcDateTimeString:(NSDate *)date;
-(NSString *)stringFromDate:(NSDate *)date;
+(WBDateFormatter *)sharedFormatter;

+(NSDate *)utcDateFromString:(NSString *)dateString;

/**
 * @param isoString An ISO-8601 string with timezone (eg "2013-10-27T13:41:00-07:00")
 */
+(NSDate *)dateFromIso8601String:(NSString *)isoString;

@end
