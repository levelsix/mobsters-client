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

@implementation MinimumUserProtoForClans (EqualityCheck)

- (BOOL) isEqual:(MinimumUserProtoForClans *)object {
  if (![object isKindOfClass:[self class]]) {
    return NO;
  }
  
  return object.minUserProto.minUserProtoWithLevel.minUserProto.userId == self.minUserProto.minUserProtoWithLevel.minUserProto.userId;
}

@end

@implementation ClanTeamMonsterView

- (void) awakeFromNib {
  self.layer.cornerRadius = 4.f;
}

- (void) updateForMonsterId:(int)monsterId {
  if (monsterId) {
    GameState *gs = [GameState sharedGameState];
    MonsterProto *mp = [gs monsterWithId:monsterId];
    NSString *file = [mp.imagePrefix stringByAppendingString:@"Thumbnail.png"];
    [Globals imageNamed:file withView:self.monsterIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    file = [Globals imageNameForElement:mp.monsterElement suffix:@"mteam.png"];
    [Globals imageNamed:file withView:self.bgdIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  } else {
    self.bgdIcon.image = [Globals imageNamed:@"teamempty.png"];
    self.monsterIcon.image = nil;
  }
}

@end

@implementation ClanMemberCell

- (void) awakeFromNib {
  CGRect r = self.editMemberView.frame;
  self.editMemberView.frame = r;
  
  for (ClanTeamMonsterView *mv in self.monsterViews) {
    mv.transform = CGAffineTransformMakeScale(0.8, 0.8);
  }
}

- (void) loadForUser:(MinimumUserProtoForClans *)mup currentTeam:(NSArray *)currentTeam myStatus:(UserClanStatus)myStatus {
  MinimumUserProtoWithLevel *mupl = mup.minUserProto.minUserProtoWithLevel;
  self.user = mup;
  
  self.nameLabel.text = mupl.minUserProto.name;
  self.raidContributionLabel.text = [NSString stringWithFormat:@"%d%%", (int)roundf(mup.raidContribution*100.f)];
  self.battleWinsLabel.text = [NSString stringWithFormat:@"%@ Win%@", [Globals commafyNumber:mup.minUserProto.battlesWon], mup.minUserProto.battlesWon == 1 ? @"" : @"s"];
  
  self.typeLabel.text = [Globals stringForClanStatus:mup.clanStatus];
  self.typeLabel.highlighted = (mup.clanStatus == UserClanStatusRequesting);
  self.levelLabel.text = [Globals commafyNumber:mupl.level];
  
  for (int i = 0; i < self.monsterViews.count; i++) {
    ClanTeamMonsterView *mv = self.monsterViews[i];
    UserMonster *um = i < currentTeam.count ? currentTeam[i] : nil;
    
    [mv updateForMonsterId:um.monsterId];
  }
  
  if (myStatus == UserClanStatusLeader) {
    if (mup.clanStatus != UserClanStatusLeader) {
      [self editMemberConfiguration];
    } else {
      [self regularConfiguration];
    }
  } else if (myStatus == UserClanStatusJuniorLeader) {
    if (mup.clanStatus != UserClanStatusLeader && mup.clanStatus != UserClanStatusJuniorLeader) {
      [self editMemberConfiguration];
    } else {
      [self regularConfiguration];
    }
  } else {
    [self regularConfiguration];
  }
}

- (void) editMemberConfiguration {
  self.editMemberView.hidden = NO;
  self.profileView.hidden = YES;
}

- (void) respondInviteConfiguration {
  self.editMemberView.hidden = YES;
  self.profileView.hidden = YES;
}

- (void) regularConfiguration {
  self.editMemberView.hidden = YES;
  self.profileView.hidden = NO;
}

@end

@implementation ClanInfoView

- (void) awakeFromNib {
  UITextView *text = self.descriptionView;
  text.layer.shadowColor = [[UIColor colorWithWhite:0.f alpha:0.3f] CGColor];
  text.layer.shadowOffset = CGSizeMake(0.f, 1.0f);
  text.layer.shadowOpacity = 1.0f;
  text.layer.shadowRadius = 1.0f;
  
  self.requestView.frame = self.leaderView.frame;
  [self.leaderView.superview addSubview:self.requestView];
  
  self.cancelView.frame = self.leaderView.frame;
  [self.leaderView.superview addSubview:self.cancelView];
  
  self.leaveView.frame = self.leaderView.frame;
  [self.leaderView.superview addSubview:self.leaveView];
  
  self.joinView.frame = self.leaderView.frame;
  [self.leaderView.superview addSubview:self.joinView];
  
  self.anotherClanView.frame = self.leaderView.frame;
  [self.leaderView.superview addSubview:self.anotherClanView];
}

- (void) hideAllViews {
  self.requestView.hidden = YES;
  self.cancelView.hidden = YES;
  self.leaveView.hidden = YES;
  self.joinView.hidden = YES;
  self.leaderView.hidden = YES;
  self.anotherClanView.hidden = YES;
}

- (void) loadForClan:(FullClanProtoWithClanSize *)c clanStatus:(UserClanStatus)clanStatus {
  if (c) {
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    
    self.nameLabel.text = c.clan.name;
    self.membersLabel.text = [NSString stringWithFormat:@"Members: %d/%d", c.clanSize, gl.maxClanSize];
    self.descriptionView.text = c.clan.description;
    
    ClanIconProto *icon = [gs clanIconWithId:c.clan.clanIconId];
    [Globals imageNamed:icon.imgName withView:self.iconImage greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    MSDate *date = [MSDate dateWithTimeIntervalSince1970:c.clan.createTime/1000.0];
    self.foundedLabel.text = [NSString stringWithFormat:@"Founded: %@", [dateFormatter stringFromDate:date.relativeNSDate]];
    
    if (c.clan.requestToJoinRequired) {
      self.typeLabel.text = @"By Request Only";
    } else {
      self.typeLabel.text = @"Anyone Can Join";
    }
    
    [self hideAllViews];
    if (gs.clan.clanId == c.clan.clanId) {
      if (clanStatus == UserClanStatusLeader || clanStatus == UserClanStatusJuniorLeader) {
        self.leaderView.hidden = NO;
      } else if (clanStatus) {
        // Only show if clan status is there, aka this is the editable screen
        self.leaveView.hidden = NO;
      }
    } else if (gs.clan) {
      self.anotherClanView.hidden = NO;
    } else {
      if ([gs.requestedClans containsObject:[NSNumber numberWithInt:c.clan.clanId]]) {
        self.cancelView.hidden = NO;
      } else {
        if (c.clan.requestToJoinRequired) {
          self.requestView.hidden = NO;
        } else {
          self.joinView.hidden = NO;
        }
      }
    }
  } else {
    self.nameLabel.text = @"Loading...";
    self.membersLabel.text = nil;
    self.typeLabel.text = nil;
    self.foundedLabel.text = nil;
    self.descriptionView.text = nil;
    self.iconImage.image = nil;
    [self hideAllViews];
  }
}

@end

@implementation ClanInfoSettingsButtonView

- (void) updateForSetting:(ClanSetting)setting {
  self.setting = setting;
  
  NSString *topText = nil;
  NSString *botText = nil;
  switch (setting) {
    case ClanSettingBoot:
      topText = @"Boot From";
      botText = @"Clan";
      break;
    case ClanSettingDemoteToCaptain:
      topText = @"Demote To";
      botText = @"Captain";
      break;
    case ClanSettingDemoteToMember:
      topText = @"Demote To";
      botText = @"Member";
      break;
    case ClanSettingPromoteToCaptain:
      topText = @"Promote To";
      botText = @"Captain";
      break;
    case ClanSettingPromoteToJrLeader:
      topText = @"Promote To";
      botText = @"Jr. Leader";
      break;
    case ClanSettingTransferLeader:
      topText = @"Transfer";
      botText = @"Leadership";
      break;
    case ClanSettingAcceptMember:
      topText = @"Accept";
      botText = @"Requestee";
      break;
    case ClanSettingRejectMember:
      topText = @"Reject";
      botText = @"Requestee";
      break;
      
    default:
      break;
  }
  self.topLabel.text = topText;
  self.botLabel.text = botText;
  
  [self stopSpinning];
}

- (IBAction) buttonClicked:(id)sender {
  [self.delegate settingClicked:self];
}

- (void) beginSpinning {
  self.topLabel.hidden = YES;
  self.botLabel.hidden = YES;
  self.spinner.hidden = NO;
}

- (void) stopSpinning {
  self.topLabel.hidden = NO;
  self.botLabel.hidden = NO;
  self.spinner.hidden = YES;
}

@end

@implementation ClanInfoViewController

- (id) initWithClanId:(int)clanId andName:(NSString *)name {
  if ((self = [super initWithNibName:nil bundle:nil])) {
    [[OutgoingEventController sharedOutgoingEventController] retrieveClanInfo:nil clanId:clanId grabType:RetrieveClanInfoRequestProto_ClanInfoGrabTypeAll isForBrowsingList:NO beforeClanId:0 delegate:self];
    self.title = name ? name : @"Loading...";
  }
  return self;
}

- (id) initWithClan:(FullClanProtoWithClanSize *)clan {
  if ((self = [super initWithNibName:nil bundle:nil])) {
    self.clan = clan;
    self.title = clan.clan.name;
    
    [[OutgoingEventController sharedOutgoingEventController] retrieveClanInfo:nil clanId:clan.clan.clanId grabType:RetrieveClanInfoRequestProto_ClanInfoGrabTypeMembers isForBrowsingList:NO beforeClanId:0 delegate:self];
  }
  return self;
}

- (void) viewDidLoad {
  [self setUpCloseButton];
  [self setUpImageBackButton];
  
  [self.infoTable addSubview:self.loadingMembersView];
  [self.infoView loadForClan:self.clan clanStatus:0];
  
  self.settingsView.layer.anchorPoint = ccp(1, 0.5);
}

- (void) viewWillDisappear:(BOOL)animated {
  [self.settingsView removeFromSuperview];
}

- (void) willMoveToParentViewController:(UIViewController *)parent {
  if (!parent) {
    [[OutgoingEventController sharedOutgoingEventController] unregisterClanEventDelegate:self];
  }
}

- (void) loadForMyClan {
  GameState *gs = [GameState sharedGameState];
  
  self.clan = nil;
  self.allMembers = nil;
  self.shownMembers = nil;
  self.requesters = nil;
  [[OutgoingEventController sharedOutgoingEventController] retrieveClanInfo:nil clanId:gs.clan.clanId grabType:RetrieveClanInfoRequestProto_ClanInfoGrabTypeAll isForBrowsingList:NO beforeClanId:0 delegate:self];
  [self.infoTable reloadData];
  
  [self.infoView loadForClan:nil clanStatus:0];
  
  self.title = gs.clan.name;
  
  [[OutgoingEventController sharedOutgoingEventController] registerClanEventDelegate:self];
  _isMyClan = YES;
}

- (void) setSortOrder:(ClanInfoSortOrder)sortOrder {
  if (_sortOrder) [(UIButton *)[self.headerButtonsView viewWithTag:_sortOrder] setSelected:NO];
  if (sortOrder) [(UIButton *)[self.headerButtonsView viewWithTag:sortOrder] setSelected:YES];
  
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
    return [@(m1.minUserProto.minUserProtoWithLevel.minUserProto.userId) compare:@(m2.minUserProto.minUserProtoWithLevel.minUserProto.userId)];
  };
  
  if (_sortOrder == ClanInfoSortOrderLevel) {
    comp = ^NSComparisonResult(MinimumUserProtoForClans *m1, MinimumUserProtoForClans *m2) {
      NSComparisonResult reqResult = reqComp(m1, m2);
      if (reqResult != NSOrderedSame) return reqResult;
      
      int level1 = m1.minUserProto.minUserProtoWithLevel.level;
      int level2 = m2.minUserProto.minUserProtoWithLevel.level;
      if (level1 != level2) {
        return [@(level2) compare:@(level1)];
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
      
      NSArray *ums1 = self.curTeams[@(m1.minUserProto.minUserProtoWithLevel.minUserProto.userId)];
      NSArray *ums2 = self.curTeams[@(m2.minUserProto.minUserProtoWithLevel.minUserProto.userId)];
      
      Globals *gl = [Globals sharedGlobals];
      int str1 = 0, str2 = 0;
      for (UserMonster *um in ums1) {
        str1 += [gl calculateMaxHealthForMonster:um];
      }
      for (UserMonster *um in ums2) {
        str2 += [gl calculateMaxHealthForMonster:um];
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
      
      int wins1 = m1.minUserProto.battlesWon;
      int wins2 = m2.minUserProto.battlesWon;
      if (wins1 != wins2) {
        return [@(wins2) compare:@(wins1)];
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
}

- (void) openSettingsView:(ClanMemberCell *)cell {
  [self closeSettingsView:^{
    // Do this so adjusting the frame won't get glitchy
    self.settingsView.transform = CGAffineTransformIdentity;
    
    // Update labels
    BOOL shouldDisplay = [self updateSettingsLabelsForClanStatus:cell.user.clanStatus myStatus:self.myUser.clanStatus];
    
    if (shouldDisplay) {
      [self.infoTable addSubview:self.settingsView];
      self.settingsView.center = [self.settingsView.superview convertPoint:ccp(cell.editMemberView.frame.origin.x, cell.editMemberView.center.y) fromView:cell.editMemberView.superview];
      
      float minY = self.settingsView.frame.origin.y-3;
      float maxY = self.settingsView.frame.origin.y+self.settingsView.frame.size.height+3;
      if (maxY > self.infoTable.contentOffset.y+self.infoTable.frame.size.height) {
        [self.infoTable setContentOffset:ccp(0, maxY-self.infoTable.frame.size.height) animated:YES];
      } else if (minY < self.infoTable.contentOffset.y) {
        [self.infoTable setContentOffset:ccp(0, minY) animated:YES];
      }
      
      self.settingsView.transform = CGAffineTransformMakeScale(0.f, 0.f);
      [UIView animateWithDuration:0.2f animations:^{
        self.settingsView.transform = CGAffineTransformIdentity;
      }];
      
      for (int i = 0; i < self.settingsButtons.count; i++) {
        UIView *v = self.settingsButtons[i];
        v.transform = CGAffineTransformMakeScale(0.f, 0.f);
        [UIView animateWithDuration:0.2f delay:i*0.1f+0.1f options:UIViewAnimationOptionCurveEaseInOut animations:^{
          v.transform = CGAffineTransformIdentity;
        } completion:nil];
      }
      
      _curClickedCell = cell;
    }
  }];
}

- (void) closeSettingsView:(void (^)(void))completion {
  if (self.settingsView.superview) {
    [UIView animateWithDuration:0.1f animations:^{
      self.settingsView.transform = CGAffineTransformMakeScale(0.f, 0.f);
    } completion:^(BOOL finished) {
      _curClickedCell = nil;
      [self.settingsView removeFromSuperview];
      if (completion) {
        completion();
      }
    }];
    
    float maxY = MAX(0, self.infoTable.contentSize.height-self.infoTable.frame.size.height);
    if (self.infoTable.contentOffset.y > maxY) {
      [self.infoTable setContentOffset:ccp(0, maxY) animated:YES];
    }
  } else {
    if (completion) {
      completion();
    }
  }
}

- (void) closeSettingsAndReorderWithArray:(NSArray *)arr {
  [self closeSettingsView:^{
    [self setNewSortOrder:self.sortOrder newArray:arr animated:YES];
  }];
  [self.infoView loadForClan:self.clan clanStatus:self.myUser.clanStatus];
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
      
      [self.settingsButtons[1] updateForSetting:ClanSettingBoot];
      
      if (cs == UserClanStatusCaptain) {
        [self.settingsButtons[0] updateForSetting:ClanSettingDemoteToMember];
      } else if (cs == UserClanStatusMember) {
        [self.settingsButtons[0] updateForSetting:ClanSettingPromoteToCaptain];
      }
    }
  } else {
    if (myStatus == UserClanStatusLeader || myStatus == UserClanStatusJuniorLeader) {
      numOptions = 2;
      [self.settingsButtons[0] updateForSetting:ClanSettingAcceptMember];
      [self.settingsButtons[1] updateForSetting:ClanSettingRejectMember];
    }
  }
  
  self.settingsBgdImage.image = [Globals imageNamed:[NSString stringWithFormat:@"%doptions.png", numOptions]];
  
  CGRect r = self.settingsView.frame;
  r.size = self.settingsBgdImage.image.size;
  self.settingsView.frame = r;
  
  float height = ((UIView *)self.settingsButtons[0]).frame.size.height;
  float space = (r.size.height-numOptions*height)/(numOptions+1);
  for (int i = 0; i < self.settingsButtons.count; i++) {
    UIView *v = self.settingsButtons[i];
    v.center = ccp(v.center.x, space*(i+1)+height*(i+0.5));
    
    v.hidden = i >= numOptions;
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

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger count = self.shownMembers.count;
  self.loadingMembersView.hidden = count > 0;
  return count;
}

- (void) setDataForCellAtIndexPath:(NSIndexPath *)indexPath cell:(ClanMemberCell *)cell {
  MinimumUserProtoForClans *user = [self.shownMembers objectAtIndex:indexPath.row];
  int userId = user.minUserProto.minUserProtoWithLevel.minUserProto.userId;
  [cell loadForUser:user currentTeam:self.curTeams[@(userId)] myStatus:self.myUser.clanStatus];
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
    int userId = _curClickedCell.user.minUserProto.minUserProtoWithLevel.minUserProto.userId;
    BOOL confirming = NO;
    if (setting == ClanSettingAcceptMember) {
      [[OutgoingEventController sharedOutgoingEventController] approveOrRejectRequestToJoinClan:userId accept:YES delegate:self];
    } else if (setting == ClanSettingBoot) {
      NSString *desc = [NSString stringWithFormat:@"Are you sure you would like to boot %@?", _curClickedCell.user.minUserProto.minUserProtoWithLevel.minUserProto.name];
      [GenericPopupController displayNegativeConfirmationWithDescription:desc title:@"Boot Member?" okayButton:@"Boot" cancelButton:@"Cancel"  okTarget:self okSelector:@selector(sendBoot) cancelTarget:nil cancelSelector:nil];
      confirming = YES;
    } else if (setting == ClanSettingDemoteToCaptain) {
      [[OutgoingEventController sharedOutgoingEventController] promoteOrDemoteMember:userId newStatus:UserClanStatusCaptain delegate:self];
    } else if (setting == ClanSettingDemoteToMember) {
      [[OutgoingEventController sharedOutgoingEventController] promoteOrDemoteMember:userId newStatus:UserClanStatusMember delegate:self];
    } else if (setting == ClanSettingPromoteToCaptain) {
      [[OutgoingEventController sharedOutgoingEventController] promoteOrDemoteMember:userId newStatus:UserClanStatusCaptain delegate:self];
    } else if (setting == ClanSettingPromoteToJrLeader) {
      [[OutgoingEventController sharedOutgoingEventController] promoteOrDemoteMember:userId newStatus:UserClanStatusJuniorLeader delegate:self];
    } else if (setting == ClanSettingRejectMember) {
      [[OutgoingEventController sharedOutgoingEventController] approveOrRejectRequestToJoinClan:userId accept:NO delegate:self];
    } else if (setting == ClanSettingTransferLeader) {
      NSString *desc = [NSString stringWithFormat:@"Are you sure you would like to transfer leadership to %@?", _curClickedCell.user.minUserProto.minUserProtoWithLevel.minUserProto.name];
      [GenericPopupController displayNegativeConfirmationWithDescription:desc title:@"Transfer Leadership?" okayButton:@"Transfer" cancelButton:@"Cancel" okTarget:self okSelector:@selector(sendTransferClanOwnership) cancelTarget:nil cancelSelector:nil];
      confirming = YES;
    }
    
    if (confirming) {
      _clickedButton = button;
    } else {
      _waitingForResponse = YES;
      [button beginSpinning];
    }
  } else {
    [Globals addAlertNotification:@"Hold on! We are still processing your previous request."];
  }
}

- (void) sendBoot {
  int userId = _curClickedCell.user.minUserProto.minUserProtoWithLevel.minUserProto.userId;
  [[OutgoingEventController sharedOutgoingEventController] bootPlayerFromClan:userId delegate:self];
  _waitingForResponse = YES;
  [_clickedButton beginSpinning];
  _clickedButton = nil;
}

- (void) sendTransferClanOwnership {
  int userId = _curClickedCell.user.minUserProto.minUserProtoWithLevel.minUserProto.userId;
  [[OutgoingEventController sharedOutgoingEventController] transferClanOwnership:userId delegate:self];
  _waitingForResponse = YES;
  [_clickedButton beginSpinning];
  _clickedButton = nil;
}

#pragma mark - IBActions for green buttons

- (IBAction)joinClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] requestJoinClan:self.clan.clan.clanId delegate:self];
}

- (IBAction)requestClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] requestJoinClan:self.clan.clan.clanId delegate:self];
}

