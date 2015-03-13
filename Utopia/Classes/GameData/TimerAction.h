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

- (BOOL) canGetHelp;
- (BOOL) hasAskedForClanHelp;

// Should return an array of dummy objects that will be retained
- (NSArray *) speedupClicked:(UIView *)sender;
- (void) helpClicked;

@end

@interface TimerAction : NSObject <TimerAction>

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) MSDate *completionDate;
@property (nonatomic, assign) int totalSeconds;
@property (nonatomic, assign) BOOL allowsFreeSpeedup;
@property (nonatomic, assign) TimerProgressBarColor normalProgressBarColor;

// Used in case squad doesn't exist so button can go away
@property (nonatomic, assign) BOOL hasAskedForClanHelp;

- (NSArray *) performSpeedup:(UIView *)sender;
- (void) performHelp;

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

@property (nonatomic, retain) HospitalQueue *hospitalQueue;

- (id) initWithHospitalQueue:(HospitalQueue *)hq;

@end

@interface BattleItemTimerAction : TimerAction

@property (nonatomic, retain) BattleItemQueue *battleItemQueue;

- (id) initWithBattleItemQueue:(BattleItemQueue *)biq;

@end

@interface EnhancementTimerAction : TimerAction

@property (nonatomic, retain) UserEnhancement *userEnhancement;

- (id) initWithEnhancement:(UserEnhancement *)ue;

@end

@interface MiniJobTimerAction : TimerAction

@property (nonatomic, retain) UserMiniJob *miniJob;

- (id) initWithMiniJob:(UserMiniJob *)miniJob;

@end

@interface EvolutionTimerAction : TimerAction

@property (nonatomic, retain) UserEvolution *userEvo;

- (id) initWithEvolution:(UserEvolution *)ue;

@end

@interface CombineMonsterTimerAction : TimerAction

@property (nonatomic, retain) UserMonster *userMonster;

- (id) initWithUserMonster:(UserMonster *)um;

@end
