//
//  MiniJobsListViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 5/1/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MiniJobsListViewController.h"
#import "GameState.h"

#define SPACING_PER_NODE 46.f

@implementation MiniJobsListCell

- (void) awakeFromNib {
  self.completeView.frame = self.finishView.frame;
  [self.finishView.superview addSubview:self.completeView];
  
  [self stopSpinners];
}

- (void) updateForMiniJob:(UserMiniJob *)umj {
  self.userMiniJob = umj;
  
  MiniJobProto *mjp = umj.miniJob;
  self.nameLabel.text = mjp.name;
  self.nameLabel.textColor = [Globals colorForRarity:mjp.quality];
  self.jobQualityTag.image = [Globals imageNamed:[Globals imageNameForRarity:mjp.quality suffix:@"job.png"]];
  
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
  self.completeView.hidden = YES;
  self.finishView.hidden = YES;
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  if (umj.timeCompleted) {
    self.completeView.hidden = NO;
  } else if (umj.timeStarted) {
    self.finishView.hidden = NO;
    
    [self updateTimes];
  } else {
    self.arrowIcon.hidden = NO;
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
  }
}

- (void) updateTimes {
  if (self.userMiniJob.timeStarted) {
    Globals *gl = [Globals sharedGlobals];
    
    MSDate *date = [self.userMiniJob.timeStarted dateByAddingTimeInterval:self.userMiniJob.durationMinutes*60];
    int timeLeft = [date timeIntervalSinceNow];
    
    self.timeLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
    
    int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
    self.gemCostLabel.text = [Globals commafyNumber:gemCost];
    [Globals adjustViewForCentering:self.gemCostLabel.superview withLabel:self.gemCostLabel];
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

- (void) viewWillAppear:(BOOL)animated {
  [self reloadTableAnimated:NO];
  
  self.updateTimer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
  [self updateLabels];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(miniJobWaitTimeComplete:) name:MINI_JOB_WAIT_COMPLETE_NOTIFICATION object:nil];
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
  if (!notif.object) {
    [self reloadTableAnimated:NO];
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
  [self.delegate miniJobsListCellClicked:cell];
}

- (IBAction) collectClicked:(UIView *)sender {
  while (sender && ![sender isKindOfClass:[MiniJobsListCell class]]) {
    sender = [sender superview];
  }
  
  MiniJobsListCell *cell = (MiniJobsListCell *)sender;
  [self.delegate miniJobsListCollectClicked:cell];
}

- (IBAction) finishClicked:(UIView *)sender {
  while (sender && ![sender isKindOfClass:[MiniJobsListCell class]]) {
    sender = [sender superview];
  }
  
  MiniJobsListCell *cell = (MiniJobsListCell *)sender;
  [self.delegate miniJobsListFinishClicked:cell];
}

@end
