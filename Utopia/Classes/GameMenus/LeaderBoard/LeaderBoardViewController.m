//
//  LeaderBoardViewController.m
//  Utopia
//
//  Created by Kenneth Cox on 5/5/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//
#import "GameState.h"

#import "LeaderBoardViewController.h"

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
  }
  
  return self;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.containerView.superview.layer.cornerRadius = 5.f;
  self.containerView.superview.clipsToBounds = YES;
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  self.scoreLabel.text = _scoreName;
}

//- (void) viewDidLoad {
//  [super viewDidLoad];
//  
//  // Initialize the refresh control.
//  self.refreshControl = [[UIRefreshControl alloc] init];
//  self.refreshControl.backgroundColor = [UIColor purpleColor];
//  self.refreshControl.tintColor = [UIColor whiteColor];
//  [self.refreshControl addTarget:self.self
//                          action:@selector(reloadData)
//                forControlEvents:UIControlEventValueChanged];
//}
//
//- (void) reloadData {
////  [self.refreshControl endRefreshing];
//}

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
    [cell updateWithRank:200 score:(int)gs.totalStrength userName:gs.minUser.name scoreIcon:_scoreIcon];
  } else {
    
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

@end
