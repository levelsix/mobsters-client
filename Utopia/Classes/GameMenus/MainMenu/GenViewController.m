//
//  GenViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/14/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "GenViewController.h"

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
  
  [self loadCustomNavBarButtons];
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.menuBackButton];
  
  if (self.navigationController.viewControllers.count > 1) {
    NSArray *vcs = self.navigationController.viewControllers;
    GenViewController *gvc = [vcs objectAtIndex:vcs.count-2];
    if ([gvc isKindOfClass:[GenViewController class]]) {
      self.menuBackLabel.text = gvc.shortTitle ? gvc.shortTitle : gvc.title;
      [self.menuBackMaskedButton remakeImage];
    }
  } else {
    self.menuBackButton.hidden = YES;
  }
}

- (IBAction)menuBackClicked:(id)sender {
  [self popCurrentViewController];
}

- (void)popCurrentViewController {
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)menuCloseClicked:(id)sender {
  [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL) prefersStatusBarHidden {
  return YES;
}

@end
