//
//  HomeViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/20/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "HomeViewController.h"
#import "GameState.h"

#import "SellViewController.h"
#import "EnhanceChooserViewController.h"
#import "EvolveChooserViewController.h"
#import "HealViewController.h"
#import "TeamViewController.h"
#import "MiniJobsListViewController.h"

@implementation HomeTitleView

@end

@implementation HomeViewController

- (id) initWithSell {
  if ((self = [super init])) {
    _initViewControllerClass = [SellViewController class];
  }
  return self;
}

- (id) initWithHeal {
  if ((self = [super init])) {
    _initViewControllerClass = [HealViewController class];
  }
  return self;
}

- (id) initWithTeam {
  if ((self = [super init])) {
    _initViewControllerClass = [TeamViewController class];
  }
  return self;
}

- (id) initWithEnhance {
  if ((self = [super init])) {
    _initViewControllerClass = [EnhanceChooserViewController class];
  }
  return self;
}

- (id) initWithEvolve {
  if ((self = [super init])) {
    _initViewControllerClass = [EvolveChooserViewController class];
  }
  return self;
}

- (id) initWithMiniJobs {
  if ((self = [super init])) {
    _initViewControllerClass = [MiniJobsListViewController class];
  }
  return self;
}

#pragma mark - View loading

- (void) viewDidLoad {
  [super viewDidLoad];
  
  [self loadMainViewControllers];
  
  PopupSubViewController *vc = self.mainViewControllers[0];
  if (_initViewControllerClass) {
    for (PopupSubViewController *mvc in self.mainViewControllers) {
      if ([mvc isKindOfClass:_initViewControllerClass]) {
        vc = mvc;
      }
    }
  }
  _currentIndex = (int)[self.mainViewControllers indexOfObject:vc];
  [self replaceRootWithViewController:vc fromRight:NO animated:NO];
  
  self.containerView.superview.layer.cornerRadius = 5.f;
  self.containerView.superview.clipsToBounds = YES;
}

- (void) loadMainViewControllers {
  SellViewController *sell = [[SellViewController alloc] init];
  HealViewController *heal = [[HealViewController alloc] init];
  TeamViewController *team = [[TeamViewController alloc] init];
  EvolveChooserViewController *evo = [[EvolveChooserViewController alloc] init];
  EnhanceChooserViewController *enhance = [[EnhanceChooserViewController alloc] init];
  MiniJobsListViewController *miniJobs = [[MiniJobsListViewController alloc] init];
  
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *arr = [@[heal, team, sell] mutableCopy];
  if ([Globals shouldShowFatKidDungeon]) [arr addObject:enhance];
  if (gs.myEvoChamber.isComplete) [arr addObject:evo];
  if (gs.myMiniJobCenter.isComplete && gs.myMiniJobCenter.staticStruct.structInfo.level > 0) [arr addObject:miniJobs];
  self.mainViewControllers = arr;
}

- (IBAction)rightArrowClicked:(id)sender {
  _currentIndex = (_currentIndex+1)%self.mainViewControllers.count;
  PopupSubViewController *svc = self.mainViewControllers[_currentIndex];
  [self replaceRootWithViewController:svc fromRight:YES animated:YES];
}

- (IBAction)leftArrowClicked:(id)sender {
  // add the count so negative overlaps
  int count = (int)self.mainViewControllers.count;
  _currentIndex = (_currentIndex-1+count)%count;
  PopupSubViewController *svc = self.mainViewControllers[_currentIndex];
  [self replaceRootWithViewController:svc fromRight:NO animated:YES];
}

- (void) loadNextTitleSelectionFromRight:(BOOL)fromRight animated:(BOOL)animated {
  UIView *oldHomeView = self.curHomeTitleView;
  UIView *oldTitleView = self.curTitleView;
  
  PopupSubViewController *svc = [self.viewControllers lastObject];
  if (svc.titleImageName) {
    self.curHomeTitleView = [[NSBundle mainBundle] loadNibNamed:@"HomeTitleView" owner:self options:nil][0];
    self.curTitleLabel = self.curHomeTitleView.titleLabel;
    [Globals imageNamed:svc.titleImageName withView:self.curHomeTitleView.titleImageView greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
    
    self.curTitleView = self.selectorView;
  } else {
    self.curTitleLabel = [[NSBundle mainBundle] loadNibNamed:@"HomeTitleLabel" owner:self options:nil][0];
    self.curTitleView = self.curTitleLabel;
  }
  
  [self reloadTitleLabel];
  
  if (oldTitleView == self.selectorView && self.curTitleView == self.selectorView) {
    [self replaceTitleView:oldHomeView withNewView:self.curHomeTitleView fromRight:fromRight animated:animated];
  } else {
    // replace without animation
    if (self.curHomeTitleView != oldHomeView) {
      [self replaceTitleView:oldHomeView withNewView:self.curHomeTitleView fromRight:fromRight animated:NO];
    }
    
    [self replaceTitleView:oldTitleView withNewView:self.curTitleView fromRight:fromRight animated:animated];
  }
}

@end
