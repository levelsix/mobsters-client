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

#import "GameViewController.h"
#import "ProfileViewController.h"

#define HIGHEST_RANK_INCREMENT 25
#define SCROLL_TO_HIDE_BAR_DISTANCE 20

@implementation LeaderBoardBotBar

- (void) awakeFromNib {
  self.isUp = YES;
}

- (void) scrollViewDidScrollCheck:(UIScrollView *)scrollView {
  if(self.isAnimating) {
    return;
  }
  if(self.isUp) {
    if( scrollView.contentOffset.y > SCROLL_TO_HIDE_BAR_DISTANCE) {
      [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 0.f;
      }];
      self.isAnimating = YES;
      [self animateOut:^{
        self.isUp = NO;
        self.isAnimating = NO;
      }];
    }
  } else {
    if( scrollView.contentOffset.y < SCROLL_TO_HIDE_BAR_DISTANCE) {
      [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 1.f;
      }];
      self.isAnimating = YES;
      [self animateIn:^{
        self.isUp = YES;
        self.isAnimating = NO;
      }];
    }
  }
}

- (void) animateIn:(dispatch_block_t)completion {
  CGPoint pt = ccp(self.superview.center.x, self.superview.frame.size.height - (self.frame.size.height/2));
  self.center = ccp(pt.x, self.superview.frame.size.height + (self.frame.size.height/2));
  
  [UIView animateWithDuration:0.3f animations:^{
    self.center = pt;
  } completion:^(BOOL finished) {
    if (completion) {
      completion();
    }
  }];
}

- (void) animateOut:(dispatch_block_t)completion {
  [UIView animateWithDuration:0.3f animations:^{
    self.center = ccp(self.center.x, self.center.y + self.frame.size.height);
  } completion:^(BOOL finished) {
    if (completion) {
      completion();
    }
  }];
}

@end

@implementation LeaderBoardViewCell

- (void)updateWithLeaderBoardObject:(id<LeaderBoardObject>)leaderInfo scoreIcon:(NSString *)scoreIcon {
  [self updateWithRank:leaderInfo.rank score:leaderInfo.score userName:leaderInfo.mup.name clanTag:leaderInfo.mup.clan.tag avatarMonsterId:leaderInfo.mup.avatarMonsterId scoreIcon:scoreIcon];
  
  GameState *gs = [GameState sharedGameState];
  self.starImageView.hidden = ![gs.userUuid isEqualToString:leaderInfo.mup.userUuid];
}

- (void) updateWithRank:(int)rank score:(uint64_t)score userName:(NSString *)userName clanTag:(NSString *)clanTag avatarMonsterId:(int)avatarMonsterId scoreIcon:(NSString *)scoreIcon {
  self.selectionStyle = UITableViewCellSelectionStyleNone;
//  self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
  self.rankLabel.text = [Globals commafyNumber:(float)rank];
  self.scoreLabel.text = [Globals commafyNumber:(float)score];
  self.nameLabel.text = [Globals fullNameWithName:userName clanTag:clanTag];
  [Globals imageNamed:scoreIcon withView:self.scoreImage greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  
  [self.monsterView updateForMonsterId:avatarMonsterId];
  
  self.starImageView.hidden = YES;
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
    GameState *gs = [GameState sharedGameState];
    _scoreName = @"STRENGTH";
    _scoreIcon = @"strengthicon.png";
    _ownScore = gs.totalStrength;
  }
  
  return self;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.containerView.layer.cornerRadius = 5.f;
  
  self.tableView.hidden = YES;
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  
  UIRefreshControl *ref = [[UIRefreshControl alloc] init];
  [ref addTarget:self action:@selector(refreshFromScratch) forControlEvents:UIControlEventValueChanged];
  
  UITableViewController *tvc = [[UITableViewController alloc]initWithStyle:UITableViewStylePlain];
  [self addChildViewController:tvc];
  tvc.tableView = self.tableView;
  tvc.refreshControl = ref;
  self.refreshControl = ref;
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  self.scoreLabel.text = _scoreName;
  self.tableLoadingIndicator.hidden = NO;
  self.loadingViewIndicator.transform = CGAffineTransformMakeScale(0.75, 0.75);
  
  [self.view addSubview:self.popoverView];
  self.popoverView.hidden = YES;
  
  [self refreshFromScratch];
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

- (void) stopLoading {
  [self.refreshControl endRefreshing];
  
  if (_highestRankShown < _highestRankToShow) {
    _moreScoresAvailable = NO;
  }
  
  _waitingOnServer = NO;
  self.tableLoadingIndicator.hidden = YES;
  self.tableView.hidden = NO;
  
  [self.tableView reloadData];
}

#pragma mark - Table View Delegate Methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return self.leaderboardHeaderView.bounds.size.height;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    return 1;
  } else {
    //the additional 1 is the loading view
    return self.leaderList.count + (_moreScoresAvailable?1:0);
  }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return self.yourRankingHeader;
  } else {
    return self.leaderboardHeaderView;
  }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  GameState *gs = [GameState sharedGameState];
  
  LeaderBoardViewCell *cell = cell = [tableView dequeueReusableCellWithIdentifier:@"LeaderBoardCell"];
  if (!cell)
  {
    cell = [[NSBundle mainBundle] loadNibNamed:@"LeaderBoardCell" owner:self options:nil][0];
  }
  
  if (indexPath.section == 0) {
    [cell updateWithRank:self.ownRanking.rank score:_ownScore userName:gs.name clanTag:gs.clan.tag avatarMonsterId:gs.avatarMonsterId scoreIcon:_scoreIcon];
  } else if(indexPath.row < self.leaderList.count) {
    [cell updateWithLeaderBoardObject:self.leaderList[indexPath.row] scoreIcon:_scoreIcon];
  } else if (self.leaderList.count > 0) {
    _highestRankToShow += HIGHEST_RANK_INCREMENT;
    [self refresh];
    [self.loadingViewIndicator startAnimating];
    return self.loadingViewCell;
  }
  
  return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (self.popoverView.hidden) {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionNone animated:NO];
    [self displayPopoverOverCell:cell];
  } else {
    [self.popoverView close];
  }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
  if (!self.popoverView.hidden) {
    [self.popoverView close];
  }
  
  [self.botBar scrollViewDidScrollCheck:scrollView];
}

