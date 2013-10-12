//
//  ClanViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 9/10/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ClanViewController.h"
#import "GameState.h"
#import "Globals.h"
#import "LNSynthesizeSingleton.h"
#import "OutgoingEventController.h"
#import "GenericPopupController.h"

@implementation ClanViewController

- (void) viewDidLoad {
  self.clanBrowseViewController = [[ClanBrowseViewController alloc] initWithNibName:nil bundle:nil];
  self.clanInfoViewController = [[ClanInfoViewController alloc] initWithNibName:nil bundle:nil];
  self.clanCreateViewController = [[ClanCreateViewController alloc] initWithNibName:nil bundle:nil];
  
  [self addChildViewController:self.clanBrowseViewController];
  [self addChildViewController:self.clanInfoViewController];
  [self addChildViewController:self.clanCreateViewController];
  
  [self updateConfiguration];
  [self button1Clicked:nil];
  
  self.title = @"Clans";
  self.navigationItem.titleView = self.menuTopBar;
  [self setUpCloseButton];
  [self setUpImageBackButton];
}

- (void) viewWillAppear:(BOOL)animated {
  [self updateConfiguration];
}

- (void) updateConfiguration {
  GameState *gs = [GameState sharedGameState];
  if (gs.clan) {
    [self loadInClanConfiguration];
    [self.clanInfoViewController loadForMyClan];
  } else {
    [self loadNotInClanConfiguration];
  }
}

- (void) loadInClanConfiguration {
  _controller1 = self.clanInfoViewController;
  _controller2 = self.clanBrowseViewController;
  
  self.menuTopBar.label1.text = @"MY CLAN";
  self.menuTopBar.label2.text = @"BROWSE CLANS";
}

- (void) loadNotInClanConfiguration {
  _controller1 = self.clanBrowseViewController;
  _controller2 = self.clanCreateViewController;
  
  self.menuTopBar.label1.text = @"JOIN CLAN";
  self.menuTopBar.label2.text = @"CREATE CLAN";
}

- (void) button1Clicked:(id)sender {
  [self.clanCreateViewController.view removeFromSuperview];
  [self.clanBrowseViewController.view removeFromSuperview];
  [self.clanInfoViewController.view removeFromSuperview];
  
  [self.view addSubview:_controller1.view];
  _controller1.view.frame = CGRectMake(0, 8, self.view.bounds.size.width, self.view.bounds.size.height-8);
  
  [self.menuTopBar clickButton:kButton1];
  [self.menuTopBar unclickButton:kButton2];
}

- (void) button2Clicked:(id)sender {
  [self.clanCreateViewController.view removeFromSuperview];
  [self.clanBrowseViewController.view removeFromSuperview];
  [self.clanInfoViewController.view removeFromSuperview];
  
  [self.view addSubview:_controller2.view];
  _controller2.view.frame = CGRectMake(0, 8, self.view.bounds.size.width, self.view.bounds.size.height-8);
  
  [self.menuTopBar clickButton:kButton2];
  [self.menuTopBar unclickButton:kButton1];
}

#pragma mark - Response handlers

- (void) handleCreateClanResponseProto:(FullEvent *)e {
  [self updateConfiguration];
  [self button1Clicked:nil];
}

- (void) handleLeaveClanResponseProto:(FullEvent *)e {
  [self updateConfiguration];
  [self button1Clicked:nil];
}

- (void) handleRequestJoinClanResponseProto:(FullEvent *)e {
  RequestJoinClanResponseProto *proto = (RequestJoinClanResponseProto *)e.event;
  if (proto.status == RequestJoinClanResponseProto_RequestJoinClanStatusJoinSuccess) {
    [self updateConfiguration];
    [self button1Clicked:nil];
  } else {
    [self.clanBrowseViewController.browseClansTable reloadData];
  }
}

- (void) handleRetractRequestJoinClanResponseProto:(FullEvent *)e {
  [self.clanBrowseViewController.browseClansTable reloadData];
}

@end
