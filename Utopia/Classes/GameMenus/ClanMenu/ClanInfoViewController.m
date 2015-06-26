//
//  ClanInfoViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "ClanInfoViewController.h"
#import "Protocols.pb.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "GenericPopupController.h"
#import "ClanCreateViewController.h"
#import "ProfileViewController.h"
#import "GameViewController.h"

@implementation ClanInfoViewController

- (id) initWithClanUuid:(NSString *)clanUuid andName:(NSString *)name {
  if ((self = [super initWithNibName:nil bundle:nil])) {
    [[OutgoingEventController sharedOutgoingEventController] retrieveClanInfo:nil clanUuid:clanUuid grabType:RetrieveClanInfoRequestProto_ClanInfoGrabTypeAll isForBrowsingList:NO delegate:self];
    self.title = name ? name : @"Loading...";
  }
  return self;
}

- (id) initWithClan:(FullClanProtoWithClanSize *)clan {
  if ((self = [super initWithNibName:nil bundle:nil])) {
    self.clan = clan;
    self.title = clan.clan.name;
    
    [[OutgoingEventController sharedOutgoingEventController] retrieveClanInfo:nil clanUuid:clan.clan.clanUuid grabType:RetrieveClanInfoRequestProto_ClanInfoGrabTypeMembers isForBrowsingList:NO delegate:self];
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  [self loadInfoViewForClan:self.clan clanStatus:self.myUser.clanStatus];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [self.settingsView removeFromSuperview];
}

- (void) loadForMyClan {
  GameState *gs = [GameState sharedGameState];
  
  self.clan = nil;
  self.allMembers = nil;
  self.shownMembers = nil;
  self.requesters = nil;
  [[OutgoingEventController sharedOutgoingEventController] retrieveClanInfo:nil clanUuid:gs.clan.clanUuid grabType:RetrieveClanInfoRequestProto_ClanInfoGrabTypeAll isForBrowsingList:NO delegate:self];
  [self.infoTable reloadData];
  
  [self loadInfoViewForClan:nil clanStatus:0];
  
  self.title = gs.clan.name;
  
  _isMyClan = YES;
}

- (void) loadInfoViewForClan:(FullClanProtoWithClanSize *)c clanStatus:(UserClanStatus)clanStatus {
  [self.infoView loadForClan:c clanStatus:clanStatus];
  self.infoTable.tableHeaderView = self.infoView;
  [self.headerButtonsView.superview bringSubviewToFront:self.headerButtonsView];
}

#pragma mark - Sorting Members

- (void) setSortOrder:(ClanInfoSortOrder)sortOrder {
  _sortOrder = sortOrder;
  
  NSComparator comp = nil;
  
  NSComparator reqComp = ^NSComparisonResult(MinimumUserProtoForClans *m1, MinimumUserProtoForClans *m2) {
    if (m1.clanStatus != m2.clanStatus) {
      if (m1.clanStatus == UserClanStatusRequesting) {
        return NSOrderedAscending;
      } else if (m2.clanStatus == UserClanStatusRequesting) {
        return NSOrderedDescending;
      }
    }
    return NSOrderedSame;
  };
  
  NSComparator baseComp = ^NSComparisonResult(MinimumUserProtoForClans *m1, MinimumUserProtoForClans *m2) {
    return [@(m2.sender.strength) compare:@(m1.sender.strength)];
  };
  
  if (_sortOrder == ClanInfoSortOrderStrength) {
    comp = ^NSComparisonResult(MinimumUserProtoForClans *m1, MinimumUserProtoForClans *m2) {
      NSComparisonResult reqResult = reqComp(m1, m2);
      if (reqResult != NSOrderedSame) return reqResult;
      
      uint64_t strength1 = m1.sender.strength;
      uint64_t strength2 = m2.sender.strength;
      if (strength1 != strength2) {
        return [@(strength2) compare:@(strength1)];
      } else {
        return baseComp(m1, m2);
      }
    };
  } else if (_sortOrder == ClanInfoSortOrderMember) {
    comp = ^NSComparisonResult(MinimumUserProtoForClans *m1, MinimumUserProtoForClans *m2) {
      NSComparisonResult reqResult = reqComp(m1, m2);
      if (reqResult != NSOrderedSame) return reqResult;
      
      int status1 = m1.clanStatus;
      int status2 = m2.clanStatus;
      if (status1 != status2) {
        return [@(status1) compare:@(status2)];
      } else {
        return baseComp(m1, m2);
      }
    };
  } else if (_sortOrder == ClanInfoSortOrderTeam) {
    comp = ^NSComparisonResult(MinimumUserProtoForClans *m1, MinimumUserProtoForClans *m2) {
      NSComparisonResult reqResult = reqComp(m1, m2);
      if (reqResult != NSOrderedSame) return reqResult;
      
      NSArray *ums1 = self.curTeams[m1.sender.userUuid];
      NSArray *ums2 = self.curTeams[m2.sender.userUuid];
      
      Globals *gl = [Globals sharedGlobals];
      int str1 = 0, str2 = 0;
      for (UserMonster *um in ums1) {
        str1 += [gl calculateStrengthForMonster:um];
      }
      for (UserMonster *um in ums2) {
        str2 += [gl calculateStrengthForMonster:um];
      }
      
      if (str1 != str2) {
        return [@(str2) compare:@(str1)];
      } else {
        return baseComp(m1, m2);
      }
    };
  } else if (_sortOrder == ClanInfoSortOrderRaid) {
    comp = ^NSComparisonResult(MinimumUserProtoForClans *m1, MinimumUserProtoForClans *m2) {
      NSComparisonResult reqResult = reqComp(m1, m2);
      if (reqResult != NSOrderedSame) return reqResult;
      
      float raid1 = m1.raidContribution;
      float raid2 = m2.raidContribution;
      if (raid1 != raid2) {
        return [@(raid2) compare:@(raid1)];
      } else {
        return baseComp(m1, m2);
      }
    };
  } else if (_sortOrder == ClanInfoSortOrderBattleWins) {
    comp = ^NSComparisonResult(MinimumUserProtoForClans *m1, MinimumUserProtoForClans *m2) {
      NSComparisonResult reqResult = reqComp(m1, m2);
      if (reqResult != NSOrderedSame) return reqResult;
      
      int wins1 = m1.battlesWon;
      int wins2 = m2.battlesWon;
      if (wins1 != wins2) {
        return [@(wins2) compare:@(wins1)];
      } else {
        return baseComp(m1, m2);
      }
    };
  } else if (_sortOrder == ClanInfoSortOrderHelpsGiven) {
    comp = ^NSComparisonResult(MinimumUserProtoForClans *m1, MinimumUserProtoForClans *m2) {
      NSComparisonResult reqResult = reqComp(m1, m2);
      if (reqResult != NSOrderedSame) return reqResult;
      
      int status1 = m1.numClanHelpsGiven;
      int status2 = m2.numClanHelpsGiven;
      if (status1 != status2) {
        return [@(status2) compare:@(status1)];
      } else {
        return baseComp(m1, m2);
      }
    };
  }
  
  if (comp) {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(MinimumUserProtoForClans *evaluatedObject, NSDictionary *bindings) {
      if (evaluatedObject.clanStatus == UserClanStatusRequesting) {
        if (!(self.myUser.clanStatus == UserClanStatusLeader || self.myUser.clanStatus == UserClanStatusJuniorLeader)) {
          return NO;
        }
      }
      return YES;
    }];
    NSArray *filtered = [self.allMembers filteredArrayUsingPredicate:predicate];
    self.shownMembers = [filtered sortedArrayUsingComparator:comp];
  }
}

