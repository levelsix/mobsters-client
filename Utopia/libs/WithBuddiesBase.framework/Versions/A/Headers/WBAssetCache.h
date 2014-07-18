//
//  WBAssetCacheService.h
//  WithBuddiesCore
//
//  Created by odyth on 8/19/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <WithBuddiesBase/WBService.h>

@protocol WBDownloadableContent;
@class WBFileStream;
@interface WBAssetCache : WBService

+(NSURL *)cachedFilePathForContent:(id<WBDownloadableContent>)content;
+(BOOL)removeContent:(id<WBDownloadableContent>)content error:(NSError **)error;

+(NSURL *)cachedFilePathForUrl:(NSString *)url useTemporaryStorage:(BOOL)useTemporaryStorage;
+(BOOL)removeContentForUrl:(NSString *)url useTemporaryStorage:(BOOL)useTemporaryStorage error:(NSError **)error;

/*!
 @function
 cacheFileStream:completionHandler
 
 @abstract
 caches the filestream to disk.  If the filestream had downloaded a zip file, the zipfile will be unpacked and its contents will be cached instead.
 
 @discussion
 When this method is called, it creates a new background task to handle the request. The method then returns control to your method. Later, when the task is complete, iOS Core calls your completion handler.  Keep in mind that the completion handler may be called on a thread other than the one originally used to invoke the method. This means that the code in your block needs to be thread-safe.
 */
+(void)cacheFileStream:(WBFileStream *)fileStream completionHandler:(void(^)(NSURL *filePath, NSError *error))completionHandler;
+(NSURL *)cacheFileStream:(WBFileStream *)fileStream error:(NSError **)error;

@end
