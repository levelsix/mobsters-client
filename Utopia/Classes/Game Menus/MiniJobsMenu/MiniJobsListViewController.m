//
//  MiniJobsListViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 5/1/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MiniJobsListViewController.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "GenericPopupController.h"

#define SPACING_PER_NODE 46.f

@implementation MiniJobsListCell

- (void) awakeFromNib {
  self.completeView.frame = self.finishView.frame;
  [self.finishView.superview addSubview:self.completeView];
  
  self.getHelpView.frame = self.finishView.frame;
  [self.finishView.superview addSubview:self.getHelpView];
  
  [self stopSpinners];
}

- (void) updateForMiniJob:(UserMiniJob *)umj {
  self.userMiniJob = umj;
  
  MiniJobProto *mjp = umj.miniJob;
  self.nameLabel.text = mjp.name;
  self.nameLabel.textColor = [Globals colorForRarity:mjp.quality];
  self.jobQualityTag.image = [Globals imageNamed:[Globals imageNameForRarity:mjp.quality suffix:@"job.png"]];
  self.totalTimeLabel.text = [[Globals convertTimeToLongString:umj.durationMinutes*60] uppercaseString];
  
  NSArray *rewards = [Reward createRewardsForMiniJob:mjp];
  if (rewards.count > 2) rewards = [rewards subarrayWithRange:NSMakeRange(0, 2)];
  
  for (UIView *v in [self.rewardsView.subviews copy]) {
    [v removeFromSuperview];
  }
  
  for (int i = 0; i < rewards.count; i++) {
    [[NSBundle mainBundle] loadNibNamed:@"MiniJobsRewardView" owner:self options:nil];
    [self.rewardView loadForReward:rewards[i]];
    self.rewardView.center = ccp((2*i+1-(int)rewards.count)/2.f*SPACING_PER_NODE+self.rewardsView.frame.size.width/2,
                                 self.rewardsView.frame.size.height/2);
    [self.rewardsView addSubview:self.rewardView];
  }
  
  self.arrowIcon.hidden = YES;
  self.totalTimeLabel.hidden = YES;
  self.completeView.hidden = YES;
  self.getHelpView.hidden = YES;
  self.finishView.hidden = YES;
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  if (umj.timeCompleted) {
    self.completeView.hidden = NO;
  } else if (umj.timeStarted) {
    self.finishView.hidden = NO;
    
    [self updateTimes];
  } else {
    self.arrowIcon.hidden = NO;
    self.totalTimeLabel.hidden = NO;
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
  }
}

- (void) updateTimes {
  if (self.userMiniJob.timeStarted) {
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    
    MSDate *date = self.userMiniJob.tentativeCompletionDate;
    int timeLeft = [date timeIntervalSinceNow];
    
    self.timeLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
    
    BOOL canGetHelp = [gs canAskForClanHelp] && [gs.clanHelpUtil getNumClanHelpsForType:ClanHelpTypeMiniJob userDataId:self.userMiniJob.userMiniJobId] < 0;
    
    int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
    if (gemCost > 0) {
      self.gemCostLabel.text = [Globals commafyNumber:gemCost];
      [Globals adjustViewForCentering:self.gemCostLabel.superview withLabel:self.gemCostLabel];
      
      self.getHelpView.hidden = !canGetHelp;
      
      self.gemCostLabel.superview.hidden = NO;
      self.freeLabel.hidden = YES;
    } else {
      self.getHelpView.hidden = YES;
      self.gemCostLabel.superview.hidden = YES;
      self.freeLabel.hidden = NO;
    }
  }
}

- (void) spinCollect {
  self.completeSpinner.hidden = NO;
  self.completeLabelsView.hidden = YES;
  [self.completeSpinner startAnimating];
}

- (void) spinFinish {
  self.finishSpinner.hidden = NO;
  self.finishLabelsView.hidden = YES;
  [self.finishSpinner startAnimating];
}

- (void) stopSpinners {
  self.finishSpinner.hidden = YES;
  self.completeSpinner.hidden = YES;
  self.finishLabelsView.hidden = NO;
  self.completeLabelsView.hidden = NO;
}

@end

@implementation MiniJobsListViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.title = @"MINI JOBS";
  self.titleImageName = @"minijobsbuilding.png";
}

