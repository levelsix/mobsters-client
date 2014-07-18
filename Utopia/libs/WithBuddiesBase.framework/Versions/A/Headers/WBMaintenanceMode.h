//
//  WBMaintenanceMode.h
//  WithBuddiesCore
//
//  Created by justin stofle on 5/22/12.
//  Copyright (c) 2012 WithBuddies. All rights reserved.
//

#import <WithBuddiesBase/WBObject.h>

extern NSString *const WBMaintenanceModeChangedNotification;

@interface WBMaintenanceMode : WBObject

@property (nonatomic, strong, readonly) NSString *message;
@property (nonatomic, strong, readonly) NSDate *upDate;
@property (nonatomic, strong, readonly) NSString *status;
@property (nonatomic, strong, readonly) NSArray *platforms;

+(void)setMaintenanceMode:(WBMaintenanceMode *)maintenanceMode;
+(WBMaintenanceMode *)maintenanceMode;
-(NSString *)formattedUpDate;

@end
