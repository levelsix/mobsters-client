//
//  LoadingViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/14/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "LoadingViewController.h"

#define SECONDS_PER_PART 5.f

@implementation LoadingViewController

- (id) initWithPercentage:(float)percentage {
  if ((self = [super init])) {
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    _initPercentage = percentage;
  }
  return self;
}

- (void) viewDidLoad {
  self.loadingBar.percentage = _initPercentage;
}

- (void) progressToPercentage:(float)percentage {
  [UIView animateWithDuration:SECONDS_PER_PART animations:^{
    self.loadingBar.percentage = percentage;
  }];
}

- (void) setPercentage:(float)percentage {
  self.loadingBar.percentage = percentage;
}

- (BOOL) prefersStatusBarHidden {
  return YES;
}

@end
