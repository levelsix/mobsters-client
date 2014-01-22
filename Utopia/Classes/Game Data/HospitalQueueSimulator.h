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
@property (nonatomic, retain) NSDate *upgradeCompleteDate;
@property (nonatomic, assign) int userStructId;

- (id) initWithHospital:(UserStruct *)hospital;

@end

@interface HealingItemSim : NSObject

@property (nonatomic, assign) int userMonsterId;
@property (nonatomic, assign) float healthProgress;
@property (nonatomic, assign) int totalHealthToHeal;
@property (nonatomic, retain) NSDate *queueTime;
@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, assign) int userStructId;

@property (nonatomic, assign) int isFinished;
@property (nonatomic, assign) float totalSeconds;
@property (nonatomic, retain) NSMutableArray *timeDistribution;
@property (nonatomic, retain) NSDate *endTime;

- (id) initWithHealingItem:(UserMonsterHealingItem *)healingItem;

@end

@interface HospitalQueueSimulator : NSObject

@property (nonatomic, retain) NSArray *hospitals;
@property (nonatomic, retain) NSArray *healingItems;

- (id) initWithHospitals:(NSArray *)hospitals healingItems:(NSArray *)healingItems;

- (void) simulateUntilDate:(NSDate *)date;
- (void) simulate;

@end
