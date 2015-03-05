//
//  BoardDesignerObstacleView.m
//  Utopia
//
//  Created by Behrouz N. on 3/4/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "BoardDesignerObstacleView.h"
#import "Globals.h"

@implementation BoardDesignerObstacleView

+ (instancetype) viewWithObstacleImage:(NSString*)image name:(NSString*)name andPowerCost:(NSInteger)powerCost
{
  BoardDesignerObstacleView* obstacleView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil][0];
  [obstacleView updateWithObstacleImage:image name:name andPowerCost:powerCost];
  return obstacleView;
}

- (void) updateWithObstacleImage:(NSString*)image name:(NSString*)name andPowerCost:(NSInteger)powerCost
{
  _obstacleImage = image;
  
  [self.obstacleImageView setImage:[UIImage imageNamed:image]];
  [self.obstacleNameLabel setText:[name uppercaseString]];
  [self.obstaclePowerCostLabel setText:[NSString stringWithFormat:@"%ld", (long)powerCost]];
}

- (void) disableObstacle
{
  [self.obstacleNameLabel setTextColor:[UIColor colorWithHexString:@"B2B2B2"]];
  [self.obstaclePowerLabel setTextColor:[UIColor colorWithHexString:@"B2B2B2"]];
  [self.obstaclePowerCostLabel setTextColor:[UIColor colorWithHexString:@"DB2C2C"]];
}

- (void) enableObstacle
{
  [self.obstacleNameLabel setTextColor:[UIColor colorWithHexString:@"00C2FF"]];
  [self.obstaclePowerLabel setTextColor:[UIColor colorWithHexString:@"6F9F11"]];
  [self.obstaclePowerCostLabel setTextColor:[UIColor colorWithHexString:@"6F9F11"]];
}

- (void) lockObstacle
{
  [Globals imageNamed:_obstacleImage withView:self.obstacleImageView maskedColor:[UIColor colorWithWhite:.85f alpha:1.f] indicator:0 clearImageDuringDownload:NO];
  [self.obstacleNameLabel setTextColor:[UIColor colorWithHexString:@"B2B2B2"]];
  
  [self.lockImageView setHidden:NO];
  [self.lockLabel setHidden:NO];
  [self.obstaclePowerLabel setHidden:YES];
  [self.obstaclePowerCostLabel setHidden:YES];
}

- (void) unlockObstacle
{
  [self.obstacleImageView setImage:[UIImage imageNamed:_obstacleImage]];
  [self.obstacleNameLabel setTextColor:[UIColor colorWithHexString:@"00C2FF"]];
  
  [self.lockImageView setHidden:YES];
  [self.lockLabel setHidden:YES];
  [self.obstaclePowerLabel setHidden:NO];
  [self.obstaclePowerCostLabel setHidden:NO];
}

@end
