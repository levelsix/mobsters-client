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

#define DISAPPEAR_BOTTOM_Y ([Globals isiPad] ? 575.f : 350.f)
#define DISAPPEAR_BOTTOM_X ([Globals isiPad] ? 105.f : 75.f)

@implementation GenericPopupController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  // Retain the targets so it will never access null object
  self.targets = [NSMutableArray array];
}

- (void) displayPopup {
  [super displayView];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (void) setDescriptionString:(NSString *)labelText {
  NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  [paragraphStyle setLineSpacing:1.5];
  [paragraphStyle setAlignment:NSTextAlignmentCenter];
  [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
  self.descriptionLabel.attributedText = attributedString;
}

+ (GenericPopupController *) displayNotificationViewWithText:(NSString *)string title:(NSString *)title {
  GenericPopupController *gp = [[GenericPopupController alloc] init];
  [gp displayPopup];
  [gp setDescriptionString:string];
  gp.titleLabel.text = title;
  return gp;
}

+ (GenericPopupController *) displayNotificationViewWithText:(NSString *)string title:(NSString *)title okayButton:(NSString *)okay target:(id)target selector:(SEL)selector {
  GenericPopupController *gp = [self displayNotificationViewWithText:string title:title];
  
  gp.notifButtonLabel.text = okay;
  
	if (target) {
    [gp.notifButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [gp.targets addObject:target];
  }
  
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
  [gp setDescriptionString:description];
  gp.confOkayButtonLabel.text = okay;
  gp.confCancelButtonLabel.text = cancel;
  
  if (target) {
    [gp.confOkayButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [gp.targets addObject:target];
  }
  
  return gp;
}

+ (GenericPopupController *) displayConfirmationWithDescription:(NSString *)description title:(NSString *)title okayButton:(NSString *)okay cancelButton:(NSString *)cancel okTarget:(id)okTarget okSelector:(SEL)okSelector cancelTarget:(id)cancelTarget cancelSelector:(SEL)cancelSelector {
  GenericPopupController *gp = [GenericPopupController displayConfirmationWithDescription:description title:title okayButton:okay cancelButton:cancel target:okTarget selector:okSelector];
  
  if (cancelTarget) {
    [gp.confCancelButton addTarget:cancelTarget action:cancelSelector forControlEvents:UIControlEventTouchUpInside];
    [gp.targets addObject:cancelTarget];
  }
  
  return gp;
}

+ (GenericPopupController *) displayNegativeConfirmationWithDescription:(NSString *)description title:(NSString *)title okayButton:(NSString *)okay cancelButton:(NSString *)cancel okTarget:(id)okTarget okSelector:(SEL)okSelector cancelTarget:(id)cancelTarget cancelSelector:(SEL)cancelSelector {
  GenericPopupController *gp = [GenericPopupController displayConfirmationWithDescription:description title:title okayButton:okay cancelButton:cancel okTarget:okTarget okSelector:okSelector cancelTarget:cancelTarget cancelSelector:cancelSelector];
  
  [gp.confOkayButton setImage:[Globals imageNamed:@"orangemediumbutton.png"] forState:UIControlStateNormal];
  gp.titleBgd.image = [Globals imageNamed:@"orangenotificationheader.png"];
  
  //iPad version of header
  gp.titleBgdLeft.image = gp.titleBgdRight.image = [Globals imageNamed:@"orangenotificationheadercap.png"];
  gp.titleBgdMiddle.image = [Globals imageNamed:@"orangenotificationheadermiddle.png"];
  
  gp.confOkayButtonLabel.textColor = [UIColor colorWithRed:193/255.f green:38/255.f blue:12/255.f alpha:1.f];
  gp.confOkayButtonLabel.shadowColor = [UIColor colorWithRed:250/255.f green:199/255.f blue:72/255.f alpha:0.75f];
  
  return gp;
}

+ (GenericPopupController *) displayNegativeConfirmationWithMiddleView:(UIView *)view title:(NSString *)title okayButton:(NSString *)okay cancelButton:(NSString *)cancel okTarget:(id)okTarget okSelector:(SEL)okSelector cancelTarget:(id)cancelTarget cancelSelector:(SEL)cancelSelector {
  GenericPopupController *gp = [self displayNegativeConfirmationWithDescription:@"" title:title okayButton:okay cancelButton:cancel okTarget:okTarget okSelector:okSelector cancelTarget:cancelTarget cancelSelector:cancelSelector];
  
  [gp.mainView addSubview:view];
  view.center = gp.descriptionView.center;
  [gp.descriptionView removeFromSuperview];
  
  return gp;
}

+ (GenericPopupController *) displayNotEnoughGemsViewWithTarget:(id)target selector:(SEL)selector {
  GenericPopupController *gp = [GenericPopupController displayNotificationViewWithText:@"You don't have enough gems.\nWant more?" title:@"Not Enough Gems" okayButton:@"Enter Shop" target:target selector:selector];
  
  [gp.notifButton setImage:[Globals imageNamed:@"purplemediumbutton.png"] forState:UIControlStateNormal];
  gp.titleBgd.image = [Globals imageNamed:@"purplenotificationheader.png"];
  
  //iPad version of header
  gp.titleBgdLeft.image = gp.titleBgdRight.image = [Globals imageNamed:@"purplenotificationheadercap.png"];
  gp.titleBgdMiddle.image = [Globals imageNamed:@"purplenotificationheadermiddle.png"];
  
  gp.notifButtonLabel.textColor = [UIColor whiteColor];
  gp.notifButtonLabel.shadowColor = [UIColor colorWithRed:40/255.f green:0/255.f blue:100/255.f alpha:0.75f];
  
  gp.closeButton.hidden = NO;
  
  return gp;
}

+ (GenericPopupController *) displayNotEnoughGemsView {
  return [self displayNotEnoughGemsViewWithTarget:[GameViewController baseController] selector:@selector(openGemShop)];
}

+ (GenericPopupController *) displayGemConfirmViewWithDescription:(NSString *)description title:(NSString *)title gemCost:(int)gemCost target:(id)target selector:(SEL)selector {
  GenericPopupController *gp = [[GenericPopupController alloc] init];
  [gp displayPopup];
  
  [gp.mainView addSubview:gp.gemView];
  gp.gemView.center = gp.notificationView.center;
  [gp.notificationView removeFromSuperview];
  
  gp.titleLabel.text = title;
  gp.titleBgd.image = [Globals imageNamed:@"purplenotificationheader.png"];
  
  //iPad version of header
  gp.titleBgdLeft.image = gp.titleBgdRight.image = [Globals imageNamed:@"purplenotificationheadercap.png"];
  gp.titleBgdMiddle.image = [Globals imageNamed:@"purplenotificationheadermiddle.png"];
  
  [gp setDescriptionString:description];
  gp.gemButtonLabel.text = [Globals commafyNumber:gemCost];
  [Globals adjustViewForCentering:gp.gemButtonLabel.superview withLabel:gp.gemButtonLabel];
  
  if (target) {
    [gp.gemButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [gp.targets addObject:target];
  }
  
  gp.closeButton.hidden = NO;
  
  return gp;
}

+ (GenericPopupController *) displayExchangeForGemsViewWithResourceType:(ResourceType)resourceType amount:(int)amount target:(id)target selector:(SEL)selector {
  Globals *gl = [Globals sharedGlobals];
  
  BOOL isCash = resourceType == ResourceTypeCash;
  NSString *type = isCash ? @"cash" : @"oil";
  NSString *title = [NSString stringWithFormat:@"You need more %@", type];
  NSString *resources = isCash ? [Globals cashStringForNumber:amount] : [NSString stringWithFormat:@"%@ %@", [Globals commafyNumber:amount], type];
  NSString *description = [NSString stringWithFormat:@"Buy the missing %@?", resources];
  int gemCost = [gl calculateGemConversionForResourceType:resourceType amount:amount];
  
  GenericPopupController *gp = [GenericPopupController displayGemConfirmViewWithDescription:description title:title gemCost:gemCost target:target selector:selector];
  
  return gp;
}

- (void) close:(id)sender {
  [UIView animateWithDuration:0.7f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
    CGAffineTransform t = CGAffineTransformIdentity;
    t = CGAffineTransformScale(t, 0.75f, 0.75f);
    t = CGAffineTransformRotate(t, DISAPPEAR_ROTATION_ANGLE);
    self.mainView.transform = t;
    self.mainView.center = CGPointMake(self.mainView.center.x-DISAPPEAR_BOTTOM_X, self.mainView.center.y+DISAPPEAR_BOTTOM_Y);
    self.bgdView.alpha = 0.f;
  } completion:^(BOOL finished) {
    [self removeView];
  }];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.view endEditing:YES];
}

@end
