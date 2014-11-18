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
  Globals *gl = [Globals sharedGlobals];
  
  self.clan = c;
  self.topLabel.text = [NSString stringWithFormat:@"[%@] %@", c.clan.tag, c.clan.name];
  self.membersLabel.text = [NSString stringWithFormat:@"%d/%d", c.clanSize, gl.maxClanSize];
  
  ClanIconProto *icon = [gs clanIconWithId:c.clan.clanIconId];
  [Globals imageNamed:icon.imgName withView:self.iconImage greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  
  if (c.clan.requestToJoinRequired) {
    self.typeLabel.text = @"By Request Only";
    self.typeLabel.textColor = [UIColor colorWithRed:222/255.f green:0/255.f blue:0/255.f alpha:1.f];
    self.buttonLabel.textColor = [UIColor colorWithRed:131/255.f green:3/255.f blue:0/255.f alpha:1.f];
    self.buttonLabel.shadowColor = [UIColor colorWithRed:255/255.f green:163/255.f blue:97/255.f alpha:.8f];
    [self.redButton setImage:[Globals imageNamed:@"redsmallbutton.png"] forState:UIControlStateNormal];
  } else {
    self.typeLabel.text = @"Anyone Can Join";
    self.typeLabel.textColor = [UIColor colorWithRed:102/255.f green:165/255.f blue:0/255.f alpha:1.f];
    self.buttonLabel.textColor = [UIColor colorWithRed:23/255.f green:120/255.f blue:0/255.f alpha:1.f];
    self.buttonLabel.shadowColor = [UIColor colorWithRed:246/255.f green:255/255.f blue:151/255.f alpha:.8f];
    [self.redButton setImage:[Globals imageNamed:@"greensmallbutton.png"] forState:UIControlStateNormal];
  }
  
  if (!gs.clan) {
    self.buttonView.hidden = NO;
    if ([gs.requestedClans containsObject:c.clan.clanUuid]) {
      self.buttonLabel.text = @"Cancel";
    } else {
      if (c.clan.requestToJoinRequired) {
        self.buttonLabel.text = @"Request";
      } else {
        self.buttonLabel.text = @"Join";
      }
    }
    self.buttonView.hidden = NO;
  } else {
    self.buttonView.hidden = YES;
  }
  
  self.buttonLabel.hidden = NO;
  self.spinner.hidden = YES;
}

@end

@implementation ClanBrowseViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.browseClansTable.tableFooterView = [[UIView alloc] init];
  
  self.title = @"Browse";
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self.browseClansTable reloadData];
}

- (void) setState:(ClanBrowseState)s {
  _state = s;
  [self.browseClansTable reloadData];
  [self.browseClansTable setContentOffset:ccp(0,0) animated:YES];
}

- (void) reload {
  [self.clanList removeAllObjects];
  [[OutgoingEventController sharedOutgoingEventController] retrieveClanInfo:nil clanUuid:0 grabType:RetrieveClanInfoRequestProto_ClanInfoGrabTypeClanInfo isForBrowsingList:YES delegate:self];
  _reachedEnd = YES;//NO;
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
  
  if (!self.clanList) self.clanList = [NSMutableArray array];
  
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
  [self.browseClansTable reloadData];
}

- (NSMutableArray *) arrayForCurrentState {
  return self.clanList;
}

#pragma mark - UITableViewDelegate methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger ct = [self arrayForCurrentState].count;
  
  if (ct > 0 || (self.state == kBrowseSearch && !isSearching) || (self.state != kBrowseSearch && _reachedEnd)) {
    self.spinner.hidden = YES;
  } else {
    self.spinner.hidden = NO;
  }
  
  return ct == 0 ? 0 : ct+(self.state != kBrowseSearch && !_reachedEnd);
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

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  
  [self cellClicked:[tableView cellForRowAtIndexPath:indexPath]];
}

