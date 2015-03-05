//
//  BoardDesignerViewController.m
//  Utopia
//
//  Created by Behrouz N. on 3/3/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "BoardDesignerViewController.h"
#import "BoardDesignerObstacleView.h"
#import "HomeViewController.h"
#import "Globals.h"

@implementation BoardDesignerViewController

- (void) viewDidLoad
{
  [super viewDidLoad];
  
  self.containerView.layer.cornerRadius = 5.f;
  self.containerView.clipsToBounds = YES;
  
  UIImageView* descriptionCapLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"obstaclesdescriptioncap.png"]];
  {
    [descriptionCapLeft setFrame:CGRectMake(self.descriptionBgd.originX - 6, self.descriptionBgd.originY, 6, self.descriptionBgd.height)];
    [self.descriptionBgd.superview insertSubview:descriptionCapLeft belowSubview:self.descriptionBgd];
  }
  
  UIImageView* descriptionCapRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"obstaclesdescriptioncap.png"]];
  {
    [descriptionCapRight setFrame:CGRectMake(CGRectGetMaxX(self.descriptionBgd.frame), self.descriptionBgd.originY, 6, self.descriptionBgd.height)];
    [descriptionCapRight.layer setTransform:CATransform3DMakeScale(-1.f, 1.f, 1.f)];
    [self.descriptionBgd.superview insertSubview:descriptionCapRight belowSubview:self.descriptionBgd];
  }
  
  NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.descriptionBody.text];
  {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:4.f];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self.descriptionBody.text length])];
    [self.descriptionBody setAttributedText:attributedString];
  }
  
  UIImageView* progressBarCapLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"obstaclespowerbarbgcap.png"]];
  {
    [progressBarCapLeft setFrame:CGRectMake(self.progressBarBgd.originX - 6, self.progressBarBgd.originY, 6, self.progressBarBgd.height)];
    [self.progressBarBgd.superview insertSubview:progressBarCapLeft belowSubview:self.progressBarBgd];
  }
  
  UIImageView* progressBarCapRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"obstaclespowerbarbgcap.png"]];
  {
    [progressBarCapRight setFrame:CGRectMake(CGRectGetMaxX(self.progressBarBgd.frame), self.progressBarBgd.originY, 6, self.progressBarBgd.height)];
    [progressBarCapRight.layer setTransform:CATransform3DMakeScale(-1.f, 1.f, 1.f)];
    [self.progressBarBgd.superview insertSubview:progressBarCapRight belowSubview:self.progressBarBgd];
  }
  
  THLabel* powerLabel = (THLabel*)self.powerLabel;
  {
    powerLabel.gradientStartColor = [UIColor whiteColor];
    powerLabel.gradientEndColor = [UIColor colorWithHexString:@"E6FCFF"];
    powerLabel.strokeSize = 1.f;
    powerLabel.strokeColor = [UIColor colorWithHexString:@"007298"];
    powerLabel.shadowColor = [UIColor colorWithWhite:.65f alpha:1.f];
    powerLabel.shadowOffset = CGSizeMake(0.f, .5f);
    powerLabel.shadowBlur = 2.f;
  }
  
  [self loadObstacles];
  
  [self.powerProgressBar setPercentage:.8f];
}

- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (void) loadObstacles
{
  static const int kCellPadding = 5;

  // HARDCODED Cloud
  BoardDesignerObstacleView* obstacleView = [BoardDesignerObstacleView viewWithObstacleImage:@"cloudobstacle.png" name:@"Cloud" andPowerCost:1];
    [obstacleView setOriginX:0.f];
    [self.obstaclesScrollView addSubview:obstacleView];
  UIImageView* separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popuplinevertical.png"]];
    [separator setFrame:CGRectMake(CGRectGetMaxX(obstacleView.frame) + kCellPadding, 0, 1, self.obstaclesScrollView.height)];
    [self.obstaclesScrollView addSubview:separator];
  
  // HARDCODED Lock
  obstacleView = [BoardDesignerObstacleView viewWithObstacleImage:@"lockobstacle.png" name:@"Lock" andPowerCost:3];
    [obstacleView disableObstacle];
    [obstacleView setOriginX:separator.originX + kCellPadding];
    [self.obstaclesScrollView addSubview:obstacleView];
  separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popuplinevertical.png"]];
    [separator setFrame:CGRectMake(CGRectGetMaxX(obstacleView.frame) + kCellPadding, 0, 1, self.obstaclesScrollView.height)];
    [self.obstaclesScrollView addSubview:separator];
  
  // HARDCODED Hole
  obstacleView = [BoardDesignerObstacleView viewWithObstacleImage:@"holeobstacle.png" name:@"Hole" andPowerCost:5];
    [obstacleView lockObstacle];
    [obstacleView setOriginX:separator.originX + kCellPadding];
    [self.obstaclesScrollView addSubview:obstacleView];
  
  [self.obstaclesScrollView setContentSize:CGSizeMake(CGRectGetMaxX(obstacleView.frame), self.obstaclesScrollView.height)];
}

- (IBAction) closeClicked:(id)sender
{
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

@end
