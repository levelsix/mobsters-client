//
//  GenericPopupController.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/5/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "GenericPopupController.h"
#import "LNSynthesizeSingleton.h"
#import "cocos2d.h"
#import "Globals.h"
#import "AppDelegate.h"
#import "GameViewController.h"

#define DISAPPEAR_ROTATION_ANGLE M_PI/3

@implementation GenericPopupController

- (void) viewDidLoad {
  self.confirmationView.frame = self.notificationView.frame;
  [self.mainView addSubview:self.confirmationView];
}

- (void) displayPopup {
  [[[UIApplication sharedApplication] keyWindow] addSubview:self.view];
  [[GameViewController baseController] addChildViewController:self];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (BOOL) prefersStatusBarHidden {
  return YES;
}

+ (GenericPopupController *) displayNotificationViewWithText:(NSString *)string title:(NSString *)title {
  GenericPopupController *gp = [[GenericPopupController alloc] init];
  [gp displayPopup];
  gp.notificationView.hidden = NO;
  gp.confirmationView.hidden = YES;
  gp.descriptionLabel.text = string;
  gp.titleLabel.text = title ? title : @"Notification!";
  
  return gp;
}

+ (GenericPopupController *) displayNotificationViewWithText:(NSString *)string title:(NSString *)title okayButton:(NSString *)okay target:(id)target selector:(SEL)selector {
  GenericPopupController *gp = [[GenericPopupController alloc] init];
  [gp displayPopup];
  gp.notificationView.hidden = NO;
  gp.confirmationView.hidden = YES;
  gp.descriptionLabel.text = string;
  gp.titleLabel.text = title ? title : @"Notification!";
  gp.redButtonLabel.text = okay ? okay : @"Okay";
  
	NSMethodSignature* sig = [[target class]
                            instanceMethodSignatureForSelector:selector];
	NSInvocation* invocation = [NSInvocation
                              invocationWithMethodSignature:sig];
	[invocation setTarget:target];
	[invocation setSelector:selector];
  gp.okInvocation = invocation;
  
  return gp;
}

+ (GenericPopupController *) displayNotificationViewWithMiddleView:(UIView *)view title:(NSString *)title okayButton:(NSString *)okay target:(id)target selector:(SEL)selector {
  GenericPopupController *gp = [[GenericPopupController alloc] init];
  [gp displayPopup];
  gp.notificationView.hidden = NO;
  gp.confirmationView.hidden = YES;
  gp.descriptionLabel.hidden = YES;
  [gp.mainView addSubview:view];
  view.center = gp.descriptionLabel.center;
  gp.titleLabel.text = title ? title : @"Notification!";
  gp.redButtonLabel.text = okay ? okay : @"Okay";
  
	NSMethodSignature* sig = [[target class]
                            instanceMethodSignatureForSelector:selector];
	NSInvocation* invocation = [NSInvocation
                              invocationWithMethodSignature:sig];
	[invocation setTarget:target];
	[invocation setSelector:selector];
  gp.okInvocation = invocation;
  
  return gp;
}

+ (GenericPopupController *) displayConfirmationWithDescription:(NSString *)description title:(NSString *)title okayButton:(NSString *)okay cancelButton:(NSString *)cancel target:(id)target selector:(SEL)selector {
  GenericPopupController *gp = [[GenericPopupController alloc] init];
  [gp displayPopup];
  
  gp.notificationView.hidden = YES;
  gp.confirmationView.hidden = NO;
  
  gp.titleLabel.text = title ? title : @"Confirmation!";
  gp.descriptionLabel.text = description;
  gp.greenButtonLabel.text = okay ? okay : @"Okay";
  gp.blackButtonLabel.text = cancel ? cancel : @"Cancel";
  
	NSMethodSignature* sig = [[target class]
                            instanceMethodSignatureForSelector:selector];
	NSInvocation* invocation = [NSInvocation
                              invocationWithMethodSignature:sig];
	[invocation setTarget:target];
	[invocation setSelector:selector];
  gp.okInvocation = invocation;
  
  return gp;
}

+ (GenericPopupController *) displayConfirmationWithDescription:(NSString *)description title:(NSString *)title okayButton:(NSString *)okay cancelButton:(NSString *)cancel okTarget:(id)okTarget okSelector:(SEL)okSelector cancelTarget:(id)cancelTarget cancelSelector:(SEL)cancelSelector {
  GenericPopupController *gp = [[GenericPopupController alloc] init];
  [gp displayPopup];
  
  gp.notificationView.hidden = YES;
  gp.confirmationView.hidden = NO;
  
  gp.titleLabel.text = title ? title : @"Confirmation!";
  gp.descriptionLabel.text = description;
  gp.greenButtonLabel.text = okay ? okay : @"Okay";
  gp.blackButtonLabel.text = cancel ? cancel : @"Cancel";
  
	NSMethodSignature* sig = [[okTarget class]
                            instanceMethodSignatureForSelector:okSelector];
	NSInvocation* invocation = [NSInvocation
                              invocationWithMethodSignature:sig];
	[invocation setTarget:okTarget];
	[invocation setSelector:okSelector];
  gp.okInvocation = invocation;
  
	sig = [[cancelTarget class]
                            instanceMethodSignatureForSelector:cancelSelector];
	invocation = [NSInvocation
                              invocationWithMethodSignature:sig];
	[invocation setTarget:cancelTarget];
	[invocation setSelector:cancelSelector];
  gp.cancelInvocation = invocation;
  
  return gp;
}

- (void) close {
  [UIView animateWithDuration:0.7f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
    CGAffineTransform t = CGAffineTransformIdentity;
    t = CGAffineTransformScale(t, 0.75f, 0.75f);
    t = CGAffineTransformRotate(t, DISAPPEAR_ROTATION_ANGLE);
    self.mainView.transform = t;
    self.mainView.center = CGPointMake(self.mainView.center.x-70, self.mainView.center.y+350);
    self.bgdView.alpha = 0.f;
  } completion:^(BOOL finished) {
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
  }];
}

- (IBAction)redOkayClicked:(id)sender {
  [self.okInvocation invoke];
  [self close];
}

- (IBAction)greenOkayClicked:(id)sender {
  [self.okInvocation invoke];
  [self close];
}

- (IBAction)cancelClicked:(id)sender {
  [self.cancelInvocation invoke];
  [self close];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.view endEditing:YES];
}

#pragma mark -

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
