//
//  UIImage+BundleImage.h
//  WithBuddiesCore
//
//  Created by Max Goedjen on 8/7/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BundleImage)

+ (UIImage *)imageNamed:(NSString *)name bundle:(NSBundle *)bundle;

@end
