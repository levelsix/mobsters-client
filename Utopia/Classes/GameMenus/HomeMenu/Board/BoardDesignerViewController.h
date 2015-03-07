//
//  BoardDesignerViewController.h
//  Utopia
//
//  Created by Behrouz N. on 3/3/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HomeTitleView;
@class SplitImageProgressBar;
@class TouchableSubviewsView;

@interface BoardDesignerViewController : UIViewController <UIGestureRecognizerDelegate>
{
  NSMutableArray*         _obstacleViews;
  
  TouchableSubviewsView*  _boardContainer;
  NSMutableArray*         _boardTiles;
  CGSize                  _boardSize;
  
  BOOL                    _draggingObstacle;
  UIImageView*            _draggedObstacle;
  BOOL                    _draggedObstacleIsHole;
  CFTimeInterval          _dragLastMovementTime;
  CGPoint                 _dragOrigin;
  BOOL                    _dragOriginatedFromBoard;
}

@property (nonatomic, retain) IBOutlet UIView* mainView;
@property (nonatomic, retain) IBOutlet UIView* bgdView;
@property (nonatomic, retain) IBOutlet UIView* containerView;

@property (nonatomic, retain) IBOutlet UIImageView* descriptionBgd;
@property (nonatomic, retain) IBOutlet UILabel* descriptionTitle;
@property (nonatomic, retain) IBOutlet UILabel* descriptionBody;
@property (nonatomic, retain) IBOutlet UIImageView* progressBarBgd;
@property (nonatomic, retain) IBOutlet UILabel* powerLabel;
@property (nonatomic, retain) IBOutlet UIScrollView* obstaclesScrollView;

@property (nonatomic, retain) IBOutlet HomeTitleView* homeTitleView;
@property (nonatomic, retain) IBOutlet SplitImageProgressBar* powerProgressBar;

- (IBAction) closeClicked:(id)sender;

@end
