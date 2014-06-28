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

@interface HomeViewController ()

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

#pragma mark - View loading

- (void) viewDidLoad {
  [super viewDidLoad];
  
  EvolveChooserViewController *vc1 = [[EvolveChooserViewController alloc] init];
  SellViewController *vc2 = [[SellViewController alloc] init];
  HealViewController *vc3 = [[HealViewController alloc] init];
  TeamViewController *vc4 = [[TeamViewController alloc] init];
  EnhanceChooserViewController *vc5 = [[EnhanceChooserViewController alloc] init];
  self.mainViewControllers = @[vc1, vc2, vc3, vc4, vc5];
  
  PopupSubViewController *vc = self.mainViewControllers[0];
  if (_initViewControllerClass) {
    for (PopupSubViewController *mvc in self.mainViewControllers) {
      if ([mvc isKindOfClass:_initViewControllerClass]) {
        vc = mvc;
      }
    }
  }
  _currentIndex = [self.mainViewControllers indexOfObject:vc];
  [self replaceRootWithViewController:vc fromRight:NO animated:NO];
  [self loadNextTitleSelectionFromRight:NO animated:NO];
  
  self.containerView.superview.layer.cornerRadius = 5.f;
  self.containerView.superview.clipsToBounds = YES;
}

- (IBAction)rightArrowClicked:(id)sender {
  _currentIndex = (_currentIndex+1)%self.mainViewControllers.count;
  PopupSubViewController *svc = self.mainViewControllers[_currentIndex];
  [self replaceRootWithViewController:svc fromRight:YES animated:YES];
  
  [self loadNextTitleSelectionFromRight:YES animated:YES];
}

- (IBAction)leftArrowClicked:(id)sender {
  // add the count so negative overlaps
  int count = self.mainViewControllers.count;
  _currentIndex = (_currentIndex-1+count)%count;
  PopupSubViewController *svc = self.mainViewControllers[_currentIndex];
  [self replaceRootWithViewController:svc fromRight:NO animated:YES];
  
  [self loadNextTitleSelectionFromRight:NO animated:YES];
}

- (void) loadNextTitleSelectionFromRight:(BOOL)fromRight animated:(BOOL)animated {
  UIView *oldView = self.homeTitleView;
  
  [[NSBundle mainBundle] loadNibNamed:@"HomeTitleView" owner:self options:nil];
  
  [self reloadTitleLabel];
  [self replaceTitleView:oldView withNewView:self.homeTitleView fromRight:fromRight animated:animated];
}

- (void) reloadTitleLabel {
  PopupSubViewController *svc = [self.viewControllers lastObject];
  if (svc.attributedTitle) {
    self.homeTitleLabel.attributedText = svc.attributedTitle;
    self.bigTitleLabel.attributedText = svc.attributedTitle;
  } else {
    self.homeTitleLabel.text = svc.title;
    self.bigTitleLabel.text = svc.title;
  }
}

@end
