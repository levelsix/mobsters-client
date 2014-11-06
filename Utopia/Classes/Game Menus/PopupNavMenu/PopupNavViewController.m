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

#define ANIMATION_TIME 0.3f

@implementation PopupNavViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.viewControllers = [NSMutableArray array];
  
  self.backView.alpha = 0.f;
}

- (void) displayInParentViewController:(UIViewController *)gvc {
  [gvc addChildViewController:self];
  self.view.frame = gvc.view.bounds;
  
  [self beginAppearanceTransition:YES animated:YES];
  
  [gvc.view addSubview:self.view];
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView completion:^(BOOL finished) {
    [self endAppearanceTransition];
  }];
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if ([self shouldStopCCDirector]) {
    [[CCDirector sharedDirector] pause];
  }
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  if ([self shouldStopCCDirector]) {
    [[CCDirector sharedDirector] resume];
  }
}

- (BOOL) shouldStopCCDirector {
  return YES;
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
  [self beginAppearanceTransition:NO animated:YES];
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    // Do this so appearance methods are forwarded
    [self unloadAllControllers];
    
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
    [self endAppearanceTransition];
  }];
}

- (BOOL) shouldAutomaticallyForwardAppearanceMethods {
  return NO;
}


#pragma mark - Navigation Controller

- (void) remakeBackButton {
  float alpha = self.backView.alpha;
  self.backView.alpha = 1.f;
  [self.backMaskedButton remakeImage];
  self.backView.alpha = alpha;
}

- (void) setNewTopViewController:(PopupSubViewController *)topViewController {
  [self.topViewController removeObserver:self forKeyPath:@"title"];
  [self.topViewController removeObserver:self forKeyPath:@"attributedTitle"];
  self.topViewController = topViewController;
  [self.topViewController addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
  [self.topViewController addObserver:self forKeyPath:@"attributedTitle" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void) replaceRootWithViewController:(PopupSubViewController *)viewController {
  [self replaceRootWithViewController:viewController fromRight:NO animated:NO];
}

- (void) replaceRootWithViewController:(PopupSubViewController *)viewController fromRight:(BOOL)fromRight animated:(BOOL)animated {
  PopupSubViewController *removeVc = [self.viewControllers lastObject];
  // Check the special case where we are basically replacing root with the current view controller
  if (animated && removeVc != viewController) {
    [self.viewControllers removeObject:removeVc];
    PopupSubViewController *topVc = viewController;
    
    // Unload the rest so that the stack looks proper when this method exits
    [self unloadAllControllers];
    [self.viewControllers addObject:topVc];
    [self setNewTopViewController:topVc];
    
    if (removeVc.isBeingPresented || removeVc.isBeingDismissed) {
      [removeVc endAppearanceTransition];
    } else if (topVc.isBeingPresented || topVc.isBeingDismissed) {
      [topVc endAppearanceTransition];
    }
    
    topVc.view.frame = self.containerView.bounds;
    
    [removeVc beginAppearanceTransition:NO animated:animated];
    [topVc beginAppearanceTransition:YES animated:animated];
    
    [self.containerView addSubview:topVc.view];
    [self addChildViewController:topVc];
    
    float movementFactor = self.containerView.frame.size.width*(fromRight?1:-1);
    topVc.view.center = ccp(self.containerView.frame.size.width/2+movementFactor, self.containerView.frame.size.height/2);
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
      removeVc.view.center = ccp(self.containerView.frame.size.width/2-movementFactor, self.containerView.frame.size.height/2);
    } completion:^(BOOL finished) {
      if (finished) {
        [removeVc.view removeFromSuperview];
        [removeVc removeFromParentViewController];
        
        [removeVc endAppearanceTransition];
      }
    }];
    
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
      topVc.view.frame = self.containerView.bounds;
    } completion:^(BOOL finished) {
      if (finished) {
        [topVc endAppearanceTransition];
      }
    }];
  } else {
    [self unloadAllControllers];
    
    [self.viewControllers addObject:viewController];
    [self setNewTopViewController:viewController];
    
    viewController.view.frame = self.containerView.bounds;
    
    [viewController beginAppearanceTransition:YES animated:animated];
    [self.containerView addSubview:viewController.view];
    [self addChildViewController:viewController];
    [viewController endAppearanceTransition];
  }
  
  [self loadNextTitleSelectionFromRight:fromRight animated:animated];
  [self loadNextLeftCornerViewAnimated:animated];
}

- (void) pushViewController:(PopupSubViewController *)topVc animated:(BOOL)animated {
  PopupSubViewController *curVc = [self.viewControllers lastObject];
  
  // This is in place for enhance views (check HomeViewController for reloading)
  if (curVc != topVc) {
    [self.viewControllers addObject:topVc];
    [self setNewTopViewController:topVc];
    
    topVc.view.frame = self.containerView.bounds;
    
    [curVc beginAppearanceTransition:NO animated:animated];
    [topVc beginAppearanceTransition:YES animated:animated];
    
    [self.containerView addSubview:topVc.view];
    [self addChildViewController:topVc];
  }
  
  if (animated && curVc != topVc) {
    topVc.view.center = ccp(self.containerView.frame.size.width*3/2, self.containerView.frame.size.height/2);
    
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
      curVc.view.center = ccp(-self.containerView.frame.size.width/2, self.containerView.frame.size.height/2);
    } completion:^(BOOL finished) {
      [curVc.view removeFromSuperview];
      
      [curVc endAppearanceTransition];
    }];
    
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
      topVc.view.center = ccp(self.containerView.frame.size.width/2, self.containerView.frame.size.height/2);
    } completion:^(BOOL finished) {
      [topVc endAppearanceTransition];
    }];
  } else if (curVc != topVc) {
    [curVc.view removeFromSuperview];
    
    [curVc endAppearanceTransition];
    [topVc endAppearanceTransition];
  }
  
  [self loadNextTitleSelectionFromRight:YES animated:animated];
  [self loadNextLeftCornerViewAnimated:animated];
}

