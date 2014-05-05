//
//  MiniJobsViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 5/1/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MiniJobsViewController.h"
#import "Globals.h"
#import "GameState.h"

@implementation MiniJobsViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.listViewController = [[MiniJobsListViewController alloc] init];
  self.listViewController.delegate = self;
  [self addChildViewController:self.listViewController];
  [self.containerView addSubview:self.listViewController.view];
  
  self.backView.alpha = 0.f;
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (IBAction) closeClicked:(id)sender {
  [self close];
}

- (void) close {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

#pragma mark - Transitioning

- (void) transitionToDetailsView {
  self.detailsViewController.view.center = ccp(self.containerView.frame.size.width+
                                               self.detailsViewController.view.frame.size.width/2,
                                               self.detailsViewController.view.center.y);
  [UIView animateWithDuration:0.3f animations:^{
    self.detailsViewController.view.center = ccp(self.containerView.frame.size.width/2,
                                                 self.detailsViewController.view.center.y);
    self.listViewController.view.center = ccp(-self.listViewController.view.center.x,
                                              self.listViewController.view.center.y);
    self.backView.alpha = 1.f;
    
    self.titleLabel.alpha = 1.f;
  }];
  self.titleLabel.text = self.detailsViewController.title;
}

- (void) transitionToListView {
  // Do this so that the view doesn't update while scrolling back
  MiniJobsDetailsViewController *dvc = self.detailsViewController;
  self.detailsViewController = nil;
  
  [UIView animateWithDuration:0.3f animations:^{
    self.listViewController.view.center = ccp(self.containerView.frame.size.width/2,
                                              self.listViewController.view.center.y);
    dvc.view.center = ccp(self.containerView.frame.size.width+
                          dvc.view.frame.size.width/2,
                          dvc.view.center.y);
    self.backView.alpha = 0.f;
    
    self.titleLabel.alpha = 0.f;
  } completion:^(BOOL finished) {
    [dvc.view removeFromSuperview];
    [dvc removeFromParentViewController];
  }];
}

#pragma mark - MiniJobsListDelegate

- (void) miniJobsListCellClicked:(MiniJobsListCell *)listCell {
  [self loadDetailsViewFor];
}

- (void) loadDetailsViewFor {
  self.detailsViewController = [[MiniJobsDetailsViewController alloc] init];
  self.detailsViewController.delegate = self;
  [self addChildViewController:self.detailsViewController];
  [self.containerView addSubview:self.detailsViewController.view];
  
  [self transitionToDetailsView];
}

- (IBAction)backClicked:(id)sender {
  [self transitionToListView];
}

@end
