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

#define NUM_CITIES 5

@implementation AttackMapIconView

- (void)awakeFromNib {
  self.isLocked = YES;
  self.cityNameLabel.hidden = YES;
  self.visitView.hidden = YES;
  self.selected = NO;
}


- (void)setIsLocked:(BOOL)isLocked {
  _isLocked = isLocked;
  if (isLocked) {
    [self.cityButton setImage:[UIImage imageNamed:@"lockedcity.png"] forState:UIControlStateNormal];
    self.cityNumberLabel.hidden = YES;
  }
  else {
    [self.cityButton setImage:[UIImage imageNamed:@"opencity.png"] forState:UIControlStateNormal];
    self.cityNumberLabel.hidden = NO;
  }
}

- (void)setCityNumber:(int)cityNumber {
  _cityNumber = cityNumber;
  self.cityNumberLabel.text = [NSString stringWithFormat:@"%d",cityNumber];
}

- (void) toggleVisitButton {
  if (self.selected) {
    self.selected = NO;
    self.visitView.hidden = YES;
    self.cityNameLabel.hidden = YES;
  } else {
    self.selected = YES;
    self.visitView.hidden = NO;
    self.cityNameLabel.hidden = NO;
  }
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

- (IBAction)findMatch:(id)sender {
  //do some matchmaking ui here
}

@end

@implementation AttackMapViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self loadCities];
  [self setUpMultiplayerSettings];
}

- (BOOL)prefersStatusBarHidden {
  return YES;
}

- (void)loadCities {
  GameState *gs = [GameState sharedGameState];
  for (int i = 1; i <= NUM_CITIES;i++) {
    FullCityProto *fcp = [gs cityWithId:i];
    AttackMapIconViewContainer *amvc = (AttackMapIconViewContainer *)[self.view viewWithTag:i];
    amvc.iconView.fcp = fcp;
    if (fcp == nil) {
      amvc.iconView.isLocked = YES;
    }
    else {
      amvc.iconView.isLocked = NO;
    }
    amvc.iconView.cityNumber = i;
    amvc.iconView.cityNameLabel.text = [NSString stringWithFormat:@"%@",fcp.name];
    
    [amvc.iconView.visitButton addTarget:self action:@selector(visitClicked:) forControlEvents:UIControlEventTouchUpInside];
    [amvc.iconView.cityButton addTarget:self action:@selector(cityClicked:) forControlEvents:UIControlEventTouchUpInside];
  }
}

- (void)setUpMultiplayerSettings {
  GameState *gs = [GameState sharedGameState];
  if (gs.level < 30) {
    self.multiplayerView.needToUnlockView.hidden = NO;
  }
}

- (IBAction)cityClicked:(id)sender {
  while (sender && ![sender isKindOfClass:[AttackMapIconView class]]) {
    sender = [sender superview];
  }
  AttackMapIconView *icon = (AttackMapIconView *)sender;
  
  if (!icon.isLocked) {
    [icon toggleVisitButton];
  }
  
  for (int i = 1; i <= NUM_CITIES;i++) {
    AttackMapIconViewContainer *amvc = (AttackMapIconViewContainer *)[self.view viewWithTag:i];
    if (amvc.iconView != icon && amvc.iconView.selected) {
      [amvc.iconView toggleVisitButton];
    }
  }
}

- (IBAction)visitClicked:(id)sender {
  while (sender && ![sender isKindOfClass:[AttackMapIconView class]]) {
    sender = [sender superview];
  }
  AttackMapIconView *icon = (AttackMapIconView *)sender;
  [self.delegate visitCityClicked:icon.cityNumber];
  [self close:nil];
}

- (void)viewWillAppear:(BOOL)animated {
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (IBAction)close:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^(void) {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self cityClicked:nil];
}

@end
