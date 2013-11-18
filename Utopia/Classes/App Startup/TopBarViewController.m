//
//  TopBarViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/14/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "TopBarViewController.h"
#import "cocos2d.h"
#import "MainMenuController.h"
#import "Globals.h"
#import "GameViewController.h"
#import "MenuNavigationController.h"
#import "DiamondShopViewController.h"
#import "AttackMapViewController.h"
#import "GameState.h"
#import "ProfileViewController.h"
#import "QuestLogViewController.h"
#import "MyCroniesViewController.h"
#import "RequestsViewController.h"
#import "DialogueViewController.h"

@implementation SplitImageProgressBar

- (void) setPercentage:(float)percentage {
  _percentage = clampf(percentage, 0.f, 1.f);
  
  float totalWidth = _percentage*self.frame.size.width;
  
  CGRect r = self.leftCap.frame;
  r.size.width = MIN(ceilf(totalWidth/2), self.leftCap.image.size.width);
  self.leftCap.frame = r;
  
  r = self.rightCap.frame;
  r.size.width = self.leftCap.frame.size.width;
  if (totalWidth >= self.leftCap.image.size.width*2) {
    r.origin.x = totalWidth-r.size.width;
  } else {
    r.origin.x = CGRectGetMaxX(self.leftCap.frame);
  }
  self.rightCap.frame = r;
  
  r = self.middleBar.frame;
  r.origin.x = CGRectGetMaxX(self.leftCap.frame)-1;
  if (totalWidth >= self.leftCap.image.size.width*2) {
    r.size.width = self.rightCap.frame.origin.x-r.origin.x+2;
  } else {
    r.size.width = 0;
  }
  self.middleBar.frame = r;
}

@end

@implementation TopBarMonsterView

- (void) awakeFromNib {
  self.emptyView.frame = self.monsterView.frame;
  [self addSubview:self.emptyView];
}

- (void) updateForUserMonster:(UserMonster *)um {
  if (!um) {
    self.emptyView.hidden = NO;
    self.monsterView.hidden = YES;
  } else {
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    MonsterProto *mp = [gs monsterWithId:um.monsterId];
    self.healthBar.image = [Globals imageNamed:[Globals imageNameForElement:mp.element suffix:@"ring.png"]];
    self.healthBar.percentage = ((float)um.curHealth)/[gl calculateMaxHealthForMonster:um];
    self.healthLabel.text = [NSString stringWithFormat:@"%d/%d", um.curHealth, [gl calculateMaxHealthForMonster:um]];
    
    NSString *file = [mp.imagePrefix stringByAppendingString:@"Icon.png"];
    [Globals imageNamed:file withView:self.monsterIcon greyscale:(um.curHealth <= 0) indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    self.emptyView.hidden = YES;
    self.monsterView.hidden = NO;
  }
}

@end

@implementation TopBarView

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  // Allow all subviews to receive touch.
  for (UIView * foundView in self.subviews) {
    if (!foundView.hidden && [foundView pointInside:[self convertPoint:point toView:foundView] withEvent:event]) {
      return YES;
    }
  }
  return NO;
}

@end

@implementation TopBarViewController

- (void) viewDidLoad {
  for (UIView *container in self.topBarMonsterViewContainers) {
    container.backgroundColor = [UIColor clearColor];
    
    [[NSBundle mainBundle] loadNibNamed:@"TopBarMonsterView" owner:self options:nil];
    [container addSubview:self.topBarMonsterView];
  }
  
  self.chatViewController = [[ChatViewController alloc] init];
  [self addChildViewController:self.chatViewController];
  [self.view addSubview:self.chatViewController.view];
  [self.chatViewController closeAnimated:NO];
  
  self.myCityView.hidden = YES;
}

- (void) viewWillAppear:(BOOL)animated {
  self.expBar.percentage = 0.35;
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameStateUpdated) name:GAMESTATE_UPDATE_NOTIFICATION object:nil];
  [self gameStateUpdated];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMonsterViews) name:MY_TEAM_CHANGED_NOTIFICATION object:nil];
  [self updateMonsterViews];
}

- (void) viewDidDisappear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) showMyCityView {
  self.myCityView.hidden = NO;
}

- (void) removeMyCityView {
  self.myCityView.hidden = YES;
}

#pragma mark - Bottom view methods

- (void) replaceChatViewWithView:(MapBotView *)view {
  if (self.curViewOverChatView) {
    MapBotView *v = self.curViewOverChatView;
    [v animateOut:^{
      [v removeFromSuperview];
      if (self.curViewOverChatView == v) {
        self.curViewOverChatView = nil;
        [self addNewView:view];
      }
    }];
  } else {
    [self addNewView:view];
  }
}

- (void) addNewView:(MapBotView *)view {
  self.curViewOverChatView = view;
  [self.view insertSubview:self.curViewOverChatView atIndex:0];
  self.curViewOverChatView.center = ccp(self.view.frame.size.width/2, self.view.frame.size.height-view.frame.size.height/2);
  [view animateIn:nil];
}

