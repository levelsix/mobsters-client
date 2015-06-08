//
//  UserData.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/9/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "UserData.h"
#import "GameState.h"
#import "Globals.h"
#import "OutgoingEventController.h"
#import "ResearchUtil.h"

@implementation MonsterProto (Name)

- (NSString *) monsterName {
  return self.hasShorterName ? self.shorterName : self.displayName;
}

@end

@implementation UserMonster

- (id) initWithMonsterProto:(FullUserMonsterProto *)proto researchUtil:(ResearchUtil *)researchUtil {
  if ((self = [super init])) {
    self.userUuid = proto.userUuid;
    self.monsterId = proto.monsterId;
    self.userMonsterUuid = proto.userMonsterUuid;
    self.level = proto.currentLvl;
    self.experience = proto.currentExp;
    self.teamSlot = proto.teamSlotNum;
    self.numPieces = proto.numPieces;
    self.isComplete = proto.isComplete;
    self.combineStartTime = [MSDate dateWithTimeIntervalSince1970:proto.combineStartTime/1000.];
    self.isProtected = proto.isRestrictd;
    self.offensiveSkillId = proto.offensiveSkillId;
    self.defensiveSkillId = proto.defensiveSkillId;
    
    self.researchUtil = researchUtil;
    
    Globals *gl = [Globals sharedGlobals];
    self.curHealth = MIN(proto.currentHealth, [gl calculateMaxHealthForMonster:self]);
  }
  return self;
}

+ (id) userMonsterWithProto:(FullUserMonsterProto *)proto researchUtil:(ResearchUtil *)researchUtil {
  return [[self alloc] initWithMonsterProto:proto researchUtil:researchUtil];
}

- (id) initWithMinMonsterProto:(MinimumUserMonsterProto *)proto researchUtil:(ResearchUtil *)researchUtil {
  if ((self = [super init])){
    self.monsterId = proto.monsterId;
    self.level = proto.monsterLvl;
    self.teamSlot = proto.teamSlotNum;
    
    self.offensiveSkillId = proto.offensiveSkillId;
    self.defensiveSkillId = proto.defensiveSkillId;
    
    self.isComplete = YES;
    
    self.researchUtil = researchUtil;
    
    Globals *gl = [Globals sharedGlobals];
    self.curHealth = [gl calculateMaxHealthForMonster:self];
  }
  return self;
}

+ (id) userMonsterWithMinProto:(MinimumUserMonsterProto *)proto researchUtil:(ResearchUtil *)researchUtil {
  return [[self alloc] initWithMinMonsterProto:proto researchUtil:researchUtil];
}

- (id) initWithTaskStageMonsterProto:(TaskStageMonsterProto *)proto {
  if ((self = [super init])){
    Globals *gl = [Globals sharedGlobals];
    self.monsterId = proto.monsterId;
    self.level = proto.level;
    self.curHealth = [gl calculateMaxHealthForMonster:self];
    self.defensiveSkillId = proto.defensiveSkillId;
    self.userMonsterUuid = proto.tsfuUuid;
  }
  return self;
}

+ (id) userMonsterWithTaskStageMonsterProto:(TaskStageMonsterProto *)proto {
  return [[self alloc] initWithTaskStageMonsterProto:proto];
}

- (id) initWithMonsterSnapshotProto:(UserMonsterSnapshotProto *)proto researchUtil:(ResearchUtil *)researchUtil {
  if ((self = [super init])){
    self.userMonsterUuid  = proto.monsterForUserUuid;
    self.monsterId = proto.monsterId;
    self.experience = proto.currentExp;
    self.level = proto.currentLvl;
    self.curHealth = proto.currentHp;
    self.offensiveSkillId = proto.offensiveSkillId;
    self.defensiveSkillId = proto.defensiveSkillId;
    self.isComplete = YES;
    
    self.researchUtil = researchUtil;
  }
  return self;
}

+ (id) userMonsterWithMonsterSnapshotProto:(UserMonsterSnapshotProto *)proto researchUtil:(ResearchUtil *)researchUtil {
  return [[self alloc] initWithMonsterSnapshotProto:proto researchUtil:researchUtil];
}

- (BOOL) isHealing {
  GameState *gs = [GameState sharedGameState];
  for (HospitalQueue *hq in gs.monsterHealingQueues.allValues) {
    for (UserMonsterHealingItem *item in hq.healingItems) {
      if ([item.userMonsterUuid isEqualToString:self.userMonsterUuid]) {
        return YES;
      }
    }
  }
  return NO;
}

- (BOOL) isEnhancing {
  GameState *gs = [GameState sharedGameState];
  return [self.userMonsterUuid isEqualToString:gs.userEnhancement.baseMonster.userMonsterUuid];
}

- (BOOL) isEvolving {
  GameState *gs = [GameState sharedGameState];
  NSString *i = self.userMonsterUuid;
  UserEvolution *evo = gs.userEvolution;
  return [evo.userMonsterUuid1 isEqualToString:i] || [evo.userMonsterUuid2 isEqualToString:i] || [evo.catalystMonsterUuid isEqualToString:i];
}

- (BOOL) isSacrificing {
  GameState *gs = [GameState sharedGameState];
  for (EnhancementItem *ei in gs.userEnhancement.feeders) {
    if ([self.userMonsterUuid isEqualToString:ei.userMonsterUuid]) {
      return YES;
    }
  }
  return NO;
}

- (BOOL) isOnAMiniJob {
  GameState *gs = [GameState sharedGameState];
  for (UserMiniJob *mj in gs.myMiniJobs) {
    if ([mj.userMonsterUuids containsObject:self.userMonsterUuid]) {
      return YES;
    }
  }
  return NO;
}

- (NSString *) statusString {
  NSString *str = @"";
  if (self.isHealing) {
    str = @"Healing";
  } else if (self.isEnhancing || self.isSacrificing) {
    str = @"Enhancing";
  } else if (self.isEvolving) {
    str = @"Evolving";
  } else if (self.isOnAMiniJob) {
    str = @"Mini Job";
  } else if (!self.isComplete) {
    if (self.isCombining) {
      str = @"Combining";
    } else {
      str = [NSString stringWithFormat:@"Pieces: %d/%d", self.numPieces, self.staticMonster.numPuzzlePieces];
    }
  } else if (self.isProtected) {
    str = @"Locked";
  }
  return str;
}

- (NSString *) statusImageName {
  NSString *str = nil;
  if (self.isHealing) {
    str = @"healingicon.png";
  } else if (self.isEnhancing || self.isSacrificing || self.isEvolving) {
    str = @"labbingicon.png";
  } else if (self.isOnAMiniJob) {
    str = @"jobbingicon.png";
  }
  return str;
}

- (BOOL) isAvailable {
  return self.isComplete && !self.isHealing && !self.isEnhancing && !self.isSacrificing && !self.isOnAMiniJob && !self.isEvolving;
}

- (BOOL) isAvailableForSelling {
  return (self.isAvailable || !self.isComplete) && !self.isProtected;
}

