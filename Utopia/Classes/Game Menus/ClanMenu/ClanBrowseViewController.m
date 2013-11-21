//
//  ClanBrowseViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "ClanBrowseViewController.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "ClanInfoViewController.h"

#define REFRESH_ROWS 20

@implementation BrowseSearchCell

@synthesize textField;

- (IBAction)clearClicked:(id)sender {
  self.textField.text = nil;
  [self.textField becomeFirstResponder];
  [self.textField resignFirstResponder];
}

@end

@implementation BrowseClanCell

@synthesize clan, topLabel, membersLabel, typeLabel;

- (void) loadForClan:(FullClanProtoWithClanSize *)c {
  GameState *gs = [GameState sharedGameState];
  
  self.clan = c;
  self.topLabel.text = [NSString stringWithFormat:@"[%@] %@", c.clan.tag, c.clan.name];
  self.membersLabel.text = [NSString stringWithFormat:@"%d/%d", c.clanSize, 5];
  
  if (c.clan.requestToJoinRequired) {
    self.typeLabel.text = @"By Request Only";
    self.typeLabel.textColor = [Globals redColor];
    [self.redButton setImage:[Globals imageNamed:@"heal.png"] forState:UIControlStateNormal];
  } else {
    self.typeLabel.text = @"Anyone Can Join";
    self.typeLabel.textColor = [Globals greenColor];
    [self.redButton setImage:[Globals imageNamed:@"confirm.png"] forState:UIControlStateNormal];
  }
  
  if (!gs.clan) {
    self.buttonView.hidden = NO;
    if ([gs.requestedClans containsObject:c.clan.clanUuid]) {
      self.buttonLabel.text = @"CANCEL";
    } else {
      if (c.clan.requestToJoinRequired) {
        self.buttonLabel.text = @"REQUEST";
      } else {
        self.buttonLabel.text = @"JOIN";
      }
    }
    self.buttonView.hidden = NO;
  } else {
    self.buttonView.hidden = YES;
  }
}

@end

@implementation ClanBrowseViewController

@synthesize state;
@synthesize clanList;
@synthesize browseClansTable, spinner;
@synthesize clanCell, searchView;
@synthesize searchString;
@synthesize shouldReload;
@synthesize loadingCell;

- (void) viewDidLoad {
  self.clanList = [NSMutableArray array];
  
  self.browseClansTable.tableFooterView = [[UIView alloc] init];
  
  [self reload];
}

- (void) viewWillAppear:(BOOL)animated {
  [self.browseClansTable reloadData];
}

- (void) setState:(ClanBrowseState)s {
  state = s;
  [browseClansTable reloadData];
  [browseClansTable setContentOffset:ccp(0,0) animated:YES];
}

- (void) reload {
  [self.clanList removeAllObjects];
  [[OutgoingEventController sharedOutgoingEventController] retrieveClanInfo:nil clanUuid:nil grabType:RetrieveClanInfoRequestProto_ClanInfoGrabTypeClanInfo isForBrowsingList:YES delegate:self];
}

- (void) handleRetrieveClanInfoResponseProto:(FullEvent *)e {
  RetrieveClanInfoResponseProto *proto = (RetrieveClanInfoResponseProto *)e.event;
  
  if ((proto.isForSearch && proto.hasClanName && [proto.clanName isEqualToString:self.searchString]) || !proto.isForSearch) {
    [self loadClans:proto.clanInfoList isForSearch:proto.isForSearch];
  }
}

- (void) loadClans:(NSArray *)clans isForSearch:(BOOL)search {
  if (search) {self.shouldReload = NO; isSearching = NO; _reachedEnd = YES;}
  else if (clans.count < 10) {self.shouldReload = NO; _reachedEnd = YES;}
  else self.shouldReload = YES;
  
  for (FullClanProtoWithClanSize *fcp in clans) {
    NSMutableArray *arr = self.clanList;
    
    BOOL canAdd = YES;
    for (FullClanProtoWithClanSize *c in arr) {
      if ([c.clan.clanUuid isEqualToString:fcp.clan.clanUuid]) {
        canAdd = NO;
      }
    }
    
    if (canAdd) {
      [arr addObject:fcp];
    }
  }
  [browseClansTable reloadData];
}

