//
//  TutorialMainMenuController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/6/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialMainMenuController.h"
#import "Globals.h"

@implementation TutorialMainMenuController

- (id) init {
  if ((self = [super initWithNibName:@"MainMenuController" bundle:nil])) {
    
  }
  return self;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [Globals createUIArrowForView:self.buildingsButtonView atAngle:M_PI];
}

- (IBAction)buildingsClicked:(id)sender {
  [Globals removeUIArrowFromViewRecursively:self.view];
  [self.delegate buildingButtonClicked];
}

- (IBAction)fundsClicked:(id)sender {
  // Do nothing
}

- (IBAction)cratesClicked:(id)sender {
  // Do nothing
}

- (IBAction)labClicked:(id)sender {
  // Do nothing
}

- (IBAction)clansClicked:(id)sender {
  // Do nothing
}

- (IBAction)profileClicked:(id)sender {
  // Do nothing
}

- (IBAction)settingsClicked:(id)sender {
  // Do nothing
}

- (void) menuCloseClicked:(id)sender {
  // Do nothing
}

@end
