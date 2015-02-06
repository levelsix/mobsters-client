//
//  TutorialBuildingUpgradeController.m
//  Utopia
//
//  Created by Rob Giusti on 2/2/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "TutorialUpgradeViewController.h"

#import "Globals.h"

@implementation TutorialUpgradeViewController

- (id) init {
  if ((self = [super initWithNibName:@"UpgradeViewController" bundle:nil])) {
    
  }
  return self;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [Globals createUIArrowForView:self.upgradeView.cashButtonView atAngle:M_PI * .5f];
}

- (void) close {
  [super closeClicked:nil];
}

- (void) closeClicked:(id)sender {
  //Do nothing
}

@end