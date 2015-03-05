//
//  BoardDesignerTile.m
//  Utopia
//
//  Created by Behrouz N. on 3/4/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "BoardDesignerTile.h"
#import "UIView+Coordinates.h"
#import "UIColor+HexColor.h"

static const int kBorderThickness = 2;
static const int kCornerInset = 6;

@implementation BoardDesignerTile

- (instancetype) initWithFrame:(CGRect)frame baseColor:(UIColor*)baseColor
{
  if (self = [super initWithFrame:frame])
  {
    _baseColor = baseColor;
    self.backgroundColor = baseColor;
    
    _borderColor = [UIColor colorWithHexString:@"181B1C"];
    _cornerImage = [UIImage imageNamed:@"boardeditorcorner.png"];
    
    self.NeighborN = nil;
    self.NeighborS = nil;
    self.NeighborW = nil;
    self.NeighborE = nil;
    self.isHole = NO;
  }
  return self;
}

- (void) updateBorders
{
  if (self.isHole)
  {
    // TODO
  }
  else
  {
    [self updateOuterBorders];
  }
}

- (void) updateOuterBorders
{
  if (!self.NeighborN)
  {
    [self updateTopOuterBorder];
  }
  if (!self.NeighborE)
  {
    [self updateRightOuterBorder];
  }
  if (!self.NeighborS)
  {
    [self updateBottomOuterBorder];
  }
  if (!self.NeighborW)
  {
    [self updateLeftOuterBorder];
  }
}

- (void) updateTopOuterBorder
{
  // Top outer border
  UIView* border = [[UIView alloc] initWithFrame:CGRectMake(kCornerInset, -kBorderThickness, self.width - kCornerInset * 2, kBorderThickness)];
  [border setBackgroundColor:_borderColor];
  [self addSubview:border];
  
  if (self.NeighborW)
  {
    // Extend border to far left
    [border setOriginX:border.originX - kCornerInset];
    [border setWidth:border.width + kCornerInset];
  }
  else
  {
    // Top-left outer corner
    UIImageView* corner = [[UIImageView alloc] initWithImage:_cornerImage];
    [corner setOrigin:CGPointMake(-kBorderThickness, -kBorderThickness)];
    [self addSubview:corner];
  }
  
  if (self.NeighborE)
  {
    // Extend border to far right
    [border setWidth:border.width + kCornerInset];
  }
}

- (void) updateRightOuterBorder
{
  // Right outer border
  UIView* border = [[UIView alloc] initWithFrame:CGRectMake(self.width, kCornerInset, kBorderThickness, self.height - kCornerInset * 2)];
  [border setBackgroundColor:_borderColor];
  [self addSubview:border];
  
  if (self.NeighborN)
  {
    // Extend border to far top
    [border setOriginY:border.originY - kCornerInset];
    [border setHeight:border.height + kCornerInset];
  }
  else
  {
    // Top-right outer corner
    UIImageView* corner = [[UIImageView alloc] initWithImage:_cornerImage];
    [corner setOrigin:CGPointMake(self.width - kCornerInset, -kBorderThickness)];
    [corner.layer setTransform:CATransform3DMakeScale(-1, 1, 1)];
    [self addSubview:corner];
  }
  
  if (self.NeighborS)
  {
    // Extend border to far bottom
    [border setHeight:border.height + kCornerInset];
  }
}

- (void) updateBottomOuterBorder
{
  // Bottom outer border
  UIView* border = [[UIView alloc] initWithFrame:CGRectMake(kCornerInset, self.height, self.width - kCornerInset * 2, kBorderThickness)];
  [border setBackgroundColor:_borderColor];
  [self addSubview:border];
  
  if (self.NeighborE)
  {
    // Extend border to far right
    [border setWidth:border.width + kCornerInset];
  }
  else
  {
    // Bottom-right outer corner
    UIImageView* corner = [[UIImageView alloc] initWithImage:_cornerImage];
    [corner setOrigin:CGPointMake(self.width - kCornerInset, self.height - kCornerInset)];
    [corner.layer setTransform:CATransform3DMakeScale(-1, -1, 1)];
    [self addSubview:corner];
  }
  
  if (self.NeighborW)
  {
    // Extend border to far left
    [border setOriginX:border.originX - kCornerInset];
    [border setWidth:border.width + kCornerInset];
  }
}

- (void) updateLeftOuterBorder
{
  // Left outer border
  UIView* border = [[UIView alloc] initWithFrame:CGRectMake(-kBorderThickness, kCornerInset, kBorderThickness, self.height - kCornerInset * 2)];
  [border setBackgroundColor:_borderColor];
  [self addSubview:border];
  
  if (self.NeighborS)
  {
    // Extend border to far bottom
    [border setHeight:border.height + kCornerInset];
  }
  else
  {
    // Bottom-left outer corner
    UIImageView* corner = [[UIImageView alloc] initWithImage:_cornerImage];
    [corner setOrigin:CGPointMake(-kBorderThickness, self.height - kCornerInset)];
    [corner.layer setTransform:CATransform3DMakeScale(1, -1, 1)];
    [self addSubview:corner];
  }
  
  if (self.NeighborN)
  {
    // Extend border to far top
    [border setOriginY:border.originY - kCornerInset];
    [border setHeight:border.height + kCornerInset];
  }
}

@end