- (int) sellPrice {
  float min = self.minLevelInfo.sellAmount;
  float max = self.maxLevelInfo.sellAmount;
  int price = 1;
  
  if (self.isComplete) {
    price = min+((self.level-1)/(float)(self.staticMonster.maxLevel-1))*(max-min);
  } else {
    price = min*self.numPieces/(float)self.staticMonster.numPuzzlePieces;
  }
  return MAX(1, price);
}

- (int) teamCost {
  float min = self.minLevelInfo.teamCost;
  float max = self.maxLevelInfo.teamCost;
  
  return min+((self.level-1)/(float)(self.staticMonster.maxLevel-1))*(max-min);
}

- (int) feederExp {
  float min = self.minLevelInfo.feederExp;
  float max = self.maxLevelInfo.feederExp;
  
  return min+((self.level-1)/(float)(self.staticMonster.maxLevel-1))*(max-min);
}

- (int) speed {
  float min = self.minLevelInfo.speed;
  float max = self.maxLevelInfo.speed;
  
  return min+((self.level-1)/(float)(self.staticMonster.maxLevel-1))*(max-min);
}

- (void) setExperience:(int)experience {
  _experience = experience;
  
  Globals *gl = [Globals sharedGlobals];
  float newLevel = [gl calculateLevelForMonster:self.monsterId experience:experience];
  self.level = newLevel;
}

- (MonsterProto *) staticMonster {
  GameState *gs = [GameState sharedGameState];
  return [gs monsterWithId:self.monsterId];
}

- (MonsterProto *) staticEvolutionMonster {
  GameState *gs = [GameState sharedGameState];
  return [gs monsterWithId:self.staticMonster.evolutionMonsterId];
}

- (MonsterProto *) staticEvolutionCatalystMonster {
  GameState *gs = [GameState sharedGameState];
  return [gs monsterWithId:self.staticMonster.evolutionCatalystMonsterId];
}

- (MonsterLevelInfoProto *) minLevelInfo {
  NSArray *arr = self.staticMonster.lvlInfoList;
  return arr.count > 0 ? arr[0] : nil;
}

- (MonsterLevelInfoProto *) maxLevelInfo {
  NSArray *arr = self.staticMonster.lvlInfoList;
  return arr.count > 0 ? arr[arr.count-1] : nil;
}

- (BOOL) isCombining {
  return !self.isComplete && self.numPieces >= self.staticMonster.numPuzzlePieces;
}

- (int) timeLeftForCombining {
  GameState *gs = [GameState sharedGameState];
  
  int seconds = self.combineStartTime.timeIntervalSinceNow + self.staticMonster.minutesToCombinePieces*60;
  
  // Account for speedups
  int speedupMins = [gs.itemUtil getSpeedupMinutesForType:GameActionTypeCombineMonster userDataUuid:self.userMonsterUuid earliestDate:self.combineStartTime];
  if (speedupMins > 0) {
    seconds -= speedupMins*60;
  }
  
  return seconds;
}

- (BOOL) isEqual:(UserMonster *)object {
  if (![object respondsToSelector:@selector(userMonsterUuid)]) {
    return NO;
  }
  return [object.userMonsterUuid isEqualToString:self.userMonsterUuid];
}

- (NSUInteger) hash {
  return self.userMonsterUuid.hash;
}

- (NSComparisonResult) compare:(UserMonster *)um {
  if (self.isComplete != um.isComplete) {
    return [@(!self.isComplete) compare:@(!um.isComplete)];
  }
  if (!self.isComplete) {
    // Both are incomplete
    if (self.isCombining != um.isCombining) {
      // One is combining, other isn't
      return [@(!self.isCombining) compare:@(!um.isCombining)];
    } else if (self.isCombining) {
      // Both are combining
      return [@([self timeLeftForCombining]) compare:@([um timeLeftForCombining])];
    } else {
      // Both are not combining
      return [@(self.staticMonster.numPuzzlePieces-self.numPieces) compare:@(um.staticMonster.numPuzzlePieces-um.numPieces)];
    }
  }
  
  // Both are complete; check if healing or enhancing, then compare stats
  int selfScore = ![self isAvailable] ? 1 : 0;
  int umScore = ![um isAvailable] ? 1 : 0;
  
  if (selfScore != umScore) {
    return [@(selfScore) compare:@(umScore)];
  } else {
    // Compare hp
    Globals *gl = [Globals sharedGlobals];
    int selfStrength = [gl calculateStrengthForMonster:self];
    int umStrength = [gl calculateStrengthForMonster:um];
    
    // Ordering now becomes strength, curHp, rarity
    if (selfStrength != umStrength) {
      return [@(umStrength) compare:@(selfStrength)];
    } else if (self.curHealth != um.curHealth) {
      return [@(um.curHealth) compare:@(self.curHealth)];
    } else if (self.staticMonster.quality != um.staticMonster.quality) {
      return [@(um.staticMonster.quality) compare:@(self.staticMonster.quality)];
    } else {
      return [@(self.monsterId) compare:@(um.monsterId)];
    }
  }
}

- (id) copy {
  return [[UserMonster alloc] initWithMonsterProto:[self convertToProto] researchUtil:self.researchUtil];
}

- (FullUserMonsterProto *) convertToProto {
  FullUserMonsterProto_Builder *bldr = [FullUserMonsterProto builder];
  bldr.userMonsterUuid = self.userMonsterUuid;
  bldr.userUuid = self.userUuid;
  bldr.monsterId = self.monsterId;
  bldr.currentHealth = self.curHealth;
  bldr.currentExp = self.experience;
  bldr.currentLvl = self.level;
  bldr.teamSlotNum = self.teamSlot;
  bldr.isComplete = self.isComplete;
  bldr.numPieces = self.numPieces;
  bldr.combineStartTime = self.combineStartTime.timeIntervalSince1970*1000.;
  bldr.isRestrictd = self.isProtected;
  bldr.offensiveSkillId = self.offensiveSkillId;
  bldr.defensiveSkillId = self.defensiveSkillId;
  return bldr.build;
}

- (MinimumUserMonsterProto *) convertToMinimumProto {
  MinimumUserMonsterProto_Builder *bldr = [MinimumUserMonsterProto builder];
  bldr.monsterId = self.monsterId;
  bldr.monsterLvl = self.level;
  return bldr.build;
}

@end

@implementation UserEnhancement

+(id) enhancementWithUserEnhancementProto:(UserEnhancementProto *)proto {
  return [[self alloc] initWithUserEnhancementProto:proto];
}

- (id) initWithUserEnhancementProto:(UserEnhancementProto *)proto {
  if ((self = [super init])) {
    if (proto.hasBaseMonster) {
      self.baseMonster = [EnhancementItem itemWithUserEnhancementItemProto:proto.baseMonster];
      self.isComplete = proto.baseMonster.enhancingComplete;
    }
    self.feeders = [NSMutableArray array];
    
    for (UserEnhancementItemProto *item in proto.feedersList) {
      [self.feeders addObject:[EnhancementItem itemWithUserEnhancementItemProto:item]];
    }
    
    [self.feeders sortUsingComparator:^NSComparisonResult(EnhancementItem *obj1, EnhancementItem *obj2) {
      return [obj1.expectedStartTime compare:obj2.expectedStartTime];
    }];
  }
  
  return self;
}

