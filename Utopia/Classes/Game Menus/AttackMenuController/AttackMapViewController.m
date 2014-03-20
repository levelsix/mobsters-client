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

@implementation AttackMapIconView

- (void)setIsLocked:(BOOL)isLocked {
  _isLocked = isLocked;
  if (isLocked) {
    [self.cityButton setImage:[UIImage imageNamed:@"closedcity.png"] forState:UIControlStateNormal];
  }
  else {
    [self.cityButton setImage:[UIImage imageNamed:@"opencity.png"] forState:UIControlStateNormal];
  }
}

- (void) doShake {
  [Globals shakeView:self.cityNameIcon duration:0.5f offset:5.f];
}

@end

@implementation AttackEventView

- (void) updateForEvo {
  GameState *gs = [GameState sharedGameState];
  _eventType = PersistentEventProto_EventTypeEvolution;
  PersistentEventProto *pe = [gs currentPersistentEventWithType:PersistentEventProto_EventTypeEvolution];
  [self updateForPersistentEvent:pe];
  [self.tabBar clickButton:kButton1];
}

- (void) updateForEnhance {
  GameState *gs = [GameState sharedGameState];
  _eventType = PersistentEventProto_EventTypeEnhance;
  PersistentEventProto *pe = [gs currentPersistentEventWithType:PersistentEventProto_EventTypeEnhance];
  [self updateForPersistentEvent:pe];
  [self.tabBar clickButton:kButton2];
}

- (void) updateForPersistentEvent:(PersistentEventProto *)pe {
  GameState *gs = [GameState sharedGameState];
  
  NSMutableArray *imgs = [NSMutableArray array];
  if (pe.type == PersistentEventProto_EventTypeEvolution) {
    for (int i = 0; i <= 12; i++) {
      NSString *str = [NSString stringWithFormat:@"Scientist%dBreath%02d.png", pe.monsterElement, i];
      UIImage *img = [Globals imageNamed:str];
      [imgs addObject:img];
    }
    for (int i = 0; i <= 12; i++) {
      NSString *str = [NSString stringWithFormat:@"Scientist%dBreath%02d.png", pe.monsterElement, i];
      UIImage *img = [Globals imageNamed:str];
      [imgs addObject:img];
    }
    for (int i = 0; i <= 12; i++) {
      NSString *str = [NSString stringWithFormat:@"Scientist%dBlink%02d.png", pe.monsterElement, i];
      UIImage *img = [Globals imageNamed:str];
      [imgs addObject:img];
    }
    for (int i = 0; i <= 12; i++) {
      NSString *str = [NSString stringWithFormat:@"Scientist%dBreath%02d.png", pe.monsterElement, i];
      UIImage *img = [Globals imageNamed:str];
      [imgs addObject:img];
    }
    for (int i = 0; i <= 12; i++) {
      NSString *str = [NSString stringWithFormat:@"Scientist%dBreath%02d.png", pe.monsterElement, i];
      UIImage *img = [Globals imageNamed:str];
      [imgs addObject:img];
    }
    for (int i = 0; i <= 16; i++) {
      NSString *str = [NSString stringWithFormat:@"Scientist%dTurn%02d.png", pe.monsterElement, i];
      UIImage *img = [Globals imageNamed:str];
      [imgs addObject:img];
    }
  } else if (pe.type == PersistentEventProto_EventTypeEnhance) {
    for (int i = 0; i <= 12; i++) {
      NSString *str = [NSString stringWithFormat:@"FatBoy%dMove%02d.png", pe.monsterElement, i];
      UIImage *img = [Globals imageNamed:str];
      [imgs addObject:img];
    }
  }
  
  self.monsterImage.animationImages = imgs;
  
  self.monsterImage.animationDuration = imgs.count*0.1;
  [self.monsterImage startAnimating];
  
  if (pe) {
    FullTaskProto *task = [gs taskWithId:pe.taskId];
    
    self.topRibbonLabel.text = pe.type == PersistentEventProto_EventTypeEnhance ? @"FEEDER" : @"DAILY";
    self.botRibbonLabel.text = pe.type == PersistentEventProto_EventTypeEvolution ? @"event now!" : @"laboratory";
    
    NSString *file = [Globals imageNameForElement:pe.monsterElement suffix:@"banner.png"];
    self.bgdImage.image = [Globals imageNamed:file];
    file = [Globals imageNameForElement:pe.monsterElement suffix:@"dailylab.png"];
    self.ribbonImage.image = [Globals imageNamed:file];
    
    self.nameLabel.text = task.name;
    
    _persistentEventId = pe.eventId;
    self.taskId = pe.taskId;
    
    self.mainView.hidden = NO;
    self.noEventView.hidden = YES;
    self.monsterImage.hidden = NO;
  } else {
    _persistentEventId = 0;
    self.taskId = 0;
    
    self.mainView.hidden = YES;
    self.noEventView.hidden = NO;
    self.monsterImage.hidden = YES;
  }
  [self updateLabels];
}

