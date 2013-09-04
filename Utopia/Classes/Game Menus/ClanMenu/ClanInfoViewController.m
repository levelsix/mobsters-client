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

@implementation ClanMemberCell

- (void) awakeFromNib {
  CGRect r = self.editMemberView.frame;
  self.editMemberView.frame = r;
  
  r = self.respondInviteView.frame;
  self.respondInviteView.frame = r;
}

- (void) loadForUser:(MinimumUserProtoForClans *)mup isLeader:(BOOL)isLeader {
  MinimumUserProtoWithLevel *mupl = mup.minUserProto.minUserProtoWithLevel;
  self.user = mup;
  
  self.nameLabel.text = mupl.minUserProto.name;
  self.typeLabel.text = isLeader ? @"Clan Leader" : mup.clanStatus == UserClanStatusMember ? @"Clan Member" : @"Requestee";
  self.userIcon.image = [Globals squareImageForUser:mupl.minUserProto.userType];
}

- (void) editMemberConfiguration {
  self.editMemberView.hidden = NO;
  self.respondInviteView.hidden = YES;
}

- (void) respondInviteConfiguration {
  self.editMemberView.hidden = YES;
  self.respondInviteView.hidden = NO;
}

- (void) emptyConfiguration {
  self.editMemberView.hidden = YES;
  self.respondInviteView.hidden = YES;
}

- (void) dealloc {
  self.user = nil;
  [super dealloc];
}

@end

@implementation ClanInfoCell

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

- (void) loadForClan:(FullClanProtoWithClanSize *)c {
  if (c) {
    GameState *gs = [GameState sharedGameState];
    int maxForTier = [gs clanTierForLevel:c.clan.currentTierLevel].maxSize;
    
    self.nameLabel.text = c.clan.name;
    self.membersLabel.text = [NSString stringWithFormat:@"%d/%d", c.clanSize, maxForTier];
    self.descriptionView.text = c.clan.description;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:c.clan.createTime/1000.0];
    self.foundedLabel.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];
    [dateFormatter release];
    
    if (c.clan.requestToJoinRequired) {
      self.typeLabel.text = @"By Request Only";
    } else {
      self.typeLabel.text = @"Anyone Can Join";
    }
    
    [self hideAllViews];
    if (gs.clan.clanId == c.clan.clanId) {
      if (gs.userId == c.clan.owner.userId) {
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

- (void) dealloc {
  self.requestView = nil;
  self.cancelView = nil;
  self.leaveView = nil;
  self.joinView = nil;
  self.leaderView = nil;
  self.anotherClanView = nil;
  [super dealloc];
}

@end

@implementation ClanInfoViewController

- (id) initWithClan:(FullClanProtoWithClanSize *)clan {
  if ((self = [super initWithNibName:nil bundle:nil])) {
    self.clan = clan;
    self.title = clan.clan.name;
    
    [[OutgoingEventController sharedOutgoingEventController] retrieveClanInfo:nil clanId:clan.clan.clanId grabType:RetrieveClanInfoRequestProto_ClanInfoGrabTypeMembers isForBrowsingList:NO beforeClanId:0 delegate:self];
  }
  return self;
}

- (void) loadForMyClan {
  GameState *gs = [GameState sharedGameState];
  
  self.clan = nil;
  self.members = nil;
  self.requesters = nil;
  [[OutgoingEventController sharedOutgoingEventController] retrieveClanInfo:nil clanId:gs.clan.clanId grabType:RetrieveClanInfoRequestProto_ClanInfoGrabTypeAll isForBrowsingList:NO beforeClanId:0 delegate:self];
  [self.infoTable reloadData];
}

- (void) viewDidLoad {
  [self setUpCloseButton];
  [self setUpImageBackButton];
  
  [self.infoTable addSubview:self.loadingMembersView];
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 3;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    return 1;
  } else if (section == 2){
    int count = self.members.count;
    self.loadingMembersView.hidden = count > 0;
    return count;
  }
  return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    ClanInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClanInfoCell"];
    
    if (!cell) {
      [[NSBundle mainBundle] loadNibNamed:@"ClanInfoCell" owner:self options:nil];
      cell = self.infoCell;
    }
    
    [cell loadForClan:self.clan];
    return cell;
  } else if (indexPath.section == 2) {
    ClanMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClanMemberCell"];
    
    if (!cell) {
      [[NSBundle mainBundle] loadNibNamed:@"ClanMemberCell" owner:self options:nil];
      cell = self.memberCell;
    }
    
    MinimumUserProtoForClans *user = [self.members objectAtIndex:indexPath.row];
    BOOL isLeader = user.minUserProto.minUserProtoWithLevel.minUserProto.userId == self.clan.clan.owner.userId;
    [cell loadForUser:user isLeader:isLeader];
    return cell;
  }
  return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    return 94.f;
  } else {
    return 47.f;
  }
}

#pragma mark - IBActions for green buttons

- (IBAction)joinClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] requestJoinClan:self.clan.clan.clanId delegate:self];
}

- (IBAction)requestClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] requestJoinClan:self.clan.clan.clanId delegate:self];
}

- (IBAction)leaveClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  if (self.clan.clanSize == 1 && gs.clan.ownerId == gs.userId) {
    [GenericPopupController displayConfirmationWithDescription:@"Are you sure you would like to delete this clan?" title:@"Delete?" okayButton:@"Delete" cancelButton:@"Cancel" target:self selector:@selector(leaveClan)];
  } else if (gs.clan.ownerId == gs.userId) {
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
  [self.navigationController pushViewController:[[[ClanCreateViewController alloc] initInEditModeForClan:self.clan] autorelease] animated:YES];
}

- (IBAction)cancelClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] retractRequestToJoinClan:self.clan.clan.clanId delegate:self];
}

#pragma mark - Response handlers

- (void) handleRetrieveClanInfoResponseProto:(FullEvent *)e {
  RetrieveClanInfoResponseProto *proto = (RetrieveClanInfoResponseProto *)e.event;
  
  if (!self.clan && proto.clanInfoList.count == 1) {
    self.clan = [proto.clanInfoList lastObject];
  }
  
  self.members = proto.membersList;
  [self.infoTable reloadData];
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

- (void) dealloc {
  self.clan = nil;
  self.members = nil;
  self.requesters = nil;
  [super dealloc];
}

@end