- (float) currentPercentageOfLevel {
  Globals *gl = [Globals sharedGlobals];
  UserMonster *base = self.baseMonster.userMonster;
  float baseLevel = [gl calculateLevelForMonster:base.monsterId experience:base.experience];
  float basePerc = baseLevel-(int)baseLevel;
  return basePerc;
}

- (float) finalPercentageFromCurrentLevel {
  Globals *gl = [Globals sharedGlobals];
  UserMonster *base = self.baseMonster.userMonster;
  int expGained = [gl calculateExperienceIncrease:self];
  float newLevel = [gl calculateLevelForMonster:base.monsterId experience:base.experience+expGained];
  return newLevel-base.level;
}

- (float) percentageIncreaseOfNewUserMonster:(UserMonster *)um roundToPercent:(BOOL)roundToPercent {
  // Calculate the percentage
  float curPerc = [self finalPercentageFromCurrentLevel]*100;
  
  // add this item to UserEnhancement
  EnhancementItem *item = [[EnhancementItem alloc] init];
  [item setFakedUserMonster:um];
  [self.feeders addObject:item];
  
  float newPerc = [self finalPercentageFromCurrentLevel]*100;
  
  [self.feeders removeObjectAtIndex:self.feeders.count-1];
  
  float percIncrease;
  if (roundToPercent) {
    percIncrease = floorf(newPerc)-floorf(curPerc);
  } else {
    percIncrease = newPerc-curPerc;
  }
  return percIncrease;
}

- (int) experienceIncreaseOfNewUserMonster:(UserMonster *)um {
  EnhancementItem *item = [[EnhancementItem alloc] init];
  [item setFakedUserMonster:um];
  
  return [self experienceIncreaseOfItem:item];
}

- (int) experienceIncreaseOfItem:(EnhancementItem *)item {
  Globals *gl = [Globals sharedGlobals];
  return [gl calculateExperienceIncrease:self.baseMonster feeder:item];
}

- (float) currentPercentageForItem:(EnhancementItem *)item {
  int totalTime = [self secondsForCompletionForItem:item];
  float timeCompleted = totalTime - [[self expectedEndTimeForItem:item] timeIntervalSinceNow];
  return timeCompleted/totalTime;
}

- (int) secondsForCompletionForItem:(EnhancementItem *)item {
  Globals *gl = [Globals sharedGlobals];
  return [gl calculateSecondsForEnhancement:self.baseMonster feeder:item];
}

- (MSDate *) expectedEndTimeForItem:(EnhancementItem *)item {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSInteger idx = [self.feeders indexOfObject:item];
  
  MSDate *startDate = item.expectedStartTime;
  // Use end time of previous item as final say, in case there are clan helps and speedups going on
  if (idx != NSNotFound && idx > 0) {
    startDate = [self expectedEndTimeForItem:self.feeders[idx-1]];
  }
  
  int seconds = [self totalSeconds];
  int secsToDock = 0;
  
  // Account for clan helps
  int numHelps = [gs.clanHelpUtil getNumClanHelpsForType:GameActionTypeEnhanceTime userDataUuid:self.baseMonster.userMonsterUuid];
  if (numHelps > 0) {
    int secsToDockPerHelp = MAX(gl.enhanceClanHelpConstants.amountRemovedPerHelp*60, roundf(seconds*gl.enhanceClanHelpConstants.percentRemovedPerHelp));
    secsToDock = numHelps*secsToDockPerHelp;
  }
  
  // Account for speedups
  MSDate *initialStartDate = [(EnhancementItem *)[self.feeders firstObject] expectedStartTime];
  int speedupMins = [gs.itemUtil getSpeedupMinutesForType:GameActionTypeEnhanceTime userDataUuid:self.baseMonster.userMonsterUuid earliestDate:initialStartDate];
  if (speedupMins > 0) {
    secsToDock += speedupMins*60;
  }
  
  // Now we need to go through list up till idx to see how many seconds can be docked off this
  if (idx != NSNotFound && idx > 0) {
    for (int i = 0; i < idx; i++) {
      secsToDock = MAX(0, secsToDock-[self secondsForCompletionForItem:self.feeders[i]]);
    }
  }
  
  int secsForThisItem = MAX(0, [self secondsForCompletionForItem:item]-secsToDock);
  
  return [startDate dateByAddingTimeInterval:secsForThisItem];
}

- (MSDate *) expectedEndTime {
  EnhancementItem *item = [self.feeders lastObject];
  return [self expectedEndTimeForItem:item];
}

- (int) totalSeconds {
  int seconds = 0;
  for (EnhancementItem *ei in self.feeders) {
    seconds += [self secondsForCompletionForItem:ei];
  }
  return seconds;
}

- (id) copy {
  UserEnhancement *ue = [[UserEnhancement alloc] init];
  ue.baseMonster = self.baseMonster;
  ue.feeders = [self.feeders copy];
  return ue;
}

- (id) clone {
  UserEnhancement *ue = [[UserEnhancement alloc] init];
  ue.baseMonster = [self.baseMonster copy];
  ue.feeders = [self.feeders clone];
  return ue;
}

@end

@implementation UserEvolution

+ (id) evolutionWithUserEvolutionProto:(UserMonsterEvolutionProto *)proto {
  return [[self alloc] initWithUserEvolutionProto:proto];
}

+ (id) evolutionWithEvoItem:(EvoItem *)evo time:(MSDate *)time {
  return [[self alloc] initWithEvoItem:evo time:time];
}

- (id) initWithUserEvolutionProto:(UserMonsterEvolutionProto *)proto {
  if ((self = [super init])) {
    self.userMonsterUuid1 = proto.userMonsterUuidsList.count > 0 ? proto.userMonsterUuidsList[0] : nil;
    self.userMonsterUuid2 = proto.userMonsterUuidsList.count > 1 ? proto.userMonsterUuidsList[1] : nil;
    self.catalystMonsterUuid = proto.catalystUserMonsterUuid;
    self.startTime = [MSDate dateWithTimeIntervalSince1970:proto.startTime/1000.];
  }
  return self;
}

- (id) initWithEvoItem:(EvoItem *)evo time:(MSDate *)time {
  if ((self = [super init])) {
    self.userMonsterUuid1 = evo.userMonster1.userMonsterUuid;
    self.userMonsterUuid2 = evo.userMonster2.userMonsterUuid;
    self.catalystMonsterUuid = evo.catalystMonster.userMonsterUuid;
    self.startTime = time;
  }
  return self;
}