- (void) setNewSortOrder:(ClanInfoSortOrder)order animated:(BOOL)animated {
  [self setNewSortOrder:order newArray:self.allMembers animated:animated];
}

- (void) setNewSortOrder:(ClanInfoSortOrder)order newArray:(NSArray *)arr animated:(BOOL)animated {
  NSArray *before = self.shownMembers;
  self.allMembers = arr;
  self.sortOrder = order;
  NSArray *after = self.shownMembers;
  
  if (animated) {
    [self.infoTable beginUpdates];
    for (int i = 0; i < before.count; i++) {
      id object = [before objectAtIndex:i];
      NSInteger newIndex = [after indexOfObject:object];
      if (newIndex != NSNotFound) {
        [self.infoTable moveRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] toIndexPath:[NSIndexPath indexPathForRow:newIndex inSection:0]];
      } else {
        [self.infoTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
      }
    }
    
    for (int i = 0; i < after.count; i++) {
      id object = [after objectAtIndex:i];
      if (![before containsObject:object]) {
        [self.infoTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
      }
    }
    [self.infoTable endUpdates];
    
    for (ClanMemberCell *cell in self.infoTable.visibleCells) {
      [self setDataForCellAtIndexPath:[self.infoTable indexPathForCell:cell] cell:cell];
    }
  } else {
    [self.infoTable reloadData];
  }
  
  if (_sortOrder) {
    UIButton *newHeader = (UIButton *)[self.headerButtonsView viewWithTag:_sortOrder];
    [_clickedHeaderButton setTitleColor:[UIColor colorWithWhite:0.f alpha:0.6f] forState:UIControlStateNormal];
    [newHeader setTitleColor:[UIColor colorWithWhite:51/255.f alpha:1.f] forState:UIControlStateNormal];
    _clickedHeaderButton = newHeader;
  }
}

#pragma mark - Settings View

- (void) openSettingsView:(ClanMemberCell *)cell {
  [self closeSettingsView:^{
    // Do this so adjusting the frame won't get glitchy
    self.settingsView.transform = CGAffineTransformIdentity;
    
    // Update labels
    BOOL shouldDisplay = [self updateSettingsLabelsForClanStatus:cell.user.clanStatus myStatus:self.myUser.clanStatus];
    
    if (shouldDisplay) {
      // Add a button over the entire view to dismiss view
      CGRect visibleRect;
      visibleRect.origin = self.infoTable.contentOffset;
      visibleRect.size = self.infoTable.contentSize;
      UIButton *button = [[UIButton alloc] initWithFrame:visibleRect];
      [self.infoTable addSubview:button];
      [button addTarget:self action:@selector(closeSettingsView) forControlEvents:UIControlEventTouchDown];
      button.tag = 123;
      
      [self.infoTable addSubview:self.settingsView];
      CGPoint finalCenter = [self.settingsView.superview convertPoint:cell.center fromView:cell.superview];
      
      self.settingsView.center = ccpAdd(finalCenter, ccp(self.view.frame.size.width, 0));
      [UIView animateWithDuration:0.3f animations:^{
        self.settingsView.center = finalCenter;
      }];
      
      _curClickedCell = cell;
    }
  }];
}

- (void) closeSettingsView:(void (^)(void))completion {
  if (self.settingsView.superview) {
    float dur = completion ? 0.1f : 0.3f;
    [UIView animateWithDuration:dur animations:^{
      self.settingsView.center = ccpAdd(self.settingsView.center, ccp(self.view.frame.size.width, 0));
    } completion:^(BOOL finished) {
      _curClickedCell = nil;
      [self.settingsView removeFromSuperview];
      [[self.infoTable viewWithTag:123] removeFromSuperview];
      if (completion) {
        completion();
      }
    }];
  } else {
    if (completion) {
      completion();
    }
  }
}

- (void) closeSettingsView {
  [self closeSettingsView:nil];
}

- (void) closeSettingsAndReorderWithArray:(NSArray *)arr {
  [self closeSettingsView:^{
    [self setNewSortOrder:self.sortOrder newArray:arr animated:YES];
  }];
  [self loadInfoViewForClan:self.clan clanStatus:self.myUser.clanStatus];
}

- (BOOL) updateSettingsLabelsForClanStatus:(UserClanStatus)cs myStatus:(UserClanStatus)myStatus {
  int numOptions = 0;
  
  if (cs != UserClanStatusRequesting) {
    if (myStatus == UserClanStatusLeader) {
      numOptions = 4;
      
      [self.settingsButtons[0] updateForSetting:ClanSettingTransferLeader];
      [self.settingsButtons[3] updateForSetting:ClanSettingBoot];
      
      if (cs == UserClanStatusJuniorLeader) {
        [self.settingsButtons[1] updateForSetting:ClanSettingDemoteToCaptain];
        [self.settingsButtons[2] updateForSetting:ClanSettingDemoteToMember];
      } else if (cs == UserClanStatusCaptain) {
        [self.settingsButtons[1] updateForSetting:ClanSettingPromoteToJrLeader];
        [self.settingsButtons[2] updateForSetting:ClanSettingDemoteToMember];
      } else if (cs == UserClanStatusMember) {
        [self.settingsButtons[1] updateForSetting:ClanSettingPromoteToJrLeader];
        [self.settingsButtons[2] updateForSetting:ClanSettingPromoteToCaptain];
      }
    } else if (myStatus == UserClanStatusJuniorLeader) {
      numOptions = 2;
      
      [self.settingsButtons[3] updateForSetting:ClanSettingBoot];
      
      if (cs == UserClanStatusCaptain) {
        [self.settingsButtons[2] updateForSetting:ClanSettingDemoteToMember];
      } else if (cs == UserClanStatusMember) {
        [self.settingsButtons[2] updateForSetting:ClanSettingPromoteToCaptain];
      }
    }
  } else {
    if (myStatus == UserClanStatusLeader || myStatus == UserClanStatusJuniorLeader) {
      numOptions = 2;
      [self.settingsButtons[2] updateForSetting:ClanSettingAcceptMember];
      [self.settingsButtons[3] updateForSetting:ClanSettingRejectMember];
    }
  }
  
  if (self.settingsView.subviews.count) {
    UIView *sv = self.settingsView.subviews[0];
    if (sv.subviews.count) {
      UIView *ssv = sv.subviews[0];
      UIView *leftButton = self.settingsButtons[4-numOptions];
      
      CGRect r = ssv.frame;
      r.origin.x = -leftButton.frame.origin.x;
      ssv.frame = r;
      
      r = sv.frame;
      r.size.width = ssv.frame.size.width+ssv.frame.origin.x;
      sv.frame = r;
      sv.center = ccp(self.settingsView.frame.size.width/2, sv.center.y);
    }
  }
  
  return numOptions > 0;
}

- (void) stopAllClanSettingsSpinners {
  for (ClanInfoSettingsButtonView *button in self.settingsButtons) {
    [button stopSpinning];
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self closeSettingsView:nil];
}

#pragma mark - UITableView delegate/dataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  if (self.clan) {
    return self.headerButtonsView.frame.size.height;
  }
  return 0.f;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  return self.headerButtonsView;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger count = self.shownMembers.count;
  if (count == 0) {
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
    if (self.clan) {
      self.spinner.center = ccp(self.view.frame.size.width/2, self.view.frame.size.height-(self.view.frame.size.height-self.infoView.frame.size.height-self.headerButtonsView.frame.size.height)/2);
    } else {
      self.spinner.center = ccp(self.view.frame.size.width/2, self.view.frame.size.height/2);
    }
  } else {
    self.spinner.hidden = YES;
  }
  return count;
}