- (void) viewWillAppear:(BOOL)animated {
  [self reloadTableAnimated:NO];
  
  self.updateTimer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
  [self updateLabels];
  
  UserMiniJob *activeJob = [self activeMiniJob];
  if (activeJob.timeCompleted) {
    [self displayCompleteView:activeJob animated:NO];
  }
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(miniJobWaitTimeComplete:) name:MINI_JOB_CHANGED_NOTIFICATION object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self.updateTimer invalidate];
}

- (void) updateLabels {
  for (MiniJobsListCell *cell in self.listTable.visibleCells) {
    [cell updateTimes];
  }
  
  GameState *gs = [GameState sharedGameState];
  UserStruct *mjc = [gs myMiniJobCenter];
  MiniJobCenterProto *fsp = (MiniJobCenterProto *)mjc.staticStruct;
  MSDate *spawnTime = [gs.lastMiniJobSpawnTime dateByAddingTimeInterval:fsp.hoursBetweenJobGeneration*60*60];
  self.spawnTimeLabel.text = [[Globals convertTimeToShortString:spawnTime.timeIntervalSinceNow] uppercaseString];
  
  [Globals adjustViewForCentering:self.spawnTimeLabel.superview withLabel:self.spawnTimeLabel];
}

- (void) reloadMiniJobsArray {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *arr = [gs.myMiniJobs mutableCopy];
  
  [arr sortUsingComparator:^NSComparisonResult(UserMiniJob *obj1, UserMiniJob *obj2) {
    int num1 = obj1.timeCompleted ? 1 : obj1.timeStarted ? 2 : 0;
    int num2 = obj2.timeCompleted ? 1 : obj2.timeStarted ? 2 : 0;
    if (num1 != num2) {
      return [@(num2) compare:@(num1)];
    } else {
      return [@(obj1.userMiniJobId) compare:@(obj2.userMiniJobId)];
    }
  }];
  
  self.miniJobsList = arr;
}

- (void) miniJobWaitTimeComplete:(NSNotification *)notif {
  if (notif.object != self) {
    UserMiniJob *mjp = [self activeMiniJob];
    self.detailsViewController.activeMiniJob = mjp;
    [self reloadTableAnimated:YES];
    if (mjp.timeCompleted) {
      [self displayCompleteView:[self activeMiniJob] animated:YES];
    }
  }
}

- (void) reloadTableAnimated:(BOOL)animated {
  NSArray *before = self.miniJobsList;
  [self reloadMiniJobsArray];
  
  if (animated) {
    NSArray *after = self.miniJobsList;
    [self.listTable beginUpdates];
    for (int i = 0; i < before.count; i++) {
      id object = [before objectAtIndex:i];
      NSInteger newIndex = [after indexOfObject:object];
      if (newIndex != NSNotFound) {
        [self.listTable moveRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] toIndexPath:[NSIndexPath indexPathForRow:newIndex inSection:0]];
      } else {
        [self.listTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
      }
    }
    
    for (int i = 0; i < after.count; i++) {
      id object = [after objectAtIndex:i];
      if (![before containsObject:object]) {
        [self.listTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
      }
    }
    [self.listTable endUpdates];
  } else {
    [self.listTable reloadData];
  }
}

#pragma mark - UITableView delegate/dataSource

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  return self.headerView;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  int ct = (int)self.miniJobsList.count;
  self.noMoreJobsLabel.hidden = ct > 0;
  return ct;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  MiniJobsListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MiniJobsListCell"];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"MiniJobsListCell" owner:self options:nil];
    cell = self.listCell;
  }
  
  [cell updateForMiniJob:self.miniJobsList[indexPath.row]];
  
  return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  
  MiniJobsListCell *cell = (MiniJobsListCell *)[tableView cellForRowAtIndexPath:indexPath];
  [self miniJobsListCellClicked:cell];
}

- (IBAction) collectClicked:(UIView *)sender {
  while (sender && ![sender isKindOfClass:[MiniJobsListCell class]]) {
    sender = [sender superview];
  }
  
  MiniJobsListCell *cell = (MiniJobsListCell *)sender;
  [self miniJobsListCollectClicked:cell];
}

- (IBAction) finishClicked:(UIView *)sender {
  while (sender && ![sender isKindOfClass:[MiniJobsListCell class]]) {
    sender = [sender superview];
  }
  
  MiniJobsListCell *cell = (MiniJobsListCell *)sender;
  [self miniJobsListFinishClicked:cell];
}

