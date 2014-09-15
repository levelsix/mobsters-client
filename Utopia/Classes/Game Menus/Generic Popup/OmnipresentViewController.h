//
//  OmnipresentViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/27/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OmnipresentViewController : UIViewController

- (void) displayView;
- (void) removeView;

- (CGRect) relativeFrame;

@end