- (void) setDataForCellAtIndexPath:(NSIndexPath *)indexPath cell:(ClanMemberCell *)cell {
  MinimumUserProtoForClans *user = [self.shownMembers objectAtIndex:indexPath.row];
  NSString *userUuid = user.sender.userUuid;
  [cell loadForUser:user currentTeam:self.curTeams[userUuid] myStatus:self.myUser.clanStatus];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ClanMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClanMemberCell"];
  
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed:@"ClanMemberCell" owner:self options:nil];
    cell = self.memberCell;
  }
  
  [self setDataForCellAtIndexPath:indexPath cell:cell];
  
  return cell;
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  [self closeSettingsView:nil];
}

#pragma mark - Settings delegate

- (void) settingClicked:(ClanInfoSettingsButtonView *)button {
  if (!_waitingForResponse) {
    ClanSetting setting = button.setting;
    NSString *userUuid = _curClickedCell.user.sender.userUuid;
    BOOL confirming = NO;
    if (setting == ClanSettingAcceptMember) {
      [[OutgoingEventController sharedOutgoingEventController] approveOrRejectRequestToJoinClan:userUuid accept:YES delegate:self];
    } else if (setting == ClanSettingBoot) {
      NSString *desc = [NSString stringWithFormat:@"Are you sure you would like to boot %@?", _curClickedCell.user.sender.name];
      [GenericPopupController displayNegativeConfirmationWithDescription:desc title:@"Boot Member?" okayButton:@"Boot" cancelButton:@"Cancel"  okTarget:self okSelector:@selector(sendBoot) cancelTarget:nil cancelSelector:nil];
      confirming = YES;
    } else if (setting == ClanSettingDemoteToCaptain) {
      [[OutgoingEventController sharedOutgoingEventController] promoteOrDemoteMember:userUuid newStatus:UserClanStatusCaptain delegate:self];
    } else if (setting == ClanSettingDemoteToMember) {
      [[OutgoingEventController sharedOutgoingEventController] promoteOrDemoteMember:userUuid newStatus:UserClanStatusMember delegate:self];
    } else if (setting == ClanSettingPromoteToCaptain) {
      [[OutgoingEventController sharedOutgoingEventController] promoteOrDemoteMember:userUuid newStatus:UserClanStatusCaptain delegate:self];
    } else if (setting == ClanSettingPromoteToJrLeader) {
      [[OutgoingEventController sharedOutgoingEventController] promoteOrDemoteMember:userUuid newStatus:UserClanStatusJuniorLeader delegate:self];
    } else if (setting == ClanSettingRejectMember) {
      [[OutgoingEventController sharedOutgoingEventController] approveOrRejectRequestToJoinClan:userUuid accept:NO delegate:self];
    } else if (setting == ClanSettingTransferLeader) {
      NSString *desc = [NSString stringWithFormat:@"Are you sure you would like to transfer leadership to %@?", _curClickedCell.user.sender.name];
      [GenericPopupController displayNegativeConfirmationWithDescription:desc title:@"Transfer Leadership?" okayButton:@"Transfer" cancelButton:@"Cancel" okTarget:self okSelector:@selector(sendTransferClanOwnership) cancelTarget:nil cancelSelector:nil];
      confirming = YES;
    }
    
    if (confirming) {
      _clickedSettingsButton = button;
    } else {
      _waitingForResponse = YES;
      [button beginSpinning];
    }
  } else {
    [Globals addAlertNotification:@"Hold on! We are still processing your previous request."];
  }
}