- (MSDate *) endTime {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserMonster *um = [gs myMonsterWithUserMonsterUuid:self.userMonsterUuid1];
  
  int seconds = um.staticMonster.minutesToEvolve*60;
  
  // Account for clan helps
  int numHelps = [gs.clanHelpUtil getNumClanHelpsForType:GameActionTypeEvolve userDataUuid:self.userMonsterUuid1];
  if (numHelps > 0) {
    int secsToDockPerHelp = MAX(gl.evolveClanHelpConstants.amountRemovedPerHelp*60, roundf(seconds*gl.evolveClanHelpConstants.percentRemovedPerHelp));
    seconds -= numHelps*secsToDockPerHelp;
  }
  
  // Account for speedups
  int speedupMins = [gs.itemUtil getSpeedupMinutesForType:GameActionTypeEvolve userDataUuid:self.userMonsterUuid1 earliestDate:self.startTime];
  if (speedupMins > 0) {
    seconds -= speedupMins*60;
  }
  
  return [self.startTime dateByAddingTimeInterval:seconds];
}

- (EvoItem *) evoItem {
  GameState *gs = [GameState sharedGameState];
  UserMonster *um1 = [gs myMonsterWithUserMonsterUuid:self.userMonsterUuid1];
  UserMonster *um2 = [gs myMonsterWithUserMonsterUuid:self.userMonsterUuid2];
  UserMonster *cata = [gs myMonsterWithUserMonsterUuid:self.catalystMonsterUuid];
  return [[EvoItem alloc] initWithUserMonster:um1 andUserMonster:um2 catalystMonster:cata suggestedMonster:nil];
}

- (UserMonsterEvolutionProto *) convertToProto {
  UserMonsterEvolutionProto_Builder *bldr = [UserMonsterEvolutionProto builder];
  [bldr addUserMonsterUuids:self.userMonsterUuid1];
  [bldr addUserMonsterUuids:self.userMonsterUuid2];
  bldr.catalystUserMonsterUuid = self.catalystMonsterUuid;
  bldr.startTime = self.startTime.timeIntervalSince1970*1000;
  return bldr.build;
}

@end

@implementation EvoItem

- (id) initWithUserMonster:(UserMonster *)um1 andUserMonster:(UserMonster *)um2 catalystMonster:(UserMonster *)catalystMonster suggestedMonster:(UserMonster *)suggestedMonster {
  if ((self = [super init])) {
    self.userMonster1 = um1;
    self.userMonster2 = um2;
    self.catalystMonster = catalystMonster;
    self.suggestedMonster = suggestedMonster;
  }
  return self;
}

- (NSArray *) userMonsters {
  NSMutableArray *arr = [NSMutableArray array];
  if (self.userMonster1) {
    [arr addObject:self.userMonster1];
  }
  if (self.userMonster2) {
    [arr addObject:self.userMonster2];
  }
  return arr;
}

- (BOOL) isReadyForEvolution {
  MonsterProto *mp = self.userMonster1.staticMonster;
  return self.catalystMonster && self.userMonster1.level >= mp.maxLevel && self.userMonster2;
}

- (BOOL) isEqual:(EvoItem *)object {
  return [self.userMonster1 isEqual:object.userMonster1] && ((!self.userMonster2 && !object.userMonster2) || [self.userMonster2 isEqual:object.userMonster2]);
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@ - 1:%@, 2:%@, C:%@", self, self.userMonster1.userMonsterUuid, self.userMonster2.userMonsterUuid, self.catalystMonster.userMonsterUuid];
}

- (NSUInteger) hash {
  return (NSUInteger)(self.userMonster1.userMonsterUuid.hash*7+self.userMonster2.userMonsterUuid.hash);
}

@end

@implementation EnhancementItem

+ (id) itemWithUserEnhancementItemProto:(UserEnhancementItemProto *)proto {
  return [[self alloc] initWithUserEnhancementItemProto:proto];
}

- (id) initWithUserEnhancementItemProto:(UserEnhancementItemProto *)proto {
  if ((self = [super init])) {
    self.userMonsterUuid = proto.userMonsterUuid;
    self.expectedStartTime = proto.hasExpectedStartTimeMillis ? [MSDate dateWithTimeIntervalSince1970:proto.expectedStartTimeMillis/1000.] : nil;
    self.enhancementCost = proto.enhancingCost;
  }
  return self;
}

- (UserMonster *) userMonster {
  GameState *gs = [GameState sharedGameState];
  return _fakedUserMonster ? _fakedUserMonster : [gs myMonsterWithUserMonsterUuid:self.userMonsterUuid];
}

- (void) setFakedUserMonster:(UserMonster *)userMonster {
  _fakedUserMonster = userMonster;
}

- (UserEnhancementItemProto *) convertToProto {
  UserEnhancementItemProto_Builder *bldr = [UserEnhancementItemProto builder];
  bldr.userMonsterUuid = self.userMonsterUuid;
  if (self.expectedStartTime) {
    bldr.expectedStartTimeMillis = self.expectedStartTime.timeIntervalSince1970*1000;
  }
  bldr.enhancingCost = self.enhancementCost;
  return bldr.build;
}

- (id) copy {
  EnhancementItem *item = [[EnhancementItem alloc] init];
  item.userMonsterUuid = self.userMonsterUuid;
  item.expectedStartTime = [self.expectedStartTime copy];
  item.enhancementCost = self.enhancementCost;
  return item;
}

- (BOOL) isEqual:(UserMonsterHealingItem *)object {
  if (![object respondsToSelector:@selector(userMonsterUuid)]) {
    return NO;
  }
  return [object.userMonsterUuid isEqualToString:self.userMonsterUuid];
}

- (NSUInteger) hash {
  return self.userMonsterUuid.hash;
}

- (NSString *) description {
  return [NSString stringWithFormat:@"Id %@: %@", self.userMonsterUuid, self.expectedStartTime];
}

@end

@implementation UserStruct

- (id) initWithStructProto:(FullUserStructureProto *)proto {
  if ((self = [super init])) {
    self.userStructUuid = proto.userStructUuid;
    self.userUuid = proto.userUuid;
    self.structId = proto.structId;
    self.isComplete = proto.isComplete;
    self.coordinates = CGPointMake(proto.coordinates.x, proto.coordinates.y);
    self.orientation = proto.orientation;
    self.purchaseTime = proto.hasPurchaseTime ? [MSDate dateWithTimeIntervalSince1970:proto.purchaseTime/1000.0] : nil;
    self.lastRetrieved = proto.hasLastRetrieved ? [MSDate dateWithTimeIntervalSince1970:proto.lastRetrieved/1000.0] : nil;
    self.fbInviteStructLvl = proto.fbInviteStructLvl;
  }
  return self;
}

+ (id) userStructWithProto:(FullUserStructureProto *)proto {
  return [[self alloc] initWithStructProto:proto];
}

- (id) initWithTutorialStructProto:(TutorialStructProto *)proto {
  if ((self = [super init])) {
    self.structId = proto.structId;
    self.userStructUuid = [NSString stringWithFormat:@"%d", proto.structId];
    self.isComplete = YES;
    self.coordinates = CGPointMake(proto.coordinate.x, proto.coordinate.y);
    self.orientation = StructOrientationPosition1;
    
    // Don't want it showing icon
    self.lastRetrieved = [[MSDate date] dateByAddingTimeInterval:1000];
  }
  return self;
}