- (IBAction) cellClicked:(id)sender {
  while (![sender isKindOfClass:[BrowseClanCell class]]) {
    sender = [sender superview];
  }
  BrowseClanCell *cell = (BrowseClanCell *)sender;
  [self.parentViewController pushViewController:[[ClanInfoViewController alloc] initWithClan:cell.clan] animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  // Load more rows when we get low enough
  if (scrollView.contentOffset.y > -REFRESH_ROWS*self.browseClansTable.rowHeight) {
    if (self.shouldReload) {
//      int min = [[self.clanList lastObject] clan].clanId;
//      [[OutgoingEventController sharedOutgoingEventController] retrieveClanInfo:nil clanId:0 grabType:RetrieveClanInfoRequestProto_ClanInfoGrabTypeClanInfo isForBrowsingList:YES beforeClanId:min delegate:self];
      self.shouldReload = NO;
    }
  }
}

#pragma mark - UITextFieldDelegate methods

- (IBAction)searchClicked:(id)sender {
  [self.searchField resignFirstResponder];
  if (self.searchField.text.length > 0 && ![self.searchField.text isEqualToString:self.searchString]) {
    [[OutgoingEventController sharedOutgoingEventController] retrieveClanInfo:self.searchField.text clanUuid:0 grabType:RetrieveClanInfoRequestProto_ClanInfoGrabTypeClanInfo isForBrowsingList:YES delegate:self];
    [self.clanList removeAllObjects];
    isSearching = YES;
    self.searchString = self.searchField.text;
    _reachedEnd = NO;
    [self.browseClansTable reloadData];
  } else if (self.searchString && self.searchField.text.length == 0) {
    [[OutgoingEventController sharedOutgoingEventController] retrieveClanInfo:nil clanUuid:0 grabType:RetrieveClanInfoRequestProto_ClanInfoGrabTypeClanInfo isForBrowsingList:YES delegate:self];
    [self.clanList removeAllObjects];
    isSearching = NO;
    self.searchString = nil;
    _reachedEnd = NO;
    [self.browseClansTable reloadData];
  }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
  [self searchClicked:nil];
  return YES;
}

#pragma mark -

- (IBAction)rightButtonClicked:(id)sender {
  if (_waitingForResponse) {
    return;
  }
  
  while (![sender isKindOfClass:[UITableViewCell class]]) {
    sender = [sender superview];
  }
  BrowseClanCell *cell = (BrowseClanCell *)sender;
  
  GameState *gs = [GameState sharedGameState];
  NSString *clanUuid = cell.clan.clan.clanUuid;
  if ([gs.requestedClans containsObject:clanUuid]) {
    [[OutgoingEventController sharedOutgoingEventController] retractRequestToJoinClan:clanUuid delegate:self];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] requestJoinClan:clanUuid delegate:self];
  }
  
  cell.buttonLabel.hidden = YES;
  cell.spinner.hidden = NO;
  [cell.spinner startAnimating];
  
  _waitingForResponse = YES;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.view endEditing:YES];
}

#pragma mark - Event handlers

- (void) handleRetractRequestJoinClanResponseProto:(FullEvent *)fe {
  [self.browseClansTable reloadData];
  _waitingForResponse = NO;
}

- (void) handleRequestJoinClanResponseProto:(FullEvent *)fe {
  RequestJoinClanResponseProto *proto = (RequestJoinClanResponseProto *)fe.event;
  if (proto.status == RequestJoinClanResponseProto_RequestJoinClanStatusSuccessJoin ||
      proto.status == RequestJoinClanResponseProto_RequestJoinClanStatusSuccessRequest) {
    [Analytics joinSquad:proto.minClan.name isRequestType:proto.minClan.requestToJoinRequired];
  }
  
  [self.browseClansTable reloadData];
  _waitingForResponse = NO;
}

- (void) handleClanEventApproveOrRejectRequestToJoinClanResponseProto:(ApproveOrRejectRequestToJoinClanResponseProto *)proto {
  [self.browseClansTable reloadData];
}

- (void) handleClanEventBootPlayerFromClanResponseProto:(BootPlayerFromClanResponseProto *)proto {
  [self.browseClansTable reloadData];
}

@end