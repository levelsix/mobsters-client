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
#import "GameViewController.h"
#import "LNSynthesizeSingleton.h"
#import "OutgoingEventController.h"
#import "GenericPopupController.h"
#import "ClanBrowseViewController.h"
#import "ClanInfoViewController.h"
#import "ClanCreateViewController.h"
#import "ClanRaidListViewController.h"
#import "ClanHelpViewController.h"

@implementation ClanViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.clanBrowseViewController = [[ClanBrowseViewController alloc] init];
  self.clanInfoViewController = [[ClanInfoViewController alloc] init];
  self.clanCreateViewController = [[ClanCreateViewController alloc] init];
  self.clanRaidViewController = [[ClanRaidListViewController alloc] init];
  self.clanHelpViewController = [[ClanHelpViewController alloc] init];
  
  [[OutgoingEventController sharedOutgoingEventController] registerClanEventDelegate:self];
  [[OutgoingEventController sharedOutgoingEventController] registerClanEventDelegate:self.clanBrowseViewController];
  [[OutgoingEventController sharedOutgoingEventController] registerClanEventDelegate:self.clanInfoViewController];
  
  self.inClanTopBar.center = self.noClanTopBar.center;
  [self.noClanTopBar.superview addSubview:self.inClanTopBar];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self updateConfiguration];
  
  [self.clanBrowseViewController reload];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHelpBadge) name:CLAN_HELPS_CHANGED_NOTIFICATION object:nil];
  [self updateHelpBadge];
  
  if (self.helpBadge.badgeNum) {
    [self button2Clicked:_activeTopBar];
  } else {
    [self button1Clicked:_activeTopBar];
  }
  
  [[GameViewController baseController] clearTutorialArrows];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [[OutgoingEventController sharedOutgoingEventController] unregisterClanEventDelegate:self];
  [[OutgoingEventController sharedOutgoingEventController] unregisterClanEventDelegate:self.clanBrowseViewController];
  [[OutgoingEventController sharedOutgoingEventController] unregisterClanEventDelegate:self.clanInfoViewController];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
//  [[GameViewController baseController] showEarlyGameTutorialArrow];
}

- (void) updateHelpBadge {
  GameState *gs = [GameState sharedGameState];
  NSInteger numHelps = [gs.clanHelpUtil getAllHelpableClanHelps].count;
  self.helpBadge.badgeNum = numHelps;
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

- (void) loadForClanUuid:(NSString *)clanUuid {
  ClanInfoViewController *civc = [[ClanInfoViewController alloc] initWithClanUuid:clanUuid andName:nil];
  [self replaceRootWithViewController:civc];
  
  // Don't click any of the buttons
  [self.noClanTopBar clickButton:0];
  [self.inClanTopBar clickButton:0];
}

- (void) loadInClanConfiguration {
  self.noClanTopBar.hidden = YES;
  self.inClanTopBar.hidden = NO;
  _activeTopBar = self.inClanTopBar;
}

- (void) loadNotInClanConfiguration {
  self.noClanTopBar.hidden = NO;
  self.inClanTopBar.hidden = YES;
  _activeTopBar = self.noClanTopBar;
}

- (void) button1Clicked:(id)sender {
  if (sender == self.noClanTopBar) {
    [self replaceRootWithViewController:self.clanBrowseViewController];
  } else {
    [self replaceRootWithViewController:self.clanInfoViewController];
  }
  
  [sender clickButton:1];
}

- (void) button2Clicked:(id)sender {
  if (sender == self.noClanTopBar) {
    [self replaceRootWithViewController:self.clanCreateViewController];
  } else {
    [self replaceRootWithViewController:self.clanHelpViewController];
  }
  
  [sender clickButton:2];
}

- (void) button3Clicked:(id)sender {
  if (sender == self.noClanTopBar) {
  } else {
    [self replaceRootWithViewController:self.clanBrowseViewController];
  }
  
  [sender clickButton:3];
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
    [self button1Clicked:_activeTopBar];
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
  if ([proto.sender.userUuid isEqualToString:gs.userUuid] && proto.status == LeaveClanResponseProto_LeaveClanStatusSuccess) {
    [self updateConfiguration];
    [self button1Clicked:_activeTopBar];
  }
}

- (void) handleClanEventApproveOrRejectRequestToJoinClanResponseProto:(ApproveOrRejectRequestToJoinClanResponseProto *)proto {
  GameState *gs = [GameState sharedGameState];
  if ([proto.requester.userUuid isEqualToString:gs.userUuid] && proto.accept && proto.status == ApproveOrRejectRequestToJoinClanResponseProto_ApproveOrRejectRequestToJoinClanStatusSuccess) {
    [self updateConfiguration];
    [self button1Clicked:_activeTopBar];
  }
}

- (void) handleClanEventBootPlayerFromClanResponseProto:(BootPlayerFromClanResponseProto *)proto {
  GameState *gs = [GameState sharedGameState];
  if ([proto.playerToBoot.userUuid isEqualToString:gs.userUuid] && proto.status == BootPlayerFromClanResponseProto_BootPlayerFromClanStatusSuccess) {
    [self updateConfiguration];
    [self button1Clicked:_activeTopBar];
  }
}

- (void) handleClanEventRequestJoinClanResponseProto:(LeaveClanResponseProto *)proto {
  GameState *gs = [GameState sharedGameState];
  if ([proto.sender.userUuid isEqualToString:gs.userUuid] && proto.status == RequestJoinClanResponseProto_RequestJoinClanStatusSuccessJoin) {
    [self updateConfiguration];
    [self button1Clicked:_activeTopBar];
  }
}

- (void) handleRetrieveClanInfoResponseProto:(FullEvent *)fe {
  [self.clanInfoViewController handleRetrieveClanInfoResponseProto:fe];
  
  GameState *gs = [GameState sharedGameState];
  RetrieveClanInfoResponseProto *proto = (RetrieveClanInfoResponseProto *)fe.event;
  if (proto.clanInfoList.count == 1 && [((FullClanProtoWithClanSize *)proto.clanInfoList[0]).clan.clanUuid isEqualToString:gs.clan.clanUuid]) {
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
