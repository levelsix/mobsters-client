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
#import "EnhanceQueueViewController.h"

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
    [GenericPopupController displayGemConfirmViewWithDescription:confirm title:@"Speedup?" gemCost:gemCost target:self selector:@selector(performSpeedup)];
  } else {
    [self performSpeedup];
  }
}

- (NSString *) confirmActionString {
  return nil;
}

- (BOOL) canGetHelp {
  return NO;
}

- (void) performSpeedup {
  // We can assume we have enough gems at this point
}

- (void) helpClicked {
  GameState *gs = [GameState sharedGameState];
  if ([gs canAskForClanHelp]) {
    [self performHelp];
  } else {
    UserStruct *us = gs.myClanHouse;
    
    NSString *structName = nil;
    if (!us) {
      for (id<StaticStructure> ss in gs.staticStructs.allValues) {
        if (ss.structInfo.structType == StructureInfoProto_StructTypeClan && !ss.structInfo.predecessorStructId) {
          structName = ss.structInfo.name;
        }
      }
    }
    
    [Globals addAlertNotification:[NSString stringWithFormat:@"You must be in a squad to ask for help. %@", us ? @"Join one now!" : [NSString stringWithFormat:@"Build a %@ now!", structName]] ];
  }
}

- (void) performHelp {
  // Ask for help
}