- (NSMutableArray *) arrayForCurrentState {
  return self.clanList;
}

#pragma mark - UITableViewDelegate methods

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  int ct = [self arrayForCurrentState].count;
  
  if (ct > 0 || (state == kBrowseSearch && !isSearching) || (state != kBrowseSearch && _reachedEnd)) {
    self.spinner.hidden = YES;
  } else {
    self.spinner.hidden = NO;
  }
  
  return ct == 0 ? 0 : ct+(state != kBrowseSearch && !_reachedEnd);
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  BrowseClanCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BrowseClanCell"];
  
  NSArray *arr = [self arrayForCurrentState];
  if (indexPath.row >= arr.count) {
    return self.loadingCell;
  }
  
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed:@"BrowseClanCell" owner:self options:nil];
    cell = self.clanCell;
  }
  
  [cell loadForClan:[arr objectAtIndex:indexPath.row]];
  
  return cell;
}

- (IBAction) cellClicked:(id)sender {
  while (![sender isKindOfClass:[BrowseClanCell class]]) {
    sender = [sender superview];
  }
  BrowseClanCell *cell = (BrowseClanCell *)sender;
  [self.parentViewController.navigationController pushViewController:[[ClanInfoViewController alloc] initWithClan:cell.clan] animated:YES];
}

// Cassandra db no longer supports this..
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//  // Load more rows when we get low enough
//  if (scrollView.contentOffset.y > -REFRESH_ROWS*self.browseClansTable.rowHeight) {
//    if (shouldReload) {
//      int min = [[self.clanList lastObject] clan].clanId;
//      [[OutgoingEventController sharedOutgoingEventController] retrieveClanInfo:nil clanId:0 grabType:RetrieveClanInfoRequestProto_ClanInfoGrabTypeClanInfo isForBrowsingList:YES beforeClanId:min delegate:self];
//      self.shouldReload = NO;
//    }
//  }
//}

#pragma mark - UITextFieldDelegate methods

- (IBAction)searchClicked:(id)sender {
  [self.searchField resignFirstResponder];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
  if (textField.text.length > 0) {
    [[OutgoingEventController sharedOutgoingEventController] retrieveClanInfo:textField.text clanUuid:nil grabType:RetrieveClanInfoRequestProto_ClanInfoGrabTypeClanInfo isForBrowsingList:YES delegate:self];
    [self.clanList removeAllObjects];
    isSearching = YES;
    self.searchString = textField.text;
    _reachedEnd = NO;
    [self.browseClansTable reloadData];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] retrieveClanInfo:nil clanUuid:nil grabType:RetrieveClanInfoRequestProto_ClanInfoGrabTypeClanInfo isForBrowsingList:YES delegate:self];
    [self.clanList removeAllObjects];
    isSearching = NO;
    self.searchString = nil;
    _reachedEnd = NO;
    [self.browseClansTable reloadData];
  }
}

#pragma mark -

- (IBAction)rightButtonClicked:(id)sender {
  while (![sender isKindOfClass:[UITableViewCell class]]) {
    sender = [sender superview];
  }
  BrowseClanCell *cell = (BrowseClanCell *)sender;
  
  GameState *gs = [GameState sharedGameState];
  NSString *clanUuid = cell.clan.clan.clanUuid;
  if ([gs.requestedClans containsObject:clanUuid]) {
    [[OutgoingEventController sharedOutgoingEventController] retractRequestToJoinClan:clanUuid delegate:self.parentViewController];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] requestJoinClan:clanUuid delegate:self.parentViewController];
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.view endEditing:YES];
}

@end