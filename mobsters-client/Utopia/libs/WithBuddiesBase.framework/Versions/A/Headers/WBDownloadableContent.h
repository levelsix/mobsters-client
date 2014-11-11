//
//  WBDownloadableContent.h
//  WithBuddiesCore
//
//  Created by odyth on 8/30/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WBDownloadableContent <NSObject>

@required
-(BOOL)hasDownloadableContent;
-(NSURL *)contentPath;
-(NSString *)contentUrl;

/*!
 *  @abstract
 *  This checks if the item is available on disk (already downloaded)
 */
-(BOOL)isContentAvailable;

/*!
 *  @abstract
 *  Determines the final destination of where the content will reside
 *
 *  @return YES if you wish for it to live in cache directory NO for documents directory
 */
-(BOOL)useTemporaryStorage;

@optional
-(NSString *)contentPreviewUrl;
-(NSString *)contentThumbnailUrl;

/*!
 *  @abstract
 *  A Boolean value that determines whether connections should be made over a cellular network to download this content.
 */
-(BOOL)allowsCellularAccess;

@end
