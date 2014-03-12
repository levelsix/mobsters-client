//
//  TutorialTopBarViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/6/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialTopBarViewController.h"
#import "Globals.h"

@implementation TutorialTopBarViewController

- (id) init {
  if ((self = [super initWithNibName:@"TopBarViewController" bundle:nil])) {
    
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  self.mainView.hidden = YES;
  self.chatViewController.view.hidden = YES;
}

- (void) displayCoinBars {
  [self.view addSubview:self.coinBarsView];
}

- (void) displayMenuButton {
  [self.view addSubview:self.menuView];
}

- (void) displayAttackButton {
  [self.view addSubview:self.attackView];
  
  self.attackView.alpha = 0.f;
  [UIView animateWithDuration:0.2f animations:^{
    self.attackView.alpha = 1.f;
  }];
}

- (void) displayQuestButton {
  [self.view addSubview:self.questView];
  
  self.questView.alpha = 0.f;
  [UIView animateWithDuration:0.2f animations:^{
    self.questView.alpha = 1.f;
  }];
}

- (void) allowMenuClick {
  _allowMenuClick = YES;
  
  [Globals createUIArrowForView:self.menuView atAngle:M_PI_2];
}

- (void) menuClicked:(id)sender {
  if (_allowMenuClick) {
    _allowMenuClick = NO;
    [Globals removeUIArrowFromViewRecursively:self.view];
    [self.delegate menuClicked];
  }
}

- (void) allowAttackClick {
  _allowAttackClick = YES;
  
  [self displayAttackButton];
  [Globals createUIArrowForView:self.attackView atAngle:M_PI_2];
}

- (IBAction)attackClicked:(id)sender {
  if (_allowAttackClick) {
    _allowAttackClick = NO;
    [Globals removeUIArrowFromViewRecursively:self.view];
    [self.delegate attackClicked];
  }
}

- (void) allowQuestsClick {
  _allowQuestsClick = YES;
  
  [self displayQuestButton];
  [Globals createUIArrowForView:self.questView atAngle:0];
}

- (IBAction)questsClicked:(id)sender {
  if (_allowQuestsClick) {
    _allowQuestsClick = NO;
    [Globals removeUIArrowFromViewRecursively:self.view];
    [self.delegate questsClicked];
  }
}

- (IBAction)plusClicked:(id)sender {
  // Do nothing
}

- (IBAction)profileClicked:(id)sender {
  // Do nothing
}

- (IBAction)monsterViewsClicked:(id)sender {
  // Do nothing
}

- (IBAction)mailClicked:(id)sender {
  // Do nothing
}

@end
