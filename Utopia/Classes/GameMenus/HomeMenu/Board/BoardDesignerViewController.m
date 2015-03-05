//
//  BoardDesignerViewController.m
//  Utopia
//
//  Created by Behrouz N. on 3/3/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "BoardDesignerViewController.h"
#import "BoardDesignerObstacleView.h"
#import "BoardDesignerTile.h"
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
  
  [self.powerProgressBar setPercentage:.8f];
  [self loadObstacles];
  [self buildBoardWithRows:9 andColumns:9];
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

- (void) buildBoardWithRows:(int)rows andColumns:(int)cols
{
  static const int kTileWidth  = 34;
  static const int kTileHeight = 34;
  static const int kBoardMarginTop  = 15;
  static const int kBoardMarginLeft = 15;
  
  const CGSize boardSize = CGSizeMake(kTileWidth * cols, kTileHeight * rows);
  UIColor* kTileColorLight = [UIColor colorWithHexString:@"3C4747"];
  UIColor* kTileColorDark  = [UIColor colorWithHexString:@"353F3F"];
  
  // Create board container
  _boardContainer = [[TouchableSubviewsView alloc] initWithFrame:CGRectMake(self.mainView.width + kBoardMarginLeft,
                                                                            kBoardMarginTop * .5f + (self.mainView.height - boardSize.height) * .5f,
                                                                            boardSize.width,
                                                                            boardSize.height)];
  [_boardContainer setBackgroundColor:[UIColor clearColor]];
  [self.mainView setWidth:self.mainView.width + kBoardMarginLeft + boardSize.width];
  [self.mainView addSubview:_boardContainer];
  
  // Create tiles
  _boardTiles = [NSMutableArray array];
  for (int row = 0; row < rows; ++row)
  {
    [_boardTiles addObject:[NSMutableArray array]];
    for (int col = 0; col < cols; ++col)
    {
      BoardDesignerTile* tile = [[BoardDesignerTile alloc] initWithFrame:CGRectMake(col * kTileWidth, row * kTileHeight, kTileWidth, kTileHeight)
                                                               baseColor:((row + col) % 2 == 0) ? kTileColorDark : kTileColorLight];
      [_boardContainer addSubview:tile];
      [[_boardTiles objectAtIndex:row] addObject:tile];
    }
  }
  
  // Assign neighbors
  for (int row = 0; row < rows; ++row)
    for (int col = 0; col < cols; ++col)
    {
      BoardDesignerTile* tile = [[_boardTiles objectAtIndex:row] objectAtIndex:col];
      if (row > 0) tile.NeighborN = [[_boardTiles objectAtIndex:row - 1] objectAtIndex:col];
      if (col > 0) tile.NeighborW = [[_boardTiles objectAtIndex:row] objectAtIndex:col - 1];
      if (row < rows - 1) tile.NeighborS = [[_boardTiles objectAtIndex:row + 1] objectAtIndex:col];
      if (col < cols - 1) tile.NeighborE = [[_boardTiles objectAtIndex:row] objectAtIndex:col + 1];
    }
  
  // Create borders
  for (int row = 0; row < rows; ++row)
    for (int col = 0; col < cols; ++col)
      [(BoardDesignerTile*)[[_boardTiles objectAtIndex:row] objectAtIndex:col] updateBorders];
}

- (IBAction) closeClicked:(id)sender
{
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

@end
