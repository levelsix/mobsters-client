//
//  LeaderBoardViewController.m
//  Utopia
//
//  Created by Kenneth Cox on 5/5/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//
#import "GameState.h"
#import "LeaderBoardViewController.h"
#import "OutgoingEventController.h"
#import "IncomingEventController.h"

#define TOTAL_CELLS_INCREMENT 25;

@implementation LeaderBoardViewCell

- (void)updateWithRank:(int)rank score:(int)score userName:(NSString *)userName scoreIcon:(NSString *)scoreIcon {
  self.rankLabel.text = [Globals commafyNumber:(float)rank];
  self.scoreLabel.text = [Globals commafyNumber:(float)score];
  self.nameLabel.text = userName;
  [Globals imageNamed:scoreIcon withView:self.scoreImage greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  
  self.rankBG.hidden = NO;
  self.cellBG.hidden = NO;
  if (rank == 1) {
    self.rankBG.image = [Globals imageNamed:@"1stplaceicon.png"];
    self.cellBG.image = [Globals imageNamed:@"1stplacebg.png"];
  } else if (rank == 2) {
    self.rankBG.image = [Globals imageNamed:@"2ndplaceicon.png"];
    self.cellBG.image = [Globals imageNamed:@"2ndplacebg.png"];
  } else if (rank == 3) {
    self.rankBG.image = [Globals imageNamed:@"3rdplaceicon.png"];
    self.cellBG.image = [Globals imageNamed:@"3rdplacebg.png"];
  } else {
    self.rankBG.hidden = YES;
    self.cellBG.hidden = YES;
  }
}

@end

@implementation LeaderBoardViewController

- (id) initStrengthLeaderBoard {
  if ((self = [super init])) {
    _scoreName = @"STRENGTH";
    _scoreIcon = @"strengthicon.png";
    _totalCellsToShow = TOTAL_CELLS_INCREMENT;
  }
  
  return self;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.containerView.superview.layer.cornerRadius = 5.f;
  self.containerView.superview.clipsToBounds = YES;
  self.tableView.hidden = YES;
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  self.scoreLabel.text = _scoreName;
  [self addPullToRefreshHeader:self.tableView];
  self.tableLoadingIndicator.hidden = NO;
  
  [self retrieveRanks];
}

#pragma mark - Table View Delegate Methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return self.LeaderBoardHeaderView.bounds.size.height;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    return 1;
  } else {
    return self.leaderList.count;
  }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return self.yourRankingHeader;
  } else {
    return self.LeaderBoardHeaderView;
  }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  GameState *gs = [GameState sharedGameState];
  
  LeaderBoardViewCell *cell = [[NSBundle mainBundle] loadNibNamed:@"LeaderBoardCell" owner:self options:nil][0];
  if (indexPath.section == 0) {
    [cell updateWithRank:self.ownRanking.rank score:self.ownRanking.score userName:gs.minUser.name scoreIcon:_scoreIcon];
  } else {
    id<LeaderBoardObject> lbo = self.leaderList[indexPath.row];
    [cell updateWithRank:lbo.rank score:lbo.score userName:lbo.name scoreIcon:_scoreIcon];
  }
  
  return cell;
}

- (IBAction)closeClicked:(id)sender {
  [self close];
}

- (void) close {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

#pragma mark - outgoing events

- (void) retrieveRanks {
  [[OutgoingEventController sharedOutgoingEventController] retrieveStrengthLeaderBoardBetweenMinRank:0 maxRank:_totalCellsToShow delegate:self];
}

- (void) handleRetrieveStrengthLeaderBoardResponseProto:(FullEvent *)fe {
  RetrieveStrengthLeaderBoardResponseProto *proto = (RetrieveStrengthLeaderBoardResponseProto *)fe.event;
  
  self.leaderList = [NSMutableArray arrayWithArray:proto.leaderBoardInfoList];
  self.ownRanking = proto.senderLeaderBoardInfo;
  
  self.tableLoadingIndicator.hidden = YES;
  self.tableView.hidden = NO;
  
  [self.tableView reloadData];
  [self refresh];
}

@end