- (IBAction)leaveClicked:(id)sender {
  if (self.clan.clanSize == 1) {
    [GenericPopupController displayConfirmationWithDescription:@"Are you sure you would like to delete this clan?" title:@"Delete?" okayButton:@"Delete" cancelButton:@"Cancel" target:self selector:@selector(leaveClan)];
  } else if (self.myUser.clanStatus == UserClanStatusLeader) {
    [Globals popupMessage:@"You must transfer ownership before leaving this clan."];
  } else {
    [GenericPopupController displayConfirmationWithDescription:@"Are you sure you would like to leave this clan?" title:@"Leave?" okayButton:@"Leave" cancelButton:@"Cancel" target:self selector:@selector(leaveClan)];
  }
}

- (void) leaveClan {
  [[OutgoingEventController sharedOutgoingEventController] leaveClanWithDelegate:self];
}

- (IBAction)editClicked:(id)sender {
  [self.navigationController pushViewController:[[ClanCreateViewController alloc] initInEditModeForClan:self.clan] animated:YES];
}

- (IBAction)cancelClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] retractRequestToJoinClan:self.clan.clan.clanId delegate:self];
}

- (IBAction)settingsClicked:(id)sender {
  while (sender && ![sender isKindOfClass:[ClanMemberCell class]]) {
    sender = [sender superview];
  }
  
  if (sender) {
    ClanMemberCell *cell = (ClanMemberCell *)sender;
    if (!self.settingsView.superview || cell != _curClickedCell) {
      [self openSettingsView:cell];
    }
  }
}

