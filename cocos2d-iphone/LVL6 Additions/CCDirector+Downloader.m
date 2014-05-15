//
//  CCDirector+Downloader.m
//  cocos2d-ios
//
//  Created by Ashwin Kamath on 1/23/14.
//
//

#import "CCDirector+Downloader.h"
#import <objc/runtime.h>

static char const * kDownloaderKey = "kDownloaderKey";

@implementation CCDirector (Downloader)

@dynamic downloaderDelegate;

- (void) setDownloaderDelegate:(id<CCDirectorDownloaderDelegate>)downloaderDelegate {
  objc_setAssociatedObject(self, kDownloaderKey, downloaderDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<CCDirectorDownloaderDelegate>) downloaderDelegate {
  return (id<CCDirectorDownloaderDelegate>)objc_getAssociatedObject(self, kDownloaderKey);
}

@end
