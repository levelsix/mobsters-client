//
//  HospitalQueue.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/2/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MSDate.h"
#import "Protocols.pb.h"

@class UserMonster;

@interface UserMonsterHealingItem : NSObject

@property (nonatomic, retain) NSString *userMonsterUuid;
@property (nonatomic, retain) NSString *userUuid;
@property (nonatomic, retain) NSString *userHospitalStructUuid;
@property (nonatomic, retain) MSDate *queueTime;
@property (nonatomic, retain) MSDate *endTime;

@property (nonatomic, assign) float healthProgress;
@property (nonatomic, assign) int priority;
@property (nonatomic, assign) float totalSeconds;
@property (nonatomic, assign) float elapsedTime;
@property (nonatomic, retain) NSArray *timeDistribution;

+ (id) userMonsterHealingItemWithProto:(UserMonsterHealingProto *)proto;

- (UserMonster *)userMonster;
- (UserMonsterHealingProto *) convertToProto;

- (float) currentPercentage;

@end

@interface HospitalQueue : NSObject

@property (nonatomic, retain) NSMutableArray *healingItems;
@property (nonatomic, retain) MSDate *queueEndTime;
@property (nonatomic, assign) BOOL hasShownFreeHealingQueueSpeedup;
@property (nonatomic, assign) float totalTimeForHealQueue;
@property (nonatomic, retain) NSString *userHospitalStructUuid;

- (void) addUserMonsterHealingItemToEndOfQueue:(UserMonsterHealingItem *)item;
- (void) removeUserMonsterHealingItem:(UserMonsterHealingItem *)item;
- (void) addAllMonsterHealingProtos:(NSArray *)items;
- (void) saveHealthProgressesFromIndex:(NSInteger)index;
- (void) saveHealthProgressesFromIndex:(NSInteger)index withDate:(MSDate *)date;
- (void) readjustAllMonsterHealingProtos;

@end