- (IBAction)profileClicked:(id)sender {
  while (sender && ![sender isKindOfClass:[ClanMemberCell class]]) {
    sender = [sender superview];
  }
  
  if (sender) {
    ClanMemberCell *cell = (ClanMemberCell *)sender;
    
    ProfileViewController *mpvc = [[ProfileViewController alloc] initWithUserId:cell.user.minUserProto.minUserProtoWithLevel.minUserProto.userId];
    UIViewController *parent = self.navigationController;
    mpvc.view.frame = parent.view.bounds;
    [parent.view addSubview:mpvc.view];
    [parent addChildViewController:mpvc];
  }
}

- (IBAction)sortClicked:(UIView *)sender {
  if (sender.tag) {
    [self setNewSortOrder:(int)sender.tag animated:YES];
  }
}

#pragma mark - Clan events

- (NSArray *) userAdded:(MinimumUserProtoForClans *)user members:(NSArray *)members {
  if (user.clanStatus != UserClanStatusRequesting) {
    FullClanProtoWithClanSize_Builder *clanBldr = [FullClanProtoWithClanSize builderWithPrototype:self.clan];
    clanBldr.clanSize++;
    self.clan = clanBldr.build;
  }
  
  return [members arrayByAddingObject:user];
}

- (NSArray *) userRemoved:(int)userId members:(NSArray *)members {
  NSMutableArray *arr = members.mutableCopy;
  for (int i = 0; i < arr.count; i++) {
    MinimumUserProtoForClans *mup = members[i];
    if (mup.minUserProto.minUserProtoWithLevel.minUserProto.userId == userId) {
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

- (NSArray *) userStatusChanged:(int)userId newStatus:(UserClanStatus)status members:(NSArray *)members {
  NSMutableArray *arr = members.mutableCopy;
  for (int i = 0; i < arr.count; i++) {
    MinimumUserProtoForClans *mup = members[i];
    if (mup.minUserProto.minUserProtoWithLevel.minUserProto.userId == userId) {
      MinimumUserProtoForClans *newMup = [[[MinimumUserProtoForClans builderWithPrototype:mup] setClanStatus:status] build];
      [arr replaceObjectAtIndex:i withObject:newMup];
      
      GameState *gs = [GameState sharedGameState];
      if (userId == gs.userId) {
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
      if (mup.minUserProto.minUserProtoWithLevel.minUserProto.userId == gs.userId) {
        self.myUser = mup;
      }
    }
  }
  
  [self setNewSortOrder:ClanInfoSortOrderMember animated:YES];
  [self.infoView loadForClan:self.clan clanStatus:self.myUser.clanStatus];
}

- (void) handleRequestJoinClanResponseProto:(FullEvent *)e {
  [self.infoView loadForClan:self.clan clanStatus:self.myUser.clanStatus];
}

- (void) handleRetractRequestJoinClanResponseProto:(FullEvent *)e {
  [self.infoView loadForClan:self.clan clanStatus:self.myUser.clanStatus];
}

- (void) handleLeaveClanResponseProto:(FullEvent *)e {
  [self.infoView loadForClan:self.clan clanStatus:self.myUser.clanStatus];
}

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
  if (proto.status == LeaveClanResponseProto_LeaveClanStatusSuccess) {
    NSArray *arr = [self userRemoved:proto.sender.userId members:self.allMembers];
    [self closeSettingsAndReorderWithArray:arr];
    
    if (self.clan.clanSize == 0 && [self.parentViewController isKindOfClass:[UINavigationController class]]) {
      [self menuCloseClicked:nil];
    }
  }
}

- (void) handleClanEventBootPlayerFromClanResponseProto:(BootPlayerFromClanResponseProto *)proto {
  if (proto.status == BootPlayerFromClanResponseProto_BootPlayerFromClanStatusSuccess) {
    NSArray *arr = [self userRemoved:proto.playerToBoot.userId members:self.allMembers];
    [self closeSettingsAndReorderWithArray:arr];
  }
}

- (void) handleClanEventTransferClanOwnershipResponseProto:(TransferClanOwnershipResponseProto *)proto {
  if (proto.status == TransferClanOwnershipResponseProto_TransferClanOwnershipStatusSuccess) {
    NSArray *arr = [self userStatusChanged:proto.sender.userId newStatus:UserClanStatusJuniorLeader members:self.allMembers];
    arr = [self userStatusChanged:proto.clanOwnerNew.userId newStatus:UserClanStatusLeader members:arr];
    [self closeSettingsAndReorderWithArray:arr];
  }
}

- (void) handleClanEventPromoteDemoteClanMemberResponseProto:(PromoteDemoteClanMemberResponseProto *)proto {
  if (proto.status == PromoteDemoteClanMemberResponseProto_PromoteDemoteClanMemberStatusSuccess) {
    NSArray *arr = [self userStatusChanged:proto.victim.userId newStatus:proto.userClanStatus members:self.allMembers];
    [self closeSettingsAndReorderWithArray:arr];
  }
}

- (void) handleClanEventRequestJoinClanResponseProto:(RequestJoinClanResponseProto *)proto {
  if (proto.status == RequestJoinClanResponseProto_RequestJoinClanStatusSuccessJoin || proto.status == RequestJoinClanResponseProto_RequestJoinClanStatusSuccessRequest) {
    [self.curTeams setObject:[Globals convertCurrentTeamToArray:proto.requesterMonsters] forKey:@(proto.requesterMonsters.userId)];
    NSArray *arr = [self userAdded:proto.requester members:self.allMembers];
    [self closeSettingsAndReorderWithArray:arr];
  }
}

- (void) handleClanEventChangeClanSettingsResponseProto:(ChangeClanSettingsResponseProto *)proto {
  if (proto.status == ChangeClanSettingsResponseProto_ChangeClanSettingsStatusSuccess) {
    self.clan = proto.fullClan;
    [self.infoView loadForClan:self.clan clanStatus:self.myUser.clanStatus];
  }
}

- (void) handleClanEventApproveOrRejectRequestToJoinClanResponseProto:(ApproveOrRejectRequestToJoinClanResponseProto *)proto {
  if (proto.status == ApproveOrRejectRequestToJoinClanResponseProto_ApproveOrRejectRequestToJoinClanStatusSuccess) {
    NSArray *arr = nil;
    if (proto.accept) {
      arr = [self userStatusChanged:proto.requester.userId newStatus:UserClanStatusMember members:self.allMembers];
    } else {
      arr = [self userRemoved:proto.requester.userId members:self.allMembers];
    }
    [self closeSettingsAndReorderWithArray:arr];
  }
}

- (void) handleClanEventRetractRequestJoinClanResponseProto:(RetractRequestJoinClanResponseProto *)proto {
  if (proto.status == RetractRequestJoinClanResponseProto_RetractRequestJoinClanStatusSuccess) {
    NSArray *arr = [self userRemoved:proto.sender.userId members:self.allMembers];
    [self closeSettingsAndReorderWithArray:arr];
  }
}

@end
