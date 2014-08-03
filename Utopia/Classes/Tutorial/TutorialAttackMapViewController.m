//
//  TutorialAttackMapViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/8/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TutorialAttackMapViewController.h"
#import "Globals.h"

@implementation TutorialAttackMapViewController

- (id) init {
  if ((self = [super initWithNibName:@"AttackMapViewController" bundle:nil])) {
    
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  if (self.clickableCityId) {
    [self allowClickOnCityId:self.clickableCityId];
  }
  
  self.multiplayerView.userInteractionEnabled = NO;
}

- (void) allowClickOnCityId:(int)cityId {
  self.clickableCityId = cityId;
  
  AttackMapIconView *icon = (AttackMapIconView *)[self.mapScrollView viewWithTag:cityId];
  [Globals createUIArrowForView:icon atAngle:M_PI];
}

- (IBAction)cityClicked:(id)sender {
  while (sender && ![sender isKindOfClass:[AttackMapIconView class]]) {
    sender = [sender superview];
  }
  AttackMapIconView *icon = (AttackMapIconView *)sender;
  
  if (icon.tag == self.clickableCityId) {
    [Globals removeUIArrowFromViewRecursively:self.view];
    [super cityClicked:sender];
    [Globals createUIArrowForView:self.taskStatusView.enterButtonView atAngle:M_PI_2];
  }
}

- (IBAction)enterDungeonClicked:(id)sender {
  // Need to overwrite so that globals doesn't send you to residence
  [self.delegate enterDungeon:self.taskStatusView.taskId isEvent:NO eventId:0 useGems:NO];
}

- (IBAction)enterEventClicked:(UIButton *)sender {
  // Do nothing
}

- (IBAction)findMatchClicked:(id)sender {
  // Do nothing
}

- (IBAction)close:(id)sender {
  // Do nothing
}

- (void) removeTaskStatusView {
  // Do nothing
}

- (void) createMyPositionViewForIcon:(AttackMapIconView *)icon {
  // Do nothing
}

@end
