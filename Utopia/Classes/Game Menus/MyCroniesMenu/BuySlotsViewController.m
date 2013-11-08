//
//  BuySlotsViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/3/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "BuySlotsViewController.h"
#import "Globals.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation FriendAcceptView

- (void) awakeFromNib {
  UIImage *maskImage = [UIImage imageNamed:@"fullfriendmask.png"];
  CALayer *mask = [CALayer layer];
  mask.contents = (id)[maskImage CGImage];
  mask.frame = CGRectMake(0, 0, self.profPicView.frame.size.width, self.profPicView.frame.size.height);
  self.profPicView.layer.mask = mask;
}

- (void) updateForFacebookId:(NSString *)uid {
  if (uid) {
    self.bgdView.highlighted = YES;
    self.slotNumLabel.hidden = YES;
    self.profPicView.hidden = NO;
    
    // add the stuff at the end so it knows where to save it
    self.profPicView.profileID = uid;
  } else {
    self.bgdView.highlighted = NO;
    self.slotNumLabel.hidden = NO;
    self.profPicView.hidden = YES;
  }
}

@end

@implementation BuySlotsViewController

- (void) viewDidLoad {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  [self.addSlotsView.superview addSubview:self.askFriendsView];
  self.askFriendsView.frame = self.addSlotsView.frame;
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  self.numSlotsLabel.text = [NSString stringWithFormat:@"Add %d slots to your team reserves!", gl.inventoryIncreaseSizeAmount];
  self.gemCostLabel.text = [NSString stringWithFormat:@"%d", gl.inventoryIncreaseSizeCost];
  
  self.chooserView.blacklistFriendIds = gs.usersUsedForExtraSlots;
  
  [self transitionToAddSlotsView:NO];
  
  [self updateAcceptedSlots];
}

- (void) updateAcceptedSlots {
  GameState *gs = [GameState sharedGameState];
  for (int i = 0; i < gs.acceptedSlotsRequests.count && i < self.acceptViews.count; i++) {
    FriendAcceptView *accept = self.acceptViews[i];
    RequestFromFriend *req = gs.acceptedSlotsRequests[i];
    
    [accept updateForFacebookId:req.invite.inviter.facebookId];
  }
}

#pragma mark - Swapping Views

- (void) transitionToAskFriendsView {
  self.askFriendsView.center = ccp(self.askFriendsView.frame.size.width*3/2, self.askFriendsView.center.y);
  self.backView.alpha = 0.f;
  self.sendView.alpha = 0.f;
  [UIView animateWithDuration:0.3f animations:^{
    self.askFriendsView.center = ccp(self.askFriendsView.frame.size.width/2, self.askFriendsView.center.y);
    self.addSlotsView.center = ccp(-self.addSlotsView.frame.size.width/2, self.addSlotsView.center.y);
    self.backView.alpha = 1.f;
    self.sendView.alpha = 1.f;
    self.closeView.alpha = 0.f;
  }];
}

- (void) transitionToAddSlotsView:(BOOL)animated {
  void (^comp)()  = ^{
    self.askFriendsView.center = ccp(self.askFriendsView.frame.size.width*3/2, self.askFriendsView.center.y);
    self.addSlotsView.center = ccp(self.addSlotsView.frame.size.width/2, self.addSlotsView.center.y);
    self.backView.alpha = 0.f;
    self.sendView.alpha = 0.f;
    self.closeView.alpha = 1.f;
  };
  
  if (animated) {
    [UIView animateWithDuration:0.3f animations:comp];
  } else {
    comp();
  }
}

#pragma mark - IBActions

- (IBAction)buyWithGemsClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] buyInventorySlots];
  [self closeClicked:nil];
  [self.delegate slotsPurchased];
}

- (IBAction)askFriendsClicked:(id)sender {
  [self transitionToAskFriendsView];
}

- (IBAction)backClicked:(id)sender {
  [self transitionToAddSlotsView:YES];
}

- (IBAction)sendClicked:(id)sender {
  if (self.chooserView.selectedIds.count > 0) {
    [self.chooserView sendRequestWithString:@"Please help me add slots!" completionBlock:^(BOOL success, NSArray *friendIds) {
      if (success && friendIds.count > 0) {
        [[OutgoingEventController sharedOutgoingEventController] inviteAllFacebookFriends:friendIds];
      }
      [self closeClicked:nil];
    }];
  }
}

- (IBAction)closeClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

@end
