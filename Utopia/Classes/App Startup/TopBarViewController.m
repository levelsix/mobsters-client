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
  r.origin.x = CGRectGetMaxX(self.leftCap.frame);
  if (totalWidth >= self.leftCap.image.size.width*2) {
    r.size.width = self.rightCap.frame.origin.x-r.origin.x+1;
  } else {
    r.size.width = 0;
  }
  self.middleBar.frame = r;
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

- (void) viewWillAppear:(BOOL)animated {
  self.expBar.percentage = 0.35;
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameStateUpdated) name:GAMESTATE_UPDATE_NOTIFICATION object:nil];
  [self gameStateUpdated];
}

- (void) viewDidDisappear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) replaceChatViewWithView:(UIView *)view {
  if (self.curViewOverChatView != view) {
    if (self.curViewOverChatView) {
      [self.curViewOverChatView removeFromSuperview];
    }
    self.curViewOverChatView = view;
    [self.view addSubview:self.curViewOverChatView];
    self.curViewOverChatView.center = ccp(self.view.frame.size.width/2, self.view.frame.size.height-10-view.frame.size.height/2);
  }
}

- (void) removeViewOverChatView {
  [self.curViewOverChatView removeFromSuperview];
  self.curViewOverChatView = nil;
}

- (IBAction)menuClicked:(id)sender {
  MenuNavigationController *m = [[MenuNavigationController alloc] init];
  GameViewController *gvc = (GameViewController *)self.parentViewController;
  [gvc presentViewController:m animated:YES completion:nil];
  [m pushViewController:[[MainMenuController alloc] init] animated:YES];
}

- (IBAction)attackClicked:(id)sender {
  GameViewController *gvc = (GameViewController *)self.parentViewController;
  AttackMapViewController *amvc = [[AttackMapViewController alloc] init];
  [gvc addChildViewController:amvc];
  amvc.view.frame = gvc.view.bounds;
  amvc.delegate = gvc;
  [gvc.view addSubview:amvc.view];
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
//  ProfileViewController *pvc = [[ProfileViewController alloc] initWithFullUserProto:[gs convertToFullUserProto] andCurrentTeam:[gs allMonstersOnMyTeam]];
  QuestLogViewController *pvc = [[QuestLogViewController alloc] init];
  [gvc addChildViewController:pvc];
  pvc.view.frame = gvc.view.bounds;
  [gvc.view addSubview:pvc.view];
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
}

#pragma mark NumTransitionLabelDelegate methods

- (void) updateLabel:(NumTransitionLabel *)label forNumber:(int)number {
  GameState *gs = [GameState sharedGameState];
  if (label == self.expLabel) {
    label.text = [NSString stringWithFormat:@"%d/%d", number, gs.expDeltaNeededForNextLevel];
    self.expBar.percentage = ((float)number)/gs.expDeltaNeededForNextLevel;
  } else if (label == self.silverLabel) {
    label.text = [Globals cashStringForNumber:number];
  } else if (label == self.goldLabel) {
    label.text = [Globals commafyNumber:number];
  }
}

@end
