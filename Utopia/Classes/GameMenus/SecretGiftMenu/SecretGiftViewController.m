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
#import "SoundEngine.h"

#import "OutgoingEventController.h"

@implementation SecretGiftViewController

- (id) initWithSecretGift:(UserSecretGiftProto *)sg {
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
    
    self.receivedLabel.text = @"You received an item!";
  }
  
  [SoundEngine secretGiftClicked];
  
  [[GameViewController baseController] clearTutorialArrows];
}

- (void) viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  //  [[GameViewController baseController] showEarlyGameTutorialArrow];
}

- (void) reload {
  Reward *reward = nil;
  
  if (self.secretGift) {
    reward = [[Reward alloc] initWithReward:self.secretGift.reward];
  } else if (self.boosterItem) {
    reward = [[Reward alloc] initWithReward:self.boosterItem.reward];
  }
  
  int quantity = reward.quantity;
  NSString *shorterName = [reward shorterName];
  
  self.itemNameLabel.text = [NSString stringWithFormat:@"%d x %@", quantity, [[reward name] uppercaseString]];
  
  if (shorterName) {
    self.iconLabel.text = shorterName;
  } else {
    self.iconLabel.hidden = YES;
  }
  
  if (quantity > 1) {
    self.itemQuantityLabel.text = [NSString stringWithFormat:@"%dx", reward.quantity];
  } else {
    self.itemQuantityLabel.superview.hidden = YES;
  }
  
  [Globals imageNamed:[reward imgName] withView:self.itemIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
}

- (IBAction)collectClicked:(id)sender {
  if (_isSpinning) {
    return;
  }
  
  if (self.secretGift) {
    BOOL requiresSpinner = self.secretGift.reward.typ == RewardProto_RewardTypeMonster || self.secretGift.reward.typ == RewardProto_RewardTypeReward;
    
    if (requiresSpinner) {
      [[OutgoingEventController sharedOutgoingEventController] redeemSecretGift:self.secretGift delegate:self];
      
      self.spinner.hidden = NO;
      [self.spinner startAnimating];
      self.collectLabel.hidden = YES;
      
      _isSpinning = YES;
    } else {
      [[OutgoingEventController sharedOutgoingEventController] redeemSecretGift:self.secretGift delegate:nil];
      
      [self closeWithGiftCount:[self incrementGiftsCollected]];
    }
  } else {
    [self close];
  }
}

- (void) handleRedeemSecretGiftResponseProto:(FullEvent *)fe {
  RedeemSecretGiftResponseProto *proto = (RedeemSecretGiftResponseProto *)fe.event;
  
  if (proto.status == ResponseStatusSuccess) {
    
    self.spinner.hidden = YES;
    self.collectLabel.hidden = NO;
    
    [self closeWithGiftCount:[self incrementGiftsCollected]];
  } else {
    [self close];
  }
}

- (int) incrementGiftsCollected {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  int giftsCollected = (int)[defaults integerForKey:SECRET_GIFTS_ACCEPTED_KEY];
  
  giftsCollected++;
  [defaults setInteger:giftsCollected forKey:SECRET_GIFTS_ACCEPTED_KEY];
  
  return giftsCollected;
}

- (void) closeWithGiftCount:(NSInteger)giftsCollected {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  GameViewController *gvc = [GameViewController baseController];
  
  [self close];
  
  if ((giftsCollected == 2 || giftsCollected == 40) && ![defaults boolForKey:[Globals userConfimredPushNotificationsKey]]) {
    [gvc openPushNotificationRequestWithMessage:@"Would you like to recieve push notifications when your secret gift is ready?"];
  }
}

- (void) close {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

@end
