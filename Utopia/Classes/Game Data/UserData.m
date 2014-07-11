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

@implementation MonsterProto (Name)

- (NSString *) monsterName {
  return self.hasShorterName ? self.shorterName : self.displayName;
}

@end

@implementation UserMonster

- (id) initWithMonsterProto:(FullUserMonsterProto *)proto {
  if ((self = [super init])){
    self.userId = proto.userId;
    self.monsterId = proto.monsterId;
    self.userMonsterId = proto.userMonsterId;
    self.level = proto.currentLvl;
    self.experience = proto.currentExp;
    self.curHealth = proto.currentHealth;
    self.teamSlot = proto.teamSlotNum;
    self.numPieces = proto.numPieces;
    self.isComplete = proto.isComplete;
    self.combineStartTime = [MSDate dateWithTimeIntervalSince1970:proto.combineStartTime/1000.];
  }
  return self;
}

+ (id) userMonsterWithProto:(FullUserMonsterProto *)proto {
  return [[self alloc] initWithMonsterProto:proto];
}

- (id) initWithMinMonsterProto:(MinimumUserMonsterProto *)proto {
  if ((self = [super init])){
    self.monsterId = proto.monsterId;
    self.level = proto.monsterLvl;
    
    Globals *gl = [Globals sharedGlobals];
    self.curHealth = [gl calculateMaxHealthForMonster:self];
    self.isComplete = YES;
  }
  return self;
}

+ (id) userMonsterWithMinProto:(MinimumUserMonsterProto *)proto {
  return [[self alloc] initWithMinMonsterProto:proto];
}

- (id) initWithTaskStageMonsterProto:(TaskStageMonsterProto *)proto {
  if ((self = [super init])){
    Globals *gl = [Globals sharedGlobals];
    self.monsterId = proto.monsterId;
    self.level = proto.level;
    self.curHealth = [gl calculateMaxHealthForMonster:self];
  }
  return self;
}

+ (id) userMonsterWithTaskStageMonsterProto:(TaskStageMonsterProto *)proto {
  return [[self alloc] initWithTaskStageMonsterProto:proto];
}

- (BOOL) isHealing {
  GameState *gs = [GameState sharedGameState];
  for (UserMonsterHealingItem *item in gs.monsterHealingQueue) {
    if (item.userMonsterId == self.userMonsterId) {
      return YES;
    }
  }
  return NO;
}

- (BOOL) isEnhancing {
  GameState *gs = [GameState sharedGameState];
  return self.userMonsterId == gs.userEnhancement.baseMonster.userMonsterId;
}

- (BOOL) isEvolving {
  GameState *gs = [GameState sharedGameState];
  uint64_t i = self.userMonsterId;
  UserEvolution *evo = gs.userEvolution;
  return evo.userMonsterId1 == i || evo.userMonsterId2 == i || evo.catalystMonsterId == i;
}

- (BOOL) isSacrificing {
  GameState *gs = [GameState sharedGameState];
  for (EnhancementItem *ei in gs.userEnhancement.feeders) {
    if (self.userMonsterId == ei.userMonsterId) {
      return YES;
    }
  }
  return NO;
}

