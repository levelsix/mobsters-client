//
//  BoardDesignerTile.h
//  Utopia
//
//  Created by Behrouz N. on 3/4/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PvpBoardObstacleProto;

@interface BoardDesignerTile : UIView
{
  BOOL     _baseColorIsDark;
  UIColor* _baseColor;
  UIColor* _borderColor;
  UIImage* _outerCornerImage;
  UIImage* _innerCornerImage;
  
  UIImageView* _obstacleImageView;
  
  UILabel* _extraPowerCostLabel;
  UILabel* _extraPowerLabel;
  UIView*  _extraPowerBg;
  BOOL     _tileAvailable; // Used only while extra power cost is being shown on the tile
}

@property (nonatomic, readonly) PvpBoardObstacleProto* obstacleProto;

@property (nonatomic, readonly) BOOL isHole;
@property (nonatomic, readonly) BOOL isOccupied;

@property (nonatomic, assign) BoardDesignerTile* NeighborN;
@property (nonatomic, assign) BoardDesignerTile* NeighborS;
@property (nonatomic, assign) BoardDesignerTile* NeighborW;
@property (nonatomic, assign) BoardDesignerTile* NeighborE;
@property (nonatomic, assign) BoardDesignerTile* NeighborNW;
@property (nonatomic, assign) BoardDesignerTile* NeighborSW;
@property (nonatomic, assign) BoardDesignerTile* NeighborNE;
@property (nonatomic, assign) BoardDesignerTile* NeighborSE;

- (instancetype) initWithFrame:(CGRect)frame darkBaseColor:(BOOL)dark;

- (void) updateBorders;
- (BOOL) canAcceptObstacle;
- (void) addObstacle:(PvpBoardObstacleProto*)obstacleProto withImage:(UIImage*)obstacleImage;
- (UIImage*) removeObstacle;
- (void) showExtraPowerCost:(int)cost available:(BOOL)available;
- (void) hideExtraPowerCost;

- (BOOL) hasNeighborN;
- (BOOL) hasNeighborS;
- (BOOL) hasNeighborW;
- (BOOL) hasNeighborE;
- (BOOL) hasNeighborNW;
- (BOOL) hasNeighborSW;
- (BOOL) hasNeighborNE;
- (BOOL) hasNeighborSE;

@end
