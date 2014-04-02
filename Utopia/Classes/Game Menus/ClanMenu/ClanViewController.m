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

@implementation ClanViewController

- (void) viewDidLoad {
  self.clanBrowseViewController = [[ClanBrowseViewController alloc] initWithNibName:nil bundle:nil];
  self.clanInfoViewController = [[ClanInfoViewController alloc] initWithNibName:nil bundle:nil];
  self.clanCreateViewController = [[ClanCreateViewController alloc] initWithNibName:nil bundle:nil];
  self.clanRaidViewController = [[ClanRaidListViewController alloc] initWithNibName:nil bundle:nil];
  
  [self addChildViewController:self.clanBrowseViewController];
  [self addChildViewController:self.clanInfoViewController];
  [self addChildViewController:self.clanCreateViewController];
  [self addChildViewController:self.clanRaidViewController];
  
  self.title = @"Clans";
  self.navigationItem.titleView = self.menuTopBar;
  [self setUpCloseButton];
  [self setUpImageBackButton];
  
  _shouldLoadFirstController = YES;
  
  [[OutgoingEventController sharedOutgoingEventController] registerClanEventDelegate:self];
}

- (void) viewWillAppear:(BOOL)animated {
  if (_shouldLoadFirstController) {
    [self updateConfiguration];
    [self button1Clicked:nil];
    _shouldLoadFirstController = NO;
    
    [self.clanBrowseViewController reload];
  }
}

- (void) willMoveToParentViewController:(UIViewController *)parent {
  if (!parent) {
    [[OutgoingEventController sharedOutgoingEventController] unregisterClanEventDelegate:self];
  }
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
  
  self.menuTopBar.label1.text = @"MY CLAN";
  self.menuTopBar.label2.text = @"BROWSE";
}

- (void) loadNotInClanConfiguration {
  _controller1 = self.clanBrowseViewController;
  _controller2 = self.clanCreateViewController;
  
  self.menuTopBar.label1.text = @"JOIN";
  self.menuTopBar.label2.text = @"CREATE";
}

- (void) button1Clicked:(id)sender {
  [self.clanCreateViewController.view removeFromSuperview];
  [self.clanBrowseViewController.view removeFromSuperview];
  [self.clanInfoViewController.view removeFromSuperview];
  
  [self.view addSubview:_controller1.view];
  _controller1.view.frame = self.view.bounds;
  
  [self.menuTopBar clickButton:kButton1];
  [self.menuTopBar unclickButton:kButton2];
}

- (void) button2Clicked:(id)sender {
  [self.clanCreateViewController.view removeFromSuperview];
  [self.clanBrowseViewController.view removeFromSuperview];
  [self.clanInfoViewController.view removeFromSuperview];
  
  [self.view addSubview:_controller2.view];
  _controller2.view.frame = self.view.bounds;
  
  [self.menuTopBar clickButton:kButton2];
  [self.menuTopBar unclickButton:kButton1];
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
    [self button1Clicked:nil];
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
    [self button1Clicked:nil];
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