#pragma mark - popover

- (void) displayPopoverOverCell:(UITableViewCell *)cell {
  self.popoverView.layer.anchorPoint = ccp(0.5, 1);
  CGPoint pt = [self.popoverView.superview convertPoint:cell.frame.origin fromView:cell.superview];
  pt.x += self.popoverView.layer.anchorPoint.x*self.popoverView.frame.size.width + ([Globals isiPad] ? 51.f : 10.f);
  [self.popoverView openAtPoint:pt];
  self.popoverView.delegate = self;
  
  NSInteger row = [self.tableView indexPathForCell:cell].row;
  _clickedLeader = self.leaderList[row];
}

- (void) closePopover {
  [self.popoverView close];
  _clickedLeader = nil;
}

- (void) profileClicked {
  if (_clickedLeader) {
    UIViewController *gvc = [GameViewController baseController];
    ProfileViewController *pvc = [[ProfileViewController alloc] initWithUserUuid:_clickedLeader.mup.userUuid];
    [gvc addChildViewController:pvc];
    pvc.view.frame = gvc.view.bounds;
    [gvc.view addSubview:pvc.view];
  }
}

- (void) messageClicked {
  if (_clickedLeader) {
    GameViewController *gvc = [GameViewController baseController];
    [gvc openPrivateChatWithUserUuid:_clickedLeader.mup.userUuid name:_clickedLeader.mup.name];
  }
}

- (void) muteClicked {
  //there's no mute button here
}

- (void) profileClicked:(NSString *)userUuid {
  UIViewController *gvc = [GameViewController baseController];
  ProfileViewController *pvc = [[ProfileViewController alloc] initWithUserUuid:userUuid];
  [gvc addChildViewController:pvc];
  pvc.view.frame = gvc.view.bounds;
  [gvc.view addSubview:pvc.view];
}

#pragma mark - server events

- (void) refreshFromScratch {
  _highestRankShown = 0;
  _highestRankToShow = HIGHEST_RANK_INCREMENT;
  _moreScoresAvailable = YES;
  [self refresh];
}

- (void) refresh {
  if (_waitingOnServer) {
    return;
  }
  GameState *gs = [GameState sharedGameState];
  
  //when we add more types of leader boards, we can just add a switch here
  [[OutgoingEventController sharedOutgoingEventController] retrieveStrengthLeaderBoardBetweenMinRank:_highestRankShown+1 maxRank:_highestRankToShow delegate:self];
  _waitingOnServer = YES;
  
  _ownScore = gs.totalStrength;
}

- (void) handleRetrieveStrengthLeaderBoardResponseProto:(FullEvent *)fe {
  RetrieveStrengthLeaderBoardResponseProto *proto = (RetrieveStrengthLeaderBoardResponseProto *)fe.event;
  
  // Basically, add to the list if highest rank shown is > 1 since it means we're loading more
  if (_highestRankShown == 0) {
    self.leaderList = [NSMutableArray arrayWithArray:proto.leaderBoardInfoList];
  } else {
    [self.leaderList addObjectsFromArray:proto.leaderBoardInfoList];
  }
  
  self.ownRanking = proto.senderLeaderBoardInfo;
  
  _highestRankShown = [[self.leaderList lastObject] rank];
  
  [self stopLoading];
}

@end
