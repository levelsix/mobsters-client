//
//  TimerAction.h
//  Utopia
//
//  Created by Ashwin on 10/7/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MSDate.h"
#import "UserData.h"

typedef enum {
  TimerProgressBarColorYellow = 1,
  TimerProgressBarColorGreen,
  TimerProgressBarColorPurple,
} TimerProgressBarColor;

@protocol TimerAction <NSObject>

- (NSString *) title;
- (int) secondsLeft;
- (int) totalSeconds;
- (int) gemCost;
- (TimerProgressBarColor) progressBarColor;

- (void) speedupClicked;

@end

@interface TimerAction : NSObject <TimerAction>

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) MSDate *completionDate;
@property (nonatomic, assign) int totalSeconds;
@property (nonatomic, assign) BOOL allowsFreeSpeedup;
@property (nonatomic, assign) TimerProgressBarColor normalProgressBarColor;

- (NSString *) confirmActionString;
- (void) performAction;

@end

@interface BuildingTimerAction : TimerAction

@property (nonatomic, retain) UserStruct *userStruct;

- (id) initWithUserStruct:(UserStruct *)us;

@end

@interface ObstacleTimerAction : TimerAction

@property (nonatomic, retain) UserObstacle *userObstacle;

- (id) initWithUserObstacle:(UserObstacle *)userObstacle;

@end

@interface HealingTimerAction : TimerAction

- (id) initWithHealingEndTime:(MSDate *)endTime totalSeconds:(int)totalSeconds;

@end

@interface MiniJobTimerAction : TimerAction

@property (nonatomic, retain) UserMiniJob *miniJob;

- (id) initWithMiniJob:(UserMiniJob *)miniJob;

@end

@interface EvolutionTimerAction : TimerAction

@property (nonatomic, retain) UserEvolution *userEvo;

- (id) initWithEvolution:(UserEvolution *)ue;

@end
