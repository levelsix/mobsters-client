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
#import "FacebookDelegate.h"
#import "RequestsFacebookTableController.h"
#import "RequestsBattleTableController.h"
#import "UnreadNotifications.h"

@implementation RequestsViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  self.facebookController = [[RequestsFacebookTableController alloc] init];
  self.battleController = [[RequestsBattleTableController alloc] init];
  
  [self updateBadgeIcons];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadgeIcons) name:NEW_FB_INVITE_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadgeIcons) name:FB_INVITE_RESPONDED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadgeIcons) name:NEW_BATTLE_HISTORY_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadgeIcons) name:BATTLE_HISTORY_VIEWED_NOTIFICATION object:nil];
  
  if (self.battleBadgeIcon.badgeNum) {
    [self button1Clicked:nil];
  } else if (self.facebookBadgeIcon.badgeNum) {
    [self button2Clicked:nil];
  } else {
    [self button1Clicked:nil];
  }
}

- (void) viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) changeTableController:(id<RequestsTableController>)newController {
  [_curTableController resignDelegate];
  self.requestsTable.delegate = newController;
  self.requestsTable.dataSource = newController;
  [newController becameDelegate:self.requestsTable noRequestsLabel:self.noRequestsLabel spinner:self.spinner];
  _curTableController = newController;
}

- (IBAction)closeClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self changeTableController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

- (void) updateBadgeIcons {
  GameState *gs = [GameState sharedGameState];
  self.facebookBadgeIcon.badgeNum = gs.fbUnacceptedRequestsFromFriends.count;
  
  int requestsBadge = 0;
  for (PvpHistoryProto *pvp in gs.battleHistory) {
    if (pvp.isUnread) {
      requestsBadge++;
    }
  }
  self.battleBadgeIcon.badgeNum = requestsBadge;
}

#pragma mark - Tab bar delegate

- (void) button1Clicked:(id)sender {
  [self changeTableController:self.battleController];
  [self.topBar clickButton:1];
}

- (void) button2Clicked:(id)sender {
  [self changeTableController:self.facebookController];
  [self.topBar clickButton:2];
}

- (void) button3Clicked:(id)sender {
  [self changeTableController:nil];
  [self.requestsTable reloadData];
  self.noRequestsLabel.hidden = NO;
  self.noRequestsLabel.text = @"There are no events in progress.";
  
  [self.topBar clickButton:3];
}

@end
