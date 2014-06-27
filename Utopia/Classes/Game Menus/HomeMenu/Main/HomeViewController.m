//
//  HomeViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/20/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "HomeViewController.h"
#import "GameState.h"

#import "SellViewController.h"
#import "EnhanceChooserViewController.h"
#import "HealViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
//  EnhanceChooserViewController *svc = [[EnhanceChooserViewController alloc] init];
//  SellViewController *svc = [[SellViewController alloc] init];
  HealViewController *svc = [[HealViewController alloc] init];
  [self replaceRootWithViewController:svc animated:NO];
  
  self.containerView.superview.layer.cornerRadius = 5.f;
  self.containerView.superview.clipsToBounds = YES;
}

@end
