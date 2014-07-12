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
  
  GameState *gs = [GameState sharedGameState];
  if (gs.myLaboratory || gs.myEvoChamber) {
    NSString *nibFile = [Globals isLongiPhone] ? @"AttackEventView" : @"AttackEventViewSmall";
    [[NSBundle mainBundle] loadNibNamed:nibFile owner:self options:nil];
    
    [self.pveView addSubview:self.enhanceEventView];
    [self.pveView addSubview:self.evoEventView];
    
    self.enhanceEventView.center = ccp(self.enhanceEventView.frame.size.width/2, self.pveView.frame.size.height-self.enhanceEventView.frame.size.height/2);
    self.evoEventView.center = ccp(self.evoEventView.frame.size.width/2, self.pveView.frame.size.height-self.evoEventView.frame.size.height/2);
  }
  
  self.multiplayerView.center = ccp(-self.multiplayerView.frame.size.width*2/3, self.multiplayerView.center.y);
  self.pveView.center = ccp(self.view.frame.size.width+self.pveView.frame.size.width*2/3, self.pveView.center.y);
  [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
    self.multiplayerView.center = ccp(self.multiplayerView.frame.size.width/2, self.multiplayerView.center.y);
    self.pveView.center = ccp(self.view.frame.size.width-self.pveView.frame.size.width/2, self.pveView.center.y);
  } completion:nil];
}

- (void) viewWillAppear:(BOOL)animated {
  [self.evoEventView updateForEvo];
  [self.enhanceEventView updateForEnhance];
  if (self.evoEventView && !self.evoEventView.hidden) {
    [self.evoEventView.monsterImage startAnimating];
    _curEventView = self.evoEventView;
  } else if (self.enhanceEventView && !self.enhanceEventView.hidden) {
    [self.enhanceEventView.monsterImage startAnimating];
    _curEventView = self.enhanceEventView;
  }
  
  [self.multiplayerView updateForLeague];
  
  GameState *gs = [GameState sharedGameState];
  if (![gs hasShownCurrentLeague]) {
    // Took out the animation..
    [gs currentLeagueWasShown];
  }
  
  [self loadCities];
}

- (void) viewDidAppear:(BOOL)animated {
  self.timer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateLabels) userInfo:Nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void) updateLabels {
  [self.evoEventView updateLabels];
  [self.enhanceEventView updateLabels];
  
//  if (self.evoEventView.hidden && self.enhanceEventView.hidden) {
//    self.mapScrollView.contentSize = CGSizeMake(self.mapScrollView.frame.size.width, self.mapView.frame.size.height);
//  } else {
//    self.mapScrollView.contentSize = CGSizeMake(self.mapScrollView.frame.size.width, self.mapView.frame.size.height+self.evoEventView.bgdImage.frame.size.height);
//  }
}

- (void) viewDidDisappear:(BOOL)animated {
  [self.timer invalidate];
}

- (IBAction)close:(id)sender {
  if (!_buttonClicked) {
    [self close];
  }
}

