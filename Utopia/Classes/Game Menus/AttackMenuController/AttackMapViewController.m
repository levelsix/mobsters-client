//
//  AttackMapViewController.m
//  Utopia
//
//  Created by Danny on 10/8/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "AttackMapViewController.h"
#import "Globals.h"
#import "GameState.h"
#import "GameViewController.h"
#import "PersistentEventProto+Time.h"
#import "MenuNavigationController.h"
#import "MyCroniesViewController.h"
#import "GenericPopupController.h"
#import "AchievementUtil.h"
#import "CAKeyframeAnimation+AHEasing.h"

#define NUM_CITIES 10

@implementation AttackMapViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self loadCities];
  
  [self.mapScrollView addSubview:self.mapView];
  if (![Globals isLongiPhone]) {
    self.mapView.center = ccp(self.mapScrollView.frame.size.width/2-22.f, self.mapView.frame.size.height/2);
  }
  
  GameState *gs = [GameState sharedGameState];
  if (gs.myLaboratory) {
    NSString *nibFile = [Globals isLongiPhone] ? @"AttackEventView" : @"AttackEventViewSmall";
    [[NSBundle mainBundle] loadNibNamed:nibFile owner:self options:nil];
    
    [self.pveView addSubview:self.enhanceEventView];
    [self.pveView addSubview:self.evoEventView];
    
    self.enhanceEventView.center = ccp(self.enhanceEventView.frame.size.width/2, self.pveView.frame.size.height-self.enhanceEventView.frame.size.height/2);
    self.evoEventView.center = ccp(self.evoEventView.frame.size.width/2, self.pveView.frame.size.height-self.evoEventView.frame.size.height/2);
  }
  
  self.multiplayerView.center = ccp(-self.multiplayerView.frame.size.width/2, self.multiplayerView.center.y);
  self.pveView.center = ccp(self.view.frame.size.width+self.pveView.frame.size.width, self.pveView.center.y);
  [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
    self.multiplayerView.center = ccp(self.multiplayerView.frame.size.width/2, self.multiplayerView.center.y);
    self.pveView.center = ccp(self.view.frame.size.width-self.pveView.frame.size.width/2, self.pveView.center.y);
  } completion:nil];
}

- (void) viewWillAppear:(BOOL)animated {
  [self.evoEventView updateForEvo];
  [self.enhanceEventView updateForEnhance];
  if (!self.evoEventView.hidden) {
    [self.evoEventView.monsterImage startAnimating];
    _curEventView = self.evoEventView;
  } else if (!self.enhanceEventView) {
    [self.enhanceEventView.monsterImage startAnimating];
    _curEventView = self.enhanceEventView;
  }
  
  [self.multiplayerView updateForLeague];
  
  GameState *gs = [GameState sharedGameState];
  if (![gs hasShownCurrentLeague]) {
    [self dropLeagueIcon];
    [gs currentLeagueWasShown];
  }
  
//    CAKeyframeAnimation *kf = [CAKeyframeAnimation animationWithKeyPath:@"position" function:BounceEaseOut
//                                                              fromPoint:ccp(-self.multiplayerView.frame.size.width/2, self.multiplayerView.center.y)
//                                                                toPoint:ccp(self.multiplayerView.frame.size.width/2, self.multiplayerView.center.y) keyframeCount:150];
//    kf.duration = 1.6f;
//    kf.delegate = self;
//    [self.multiplayerView.layer addAnimation:kf forKey:@"bounce"];
//    
//    kf = [CAKeyframeAnimation animationWithKeyPath:@"position" function:BounceEaseOut
//                                         fromPoint:ccp(self.view.frame.size.width+self.pveView.frame.size.width/2, self.pveView.center.y)
//                                           toPoint:ccp(self.view.frame.size.width-self.pveView.frame.size.width/2, self.pveView.center.y) keyframeCount:150];
//    kf.duration = 1.6f;
//    kf.delegate = self;
//    [self.pveView.layer addAnimation:kf forKey:@"bounce"];
}

- (void) dropLeagueIcon {
  GameState *gs = [GameState sharedGameState];
  [self.multiplayerView addSubview:self.leaguePromotionView];
  [self.leaguePromotionView updateForOldLeagueId:[gs lastLeagueShown] newLeagueId:gs.pvpLeague.leagueId];
  [self.leaguePromotionView performSelector:@selector(dropLeagueIcon) withObject:nil afterDelay:1.f];
}

- (void) viewDidAppear:(BOOL)animated {
  self.timer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateLabels) userInfo:Nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void) updateLabels {
  [self.evoEventView updateLabels];
  [self.enhanceEventView updateLabels];
  
  if (self.evoEventView.hidden && self.enhanceEventView.hidden) {
    self.mapScrollView.contentSize = CGSizeMake(self.mapScrollView.frame.size.width, self.mapView.frame.size.height);
  } else {
    self.mapScrollView.contentSize = CGSizeMake(self.mapScrollView.frame.size.width, self.mapView.frame.size.height+self.evoEventView.bgdImage.frame.size.height);
  }
}

- (void) viewDidDisappear:(BOOL)animated {
  [self.timer invalidate];
}

- (BOOL) prefersStatusBarHidden {
  return YES;
}

