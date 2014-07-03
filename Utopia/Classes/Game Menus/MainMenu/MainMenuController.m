//
//  MainMenuController.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/15/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "MainMenuController.h"
#import "Globals.h"
#import "ClanViewController.h"
#import "DiamondShopViewController.h"
#import "OldSettingsViewController.h"
#import "CarpenterViewController.h"
#import "MyCroniesViewController.h"
#import "GachaponViewController.h"
#import "GameState.h"
#import "LabViewController.h"

@implementation MainMenuController

- (void) viewDidLoad {
  self.title = @"Menu";
  
  [self setUpImageBackButton];
}

- (void) viewWillAppear:(BOOL)animated {
  // Set up settings button with close button
  [self loadCustomNavBarButtons];
  UIBarButtonItem *rightButton1 = [[UIBarButtonItem alloc] initWithCustomView:self.menuCloseButton];
  UIBarButtonItem *rightButton2 = [[UIBarButtonItem alloc] initWithCustomView:self.menuSettingsButton];
  self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:rightButton1, rightButton2, nil];
  
  GameState *gs = [GameState sharedGameState];
  if (!gs.myLaboratory.isComplete) {
    [[self.enhanceButtonView viewWithTag:5] removeFromSuperview];
    UIImage *img = [Globals greyScaleImageWithBaseImage:[Globals snapShotView:self.enhanceButtonView]];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    imgView.tag = 5;
    [self.enhanceButtonView insertSubview:imgView atIndex:self.enhanceButtonView.subviews.count-1];
  }
  if (!gs.myEvoChamber.isComplete) {
    [[self.evolveButtonView viewWithTag:5] removeFromSuperview];
    UIImage *img = [Globals greyScaleImageWithBaseImage:[Globals snapShotView:self.evolveButtonView]];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    imgView.tag = 5;
    [self.evolveButtonView insertSubview:imgView atIndex:self.evolveButtonView.subviews.count-1];
  }
}

- (IBAction)fundsClicked:(id)sender {
  [self.navigationController pushViewController:[[DiamondShopViewController alloc] init] animated:YES];
}

- (IBAction)cratesClicked:(id)sender {
  // Set the frame manually so featured views and such update properly
  GachaponViewController *gvc = [[GachaponViewController alloc] init];
  gvc.view.frame = self.view.bounds;
  [self.navigationController pushViewController:gvc animated:YES];
}

- (IBAction)buildingsClicked:(id)sender {
  [self.navigationController pushViewController:[[CarpenterViewController alloc] init] animated:YES];
}

- (IBAction)labClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  if (gs.myLaboratory.isComplete) {
    [self.navigationController pushViewController:[[LabViewController alloc] init] animated:YES];
  } else {
    [Globals addAlertNotification:@"You must own a completed Laboratory before you can enter."];
  }
}

- (IBAction)enhanceClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  if (gs.myLaboratory.isComplete) {
    [self.navigationController pushViewController:[[EnhanceViewController alloc] init] animated:YES];
  } else {
    [Globals addAlertNotification:@"You must own a completed Laboratory before you can enter."];
  }
}

- (IBAction)evolveClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  if (gs.myEvoChamber.isComplete) {
    [self.navigationController pushViewController:[[EvoViewController alloc] init] animated:YES];
  } else {
    [Globals addAlertNotification:@"You must own a completed Laboratory before you can enter."];
  }
}

- (IBAction)clansClicked:(id)sender {
  [self.navigationController pushViewController:[[ClanViewController alloc] init] animated:YES];
}

- (IBAction)profileClicked:(id)sender {
  [self.navigationController pushViewController:[[MyCroniesViewController alloc] init] animated:YES];
}

- (IBAction)settingsClicked:(id)sender {
  OldSettingsViewController *svc = [[OldSettingsViewController alloc] init];
  [self.navigationController pushViewController:svc animated:YES];
}

@end
