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
  self.actionName.text = goalProto.goalDesc;
  self.actionPoints.text = [NSString stringWithFormat:@"%@ Point%@", [Globals commafyNumber:goalProto.pointsGained], goalProto.pointsGained == 1 ? @"": @"s"];
}

@end