- (void) sendBoot {
  NSString *userUuid = _curClickedCell.user.sender.userUuid;
  [[OutgoingEventController sharedOutgoingEventController] bootPlayerFromClan:userUuid delegate:self];
  _waitingForResponse = YES;
  [_clickedSettingsButton beginSpinning];
  _clickedSettingsButton = nil;
}

- (void) sendTransferClanOwnership {
  NSString *userUuid = _curClickedCell.user.sender.userUuid;
  [[OutgoingEventController sharedOutgoingEventController] transferClanOwnership:userUuid delegate:self];
  _waitingForResponse = YES;
  [_clickedSettingsButton beginSpinning];
  _clickedSettingsButton = nil;
}

#pragma mark - IBActions for green buttons

- (IBAction)joinClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] requestJoinClan:self.clan.clan.clanUuid delegate:self];
  [self.infoView beginSpinners];
  _waitingForResponse = YES;
}

- (IBAction)requestClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] requestJoinClan:self.clan.clan.clanUuid delegate:self];
  [self.infoView beginSpinners];
  _waitingForResponse = YES;
}

- (IBAction)leaveClicked:(id)sender {
  if (self.clan.clanSize == 1) {
    [GenericPopupController displayConfirmationWithDescription:@"Are you sure you would like to delete this squad?" title:@"Delete?" okayButton:@"Delete" cancelButton:@"Cancel" target:self selector:@selector(leaveClan)];
  } else if (self.myUser.clanStatus == UserClanStatusLeader) {
    [Globals popupMessage:@"You must transfer ownership before leaving this squad."];
  } else {
    [GenericPopupController displayConfirmationWithDescription:@"Are you sure you would like to leave this squad?" title:@"Leave?" okayButton:@"Leave" cancelButton:@"Cancel" target:self selector:@selector(leaveClan)];
  }
}