+ (id) userStructWithTutorialStructProto:(TutorialStructProto *)proto {
  return [[self alloc] initWithTutorialStructProto:proto];
}

- (id<StaticStructure>) staticStructForPrevLevel {
  int predecessorStructId = self.staticStruct.structInfo.predecessorStructId;
  if (predecessorStructId) {
    return [[GameState sharedGameState] structWithId:predecessorStructId];
  } else {
    return nil;
  }
}

- (id<StaticStructure>) staticStruct {
  return [[GameState sharedGameState] structWithId:self.structId];
}

- (id<StaticStructure>) staticStructForNextLevel {
  int successorId = self.staticStruct.structInfo.successorStructId;
  if (successorId) {
    return [[GameState sharedGameState] structWithId:successorId];
  } else {
    return nil;
  }
}

- (id<StaticStructure>) staticStructForCurrentConstructionLevel {
  return self.isComplete ? [self staticStruct] : [self staticStructForPrevLevel];
}

- (id<StaticStructure>) maxStaticStruct {
  return self.staticStruct.structInfo.maxStructInfo.staticStruct;
}

- (NSArray *) allStaticStructs {
  NSArray *arr = self.staticStruct.structInfo.fullFamilyList;
  NSMutableArray *ss = [NSMutableArray array];
  
  for (StructureInfoProto *sip in arr) {
    [ss addObject:sip.staticStruct];
  }
  
  return ss;
}

- (id<StaticStructure>) staticStructForFbLevel {
  NSArray *allSS = [self allStaticStructs];
  for (id<StaticStructure> ss in allSS) {
    if (ss.structInfo.level == self.fbInviteStructLvl) {
      return ss;
    }
  }
  return nil;
}

- (id<StaticStructure>) staticStructForNextFbLevel {
  NSArray *allSS = [self allStaticStructs];
  for (id<StaticStructure> ss in allSS) {
    if (ss.structInfo.level == self.fbInviteStructLvl+1) {
      return ss;
    }
  }
  return nil;
}

- (int) maxLevel {
  return self.maxStaticStruct.structInfo.level;
}

- (int) baseStructId {
  Globals *gl = [Globals sharedGlobals];
  return [gl baseStructIdForStructId:self.structId];
}

- (BOOL) isAncestorOfStructId:(int)structId {
  // If it's still constructing, it's not yet a prereq
  if (self.isComplete && self.structId == structId) {
    return YES;
  }
  
  GameState *gs = [GameState sharedGameState];
  id<StaticStructure> ss = self.staticStruct;
  while (ss.structInfo.predecessorStructId) {
    if (ss.structInfo.predecessorStructId == structId) {
      return YES;
    }
    
    ss = [gs structWithId:ss.structInfo.predecessorStructId];
  }
  return NO;
}

- (int) numBonusSlots {
  int slots = 0;
  GameState *gs = [GameState sharedGameState];
  id<StaticStructure> ss = self.staticStructForFbLevel;
  while (ss) {
    if ([ss structInfo].structType == StructureInfoProto_StructTypeResidence) {
      ResidenceProto *res = (ResidenceProto *)ss;
      slots += res.numBonusMonsterSlots;
    }
    
    if (ss.structInfo.predecessorStructId) {
      ss = [gs structWithId:ss.structInfo.predecessorStructId];
    } else {
      ss = nil;
    }
  }
  return slots;
}

- (MSDate *) buildCompleteDate {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  float seconds = [gl calculateSecondsToBuild:self.staticStruct.structInfo];
  
  // Account for clan helps
  int numHelps = [gs.clanHelpUtil getNumClanHelpsForType:GameActionTypeUpgradeStruct userDataUuid:self.userStructUuid];
  if (numHelps > 0) {
    float secsToDockPerHelp = MAX(gl.buildingClanHelpConstants.amountRemovedPerHelp*60, roundf(seconds*gl.buildingClanHelpConstants.percentRemovedPerHelp));
    seconds -= numHelps*secsToDockPerHelp;
  }
  
  // Account for speedups
  int speedupMins = [gs.itemUtil getSpeedupMinutesForType:GameActionTypeUpgradeStruct userDataUuid:self.userStructUuid earliestDate:self.purchaseTime];
  if (speedupMins > 0) {
    seconds -= speedupMins*60;
  }
  
  return [self.purchaseTime dateByAddingTimeInterval:seconds];
}

- (NSTimeInterval) timeLeftForBuildComplete {
  return [self.buildCompleteDate timeIntervalSinceNow];
}

- (int) storageCapacity {
  id<StaticStructure> ss = self.staticStructForCurrentConstructionLevel;
  
  if ([ss isKindOfClass:[ResourceStorageProto class]]) {
    ResourceStorageProto *rgp = (ResourceStorageProto *)ss;
    int baseStorage = rgp.capacity;
    
    GameState *gs = [GameState sharedGameState];
    float researchFactor = 1.f+[gs.researchUtil percentageBenefitForType:ResearchTypeResourceStorage resType:rgp.resourceType];
    
    return roundf(baseStorage*researchFactor);
  } else if ([ss isKindOfClass:[ResourceGeneratorProto class]]) {
    ResourceGeneratorProto *rgp = (ResourceGeneratorProto *)ss;
    int baseStorage = rgp.capacity;
    
    GameState *gs = [GameState sharedGameState];
    float researchFactor = 1.f+[gs.researchUtil percentageBenefitForType:ResearchTypeResourceGeneratorStorage resType:rgp.resourceType];
    
    return roundf(baseStorage*researchFactor);
  } else if ([ss isKindOfClass:[MoneyTreeProto class]]) {
    MoneyTreeProto *rgp = (MoneyTreeProto *)ss;
    int baseStorage = rgp.capacity;
    
    GameState *gs = [GameState sharedGameState];
    float researchFactor = 1.f+[gs.researchUtil percentageBenefitForType:ResearchTypeResourceGeneratorStorage resType:ResourceTypeGems];
    
    return roundf(baseStorage*researchFactor);
  }
  
  return 0;
}

- (float) productionRate {
  ResourceGeneratorProto *gen = (ResourceGeneratorProto *)self.staticStructForCurrentConstructionLevel;
  if ([gen isKindOfClass:[ResourceGeneratorProto class]]) {
    float base = gen.productionRate;
    
    GameState *gs = [GameState sharedGameState];
    float researchFactor = 1.f+[gs.researchUtil percentageBenefitForType:ResearchTypeResourceProduction resType:gen.resourceType];
    
    return roundf(base*researchFactor);
  } else if ([gen isKindOfClass:[MoneyTreeProto class]]) {
    MoneyTreeProto *mtp = (MoneyTreeProto *)gen;
    
    float base = mtp.productionRate;
    
    GameState *gs = [GameState sharedGameState];
    float researchFactor = 1.f+[gs.researchUtil percentageBenefitForType:ResearchTypeResourceProduction resType:ResourceTypeGems];
    
    return base*researchFactor;
  }
  return 0.f;
}

