//
//  WBFileStream.h
//  WithBuddiesCore
//
//  Created by odyth on 8/19/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBFileStream : NSObject

@property (nonatomic, copy, readonly) NSURL *filePath; //nil until the stream prcess has completed successfully, same file that is returned by completion handler

/*!
 *   Keep in mind that the completion handler may be called on a thread other than the one originally used to invoke the method. This means that the code in your block needs to be thread-safe.
 */
@property (nonatomic, copy) void(^completionHandler)(NSURL *filePath, NSError *error);

-(id)initWithFilePath:(NSURL *)path;
-(id)initWithFilePath:(NSURL *)path tempPath:(NSURL *)tempPath;
-(long long)checkPartialDownloadOffset;
-(void)beginWriteOperationWithExpectedLength:(long long)expectedContentLength offset:(long long)offset;
-(void)writeData:(NSData *)data;
-(void)close;
-(void)cancel;

@end