- (BOOL) isOnAMiniJob {
  GameState *gs = [GameState sharedGameState];
  for (UserMiniJob *mj in gs.myMiniJobs) {
    if ([mj.userMonsterIds containsObject:@(self.userMonsterId)]) {
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
  return self.isAvailable || !self.isComplete;
}

- (int) sellPrice {
  float base = self.levelInfo.sellAmount;
  float fraction = self.isComplete ? self.level : self.numPieces/(float)self.staticMonster.numPuzzlePieces;
  int price = MAX(1, base*fraction);
  return price;
}

- (void) setExperience:(int)experience {
  _experience = experience;
  
  Globals *gl = [Globals sharedGlobals];
  float newLevel = [gl calculateLevelForMonster:self.monsterId experience:experience];
  self.level = MAX(self.level, newLevel);
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

- (MonsterLevelInfoProto *) levelInfo {
  NSArray *arr = self.staticMonster.lvlInfoList;
  return arr.count > 0 ? arr[0] : nil;
}

- (BOOL) isCombining {
  return !self.isComplete && self.numPieces >= self.staticMonster.numPuzzlePieces;
}

- (int) timeLeftForCombining {
  return self.combineStartTime.timeIntervalSinceNow + self.staticMonster.minutesToCombinePieces*60;
}

- (BOOL) isEqual:(UserMonster *)object {
  if (![object respondsToSelector:@selector(userMonsterId)]) {
    return NO;
  }
  return object.userMonsterId == self.userMonsterId;
}

- (NSUInteger) hash {
  return (NSUInteger)self.userMonsterId;
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
    int selfHp = [gl calculateMaxHealthForMonster:self];
    int umHp = [gl calculateMaxHealthForMonster:um];
    
    // Ordering now becomes maxHp, curHp, rarity
    if (selfHp != umHp) {
      return [@(umHp) compare:@(selfHp)];
    } else if (self.curHealth != um.curHealth) {
      return [@(um.curHealth) compare:@(self.curHealth)];
    } else if (self.staticMonster.quality != um.staticMonster.quality) {
      return [@(um.staticMonster.quality) compare:@(self.staticMonster.quality)];
    } else {
      return [@(self.monsterId) compare:@(um.monsterId)];
    }
  }
}

- (FullUserMonsterProto *) convertToProto {
  FullUserMonsterProto_Builder *bldr = [FullUserMonsterProto builder];
  bldr.userMonsterId = self.userMonsterId;
  bldr.userId = self.userId;
  bldr.monsterId = self.monsterId;
  bldr.currentHealth = self.curHealth;
  bldr.currentExp = self.experience;
  bldr.currentLvl = self.level;
  bldr.teamSlotNum = self.teamSlot;
  bldr.isComplete = self.isComplete;
  bldr.numPieces = self.numPieces;
  bldr.combineStartTime = self.combineStartTime.timeIntervalSince1970*1000.;
  return bldr.build;
}

- (MinimumUserMonsterProto *) convertToMinimumProto {
  MinimumUserMonsterProto_Builder *bldr = [MinimumUserMonsterProto builder];
  bldr.monsterId = self.monsterId;
  bldr.monsterLvl = self.level;
  return bldr.build;
}

@end

@implementation UserMonsterHealingItem

- (id) initWithHealingProto:(UserMonsterHealingProto *)proto {
  if ((self = [super init])){
    self.userId = proto.userId;
    self.userMonsterId = proto.userMonsterId;
    self.queueTime = proto.hasQueuedTimeMillis ? [MSDate dateWithTimeIntervalSince1970:proto.queuedTimeMillis/1000.0] : nil;
    self.healthProgress = proto.healthProgress;
    self.priority = proto.priority;
  }
  return self;
}

+ (id) userMonsterHealingItemWithProto:(UserMonsterHealingProto *)proto {
  return [[self alloc] initWithHealingProto:proto];
}

- (UserMonster *) userMonster {
  GameState *gs = [GameState sharedGameState];
  return [gs myMonsterWithUserMonsterId:self.userMonsterId];
}

- (UserMonsterHealingProto *) convertToProto {
  UserMonsterHealingProto_Builder *bldr = [[[[[UserMonsterHealingProto builder]
                                              setUserId:self.userId]
                                             setUserMonsterId:self.userMonsterId]
                                            setHealthProgress:self.healthProgress]
                                           setPriority:self.priority];
  
  [bldr setQueuedTimeMillis:self.queueTime.timeIntervalSince1970*1000];
  return [bldr build];
}

- (float) totalSeconds {
  float secs = 0;
  for (int i = 0; i < self.timeDistribution.count; i += 2) {
    secs += [self.timeDistribution[i] floatValue];
  }
  return secs;
}

- (float) currentPercentage {
  Globals *gl = [Globals sharedGlobals];
  float totalSecs = [self totalSeconds];
  float timeLeft = [self.endTime timeIntervalSinceNow];
  float timeCompleted = MAX(totalSecs-timeLeft, 0);
  float totalHealth = [gl calculateMaxHealthForMonster:self.userMonster]-self.userMonster.curHealth;
  
  float healthToHeal = 0;
  for (int i = 1; i < self.timeDistribution.count; i += 2) {
    healthToHeal += [self.timeDistribution[i] intValue];
  }
  
  float basePerc = self.healthProgress/totalHealth;
  float percentage = basePerc;
  for (int i = 0; i < self.timeDistribution.count; i += 2) {
    float secs = [self.timeDistribution[i] floatValue];
    float health = [self.timeDistribution[i+1] floatValue];
    
    if (timeCompleted > secs) {
      timeCompleted -= secs;
      percentage += health/healthToHeal;
    } else {
      percentage += health/healthToHeal*timeCompleted/secs*(1-basePerc);
      break;
    }
  }
  
  return percentage;
}

- (id) copy {
  UserMonsterHealingItem *item = [[UserMonsterHealingItem alloc] init];
  item.userId = self.userId;
  item.userMonsterId = self.userMonsterId;
  item.queueTime = [self.queueTime copy];
  item.healthProgress = self.healthProgress;
  item.priority = self.priority;
  return item;
}

- (BOOL) isEqual:(UserMonsterHealingItem *)object {
  if (![object respondsToSelector:@selector(userMonsterId)]) {
    return NO;
  }
  return object.userMonsterId == self.userMonsterId;
}

- (NSUInteger) hash {
  return (NSUInteger)self.userMonsterId;
}

- (NSString *) description {
  return [NSString stringWithFormat:@"%p: %lld, %@", self, self.userMonsterId, self.queueTime];
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
  
  if (self.feeders.count == 0) {
    return basePerc;
  }
  
  EnhancementItem *feeder = [self.feeders objectAtIndex:0];
  int expGained = [gl calculateExperienceIncrease:self.baseMonster feeder:feeder];
  float curPerc = [self currentPercentageForItem:feeder];
  float curLevel = [gl calculateLevelForMonster:base.monsterId experience:base.experience+expGained*curPerc];
  return basePerc+(curLevel-baseLevel);
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
  item.userMonsterId = um.userMonsterId;
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
  item.userMonsterId = um.userMonsterId;
  
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
  return [item.expectedStartTime dateByAddingTimeInterval:[self secondsForCompletionForItem:item]];
}

- (MSDate *) expectedEndTime {
  EnhancementItem *item = [self.feeders lastObject];
  return [self expectedEndTimeForItem:item];
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
    self.userMonsterId1 = proto.userMonsterIdsList.count > 0 ? [proto.userMonsterIdsList[0] intValue] : 0;
    self.userMonsterId2 = proto.userMonsterIdsList.count > 1 ? [proto.userMonsterIdsList[1] intValue] : 0;
    self.catalystMonsterId = proto.catalystUserMonsterId;
    self.startTime = [MSDate dateWithTimeIntervalSince1970:proto.startTime/1000.];
  }
  return self;
}

- (id) initWithEvoItem:(EvoItem *)evo time:(MSDate *)time {
  if ((self = [super init])) {
    self.userMonsterId1 = evo.userMonster1.userMonsterId;
    self.userMonsterId2 = evo.userMonster2.userMonsterId;
    self.catalystMonsterId = evo.catalystMonster.userMonsterId;
    self.startTime = time;
  }
  return self;
}

- (MSDate *) endTime {
  GameState *gs = [GameState sharedGameState];
  UserMonster *um = [gs myMonsterWithUserMonsterId:self.userMonsterId1];
  return [self.startTime dateByAddingTimeInterval:um.staticMonster.minutesToEvolve*60];
}

- (EvoItem *) evoItem {
  GameState *gs = [GameState sharedGameState];
  UserMonster *um1 = [gs myMonsterWithUserMonsterId:self.userMonsterId1];
  UserMonster *um2 = [gs myMonsterWithUserMonsterId:self.userMonsterId2];
  UserMonster *cata = [gs myMonsterWithUserMonsterId:self.catalystMonsterId];
  return [[EvoItem alloc] initWithUserMonster:um1 andUserMonster:um2 catalystMonster:cata suggestedMonster:nil];
}

- (UserMonsterEvolutionProto *) convertToProto {
  UserMonsterEvolutionProto_Builder *bldr = [UserMonsterEvolutionProto builder];
  [bldr addUserMonsterIds:self.userMonsterId1];
  [bldr addUserMonsterIds:self.userMonsterId2];
  bldr.catalystUserMonsterId = self.catalystMonsterId;
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
  return self.catalystMonster && self.userMonster1.level >= mp.maxLevel && self.userMonster2.level >= mp.maxLevel;
}

- (BOOL) isEqual:(EvoItem *)object {
  return [self.userMonster1 isEqual:object.userMonster1] && ((!self.userMonster2 && !object.userMonster2) || [self.userMonster2 isEqual:object.userMonster2]);
}

- (NSString *)description {
  return [NSString stringWithFormat:@"1:%lld, 2:%lld, C:%lld", self.userMonster1.userMonsterId, self.userMonster2.userMonsterId, self.catalystMonster.userMonsterId];
}

- (NSUInteger) hash {
  return (NSUInteger)(self.userMonster1.userMonsterId+self.userMonster2.userMonsterId);
}

@end

@implementation EnhancementItem

+ (id) itemWithUserEnhancementItemProto:(UserEnhancementItemProto *)proto {
  return [[self alloc] initWithUserEnhancementItemProto:proto];
}

- (id) initWithUserEnhancementItemProto:(UserEnhancementItemProto *)proto {
  if ((self = [super init])) {
    self.userMonsterId = proto.userMonsterId;
    self.expectedStartTime = proto.hasExpectedStartTimeMillis ? [MSDate dateWithTimeIntervalSince1970:proto.expectedStartTimeMillis/1000.] : nil;
    self.enhancementCost = proto.enhancingCost;
  }
  return self;
}

- (UserMonster *) userMonster {
  GameState *gs = [GameState sharedGameState];
  return [gs myMonsterWithUserMonsterId:self.userMonsterId];
}

- (UserEnhancementItemProto *) convertToProto {
  UserEnhancementItemProto_Builder *bldr = [UserEnhancementItemProto builder];
  bldr.userMonsterId = self.userMonsterId;
  if (self.expectedStartTime) {
    bldr.expectedStartTimeMillis = self.expectedStartTime.timeIntervalSince1970*1000;
  }
  bldr.enhancingCost = self.enhancementCost;
  return bldr.build;
}

- (id) copy {
  EnhancementItem *item = [[EnhancementItem alloc] init];
  item.userMonsterId = self.userMonsterId;
  item.expectedStartTime = [self.expectedStartTime copy];
  item.enhancementCost = self.enhancementCost;
  return item;
}

- (BOOL) isEqual:(UserMonsterHealingItem *)object {
  if (![object respondsToSelector:@selector(userMonsterId)]) {
    return NO;
  }
  return object.userMonsterId == self.userMonsterId;
}

- (NSUInteger) hash {
  return (NSUInteger)self.userMonsterId;
}

- (NSString *) description {
  return [NSString stringWithFormat:@"Id %lld: %@", self.userMonsterId, self.expectedStartTime];
}

@end

@implementation UserStruct

- (id) initWithStructProto:(FullUserStructureProto *)proto {
  if ((self = [super init])) {
    self.userStructId = proto.userStructId;
    self.userId = proto.userId;
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
    self.userStructId = proto.structId;
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

- (id<StaticStructure>) maxStaticStruct {
  GameState *gs = [GameState sharedGameState];
  id<StaticStructure> ss = self.staticStruct;
  while (ss.structInfo.successorStructId) {
    ss = [gs structWithId:ss.structInfo.successorStructId];
  }
  return ss;
}

- (NSArray *) allStaticStructs {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *arr = [NSMutableArray array];
  int curId = self.baseStructId;
  while (curId) {
    id<StaticStructure> ss = [gs structWithId:curId];
    [arr addObject:ss];
    curId = ss.structInfo.successorStructId;
  }
  return arr;
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
  GameState *gs = [GameState sharedGameState];
  id<StaticStructure> ss = self.staticStruct;
  while (ss.structInfo.predecessorStructId) {
    ss = [gs structWithId:ss.structInfo.predecessorStructId];
  }
  return ss.structInfo.structId;
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
  int minutes = self.staticStruct.structInfo.minutesToBuild;
  return [self.purchaseTime dateByAddingTimeInterval:minutes*60.f];
}

- (NSTimeInterval) timeLeftForBuildComplete {
  return [self.buildCompleteDate timeIntervalSinceNow];
}

- (int) numResourcesAvailable {
  ResourceGeneratorProto *gen = (ResourceGeneratorProto *)self.staticStruct;
  if (![gen isKindOfClass:[ResourceGeneratorProto class]]) {
    return 0;
  }
  float secs = -[self.lastRetrieved timeIntervalSinceNow];
  int numRes = gen.productionRate/3600.f*secs;
  return MIN(numRes, gen.capacity);
}

- (NSString *) description {
  StructureInfoProto *fsp = [[[GameState sharedGameState] structWithId:self.structId] structInfo];
  return [NSString stringWithFormat:@"%p: %@, %@", self, fsp.name, NSStringFromCGPoint(self.coordinates)];
}

@end

@implementation UserObstacle

- (id) initWithObstacleProto:(UserObstacleProto *)obstacle {
  if ((self = [super init])) {
    self.userObstacleId = obstacle.userObstacleId;
    self.userId = obstacle.userId;
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
  ObstacleProto *op = self.staticObstacle;
  return [self.removalTime dateByAddingTimeInterval:op.secondsToRemove];
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
    self.otherPlayer = proto.poster.minUserProto;
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

@implementation ChatMessage

@synthesize message, sender, date, isAdmin;

- (id) initWithProto:(GroupChatMessageProto *)p {
  if ((self = [super init])) {
    self.message = p.content;
    self.sender = p.sender;
    self.date = [MSDate dateWithTimeIntervalSince1970:p.timeOfChat/1000.];
    self.isAdmin = p.isAdmin;
  }
  return self;
}

@end

@implementation UserExpansion

- (id) initWithUserCityExpansionDataProto:(UserCityExpansionDataProto *)proto {
  if ((self = [super init])) {
    self.userId = proto.userId;
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

@implementation Reward

+ (NSArray *) createRewardsForDungeon:(BeginDungeonResponseProto *)proto {
  return [self createRewardsForDungeon:proto tillStage:(int)proto.tspList.count-1];
}

+ (NSArray *) createRewardsForDungeon:(BeginDungeonResponseProto *)proto tillStage:(int)stageNum {
  NSMutableArray *rewards = [NSMutableArray array];
  
  int silverAmount = 0, oilAmount = 0, expAmount = 0;
  for (int i = 0; i <= stageNum && i < proto.tspList.count; i++) {
    TaskStageProto *tsp = proto.tspList[i];
    for (TaskStageMonsterProto *tsm in tsp.stageMonstersList) {
      silverAmount += tsm.cashReward;
      oilAmount += tsm.oilReward;
      expAmount += tsm.expReward;
      
      if (tsm.puzzlePieceDropped) {
        Reward *r = [[Reward alloc] initWithMonsterId:tsm.monsterId isPuzzlePiece:YES];
        [rewards addObject:r];
      } else if (tsm.hasItemId) {
        Reward *r = [[Reward alloc] initWithItemId:tsm.itemId];
        [rewards addObject:r];
      }
    }
  }
  
  if (silverAmount) {
    Reward *r = [[Reward alloc] initWithSilverAmount:silverAmount];
    [rewards addObject:r];
  }
  if (oilAmount) {
    Reward *r = [[Reward alloc] initWithOilAmount:oilAmount];
    [rewards addObject:r];
  }
  
  return rewards;
}

+ (NSArray *) createRewardsForQuest:(FullQuestProto *)quest {
  NSMutableArray *rewards = [NSMutableArray array];
  
  if (quest.gemReward) {
    Reward *r = [[Reward alloc] initWithGoldAmount:quest.gemReward];
    [rewards addObject:r];
  }
  
  if (quest.monsterIdReward) {
    Reward *r = [[Reward alloc] initWithMonsterId:quest.monsterIdReward isPuzzlePiece:!quest.isCompleteMonster];
    [rewards addObject:r];
  }
  
  if (quest.cashReward) {
    Reward *r = [[Reward alloc] initWithSilverAmount:quest.cashReward];
    [rewards addObject:r];
  }
  
  if (quest.oilReward) {
    Reward *r = [[Reward alloc] initWithOilAmount:quest.oilReward];
    [rewards addObject:r];
  }
  
  return rewards;
}

+ (NSArray *) createRewardsForMiniJob:(MiniJobProto *)miniJob {
  NSMutableArray *rewards = [NSMutableArray array];
  
  if (miniJob.gemReward) {
    Reward *r = [[Reward alloc] initWithGoldAmount:miniJob.gemReward];
    [rewards addObject:r];
  }
  
  if (miniJob.monsterIdReward) {
    Reward *r = [[Reward alloc] initWithMonsterId:miniJob.monsterIdReward isPuzzlePiece:YES];
    [rewards addObject:r];
  }
  
  if (miniJob.cashReward) {
    Reward *r = [[Reward alloc] initWithSilverAmount:miniJob.cashReward];
    [rewards addObject:r];
  }
  
  if (miniJob.oilReward) {
    Reward *r = [[Reward alloc] initWithOilAmount:miniJob.oilReward];
    [rewards addObject:r];
  }
  
  return rewards;
}

+ (NSArray *) createRewardsForPvpProto:(PvpProto *)pvp {
  NSMutableArray *rewards = [NSMutableArray array];
  
  if (pvp.prospectiveCashWinnings) {
    Reward *r = [[Reward alloc] initWithSilverAmount:pvp.prospectiveCashWinnings];
    [rewards addObject:r];
  }
  
  if (pvp.prospectiveOilWinnings) {
    Reward *r = [[Reward alloc] initWithOilAmount:pvp.prospectiveOilWinnings];
    [rewards addObject:r];
  }
  
  return rewards;
}

- (id) initWithMonsterId:(int)monsterId isPuzzlePiece:(BOOL)isPuzzlePiece {
  if ((self = [super init])) {
    self.type = RewardTypeMonster;
    self.monsterId = monsterId;
    self.isPuzzlePiece = isPuzzlePiece;
  }
  return self;
}

- (id) initWithItemId:(int)itemId {
  if ((self = [super init])) {
    self.type = RewardTypeItem;
    self.itemId = itemId;
  }
  return self;
}

- (id) initWithSilverAmount:(int)silverAmount {
  if ((self = [super init])) {
    self.type = RewardTypeSilver;
    self.silverAmount = silverAmount;
  }
  return self;
}

- (id) initWithOilAmount:(int)oilAmount {
  if ((self = [super init])) {
    self.type = RewardTypeOil;
    self.oilAmount = oilAmount;
  }
  return self;
}

- (id) initWithGoldAmount:(int)goldAmount {
  if ((self = [super init])) {
    self.type = RewardTypeGold;
    self.goldAmount = goldAmount;
  }
  return self;
}

- (id) initWithExpAmount:(int)expAmount {
  if ((self = [super init])) {
    self.type = RewardTypeExperience;
    self.expAmount = expAmount;
  }
  return self;
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
    self.userId = proto.userId;
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
  return self.invite.inviteId == object.invite.inviteId;
}

- (NSUInteger) hash {
  return self.invite.inviteId;
}

@end

@implementation UserMiniJob

+ (id) userMiniJobWithProto:(UserMiniJobProto *)proto {
  return [[UserMiniJob alloc] initWithProto:proto];
}

- (id) initWithProto:(UserMiniJobProto *)proto {
  if ((self = [super init])) {
    self.userMiniJobId = proto.userMiniJobId;
    self.miniJob = proto.miniJob;
    self.baseDmgReceived = proto.baseDmgReceived;
    self.durationMinutes = proto.durationMinutes;
    self.timeStarted = proto.hasTimeStarted ? [MSDate dateWithTimeIntervalSince1970:proto.timeStarted/1000.] : nil;
    self.timeCompleted = proto.hasTimeCompleted ? [MSDate dateWithTimeIntervalSince1970:proto.timeCompleted/1000.] : nil;
    self.userMonsterIds = proto.userMonsterIdsList;
  }
  return self;
}

- (NSDictionary *) damageDealtPerUserMonsterId {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  NSMutableDictionary *damages = [NSMutableDictionary dictionary];
  NSMutableArray *userMonsters = [NSMutableArray array];
  
  int totalAttack = 0;
  for (NSNumber *umId in self.userMonsterIds) {
    UserMonster *um = [gs myMonsterWithUserMonsterId:umId.longLongValue];
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
        int damage = [damages[@(um.userMonsterId)] intValue];
        lowestHealth = um.curHealth-damage;
      }
    }
    
    int dmgThisRound = lowestHealth * (int)aliveMonsters.count;
    if (dmgThisRound < damageToDeal) {
      for (UserMonster *um in aliveMonsters) {
        int damage = [damages[@(um.userMonsterId)] intValue];
        damage += lowestHealth;
        [damages setObject:@(damage) forKey:@(um.userMonsterId)];
      }
      damageToDeal -= dmgThisRound;
    } else {
      int dmgPerChar = damageToDeal/aliveMonsters.count;
      
      for (UserMonster *um in aliveMonsters) {
        int damage = [damages[@(um.userMonsterId)] intValue];
        damage += dmgPerChar;
        [damages setObject:@(damage) forKey:@(um.userMonsterId)];
      }
      
      // Deal remaining damage (i.e. 2 monsters-7 dmg to deal: 1 dmg needs to be dealt to someone)
      damageToDeal -= dmgPerChar * aliveMonsters.count;
      for (int i = 0; i < damageToDeal; i++) {
        UserMonster *um = aliveMonsters[i];
        int damage = [damages[@(um.userMonsterId)] intValue];
        damage += 1;
        [damages setObject:@(damage) forKey:@(um.userMonsterId)];
      }
      damageToDeal = 0;
    }
    
    // Clear out all dead monsters
    for (UserMonster *um in userMonsters) {
      int damage = [damages[@(um.userMonsterId)] intValue];
      if (um.curHealth-damage <= 0) {
        [aliveMonsters removeObject:um];
      }
    }
  }
  
  return damages;
}

- (BOOL) isEqual:(UserMiniJob *)object {
  return self.userMiniJobId == object.userMiniJobId;
}

- (NSUInteger) hash {
  return (NSUInteger)self.userMiniJobId;
}

@end