- (int) numResourcesAvailable {
  ResourceGeneratorProto *gen = (ResourceGeneratorProto *)self.staticStruct;
  if ([gen isKindOfClass:[ResourceGeneratorProto class]]) {
    float secs = -[self.lastRetrieved timeIntervalSinceNow];
    int numRes = roundf(self.productionRate/3600.f*secs);
    return MIN(numRes, self.storageCapacity);
    
  } else if ([gen isKindOfClass:[MoneyTreeProto class]]) {
    float timeSinceEndDate = -[self timeTillExpiry];
    float timeSinceLastRetrieved = -[self.lastRetrieved timeIntervalSinceNow];
    float secs = 0;
    if (timeSinceLastRetrieved >= timeSinceEndDate && timeSinceEndDate > 0) {
      secs = timeSinceLastRetrieved - timeSinceEndDate;
    } else if (timeSinceEndDate > timeSinceLastRetrieved) {
      secs = 0;
    } else {
      secs = timeSinceLastRetrieved;
    }
    int numRes = roundf(self.productionRate/3600.f*secs);
    return MIN(numRes, self.storageCapacity);
  }
  return 0;
}

#pragma mark - Money Tree methods

- (BOOL) isExpired {
  return [self timeTillExpiry] <= 0;
}

- (NSTimeInterval) timeTillExpiry {
  MoneyTreeProto *mtp = (MoneyTreeProto *)self.staticStruct;
  return [self.purchaseTime dateByAddingTimeInterval:mtp.daysOfDuration*24*3600].timeIntervalSinceNow;
}

- (BOOL) isNoLongerValidForRenewal {
  MoneyTreeProto *mtp = (MoneyTreeProto *)self.staticStruct;
  MSDate *d1 = [self.purchaseTime dateByAddingTimeInterval:(mtp.daysOfDuration+mtp.daysForRenewal)*24*3600];
  MSDate *d2 = [self.lastRetrieved dateByAddingTimeInterval:(mtp.daysForRenewal)*24*3600];
  MSDate *date = [d1 compare:d2] == NSOrderedAscending ? d2 : d1;
  return self.numResourcesAvailable <= 0 && date.timeIntervalSinceNow < 0;
}

#pragma mark - Prerequisites

- (NSArray *) allPrerequisites {
  return self.staticStruct.structInfo.prereqs;
}

- (NSArray *) incompletePrerequisites {
  NSMutableArray *arr = [NSMutableArray array];
  NSArray *allPrereqs = [self allPrerequisites];
  Globals *gl = [Globals sharedGlobals];
  
  for (PrereqProto *pp in allPrereqs) {
    if (![gl isPrerequisiteComplete:pp]) {
      [arr addObject:pp];
    }
  }
  
  return arr;
}

- (BOOL) satisfiesAllPrerequisites {
  return [self incompletePrerequisites].count == 0;
}

- (NSString *) description {
  StructureInfoProto *fsp = [[[GameState sharedGameState] structWithId:self.structId] structInfo];
  return [NSString stringWithFormat:@"%p: %@, %@", self, fsp.name, NSStringFromCGPoint(self.coordinates)];
}

@end

@implementation UserObstacle

- (id) initWithObstacleProto:(UserObstacleProto *)obstacle {
  if ((self = [super init])) {
    self.userObstacleUuid = obstacle.userObstacleUuid;
    self.obstacleId = obstacle.obstacleId;
    self.coordinates = ccp(obstacle.coordinates.x, obstacle.coordinates.y);
    self.removalTime = obstacle.hasRemovalStartTime ? [MSDate dateWithTimeIntervalSince1970:obstacle.removalStartTime/1000.] : nil;
    self.orientation = obstacle.orientation;
  }
  return self;
}

- (ObstacleProto *) staticObstacle {
  GameState *gs = [GameState sharedGameState];
  return [gs obstacleWithId:self.obstacleId];
}

- (MSDate *) endTime {
  GameState *gs = [GameState sharedGameState];
  ObstacleProto *op = self.staticObstacle;
  int seconds = op.secondsToRemove;
  
  // Account for speedups
  int speedupMins = [gs.itemUtil getSpeedupMinutesForType:GameActionTypeRemoveObstacle userDataUuid:self.userObstacleUuid earliestDate:self.removalTime];
  if (speedupMins > 0) {
    seconds -= speedupMins*60;
  }
  
  return [self.removalTime dateByAddingTimeInterval:seconds];
}

@end

@implementation UserNotification

- (id) initReferralNotificationAtStartup:(StartupResponseProto_ReferralNotificationProto *)proto {
  if ((self = [super init])) {
    self.otherPlayer = proto.referred;
    self.time = [MSDate dateWithTimeIntervalSince1970:proto.recruitTime/1000.0];
    self.type = kNotificationReferral;
  }
  return self;
}

- (id) initWithReferralResponse:(ReferralCodeUsedResponseProto *)proto {
  if ((self = [super init])) {
    self.otherPlayer = proto.referredPlayer;
    self.time = [MSDate date];
    self.type = kNotificationReferral;
  }
  return self;
}

- (id) initWithPrivateChatPost:(PrivateChatPostProto *)proto {
  if ((self = [super init])) {
    self.otherPlayer = proto.poster;
    self.time = [MSDate dateWithTimeIntervalSince1970:proto.timeOfPost/1000.];
    self.type = kNotificationPrivateChat;
    self.wallPost = proto.content;
  }
  return self;
}

- (id) initWithTitle:(NSString *)t subtitle:(NSString *)st color:(UIColor *)c {
  if ((self = [super init])) {
    self.title = t;
    self.subtitle = st;
    self.color = c;
    self.type = kNotificationGeneral;
  }
  return self;
}

- (NSString *) description {
  return [NSString stringWithFormat:@"<UserNotification> Type: %d", self.type];
}

@end

@implementation UserExpansion

- (id) initWithUserCityExpansionDataProto:(UserCityExpansionDataProto *)proto {
  if ((self = [super init])) {
    self.xPosition = proto.xPosition;
    self.yPosition = proto.yPosition;
    self.lastExpandTime = proto.hasExpandStartTime ? [MSDate dateWithTimeIntervalSince1970:proto.expandStartTime/1000.0] : nil;
    self.isExpanding = proto.isExpanding;
  }
  return self;
}

+ (id) userExpansionWithUserCityExpansionDataProto:(UserCityExpansionDataProto *)proto {
  return [[self alloc] initWithUserCityExpansionDataProto:proto];
}

@end

@implementation UserQuestJob

- (id) initWithProto:(UserQuestJobProto *)proto {
  if ((self = [super init])) {
    self.questId = proto.questId;
    self.questJobId = proto.questJobId;
    self.progress = proto.progress;
    self.isComplete = proto.isComplete;
  }
  return self;
}

+ (id) questJobWithProto:(UserQuestJobProto *)proto {
  return [[UserQuestJob alloc] initWithProto:proto];
}

- (UserQuestJobProto *) convertToProto {
  UserQuestJobProto_Builder *bldr = [UserQuestJobProto builder];
  bldr.questId = self.questId;
  bldr.questJobId = self.questJobId;
  bldr.progress = self.progress;
  bldr.isComplete = self.isComplete;
  return bldr.build;
}

