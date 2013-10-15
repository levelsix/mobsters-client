//
//  LoadingViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/14/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "LoadingViewController.h"

#define SECONDS_PER_PART 10.f

@implementation LoadingViewController

- (id) init
{
    self = [super init];
    if (self) {
        // Custom initialization
      self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (void) viewDidLoad {
  self.loadingBar.percentage = 0.f;
}

- (void) progressToPercentage:(float)percentage {
  [UIView animateWithDuration:SECONDS_PER_PART animations:^{
    self.loadingBar.percentage = percentage;
  }];
}

- (BOOL) prefersStatusBarHidden {
  return YES;
}

@end
