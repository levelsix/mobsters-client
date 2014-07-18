//
//  WBTime.h
//  WithBuddiesCore
//
//  Created by odyth on 7/17/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, WBTime)
{
    WBTimeOneMinute = 60,
    WBTimeFifteenMinutes = 900,
    WBTimeOneHour = 3600,
    WBTimeOneDay = 86400,
    WBTimeOneWeek = 604800,
    WBTimeTwoWeek = 1209600,
    WBTimeOneMonth = 2678400
};

extern const int64_t    WBTimeTicksPerMillisecond;
extern const double     WBTimeMillisecondsPerTick;
extern const int64_t    WBTimeTicksPerSecond;
extern const double     WBTimeSecondsPerTick;
extern const int64_t    WBTimeTicksPerMinute;
extern const double     WBTimeMinutesPerTick;
extern const int64_t    WBTimeTicksPerHour;
extern const double     WBTimeHoursPerTick;
extern const int64_t    WBTimeTicksPerDay;
extern const double     WBTimeDaysPerTick;
extern const int        WBTimeMillisPerSecond;
extern const int        WBTimeMillisPerMinute;
extern const int        WBTimeMillisPerHour;
extern const int        WBTimeMillisPerDay;
extern const int64_t    WBTimeMaxSeconds;
extern const int64_t    WBTimeMinSeconds;
extern const int64_t    WBTimeMaxMilliSeconds;
extern const int64_t    WBTimeMinMilliSeconds;
extern const int64_t    WBTimeTicksPerTenthSecond;