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
#import "Structure.pb.h"

static const int kBorderThickness = 2;
static const int kCornerSize = 8;
static const int kCornerInset = kCornerSize - kBorderThickness;
static const int kObstacleInset = 2;

@implementation BoardDesignerTile

- (instancetype) initWithFrame:(CGRect)frame darkBaseColor:(BOOL)dark
{
  if (self = [super initWithFrame:frame])
  {
    _baseColorIsDark = dark;
    _baseColor = dark ? [UIColor colorWithHexString:@"353F3F"] : [UIColor colorWithHexString:@"3C4747"];
    _borderColor = [UIColor colorWithHexString:@"181B1C"];
    _outerCornerImage = [UIImage imageNamed:@"boardeditorcorner.png"];
    _innerCornerImage = dark ? [UIImage imageNamed:@"boardeditorcornerlight.png"] : [UIImage imageNamed:@"boardeditorcornerdark.png"];
    _obstacleImageView = nil;
    _obstacleProto = nil;
    
    _isHole = NO;
    _isOccupied = NO;
    
    self.NeighborN = nil;
    self.NeighborS = nil;
    self.NeighborW = nil;
    self.NeighborE = nil;
  }
  return self;
}

- (void) updateBorders
{
  // Remove all subviews
  [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
  
  if (self.isHole)
  {
    self.backgroundColor = [UIColor clearColor];
    
    [self updateInnerBorders];
  }
  else
  {
    self.backgroundColor = _baseColor;
    
    [self updateOuterBorders];
    
    if (_obstacleImageView)
    {
      [self addSubview:_obstacleImageView];
    }
  }
}

- (void) updateOuterBorders
{
  if (![self hasNeighborN])
  {
    [self updateTopOuterBorder];
  }
  if (![self hasNeighborE])
  {
    [self updateRightOuterBorder];
  }
  if (![self hasNeighborS])
  {
    [self updateBottomOuterBorder];
  }
  if (![self hasNeighborW])
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
  
  if (![self hasNeighborW])
  {
    // Top-left outer corner
    UIImageView* corner = [[UIImageView alloc] initWithImage:_outerCornerImage];
    [corner setOrigin:CGPointMake(-kBorderThickness, -kBorderThickness)];
    [self addSubview:corner];
  }
  else if (![self.NeighborW hasNeighborN])
  {
    // Extend border to far left
    [border setOriginX:border.originX - kCornerInset];
    [border setWidth:border.width + kCornerInset];
  }
  
  if ([self hasNeighborE] && ![self.NeighborE hasNeighborN])
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
  
  if (![self hasNeighborN])
  {
    // Top-right outer corner
    UIImageView* corner = [[UIImageView alloc] initWithImage:_outerCornerImage];
    [corner setOrigin:CGPointMake(self.width - kCornerInset, -kBorderThickness)];
    [corner.layer setTransform:CATransform3DMakeScale(-1, 1, 1)];
    [self addSubview:corner];
  }
  else if (![self.NeighborN hasNeighborE])
  {
    // Extend border to far top
    [border setOriginY:border.originY - kCornerInset];
    [border setHeight:border.height + kCornerInset];
  }
  
  if ([self hasNeighborS] && ![self.NeighborS hasNeighborE])
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
  
  if (![self hasNeighborE])
  {
    // Bottom-right outer corner
    UIImageView* corner = [[UIImageView alloc] initWithImage:_outerCornerImage];
    [corner setOrigin:CGPointMake(self.width - kCornerInset, self.height - kCornerInset)];
    [corner.layer setTransform:CATransform3DMakeScale(-1, -1, 1)];
    [self addSubview:corner];
  }
  else if (![self.NeighborE hasNeighborS])
  {
    // Extend border to far right
    [border setWidth:border.width + kCornerInset];
  }
  
  if ([self hasNeighborW] && ![self.NeighborW hasNeighborS])
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
  
  if (![self hasNeighborS])
  {
    // Bottom-left outer corner
    UIImageView* corner = [[UIImageView alloc] initWithImage:_outerCornerImage];
    [corner setOrigin:CGPointMake(-kBorderThickness, self.height - kCornerInset)];
    [corner.layer setTransform:CATransform3DMakeScale(1, -1, 1)];
    [self addSubview:corner];
  }
  else if (![self.NeighborS hasNeighborW])
  {
    // Extend border to far bottom
    [border setHeight:border.height + kCornerInset];
  }
  
  if ([self hasNeighborN] && ![self.NeighborN hasNeighborW])
  {
    // Extend border to far top
    [border setOriginY:border.originY - kCornerInset];
    [border setHeight:border.height + kCornerInset];
  }
}

- (void) updateInnerBorders
{
  if ([self hasNeighborN] && [self hasNeighborW] && [self.NeighborN hasNeighborW])
  {
    // Top-left inner corner
    UIImageView* corner = [[UIImageView alloc] initWithImage:_innerCornerImage];
    [corner setOrigin:CGPointMake(0, 0)];
    [self addSubview:corner];
  }
  
  if ([self hasNeighborE] && [self hasNeighborN] && [self.NeighborE hasNeighborN])
  {
    // Top-right inner corner
    UIImageView* corner = [[UIImageView alloc] initWithImage:_innerCornerImage];
    [corner setOrigin:CGPointMake(self.width - kCornerSize, 0)];
    [corner.layer setTransform:CATransform3DMakeScale(-1, 1, 1)];
    [self addSubview:corner];
  }
  
  if ([self hasNeighborS] && [self hasNeighborE] && [self.NeighborS hasNeighborE])
  {
    // Bottom-right inner corner
    UIImageView* corner = [[UIImageView alloc] initWithImage:_innerCornerImage];
    [corner setOrigin:CGPointMake(self.width - kCornerSize, self.height - kCornerSize)];
    [corner.layer setTransform:CATransform3DMakeScale(-1, -1, 1)];
    [self addSubview:corner];
  }
  
  if ([self hasNeighborW] && [self hasNeighborS] && [self.NeighborW hasNeighborS])
  {
    // Bottom-left inner corner
    UIImageView* corner = [[UIImageView alloc] initWithImage:_innerCornerImage];
    [corner setOrigin:CGPointMake(0, self.height - kCornerSize)];
    [corner.layer setTransform:CATransform3DMakeScale(1, -1, 1)];
    [self addSubview:corner];
  }
}

- (BOOL) canAcceptObstacle
{
  // TODO - Logic for allowing certain obstacles to stack
  
  return !self.isOccupied && !self.isHole;
}

- (void) addObstacle:(PvpBoardObstacleProto*)obstacleProto withImage:(UIImage*)obstacleImage
{
  _obstacleProto = obstacleProto;
  _obstacleImageView = [[UIImageView alloc] initWithImage:obstacleImage];
  
  if (obstacleProto.obstacleType == BoardObstacleTypeHole)
  {
    _isHole = YES;
  }
  else
  {
    [_obstacleImageView setFrame:CGRectMake(kObstacleInset, kObstacleInset, self.width - kObstacleInset * 2, self.height - kObstacleInset * 2)];
    [self addSubview:_obstacleImageView];
    
    _isOccupied = YES;
  }
}

- (UIImage*) removeObstacle
{
  UIImage* ret = _obstacleImageView.image;
  
  if (_obstacleProto.obstacleType == BoardObstacleTypeHole)
  {
    _isHole = NO;
  }
  else
  {
    [_obstacleImageView removeFromSuperview];
    
    _isOccupied = NO;
  }
  
  _obstacleImageView = nil;
  _obstacleProto = nil;
  
  return ret;
}

- (BOOL) hasNeighborN
{
  return (self.NeighborN && !self.NeighborN.isHole);
}

- (BOOL) hasNeighborS
{
  return (self.NeighborS && !self.NeighborS.isHole);
}

- (BOOL) hasNeighborW
{
  return (self.NeighborW && !self.NeighborW.isHole);
}

- (BOOL) hasNeighborE
{
  return (self.NeighborE && !self.NeighborE.isHole);
}

@end
