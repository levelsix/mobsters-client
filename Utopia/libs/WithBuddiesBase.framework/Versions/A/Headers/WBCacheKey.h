//
//  WBCacheKey.h
//  WithBuddiesCore
//
//  Created by odyth on 7/15/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBCacheKey : NSObject

+(WBCacheKey *)cacheKeyForDomain:(NSString *)domain key:(NSString *)key;
+(WBCacheKey *)cacheKeyForDomain:(NSString *)domain key:(NSString *)key version:(int)version;

@end
