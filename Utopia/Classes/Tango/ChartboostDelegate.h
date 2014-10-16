//
//  ChartboostDelegate.h
//  Utopia
//
//  Created by Ashwin on 10/15/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Chartboost/Chartboost.h>

@interface ChartboostDelegate : NSObject <ChartboostDelegate>

+ (void) setUpChartboost;

+ (void) firePvpMatch;
+ (void) firePveMatch;
+ (void) fireAchievementRedeemed;
+ (void) fireMiniJobSent;

@end