- (void) updateLabels {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  PersistentEventProto *pe = [gs currentPersistentEventWithType:_eventType];
  
  if (_persistentEventId != pe.eventId) {
    [self updateForPersistentEvent:pe];
  } else {
    int timeLeft = [pe.endTime timeIntervalSinceNow];
    self.timeLeftLabel.text = [NSString stringWithFormat:@"Time Left: %@", [Globals convertTimeToShortString:timeLeft]];
    
    NSDate *cdTime = pe.cooldownEndTime;
    timeLeft = [cdTime timeIntervalSinceNow];
    if (timeLeft <= 0) {
      self.enterView.hidden = NO;
      self.cooldownView.hidden = YES;
    } else {
      self.cooldownLabel.text = [NSString stringWithFormat:@"Opens In: %@", [Globals convertTimeToShortString:timeLeft]];
      int speedupCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
      self.speedupGemsLabel.text = [Globals commafyNumber:speedupCost];
      
      self.enterView.hidden = YES;
      self.cooldownView.hidden = NO;
    }
  }
}

- (void) button1Clicked:(id)sender {
  [self updateForEvo];
}

- (void) button2Clicked:(id)sender {
  [self updateForEnhance];
}

@end

@implementation AttackMapIconViewContainer

- (void)awakeFromNib {
  self.backgroundColor = [UIColor clearColor];
  [[NSBundle mainBundle] loadNibNamed:@"AttackMapIconView" owner:self options:nil];
  [self addSubview:self.iconView];
}

@end

@implementation MultiplayerView

- (void) awakeFromNib {
  Globals *gl = [Globals sharedGlobals];
  self.multiplayerUnlockLabel.superview.layer.cornerRadius = 5.f;
  self.multiplayerUnlockLabel.text = [NSString stringWithFormat:@"Multiplayer play\n unlocks at level %d", gl.pvpRequiredMinLvl];
  
  GameState *gs = [GameState sharedGameState];
  TownHallProto *thp = (TownHallProto *)gs.myTownHall.staticStruct;
  self.cashCostLabel.text = [NSString stringWithFormat:@"Match Cost: %@", [Globals cashStringForNumber:thp.pvpQueueCashCost]];
}

@end

@implementation AttackMapViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self loadCities];
  self.mapScrollView.layer.cornerRadius = 5.f;
  
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
  
  GameState *gs = [GameState sharedGameState];
  [gs currentPersistentEventWithType:PersistentEventProto_EventTypeEnhance];
}

- (void) viewWillAppear:(BOOL)animated {
  [self.eventView updateForEvo];
  
  // In case we come from back button on gem view
  self.navigationController.navigationBarHidden = YES;
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
    TownHallProto *thp = (TownHallProto *)gs.myTownHall.staticStruct;
    if (gs.silver < thp.pvpQueueCashCost) {
      [GenericPopupController displayExchangeForGemsViewWithResourceType:ResourceTypeCash amount:thp.pvpQueueCashCost-gs.silver target:self selector:@selector(nextMatchUseGems)];
    } else {
      [self nextMatch:NO];
    }
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
