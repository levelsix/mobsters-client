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

- (IBAction)plusClicked:(id)sender {
  // Do nothing
}

- (void) allowQuestClick {
  self.mainView.hidden = YES;
  self.mainView.alpha = 0.f;
  [UIView animateWithDuration:0.3f animations:^{
    self.mainView.alpha = 1.f;
  } completion:^(BOOL finished) {
    [Globals createUIArrowForView:self.questView atAngle:M_PI_2];
  }];
}

- (IBAction)questsClicked:(id)sender {
  [super questsClicked:sender];
  [Globals removeUIArrowFromViewRecursively:self.view];
}

- (IBAction)attackClicked:(id)sender {
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
