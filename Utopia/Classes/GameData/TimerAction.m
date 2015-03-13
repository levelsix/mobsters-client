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
#import "TeamViewController.h"
#import "ItemFactoryViewController.h"

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

- (NSArray *) speedupClicked:(UIView *)sender {
  return [self performSpeedup:sender];
}

- (BOOL) canGetHelp {
  return NO;
}

- (NSArray *) performSpeedup:(UIView *)sender {
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
    
    self.hasAskedForClanHelp = YES;
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

- (NSArray *) performSpeedup:(UIView *)sender {
  // Somewhat hacky, but super easy. Just let the home map deal with it
  GameViewController *gvc = [GameViewController baseController];
  HomeMap *hm = (HomeMap *)gvc.currentMap;
  if ([hm isKindOfClass:[HomeMap class]]) {
    [hm finishNow:self.userStruct sender:sender];
  }
  return nil;
}

- (void) performHelp {
  GameViewController *gvc = [GameViewController baseController];
  HomeMap *hm = (HomeMap *)gvc.currentMap;
  if ([hm isKindOfClass:[HomeMap class]]) {
    [hm getHelpClicked:self.userStruct];
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

- (NSArray *) performSpeedup:(UIView *)sender {
  GameViewController *gvc = [GameViewController baseController];
  HomeMap *hm = (HomeMap *)gvc.currentMap;
  if ([hm isKindOfClass:[HomeMap class]]) {
    [hm finishNow:self.userObstacle sender:sender];
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

- (id) initWithHospitalQueue:(HospitalQueue *)hq {
  if ((self = [super init])) {
    self.title = [NSString stringWithFormat:@"Healing %@s", MONSTER_NAME];
    self.normalProgressBarColor = TimerProgressBarColorGreen;
    self.allowsFreeSpeedup = YES;
    self.completionDate = hq.queueEndTime;
    self.totalSeconds = hq.totalTimeForHealQueue;
    self.hospitalQueue = hq;
  }
  return self;
}

- (BOOL) canGetHelp {
  GameState *gs = [GameState sharedGameState];
  //  for (UserMonsterHealingItem *hi in self.hospitalQueue.healingItems) {
  if (self.hospitalQueue.healingItems.count) {
    UserMonsterHealingItem *hi = self.hospitalQueue.healingItems[0];
    if ([gs.clanHelpUtil getNumClanHelpsForType:GameActionTypeHeal userDataUuid:hi.userMonsterUuid] < 0) {
      return YES;
    }
  }
  return NO;
}

- (NSArray *) performSpeedup:(UIView *)sender {
  HealViewController *hvc = [[HealViewController alloc] init];
  hvc.fakeHospitalQueue = self.hospitalQueue;
  [hvc speedupButtonClicked:sender];
  
  return @[hvc];
}

- (void) performHelp {
  HealViewController *hvc = [[HealViewController alloc] init];
  hvc.fakeHospitalQueue = self.hospitalQueue;
  [hvc getHelpClicked:nil];
}

- (BOOL) isEqual:(id)object {
  return [self class] == [object class] && [self.hospitalQueue.userHospitalStructUuid isEqualToString:[object hospitalQueue].userHospitalStructUuid];
}

- (NSUInteger) hash {
  return self.hospitalQueue.userHospitalStructUuid.hash;
}

@end

@implementation BattleItemTimerAction

- (id) initWithBattleItemQueue:(BattleItemQueue *)biq {
  if ((self = [super init])) {
    self.title = @"Creating Items";
    self.normalProgressBarColor = TimerProgressBarColorGreen;
    self.allowsFreeSpeedup = YES;
    self.completionDate = biq.queueEndTime;
    self.totalSeconds = biq.totalTimeForQueue;
    self.battleItemQueue = biq;
  }
  return self;
}

- (BOOL) canGetHelp {
  GameState *gs = [GameState sharedGameState];
  //  for (BattleItemQueueObject *hi in self.battleItemQueue.queueObjects) {
  if (self.battleItemQueue.queueObjects.count) {
    BattleItemQueueObject *hi = self.battleItemQueue.queueObjects[0];
    if ([gs.clanHelpUtil getNumClanHelpsForType:GameActionTypeCreateBattleItem userDataUuid:hi.battleItemQueueUuid] < 0) {
      return YES;
    }
  }
  return NO;
}

- (NSArray *) performSpeedup:(UIView *)sender {
  ItemFactoryViewController *hvc = [[ItemFactoryViewController alloc] init];
  [hvc speedupButtonClicked:sender];
  
  return @[hvc];
}

- (void) performHelp {
  ItemFactoryViewController *hvc = [[ItemFactoryViewController alloc] init];
  [hvc getHelpClicked:nil];
}

- (BOOL) isEqual:(id)object {
  return [self class] == [object class];
}

- (NSUInteger) hash {
  return 9203;
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

- (NSArray *) performSpeedup:(UIView *)sender {
  EnhanceQueueViewController *evc = [[EnhanceQueueViewController alloc] initWithCurrentEnhancement];
  [evc finishClicked:sender];
  
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

- (NSArray *) performSpeedup:(UIView *)sender {
  MiniJobsListViewController *lvc = [[MiniJobsListViewController alloc] init];
  MiniJobsListCell *cell = [[MiniJobsListCell alloc] init];
  cell.userMiniJob = self.miniJob;
  [lvc miniJobsListFinishClicked:cell invokingView:sender popupDirection:ViewAnchoringDirectionNone];
  
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

- (NSArray *) performSpeedup:(UIView *)sender {
  EvolveDetailsViewController *evc = [[EvolveDetailsViewController alloc] initWithCurrentEvolution];
  [evc speedupClicked:sender];
  
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

@implementation CombineMonsterTimerAction

- (id) initWithUserMonster:(UserMonster *)um {
  if ((self = [super init])) {
    self.userMonster = um;
    
    MonsterProto *mp = self.userMonster.staticMonster;
    self.title = @"Combining";
    self.normalProgressBarColor = TimerProgressBarColorGreen;
    self.allowsFreeSpeedup = YES;
    self.completionDate = [MSDate dateWithTimeIntervalSinceNow:um.timeLeftForCombining];
    self.totalSeconds = mp.minutesToCombinePieces*60;
  }
  return self;
}

- (BOOL) canGetHelp {
  return NO;
}

- (NSArray *) performSpeedup:(UIView *)sender {
  TeamViewController *tvc = [[TeamViewController alloc] init];
  [tvc speedupClicked:self.userMonster invokingView:sender indexPath:nil];
  
  return @[tvc];
}

- (void) performHelp {
  // Do nothing
}

- (BOOL) isEqual:(id)object {
  return [self class] == [object class] && [self.userMonster.userMonsterUuid isEqualToString:[object userMonster].userMonsterUuid];
}

- (NSUInteger) hash {
  return (NSUInteger)self.userMonster.userMonsterUuid.hash;
}

@end
