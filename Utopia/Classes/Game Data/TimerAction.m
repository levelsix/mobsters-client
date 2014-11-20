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

- (NSArray *) speedupClicked {
  GameState *gs = [GameState sharedGameState];
  int gemCost = [self gemCost];
  NSString *confirm = [self confirmActionString];
  // Disabled since the item select popup will show up
  if (false && [self gemCost] > gs.gems) {
    [GenericPopupController displayNotEnoughGemsView];
  }
  else if (false && gemCost && confirm) {
    [GenericPopupController displayGemConfirmViewWithDescription:confirm title:@"Speedup?" gemCost:gemCost target:self selector:@selector(performSpeedup)];
  }
  else {
    return [self performSpeedup];
  }
  return nil;
}

- (NSString *) confirmActionString {
  return nil;
}

- (BOOL) canGetHelp {
  return NO;
}

- (NSArray *) performSpeedup {
  // We can assume we have enough gems at this point
  return nil;
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
  return [gs.clanHelpUtil getNumClanHelpsForType:GameActionTypeUpgradeStruct userDataUuid:self.userStruct.userStructUuid] < 0;
}

- (NSArray *) performSpeedup {
  // Somewhat hacky, but super easy. Just let the home map deal with it
  GameViewController *gvc = [GameViewController baseController];
  HomeMap *hm = (HomeMap *)gvc.currentMap;
  if ([hm isKindOfClass:[HomeMap class]]) {
    [hm finishNowClicked:nil];
  }
  return nil;
}

- (void) performHelp {
  GameViewController *gvc = [GameViewController baseController];
  HomeMap *hm = (HomeMap *)gvc.currentMap;
  if ([hm isKindOfClass:[HomeMap class]]) {
    [hm getHelpClicked:nil];
  }
}

- (BOOL) isEqual:(id)object {
  return [self class] == [object class] && [self.userStruct.userStructUuid isEqualToString:[object userStruct].userStructUuid];
}

- (NSUInteger) hash {
  return self.userStruct.userStructUuid.hash;
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

- (NSArray *) performSpeedup {
  GameViewController *gvc = [GameViewController baseController];
  HomeMap *hm = (HomeMap *)gvc.currentMap;
  if ([hm isKindOfClass:[HomeMap class]]) {
    [hm finishNowClicked:nil];
  }
  return nil;
}

- (BOOL) isEqual:(id)object {
  return [self class] == [object class] && [self.userObstacle.userObstacleUuid isEqualToString:[object userObstacle].userObstacleUuid];
}

- (NSUInteger) hash {
  return self.userObstacle.userObstacleUuid.hash;
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
    if ([gs.clanHelpUtil getNumClanHelpsForType:GameActionTypeHeal userDataUuid:hi.userMonsterUuid] < 0) {
      return YES;
    }
  }
  return NO;
}

- (NSString *) confirmActionString {
  return [NSString stringWithFormat:@"Would you like to speedup your hospital queue for %d gem%@?" , [self gemCost], [self gemCost] == 1 ? @"" : @"s"];
}

- (NSArray *) performSpeedup {
  HealViewController *hvc = [[HealViewController alloc] init];
  [hvc speedupButtonClicked:nil];
  
  return @[hvc];
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
    
    self.title = @"Enhancing";
    self.normalProgressBarColor = TimerProgressBarColorGreen;
    self.allowsFreeSpeedup = YES;
    self.completionDate = self.userEnhancement.expectedEndTime;
    self.totalSeconds = self.userEnhancement.totalSeconds;
  }
  return self;
}

- (BOOL) canGetHelp {
  GameState *gs = [GameState sharedGameState];
  return [gs.clanHelpUtil getNumClanHelpsForType:GameActionTypeEnhanceTime userDataUuid:self.userEnhancement.baseMonster.userMonsterUuid] < 0;
}

- (NSString *) confirmActionString {
  return [NSString stringWithFormat:@"Would you like to speedup %@'s enhancement for %d gem%@?" , self.title, [self gemCost], [self gemCost] == 1 ? @"" : @"s"];
}

