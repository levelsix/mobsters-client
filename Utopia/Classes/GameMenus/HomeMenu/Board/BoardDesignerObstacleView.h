//
//  BoardDesignerObstacleView.h
//  Utopia
//
//  Created by Behrouz N. on 3/4/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BoardDesignerObstacleView : UIView
{
  NSString* _obstacleImage;
}

@property (nonatomic, retain) IBOutlet UIImageView* obstacleImageView;
@property (nonatomic, retain) IBOutlet UILabel* obstacleNameLabel;
@property (nonatomic, retain) IBOutlet UILabel* obstaclePowerLabel;
@property (nonatomic, retain) IBOutlet UILabel* obstaclePowerCostLabel;
@property (nonatomic, retain) IBOutlet UIImageView* lockImageView;
@property (nonatomic, retain) IBOutlet UILabel* lockLabel;

+ (instancetype) viewWithObstacleImage:(NSString*)image name:(NSString*)name andPowerCost:(NSInteger)powerCost;

- (void) disableObstacle;
- (void) enableObstacle;
- (void) lockObstacle;
- (void) unlockObstacle;

@end
