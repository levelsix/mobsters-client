//
//  OmnipresentViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/27/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "OmnipresentViewController.h"
#import "GameViewController.h"
#import "MSWindow.h"

@interface OmnipresentViewController ()

@end

@implementation OmnipresentViewController

- (BOOL) prefersStatusBarHidden {
  return YES;
}

- (void) displayView {
  MSWindow *window = (MSWindow *)[[UIApplication sharedApplication] keyWindow];
  [window displayOmnipresentView:self.view];
  [[GameViewController baseController] addChildViewController:self];
}

- (void) removeView {
  MSWindow *window = (MSWindow *)[[UIApplication sharedApplication] keyWindow];
  [window removeOmniPresentView:self.view];
  [self removeFromParentViewController];
}

#pragma mark -
#pragma mark - Emulate UIAlertView behavior

- (void) viewWillAppear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameOrOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameOrOrientationChanged:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (void) viewDidAppear:(BOOL)animated {
  [self rotateAccordingToStatusBarOrientationAndSupportedOrientations];
}

- (void) viewDidDisappear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)statusBarFrameOrOrientationChanged:(NSNotification *)notification
{
  /*
   This notification is most likely triggered inside an animation block,
   therefore no animation is needed to perform this nice transition.
   */
  [self rotateAccordingToStatusBarOrientationAndSupportedOrientations];
}

- (void)rotateAccordingToStatusBarOrientationAndSupportedOrientations
{
  UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
  CGFloat angle = UIInterfaceOrientationAngleOfOrientation(statusBarOrientation);
  CGFloat statusBarHeight = [[self class] getStatusBarHeight];
  
  CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
  CGRect frame = [[self class] rectInWindowBounds:self.view.window.bounds statusBarOrientation:statusBarOrientation statusBarHeight:statusBarHeight];
  
  [self setIfNotEqualTransform:transform frame:frame];
}

- (void)setIfNotEqualTransform:(CGAffineTransform)transform frame:(CGRect)frame
{
  if(!CGAffineTransformEqualToTransform(self.view.transform, transform))
  {
    self.view.transform = transform;
  }
  if(!CGRectEqualToRect(self.view.frame, frame))
  {
    self.view.frame = frame;
  }
}

+ (CGFloat)getStatusBarHeight
{
  UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
  if(UIInterfaceOrientationIsLandscape(orientation))
  {
    return [UIApplication sharedApplication].statusBarFrame.size.width;
  }
  else
  {
    return [UIApplication sharedApplication].statusBarFrame.size.height;
  }
}

+ (CGRect)rectInWindowBounds:(CGRect)windowBounds statusBarOrientation:(UIInterfaceOrientation)statusBarOrientation statusBarHeight:(CGFloat)statusBarHeight
{
  CGRect frame = windowBounds;
  frame.origin.x += statusBarOrientation == UIInterfaceOrientationLandscapeLeft ? statusBarHeight : 0;
  frame.origin.y += statusBarOrientation == UIInterfaceOrientationPortrait ? statusBarHeight : 0;
  frame.size.width -= UIInterfaceOrientationIsLandscape(statusBarOrientation) ? statusBarHeight : 0;
  frame.size.height -= UIInterfaceOrientationIsPortrait(statusBarOrientation) ? statusBarHeight : 0;
  return frame;
}

CGFloat UIInterfaceOrientationAngleOfOrientation(UIInterfaceOrientation orientation)
{
  CGFloat angle;
  
  switch (orientation)
  {
    case UIInterfaceOrientationPortraitUpsideDown:
      angle = M_PI;
      break;
    case UIInterfaceOrientationLandscapeLeft:
      angle = -M_PI_2;
      break;
    case UIInterfaceOrientationLandscapeRight:
      angle = M_PI_2;
      break;
    default:
      angle = 0.0;
      break;
  }
  
  return angle;
}

UIInterfaceOrientationMask UIInterfaceOrientationMaskFromOrientation(UIInterfaceOrientation orientation)
{
  return 1 << orientation;
}

@end
