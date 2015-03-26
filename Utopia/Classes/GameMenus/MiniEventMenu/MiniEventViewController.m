//
//  MiniEventViewController.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 3/23/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "MiniEventViewController.h"
#import "MiniEventDetailsView.h"
#import "MiniEventPointsView.h"
#import "Globals.h"

@interface MiniEventViewController ()

@end

@implementation MiniEventViewController

- (void) viewDidLoad
{
  [super viewDidLoad];
  
  self.containerView.superview.layer.cornerRadius = 5.f;
  self.containerView.superview.clipsToBounds = YES;
  
  _tabLeftShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eventtabshadow.png"]];
  {
    _tabLeftShadow.frame = CGRectMake(self.tab1Button.originX - 4 + 1, self.tab1Button.originY, 4, 53);
    _tabLeftShadow.layer.transform = CATransform3DMakeScale(-1, 1, 1);
    [self.buttonTabBar addSubview:_tabLeftShadow];
  }
  _tabRightShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eventtabshadow.png"]];
  {
    _tabRightShadow.frame = CGRectMake(self.tab1Button.originX + self.tab1Button.width, self.tab1Button.originY, 4, 53);
    [self.buttonTabBar addSubview:_tabRightShadow];
  }
  
  UIImageView* _tabLeftDivider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eventtabdivider.png"]];
  {
    _tabLeftDivider.frame = CGRectMake(self.tab1Button.originX, self.tab1Button.originY, 1, 53);
    [self.buttonTabBar addSubview:_tabLeftDivider];
  }
  UIImageView* _tabMiddleDivider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eventtabdivider.png"]];
  {
    _tabMiddleDivider.frame = CGRectMake(self.tab2Button.originX, self.tab2Button.originY, 1, 53);
    [self.buttonTabBar addSubview:_tabMiddleDivider];
  }
  UIImageView* _tabRightDivider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eventtabdivider.png"]];
  {
    _tabRightDivider.frame = CGRectMake(self.tab2Button.originX + self.tab2Button.width, self.tab2Button.originY, 1, 53);
    [self.buttonTabBar addSubview:_tabRightDivider];
  }
  
  self.buttonTabBar.inactiveTextColor = [UIColor colorWithHexString:@"0089C6"];
  self.buttonTabBar.activeTextColor   = [UIColor colorWithHexString:@"15AFD6"];
  
  self.detailsView = [[NSBundle mainBundle] loadNibNamed:@"MiniEventDetailsView" owner:self options:nil][0];
  self.pointsView  = [[NSBundle mainBundle] loadNibNamed:@"MiniEventPointsView" owner:self options:nil][0];
  
  [self.detailsView updateForMiniEvent];
  [self.pointsView updateForMiniEvent];
  
  [self button1Clicked:self];
}

- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (IBAction) closeClicked:(id)sender
{
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

- (void) button1Clicked:(id)sender
{
  _tabLeftShadow.originX  = self.tab1Button.originX - _tabLeftShadow.width;
  _tabRightShadow.originX = self.tab1Button.originX + self.tab1Button.width;
  
  [self.buttonTabBar clickButton:1];
  
  // Load mini event details view
  [self.containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  [self.containerView addSubview:self.detailsView];
}

- (void) button2Clicked:(id)sender
{
  _tabLeftShadow.originX  = self.tab2Button.originX - _tabLeftShadow.width;
  _tabRightShadow.originX = self.tab2Button.originX + self.tab2Button.width;
  
  [self.buttonTabBar clickButton:2];
  
  // Load mini event points view
  [self.containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  [self.containerView addSubview:self.pointsView];
}

@end
