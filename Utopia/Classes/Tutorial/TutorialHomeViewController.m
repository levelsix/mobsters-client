//
//  TutorialHomeViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 7/4/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialHomeViewController.h"

@interface TutorialHomeViewController ()

@end

@implementation TutorialHomeViewController

- (id) initWithSubViewController:(PopupSubViewController *)svc {
  if ((self = [super initWithNibName:@"HomeViewController" bundle:nil])) {
    self.mainViewControllers = @[svc];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  NSArray *svs = self.selectorView.subviews;
  for (UIView *v in svs) {
    if (v != self.curHomeTitleView) {
      [v removeFromSuperview];
    }
  }
}

- (void) loadMainViewControllers {
  // Already loaded
}

@end
