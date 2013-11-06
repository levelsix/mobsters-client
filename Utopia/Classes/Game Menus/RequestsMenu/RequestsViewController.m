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

@implementation RequestTableCell

- (void) awakeFromNib {
  UIImage *maskImage = [UIImage imageNamed:@"fullfriendmask.png"];
  CALayer *mask = [CALayer layer];
  mask.contents = (id)[maskImage CGImage];
  mask.frame = CGRectMake(0, 0, self.pfPic.frame.size.width, self.pfPic.frame.size.height);
  self.pfPic.layer.mask = mask;
}

- (void) updateForRequest:(RequestFromFriend *)request {
  if (request.type == RequestFromFriendInventorySlots) {
    self.pfPic.profileID = request.user.facebookId;
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

- (IBAction)unselectAllClicked:(id)sender {
  [self.unselectedRequests addObjectsFromArray:self.requests];
  [self.requestsTable reloadData];
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
  [cell updateForRequest:req];
  cell.checkmark.hidden = [self.unselectedRequests containsObject:req];
  
  return cell;
}

@end
