//
//  NSObject+ShouldExecute.h
//  WithBuddiesCore
//
//  Created by justin stofle on 5/24/12.
//  Copyright (c) 2012 WithBuddies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ShouldExecute)

+(BOOL)shouldExecute:(NSTimeInterval)executionInterval;
+(BOOL)shouldExecute:(NSTimeInterval)executionInterval withParameter:(NSObject *)obj;
+(void)executed;

@end
