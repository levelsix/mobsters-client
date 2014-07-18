//
//  WBDBCache.h
//  WithBuddiesCore
//
//  Created by odyth on 7/17/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <WithBuddiesBase/WBCache.h>

@interface WBDiskBasedCache : WBCache

+(id)objectForKey:(WBCacheKey *)key;
+(void)setObject:(id<NSCoding>)obj forKey:(WBCacheKey *)key;
+(void)flush;

@end