- (void) leaveClan {
  [[OutgoingEventController sharedOutgoingEventController] leaveClanWithDelegate:self];
  [self.infoView beginSpinners];
  _waitingForResponse = YES;
}

- (IBAction)editClicked:(id)sender {
  [self.parentViewController pushViewController:[[ClanCreateViewController alloc] initInEditModeForClan:self.clan] animated:YES];
}

- (IBAction)cancelClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] retractRequestToJoinClan:self.clan.clan.clanUuid delegate:self];
  [self.infoView beginSpinners];
  _waitingForResponse = YES;
}

- (IBAction)settingsClicked:(id)sender {
  sender = [sender getAncestorInViewHierarchyOfType:[ClanMemberCell class]];
  
  if (sender) {
    ClanMemberCell *cell = (ClanMemberCell *)sender;
    if (!self.settingsView.superview || cell != _curClickedCell) {
      [self openSettingsView:cell];
    }
  }
}

- (IBAction)profileClicked:(id)sender {
  sender = [sender getAncestorInViewHierarchyOfType:[ClanMemberCell class]];
  
  if (sender) {
    ClanMemberCell *cell = (ClanMemberCell *)sender;
    ProfileViewController *mpvc = [[ProfileViewController alloc] initWithUserUuid:cell.user.sender.userUuid];
    UIViewController *parent = [GameViewController baseController];
    mpvc.view.frame = parent.view.bounds;
    [parent.view addSubview:mpvc.view];
    [parent addChildViewController:mpvc];
  }
}

