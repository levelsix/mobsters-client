//
//  MiniEventPointsActionCell.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 3/25/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "MiniEventPointsActionCell.h"
#import "Globals.h"

@implementation MiniEventPointsActionCell

- (void) updateForAction:(MiniEventGoalProto*)goalProto
{
  // From UITableViewCell Class Reference: In iOS 7, cells have a white background by default;
  // in earlier versions of iOS, cells inherit the background color of the enclosing table view.
  self.backgroundColor = [UIColor clearColor];
  
  self.actionName.text = goalProto.goalDesc;
  self.actionPoints.text = [[Globals commafyNumber:goalProto.pointsGained] stringByAppendingString:@" Points"];
}

@end