- (NSComparisonResult) compare:(TimerAction *)object {
  int thisGemCost = [self gemCost];
  int otherGemCost = [object gemCost];
  
  if (thisGemCost != otherGemCost) {
    return [@(thisGemCost) compare:@(otherGemCost)];
  }
  
  return [self.completionDate compare:object.completionDate];
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

- (BOOL) canGetHelp {
  GameState *gs = [GameState sharedGameState];
  return [gs.clanHelpUtil getNumClanHelpsForType:ClanHelpTypeUpgradeStruct userDataId:self.userStruct.userStructId] < 0;
}

- (void) performSpeedup {
  // Somewhat hacky, but super easy. Just let the home map deal with it
  GameViewController *gvc = [GameViewController baseController];
  HomeMap *hm = (HomeMap *)gvc.currentMap;
  if ([hm isKindOfClass:[HomeMap class]]) {
    [hm finishNowClicked:nil];
  }
}

- (void) performHelp {
  GameViewController *gvc = [GameViewController baseController];
  HomeMap *hm = (HomeMap *)gvc.currentMap;
  if ([hm isKindOfClass:[HomeMap class]]) {
    [hm getHelpClicked:nil];
  }
}

- (BOOL) isEqual:(id)object {
  return [self class] == [object class] && self.userStruct.userStructId == [object userStruct].userStructId;
}

- (NSUInteger) hash {
  return self.userStruct.userStructId*31;
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

- (void) performSpeedup {
  GameViewController *gvc = [GameViewController baseController];
  HomeMap *hm = (HomeMap *)gvc.currentMap;
  if ([hm isKindOfClass:[HomeMap class]]) {
    [hm finishNowClicked:nil];
  }
}

- (BOOL) isEqual:(id)object {
  return [self class] == [object class] && self.userObstacle.userObstacleId == [object userObstacle].userObstacleId;
}

- (NSUInteger) hash {
  return self.userObstacle.userObstacleId*97;
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

- (BOOL) canGetHelp {
  GameState *gs = [GameState sharedGameState];
  for (UserMonsterHealingItem *hi in gs.monsterHealingQueue) {
    if ([gs.clanHelpUtil getNumClanHelpsForType:ClanHelpTypeHeal userDataId:hi.userMonsterId] < 0) {
      return YES;
    }
  }
  return NO;
}

- (NSString *) confirmActionString {
  return [NSString stringWithFormat:@"Would you like to speedup your hospital queue for %d gem%@?" , [self gemCost], [self gemCost] == 1 ? @"" : @"s"];
}

- (void) performSpeedup {
  HealViewController *hvc = [[HealViewController alloc] init];
  [hvc speedupButtonClicked:nil];
}

- (void) performHelp {
  HealViewController *hvc = [[HealViewController alloc] init];
  [hvc getHelpClicked:nil];
}

- (BOOL) isEqual:(id)object {
  // There should only ever be one healing timer action
  return [self class] == [object class];
}

- (NSUInteger) hash {
  return 3747823;
}

@end

@implementation EnhancementTimerAction

- (id) initWithEnhancement:(UserEnhancement *)ue {
  if ((self = [super init])) {
    self.userEnhancement = ue;
    
    MonsterProto *mp = self.userEnhancement.baseMonster.userMonster.staticMonster;
    self.title = mp.monsterName;
    self.normalProgressBarColor = TimerProgressBarColorGreen;
    self.allowsFreeSpeedup = YES;
    self.completionDate = self.userEnhancement.expectedEndTime;
    self.totalSeconds = self.userEnhancement.totalSeconds;
  }
  return self;
}

- (BOOL) canGetHelp {
  GameState *gs = [GameState sharedGameState];
  return [gs.clanHelpUtil getNumClanHelpsForType:ClanHelpTypeEnhanceTime userDataId:self.userEnhancement.baseMonster.userMonsterId] < 0;
}

- (NSString *) confirmActionString {
  return [NSString stringWithFormat:@"Would you like to speedup %@'s enhancement for %d gem%@?" , self.title, [self gemCost], [self gemCost] == 1 ? @"" : @"s"];
}

- (void) performSpeedup {
  EnhanceQueueViewController *evc = [[EnhanceQueueViewController alloc] initWithCurrentEnhancement];
  [evc finishClicked:nil];
}

- (void) performHelp {
  EnhanceQueueViewController *evc = [[EnhanceQueueViewController alloc] initWithCurrentEnhancement];
  [evc helpClicked:nil];
}

- (BOOL) isEqual:(id)object {
  return [self class] == [object class] && self.userEnhancement.baseMonster.userMonsterId == [object userEnhancement].baseMonster.userMonsterId;
}

- (NSUInteger) hash {
  return (NSUInteger)self.userEnhancement.baseMonster.userMonsterId*17;
}

@end

@implementation MiniJobTimerAction

- (id) initWithMiniJob:(UserMiniJob *)miniJob {
  if ((self = [super init])) {
    self.miniJob = miniJob;
    
    self.title = self.miniJob.miniJob.name;
    self.normalProgressBarColor = TimerProgressBarColorGreen;
    self.allowsFreeSpeedup = YES;
    self.completionDate = self.miniJob.tentativeCompletionDate;
    self.totalSeconds = self.miniJob.durationSeconds;
  }
  return self;
}

- (BOOL) canGetHelp {
  GameState *gs = [GameState sharedGameState];
  return [gs.clanHelpUtil getNumClanHelpsForType:ClanHelpTypeMiniJob userDataId:self.miniJob.userMiniJobId] < 0;
}

- (NSString *) confirmActionString {
  return [NSString stringWithFormat:@"Would you like to speedup your %@ for %d gem%@?" , self.title, [self gemCost], [self gemCost] == 1 ? @"" : @"s"];
}

- (void) performSpeedup {
  MiniJobsListViewController *lvc = [[MiniJobsListViewController alloc] init];
  MiniJobsListCell *cell = [[MiniJobsListCell alloc] init];
  cell.userMiniJob = self.miniJob;
  [lvc miniJobsListFinishClicked:cell];
}

- (void) performHelp {
  MiniJobsListViewController *lvc = [[MiniJobsListViewController alloc] init];
  MiniJobsListCell *cell = [[MiniJobsListCell alloc] init];
  cell.userMiniJob = self.miniJob;
  [lvc miniJobsListHelpClicked:cell];
}

- (BOOL) isEqual:(id)object {
  return [self class] == [object class] && self.miniJob.userMiniJobId == [(MiniJobTimerAction *)object miniJob].userMiniJobId;
}

- (NSUInteger) hash {
  return (NSUInteger)self.miniJob.userMiniJobId*51;
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

- (BOOL) canGetHelp {
  GameState *gs = [GameState sharedGameState];
  return [gs.clanHelpUtil getNumClanHelpsForType:ClanHelpTypeEvolve userDataId:self.userEvo.userMonsterId1] < 0;
}

- (NSString *) confirmActionString {
  return [NSString stringWithFormat:@"Would you like to speedup %@'s evolution for %d gem%@?" , self.title, [self gemCost], [self gemCost] == 1 ? @"" : @"s"];
}

- (void) performSpeedup {
  EvolveDetailsViewController *evc = [[EvolveDetailsViewController alloc] initWithCurrentEvolution];
  [evc speedupClicked:nil];
}

- (void) performHelp {
  EvolveDetailsViewController *evc = [[EvolveDetailsViewController alloc] initWithCurrentEvolution];
  [evc helpClicked:nil];
}

- (BOOL) isEqual:(id)object {
  return [self class] == [object class] && self.userEvo.userMonsterId1 == [object userEvo].userMonsterId1;
}

- (NSUInteger) hash {
  return (NSUInteger)self.userEvo.userMonsterId1*19;
}

@end
