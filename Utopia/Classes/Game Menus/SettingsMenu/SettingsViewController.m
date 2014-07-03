//
//  SettingsViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 7/2/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SettingsViewController.h"

@implementation SettingsViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.settingsSubViewController = [[SettingsSubViewController alloc] init];
  self.faqViewController = [[FAQViewController alloc] init];
  
  [self button1Clicked:nil];
}

#pragma mark - TabBar delegate

- (void) button1Clicked:(id)sender {
  [self replaceRootWithViewController:self.settingsSubViewController];
  
  [self.tabBar clickButton:1];
}

- (void) button2Clicked:(id)sender {
  [self replaceRootWithViewController:self.faqViewController];
  
  [self.tabBar clickButton:2];
}

@end
