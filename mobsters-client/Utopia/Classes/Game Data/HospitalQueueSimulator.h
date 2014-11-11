//
//  HospitalQueueSimulator.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/13/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserData.h"

@interface HospitalSim : NSObject

@property (nonatomic, assign) float healthPerSecond;
@property (nonatomic, retain) MSDate *upgradeCompleteDate;
@property (nonatomic, assign) int userStructId;

- (id) initWithHospital:(UserStruct *)hospital;

@end

@interface HealingItemSim : NSObject

@property (nonatomic, assign) uint64_t userMonsterId;
@property (nonatomic, assign) float healthProgress;
@property (nonatomic, assign) int totalHealthToHeal;
@property (nonatomic, retain) MSDate *queueTime;
@property (nonatomic, assign) int userStructId;

@property (nonatomic, assign) int isFinished;
@property (nonatomic, assign) float totalSeconds;
@property (nonatomic, assign) float waitingSeconds;
@property (nonatomic, retain) NSMutableArray *timeDistribution;

// Used for intermediate steps
@property (nonatomic, retain) MSDate *startTime;
@property (nonatomic, retain) MSDate *endTime;

- (id) initWithHealingItem:(UserMonsterHealingItem *)healingItem;

@end

@interface HospitalQueueSimulator : NSObject

@property (nonatomic, retain) NSArray *hospitals;
@property (nonatomic, retain) NSArray *healingItems;

- (id) initWithHospitals:(NSArray *)hospitals healingItems:(NSArray *)healingItems;

- (void) simulateUntilDate:(MSDate *)date;
- (void) simulate;

@end