- (IBAction)sortClicked:(UIButton *)sender {
  if (sender.tag) {
    [self setNewSortOrder:(int)sender.tag animated:YES];
  }
}

#pragma mark - Clan events

- (NSArray *) userAdded:(MinimumUserProtoForClans *)user members:(NSArray *)members {
  if (user.clanStatus != UserClanStatusRequesting) {
    if (self.clan) {
      FullClanProtoWithClanSize_Builder *clanBldr = [FullClanProtoWithClanSize builderWithPrototype:self.clan];
      clanBldr.clanSize++;
      self.clan = clanBldr.build;
    }
  }
  
  return [members arrayByAddingObject:user];
}

- (NSArray *) userRemoved:(NSString *)userUuid members:(NSArray *)members {
  NSMutableArray *arr = members.mutableCopy;
  for (int i = 0; i < arr.count; i++) {
    MinimumUserProtoForClans *mup = members[i];
    if ([mup.sender.userUuid isEqualToString:userUuid]) {
      [arr removeObjectAtIndex:i];
      
      if (mup.clanStatus != UserClanStatusRequesting) {
        FullClanProtoWithClanSize_Builder *clanBldr = [FullClanProtoWithClanSize builderWithPrototype:self.clan];
        clanBldr.clanSize--;
        self.clan = clanBldr.build;
      }
    }
  }
  return arr;
}

