//
//  BattleItemQueue.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/9/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MSDate.h"
#import "Protocols.pb.h"

@interface BattleItemQueueObject : NSObject

@property (nonatomic, assign) int priority;
@property (nonatomic, retain) NSString *userUuid;
@property (nonatomic, assign) int battleItemId;
@property (nonatomic, retain) MSDate *expectedStartTime;
@property (nonatomic, assign) float elapsedTime;

- (BattleItemProto *) staticBattleItem;
- (int) totalSecondsToComplete;
- (MSDate *) expectedEndTime;

- (NSString *) battleItemQueueUuid;

- (BattleItemQueueForUserProto *) convertToProto;

@end

@interface BattleItemQueue : NSObject

@property (nonatomic, retain) NSMutableArray *queueObjects;

@property (nonatomic, assign) BOOL hasShownFreeSpeedup;
@property (nonatomic, retain) MSDate *queueEndTime;
@property (nonatomic, assign) float totalTimeForQueue;

- (void) addAllBattleItemQueueObjects:(NSArray *)objects;
- (void) addToEndOfQueue:(BattleItemQueueObject *)object;
- (void) removeFromQueue:(BattleItemQueueObject *)object;
- (void) updateElapsedTimesWithCompletedObjects:(NSArray *)objs;

- (void) readjustQueueObjects;

- (MSDate *) queueEndTime;
- (float) totalTimeForQueue;

@end
