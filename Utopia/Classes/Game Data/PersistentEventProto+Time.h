//
//  PersistentEventProto+Time.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/21/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "Task.pb.h"

@interface PersistentEventProto (Time)

- (NSDate *) startTime;
- (NSDate *) endTime;
- (NSDate *) cooldownEndTime;
- (BOOL) isRunning;

@end
