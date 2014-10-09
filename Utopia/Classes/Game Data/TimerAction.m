//
//  TimerAction.m
//  Utopia
//
//  Created by Ashwin on 10/7/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "TimerAction.h"

#import "Globals.h"
#import "GameState.h"
#import "GenericPopupController.h"
#import "GameViewController.h"
#import "HomeMap.h"
#import "HealViewController.h"
#import "MiniJobsListViewController.h"
#import "EvolveDetailsViewController.h"

@implementation TimerAction

- (int) secondsLeft {
  return self.completionDate.timeIntervalSinceNow;
}

- (int) gemCost {
  Globals *gl = [Globals sharedGlobals];
  return [gl calculateGemSpeedupCostForTimeLeft:[self secondsLeft] allowFreeSpeedup:self.allowsFreeSpeedup];
}

- (TimerProgressBarColor) progressBarColor {
  if ([self gemCost] || !self.allowsFreeSpeedup) {
    return self.normalProgressBarColor;
  } else {
    return TimerProgressBarColorPurple;
  }
}

- (void) speedupClicked {
  GameState *gs = [GameState sharedGameState];
  int gemCost = [self gemCost];
  NSString *confirm = [self confirmActionString];
  if ([self gemCost] > gs.gems) {
    [GenericPopupController displayNotEnoughGemsView];
  } else if (gemCost && confirm) {
    [GenericPopupController displayGemConfirmViewWithDescription:confirm title:@"Speedup?" gemCost:gemCost target:self selector:@selector(performAction)];
  } else {
    [self performAction];
  }
}

- (NSString *) confirmActionString {
  return nil;
}

- (void) performAction {
  // We can assume we have enough gems at this point
}

- (NSComparisonResult) compare:(TimerAction *)object {
  int thisGemCost = [self gemCost];
  int otherGemCost = [object gemCost];
  
  if (thisGemCost != otherGemCost) {
    return [@(thisGemCost) compare:@(otherGemCost)];
  }
  
  return [self.completionDate compare:object.completionDate];
}

- (BOOL) isEqual:(id)object {
  // For now, since only 1 timer can exist for each, just check the class.
  return [self class] == [object class] && [self secondsLeft] == [object secondsLeft];
}

- (NSUInteger) hash {
  return [self secondsLeft]*31+[self gemCost]*19+self.normalProgressBarColor*97;
}

@end

@implementation BuildingTimerAction

- (id) initWithUserStruct:(UserStruct *)us {
  if ((self = [super init])) {
    self.userStruct = us;
    
    self.title = self.userStruct.staticStruct.structInfo.name;
    self.normalProgressBarColor = TimerProgressBarColorYellow;
    self.allowsFreeSpeedup = YES;
    self.completionDate = self.userStruct.buildCompleteDate;
    self.totalSeconds = self.userStruct.staticStruct.structInfo.minutesToBuild*60;
  }
  return self;
}

- (void) performAction {
  // Somewhat hacky, but super easy. Just let the home map deal with it
  GameViewController *gvc = [GameViewController baseController];
  HomeMap *hm = (HomeMap *)gvc.currentMap;
  if ([hm isKindOfClass:[HomeMap class]]) {
    [hm finishNowClicked:nil];
  }
}

@end

@implementation ObstacleTimerAction

- (id) initWithUserObstacle:(UserObstacle *)userObstacle {
  if ((self = [super init])) {
    self.userObstacle = userObstacle;
    
    self.title = self.userObstacle.staticObstacle.name;
    self.normalProgressBarColor = TimerProgressBarColorYellow;
    self.allowsFreeSpeedup = NO;
    self.completionDate = self.userObstacle.endTime;
    self.totalSeconds = self.userObstacle.staticObstacle.secondsToRemove;
  }
  return self;
}

- (void) performAction {
  GameViewController *gvc = [GameViewController baseController];
  HomeMap *hm = (HomeMap *)gvc.currentMap;
  if ([hm isKindOfClass:[HomeMap class]]) {
    [hm finishNowClicked:nil];
  }
}

@end

@implementation HealingTimerAction

- (id) initWithHealingEndTime:(MSDate *)endTime totalSeconds:(int)totalSeconds {
  if ((self = [super init])) {
    self.title = [NSString stringWithFormat:@"Healing %@s", MONSTER_NAME];
    self.normalProgressBarColor = TimerProgressBarColorGreen;
    self.allowsFreeSpeedup = YES;
    self.completionDate = endTime;
    self.totalSeconds = totalSeconds;
  }
  return self;
}

- (NSString *) confirmActionString {
  return [NSString stringWithFormat:@"Would you like to speedup your hospital queue for %d gem%@?" , [self gemCost], [self gemCost] == 1 ? @"" : @"s"];
}

- (void) performAction {
  HealViewController *hvc = [[HealViewController alloc] init];
  [hvc speedupButtonClicked:nil];
}

@end

@implementation MiniJobTimerAction

- (id) initWithMiniJob:(UserMiniJob *)miniJob {
  if ((self = [super init])) {
    self.miniJob = miniJob;
    
    self.title = self.miniJob.miniJob.name;
    self.normalProgressBarColor = TimerProgressBarColorGreen;
    self.allowsFreeSpeedup = YES;
    self.completionDate = [self.miniJob.timeStarted dateByAddingTimeInterval:self.miniJob.durationMinutes*60];
    self.totalSeconds = self.miniJob.durationMinutes*60;
  }
  return self;
}

- (NSString *) confirmActionString {
  return [NSString stringWithFormat:@"Would you like to speedup your %@ for %d gem%@?" , self.title, [self gemCost], [self gemCost] == 1 ? @"" : @"s"];
}

- (void) performAction {
  MiniJobsListViewController *lvc = [[MiniJobsListViewController alloc] init];
  MiniJobsListCell *cell = [[MiniJobsListCell alloc] init];
  cell.userMiniJob = self.miniJob;
  [lvc miniJobsListFinishClicked:cell];
}

@end

@implementation EvolutionTimerAction

- (id) initWithEvolution:(UserEvolution *)ue {
  if ((self = [super init])) {
    self.userEvo = ue;
    
    MonsterProto *mp = self.userEvo.evoItem.userMonster1.staticMonster;
    self.title = mp.monsterName;
    self.normalProgressBarColor = TimerProgressBarColorGreen;
    self.allowsFreeSpeedup = YES;
    self.completionDate = self.userEvo.endTime;
    self.totalSeconds = mp.minutesToEvolve*60;
  }
  return self;
}

- (NSString *) confirmActionString {
  return [NSString stringWithFormat:@"Would you like to speedup %@'s evolution for %d gem%@?" , self.title, [self gemCost], [self gemCost] == 1 ? @"" : @"s"];
}

- (void) performAction {
  EvolveDetailsViewController *evc = [[EvolveDetailsViewController alloc] initWithCurrentEvolution];
  [evc speedupClicked:nil];
}

@end
