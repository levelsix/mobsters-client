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
  [Globals createUIArrowForView:icon.cityButton atAngle:M_PI];
}

- (IBAction)cityClicked:(id)sender {
  while (sender && ![sender isKindOfClass:[AttackMapIconView class]]) {
    sender = [sender superview];
  }
  AttackMapIconView *icon = (AttackMapIconView *)sender;
  
  if (icon.tag == self.clickableCityId) {
    [super cityClicked:sender];
  }
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

@end
