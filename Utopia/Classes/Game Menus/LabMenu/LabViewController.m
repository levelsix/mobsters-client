//
//  LabViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/28/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "LabViewController.h"

@interface LabViewController ()

@end

@implementation LabViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.enhanceViewController = [[EnhanceViewController alloc] initWithNibName:nil bundle:nil];
  self.evoViewController = [[EvoViewController alloc] initWithNibName:nil bundle:nil];
  
  [self addChildViewController:self.enhanceViewController];
  [self addChildViewController:self.evoViewController];
  
  self.title = @"Lab";
  [self setUpCloseButton];
  [self setUpImageBackButton];
  
  [self button1Clicked:nil];
}

- (void) button1Clicked:(id)sender {
  [self.evoViewController.view removeFromSuperview];
  
  [self.view addSubview:self.enhanceViewController.view];
  self.enhanceViewController.view.frame = self.view.bounds;
  
  [self.menuTopBar clickButton:kButton1];
  [self.menuTopBar unclickButton:kButton2];
  
  self.navigationItem.leftBarButtonItem = self.enhanceViewController.navigationItem.leftBarButtonItem;
}

- (void) button2Clicked:(id)sender {
  [self.enhanceViewController.view removeFromSuperview];
  
  [self.view addSubview:self.evoViewController.view];
  self.evoViewController.view.frame = self.view.bounds;
  
  [self.menuTopBar clickButton:kButton2];
  [self.menuTopBar unclickButton:kButton1];
  
  self.navigationItem.leftBarButtonItem = self.evoViewController.navigationItem.leftBarButtonItem;
}

@end
