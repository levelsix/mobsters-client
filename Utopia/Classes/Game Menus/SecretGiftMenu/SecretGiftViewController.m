//
//  SecretGiftViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/25/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SecretGiftViewController.h"

#import "Globals.h"
#import "GameState.h"

#import "OutgoingEventController.h"

@implementation SecretGiftViewController

- (id) initWithSecretGift:(UserItemSecretGiftProto *)sg {
  if ((self = [super init])) {
    self.secretGift = sg;
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.containerView.superview.layer.cornerRadius = 5.f;
  self.containerView.superview.clipsToBounds = YES;
  
  self.congratsLabel.gradientStartColor = [UIColor colorWithHexString:@"edfaff"];
  self.congratsLabel.gradientEndColor = [UIColor colorWithHexString:@"a0e3ff"];
  self.congratsLabel.strokeColor = [UIColor colorWithHexString:@"094984"];
  self.congratsLabel.strokeSize = 1.f;
  self.congratsLabel.shadowBlur = 0.5f;
  
  self.receivedLabel.strokeColor = [UIColor colorWithHexString:@"094984"];
  self.receivedLabel.strokeSize = 0.8f;
  
  self.iconLabel.strokeSize = 1.5f;
  self.iconLabel.strokeColor = [UIColor colorWithHexString:@"ebebeb"];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  [self reload];
}

- (void) reload {
  if (self.secretGift) {
    // Create a UserItem so we can use ItemObject protocol
    UserItem *ui = [[UserItem alloc] init];
    ui.itemId = self.secretGift.itemId;
    
    self.itemNameLabel.text = [NSString stringWithFormat:@"1 x %@", [[ui name] uppercaseString]];
    self.iconLabel.text = [ui iconText];
    
    [Globals imageNamed:[ui iconImageName] withView:self.itemIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  }
}

- (IBAction)collectClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] redeemSecretGift:self.secretGift];
  
  [self close];
}

- (void) close {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

@end
