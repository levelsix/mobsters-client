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

@implementation TutorialFacebookViewController

- (void) viewDidLoad {
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
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
  [FacebookDelegate openSessionWithReadPermissionsWithLoginUI:YES completionHandler:^(BOOL success) {
    if (success) {
      [self.delegate facebookConnectAccepted];
    } else {
      [self allowClick];
    }
  }];
}

- (IBAction)skipClicked:(id)sender {
  NSString *desc = @"This is a once in a lifetime oppurtunity that you'll tell your grandchildren about. Please reconsider!";
  [GenericPopupController displayNegativeConfirmationWithDescription:desc title:@"You Don't Like Free Stuff?" okayButton:@"Connect" cancelButton:@"Continue" okTarget:self okSelector:@selector(rejectionRejected) cancelTarget:self cancelSelector:@selector(rejectionConfirmed)];
}

- (void) rejectionRejected {
  [self connectClicked:nil];
}

- (void) rejectionConfirmed {
  [self.delegate facebookConnectRejected];
}

- (void) close {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

@end