- (NSArray *) userStatusChanged:(NSString *)userUuid newStatus:(UserClanStatus)status members:(NSArray *)members {
  NSMutableArray *arr = members.mutableCopy;
  for (int i = 0; i < arr.count; i++) {
    MinimumUserProtoForClans *mup = members[i];
    if ([mup.sender.userUuid isEqualToString:userUuid]) {
      MinimumUserProtoForClans *newMup = [[[MinimumUserProtoForClans builderWithPrototype:mup] setClanStatus:status] build];
      [arr replaceObjectAtIndex:i withObject:newMup];
      
      GameState *gs = [GameState sharedGameState];
      if ([userUuid isEqualToString:gs.userUuid]) {
        self.myUser = newMup;
      }
      
      if (mup.clanStatus == UserClanStatusRequesting && status != UserClanStatusRequesting) {
        FullClanProtoWithClanSize_Builder *clanBldr = [FullClanProtoWithClanSize builderWithPrototype:self.clan];
        clanBldr.clanSize++;
        self.clan = clanBldr.build;
      }
    }
  }
  return arr;
}

#pragma mark - Response handlers

- (void) handleRetrieveClanInfoResponseProto:(FullEvent *)e {
  RetrieveClanInfoResponseProto *proto = (RetrieveClanInfoResponseProto *)e.event;
  
  if (proto.clanInfoList.count == 1) {
    self.clan = [proto.clanInfoList lastObject];
  }
  
  self.title = self.clan.clan.name;
  
  self.allMembers = proto.membersList;
  self.curTeams = [[Globals convertUserTeamArrayToDictionary:proto.monsterTeamsList] mutableCopy];
  
  // Get current user's user clan status
  self.myUser = nil;
  if (_isMyClan) {
    GameState *gs = [GameState sharedGameState];
    for (MinimumUserProtoForClans *mup in self.allMembers) {
      if ([mup.sender.userUuid isEqualToString:gs.userUuid]) {
        self.myUser = mup;
      }
    }
  }
  
  [self setNewSortOrder:ClanInfoSortOrderMember animated:YES];
  [self loadInfoViewForClan:self.clan clanStatus:self.myUser.clanStatus];
}

#pragma mark Self Actions

- (void) handleRequestJoinClanResponseProto:(FullEvent *)e {
  RequestJoinClanResponseProto *proto = (RequestJoinClanResponseProto *)e.event;
  if (proto.status == ResponseStatusSuccessJoin ||
      proto.status == ResponseStatusSuccessRequest) {
    [Analytics joinSquad:proto.minClan.name isRequestType:proto.minClan.requestToJoinRequired];
  }
  
  [self loadInfoViewForClan:self.clan clanStatus:self.myUser.clanStatus];
  [self.infoView stopAllSpinners];
  _waitingForResponse = NO;
}

- (void) handleRetractRequestJoinClanResponseProto:(FullEvent *)e {
  [self loadInfoViewForClan:self.clan clanStatus:self.myUser.clanStatus];
  [self.infoView stopAllSpinners];
  _waitingForResponse = NO;
}

- (void) handleLeaveClanResponseProto:(FullEvent *)e {
  [self loadInfoViewForClan:self.clan clanStatus:self.myUser.clanStatus];
  [self.infoView stopAllSpinners];
  _waitingForResponse = NO;
}

#pragma mark Other Member Actions

- (void) handleApproveOrRejectRequestToJoinClanResponseProto:(FullEvent *)e {
  [self stopAllClanSettingsSpinners];
  _waitingForResponse = NO;
}