- (void)loadCities {
  GameState *gs = [GameState sharedGameState];
  for (int i = 1; i <= NUM_CITIES;i++) {
    FullCityProto *fcp = [gs cityWithId:i];
    AttackMapIconViewContainer *amvc = (AttackMapIconViewContainer *)[self.mapView viewWithTag:i];
    amvc.iconView.fcp = fcp;
    amvc.iconView.isLocked = ![gs isCityUnlocked:i];
    amvc.iconView.cityNumber = i;
    amvc.iconView.nameLabel.text = [NSString stringWithFormat:@"%@ »", fcp.name];
    [Globals imageNamed:fcp.attackMapLabelImgName withView:amvc.iconView.cityNameIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    [amvc.iconView.cityButton addTarget:self action:@selector(cityClicked:) forControlEvents:UIControlEventTouchUpInside];
  }
}

- (IBAction)cityClicked:(id)sender {
  while (sender && ![sender isKindOfClass:[AttackMapIconView class]]) {
    sender = [sender superview];
  }
  AttackMapIconView *icon = (AttackMapIconView *)sender;
  
  if (icon.isLocked) {
    [icon doShake];
  } else if (!_buttonClicked) {
    _buttonClicked = YES;
    [self.delegate visitCityClicked:icon.cityNumber attackMapViewController:self];
    
    icon.cityButton.hidden = YES;
    icon.cityNumLabel.hidden = YES;
    icon.shadowIcon.hidden = YES;
    icon.spinner.hidden = NO;
    [icon.spinner startAnimating];
  }
}

- (IBAction)enterEventClicked:(UIView *)sender {
  int tag = (int)sender.tag;
  while (sender && ![sender isKindOfClass:[AttackEventView class]]) {
    sender = [sender superview];
  }
  
  AttackEventView *eventView = (AttackEventView *)sender;
  if (!_buttonClicked && [Globals checkEnteringDungeonWithTarget:self selector:@selector(visitTeamPage)]) {
    _buttonClicked = YES;
    [self.timer invalidate];
    [self.delegate enterDungeon:eventView.taskId isEvent:YES eventId:eventView.persistentEventId useGems:tag];
  }
}

- (IBAction)findMatchClicked:(id)sender {
  if (!_buttonClicked && [Globals checkEnteringDungeonWithTarget:self selector:@selector(visitTeamPage)]) {
    GameState *gs = [GameState sharedGameState];
    if (gs.hasActiveShield) {
      NSString *desc = @"Attacking will disable your shield, and other players will be able to attack you. Are you sure?";
      [GenericPopupController displayNegativeConfirmationWithDescription:desc title:@"Shield is active" okayButton:@"Attack" cancelButton:@"Cancel" okTarget:self okSelector:@selector(findMatch) cancelTarget:nil cancelSelector:nil];
    } else {
      [self findMatch];
    }
  }
}

- (IBAction) leaguePromotionOkayClicked:(id)sender {
  [UIView animateWithDuration:0.3f animations:^{
    self.leaguePromotionView.alpha = 0.f;
  } completion:^(BOOL finished) {
    [self.leaguePromotionView removeFromSuperview];
  }];
}

- (void) findMatch {
  GameState *gs = [GameState sharedGameState];
  TownHallProto *thp = (TownHallProto *)gs.myTownHall.staticStruct;
  if (gs.silver < thp.pvpQueueCashCost) {
    [GenericPopupController displayExchangeForGemsViewWithResourceType:ResourceTypeCash amount:thp.pvpQueueCashCost-gs.silver target:self selector:@selector(nextMatchUseGems)];
  } else {
    [self nextMatch:NO];
  }
}

- (void) nextMatchUseGems {
  if (!_buttonClicked) {
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    TownHallProto *thp = (TownHallProto *)gs.myTownHall.staticStruct;
    int cost = thp.pvpQueueCashCost;
    int curAmount = gs.silver;
    int gemCost = [gl calculateGemConversionForResourceType:ResourceTypeCash amount:cost-curAmount];
    
    if (gemCost > gs.gold) {
      [GenericPopupController displayNotEnoughGemsView];
    } else {
      _buttonClicked = YES;
      [self nextMatch:YES];
    }
  }
}

- (void) nextMatch:(BOOL)useGems {
  // GameViewController will close
  [self.delegate findPvpMatch:useGems];
}

- (void) visitTeamPage {
  MenuNavigationController *mnc = [[MenuNavigationController alloc] init];
  [mnc pushViewController:[[MyCroniesViewController alloc] init] animated:YES];
  [self presentViewController:mnc animated:YES completion:nil];
}

- (IBAction)close:(id)sender {
  if (!_buttonClicked) {
    [self close];
  }
}

- (void) close {
  [UIView animateWithDuration:0.75f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
    self.multiplayerView.center = ccp(-self.multiplayerView.frame.size.width/2, self.multiplayerView.center.y);
    self.pveView.center = ccp(self.view.frame.size.width+self.pveView.frame.size.width/2, self.pveView.center.y);
  } completion:^(BOOL finished) {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

#pragma mark - Event View Delegate

- (void) eventViewSelected:(AttackEventView *)eventView {
  if (!_buttonClicked && _curEventView != eventView) {
    [eventView.superview bringSubviewToFront:eventView];
    [eventView.monsterImage startAnimating];
    
    [_curEventView.monsterImage stopAnimating];
    _curEventView = eventView;
  }
}

@end