@end

@implementation UserQuest

- (id) init {
  if ((self = [super init])) {
    self.progressDict = [NSMutableDictionary dictionary];
  }
  return self;
}

- (id) initWithProto:(FullUserQuestProto *)proto {
  if ((self = [self init])) {
    self.userUuid = proto.userUuid;
    self.questId = proto.questId;
    self.isRedeemed = proto.isRedeemed;
    self.isComplete = proto.isComplete;
    
    for (UserQuestJobProto *uq in proto.userQuestJobsList) {
      [self.progressDict setObject:[UserQuestJob questJobWithProto:uq] forKey:@(uq.questJobId)];
    }
  }
  return self;
}

+ (id) questWithProto:(FullUserQuestProto *)proto {
  return [[UserQuest alloc] initWithProto:proto];
}

- (FullQuestProto *) quest {
  GameState *gs = [GameState sharedGameState];
  return [gs questForId:self.questId];
}

- (void) setProgress:(int)progress forQuestJobId:(int)questJobId {
  UserQuestJob *job = self.progressDict[@(questJobId)];
  
  if (job) {
    job.progress = progress;
  } else {
    job = [[UserQuestJob alloc] init];
    job.questId = self.questId;
    job.questJobId = questJobId;
    job.progress = progress;
    [self.progressDict setObject:job forKey:@(questJobId)];
  }
}

- (void) setIsCompleteForQuestJobId:(int)questJobId {
  UserQuestJob *job = self.progressDict[@(questJobId)];
  
  if (job) {
    job.isComplete = YES;
  } else {
    job = [[UserQuestJob alloc] init];
    job.questId = self.questId;
    job.questJobId = questJobId;
    job.isComplete = YES;
    [self.progressDict setObject:job forKey:@(questJobId)];
  }
}

- (int) getProgressForQuestJobId:(int)questJobId {
  UserQuestJob *job = self.progressDict[@(questJobId)];
  return job.progress;
}

- (UserQuestJob *) jobForId:(int)questJobId {
  UserQuestJob *job = self.progressDict[@(questJobId)];
  if (!job) {
    job = [[UserQuestJob alloc] init];
    job.questId = self.questId;
    job.questJobId = questJobId;
    [self.progressDict setObject:job forKey:@(questJobId)];
  }
  return job;
}

@end

@implementation UserAchievement

+ (id) userAchievementWithProto:(UserAchievementProto *)achievement {
  return [[UserAchievement alloc] initWithProto:achievement];
}

- (id) initWithProto:(UserAchievementProto *)proto {
  if ((self = [super init])) {
    self.achievementId = proto.achievementId;
    self.isRedeemed = proto.isRedeemed;
    self.isComplete = proto.isComplete;
    self.progress = proto.progress;
  }
  return self;
}

- (UserAchievementProto *) convertToProto {
  UserAchievementProto_Builder *uap = [UserAchievementProto builder];
  uap.achievementId = self.achievementId;
  uap.isComplete = self.isComplete;
  uap.isRedeemed = self.isRedeemed;
  uap.progress = self.progress;
  return uap.build;
}

@end

@implementation RequestFromFriend

+ (id) requestForInventorySlotsWithInvite:(UserFacebookInviteForSlotProto *)invite {
  return [[self alloc] initInventorySlotsRequestWithInvite:invite];
}

- (id) initInventorySlotsRequestWithInvite:(UserFacebookInviteForSlotProto *)invite {
  if ((self = [super init])) {
    self.invite = invite;
    self.type = RequestFromFriendInventorySlots;
  }
  return self;
}

- (BOOL) isEqual:(RequestFromFriend *)object {
  return [self class] == [object class] && [self.invite.inviteUuid isEqualToString:object.invite.inviteUuid];
}

- (NSUInteger) hash {
  return self.invite.inviteUuid.hash;
}

@end

@implementation UserMiniJob

+ (id) userMiniJobWithProto:(UserMiniJobProto *)proto {
  return [[UserMiniJob alloc] initWithProto:proto];
}

- (id) initWithProto:(UserMiniJobProto *)proto {
  if ((self = [super init])) {
    self.userMiniJobUuid = proto.userMiniJobUuid;
    self.miniJob = proto.miniJob;
    self.baseDmgReceived = proto.baseDmgReceived;
    self.durationSeconds = proto.durationSeconds ?: proto.durationMinutes*60;
    self.timeStarted = proto.hasTimeStarted ? [MSDate dateWithTimeIntervalSince1970:proto.timeStarted/1000.] : nil;
    self.timeCompleted = proto.hasTimeCompleted ? [MSDate dateWithTimeIntervalSince1970:proto.timeCompleted/1000.] : nil;
    self.userMonsterUuids = proto.userMonsterUuidsList;
  }
  return self;
}

- (MSDate *)tentativeCompletionDate {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int seconds = self.durationSeconds;
  
  // Account for clan helps
  int numHelps = [gs.clanHelpUtil getNumClanHelpsForType:GameActionTypeMiniJob userDataUuid:self.userMiniJobUuid];
  if (numHelps > 0) {
    int secsToDockPerHelp = MAX(gl.miniJobClanHelpConstants.amountRemovedPerHelp*60, roundf(seconds*gl.miniJobClanHelpConstants.percentRemovedPerHelp));
    seconds -= numHelps*secsToDockPerHelp;
  }
  
  // Account for speedups
  int speedupMins = [gs.itemUtil getSpeedupMinutesForType:GameActionTypeMiniJob userDataUuid:self.userMiniJobUuid earliestDate:self.timeStarted];
  if (speedupMins > 0) {
    seconds -= speedupMins*60;
  }
  
  return [self.timeStarted dateByAddingTimeInterval:seconds];
}

