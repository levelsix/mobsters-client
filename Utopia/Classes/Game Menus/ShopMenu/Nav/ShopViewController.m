//
//  MainMenuViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/29/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ShopViewController.h"


@implementation ShopViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.buildingViewController = [[BuildingViewController alloc] init];
  
  [self button1Clicked:nil];
}

#pragma mark - TabBar delegate

- (void) button1Clicked:(id)sender {
  [self replaceRootWithViewController:self.buildingViewController];
  
  [self.tabBar clickButton:1];
}

- (void) button2Clicked:(id)sender {
  [self.tabBar clickButton:2];
}

- (void) button3Clicked:(id)sender {
  [self.tabBar clickButton:3];
}

@end
