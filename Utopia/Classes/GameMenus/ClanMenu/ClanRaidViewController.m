//
//  ClanRaidViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/27/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ClanRaidViewController.h"
#import "GameState.h"
#import "Globals.h"
#import "GameViewController.h"

@implementation ClanRaidViewController

- (id) initWithClanEvent:(PersistentClanEventProto *)clanEvent membersList:(NSArray *)membersList canStartRaidStage:(BOOL)canStartRaidStage {
  if ((self = [super init])) {
    self.clanEvent = clanEvent;
    
    self.detailsViewController = [[ClanRaidDetailsViewController alloc] initWithClanEvent:self.clanEvent];
    self.detailsViewController.delegate = [GameViewController baseController];
    self.detailsViewController.canStartRaidStage = canStartRaidStage;
    [self addChildViewController:self.detailsViewController];
    
    GameState *gs = [GameState sharedGameState];
    if (gs.curClanRaidInfo.clanEventId == self.clanEvent.clanEventId) {
      self.leaderboardViewController = [[ClanRaidLeaderboardViewController alloc] initWithMembersList:membersList];
      [self addChildViewController:self.leaderboardViewController];
    }
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  GameState *gs = [GameState sharedGameState];
  if (self.leaderboardViewController) {
    self.navigationItem.titleView = self.menuTopBar;
  }
  
  self.title = [gs raidWithId:self.clanEvent.clanRaidId].clanRaidName;
  self.shortTitle = @"Raid";
  [self setUpCloseButton:YES];
  [self setUpImageBackButton];
  
  [self button1Clicked:nil];
}

- (void) button1Clicked:(id)sender {
  [self.leaderboardViewController.view removeFromSuperview];
  
  [self.view addSubview:self.detailsViewController.view];
  self.detailsViewController.view.frame = self.view.bounds;
  
  [self.menuTopBar clickButton:kButton1];
  [self.menuTopBar unclickButton:kButton2];
}

- (void) button2Clicked:(id)sender {
  [self.detailsViewController.view removeFromSuperview];
  
  [self.view addSubview:self.leaderboardViewController.view];
  self.leaderboardViewController.view.frame = self.view.bounds;
  
  [self.menuTopBar clickButton:kButton2];
  [self.menuTopBar unclickButton:kButton1];
}

@end
