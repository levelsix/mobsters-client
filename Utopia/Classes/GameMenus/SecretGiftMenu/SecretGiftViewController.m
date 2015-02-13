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
#import "GameViewController.h"

#import "OutgoingEventController.h"

@implementation SecretGiftViewController

- (id) initWithSecretGift:(UserItemSecretGiftProto *)sg {
  if ((self = [super init])) {
    self.secretGift = sg;
  }
  return self;
}

- (id) initWithBoosterItem:(BoosterItemProto *)bi {
  if ((self = [super init])) {
    self.boosterItem = bi;
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
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  [self reload];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  [self reload];
  
  if (self.boosterItem) {
    [self.homeTitleView.titleImageView removeFromSuperview];
    self.homeTitleView.titleLabel.text = @"ITEM OPENED!";
    self.homeTitleView.titleLabel.font = [UIFont fontWithName:self.homeTitleView.titleLabel.font.fontName size:16.f];
    self.homeTitleView.titleLabel.centerY -= 16.f;
  }
}

- (void) reload {
  UserItem *ui = [[UserItem alloc] init];
  
  if (self.secretGift) {
    // Create a UserItem so we can use ItemObject protocol
    ui.itemId = self.secretGift.itemId;
    ui.quantity = 1;
  } else {
    ui.itemId = self.boosterItem.itemId;
    ui.quantity = self.boosterItem.itemQuantity;
  }
  
  self.itemNameLabel.text = [NSString stringWithFormat:@"%d x %@", ui.quantity, [[ui name] uppercaseString]];
  self.iconLabel.text = [ui iconText];
  self.itemQuantityLabel.text = [NSString stringWithFormat:@"%dx", ui.quantity];
  
  [Globals imageNamed:[ui iconImageName] withView:self.itemIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
}

- (IBAction)collectClicked:(id)sender {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSInteger giftsCollected = [defaults integerForKey:SECRET_GIFTS_ACCEPTED_KEY];
  if (self.secretGift) {
    [[OutgoingEventController sharedOutgoingEventController] redeemSecretGift:self.secretGift];
    
    giftsCollected++;
    [defaults setInteger:giftsCollected forKey:SECRET_GIFTS_ACCEPTED_KEY];
  }
  
  [self closeWithGiftCount:giftsCollected];
}

- (void) closeWithGiftCount:(NSInteger)giftsCollected {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  GameViewController *gvc = [GameViewController baseController];
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    if ((giftsCollected == 2 || giftsCollected == 40) && ![defaults boolForKey:[Globals userConfimredPushNotificationsKey]]) {
      [gvc openPushNotificationRequestWithMessage:@"Would you like to recieve push notifications when your secret gift is ready?"];
    }
  }];
}

@end
