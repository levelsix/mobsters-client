//
//  PopupSubViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/20/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupNavViewController.h"

@interface PopupSubViewController : UIViewController

// Used by Home view controller
@property (nonatomic, retain) NSAttributedString *attributedTitle;
@property (nonatomic, retain) NSString *titleImageName;

@property (nonatomic, readonly) PopupNavViewController *parentViewController;

- (BOOL) canGoBack;
- (BOOL) canClose;

@end
