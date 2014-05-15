//
//  CCDirector+Downloader.h
//  cocos2d-ios
//
//  Created by Ashwin Kamath on 1/23/14.
//
//

#import "CCDirector.h"

@protocol CCDirectorDownloaderDelegate <NSObject>

- (NSString *) filepathToFile:(NSString *)filename;
- (NSString *) downloadFile:(NSString *)filename;

@end

@interface CCDirector (Downloader)

@property (nonatomic, assign) id<CCDirectorDownloaderDelegate> downloaderDelegate;

@end
