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
}

- (void) allowClickOnCityId:(int)cityId {
  self.clickableCityId = cityId;
  
  AttackMapIconViewContainer *amvc = (AttackMapIconViewContainer *)[self.mapView viewWithTag:cityId];
  [Globals createUIArrowForView:amvc.iconView.cityButton atAngle:M_PI];
}

- (IBAction)cityClicked:(id)sender {
  while (sender && ![sender isKindOfClass:[AttackMapIconView class]]) {
    sender = [sender superview];
  }
  AttackMapIconView *icon = (AttackMapIconView *)sender;
  
  if (icon.cityNumber == self.clickableCityId) {
    [super cityClicked:nil];
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
