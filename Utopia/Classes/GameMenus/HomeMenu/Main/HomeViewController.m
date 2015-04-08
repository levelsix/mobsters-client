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
#import "EnhanceQueueViewController.h"
#import "EvolveChooserViewController.h"
#import "HealViewController.h"
#import "TeamViewController.h"
#import "MiniJobsListViewController.h"
#import "ItemFactoryViewController.h"
#import "ResearchViewController.h"

@implementation HomeTitleView

@end

@implementation HomeViewController

- (id) initWithSell {
  if ((self = [super init])) {
    _initViewControllerClass = [SellViewController class];
  }
  return self;
}

- (id) initWithHeal:(NSString *)hospitalUserStructUuid {
  if ((self = [super init])) {
    _initViewControllerClass = [HealViewController class];
    _initHospitalUserStructUuid = hospitalUserStructUuid;
  }
  return self;
}

- (id) initWithTeamShowRequestArrow:(BOOL)showArrow {
  if ((self = [super init])) {
    _initViewControllerClass = [TeamViewController class];
    _showArrowOnRequestToon = showArrow;
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

- (id) initWithBattleItemFactory {
  if ((self = [super init])) {
    _initViewControllerClass = [ItemFactoryViewController class];
  }
  return self;
}

- (id) initWithResearchLab {
  if((self = [super init])) {
    _initViewControllerClass = [ResearchViewController class];
  }
  return self;
}

#pragma mark - View loading

- (void) viewDidLoad {
  [super viewDidLoad];
  
  // Basically if this doesn't have an _initViewControllerClass assume its going to just be used a generic nav
  if (_initViewControllerClass) {
    [self loadMainViewControllers];
  }
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadEnhanceViewController) name:ENHANCE_MONSTER_NOTIFICATION object:nil];
  [self reloadEnhanceViewController];
  
  PopupSubViewController *vc = [self.mainViewControllers firstObject];
  if (_initViewControllerClass) {
    for (PopupSubViewController *mvc in self.mainViewControllers) {
      if ([mvc isKindOfClass:_initViewControllerClass]) {
        vc = mvc;
      }
    }
  }
  
  if (vc) {
    _currentIndex = (int)[self.mainViewControllers indexOfObject:vc];
    [self replaceRootWithViewController:vc fromRight:NO animated:NO];
  }
  
  self.containerView.superview.layer.cornerRadius = 5.f;
  self.containerView.superview.clipsToBounds = YES;
}

- (void) loadMainViewControllers {
  SellViewController *sell = [[SellViewController alloc] init];
  HealViewController *heal = [[HealViewController alloc] initWithUserStructUuid:_initHospitalUserStructUuid];
  TeamViewController *team = [[TeamViewController alloc] initShowArrowOnRequestToon:_showArrowOnRequestToon];
  EvolveChooserViewController *evo = [[EvolveChooserViewController alloc] init];
  EnhanceChooserViewController *enhance = [[EnhanceChooserViewController alloc] init];
  MiniJobsListViewController *miniJobs = [[MiniJobsListViewController alloc] init];
  ItemFactoryViewController *itemFactory = [[ItemFactoryViewController alloc] init];
  ResearchViewController *research = [[ResearchViewController alloc] init];
  
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *arr = [@[team, sell] mutableCopy];
  if (true || gs.myValidHospitals.count) [arr insertObject:heal atIndex:0];
  if ((gs.myLaboratory.isComplete && gs.myLaboratory.staticStruct.structInfo.level > 0) || gs.myLaboratory.staticStruct.structInfo.level > 1) [arr addObject:enhance];
  if (gs.myEvoChamber.isComplete || gs.myEvoChamber.staticStruct.structInfo.level > 1) [arr addObject:evo];
  if ((gs.myMiniJobCenter.isComplete && gs.myMiniJobCenter.staticStruct.structInfo.level > 0) || gs.myMiniJobCenter.staticStruct.structInfo.level > 1) [arr addObject:miniJobs];
  if (gs.myBattleItemFactory.isComplete || gs.myBattleItemFactory.staticStruct.structInfo.level > 1) [arr addObject:itemFactory];
  if (gs.myResearchLab.isComplete || gs.myResearchLab.staticStruct.structInfo.level > 1) [arr addObject:research];
  self.mainViewControllers = arr;
}

- (void) reloadEnhanceViewController {
  NSInteger mainIdx = NSNotFound;
  BOOL chooserIsMain = YES;
  
  EnhanceChooserViewController *ecvc = nil;
  EnhanceQueueViewController *eqvc = nil;
  for (id vc in self.mainViewControllers) {
    if ([vc isKindOfClass:[EnhanceChooserViewController class]]) {
      ecvc = vc;
      chooserIsMain = YES;
      mainIdx = [self.mainViewControllers indexOfObject:vc];
    } else if ([vc isKindOfClass:[EnhanceQueueViewController class]]) {
      eqvc = vc;
      chooserIsMain = NO;
      mainIdx = [self.mainViewControllers indexOfObject:vc];
    }
  }
  
  // Make sure they exist. If they don't that means its not unlocked so return.
  if (mainIdx != NSNotFound) {
    // Also, check if queue is in cur vcs
    id vc = [self.viewControllers lastObject];
    if ([vc isKindOfClass:[EnhanceQueueViewController class]]) {
      eqvc = vc;
    }
    
    GameState *gs = [GameState sharedGameState];
    BOOL chooserShouldBeMain = gs.userEnhancement == nil;
    
    if (chooserIsMain != chooserShouldBeMain) {
      
      if (!chooserShouldBeMain) {
        // Replace chooser
        BOOL shouldDisplay = eqvc != nil || [vc isKindOfClass:[EnhanceChooserViewController class]];
        if (!eqvc) {
          eqvc = [[EnhanceQueueViewController alloc] initWithCurrentEnhancement];
        }
        
        [self.mainViewControllers replaceObjectAtIndex:mainIdx withObject:eqvc];
        
        if (shouldDisplay) {
          [self replaceRootWithViewController:eqvc fromRight:NO animated:YES];
        }
        
        if (_initViewControllerClass == [EnhanceChooserViewController class]) {
          _initViewControllerClass = [EnhanceQueueViewController class];
        }
      }
      
      else {
        // Replace queue
        BOOL shouldDisplay = eqvc == [self.viewControllers lastObject];
        
        if (!ecvc) {
          ecvc = [[EnhanceChooserViewController alloc] init];
        }
        
        [self.mainViewControllers replaceObjectAtIndex:mainIdx withObject:ecvc];
        
        if (shouldDisplay) {
          [self.viewControllers insertObject:ecvc atIndex:0];
          [self addChildViewController:ecvc];
          
          [self pushViewController:eqvc animated:YES];
        }
      }
    }
  }
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
  if (svc.titleImageName && self.viewControllers.count == 1) {
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

- (void) close {
  [super close];
  [self.delegate homeViewControllerClosed];
}

@end