- (IBAction) getHelpClicked:(UIView *)sender {
  while (sender && ![sender isKindOfClass:[MiniJobsListCell class]]) {
    sender = [sender superview];
  }
  
  MiniJobsListCell *cell = (MiniJobsListCell *)sender;
  [self miniJobsListHelpClicked:cell];
}

#pragma mark - Transitioning

- (void) transitionToDetailsView {
  [self.parentViewController pushViewController:self.detailsViewController animated:YES];
}

- (void) transitionToListView {
  if (self.detailsViewController) {
    // Set to nil first or else pop will chain viewWillAppear which will try to displayCompleteView again.
    self.detailsViewController = nil;
    [self.parentViewController popViewControllerAnimated:YES];
  }
}

- (void) displayCompleteView:(UserMiniJob *)miniJob animated:(BOOL)animated {
  if (!self.completeViewController) {
    MiniJobsCompleteViewController *comp = [[MiniJobsCompleteViewController alloc] init];
    [comp loadForMiniJob:miniJob];
    comp.delegate = self;
    self.completeViewController = comp;
    
    // Add it right on top of list view so it will transition back from details view
    [self addChildViewController:comp];
    comp.view.frame = self.view.bounds;
    [self.view addSubview:comp.view];
    
    if (self.detailsViewController) {
      [self transitionToListView];
    } else {
      if (animated) {
        comp.view.alpha = 0.f;
        [UIView animateWithDuration:0.3f animations:^{
          comp.view.alpha = 1.f;
        }];
      }
    }
    
  }
}

- (void) removeCompleteView {
  [UIView animateWithDuration:0.3f animations:^{
    self.completeViewController.view.alpha = 0.f;
  } completion:^(BOOL finished) {
    [self.completeViewController.view removeFromSuperview];
    [self.completeViewController removeFromParentViewController];
    self.completeViewController = nil;
  }];
}

#pragma mark - MiniJobsListDelegate

- (void) miniJobsListCellClicked:(MiniJobsListCell *)listCell {
  if (!listCell.userMiniJob.timeStarted && !_selectedCell) {
    [self loadDetailsViewForMiniJob:listCell.userMiniJob];
  }
}

- (void) miniJobsListCollectClicked:(MiniJobsListCell *)listCell {
  if (!_selectedCell) {
    [[OutgoingEventController sharedOutgoingEventController] redeemMiniJob:listCell.userMiniJob delegate:self];
    [listCell spinCollect];
    _selectedCell = listCell;
    
    [self.detailsViewController beginCollectSpinning];
    [self.completeViewController beginSpinning]; 
  }
}

- (void) miniJobsListFinishClicked:(MiniJobsListCell *)listCell {
  if (!_selectedCell) {
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    
    MSDate *date = listCell.userMiniJob.tentativeCompletionDate;
    int timeLeft = [date timeIntervalSinceNow];
    
    int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
    if (gs.gems < gemCost) {
      [GenericPopupController displayNotEnoughGemsView];
    } else {
      [[OutgoingEventController sharedOutgoingEventController] completeMiniJob:listCell.userMiniJob isSpeedup:YES gemCost:gemCost delegate:self];
      [listCell spinFinish];
      _selectedCell = listCell;
      
      [self.detailsViewController beginFinishSpinning];
    }
    
    // Added this here so that timers can update
    [[NSNotificationCenter defaultCenter] postNotificationName:MINI_JOB_CHANGED_NOTIFICATION object:self];
  }
}

- (void) miniJobsListHelpClicked:(MiniJobsListCell *)listCell {
  if (listCell.userMiniJob.timeStarted && !listCell.userMiniJob.timeCompleted && !_selectedCell) {
    [[OutgoingEventController sharedOutgoingEventController] solicitMiniJobHelp:listCell.userMiniJob];
    [listCell updateForMiniJob:listCell.userMiniJob];
  }
}

- (UserMiniJob *) activeMiniJob {
  GameState *gs = [GameState sharedGameState];
  
  for (UserMiniJob *miniJob in gs.myMiniJobs) {
    if (miniJob.timeStarted || miniJob.timeCompleted) {
      return miniJob;
    }
  }
  return nil;
}

- (void) loadDetailsViewForMiniJob:(UserMiniJob *)miniJob {
  self.detailsViewController = [[MiniJobsDetailsViewController alloc] initWithMiniJob:miniJob];
  self.detailsViewController.delegate = self;
  
  [self transitionToDetailsView];
  
  self.detailsViewController.activeMiniJob = [self activeMiniJob];
}

