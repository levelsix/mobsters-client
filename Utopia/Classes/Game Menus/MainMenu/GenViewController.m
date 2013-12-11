//
//  GenViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/14/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "GenViewController.h"
#import "SettingsViewController.h"

@implementation GenViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.navigationItem.titleView = self.topBar;
}

- (void)loadCustomNavBarButtons {
  if (!self.menuCloseButton) {
    [[NSBundle mainBundle] loadNibNamed:@"CustomNavBarButtons" owner:self options:nil];
  }
}

- (void)setUpCloseButton {
  [self loadCustomNavBarButtons];
  UIBarButtonItem *rightButton1 = [[UIBarButtonItem alloc] initWithCustomView:self.menuCloseButton];
  self.navigationItem.rightBarButtonItem = rightButton1;
}

- (void)setUpImageBackButton
{
  self.navigationItem.hidesBackButton = YES;
  if (self.navigationController.viewControllers.count > 1) {
    [self loadCustomNavBarButtons];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.menuBackButton];
    
    NSArray *vcs = self.navigationController.viewControllers;
    GenViewController *gvc = [vcs objectAtIndex:vcs.count-2];
    self.menuBackLabel.text = gvc.shortTitle ? gvc.shortTitle : gvc.title;
  }
}

- (IBAction)popCurrentViewController:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)menuCloseClicked:(id)sender {
  [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL) prefersStatusBarHidden {
  return YES;
}

@end
