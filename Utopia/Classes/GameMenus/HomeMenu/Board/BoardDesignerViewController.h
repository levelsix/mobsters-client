//
//  BoardDesignerViewController.h
//  Utopia
//
//  Created by Behrouz N. on 3/3/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BoardDesignerViewControllerDelegate <NSObject>

- (void) boardDesignerViewControllerClosed;

@end

@class HomeTitleView;
@class SplitImageProgressBar;
@class TouchableSubviewsView;
@class PvpBoardObstacleProto;

@interface BoardDesignerViewController : UIViewController <UIGestureRecognizerDelegate>
{
  int32_t                 _powerLimit;
  int32_t                 _powerUsed;
  int32_t                 _powerUsedExtra; // Extra power cost dictated by restrictions (e.g. adjacency in a row)
  
  int                     _currObstacleFocusIndex;
  
  NSMutableArray*         _obstacleViews;
  
  TouchableSubviewsView*  _boardContainer;
  NSMutableArray*         _boardTiles;
  CGSize                  _boardSize;
  
  BOOL                    _draggingObstacle;
  UIImageView*            _draggedObstacleImage;
  PvpBoardObstacleProto*  _draggedObstacle;
  CFTimeInterval          _dragLastMovementTime;
  CGPoint                 _dragOrigin;
  BOOL                    _dragOriginatedFromBoard;
}

@property (nonatomic, retain) IBOutlet UIView* mainView;
@property (nonatomic, retain) IBOutlet UIView* bgdView;
@property (nonatomic, retain) IBOutlet UIView* containerView;

@property (nonatomic, retain) IBOutlet UIImageView* descriptionBgd;
@property (nonatomic, retain) IBOutlet UIImageView* descriptionImage;
@property (nonatomic, retain) IBOutlet UILabel* descriptionTitle;
@property (nonatomic, retain) IBOutlet UILabel* descriptionBody;
@property (nonatomic, retain) IBOutlet UIImageView* progressBarBgd;
@property (nonatomic, retain) IBOutlet UILabel* powerLabel;
@property (nonatomic, retain) IBOutlet UIScrollView* obstaclesScrollView;

@property (nonatomic, retain) IBOutlet UIButton* rightArrowButton;
@property (nonatomic, retain) IBOutlet UIButton* leftArrowButton;

@property (nonatomic, retain) IBOutlet HomeTitleView* homeTitleView;
@property (nonatomic, retain) IBOutlet SplitImageProgressBar* powerProgressBar;
@property (nonatomic, retain) IBOutlet UIButton* closeButton;

@property (nonatomic, weak) id<BoardDesignerViewControllerDelegate> delegate;

- (IBAction) closeClicked:(id)sender;

- (IBAction) rightArrowClicked:(id)sender;
- (IBAction) leftArrowClicked:(id)sender;

@end
