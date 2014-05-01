//
//  MiniJobsViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 5/1/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MiniJobsViewController.h"
#import "Globals.h"
#import "GameState.h"

@implementation MiniJobsViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.listViewController = [[MiniJobsListViewController alloc] init];
  [self addChildViewController:self.listViewController];
  [self.containerView addSubview:self.listViewController.view];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (IBAction) closeClicked:(id)sender {
  [self close];
}

- (void) close {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

@end
