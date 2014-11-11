//
//  NSString+URLEncoding.h
//  WithBuddiesCore
//
//  Created by Michael Gao on 5/8/14.
//  Copyright (c) 2014 WithBuddies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLEncoding)

+ (NSString *)urlEncodeValue:(NSString *)str;
- (NSString *)urlEncode;

@end
