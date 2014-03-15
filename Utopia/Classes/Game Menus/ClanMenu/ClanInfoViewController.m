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
  
  r = self.respondInviteView.frame;
  self.respondInviteView.frame = r;
  
  for (ClanTeamMonsterView *mv in self.monsterViews) {
    mv.transform = CGAffineTransformMakeScale(0.8, 0.8);
  }
}

- (void) loadForUser:(MinimumUserProtoForClans *)mup currentTeam:(NSArray *)currentTeam myStatus:(UserClanStatus)myStatus {
  MinimumUserProtoWithLevel *mupl = mup.minUserProto.minUserProtoWithLevel;
  self.user = mup;
  
  self.nameLabel.text = mupl.minUserProto.name;
  self.raidContributionLabel.text = [NSString stringWithFormat:@"%d%%", (int)roundf(mup.raidContribution*100.f)];
  
  NSString *typeText = nil;
  switch (mup.clanStatus) {
    case UserClanStatusLeader:
      typeText = @"Clan Leader";
      break;
    case UserClanStatusJuniorLeader:
      typeText = @"Jr. Leader";
      break;
    case UserClanStatusCaptain:
      typeText = @"Clan Captain";
      break;
    case UserClanStatusMember:
      typeText = @"Clan Member";
      break;
    case UserClanStatusRequesting:
      typeText = @"Requestee";
      break;
  }
  self.typeLabel.text = typeText;
  self.levelLabel.text = [Globals commafyNumber:mupl.level];
  
  for (int i = 0; i < self.monsterViews.count && i < currentTeam.count; i++) {
    ClanTeamMonsterView *mv = self.monsterViews[i];
    UserMonster *um = currentTeam[i];
    
    [mv updateForMonsterId:um.monsterId];
  }
  
  if (myStatus == UserClanStatusLeader) {
    if (mup.clanStatus == UserClanStatusRequesting) {
      [self respondInviteConfiguration];
    } else if (mup.clanStatus != UserClanStatusLeader) {
      [self editMemberConfiguration];
    } else {
      [self regularConfiguration];
    }
  } else if (myStatus == UserClanStatusJuniorLeader) {
    if (mup.clanStatus == UserClanStatusRequesting) {
      [self respondInviteConfiguration];
    } else if (mup.clanStatus != UserClanStatusLeader && mup.clanStatus != UserClanStatusJuniorLeader) {
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
  self.respondInviteView.hidden = YES;
  self.profileView.hidden = YES;
}

- (void) respondInviteConfiguration {
  self.editMemberView.hidden = YES;
  self.respondInviteView.hidden = NO;
  self.profileView.hidden = YES;
}

- (void) regularConfiguration {
  self.editMemberView.hidden = YES;
  self.respondInviteView.hidden = YES;
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

- (void) loadForClan:(FullClanProtoWithClanSize *)c isLeader:(BOOL)isLeader {
  if (c) {
    GameState *gs = [GameState sharedGameState];
    
    self.nameLabel.text = c.clan.name;
    self.membersLabel.text = [NSString stringWithFormat:@"Members: %d/%d", c.clanSize, 5];
    self.descriptionView.text = c.clan.description;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:c.clan.createTime/1000.0];
    self.foundedLabel.text = [NSString stringWithFormat:@"Founded: %@", [dateFormatter stringFromDate:date]];
    
    if (c.clan.requestToJoinRequired) {
      self.typeLabel.text = @"By Request Only";
    } else {
      self.typeLabel.text = @"Anyone Can Join";
    }
    
    [self hideAllViews];
    if (gs.clan.clanId == c.clan.clanId) {
      if (isLeader) {
        self.leaderView.hidden = NO;
      } else {
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
    [self hideAllViews];
  }
}

- (void) setHighlighted:(BOOL)highlighted {
  [self.buttonOverlay setHighlighted:highlighted];
}

- (void) setSelected:(BOOL)selected {
  [self.buttonOverlay setSelected:selected];
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
      
    default:
      break;
  }
  self.topLabel.text = topText;
  self.botLabel.text = botText;
}

- (IBAction) buttonClicked:(id)sender {
  [self.delegate settingClicked:self.setting];
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
  [self.infoView loadForClan:self.clan isLeader:NO];
  
  self.settingsView.layer.anchorPoint = ccp(1, 0.5);
}

- (void) viewWillDisappear:(BOOL)animated {
  [self.settingsView removeFromSuperview];
}

- (void) loadForMyClan {
  GameState *gs = [GameState sharedGameState];
  
  self.clan = nil;
  self.members = nil;
  self.requesters = nil;
  [[OutgoingEventController sharedOutgoingEventController] retrieveClanInfo:nil clanId:gs.clan.clanId grabType:RetrieveClanInfoRequestProto_ClanInfoGrabTypeAll isForBrowsingList:NO beforeClanId:0 delegate:self.parentViewController];
  [self.infoTable reloadData];
  
  [self.infoView loadForClan:nil isLeader:NO];
}

- (void) setSortOrder:(ClanInfoSortOrder)sortOrder {
  _sortOrder = sortOrder;
  
  NSComparator comp = nil;
  
  NSComparator baseComp = ^NSComparisonResult(MinimumUserProtoForClans *m1, MinimumUserProtoForClans *m2) {
    return [@(m1.minUserProto.minUserProtoWithLevel.minUserProto.userId) compare:@(m2.minUserProto.minUserProtoWithLevel.minUserProto.userId)];
  };
  
  if (_sortOrder == ClanInfoSortOrderLevel) {
    comp = ^NSComparisonResult(MinimumUserProtoForClans *m1, MinimumUserProtoForClans *m2) {
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
      float raid1 = m1.raidContribution;
      float raid2 = m2.raidContribution;
      if (raid1 != raid2) {
        return [@(raid2) compare:@(raid1)];
      } else {
        return baseComp(m1, m2);
      }
    };
  }
  
  if (comp) {
    self.members = [self.members sortedArrayUsingComparator:comp];
  }
}

- (void) openSettingsView:(ClanMemberCell *)cell {
  [self closeSettingsView:^{
    // Do this so adjusting the frame won't get glitchy
    self.settingsView.transform = CGAffineTransformIdentity;
    
    // Update labels
    [self updateSettingsLabelsForClanStatus:cell.user.clanStatus myStatus:self.myUser.clanStatus];
    
    [self.infoTable addSubview:self.settingsView];
    self.settingsView.center = [self.settingsView.superview convertPoint:ccp(cell.editMemberView.frame.origin.x, cell.editMemberView.center.y) fromView:cell.editMemberView.superview];
    
    float maxY = self.settingsView.frame.origin.y+self.settingsView.frame.size.height+3;
    if (maxY > self.infoTable.contentOffset.y+self.infoTable.frame.size.height) {
      [self.infoTable setContentOffset:ccp(0, maxY-self.infoTable.frame.size.height) animated:YES];
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
    
    float maxY = self.infoTable.contentSize.height-self.infoTable.frame.size.height;
    if (self.infoTable.contentOffset.y > maxY) {
      [self.infoTable setContentOffset:ccp(0, maxY) animated:YES];
    }
  } else {
    if (completion) {
      completion();
    }
  }
}

- (void) updateSettingsLabelsForClanStatus:(UserClanStatus)cs myStatus:(UserClanStatus)myStatus {
  int numOptions = 0;
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
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self closeSettingsView:nil];
}

#pragma mark - UITableView delegate/dataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger count = self.members.count;
  self.loadingMembersView.hidden = count > 0;
  return count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ClanMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClanMemberCell"];
  
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed:@"ClanMemberCell" owner:self options:nil];
    cell = self.memberCell;
  }
  
  MinimumUserProtoForClans *user = [self.members objectAtIndex:indexPath.row];
  int userId = user.minUserProto.minUserProtoWithLevel.minUserProto.userId;
  [cell loadForUser:user currentTeam:self.curTeams[@(userId)] myStatus:self.myUser.clanStatus];
  return cell;
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  [self closeSettingsView:nil];
}

#pragma mark - Settings delegate

- (void) settingClicked:(ClanSetting)setting {
  NSLog(@"Setting %d.", setting);
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
  // If it has a nav controller, it should control so it can pop.
  // Otherwise, it's part of clan controller.
  id delegate = self.parentViewController == self.navigationController ? self : self.parentViewController;
  [[OutgoingEventController sharedOutgoingEventController] leaveClanWithDelegate:delegate];
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
    NSArray *before = self.members;
    self.sortOrder = (int)sender.tag;
    NSArray *after = self.members;
    
    [self.infoTable beginUpdates];
    for (int i = 0; i < before.count; i++) {
      id object = [before objectAtIndex:i];
      NSInteger newIndex = [after indexOfObject:object];
      [self.infoTable moveRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] toIndexPath:[NSIndexPath indexPathForRow:newIndex inSection:0]];
    }
    [self.infoTable endUpdates];
  }
}

