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
  UIColor* _baseColor;
  
  UIColor* _borderColor;
  UIImage* _cornerImage;
}

@property (nonatomic, assign) BOOL isHole;

@property (nonatomic, assign) BoardDesignerTile* NeighborN;
@property (nonatomic, assign) BoardDesignerTile* NeighborS;
@property (nonatomic, assign) BoardDesignerTile* NeighborW;
@property (nonatomic, assign) BoardDesignerTile* NeighborE;

- (instancetype) initWithFrame:(CGRect)frame baseColor:(UIColor*)baseColor;

- (void) updateBorders;

@end
