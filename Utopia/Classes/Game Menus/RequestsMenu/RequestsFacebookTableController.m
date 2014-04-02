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
  UIImage *maskImage = [UIImage imageNamed:@"fullfriendmask.png"];
  CALayer *mask = [CALayer layer];
  mask.contents = (id)[maskImage CGImage];
  mask.frame = CGRectMake(0, 0, self.pfPic.frame.size.width, self.pfPic.frame.size.height);
  self.pfPic.layer.mask = mask;
}

- (void) updateForRequest:(RequestFromFriend *)request andFbInfo:(NSDictionary *)fbInfo {
  if (request.type == RequestFromFriendInventorySlots) {
    self.pfPic.profileID = request.invite.inviter.facebookId;
    NSString *name = fbInfo ? fbInfo[@"first_name"] : request.invite.inviter.minUserProto.name;
    self.titleLabel.text = [NSString stringWithFormat:@"%@ needs your help!", name];
    self.subtitleLabel.text = @"Be a helper at his residence.";
  }
  
  self.request = request;
}

@end

@implementation RequestsFacebookTableController

- (id) init {
  if ((self = [super init])) {
    [self reloadRequestsArray];
  }
  return self;
}

- (void) becameDelegate:(UITableView *)requestsTable noRequestsLabel:(UILabel *)noRequestsLabel spinner:(UIActivityIndicatorView *)spinner {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadRequestsArray) name:NEW_FB_INVITE_NOTIFICATION object:nil];
  self.requestsTable = requestsTable;
  self.noRequestsLabel = noRequestsLabel;
  self.spinner = spinner;
  [self reloadRequestsArray];
  self.spinner.hidden = YES;
  
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
  [self.acceptedRequestIds addObject:@(cell.request.invite.inviteId)];
  
  [self removeRequestCell:cell];
}

- (IBAction)rejectClicked:(id)sender {
  while (![sender isKindOfClass:[RequestsFacebookCell class]]) {
    sender = [sender superview];
  }
  RequestsFacebookCell *cell = (RequestsFacebookCell *)sender;
  [self.rejectedRequestIds addObject:@(cell.request.invite.inviteId)];
  
  [self removeRequestCell:cell];
}

- (void) removeRequestCell:(RequestsFacebookCell *)cell {
  NSIndexPath *ip = [self.requestsTable indexPathForCell:cell];
  [self.requests removeObject:cell.request];
  [self.requestsTable deleteRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationFade];
  
  [self sendInviteResponses];
}

- (void) sendInviteResponses {
  [[OutgoingEventController sharedOutgoingEventController] acceptAndRejectInvitesWithAcceptIds:self.acceptedRequestIds rejectIds:self.rejectedRequestIds];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:FB_INVITE_RESPONDED_NOTIFICATION object:nil];
  [self reloadRequestsArray];
}

#pragma mark - UITableViewDelegate/DataSource methods

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
  return 60.f;
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
