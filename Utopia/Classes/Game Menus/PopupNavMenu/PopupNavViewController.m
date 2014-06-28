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

- (void) replaceRootWithViewController:(PopupSubViewController *)viewController {
  [self replaceRootWithViewController:viewController fromRight:NO animated:NO];
}

- (void) replaceRootWithViewController:(PopupSubViewController *)viewController fromRight:(BOOL)fromRight animated:(BOOL)animated {
  if (animated) {
    UIViewController *removeVc = [self.viewControllers lastObject];
    [self.viewControllers removeObject:removeVc];
    UIViewController *topVc = viewController;
    
    // Unload the rest so that the stack looks proper when this method exits
    [self unloadAllControllers];
    [self.viewControllers addObject:topVc];
    int x = arc4random()%2000;
    NSLog(@"%d: 1", x);
    [removeVc.view.layer removeAllAnimations];
    [topVc.view.layer removeAllAnimations];
    [self.backView.layer removeAllAnimations];
    NSLog(@"%d: 2", x);
    
    if (removeVc.isBeingPresented || removeVc.isBeingDismissed) {
      [removeVc endAppearanceTransition];
    } else if (topVc.isBeingPresented || topVc.isBeingDismissed) {
      [topVc endAppearanceTransition];
    }
    
    [removeVc beginAppearanceTransition:NO animated:animated];
    [topVc beginAppearanceTransition:YES animated:animated];
    
    [self.containerView addSubview:topVc.view];
    [self addChildViewController:topVc];
    
    float movementFactor = self.containerView.frame.size.width*(fromRight?1:-1);
    topVc.view.center = ccp(self.containerView.frame.size.width/2+movementFactor, self.containerView.frame.size.height/2);
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
      removeVc.view.center = ccp(self.containerView.frame.size.width/2-movementFactor, self.containerView.frame.size.height/2);
      self.backView.alpha = 0.f;
    } completion:^(BOOL finished) {
      if (finished) {
        [removeVc.view removeFromSuperview];
        [removeVc removeFromParentViewController];
        
        [removeVc endAppearanceTransition];
      }
      NSLog(@"%d: 3", x);
    }];
    
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
      topVc.view.frame = self.containerView.bounds;
    } completion:^(BOOL finished) {
      if (finished) {
        [topVc endAppearanceTransition];
      }
      NSLog(@"%d: 4", x);
    }];
  } else {
    [self unloadAllControllers];
    [self pushViewController:viewController animated:animated];
  }
}

- (void) pushViewController:(PopupSubViewController *)topVc animated:(BOOL)animated {
  UIViewController *curVc = [self.viewControllers lastObject];
  [self.viewControllers addObject:topVc];
  
  BOOL shouldDisplayBackButton = NO;
  if (self.viewControllers.count > 1) {
    shouldDisplayBackButton = YES;
    self.backLabel.text = [self.viewControllers[self.viewControllers.count-2] title];
    [self remakeBackButton];
  }
  
  [curVc.view.layer removeAllAnimations];
  [topVc.view.layer removeAllAnimations];
  [self.backView.layer removeAllAnimations];
  
  [curVc beginAppearanceTransition:NO animated:animated];
  [topVc beginAppearanceTransition:YES animated:animated];
  
  [self.containerView addSubview:topVc.view];
  [self addChildViewController:topVc];
  topVc.view.frame = self.containerView.bounds;
  if (animated) {
    topVc.view.center = ccp(self.containerView.frame.size.width*3/2, self.containerView.frame.size.height/2);
    
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
      curVc.view.center = ccp(-self.containerView.frame.size.width/2, self.containerView.frame.size.height/2);
      self.backView.alpha = shouldDisplayBackButton;
    } completion:^(BOOL finished) {
      [curVc.view removeFromSuperview];
      
      [curVc endAppearanceTransition];
    }];
    
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
      topVc.view.center = ccp(self.containerView.frame.size.width/2, self.containerView.frame.size.height/2);
    } completion:^(BOOL finished) {
      [topVc endAppearanceTransition];
    }];
  } else {
    self.backView.alpha = shouldDisplayBackButton;
    [curVc.view removeFromSuperview];
    
    [curVc endAppearanceTransition];
    [topVc endAppearanceTransition];
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
  
  [removeVc.view.layer removeAllAnimations];
  [topVc.view.layer removeAllAnimations];
  [self.backView.layer removeAllAnimations];
  
  [removeVc beginAppearanceTransition:NO animated:animated];
  [topVc beginAppearanceTransition:YES animated:animated];
  
  [self.containerView addSubview:topVc.view];
  if (animated) {
    topVc.view.center = ccp(-self.containerView.frame.size.width/2, self.containerView.frame.size.height/2);
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
      removeVc.view.center = ccp(self.containerView.frame.size.width*3/2, self.containerView.frame.size.height/2);
      self.backView.alpha = shouldDisplayBackButton;
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
    self.backView.alpha = shouldDisplayBackButton;
    
    topVc.view.frame = self.containerView.bounds;
    
    [removeVc endAppearanceTransition];
    [topVc endAppearanceTransition];
  }
  
  return removeVc;
}

- (void) unloadAllControllers {
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

@end
