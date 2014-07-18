//
//  WBAdLog.h
//  WithBuddiesCore
//
//  Created by Michael Gao on 6/17/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WithBuddiesBase/WBLogLevel.h>
#import <WithBuddiesBase/WBLogType.h>

@interface WBLog : NSObject

@property (nonatomic) WBLogLevel level;
@property (nonatomic) WBLogType type;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *lineNumber;
@property (nonatomic) NSTimeInterval timestamp;

+(id)logWithLevel:(WBLogLevel)level message:(NSString *)message;
+(id)logWithLevel:(WBLogLevel)level type:(WBLogType)type message:(NSString *)message;
+(id)logWithLevel:(WBLogLevel)level type:(WBLogType)type lineNumber:(NSString *)lineNumber message:(NSString*)message;


@end
