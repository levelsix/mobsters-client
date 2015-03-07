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

static const int kTileWidth  = 34;
static const int kTileHeight = 34;
static const int kBoardMarginTop  = 15;
static const int kBoardMarginLeft = 15;

@implementation BoardDesignerViewController

- (void) viewDidLoad
{
  [super viewDidLoad];
  
  [self.containerView.layer setCornerRadius:5.f];
  [self.containerView setClipsToBounds:YES];
  
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
  
  // Gesture recognizer for dragging views around
  UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [panGestureRecognizer setDelegate:self];
    [self.view setGestureRecognizers:@[ panGestureRecognizer ]];
  // Gesture recognizer for detecting long press on obstacles in the scroll
  // view. If the scroll view does not need to scroll due to its content
  // size, the minimum long press duration is set to zero
  UILongPressGestureRecognizer* longPressGestureRecogzier = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [longPressGestureRecogzier setDelegate:self];
    [longPressGestureRecogzier setMinimumPressDuration:(self.obstaclesScrollView.contentSize.width > self.obstaclesScrollView.width) ? .1f : 0.f];
    [self.obstaclesScrollView setGestureRecognizers:@[ longPressGestureRecogzier ]];
  // Gesture recognizer for detecting long press on obstacles on the board
  longPressGestureRecogzier = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [longPressGestureRecogzier setDelegate:self];
    [longPressGestureRecogzier setMinimumPressDuration:0.f];
    [_boardContainer setGestureRecognizers:@[ longPressGestureRecogzier ]];
  
  _draggingObstacle = NO;
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

- (void) loadObstacles
{
  static const int kCellPadding = 5;
  
  _obstacleViews = [NSMutableArray array];

  // HARDCODED Cloud
  BoardDesignerObstacleView* obstacleView = [BoardDesignerObstacleView viewWithObstacleImage:@"cloudobstacle.png" name:@"Cloud" andPowerCost:1];
    [obstacleView setOriginX:0.f];
    [self.obstaclesScrollView addSubview:obstacleView];
    [_obstacleViews addObject:obstacleView];
  UIImageView* separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popuplinevertical.png"]];
    [separator setFrame:CGRectMake(CGRectGetMaxX(obstacleView.frame) + kCellPadding, 0, 1, self.obstaclesScrollView.height)];
    [self.obstaclesScrollView addSubview:separator];
  
  // HARDCODED Lock
  obstacleView = [BoardDesignerObstacleView viewWithObstacleImage:@"lockobstacle.png" name:@"Lock" andPowerCost:3];
    /* [obstacleView disableObstacle]; */
    [obstacleView setOriginX:separator.originX + kCellPadding];
    [self.obstaclesScrollView addSubview:obstacleView];
    [_obstacleViews addObject:obstacleView];
  separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popuplinevertical.png"]];
    [separator setFrame:CGRectMake(CGRectGetMaxX(obstacleView.frame) + kCellPadding, 0, 1, self.obstaclesScrollView.height)];
    [self.obstaclesScrollView addSubview:separator];
  
  // HARDCODED Hole
  obstacleView = [BoardDesignerObstacleView viewWithObstacleImage:@"holeobstacle.png" name:@"Hole" andPowerCost:5];
    /* [obstacleView lockObstacle]; */
    [obstacleView setOriginX:separator.originX + kCellPadding];
    [self.obstaclesScrollView addSubview:obstacleView];
    [_obstacleViews addObject:obstacleView];
  
  [self.obstaclesScrollView setContentSize:CGSizeMake(CGRectGetMaxX(obstacleView.frame), self.obstaclesScrollView.height)];
}

- (void) buildBoardWithRows:(int)rows andColumns:(int)cols
{
  _boardSize = CGSizeMake(cols, rows);
  const CGSize boardBounds = CGSizeMake(kTileWidth * cols, kTileHeight * rows);
  
  // Create board container
  _boardContainer = [[TouchableSubviewsView alloc] initWithFrame:CGRectMake(self.mainView.width + kBoardMarginLeft,
                                                                            kBoardMarginTop * .5f + (self.mainView.height - boardBounds.height) * .5f,
                                                                            boardBounds.width,
                                                                            boardBounds.height)];
  [_boardContainer setBackgroundColor:[UIColor clearColor]];
  [self.mainView setWidth:self.mainView.width + kBoardMarginLeft + boardBounds.width];
  [self.mainView addSubview:_boardContainer];
  
  // Create tiles
  _boardTiles = [NSMutableArray array];
  for (int row = 0; row < rows; ++row)
  {
    [_boardTiles addObject:[NSMutableArray array]];
    for (int col = 0; col < cols; ++col)
    {
      BoardDesignerTile* tile = [[BoardDesignerTile alloc] initWithFrame:CGRectMake(col * kTileWidth, row * kTileHeight, kTileWidth, kTileHeight)
                                                           darkBaseColor:((row + col) % 2 == 0)];
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

- (BOOL) gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer
  shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer
{
  return YES;
}

- (void) handleLongPress:(UIPanGestureRecognizer*)gestureRecognizer
{
  CGPoint point = [gestureRecognizer locationInView:self.view];
  if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
  {
    if (!_draggingObstacle)
    {
      UIImage* draggedObstacleImage = nil;
      CGPoint draggedObstacleAnchorPoint = CGPointMake(.5f, .5f);
      
      CGPoint localPoint = [self.view convertPoint:point toView:_boardContainer];
      if ([_boardContainer pointInside:localPoint withEvent:nil])
      {
        const int row = floorf(localPoint.y / kTileHeight);
        const int col = floorf(localPoint.x / kTileWidth);
        
        BoardDesignerTile* targetTile = [[_boardTiles objectAtIndex:row] objectAtIndex:col];
        localPoint = [self.view convertPoint:point toView:targetTile];
        
        if (targetTile.isHole)
        {
          // Begin dragging a hole that has been placed on the board

          [targetTile setIsHole:NO];
          [[self tilesSurroundingAndIncludingTileAtRow:row andColumn:col] makeObjectsPerformSelector:@selector(updateBorders)];
          
          draggedObstacleImage = [UIImage imageNamed:@"holeobstacle.png"]; // TODO - Will unhack this once data has been hooked up
          
          _draggingObstacle = YES;
          _draggedObstacleIsHole = YES;
        }
        else if (targetTile.isOccupied)
        {
          // Begin dragging an obstacle that has been placed on the board
          
          draggedObstacleImage = [targetTile removeObstacle];
          
          _draggingObstacle = YES;
          _draggedObstacleIsHole = NO;
        }
        
        if (_draggingObstacle)
        {
          _dragOrigin = [targetTile.superview convertPoint:targetTile.center toView:self.view];
          _dragOriginatedFromBoard = YES;
          
          draggedObstacleAnchorPoint = CGPointMake(localPoint.x / targetTile.width, localPoint.y / targetTile.height);
        }
      }
      else
      {
        for (BoardDesignerObstacleView* obstacleView in _obstacleViews)
          if (obstacleView.isEnabled && !obstacleView.isLocked)
          {
            CGPoint localPoint = [self.view convertPoint:point toView:obstacleView.obstacleImageView];
            if ([obstacleView.obstacleImageView pointInside:localPoint withEvent:nil])
            {
              // Begin dragging an obstacle that is enabled and unlocked out of the scroll view
              
              _dragOrigin = [obstacleView convertPoint:obstacleView.obstacleImageView.center toView:self.view];
              
              draggedObstacleImage = obstacleView.obstacleImageView.image;
              draggedObstacleAnchorPoint = CGPointMake(localPoint.x / obstacleView.obstacleImageView.width, localPoint.y / obstacleView.obstacleImageView.height);
              
              _draggingObstacle = YES;
              _draggedObstacleIsHole = (obstacleView == [_obstacleViews objectAtIndex:2]); // TODO - Will unhack this once data has been hooked up
              _dragOriginatedFromBoard = NO;
              
              // Valid drag gesture detected; disable scrolling
              [self.obstaclesScrollView setScrollEnabled:NO];
              
              break;
            }
          }
      }
      
      if (_draggingObstacle)
      {
        _draggedObstacle = [[UIImageView alloc] initWithImage:draggedObstacleImage];
          [_draggedObstacle setCenter:point];
          [_draggedObstacle setAlpha:0.f];
          [_draggedObstacle.layer setAnchorPoint:draggedObstacleAnchorPoint];
          [self.view insertSubview:_draggedObstacle aboveSubview:self.mainView];
        [UIView animateWithDuration:.1f animations:^{
          [_draggedObstacle setAlpha:1.f];
          [_draggedObstacle.layer setTransform:CATransform3DMakeScale(1.5f, 1.5f, 1.f)];
        }];
        
        _dragLastMovementTime = CACurrentMediaTime();
      }
    }
  }
  if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
  {
    if (_draggingObstacle)
    {
      BOOL invalidDrop = YES;
      
      CGPoint localPoint = [self.view convertPoint:point toView:_boardContainer];
      if ([_boardContainer pointInside:localPoint withEvent:nil])
      {
        int row = floorf(localPoint.y / kTileHeight);
        int col = floorf(localPoint.x / kTileWidth);
        
        BoardDesignerTile* targetTile = [[_boardTiles objectAtIndex:row] objectAtIndex:col];
        if ([targetTile canAcceptObstacle] || _dragOriginatedFromBoard)
        {
          // Dropping obstacle onto a board tile that is willing to accept it,
          // or dargging an obstacle already on the board onto an invalid tile,
          // in which case it will fly back to the tile it originated from
          
          if (![targetTile canAcceptObstacle])
          {
            CGPoint localPoint = [self.view convertPoint:_dragOrigin toView:_boardContainer];
            row = floorf(localPoint.y / kTileHeight);
            col = floorf(localPoint.x / kTileWidth);
            targetTile = [[_boardTiles objectAtIndex:row] objectAtIndex:col];
          }
          
          CGPoint dragTarget = [targetTile.superview convertPoint:targetTile.center toView:self.view];
          
          if (_draggedObstacleIsHole)
          {
            [UIView animateWithDuration:.1f animations:^{
              [_draggedObstacle setCenter:dragTarget];
              [_draggedObstacle.layer setAnchorPoint:CGPointMake(.5f, .5f)];
              [_draggedObstacle.layer setTransform:CATransform3DMakeScale(.85, .85, 1.f)];
            } completion:^(BOOL finished) {
              [targetTile setIsHole:YES];
              [[self tilesSurroundingAndIncludingTileAtRow:row andColumn:col] makeObjectsPerformSelector:@selector(updateBorders)];
              
              [UIView animateWithDuration:.1f animations:^{
                [_draggedObstacle setAlpha:0.f];
              } completion:^(BOOL finished) {
                [_draggedObstacle removeFromSuperview];
                _draggedObstacle = nil;
              }];
            }];
          }
          else
          {
            [UIView animateWithDuration:.1f animations:^{
              [_draggedObstacle setCenter:dragTarget];
              [_draggedObstacle.layer setAnchorPoint:CGPointMake(.5f, .5f)];
              [_draggedObstacle.layer setTransform:CATransform3DMakeScale(.65f, .65f, 1.f)];
            } completion:^(BOOL finished) {
              [targetTile addObstacle:_draggedObstacle.image];
              
              [_draggedObstacle removeFromSuperview];
              _draggedObstacle = nil;
            }];
          }
          
          invalidDrop = NO;
        }
      }
      
      if (invalidDrop)
      {
        if (_dragOriginatedFromBoard)
        {
          // Dragged obstacle will be removed from the board with a poof animation
          [UIView animateWithDuration:.1f animations:^{
            [_draggedObstacle setAlpha:0.f];
            [_draggedObstacle.layer setTransform:CATransform3DMakeScale(2.5f, 2.5f, 1.f)];
          } completion:^(BOOL finished) {
            [_draggedObstacle removeFromSuperview];
            _draggedObstacle = nil;
          }];
        }
        else
        {
          // Dragged obstacle will fly back to its origin
          [UIView animateWithDuration:.1f animations:^{
            [_draggedObstacle setCenter:_dragOrigin];
            [_draggedObstacle.layer setAnchorPoint:CGPointMake(.5f, .5f)];
            [_draggedObstacle.layer setTransform:CATransform3DIdentity];
          } completion:^(BOOL finished) {
            [_draggedObstacle removeFromSuperview];
            _draggedObstacle = nil;
          }];
        }
      }
      
      _draggingObstacle = NO;
      
      // Drag gesture ended; re-enable scrolling
      [self.obstaclesScrollView setScrollEnabled:YES];
    }
  }
}

- (void) handlePan:(UIPanGestureRecognizer*)gestureRecognizer
{
  CGPoint point = [gestureRecognizer locationInView:self.view];
  if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
  {
    if (_draggingObstacle)
    {
      // Obstacle being dragged will follow finger movement
      [UIView animateWithDuration:CACurrentMediaTime() - _dragLastMovementTime animations:^{
        [_draggedObstacle setCenter:point];
      }];
      _dragLastMovementTime = CACurrentMediaTime();
    }
  }
}

- (NSArray*) tilesSurroundingAndIncludingTileAtRow:(int)row andColumn:(int)col
{
  NSMutableArray* tiles = [NSMutableArray array];
  for (int r = row - 1; r <= row + 1; ++r)
    for (int c = col - 1; c <= col + 1; ++c)
      if (r >= 0 && r < _boardSize.height && c >= 0 && c < _boardSize.width)
        [tiles addObject:[[_boardTiles objectAtIndex:r] objectAtIndex:c]];
  
  return [NSArray arrayWithArray:tiles];
}

@end