- (void) handlePromoteDemoteClanMemberResponseProto:(FullEvent *)e {
  [self stopAllClanSettingsSpinners];
  _waitingForResponse = NO;
}

- (void) handleBootPlayerFromClanResponseProto:(FullEvent *)e {
  [self stopAllClanSettingsSpinners];
  _waitingForResponse = NO;
}

- (void) handleTransferClanOwnershipResponseProto:(FullEvent *)e {
  [self stopAllClanSettingsSpinners];
  _waitingForResponse = NO;
}

#pragma mark Clan Event handlers

- (void) handleClanEventLeaveClanResponseProto:(LeaveClanResponseProto *)proto {
  if (proto.status == ResponseStatusSuccess) {
    NSArray *arr = [self userRemoved:proto.sender.userUuid members:self.allMembers];
    [self closeSettingsAndReorderWithArray:arr];
  }
}

- (void) handleClanEventBootPlayerFromClanResponseProto:(BootPlayerFromClanResponseProto *)proto {
  if (proto.status == ResponseStatusSuccess) {
    NSArray *arr = [self userRemoved:proto.playerToBoot.userUuid members:self.allMembers];
    [self closeSettingsAndReorderWithArray:arr];
  }
}

- (void) handleClanEventTransferClanOwnershipResponseProto:(TransferClanOwnershipResponseProto *)proto {
  if (proto.status == ResponseStatusSuccess) {
    NSArray *arr = [self userStatusChanged:proto.sender.userUuid newStatus:UserClanStatusJuniorLeader members:self.allMembers];
    arr = [self userStatusChanged:proto.clanOwnerNew.userUuid newStatus:UserClanStatusLeader members:arr];
    [self closeSettingsAndReorderWithArray:arr];
  }
}

- (void) handleClanEventPromoteDemoteClanMemberResponseProto:(PromoteDemoteClanMemberResponseProto *)proto {
  if (proto.status == ResponseStatusSuccess) {
    NSArray *arr = [self userStatusChanged:proto.victim.userUuid newStatus:proto.userClanStatus members:self.allMembers];
    [self closeSettingsAndReorderWithArray:arr];
  }
}

- (void) handleClanEventRequestJoinClanResponseProto:(RequestJoinClanResponseProto *)proto {
  if (proto.status == ResponseStatusSuccessJoin || proto.status == ResponseStatusSuccessRequest) {
    [self.curTeams setObject:[Globals convertCurrentTeamToArray:proto.requesterMonsters] forKey:proto.requesterMonsters.userUuid];
    NSArray *arr = [self userAdded:proto.requester members:self.allMembers];
    [self closeSettingsAndReorderWithArray:arr];
  }
}

- (void) handleClanEventChangeClanSettingsResponseProto:(ChangeClanSettingsResponseProto *)proto {
  if (proto.status == ResponseStatusSuccess) {
    self.clan = proto.fullClan;
    [self loadInfoViewForClan:self.clan clanStatus:self.myUser.clanStatus];
  }
}

- (void) handleClanEventApproveOrRejectRequestToJoinClanResponseProto:(ApproveOrRejectRequestToJoinClanResponseProto *)proto {
  if (proto.status == ResponseStatusSuccess) {
    NSArray *arr = nil;
    if (proto.accept) {
      arr = [self userStatusChanged:proto.requester.userUuid newStatus:UserClanStatusMember members:self.allMembers];
    } else {
      arr = [self userRemoved:proto.requester.userUuid members:self.allMembers];
    }
    [self closeSettingsAndReorderWithArray:arr];
  }
}

- (void) handleClanEventRetractRequestJoinClanResponseProto:(RetractRequestJoinClanResponseProto *)proto {
  if (proto.status == ResponseStatusSuccess) {
    NSArray *arr = [self userRemoved:proto.sender.userUuid members:self.allMembers];
    [self closeSettingsAndReorderWithArray:arr];
  }
}

@end
