//
//  ImageDownloader.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/14/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BgdFileDownload : NSObject

@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, assign) BOOL onlyUseWifi;

@end

@interface DownloaderLoadingView : UIView

@property (nonatomic, retain) IBOutlet UIView *darkView;
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *actIndView;

@end

@interface Downloader : NSObject {
  dispatch_queue_t _syncQueue;
  dispatch_queue_t _asyncQueue;
  dispatch_queue_t _bgdQueue;
  NSString *_cacheDir;
  
  NSMutableArray *_bgdFilesToDownload;
}

@property (nonatomic, retain) IBOutlet DownloaderLoadingView *loadingView;
@property (nonatomic, retain) NSMutableArray *bgdFilesToDownload;

+ (Downloader *) sharedDownloader;

- (NSString *) syncDownloadFile:(NSString *)fileName;
- (void) asyncDownloadFile:(NSString *)imageName completion:(void (^)(BOOL success))completed;
- (void) syncDownloadBundle:(NSString *)bundleName;
- (void) asyncDownloadBundle:(NSString *)bundleName;

- (void) purgeAllDownloadedData;
- (void) deleteFile:(NSString *)file;

- (void) backgroundDownloadFiles:(NSArray *)fileNames;

@end
