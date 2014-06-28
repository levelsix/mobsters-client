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
  [super viewDidLoad];
  
  self.clanBrowseViewController = [[ClanBrowseViewController alloc] init];
  self.clanInfoViewController = [[ClanInfoViewController alloc] init];
  self.clanCreateViewController = [[ClanCreateViewController alloc] init];
  self.clanRaidViewController = [[ClanRaidListViewController alloc] init];
  
  [[OutgoingEventController sharedOutgoingEventController] registerClanEventDelegate:self];
  [[OutgoingEventController sharedOutgoingEventController] registerClanEventDelegate:self.clanBrowseViewController];
  [[OutgoingEventController sharedOutgoingEventController] registerClanEventDelegate:self.clanInfoViewController];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self updateConfiguration];
  
  GameState *gs = [GameState sharedGameState];
  if (gs.clan) {
    [self button2Clicked:nil];
  } else {
    [self button1Clicked:nil];
  }
  
  [self.clanBrowseViewController reload];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [[OutgoingEventController sharedOutgoingEventController] unregisterClanEventDelegate:self];
  [[OutgoingEventController sharedOutgoingEventController] unregisterClanEventDelegate:self.clanBrowseViewController];
  [[OutgoingEventController sharedOutgoingEventController] unregisterClanEventDelegate:self.clanInfoViewController];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void) loadForClanId:(int)clanId {
  ClanInfoViewController *civc = [[ClanInfoViewController alloc] initWithClanId:clanId andName:nil];
  [self replaceRootWithViewController:civc];
  
  [self.topBar clickButton:0];
}

- (void) loadInClanConfiguration {
  [self.topBar button:2 shouldBeHidden:NO];
  [self.topBar button:3 shouldBeHidden:YES];
}

- (void) loadNotInClanConfiguration {
  [self.topBar button:2 shouldBeHidden:YES];
  [self.topBar button:3 shouldBeHidden:NO];
}

- (void) button1Clicked:(id)sender {
  [self replaceRootWithViewController:self.clanBrowseViewController];
  
  [self.topBar clickButton:1];
}

- (void) button2Clicked:(id)sender {
  [self replaceRootWithViewController:self.clanInfoViewController];
  
  [self.topBar clickButton:2];
}

- (void) button3Clicked:(id)sender {
  [self replaceRootWithViewController:self.clanCreateViewController];
  
  [self.topBar clickButton:3];
}
- (void) keyboardWillShow:(id)n {
  _isEditing = YES;
}

- (void) keyboardWillHide:(id)n {
  _isEditing = NO;
}

- (void) backClicked:(id)sender {
  if (_isEditing) {
    [self.view endEditing:YES];
  } else {
    [super backClicked:sender];
  }
}

- (void) closeClicked:(id)sender {
  if (_isEditing) {
    [self.view endEditing:YES];
  } else {
    [super closeClicked:sender];
  }
}

- (void) close {
  [super close];
  [self.delegate clanViewControllerDidClose:self];
}

#pragma mark - Response handlers

- (void) handleClanEventCreateClanResponseProto:(CreateClanResponseProto *)proto {
  if (proto.status == CreateClanResponseProto_CreateClanStatusSuccess) {
    [self updateConfiguration];
    [self button2Clicked:nil];
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
