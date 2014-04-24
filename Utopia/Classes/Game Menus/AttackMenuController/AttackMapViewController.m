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

#define NUM_CITIES 10

@implementation AttackMapViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self loadCities];
  self.mapScrollView.layer.cornerRadius = 8.f;
  
  [self.mapScrollView addSubview:self.mapView];
  self.mapScrollView.contentSize = CGSizeMake(self.mapScrollView.frame.size.width, self.mapView.frame.size.height);
  
  if ([Globals isLongiPhone]) {
    self.borderView.image = [Globals imageNamed:@"attackmapborderwide.png"];
    self.mapView.center = ccp(self.mapView.frame.size.width/2, self.mapView.frame.size.height/2);
  } else {
    self.borderView.image = [Globals imageNamed:@"attackmapborder.png"];
    self.mapView.center = ccp(self.mapScrollView.frame.size.width/2-22.f, self.mapView.frame.size.height/2);
    [self.eventView.monsterImage removeFromSuperview];
    self.eventView.monsterImage = nil;
  }
}

- (void) viewWillAppear:(BOOL)animated {
  [self.eventView updateForEvo];
  
  // In case we come from back button on gem view
  self.navigationController.navigationBarHidden = YES;
  
  [self.multiplayerView updateForLeague];
  
  GameState *gs = [GameState sharedGameState];
  if (![gs hasShownCurrentLeague]) {
    [self dropLeagueIcon];
    [gs currentLeagueWasShown];
  }
}

- (void) dropLeagueIcon {
  GameState *gs = [GameState sharedGameState];
  [self.multiplayerView addSubview:self.leaguePromotionView];
  [self.leaguePromotionView updateForOldLeagueId:[gs lastLeagueShown] newLeagueId:gs.pvpLeague.leagueId];
  [self.leaguePromotionView performSelector:@selector(dropLeagueIcon) withObject:nil afterDelay:1.f];
}

- (void) viewDidAppear:(BOOL)animated {
  self.timer = [NSTimer timerWithTimeInterval:1.f target:self.eventView selector:@selector(updateLabels) userInfo:Nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
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
    [self.delegate visitCityClicked:icon.cityNumber];
    [self close];
  }
}

- (IBAction)enterEventClicked:(UIButton *)sender {
  if (!_buttonClicked && [Globals checkEnteringDungeonWithTarget:self selector:@selector(visitTeamPage)]) {
    _buttonClicked = YES;
    [self.timer invalidate];
    [self.delegate enterDungeon:self.eventView.taskId isEvent:YES eventId:self.eventView.persistentEventId useGems:[sender tag]];
    [self performSelector:@selector(close:) withObject:nil afterDelay:0.1f];
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
  [self.delegate findPvpMatch:useGems];
  [self close:nil];
}

- (void) visitTeamPage {
  [self.navigationController pushViewController:[[MyCroniesViewController alloc] init] animated:YES];
  self.navigationController.navigationBarHidden = NO;
}

- (IBAction)close:(id)sender {
  [self close];
}

- (void) close {
  [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
