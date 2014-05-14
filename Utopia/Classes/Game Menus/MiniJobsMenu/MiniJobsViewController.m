//
//  MiniJobsViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 5/1/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "MiniJobsViewController.h"
#import "Globals.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "GenericPopupController.h"

@implementation MiniJobsViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.listViewController = [[MiniJobsListViewController alloc] init];
  self.listViewController.delegate = self;
  [self addChildViewController:self.listViewController];
  [self.containerView addSubview:self.listViewController.view];
  
  self.backView.alpha = 0.f;
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (void) viewDidAppear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(miniJobWaitTimeComplete:) name:MINI_JOB_WAIT_COMPLETE_NOTIFICATION object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) miniJobWaitTimeComplete:(NSNotification *)notif {
  if (notif.object != self) {
    self.detailsViewController.activeMiniJob = [self activeMiniJob];
  }
}

- (IBAction) closeClicked:(id)sender {
  [self close];
}

- (void) close {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

#pragma mark - Transitioning

- (void) transitionToDetailsView {
  self.detailsViewController.view.center = ccp(self.containerView.frame.size.width+
                                               self.detailsViewController.view.frame.size.width/2,
                                               self.detailsViewController.view.center.y);
  [UIView animateWithDuration:0.3f animations:^{
    self.detailsViewController.view.center = ccp(self.containerView.frame.size.width/2,
                                                 self.detailsViewController.view.center.y);
    self.listViewController.view.center = ccp(-self.listViewController.view.center.x,
                                              self.listViewController.view.center.y);
    self.backView.alpha = 1.f;
    
    self.titleLabel.alpha = 1.f;
    
    [self.listViewController viewWillDisappear:YES];
  } completion:^(BOOL finished) {
    [self.listViewController viewDidDisappear:YES];
  }];
  self.titleLabel.text = self.detailsViewController.title;
}

- (void) transitionToListView {
  MiniJobsDetailsViewController *dvc = self.detailsViewController;
  [self.listViewController reloadTableAnimated:NO];
  [UIView animateWithDuration:0.3f animations:^{
    self.listViewController.view.center = ccp(self.containerView.frame.size.width/2,
                                              self.listViewController.view.center.y);
    dvc.view.center = ccp(self.containerView.frame.size.width+
                          dvc.view.frame.size.width/2,
                          dvc.view.center.y);
    self.backView.alpha = 0.f;
    
    self.titleLabel.alpha = 0.f;
    
    [self.listViewController viewWillAppear:YES];
  } completion:^(BOOL finished) {
    [self.listViewController viewDidAppear:YES];
    
    [dvc.view removeFromSuperview];
    [dvc removeFromParentViewController];
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
  }
}

- (void) miniJobsListFinishClicked:(MiniJobsListCell *)listCell {
  if (!_selectedCell) {
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    
    MSDate *date = [listCell.userMiniJob.timeStarted dateByAddingTimeInterval:listCell.userMiniJob.durationMinutes*60];
    int timeLeft = [date timeIntervalSinceNow];
    
    int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
    if (gs.gold < gemCost) {
      [GenericPopupController displayNotEnoughGemsView];
    } else {
      [[OutgoingEventController sharedOutgoingEventController] completeMiniJob:listCell.userMiniJob isSpeedup:YES gemCost:gemCost delegate:self];
      [listCell spinFinish];
      _selectedCell = listCell;
    }
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
  [self addChildViewController:self.detailsViewController];
  [self.containerView addSubview:self.detailsViewController.view];
  
  self.detailsViewController.activeMiniJob = [self activeMiniJob];
  
  [self transitionToDetailsView];
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
        [Globals addAlertNotification:@"You must select mobsters before engaging."];
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
  NSUInteger idx = [self.listViewController.miniJobsList indexOfObject:miniJob];
  if (idx != NSNotFound) {
    MiniJobsListCell *listCell = (MiniJobsListCell *)[self.listViewController.listTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
    if (!listCell) {
      listCell = [[MiniJobsListCell alloc] init];
      listCell.userMiniJob = miniJob;
    }
    [self miniJobsListFinishClicked:listCell];
    
    [self.detailsViewController beginFinishSpinning];
  }
}

- (void) activeMiniJobCompleted:(UserMiniJob *)miniJob {
  NSUInteger idx = [self.listViewController.miniJobsList indexOfObject:miniJob];
  if (idx != NSNotFound) {
    MiniJobsListCell *listCell = (MiniJobsListCell *)[self.listViewController.listTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
    if (!listCell) {
      listCell = [[MiniJobsListCell alloc] init];
      listCell.userMiniJob = miniJob;
    }
    [self miniJobsListCollectClicked:listCell];
    
    [self.detailsViewController beginCollectSpinning];
  }
}

#pragma mark - Event response delegate methods

- (void) handleBeginMiniJobResponseProto:(FullEvent *)fe {
  _isBeginningJob = NO;
  [self.detailsViewController stopSpinning];
  [self transitionToListView];
  _selectedCell = nil;
  
  [[NSNotificationCenter defaultCenter] postNotificationName:MINI_JOB_WAIT_COMPLETE_NOTIFICATION object:self];
}

- (void) handleCompleteMiniJobResponseProto:(FullEvent *)fe {
  [_selectedCell stopSpinners];
  [_selectedCell updateForMiniJob:_selectedCell.userMiniJob];
  _selectedCell = nil;
  
  [self.detailsViewController stopSpinning];
  self.detailsViewController.activeMiniJob = [self activeMiniJob];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:MINI_JOB_WAIT_COMPLETE_NOTIFICATION object:self];
}

- (void) handleRedeemMiniJobResponseProto:(FullEvent *)fe {
  [_selectedCell stopSpinners];
  _selectedCell = nil;
  
  [self.detailsViewController stopSpinning];
  self.detailsViewController.activeMiniJob = [self activeMiniJob];
  
  [self.listViewController reloadTableAnimated:YES];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:MINI_JOB_WAIT_COMPLETE_NOTIFICATION object:self];
}

@end
