//
//  UILabel+ResizeFontToFit.h
//  WithBuddiesCore
//
//  Created by odyth on 10/1/12.
//  Copyright (c) 2012 WithBuddies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (ResizeFontToFit)

-(void)resizeFontToFit:(int)maxSize minSize:(int)minSize;
- (void)resizeFontToFit;

@end
