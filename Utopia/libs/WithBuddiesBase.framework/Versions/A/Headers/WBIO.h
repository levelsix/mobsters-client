//
//  WBIO.h
//  WithBuddiesCore
//
//  Created by odyth on 8/19/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <WithBuddiesBase/WBService.h>

@class WBFileStream;
@interface WBIO : WBService

+(NSURL *)documentsDirectory;
+(NSURL *)cacheDirectory;
+(NSURL *)cacheSubDirectory:(NSString *)subDirectory;
+(NSURL *)downloadDirectory;

+(NSURL *)filePathForUrl:(NSString *)url useTemporaryStorage:(BOOL)useTemporaryStorage;
+(BOOL)removeContentForUrl:(NSString *)url useTemporaryStorage:(BOOL)useTemporaryStorage;
+(WBFileStream *)fileStreamForUrl:(NSURL *)url useTemporaryStorage:(BOOL)useTemporaryStorage;

+(BOOL)removeAllFilesInDirectory:(NSURL *)directory error:(NSError **)error;
+(BOOL)removeDirectory:(NSURL *)directory error:(NSError **)error;
+(BOOL)removeAllFiles:(NSError **)error;

@end
