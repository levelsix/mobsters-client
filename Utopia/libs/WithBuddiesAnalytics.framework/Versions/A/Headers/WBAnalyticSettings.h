//
//  WBAnalyticSettings.h
//  WithBuddiesAnalytics
//
//  Created by odyth on 3/21/14.
//  Copyright (c) 2014 Scopely. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WithBuddiesAnalytics/WBAnalyticBuildType.h>

@interface WBAnalyticSettings : NSObject

@property (nonatomic) BOOL allowUseOfAdvertisingIdentifier; //defaults to YES
@property (nonatomic) WBAnalyticBuildType buildType; //defaults to WBAnalyticEventBuildTypeProduction

@end
