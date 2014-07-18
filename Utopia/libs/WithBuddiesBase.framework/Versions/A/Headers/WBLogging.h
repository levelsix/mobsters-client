//
//  WBLogging.h
//  WithBuddiesCore
//
//  Created by odyth on 6/25/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WithBuddiesBase/WBLogLevel.h>
#import <WithBuddiesBase/WBLogType.h>

extern NSString *const WBLogRecievedNotification;
extern NSString *const WBLogRecievedNotificationLogKey;

@interface WBLogging : NSObject

+(WBLogging *)logger;
-(NSMutableArray *)logMessagesForLevel:(WBLogLevel)logLevel;
-(NSMutableArray *)logMessagesForLevel:(WBLogLevel)logLevel type:(WBLogType)type;
-(void)clear;
-(void)clearType:(WBLogType)type;

@end

#if defined(DEBUG) || defined(ADHOC)

void _WBLog(WBLogLevel level, WBLogType logType, id obj, NSString *file, int line, NSString *message);

#define CoreLog(level, message, ... ) _WBLog(level, WBLogTypeNone, self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(message), ##__VA_ARGS__] )

#define CoreLogType(level, type, message, ... ) _WBLog(level, type, self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(message), ##__VA_ARGS__] )

#else

#define CoreLog(level, message, ... )
#define CoreLogType(level, type, message, ... )

#endif