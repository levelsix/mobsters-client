//
//  WBNetworkService.h
//  WithBuddiesBase
//
//  Created by odyth on 10/7/13.
//  Copyright (c) 2013 scopely. All rights reserved.
//

#import <WithBuddiesBase/WBService.h>
#import <WithBuddiesBase/WBDownloadableContent.h>
#import <WithBuddiesBase/WBDownloadOperation.h>
#import <WithBuddiesBase/Reachability.h>

extern NSString *const WBNetworkServiceNetworkStatusChangedNotification;
extern NSString *const WBNetworkServiceNetworkStatusChangedNotificationStatusKey;
extern NSString *const WBNetworkServiceNetworkStatusChangedNotificationPreviousStatusKey;

@interface WBNetworkService : WBService

+(NetworkStatus)networkStatus;
+(BOOL)online;
+(NSThread *)networkThread;
+(NSOperationQueue *)networkOperationQueue;

@end

@interface WBNetworkService (Downloading)

/*!
 *  @function
 *  downloadContentSynchronously:error
 *
 *  @abstract
 *  downloads content in an asynchronous fashion
 *
 *  @discussion
 *  content will be downloaded in the background and controll will be returned to your program.  Once the content has finished your completion handler will be called.
 *
 *  @param content           content to download
 *  @param progressHandler   block to receive progress updates on, this is called on the main thread
 *  @param completionHandler block to receive completion of download, this is called on the main thread
 */
+(void)downloadContent:(id<WBDownloadableContent>)content progressHandler:(WBDownloadOperationProgressHandler)progressHandler completionHandler:(WBDownloadOperationCompletionHandler)completionHandler;

/*!
 *  @function
 *  downloadContentSynchronously:error
 *
 *  @abstract
 *  downloads content in a synchronous fashion
 *
 *  @discussion
 *  This is a blocking call.
 *
 *  @param content content do download
 *  @param error   an out error parameter if something goes wrong
 *
 *  @return the path on disk of where the content was downloaded too
 */
+(NSURL *)downloadContentSynchronously:(id<WBDownloadableContent>)content error:(NSError **)error;

@end


@interface WBNetworkService (Background)

+(void)enqueueContentForBackgroundDownload:(id<WBDownloadableContent>)content;

@end
