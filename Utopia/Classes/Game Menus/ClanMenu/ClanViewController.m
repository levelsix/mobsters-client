//
//  ClanViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 9/10/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ClanViewController.h"
#import "GameState.h"
#import "Globals.h"
#import "LNSynthesizeSingleton.h"
#import "OutgoingEventController.h"
#import "GenericPopupController.h"
#import "ClanBrowseViewController.h"
#import "ClanInfoViewController.h"
#import "ClanCreateViewController.h"
#import "ClanRaidListViewController.h"

@implementation ClanViewController

- (void) viewDidLoad {
  self.clanBrowseViewController = [[ClanBrowseViewController alloc] init];
  self.clanInfoViewController = [[ClanInfoViewController alloc] init];
  self.clanCreateViewController = [[ClanCreateViewController alloc] init];
  self.clanRaidViewController = [[ClanRaidListViewController alloc] init];
  
  [[OutgoingEventController sharedOutgoingEventController] registerClanEventDelegate:self];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  self.viewControllers = [NSMutableArray array];
  
  self.backView.alpha = 0.f;
}

- (void) viewWillAppear:(BOOL)animated {
  [self updateConfiguration];
  
  GameState *gs = [GameState sharedGameState];
  if (gs.clan) {
    [self button2Clicked:nil];
  } else {
    [self button1Clicked:nil];
  }
  
  [self.clanBrowseViewController reload];
}

- (void) viewWillDisappear:(BOOL)animated {
  [[OutgoingEventController sharedOutgoingEventController] unregisterClanEventDelegate:self];
}

- (void) updateConfiguration {
  GameState *gs = [GameState sharedGameState];
  if (gs.clan) {
    [self loadInClanConfiguration];
    [self.clanInfoViewController loadForMyClan];
  } else {
    [self loadNotInClanConfiguration];
  }
}

- (void) loadInClanConfiguration {
  _controller1 = self.clanInfoViewController;
  _controller2 = self.clanBrowseViewController;
  
  [self.topBar button:2 shouldBeHidden:NO];
  [self.topBar button:3 shouldBeHidden:YES];
}

- (void) loadNotInClanConfiguration {
  _controller1 = self.clanBrowseViewController;
  _controller2 = self.clanCreateViewController;
  
  [self.topBar button:2 shouldBeHidden:YES];
  [self.topBar button:3 shouldBeHidden:NO];
}

- (void) button1Clicked:(id)sender {
  [self unloadAllControllers];
  [self pushViewController:self.clanBrowseViewController animated:NO];
  
  [self.topBar clickButton:1];
}

- (void) button2Clicked:(id)sender {
  [self unloadAllControllers];
  [self pushViewController:self.clanInfoViewController animated:NO];
  
  [self.topBar clickButton:2];
}

- (void) button3Clicked:(id)sender {
  [self unloadAllControllers];
  [self pushViewController:self.clanCreateViewController animated:NO];
  
  [self.topBar clickButton:3];
}

- (IBAction) backClicked:(id)sender {
  if (!self.viewControllers.count || [[self.viewControllers lastObject] canGoBack]) {
    [self goBack];
  }
}

- (void) goBack {
  [self popViewControllerAnimated:YES];
}

- (IBAction) closeClicked:(id)sender {
  if (!self.viewControllers.count || [[self.viewControllers lastObject] canGoBack]) {
    [self close];
  }
}

