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
  self.mainView.layer.cornerRadius = 6.f;
}

- (void) displayPopup {
  [super displayView];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

+ (GenericPopupController *) displayNotificationViewWithText:(NSString *)string title:(NSString *)title {
  GenericPopupController *gp = [[GenericPopupController alloc] init];
  [gp displayPopup];
  gp.descriptionLabel.text = string;
  gp.titleLabel.text = title;
  return gp;
}

+ (GenericPopupController *) displayNotificationViewWithText:(NSString *)string title:(NSString *)title okayButton:(NSString *)okay target:(id)target selector:(SEL)selector {
  GenericPopupController *gp = [self displayNotificationViewWithText:string title:title];
  
  gp.notifButtonLabel.text = okay;
  
	if (target) [gp.notifButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
  
  return gp;
}

+ (GenericPopupController *) displayNotificationViewWithMiddleView:(UIView *)view title:(NSString *)title okayButton:(NSString *)okay target:(id)target selector:(SEL)selector {
  GenericPopupController *gp = [self displayNotificationViewWithText:nil title:title okayButton:okay target:target selector:selector];
  
  [gp.mainView addSubview:view];
  view.center = gp.descriptionView.center;
  [gp.descriptionView removeFromSuperview];
  
  return gp;
}

+ (GenericPopupController *) displayConfirmationWithDescription:(NSString *)description title:(NSString *)title okayButton:(NSString *)okay cancelButton:(NSString *)cancel target:(id)target selector:(SEL)selector {
  GenericPopupController *gp = [[GenericPopupController alloc] init];
  [gp displayPopup];
  
  [gp.mainView addSubview:gp.confirmationView];
  gp.confirmationView.center = gp.notificationView.center;
  [gp.notificationView removeFromSuperview];
  
  gp.titleLabel.text = title;
  gp.descriptionLabel.text = description;
  gp.confOkayButtonLabel.text = okay;
  gp.confCancelButtonLabel.text = cancel;
  
  if (target) [gp.confOkayButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
  
  return gp;
}

+ (GenericPopupController *) displayConfirmationWithDescription:(NSString *)description title:(NSString *)title okayButton:(NSString *)okay cancelButton:(NSString *)cancel okTarget:(id)okTarget okSelector:(SEL)okSelector cancelTarget:(id)cancelTarget cancelSelector:(SEL)cancelSelector {
  GenericPopupController *gp = [GenericPopupController displayConfirmationWithDescription:description title:title okayButton:okay cancelButton:cancel target:okTarget selector:okSelector];
  
  if (cancelTarget) [gp.confCancelButton addTarget:cancelTarget action:cancelSelector forControlEvents:UIControlEventTouchUpInside];
  
  return gp;
}

+ (GenericPopupController *) displayNegativeConfirmationWithDescription:(NSString *)description title:(NSString *)title okayButton:(NSString *)okay cancelButton:(NSString *)cancel okTarget:(id)okTarget okSelector:(SEL)okSelector cancelTarget:(id)cancelTarget cancelSelector:(SEL)cancelSelector {
  GenericPopupController *gp = [GenericPopupController displayConfirmationWithDescription:description title:title okayButton:okay cancelButton:cancel okTarget:okTarget okSelector:okSelector cancelTarget:cancelTarget cancelSelector:cancelSelector];
  
  [gp.confOkayButton setImage:[Globals imageNamed:@"orangebutton.png"] forState:UIControlStateNormal];
  return gp;
}

+ (GenericPopupController *) displayNotEnoughGemsView {
  GenericPopupController *gp = [GenericPopupController displayNotificationViewWithText:@"You don't have enough gems. Want more?" title:@"Not Enough Gems" okayButton:@"Enter Shop" target:[GameViewController baseController] selector:@selector(openGemShop)];
  
  [gp.notifButton setImage:[Globals imageNamed:@"finishbuild.png"] forState:UIControlStateNormal];
  return gp;
}

- (void) close:(id)sender {
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

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.view endEditing:YES];
}

@end
