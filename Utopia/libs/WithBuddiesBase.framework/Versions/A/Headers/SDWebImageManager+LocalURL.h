//
//  SDWebImageManager+LocalURL.h
//  WithBuddiesCore
//
//  Created by Stepan Generalov on 31.01.13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <WithBuddiesBase/SDWebImageManager.h>

@interface SDWebImageManager (LocalURL)

/** @returns File URL if image already downloaded or url itself if not. */
- (NSString *) nearestURLWithURL: (NSString *) url;

@end
