//
//  UIColor+ConvertToImage.h
//  WithBuddiesCore
//
//  Created by Michael Gao on 6/26/13.
//  Copyright (c) 2013 WithBuddies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ConvertToImage)

+ (UIImage *)imageWithColor:(UIColor *)color;

-(UIImage *)image;

@end
