//
//  TutorialFacebookViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/6/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialFacebookViewController.h"
#import "Globals.h"
#import "FacebookDelegate.h"
#import "GenericPopupController.h"

#import "Analytics.h"

@implementation TutorialFacebookViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  [Analytics tutorialFbPopup];
}

- (void) allowClick {
  self.spinner.hidden = YES;
  self.connectLabel.hidden = NO;
  self.view.userInteractionEnabled = YES;
}

- (IBAction)connectClicked:(id)sender {
  self.spinner.hidden = NO;
  self.connectLabel.hidden = YES;
  self.view.userInteractionEnabled = NO;
  [Analytics tutorialFbPopupConnect];
  [FacebookDelegate openSessionWithLoginUI:YES completionHandler:^(BOOL success) {
    if (success) {
      [self.delegate facebookConnectAccepted];
      [Analytics tutorialFbPopupConnectSuccess];
    } else {
      [self allowClick];
      [Analytics tutorialFbPopupConnectFail];
    }
  }];
}

- (IBAction)skipClicked:(id)sender {
  //[self rejectionConfirmed];
  [Analytics tutorialFbPopupConnectSkip];
  NSString *desc = @"This is a once in a lifetime oppurtunity that you'll tell your grandchildren about. Please reconsider!";
  [GenericPopupController displayNegativeConfirmationWithDescription:desc title:@"You Don't Like Free Stuff?" okayButton:@"Connect" cancelButton:@"Skip" okTarget:self okSelector:@selector(rejectionRejected) cancelTarget:self cancelSelector:@selector(rejectionConfirmed)];
}

- (void) rejectionRejected {
  self.spinner.hidden = NO;
  self.connectLabel.hidden = YES;
  self.view.userInteractionEnabled = NO;
  [Analytics tutorialFbConfirmConnect];
  [FacebookDelegate openSessionWithLoginUI:YES completionHandler:^(BOOL success) {
    if (success) {
      [self.delegate facebookConnectAccepted];
      [Analytics tutorialFbConfirmConnectSuccess];
    } else {
      [self allowClick];
      [Analytics tutorialFbConfirmConnectFail];
    }
  }];
}

- (void) rejectionConfirmed {
  [self.delegate facebookConnectRejected];
  [Analytics tutorialFbConfirmSkip];
}

- (void) close {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

@end