- (void) close {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

#pragma mark - Navigation Controller

- (void) pushViewController:(ClanSubViewController *)viewController animated:(BOOL)animated {
  UIViewController *curVc = [self.viewControllers lastObject];
  [self.viewControllers addObject:viewController];
  
  BOOL shouldDisplayBackButton = NO;
  if (self.viewControllers.count > 1) {
    shouldDisplayBackButton = YES;
    self.backLabel.text = [self.viewControllers[self.viewControllers.count-2] title];
    [self.backMaskedButton remakeImage];
  }
  
  [self.containerView addSubview:viewController.view];
  [self addChildViewController:viewController];
  viewController.view.frame = self.containerView.bounds;
  if (animated) {
    viewController.view.center = ccp(self.containerView.frame.size.width*3/2, self.containerView.frame.size.height/2);
    [UIView animateWithDuration:0.3f animations:^{
      viewController.view.center = ccp(self.containerView.frame.size.width/2, self.containerView.frame.size.height/2);
      curVc.view.center = ccp(-self.containerView.frame.size.width/2, self.containerView.frame.size.height/2);
      self.backView.alpha = shouldDisplayBackButton;
    } completion:^(BOOL finished) {
      [curVc.view removeFromSuperview];
    }];
  } else {
    self.backView.alpha = shouldDisplayBackButton;
    [curVc.view removeFromSuperview];
  }
}

- (UIViewController *) popViewControllerAnimated:(BOOL)animated {
  UIViewController *removeVc = [self.viewControllers lastObject];
  [self.viewControllers removeObject:removeVc];
  UIViewController *topVc = [self.viewControllers lastObject];
  
  BOOL shouldDisplayBackButton = NO;
  if (self.viewControllers.count > 1) {
    shouldDisplayBackButton = YES;
    self.backLabel.text = [self.viewControllers[self.viewControllers.count-2] title];
    [self.backMaskedButton remakeImage];
  }
  
  [self.containerView addSubview:topVc.view];
  if (animated) {
    topVc.view.center = ccp(-self.containerView.frame.size.width/2, self.containerView.frame.size.height/2);
    [UIView animateWithDuration:0.3f animations:^{
      removeVc.view.center = ccp(self.containerView.frame.size.width*3/2, self.containerView.frame.size.height/2);
      topVc.view.frame = self.containerView.bounds;
      self.backView.alpha = shouldDisplayBackButton;
    } completion:^(BOOL finished) {
      [removeVc.view removeFromSuperview];
      [removeVc removeFromParentViewController];
    }];
  } else {
    [removeVc.view removeFromSuperview];
    [removeVc removeFromParentViewController];
    self.backView.alpha = shouldDisplayBackButton;
    
    topVc.view.frame = self.containerView.bounds;
  }
  
  return removeVc;
}

- (void) unloadAllControllers {
  for (UIViewController *vc in self.viewControllers) {
    [vc.view removeFromSuperview];
    [vc removeFromParentViewController];
  }
  [self.viewControllers removeAllObjects];
}

#pragma mark - Response handlers

- (void) handleClanEventCreateClanResponseProto:(CreateClanResponseProto *)proto {
  if (proto.status == CreateClanResponseProto_CreateClanStatusSuccess) {
    [self updateConfiguration];
    [self button1Clicked:nil];
  } else if (proto.status == CreateClanResponseProto_CreateClanStatusFailNameTaken) {
    [Globals popupMessage:@"Sorry, this name is already in use."];
  } else if (proto.status == CreateClanResponseProto_CreateClanStatusFailTagTaken) {
    [Globals popupMessage:@"Sorry, this tag is already in use."];
  } else {
    [Globals popupMessage:@"Sorry, something went wrong! Please try again."];
  }
}

- (void) handleClanEventLeaveClanResponseProto:(LeaveClanResponseProto *)proto {
  GameState *gs = [GameState sharedGameState];
  if (proto.sender.userId == gs.userId && proto.status == LeaveClanResponseProto_LeaveClanStatusSuccess) {
    [self updateConfiguration];
    [self button1Clicked:nil];
  }
}

- (void) handleClanEventApproveOrRejectRequestToJoinClanResponseProto:(ApproveOrRejectRequestToJoinClanResponseProto *)proto {
  GameState *gs = [GameState sharedGameState];
  if (proto.requester.userId == gs.userId && proto.accept && proto.status == ApproveOrRejectRequestToJoinClanResponseProto_ApproveOrRejectRequestToJoinClanStatusSuccess) {
    [self updateConfiguration];
    [self button2Clicked:nil];
  }
}

- (void) handleClanEventBootPlayerFromClanResponseProto:(BootPlayerFromClanResponseProto *)proto {
  GameState *gs = [GameState sharedGameState];
  if (proto.playerToBoot.userId == gs.userId && proto.status == BootPlayerFromClanResponseProto_BootPlayerFromClanStatusSuccess) {
    [self updateConfiguration];
    [self button1Clicked:nil];
  }
}

- (void) handleClanEventRequestJoinClanResponseProto:(LeaveClanResponseProto *)proto {
  GameState *gs = [GameState sharedGameState];
  if (proto.sender.userId == gs.userId && proto.status == RequestJoinClanResponseProto_RequestJoinClanStatusSuccessJoin) {
    [self updateConfiguration];
    [self button2Clicked:nil];
  }
}

- (void) handleRetrieveClanInfoResponseProto:(FullEvent *)fe {
  [self.clanInfoViewController handleRetrieveClanInfoResponseProto:fe];
  
  GameState *gs = [GameState sharedGameState];
  RetrieveClanInfoResponseProto *proto = (RetrieveClanInfoResponseProto *)fe.event;
  if (proto.clanInfoList.count == 1 && ((FullClanProtoWithClanSize *)proto.clanInfoList[0]).clan.clanId == gs.clan.clanId) {
    if (!self.clanRaidViewController.raidViewController.leaderboardViewController.allMembers) {
      [self.clanRaidViewController.raidViewController.leaderboardViewController createMembersListFromClanMembers:proto.membersList];
    }
    self.myClanMembersList = proto.membersList;
    
    if (self.clanInfoViewController.myUser) {
      UserClanStatus status = self.clanInfoViewController.myUser.clanStatus;
      switch (status) {
        case UserClanStatusLeader:
        case UserClanStatusJuniorLeader:
        case UserClanStatusCaptain:
          self.canStartRaidStage = YES;
          break;
          
        default:
          break;
      }
    }
  }
}

@end
