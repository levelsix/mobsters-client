//
//  BoardDesignerTile.h
//  Utopia
//
//  Created by Behrouz N. on 3/4/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BoardDesignerTile : UIView
{
  BOOL     _baseColorIsDark;
  UIColor* _baseColor;
  UIColor* _borderColor;
  UIImage* _outerCornerImage;
  UIImage* _innerCornerImage;
  
  UIImageView* _obstacleImageView;
}

@property (nonatomic, assign) BOOL isHole;
@property (nonatomic, readonly) BOOL isOccupied;

@property (nonatomic, assign) BoardDesignerTile* NeighborN;
@property (nonatomic, assign) BoardDesignerTile* NeighborS;
@property (nonatomic, assign) BoardDesignerTile* NeighborW;
@property (nonatomic, assign) BoardDesignerTile* NeighborE;

- (instancetype) initWithFrame:(CGRect)frame darkBaseColor:(BOOL)dark;

- (void) updateBorders;
- (BOOL) canAcceptObstacle;
- (void) addObstacle:(UIImage*)obstacleImage;
- (UIImage*) removeObstacle;
- (BOOL) hasNeighborN;
- (BOOL) hasNeighborS;
- (BOOL) hasNeighborW;
- (BOOL) hasNeighborE;

@end
