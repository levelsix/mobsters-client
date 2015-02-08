//
//  RequestsFacebookTableController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/17/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "RequestsFacebookTableController.h"
#import "GameState.h"
#import "Globals.h"
#import "FacebookDelegate.h"
#import "OutgoingEventController.h"

@implementation RequestsFacebookCell

- (void) awakeFromNib {
//  UIImage *maskImage = [UIImage imageNamed:@"fullfriendmask.png"];
//  CALayer *mask = [CALayer layer];
//  mask.contents = (id)[maskImage CGImage];
//  mask.frame = CGRectMake(0, 0, self.pfPic.frame.size.width, self.pfPic.frame.size.height);
//  self.pfPic.layer.mask = mask;
  
  self.pfPic.layer.cornerRadius = self.pfPic.frame.size.width/2;
}

- (void) updateForRequest:(RequestFromFriend *)request andFbInfo:(NSDictionary *)fbInfo {
  if (request.type == RequestFromFriendInventorySlots) {
    GameState *gs = [GameState sharedGameState];
    NSString *position = @"";
    for (id<StaticStructure> ss in gs.staticStructs.allValues) {
      if (ss.structInfo.structType == StructureInfoProto_StructTypeResidence &&
          ss.structInfo.level == request.invite.structFbLvl) {
        ResidenceProto *rp = (ResidenceProto *)ss;
        position = [NSString stringWithFormat:@" hiring a %@", rp.occupationName];
      }
    }
    
    self.pfPic.profileID = request.invite.inviter.facebookId;
    NSString *name = fbInfo ? fbInfo[@"first_name"] : request.invite.inviter.minUserProto.name;
    self.titleLabel.text = [NSString stringWithFormat:@"%@ needs help%@!", name, position];
    self.subtitleLabel.text = [Globals stringForTimeSinceNow:[MSDate dateWithTimeIntervalSince1970:request.invite.timeOfInvite/1000.] shortened:YES];
  }
  
  self.request = request;
}

@end

@implementation RequestsFacebookTableController

- (void) becameDelegate:(UITableView *)requestsTable noRequestsLabel:(UILabel *)noRequestsLabel spinner:(UIActivityIndicatorView *)spinner {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadRequestsArray) name:NEW_FB_INVITE_NOTIFICATION object:nil];
  self.requestsTable = requestsTable;
  self.noRequestsLabel = noRequestsLabel;
  self.spinner = spinner;
  [self reloadRequestsArray];
  self.spinner.hidden = YES;
  
  self.acceptedRequestUuids = [NSMutableArray array];
  self.rejectedRequestUuids = [NSMutableArray array];
}

- (void) resignDelegate {
  [self sendInviteResponses];
  self.requestsTable = nil;
  self.noRequestsLabel = nil;
  self.spinner = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) reloadRequestsArray {
  GameState *gs = [GameState sharedGameState];
  self.requests = [NSMutableArray arrayWithArray:gs.fbUnacceptedRequestsFromFriends.allObjects];
  
  [self.requestsTable reloadData];
  
  if (self.requests.count > 0) {
    [self getFacebookInfo];
  }
}

- (void) getFacebookInfo {
  if (self.requests.count == 0) {
    return;
  }
  
  NSMutableArray *ids = [NSMutableArray array];
  for (RequestFromFriend *req in self.requests) {
    if (req.invite.inviter.facebookId.length > 0) {
      [ids addObject:req.invite.inviter.facebookId];
    }
  }
  
  [FacebookDelegate getFacebookUsersWithIds:ids handler:^(id result) {
    self.fbInfo = result;
    
    [self.requestsTable reloadData];
  }];
}

- (IBAction)acceptClicked:(id)sender {
  while (![sender isKindOfClass:[RequestsFacebookCell class]]) {
    sender = [sender superview];
  }
  RequestsFacebookCell *cell = (RequestsFacebookCell *)sender;
  [self.acceptedRequestUuids addObject:cell.request.invite.inviteUuid];
  
  [self removeRequestCell:cell];
}

- (IBAction)rejectClicked:(id)sender {
  while (![sender isKindOfClass:[RequestsFacebookCell class]]) {
    sender = [sender superview];
  }
  RequestsFacebookCell *cell = (RequestsFacebookCell *)sender;
  [self.rejectedRequestUuids addObject:cell.request.invite.inviteUuid];
  
  [self removeRequestCell:cell];
}

- (void) removeRequestCell:(RequestsFacebookCell *)cell {
  NSIndexPath *ip = [self.requestsTable indexPathForCell:cell];
  [self.requests removeObject:cell.request];
  [self.requestsTable deleteRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationTop];
  
  if (!self.requests.count) {
    [UIView animateWithDuration:0.3f animations:^{
      self.headerView.alpha = 0.f;
    }];
  }
  
  [self sendInviteResponses];
}

- (void) sendInviteResponses {
  [[OutgoingEventController sharedOutgoingEventController] acceptAndRejectInvitesWithAcceptUuids:self.acceptedRequestUuids rejectUuids:self.rejectedRequestUuids];
  
  [self.acceptedRequestUuids removeAllObjects];
  [self.rejectedRequestUuids removeAllObjects];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:FB_INVITE_RESPONDED_NOTIFICATION object:nil];
}

#pragma mark - UITableViewDelegate/DataSource methods

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if (self.requests.count > 0) {
    if (!self.headerView) {
      [[NSBundle mainBundle] loadNibNamed:@"RequestsFacebookHeader" owner:self options:nil];
    }
    self.headerView.alpha = 1.f;
    return self.headerView;
  }
  return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return self.requests.count ? tableView.sectionHeaderHeight :  0.f;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (self.requests.count == 0) {
    self.noRequestsLabel.text = @"You have no pending requests.";
    self.noRequestsLabel.hidden = NO;
  } else {
    self.noRequestsLabel.hidden = YES;
  }
  return self.requests.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 45.f;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  RequestsFacebookCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RequestsFacebookCell"];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"RequestsFacebookCell" owner:self options:nil];
    cell = self.requestCell;
  }
  
  RequestFromFriend *req = self.requests[indexPath.row];
  [cell updateForRequest:req andFbInfo:self.fbInfo[req.invite.inviter.facebookId]];
  
  return cell;
}

@end
