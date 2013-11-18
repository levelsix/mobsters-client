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
#import "EnhanceViewController.h"
#import "DiamondShopViewController.h"
#import "SettingsViewController.h"
#import "CarpenterViewController.h"
#import "MyCroniesViewController.h"
#import "GachaponListViewController.h"

@interface MainMenuController ()

@end

@implementation MainMenuController

- (id)init
{
    if ((self = [super init])) {
      self.title = @"Menu";
      
      [self setUpImageBackButton];
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
  // Set up settings button with close button
  [self loadCustomNavBarButtons];
  UIBarButtonItem *rightButton1 = [[UIBarButtonItem alloc] initWithCustomView:self.menuCloseButton];
  UIBarButtonItem *rightButton2 = [[UIBarButtonItem alloc] initWithCustomView:self.menuSettingsButton];
  self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:rightButton1, rightButton2, nil];
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
  [self.navigationController pushViewController:[[EnhanceViewController alloc] init] animated:YES];
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