- (void) close {
  [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
    self.multiplayerView.center = ccp(-self.multiplayerView.frame.size.width*2/3, self.multiplayerView.center.y);
    self.pveView.center = ccp(self.view.frame.size.width+self.pveView.frame.size.width*2/3, self.pveView.center.y);
  } completion:^(BOOL finished) {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

#pragma mark - PVE

- (void)loadCities {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  
  NSArray *svs = [self.mapScrollView.subviews copy];
  for (UIView *sv in svs) {
    [sv removeFromSuperview];
  }
  
  // Assemble map sections
  float scaleFactor = self.mapScrollView.frame.size.width/gl.mapTotalWidth;
  for (int i = 1; i <= gl.mapNumberOfSections; i++) {
    NSString *imgName = [NSString stringWithFormat:@"%@%d.png", gl.mapSectionImagePrefix, i];
    
    CGRect frame = CGRectZero;
    frame.size.width = self.mapScrollView.frame.size.width;
    frame.size.height = scaleFactor*gl.mapSectionHeight;
    frame.origin.y = gl.mapTotalHeight*scaleFactor-frame.size.height*i;
    
    // The last section might be smaller than the section height
    if (frame.origin.y < 0) {
      frame.size.height = frame.origin.y+frame.size.height;
      frame.origin.y = 0;
    }
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:frame];
    iv.contentMode = UIViewContentModeScaleToFill;
    [self.mapScrollView addSubview:iv];
    [Globals imageNamed:imgName withView:iv greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  }
  self.mapScrollView.contentSize = CGSizeMake(self.mapScrollView.frame.size.width, gl.mapTotalHeight*scaleFactor);
  
  for (TaskMapElementProto *elem in gs.staticMapElements) {
    FullTaskProto *task = [gs taskWithId:elem.taskId];
    AttackMapIconView *icon = [[NSBundle mainBundle] loadNibNamed:@"AttackMapIconView" owner:self options:nil][0];
    [icon setIsLocked:![gs isTaskUnlocked:elem.taskId] isBoss:elem.boss];
    icon.tag = elem.mapElementId;
    icon.nameLabel.text = [NSString stringWithFormat:@"%@ »", task.name];
    icon.cityNumLabel.text = [NSString stringWithFormat:@"%d", elem.mapElementId];
    icon.nameLabel.hidden = YES;
    
    [self.mapScrollView addSubview:icon];
    icon.center = ccpMult(ccp(elem.xPos, gl.mapTotalHeight-elem.yPos), scaleFactor);
    
    [icon.cityButton addTarget:self action:@selector(cityClicked:) forControlEvents:UIControlEventTouchUpInside];
  }
  
  [self centerOnAppropriateMapIcon];
}

- (void) centerOnAppropriateMapIcon {
  GameState *gs = [GameState sharedGameState];
  TaskMapElementProto *bestElem = nil;
  for (TaskMapElementProto *elem in gs.staticMapElements) {
    if ([gs isTaskUnlocked:elem.taskId]) {
      BOOL bestCompleted = [gs isTaskCompleted:bestElem.taskId];
      BOOL curCompleted = [gs isTaskCompleted:elem.taskId];
      
      if (bestCompleted != curCompleted) {
        // Choose non-completed one
        bestElem = bestCompleted ? elem : bestElem;
      } else {
        // Choose higher map elem id
        bestElem = bestElem.mapElementId > elem.mapElementId ? bestElem : elem;
      }
    }
  }
  
  if (bestElem) {
    AttackMapIconView *icon = (AttackMapIconView *)[self.mapScrollView viewWithTag:bestElem.mapElementId];
    float center = icon.center.y-self.mapScrollView.frame.size.height/3;
    float max = self.mapScrollView.contentSize.height-self.mapScrollView.frame.size.height;
    float min = 0;
    self.mapScrollView.contentOffset = ccp(0, clampf(center, min, max));
    
    if (!((self.evoEventView && !self.evoEventView.hidden) || (self.enhanceEventView && !self.enhanceEventView.hidden))) {
      [self cityClicked:icon];
    }
  } else {
    self.mapScrollView.contentOffset = ccp(0, self.mapScrollView.contentSize.height-self.mapScrollView.frame.size.height);
  }
}

- (void) cityClicked:(id)sender {
  while (sender && ![sender isKindOfClass:[AttackMapIconView class]]) {
    sender = [sender superview];
  }
  AttackMapIconView *icon = (AttackMapIconView *)sender;
  [self showTaskStatusForMapElement:(int)icon.tag];
  
  _selectedIcon.glowIcon.hidden = YES;
  _selectedIcon.nameLabel.hidden = YES;
  _selectedIcon = icon;
  if (!icon.isLocked) _selectedIcon.glowIcon.hidden = NO;
  _selectedIcon.nameLabel.hidden = NO;
  [_selectedIcon.superview bringSubviewToFront:_selectedIcon];
}

- (IBAction)enterDungeonClicked:(id)sender {
  if (!_buttonClicked && [Globals checkEnteringDungeon]) {
    [self.delegate enterDungeon:self.taskStatusView.taskId isEvent:NO eventId:0 useGems:NO];
  }
}

- (IBAction)enterEventClicked:(UIView *)sender {
  int tag = (int)sender.tag;
  while (sender && ![sender isKindOfClass:[AttackEventView class]]) {
    sender = [sender superview];
  }
  
  AttackEventView *eventView = (AttackEventView *)sender;
  if (!_buttonClicked && [Globals checkEnteringDungeon]) {
    _buttonClicked = YES;
    [self.timer invalidate];
    [self.delegate enterDungeon:eventView.taskId isEvent:YES eventId:eventView.persistentEventId useGems:tag];
  }
}

#pragma mark - PVP

- (IBAction)findMatchClicked:(id)sender {
  if (!_buttonClicked && [Globals checkEnteringDungeon]) {
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
  // GameViewController will close
  [self.delegate findPvpMatch:useGems];
}

#pragma mark - EventView and TaskStatusView

- (void) showTaskStatusForMapElement:(int)mapElementId {
  GameState *gs = [GameState sharedGameState];
  TaskMapElementProto *elem = [gs mapElementWithId:mapElementId];
  
  if (self.taskStatusView.taskId != elem.taskId) {
    UIView *oldTaskStatusView = self.taskStatusView;
    [[NSBundle mainBundle] loadNibNamed:@"AttackMapTaskStatusView" owner:self options:nil];
    [self.pveView addSubview:self.taskStatusView];
    [self.taskStatusView updateForTaskId:elem.taskId element:elem.element level:elem.mapElementId isLocked:![gs isTaskUnlocked:elem.taskId] isCompleted:[gs isTaskCompleted:elem.taskId]];
    self.taskStatusView.frame = CGRectMake(0, 0, self.pveView.frame.size.width, self.taskStatusView.frame.size.height);
    
    self.taskStatusView.center = ccp(self.taskStatusView.frame.size.width/2, self.pveView.frame.size.height+self.taskStatusView.frame.size.height/2);
    [UIView animateWithDuration:0.3f animations:^{
      NSMutableArray *arr = [NSMutableArray array];
      if (oldTaskStatusView) [arr addObject:oldTaskStatusView];
      if (self.evoEventView) [arr addObject:self.evoEventView];
      if (self.enhanceEventView) [arr addObject:self.enhanceEventView];
      
      for (UIView *v in arr) {
        v.center = ccp(v.frame.size.width/2, self.pveView.frame.size.height+v.frame.size.height/2);
      }
      
      self.taskStatusView.center = ccp(self.taskStatusView.frame.size.width/2, self.pveView.frame.size.height-self.taskStatusView.frame.size.height/2);
    } completion:^(BOOL finished) {
      [oldTaskStatusView removeFromSuperview];
    }];
  }
}

- (IBAction) removeTaskStatusView {
  if (self.taskStatusView && ((self.evoEventView && !self.evoEventView.hidden) || (self.enhanceEventView && !self.enhanceEventView.hidden)) ) {
    [UIView animateWithDuration:0.3f animations:^{
      NSMutableArray *arr = [NSMutableArray array];
      if (self.evoEventView) [arr addObject:self.evoEventView];
      if (self.enhanceEventView) [arr addObject:self.enhanceEventView];
      
      for (UIView *v in arr) {
        v.center = ccp(v.frame.size.width/2, self.pveView.frame.size.height-v.frame.size.height/2);
      }
      
      self.taskStatusView.center = ccp(self.taskStatusView.frame.size.width/2, self.pveView.frame.size.height+self.taskStatusView.frame.size.height/2);
    } completion:^(BOOL finished) {
      [self.taskStatusView removeFromSuperview];
      self.taskStatusView = nil;
    }];
    
    _selectedIcon.glowIcon.hidden = YES;
    _selectedIcon.nameLabel.hidden = YES;
    _selectedIcon = nil;
  }
}

- (void) eventViewSelected:(AttackEventView *)eventView {
  if (!_buttonClicked && _curEventView != eventView) {
    [eventView.superview bringSubviewToFront:eventView];
    [eventView.monsterImage startAnimating];
    
    [_curEventView.monsterImage stopAnimating];
    _curEventView = eventView;
  }
}

@end
