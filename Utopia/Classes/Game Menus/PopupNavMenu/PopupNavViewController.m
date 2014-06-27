//
//  PopupNavViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/19/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PopupNavViewController.h"
#import "Globals.h"
#import "PopupSubViewController.h"

@implementation PopupNavViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  self.viewControllers = [NSMutableArray array];
  
  self.backView.alpha = 0.f;
}

- (IBAction) backClicked:(id)sender {
  if ((!self.viewControllers.count || [[self.viewControllers lastObject] canGoBack])) {
    [self goBack];
  }
  [self.view endEditing:YES];
}

- (void) goBack {
  [self popViewControllerAnimated:YES];
}

- (IBAction) closeClicked:(id)sender {
  if ((!self.viewControllers.count || [[self.viewControllers lastObject] canClose])) {
    [self close];
  }
  [self.view endEditing:YES];
}

- (void) close {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    // Do this so appearance methods are forwarded
    [self unloadAllControllers];
    
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}


#pragma mark - Navigation Controller

- (void) remakeBackButton {
  float alpha = self.backView.alpha;
  self.backView.alpha = 1.f;
  [self.backMaskedButton remakeImage];
  self.backView.alpha = alpha;
}

- (BOOL) shouldAutomaticallyForwardAppearanceMethods {
  return NO;
}

- (void) replaceRootWithViewController:(PopupSubViewController *)viewController animated:(BOOL)animated {
  [self unloadAllControllers];
  [self pushViewController:viewController animated:NO];
}

- (void) pushViewController:(PopupSubViewController *)viewController animated:(BOOL)animated {
  UIViewController *curVc = [self.viewControllers lastObject];
  [self.viewControllers addObject:viewController];
  
  BOOL shouldDisplayBackButton = NO;
  if (self.viewControllers.count > 1) {
    shouldDisplayBackButton = YES;
    self.backLabel.text = [self.viewControllers[self.viewControllers.count-2] title];
    [self remakeBackButton];
  }
  
  [curVc beginAppearanceTransition:NO animated:animated];
  [viewController beginAppearanceTransition:YES animated:animated];
  
  [self.containerView addSubview:viewController.view];
  [self addChildViewController:viewController];
  viewController.view.frame = self.containerView.bounds;
  if (animated) {
    viewController.view.center = ccp(self.containerView.frame.size.width*3/2, self.containerView.frame.size.height/2);
    
    [UIView animateWithDuration:0.3f animations:^{
      viewController.view.center = ccp(self.containerView.frame.size.width/2, self.containerView.frame.size.height/2);
      curVc.view.center = ccp(-self.containerView.frame.size.width/2, self.containerView.frame.size.height/2);
      self.backView.alpha = shouldDisplayBackButton;
    } completion:^(BOOL finished) {
      [curVc.view removeFromSuperview];
      
      [curVc endAppearanceTransition];
      [viewController endAppearanceTransition];
    }];
  } else {
    self.backView.alpha = shouldDisplayBackButton;
    [curVc.view removeFromSuperview];
    
    [curVc endAppearanceTransition];
    [viewController endAppearanceTransition];
  }
}

- (UIViewController *) popViewControllerAnimated:(BOOL)animated {
  UIViewController *removeVc = [self.viewControllers lastObject];
  [self.viewControllers removeObject:removeVc];
  UIViewController *topVc = [self.viewControllers lastObject];
  
  BOOL shouldDisplayBackButton = NO;
  if (self.viewControllers.count > 1) {
    shouldDisplayBackButton = YES;
    self.backLabel.text = [self.viewControllers[self.viewControllers.count-2] title];
    [self remakeBackButton];
  }
  
  [removeVc beginAppearanceTransition:NO animated:animated];
  [topVc beginAppearanceTransition:YES animated:animated];
  
  [self.containerView addSubview:topVc.view];
  if (animated) {
    topVc.view.center = ccp(-self.containerView.frame.size.width/2, self.containerView.frame.size.height/2);
    [UIView animateWithDuration:0.3f animations:^{
      removeVc.view.center = ccp(self.containerView.frame.size.width*3/2, self.containerView.frame.size.height/2);
      topVc.view.frame = self.containerView.bounds;
      self.backView.alpha = shouldDisplayBackButton;
    } completion:^(BOOL finished) {
      [removeVc.view removeFromSuperview];
      [removeVc removeFromParentViewController];
      
      [removeVc endAppearanceTransition];
      [topVc endAppearanceTransition];
    }];
  } else {
    [removeVc.view removeFromSuperview];
    [removeVc removeFromParentViewController];
    self.backView.alpha = shouldDisplayBackButton;
    
    topVc.view.frame = self.containerView.bounds;
    
    [removeVc endAppearanceTransition];
    [topVc endAppearanceTransition];
  }
  
  return removeVc;
}

- (void) unloadAllControllers {
  for (UIViewController *vc in self.viewControllers) {
    [vc beginAppearanceTransition:NO animated:NO];
    [vc.view removeFromSuperview];
    [vc removeFromParentViewController];
    [vc endAppearanceTransition];
  }
  [self.viewControllers removeAllObjects];
}

@end
