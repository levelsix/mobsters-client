//
//  LabViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/28/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EvoViewController.h"
#import "EnhanceViewController.h"

@interface LabViewController : GenViewController 

@property (nonatomic, retain) EvoViewController *evoViewController;
@property (nonatomic, retain) EnhanceViewController *enhanceViewController;

@property (nonatomic, retain) IBOutlet FlipTabBar *menuTopBar;

@end
