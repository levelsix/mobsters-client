//
//  RequestsViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/4/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "RequestsViewController.h"
#import "Globals.h"
#import "GameState.h"
#import "UserData.h"
#import "OutgoingEventController.h"

@implementation RequestTableCell

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

@implementation RequestsViewController

- (void) viewDidLoad {
  self.unselectButton.superview.layer.cornerRadius = 5.f;
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  self.unselectedRequests = [NSMutableSet set];
  [self reloadRequestsArray];
}

- (IBAction)closeClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

- (IBAction)acceptClicked:(id)sender {
  NSMutableArray *accept = [NSMutableArray array];
  NSMutableArray *reject = [NSMutableArray array];
  
  for (RequestFromFriend *req in self.requests) {
    if ([self.unselectedRequests containsObject:req]) {
      [reject addObject:[NSNumber numberWithInt:req.invite.inviteId]];
    } else {
      [accept addObject:[NSNumber numberWithInt:req.invite.inviteId]];
    }
  }
  
  [[OutgoingEventController sharedOutgoingEventController] acceptAndRejectInvitesWithAcceptIds:accept rejectIds:reject];
}

- (IBAction)unselectAllClicked:(id)sender {
  [self.unselectedRequests addObjectsFromArray:self.requests];
  
  for (RequestTableCell *cell in self.requestsTable.visibleCells) {
    cell.checkmark.hidden = YES;
  }
}

- (IBAction)rowClicked:(id)sender {
  while (![sender isKindOfClass:[RequestTableCell class]]) {
    sender = [sender superview];
  }
  RequestTableCell *cell = (RequestTableCell *)sender;
  
  if ([self.unselectedRequests containsObject:cell.request]) {
    [self.unselectedRequests removeObject:cell.request];
    cell.checkmark.hidden = YES;
  } else {
    [self.unselectedRequests addObject:cell.request];
    cell.checkmark.hidden = NO;
  }
}

- (void) reloadRequestsArray {
  GameState *gs = [GameState sharedGameState];
  self.requests = gs.requestsFromFriends.mutableCopy;
  
  [self.requestsTable reloadData];
  [self getFacebookInfo];
}

- (void) getFacebookInfo {
  if (self.requests.count == 0) {
    return;
  }
  
  FBRequestConnection *conn = [[FBRequestConnection alloc] init];
  
  NSMutableString *ids = [NSMutableString stringWithFormat:@"%@", [(RequestFromFriend *)self.requests[0] invite].inviter.facebookId];
  for (int i = 1; i < self.requests.count; i++) {
    RequestFromFriend *req = self.requests[i];
    [ids appendFormat:@",%@", req.invite.inviter.facebookId];
  }
  
  self.spinner.hidden = NO;
  NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:ids, @"ids", nil];
  FBRequest *req = [[FBRequest alloc] initWithSession:nil graphPath:@"" parameters:params HTTPMethod:nil];
  [conn addRequest:req completionHandler:^(FBRequestConnection *connection, NSDictionary *result, NSError *error) {
    self.fbInfo = result;
    
    [self.requestsTable reloadData];
    self.spinner.hidden = YES;
  }];
  [conn start];
}

#pragma mark - UITableViewDelegate/DataSource methods

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.requests.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  RequestTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RequestTableCell"];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"RequestTableCell" owner:self options:nil];
    cell = self.requestCell;
  }
  
  RequestFromFriend *req = self.requests[indexPath.row];
  [cell updateForRequest:req andFbInfo:self.fbInfo[req.invite.inviter.facebookId]];
  cell.checkmark.hidden = [self.unselectedRequests containsObject:req];
  
  return cell;
}

@end