- (NSArray *) performSpeedup {
  EnhanceQueueViewController *evc = [[EnhanceQueueViewController alloc] initWithCurrentEnhancement];
  [evc finishClicked:nil];
  
  return @[evc];
}

- (void) performHelp {
  EnhanceQueueViewController *evc = [[EnhanceQueueViewController alloc] initWithCurrentEnhancement];
  [evc helpClicked:nil];
}

- (BOOL) isEqual:(id)object {
  return [self class] == [object class] && [self.userEnhancement.baseMonster.userMonsterUuid isEqualToString:[object userEnhancement].baseMonster.userMonsterUuid];
}

- (NSUInteger) hash {
  return self.userEnhancement.baseMonster.userMonsterUuid.hash;
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
  return [gs.clanHelpUtil getNumClanHelpsForType:GameActionTypeMiniJob userDataUuid:self.miniJob.userMiniJobUuid] < 0;
}

- (NSString *) confirmActionString {
  return [NSString stringWithFormat:@"Would you like to speedup your %@ for %d gem%@?" , self.title, [self gemCost], [self gemCost] == 1 ? @"" : @"s"];
}

- (NSArray *) performSpeedup {
  MiniJobsListViewController *lvc = [[MiniJobsListViewController alloc] init];
  MiniJobsListCell *cell = [[MiniJobsListCell alloc] init];
  cell.userMiniJob = self.miniJob;
  [lvc miniJobsListFinishClicked:cell];
  
  return @[lvc];
}

- (void) performHelp {
  MiniJobsListViewController *lvc = [[MiniJobsListViewController alloc] init];
  MiniJobsListCell *cell = [[MiniJobsListCell alloc] init];
  cell.userMiniJob = self.miniJob;
  [lvc miniJobsListHelpClicked:cell];
}

- (BOOL) isEqual:(id)object {
  return [self class] == [object class] && [self.miniJob.userMiniJobUuid isEqualToString:[(MiniJobTimerAction *)object miniJob].userMiniJobUuid];
}

- (NSUInteger) hash {
  return self.miniJob.userMiniJobUuid.hash;
}

@end

@implementation EvolutionTimerAction

- (id) initWithEvolution:(UserEvolution *)ue {
  if ((self = [super init])) {
    self.userEvo = ue;
    
    MonsterProto *mp = self.userEvo.evoItem.userMonster1.staticMonster;
    self.title = @"Evolving";
    self.normalProgressBarColor = TimerProgressBarColorGreen;
    self.allowsFreeSpeedup = YES;
    self.completionDate = self.userEvo.endTime;
    self.totalSeconds = mp.minutesToEvolve*60;
  }
  return self;
}

- (BOOL) canGetHelp {
  GameState *gs = [GameState sharedGameState];
  return [gs.clanHelpUtil getNumClanHelpsForType:GameActionTypeEvolve userDataUuid:self.userEvo.userMonsterUuid1] < 0;
}

- (NSString *) confirmActionString {
  return [NSString stringWithFormat:@"Would you like to speedup %@'s evolution for %d gem%@?" , self.title, [self gemCost], [self gemCost] == 1 ? @"" : @"s"];
}

- (NSArray *) performSpeedup {
  EvolveDetailsViewController *evc = [[EvolveDetailsViewController alloc] initWithCurrentEvolution];
  [evc speedupClicked:nil];
  
  return @[evc];
}

- (void) performHelp {
  EvolveDetailsViewController *evc = [[EvolveDetailsViewController alloc] initWithCurrentEvolution];
  [evc helpClicked:nil];
}

- (BOOL) isEqual:(id)object {
  return [self class] == [object class] && [self.userEvo.userMonsterUuid1 isEqualToString:[object userEvo].userMonsterUuid1];
}

- (NSUInteger) hash {
  return (NSUInteger)self.userEvo.userMonsterUuid1.hash;
}

@end
