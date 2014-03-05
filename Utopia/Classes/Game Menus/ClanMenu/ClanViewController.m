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
}

- (void) viewWillAppear:(BOOL)animated {
  BOOL _firstTime = !_controller1;
  [self updateConfiguration];
  
  if (_firstTime) {
    [self button1Clicked:nil];
  }
  
  // Do this so it reloads the list when it comes back from other view
  [self.clanBrowseViewController reload];
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
  _controller2 = self.clanRaidViewController;
  
  self.menuTopBar.label1.text = @"MY CLAN";
  self.menuTopBar.label2.text = @"RAIDS";
}

- (void) loadNotInClanConfiguration {
  _controller1 = self.clanBrowseViewController;
  _controller2 = self.clanCreateViewController;
  
  self.menuTopBar.label1.text = @"JOIN CLAN";
  self.menuTopBar.label2.text = @"CREATE CLAN";
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

- (void) handleCreateClanResponseProto:(FullEvent *)e {
  [self updateConfiguration];
  [self button1Clicked:nil];
}

- (void) handleLeaveClanResponseProto:(FullEvent *)e {
  [self updateConfiguration];
  [self button1Clicked:nil];
}

- (void) handleRequestJoinClanResponseProto:(FullEvent *)e {
  RequestJoinClanResponseProto *proto = (RequestJoinClanResponseProto *)e.event;
  if (proto.status == RequestJoinClanResponseProto_RequestJoinClanStatusJoinSuccess) {
    [self updateConfiguration];
    [self button1Clicked:nil];
  } else {
    [self.clanBrowseViewController.browseClansTable reloadData];
  }
}

- (void) handleRetractRequestJoinClanResponseProto:(FullEvent *)e {
  [self.clanBrowseViewController.browseClansTable reloadData];
}

- (void) handleRetrieveClanInfoResponseProto:(FullEvent *)fe {
  [self.clanInfoViewController handleRetrieveClanInfoResponseProto:fe];
  
  GameState *gs = [GameState sharedGameState];
  RetrieveClanInfoResponseProto *proto = (RetrieveClanInfoResponseProto *)fe.event;
  if (proto.clanInfoList.count == 1 && ((FullClanProtoWithClanSize *)proto.clanInfoList[0]).clan.clanId == gs.clan.clanId) {
    if (!self.clanRaidViewController.raidViewController.leaderboardViewController.members) {
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