- (UIViewController *) popViewControllerAnimated:(BOOL)animated {
  PopupSubViewController *removeVc = [self.viewControllers lastObject];
  [self.viewControllers removeObject:removeVc];
  PopupSubViewController *topVc = [self.viewControllers lastObject];
  [self setNewTopViewController:topVc];
  
  topVc.view.frame = self.containerView.bounds;
  
  [removeVc beginAppearanceTransition:NO animated:animated];
  [topVc beginAppearanceTransition:YES animated:animated];
  [self.containerView addSubview:topVc.view];
  if (animated) {
    topVc.view.center = ccp(-self.containerView.frame.size.width/2, self.containerView.frame.size.height/2);
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
      removeVc.view.center = ccp(self.containerView.frame.size.width*3/2, self.containerView.frame.size.height/2);
    } completion:^(BOOL finished) {
      [removeVc.view removeFromSuperview];
      [removeVc removeFromParentViewController];
      
      [removeVc endAppearanceTransition];
    }];
    
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
      topVc.view.frame = self.containerView.bounds;
    } completion:^(BOOL finished) {
      [topVc endAppearanceTransition];
    }];
  } else {
    [removeVc.view removeFromSuperview];
    [removeVc removeFromParentViewController];
    
    topVc.view.frame = self.containerView.bounds;
    
    [removeVc endAppearanceTransition];
    [topVc endAppearanceTransition];
  }
  
  [self loadNextTitleSelectionFromRight:NO animated:animated];
  [self loadNextLeftCornerViewAnimated:animated];
  
  return removeVc;
}

- (void) unloadAllControllers {
  [self setNewTopViewController:nil];
  for (UIViewController *vc in self.viewControllers) {
    if (vc.view.superview) {
      [vc beginAppearanceTransition:NO animated:NO];
      [vc.view removeFromSuperview];
      [vc endAppearanceTransition];
    }
    
    [vc removeFromParentViewController];
  }
  [self.viewControllers removeAllObjects];
}

#pragma mark - Title views

- (void) replaceTitleView:(UIView *)oldView withNewView:(UIView *)newView fromRight:(BOOL)fromRight animated:(BOOL)animated {
  [oldView.superview insertSubview:newView aboveSubview:oldView];
  if (animated) {
    float movementFactor = 70.f*(fromRight?1:-1);
    newView.center = ccpAdd(oldView.center, ccp(movementFactor, 0));
    newView.alpha = 0.f;
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
      newView.center = oldView.center;
      oldView.center = ccpAdd(oldView.center, ccp(-movementFactor, 0));
      
      oldView.alpha = 0.f;
      newView.alpha = 1.f;
    } completion:^(BOOL finished) {
      [oldView removeFromSuperview];
    }];
  } else {
    newView.center = oldView.center;
    
    [oldView removeFromSuperview];
  }
}

- (void) loadNextTitleSelectionFromRight:(BOOL)fromRight animated:(BOOL)animated {
  UIView *oldTitleView = self.curTitleView;
  
  self.curTitleLabel = [[NSBundle mainBundle] loadNibNamed:@"HomeTitleLabel" owner:self options:nil][0];
  self.curTitleView = self.curTitleLabel;
  
  [self reloadTitleLabel];
  
  [self replaceTitleView:oldTitleView withNewView:self.curTitleView fromRight:fromRight animated:animated];
}

- (void) reloadTitleLabel {
  PopupSubViewController *svc = [self.viewControllers lastObject];
  if (svc.attributedTitle) {
    self.curTitleLabel.attributedText = svc.attributedTitle;
  } else {
    self.curTitleLabel.text = svc.title;
  }
}

- (void) loadNextLeftCornerViewAnimated:(BOOL)animated {
  PopupSubViewController *svc = [self.viewControllers lastObject];
  
  BOOL shouldDisplayBackButton = NO;
  if (self.viewControllers.count > 1) {
    shouldDisplayBackButton = YES;
    self.backLabel.text = [self.viewControllers[self.viewControllers.count-2] title];
    [self remakeBackButton];
  }
  
  UIView *oldLeftCorner = self.leftCornerView;
  
  if (!shouldDisplayBackButton) {
    self.leftCornerView = svc.leftCornerView;
    [self.leftCornerViewContainer addSubview:self.leftCornerView];
    self.leftCornerView.alpha = 0.f;
    self.leftCornerView.originY = self.leftCornerViewContainer.height-self.leftCornerView.height;
  } else {
    self.leftCornerView = nil;
  }
  
  // Disable touches so that we can reassign them after
  oldLeftCorner.userInteractionEnabled = NO;
  self.leftCornerView.userInteractionEnabled = NO;
  self.backView.userInteractionEnabled = NO;
  
  [UIView animateWithDuration:ANIMATION_TIME animations:^{
    oldLeftCorner.alpha = 0.f;
    self.leftCornerView.alpha = 1.f;
    self.backView.alpha = shouldDisplayBackButton;
  } completion:^(BOOL finished) {
    if (oldLeftCorner != self.leftCornerView) {
      [oldLeftCorner removeFromSuperview];
    }
    
    oldLeftCorner.userInteractionEnabled = YES;
    self.leftCornerView.userInteractionEnabled = YES;
    self.backView.userInteractionEnabled = YES;
  }];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  [self reloadTitleLabel];
}

@end
