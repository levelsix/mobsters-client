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

@implementation RequestFacebookCell

- (void) awakeFromNib {
  UIImage *maskImage = [UIImage imageNamed:@"fullfriendmask.png"];
  CALayer *mask = [CALayer layer];
  mask.contents = (id)[maskImage CGImage];
  mask.frame = CGRectMake(0, 0, self.pfPic.frame.size.width, self.pfPic.frame.size.height);
  self.pfPic.layer.mask = mask;
}

- (void) updateForRequest:(RequestFromFriend *)request andFbInfo:(NSDictionary *)fbInfo {
  self.hidden = !fbInfo;
  if (request.type == RequestFromFriendInventorySlots) {
    self.pfPic.profileID = request.invite.inviter.facebookId;
    self.titleLabel.text = [NSString stringWithFormat:@"%@ needs your help!", fbInfo[@"first_name"]];
    self.subtitleLabel.text = [NSString stringWithFormat:@"Your friend %@ needs help unlocking more mobster slots", fbInfo[@"first_name"]];
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
  
  self.acceptedRequestIds = [NSMutableArray array];
  self.rejectedRequestIds = [NSMutableArray array];
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
  
  if (self.requests.count == 0) {
    self.noRequestsLabel.hidden = NO;
    self.spinner.hidden = YES;
  } else {
    [self getFacebookInfo];
    self.noRequestsLabel.hidden = YES;
    self.spinner.hidden = NO;
  }
}

- (void) getFacebookInfo {
  if (self.requests.count == 0) {
    return;
  }
  
  NSMutableArray *ids = [NSMutableArray array];
  for (RequestFromFriend *req in self.requests) {
    [ids addObject:req.invite.inviter.facebookId];
  }
  
  [FacebookDelegate getFacebookUsersWithIds:ids handler:^(id result) {
    self.fbInfo = result;
    
    [self.requestsTable reloadData];
    self.spinner.hidden = YES;
  }];
}

- (IBAction)acceptClicked:(id)sender {
  while (![sender isKindOfClass:[RequestFacebookCell class]]) {
    sender = [sender superview];
  }
  RequestFacebookCell *cell = (RequestFacebookCell *)sender;
  [self.acceptedRequestIds addObject:@(cell.request.invite.inviteId)];
  
  [self removeRequestCell:cell];
}

- (IBAction)rejectClicked:(id)sender {
  while (![sender isKindOfClass:[RequestFacebookCell class]]) {
    sender = [sender superview];
  }
  RequestFacebookCell *cell = (RequestFacebookCell *)sender;
  [self.rejectedRequestIds addObject:@(cell.request.invite.inviteId)];
  
  [self removeRequestCell:cell];
}

- (void) removeRequestCell:(RequestFacebookCell *)cell {
  NSIndexPath *ip = [self.requestsTable indexPathForCell:cell];
  [self.requests removeObject:cell.request];
  [self.requestsTable deleteRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationFade];
}

- (void) sendInviteResponses {
  [[OutgoingEventController sharedOutgoingEventController] acceptAndRejectInvitesWithAcceptIds:self.acceptedRequestIds rejectIds:self.rejectedRequestIds];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:FB_INVITE_RESPONDED_NOTIFICATION object:nil];
  [self reloadRequestsArray];
}

#pragma mark - UITableViewDelegate/DataSource methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.requests.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 60.f;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  RequestFacebookCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RequestFacebookCell"];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"RequestFacebookCell" owner:self options:nil];
    cell = self.requestCell;
  }
  
  RequestFromFriend *req = self.requests[indexPath.row];
  [cell updateForRequest:req andFbInfo:self.fbInfo[req.invite.inviter.facebookId]];
  
  return cell;
}

@end