- (void) removeViewOverChatView {
  MapBotView *v = self.curViewOverChatView;
  [v animateOut:^{
    [v removeFromSuperview];
    if (self.curViewOverChatView == v) {
      self.curViewOverChatView = nil;
    }
  }];
}

#pragma mark - IBActions

- (IBAction)menuClicked:(id)sender {
  MenuNavigationController *m = [[MenuNavigationController alloc] init];
  GameViewController *gvc = (GameViewController *)self.parentViewController;
  [gvc presentViewController:m animated:YES completion:nil];
  [m pushViewController:[[MainMenuController alloc] init] animated:YES];
}

- (IBAction)attackClicked:(id)sender {
  GameViewController *gvc = (GameViewController *)self.parentViewController;
  AttackMapViewController *amvc = [[AttackMapViewController alloc] init];
  amvc.delegate = gvc;
  MenuNavigationController *nav = [[MenuNavigationController alloc] init];
  nav.navigationBarHidden = YES;
  [gvc presentViewController:nav animated:YES completion:nil];
  [nav pushViewController:amvc animated:YES];
}

- (IBAction)plusClicked:(id)sender {
  MenuNavigationController *m = [[MenuNavigationController alloc] init];
  GameViewController *gvc = (GameViewController *)self.parentViewController;
  [gvc presentViewController:m animated:YES completion:nil];
  [m pushViewController:[[DiamondShopViewController alloc] init] animated:NO];
}

- (IBAction)profileClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  GameViewController *gvc = (GameViewController *)self.parentViewController;
  ProfileViewController *pvc = [[ProfileViewController alloc] initWithFullUserProto:[gs convertToFullUserProto] andCurrentTeam:[gs allMonstersOnMyTeam]];
  [gvc addChildViewController:pvc];
  pvc.view.frame = gvc.view.bounds;
  [gvc.view addSubview:pvc.view];
}

- (IBAction)questsClicked:(id)sender {
  GameViewController *gvc = (GameViewController *)self.parentViewController;
  QuestLogViewController *qvc = [[QuestLogViewController alloc] init];
  [gvc addChildViewController:qvc];
  qvc.view.frame = gvc.view.bounds;
  [gvc.view addSubview:qvc.view];
}

- (IBAction)myCityClicked:(id)sender {
  GameViewController *gvc = (GameViewController *)self.parentViewController;
  [gvc visitCityClicked:0];
}

- (IBAction)monsterViewsClicked:(id)sender {
  MenuNavigationController *m = [[MenuNavigationController alloc] init];
  GameViewController *gvc = (GameViewController *)self.parentViewController;
  [gvc presentViewController:m animated:YES completion:nil];
  [m pushViewController:[[MyCroniesViewController alloc] init] animated:NO];
}

- (IBAction)mailClicked:(id)sender {
  GameViewController *gvc = (GameViewController *)self.parentViewController;
  RequestsViewController *rvc = [[RequestsViewController alloc] init];
  [gvc addChildViewController:rvc];
  rvc.view.frame = gvc.view.bounds;
  [gvc.view addSubview:rvc.view];
}

#pragma mark - Updating HUD Stuff

- (void) gameStateUpdated {
  GameState *gs = [GameState sharedGameState];
  [self.silverLabel transitionToNum:gs.silver];
  [self.goldLabel transitionToNum:gs.gold];
  
  if (self.expLabel.currentNum <= gs.currentExpForLevel) {
    [self.expLabel transitionToNum:gs.currentExpForLevel];
  } else {
    [self.expLabel instaMoveToNum:gs.currentExpForLevel];
  }
  
  self.levelLabel.text = [Globals commafyNumber:gs.level];
}

- (void) updateMonsterViews {
  GameState *gs = [GameState sharedGameState];
  for (int i = 0; i < self.topBarMonsterViewContainers.count; i++) {
    UserMonster *um = [gs myMonsterWithSlotNumber:i+1];
    UIView *container = [self.topBarMonsterViewContainers objectAtIndex:i];
    TopBarMonsterView *mv = (TopBarMonsterView *)[[container subviews] lastObject];
    [mv updateForUserMonster:um];
  }
}

#pragma mark NumTransitionLabelDelegate methods

- (void) updateLabel:(NumTransitionLabel *)label forNumber:(int)number {
  GameState *gs = [GameState sharedGameState];
  if (label == self.expLabel) {
    label.text = [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:number], [Globals commafyNumber:gs.expDeltaNeededForNextLevel]];
    self.expBar.percentage = ((float)number)/gs.expDeltaNeededForNextLevel;
  } else if (label == self.silverLabel) {
    label.text = [Globals cashStringForNumber:number];
  } else if (label == self.goldLabel) {
    label.text = [Globals commafyNumber:number];
  }
}

@end
