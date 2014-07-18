//
//  WBCache.h
//  WithBuddiesCore
//
//  Created by odyth on 7/15/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WithBuddiesBase/WBCacheKey.h>

typedef id(^WBCacheItemNotFoundHandler) ();

@interface WBCache : NSObject

+(id)objectForKey:(WBCacheKey *)key;
+(id)objectForKey:(WBCacheKey *)key itemNotFoundHandler:(WBCacheItemNotFoundHandler)itemNotFoundHandler;
+(void)setObject:(id)obj forKey:(WBCacheKey *)key;
+(void)removeObjectForKey:(WBCacheKey *)key;
+(void)flush;

@end