#pragma mark - Response handlers

- (void) handleRetrieveClanInfoResponseProto:(FullEvent *)e {
  RetrieveClanInfoResponseProto *proto = (RetrieveClanInfoResponseProto *)e.event;
  
  if (proto.clanInfoList.count == 1) {
    self.clan = [proto.clanInfoList lastObject];
  }
  
  self.title = self.clan.clan.name;
  
  self.members = proto.membersList;
  self.sortOrder = ClanInfoSortOrderMember;
  self.curTeams = [Globals convertUserTeamArrayToDictionary:proto.monsterTeamsList];
  [self.infoTable reloadData];
  
  // Get current user's user clan status
  GameState *gs = [GameState sharedGameState];
  self.myUser = nil;
  for (MinimumUserProtoForClans *mup in self.members) {
    if (mup.minUserProto.minUserProtoWithLevel.minUserProto.userId == gs.userId) {
      self.myUser = mup;
    }
  }
  [self.infoView loadForClan:self.clan isLeader:(self.myUser.clanStatus == UserClanStatusLeader)];
}

- (void) handleRequestJoinClanResponseProto:(FullEvent *)e {
  [self.infoTable reloadData];
}

- (void) handleRetractRequestJoinClanResponseProto:(FullEvent *)e {
  [self.infoTable reloadData];
}

- (void) handleLeaveClanResponseProto:(FullEvent *)e {
  [self.navigationController popViewControllerAnimated:YES];
}

@end
