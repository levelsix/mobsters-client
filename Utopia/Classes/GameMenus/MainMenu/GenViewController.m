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

- (void)setUpCloseButton:(BOOL)right {
  [self loadCustomNavBarButtons];
  
  UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:self.menuCloseButton];
  if (right) self.navigationItem.rightBarButtonItem = button;
  else self.navigationItem.leftBarButtonItem = button;
}

- (void)setUpImageBackButton {
  self.navigationItem.hidesBackButton = YES;
  
  [self loadCustomNavBarButtons];
  
  if (self.navigationController.viewControllers.count > 1) {
    if (self.navigationItem.leftBarButtonItem) {
      // In case of close button having been placed on the left
      self.navigationItem.rightBarButtonItem = self.navigationItem.leftBarButtonItem;
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.menuBackButton];
    
    NSArray *vcs = self.navigationController.viewControllers;
    GenViewController *gvc = [vcs objectAtIndex:vcs.count-2];
    if ([gvc isKindOfClass:[GenViewController class]]) {
      self.menuBackLabel.text = gvc.shortTitle ? gvc.shortTitle : gvc.title;
      [self.menuBackMaskedButton remakeImage];
    }
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
