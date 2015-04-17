//
//  MainMenuViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/29/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ShopViewController.h"

#import "GameViewController.h"
#import "SettingsViewController.h"
#import "GameState.h"

#import "SalePackageViewController.h"

@implementation ShopViewController

- (id) init {
  if ((self = [super init])) {
    // Preload the sales view since it loads slow
    SalePackageViewController *svc = [[SalePackageViewController alloc] init];
    [svc view];
  }
  return self;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  self.buildingsBadge.badgeNum = [gl calculateNumberOfUnpurchasedStructs];
  
  self.gachasBadge.badgeNum = [gs hasDailyFreeSpin];
  for (BoosterPackProto *bpp in gs.boosterPacks) {
    self.gachasBadge.badgeNum += [gs numberOfFreeSpinsForBoosterPack:bpp.boosterPackId];
  }
  
  [self initializeSubViewControllers];
  
  self.tabBar.label3.text = [NSString stringWithFormat:@"%@S", MONSTER_NAME.uppercaseString];
  [Globals adjustViewForCentering:self.tabBar.label3.superview withLabel:self.tabBar.label3];
  
  if (!self.topViewController) {
    if (self.gachasBadge.badgeNum) {
      [self button3Clicked:nil];
    } else if (self.buildingsBadge.badgeNum) {
      [self button1Clicked:nil];
    } else {
      [self button3Clicked:nil];
    }
  }
  
  [[CCDirector sharedDirector] pause];
}

- (void) initializeSubViewControllers {
  self.buildingViewController = [[BuildingViewController alloc] init];
  self.fundsViewController = [[FundsViewController alloc] init];
  self.gachaViewController = [[GachaChooserViewController alloc] init];
  self.salesViewController = [[SalesViewController alloc] init];
  
  self.buildingViewController.delegate = [GameViewController baseController];
}

- (void) viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  // Do this to unload the controllers when shop goes down
  self.buildingViewController = nil;
  self.fundsViewController = nil;
  self.gachaViewController = nil;
  [self unloadAllControllers];
  
  [[CCDirector sharedDirector] resume];
}

- (BOOL) shouldStopCCDirector {
  return NO;
}

- (void) displayInParentViewController:(UIViewController *)gvc {
  self.view.frame = gvc.view.bounds;
  
  [self beginAppearanceTransition:YES animated:YES];
  
  [gvc addChildViewController:self];
  [gvc.view addSubview:self.view];
  
  self.bgdView.alpha = 0.f;
  self.mainView.center = ccp(self.mainView.frame.size.width/2, self.view.frame.size.height+self.mainView.frame.size.height/2);
  [UIView animateWithDuration:0.3f animations:^{
    self.bgdView.alpha = 1.f;
    self.mainView.center = ccp(self.mainView.frame.size.width/2, self.view.frame.size.height-self.mainView.frame.size.height/2);
  } completion:^(BOOL finished) {
    [self endAppearanceTransition];
  }];
}

- (void) openBuildingsShop {
  [self button1Clicked:nil];
}

- (void) openFundsShop {
  [self button2Clicked:nil];
}

- (void) openGachaShop {
  [self button3Clicked:nil];
}

- (void) close {
  [self beginAppearanceTransition:NO animated:YES];
  [UIView animateWithDuration:0.3f animations:^{
    self.bgdView.alpha = 0.f;
    self.mainView.center = ccp(self.mainView.frame.size.width/2, self.view.frame.size.height+self.mainView.frame.size.height/2);
  } completion:^(BOOL finished) {
    [self unloadAllControllers];
    
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
    [self endAppearanceTransition];
  }];
}

- (IBAction) settingsClicked:(id)sender {
  GameViewController *gvc = [GameViewController baseController];
  SettingsViewController *svc = [[SettingsViewController alloc] init];
  [svc displayInParentViewController:gvc];
}

#pragma mark - TabBar delegate

- (void) adjustContainerViewForSubViewController:(UIViewController *)uvc {
  self.containerView.originY = CGRectGetMaxY(self.containerView.frame)-uvc.view.height;
  self.containerView.height = uvc.view.height;
  
  if (self.containerView.originY < 45) {
    [self.delegate sendShopViewAboveCoinBars:self];
  } else {
    [self.delegate sendShopViewUnderCoinBars:self];
  }
}

- (void) replaceRootWithViewController:(PopupSubViewController *)viewController {
  [self adjustContainerViewForSubViewController:viewController];
  [super replaceRootWithViewController:viewController];
}

- (void) button1Clicked:(id)sender {
  [self replaceRootWithViewController:self.buildingViewController];
  
  [self.tabBar clickButton:1];
}

- (void) button2Clicked:(id)sender {
  [self replaceRootWithViewController:self.salesViewController];
  
  [self.tabBar clickButton:2];
}

- (void) button3Clicked:(id)sender {
  [self replaceRootWithViewController:self.gachaViewController];
  
  [self.tabBar clickButton:3];
}

@end