- (IBAction)backClicked:(id)sender {
  if (!_isBeginningJob) {
    [self transitionToListView];
    _selectedCell = nil;
  }
}

#pragma mark - MiniJobsDetailsDelegate

- (void) beginMiniJob:(UserMiniJob *)miniJob withUserMonsters:(NSArray *)userMonsters {
  if (!_isBeginningJob) {
    Globals *gl = [Globals sharedGlobals];
    NSMutableArray *arr = [NSMutableArray array];
    int totalHp = 0, totalAtk = 0;
    int reqHp = miniJob.miniJob.hpRequired, reqAtk = miniJob.miniJob.atkRequired;
    for (UserMonster *um in userMonsters) {
      [arr addObject:@(um.userMonsterId)];
      
      totalHp += um.curHealth;
      totalAtk += [gl calculateTotalDamageForMonster:um];
    }
    if (totalHp >= reqHp && totalAtk >= reqAtk) {
      [[OutgoingEventController sharedOutgoingEventController] beginMiniJob:miniJob userMonsterIds:arr delegate:self];
      _isBeginningJob = YES;
      
      [self.detailsViewController beginEngageSpinning];
    } else {
      if (userMonsters.count == 0) {
        [Globals addAlertNotification:[NSString stringWithFormat:@"You must select %@s before engaging.", MONSTER_NAME]];
      } else {
        if (totalHp < reqHp && totalAtk < reqAtk) {
          [Globals addAlertNotification:@"You need more hp and attack to engage."];
        } else if (totalHp < reqHp) {
          [Globals addAlertNotification:@"You need more hp to engage."];
        } else if (totalAtk < reqAtk) {
          [Globals addAlertNotification:@"You need more attack to engage."];
        }
      }
    }
  }
}

- (void) activeMiniJobSpedUp:(UserMiniJob *)miniJob {
  NSUInteger idx = [self.miniJobsList indexOfObject:miniJob];
  if (idx != NSNotFound) {
    MiniJobsListCell *listCell = (MiniJobsListCell *)[self.listTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
    if (!listCell) {
      listCell = [[MiniJobsListCell alloc] init];
      listCell.userMiniJob = miniJob;
    }
    [self miniJobsListFinishClicked:listCell];
  }
}

- (void) activeMiniJobCompleted:(UserMiniJob *)miniJob {
  NSUInteger idx = [self.miniJobsList indexOfObject:miniJob];
  if (idx != NSNotFound) {
    MiniJobsListCell *listCell = (MiniJobsListCell *)[self.listTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
    if (!listCell) {
      listCell = [[MiniJobsListCell alloc] init];
      listCell.userMiniJob = miniJob;
    }
    [self miniJobsListCollectClicked:listCell];
  }
}

#pragma mark - Event response delegate methods

- (void) handleBeginMiniJobResponseProto:(FullEvent *)fe {
  _isBeginningJob = NO;
  [self.detailsViewController stopSpinning];
  [self transitionToListView];
  self.listTable.contentOffset = ccp(0,0);
  _selectedCell = nil;
  
  [[NSNotificationCenter defaultCenter] postNotificationName:MINI_JOB_CHANGED_NOTIFICATION object:self];
  [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:self];
}

- (void) handleCompleteMiniJobResponseProto:(FullEvent *)fe {
  [_selectedCell stopSpinners];
  [_selectedCell updateForMiniJob:_selectedCell.userMiniJob];
  _selectedCell = nil;
  
  [self.detailsViewController stopSpinning];
  self.detailsViewController.activeMiniJob = [self activeMiniJob];
  [self displayCompleteView:[self activeMiniJob] animated:YES];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:MINI_JOB_CHANGED_NOTIFICATION object:self];
}

- (void) handleRedeemMiniJobResponseProto:(FullEvent *)fe {
  [_selectedCell stopSpinners];
  _selectedCell = nil;
  
  [self.detailsViewController stopSpinning];
  self.detailsViewController.activeMiniJob = [self activeMiniJob];
  [self.completeViewController stopSpinning];
  [self removeCompleteView];
  
  [self reloadTableAnimated:YES];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:MINI_JOB_CHANGED_NOTIFICATION object:self];
  [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:self];
}

@end
