//
//  UIDevice+ScreenSize.h
//  WithBuddiesCore
//
//  Created by Max Goedjen on 10/3/12.
//  Copyright (c) 2012 WithBuddies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (ScreenSize)

- (BOOL)tallScreen;
- (BOOL)shouldEnableRetina;

@end
