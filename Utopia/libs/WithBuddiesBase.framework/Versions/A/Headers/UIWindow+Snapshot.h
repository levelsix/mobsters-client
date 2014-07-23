//
//  UIWindow+Snapshot.h
//  WithBuddiesBase
//
//  Created by Michael Gao on 7/16/14.
//  Copyright (c) 2014 scopely. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (Snapshot)

- (UIImage *)snapshotImage;
- (UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates;

@end
