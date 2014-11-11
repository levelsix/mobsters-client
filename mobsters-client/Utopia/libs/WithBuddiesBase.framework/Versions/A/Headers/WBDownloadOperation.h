//
//  WBDownloadOperation.h
//  WithBuddiesBase
//
//  Created by odyth on 10/7/13.
//  Copyright (c) 2013 scopely. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBDownloadOperation : NSOperation

typedef void(^WBDownloadOperationProgressHandler)(WBDownloadOperation *download, float progress);
typedef void(^WBDownloadOperationCompletionHandler)(WBDownloadOperation *download, NSURL *filePath, NSError *error);

@property (nonatomic, strong, readonly) NSString *uuid;

@end
