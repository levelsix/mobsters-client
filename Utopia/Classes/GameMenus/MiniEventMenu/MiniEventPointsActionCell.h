//
//  MiniEventPointsActionCell.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 3/25/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MiniEventGoalProto;

@interface MiniEventPointsActionCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel* actionName;
@property (nonatomic, retain) IBOutlet UILabel* actionPoints;

- (void) updateForAction:(MiniEventGoalProto*)goalProto;

@end
