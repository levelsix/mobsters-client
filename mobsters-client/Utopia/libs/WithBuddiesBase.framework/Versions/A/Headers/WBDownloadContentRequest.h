//
//  WBDownloadContentRequest.h
//  WithBuddiesCore
//
//  Created by odyth on 9/3/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <WithBuddiesBase/WBObject.h>
#import <WithBuddiesBase/WBDownloadableContent.h>

@interface WBDownloadContentRequest : WBObject <WBDownloadableContent>

@property (nonatomic, strong, readonly) NSString *contentUrl;
@property (nonatomic, readonly) BOOL useTemporaryStorage;
@property (nonatomic, strong) NSURL *contentPath;

@end
