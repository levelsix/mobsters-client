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
#import "SettingsViewController.h"
#import "CarpenterViewController.h"
#import "MyCroniesViewController.h"
#import "GachaponListViewController.h"
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
    [[self.labButtonView viewWithTag:5] removeFromSuperview];
    UIImage *img = [Globals greyScaleImageWithBaseImage:[Globals snapShotView:self.labButtonView]];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    imgView.tag = 5;
    [self.labButtonView insertSubview:imgView belowSubview:self.labButton];
  }
}

- (IBAction)fundsClicked:(id)sender {
  [self.navigationController pushViewController:[[DiamondShopViewController alloc] init] animated:YES];
}

- (IBAction)cratesClicked:(id)sender {
  [self.navigationController pushViewController:[[GachaponListViewController alloc] init] animated:YES];
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

- (IBAction)clansClicked:(id)sender {
  [self.navigationController pushViewController:[[ClanViewController alloc] init] animated:YES];
}

- (IBAction)profileClicked:(id)sender {
  [self.navigationController pushViewController:[[MyCroniesViewController alloc] init] animated:YES];
}

- (IBAction)settingsClicked:(id)sender {
  SettingsViewController *svc = [[SettingsViewController alloc] init];
  [self.navigationController pushViewController:svc animated:YES];
}

@end
