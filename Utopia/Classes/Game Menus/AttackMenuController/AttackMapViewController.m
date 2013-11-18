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
    self.mapView.center = ccp(self.mapScrollView.frame.size.width/2-22.f, self.mapView.frame.size.height/2);
  }
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
  } else {
    [self.delegate visitCityClicked:icon.cityNumber];
    [self close:nil];
  }
}

- (IBAction)close:(id)sender {
  [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
