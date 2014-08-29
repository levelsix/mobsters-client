//
//  TutorialShopViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 7/6/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialShopViewController.h"

@implementation TutorialShopViewController

- (id) initWithBuildingViewController:(BuildingViewController *)svc {
  if ((self = [super initWithNibName:@"ShopViewController" bundle:nil])) {
    self.buildingViewController = svc;
  }
  return self;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  // Make sure it actually opens the building menu
  [super openBuildingsShop];
  
  self.gachasBadge.badgeNum = 0;
  self.buildingsBadge.badgeNum = 0;
}

- (void) initializeSubViewControllers {
  // Do nothing
}

- (IBAction) settingsClicked:(id)sender {
  // Do nothing
}

- (void) button2Clicked:(id)sender {
  // Do nothing
}

- (void) button3Clicked:(id)sender {
  // Do nothing
}

- (void) closeClicked:(id)sender {
  // Do nothing
}

@end