- (NSDictionary *) damageDealtPerUserMonsterUuid {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  NSMutableDictionary *damages = [NSMutableDictionary dictionary];
  NSMutableArray *userMonsters = [NSMutableArray array];
  
  int totalAttack = 0;
  for (NSString *umUuid in self.userMonsterUuids) {
    UserMonster *um = [gs myMonsterWithUserMonsterUuid:umUuid];
    if (um) {
      [userMonsters addObject:um];
      totalAttack += [gl calculateTotalDamageForMonster:um];
    } else {
      [Globals popupMessage:[NSString stringWithFormat:@"Unable to find %@ on mini job.", MONSTER_NAME]];
      return nil;
    }
  }
  
  // Deal damage evenly
  float multiplier = 1.f;//userMiniJob.miniJob.atkRequired/(float)totalAttack;
  int damageToDeal = ceilf(self.baseDmgReceived*multiplier);
  NSMutableArray *aliveMonsters = [userMonsters mutableCopy];
  while (damageToDeal && aliveMonsters.count > 0) {
    // Find lowest health
    int lowestHealth = [aliveMonsters[0] curHealth];
    for (UserMonster *um in aliveMonsters) {
      if (um.curHealth < lowestHealth) {
        int damage = [damages[um.userMonsterUuid] intValue];
        lowestHealth = um.curHealth-damage;
      }
    }
    
    int dmgThisRound = lowestHealth * (int)aliveMonsters.count;
    if (dmgThisRound < damageToDeal) {
      for (UserMonster *um in aliveMonsters) {
        int damage = [damages[um.userMonsterUuid] intValue];
        damage += lowestHealth;
        [damages setObject:@(damage) forKey:um.userMonsterUuid];
      }
      damageToDeal -= dmgThisRound;
    } else {
      int dmgPerChar = damageToDeal/aliveMonsters.count;
      
      for (UserMonster *um in aliveMonsters) {
        int damage = [damages[um.userMonsterUuid] intValue];
        damage += dmgPerChar;
        [damages setObject:@(damage) forKey:um.userMonsterUuid];
      }
      
      // Deal remaining damage (i.e. 2 monsters-7 dmg to deal: 1 dmg needs to be dealt to someone)
      damageToDeal -= dmgPerChar * aliveMonsters.count;
      for (int i = 0; i < damageToDeal; i++) {
        UserMonster *um = aliveMonsters[i];
        int damage = [damages[um.userMonsterUuid] intValue];
        damage += 1;
        [damages setObject:@(damage) forKey:um.userMonsterUuid];
      }
      damageToDeal = 0;
    }
    
    // Clear out all dead monsters
    for (UserMonster *um in userMonsters) {
      int damage = [damages[um.userMonsterUuid] intValue];
      if (um.curHealth-damage <= 0) {
        [aliveMonsters removeObject:um];
      }
    }
  }
  
  return damages;
}

- (BOOL) isEqual:(UserMiniJob *)object {
  return [self.userMiniJobUuid isEqualToString:object.userMiniJobUuid];
}

- (NSUInteger) hash {
  return self.userMiniJobUuid.hash;
}

@end

@implementation UserMiniEventGoal

- (instancetype) initWithProto:(MiniEventGoalProto*)proto
{
  self = [super init];
  if (self)
  {
    self.userUuid = [GameState sharedGameState].userUuid;
    self.miniEventGoalId = proto.miniEventGoalId;
    self.goalAmt = proto.goalAmt;
    self.pointsGained = proto.pointsGained;
    self.progress = 0; // Will be set and updated by owner class
    self.goalDesc = proto.goalDesc;
    self.actionDescription = proto.actionDescription;
  }
  return self;
}

+ (instancetype) userMiniEventGoalWithProto:(MiniEventGoalProto*)proto
{
  return [[UserMiniEventGoal alloc] initWithProto:proto];
}

- (UserMiniEventGoalProto*) convertToProto
{
  return [[[[[UserMiniEventGoalProto builder]
             setUserUuid:self.userUuid]
            setMiniEventGoalId:self.miniEventGoalId]
           setProgress:self.progress] build];
}

@end

@implementation UserMiniEvent

- (instancetype) initWithProto:(UserMiniEventProto*)proto
{
  self = [super init];
  if (self)
  {
    self.miniEventId = proto.miniEventId;
    self.userUuid = proto.userUuid;
    self.userLvl = proto.userLvl;
    self.tierOneRedeemed = proto.tierOneRedeemed;
    self.tierTwoRedeemed = proto.tierTwoRedeemed;
    self.tierThreeRedeemed = proto.tierThreeRedeemed;
    self.miniEvent = proto.miniEvent;

    self.miniEventGoals = [NSMutableDictionary dictionary];
    // All goals for this mini event
    for (MiniEventGoalProto* goalProto in proto.miniEvent.goalsList)
      [self.miniEventGoals setObject:[UserMiniEventGoal userMiniEventGoalWithProto:goalProto] forKey:@(goalProto.miniEventGoalId)];
    // All goals on which the user has made some progress
    for (UserMiniEventGoalProto* userGoalProto in proto.goalsList)
      [(UserMiniEventGoal*)[self.miniEventGoals objectForKey:@(userGoalProto.miniEventGoalId)] setProgress:userGoalProto.progress];
    
    self.pointsEarned = 0;
    // Calculate total points earned based on user goals' progress
    for (UserMiniEventGoal* userGoal in [self.miniEventGoals allValues])
      self.pointsEarned += ((userGoal.progress - userGoal.progress % userGoal.goalAmt) / userGoal.goalAmt) * userGoal.pointsGained;
  }
  return self;
}

+ (instancetype) userMiniEventWithProto:(UserMiniEventProto*)proto
{
  return [[UserMiniEvent alloc] initWithProto:proto];
}

- (BOOL) eventHasEnded
{
  MSDate* eventEndTime = [MSDate dateWithTimeIntervalSince1970:self.miniEvent.miniEventEndTime / 1000.f];
  MSDate* now = [MSDate date];
  return ([now compare:eventEndTime] != NSOrderedAscending);
}

- (NSTimeInterval) secondsTillEventEndTime
{
  MSDate* eventEndTime = [MSDate dateWithTimeIntervalSince1970:self.miniEvent.miniEventEndTime / 1000.f];
  MSDate* now = [MSDate date];
  return [eventEndTime timeIntervalSinceDate:now];
}

- (int) completedTiersWithUnredeemedRewards
{
  int unredeemedTiers = 0;
  if (self.pointsEarned >= self.miniEvent.lvlEntered.tierOneMinPts   && !self.tierOneRedeemed)   ++unredeemedTiers;
  if (self.pointsEarned >= self.miniEvent.lvlEntered.tierTwoMinPts   && !self.tierTwoRedeemed)   ++unredeemedTiers;
  if (self.pointsEarned >= self.miniEvent.lvlEntered.tierThreeMinPts && !self.tierThreeRedeemed) ++unredeemedTiers;
  return unredeemedTiers;
}

- (BOOL) allCompletedTiersHaveBeenRedeemed
{
  return ((self.tierOneRedeemed   || self.pointsEarned < self.miniEvent.lvlEntered.tierOneMinPts) &&
          (self.tierTwoRedeemed   || self.pointsEarned < self.miniEvent.lvlEntered.tierTwoMinPts) &&
          (self.tierThreeRedeemed || self.pointsEarned < self.miniEvent.lvlEntered.tierThreeMinPts));
}

- (UserMiniEventProto*) convertToProto
{
  NSMutableArray* goalsList = [NSMutableArray array];
  // All goals on which the user has made some progress
  for (UserMiniEventGoal* userGoal in [self.miniEventGoals allValues])
    if (userGoal.progress > 0)
      [goalsList addObject:[userGoal convertToProto]];
  
  return [[[[[[[[[[UserMiniEventProto builder]
                  setMiniEventId:self.miniEventId]
                 setUserUuid:self.userUuid]
                setUserLvl:self.userLvl]
               setTierOneRedeemed:self.tierOneRedeemed]
              setTierTwoRedeemed:self.tierTwoRedeemed]
             setTierThreeRedeemed:self.tierThreeRedeemed]
            setMiniEvent:self.miniEvent]
           addAllGoals:[NSArray arrayWithArray:goalsList]] build];
}

@end
