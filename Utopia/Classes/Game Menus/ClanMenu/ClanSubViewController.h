//
//  ClanSubViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/12/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClanViewController.h"

//@class ClanViewController;

@interface ClanSubViewController : UIViewController

@property (nonatomic, readonly) ClanViewController *parentViewController;

- (BOOL) canGoBack;
- (BOOL) canClose;

@end
