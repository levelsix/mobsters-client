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
    self.combineStartTime = [NSDate dateWithTimeIntervalSince1970:proto.combineStartTime/1000.];
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
  int i = self.userMonsterId;
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

- (BOOL) isDonatable {
  return self.isComplete && !self.isHealing && !self.isEnhancing && !self.isSacrificing;
}

- (int) sellPrice {
  return self.experience+self.level;
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

- (MonsterLevelInfoProto *) currentLevelInfo {
  NSArray *arr = self.staticMonster.lvlInfoList;
  return arr.count > self.level-1 ? arr[self.level-1] : nil;
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
  return self.userMonsterId;
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
  int selfScore = [self isHealing] ? 3 : [self isEnhancing] ? 2 : [self isSacrificing] ? 1 : 0;
  int umScore = [um isHealing] ? 3 : [um isEnhancing] ? 2 : [um isSacrificing] ? 1 : 0;
  
  if (selfScore != umScore) {
    return [@(umScore) compare:@(selfScore)];
  } else {
    // Compare hp
    Globals *gl = [Globals sharedGlobals];
    int selfHp = [gl calculateMaxHealthForMonster:self];
    int umHp = [gl calculateMaxHealthForMonster:um];
    
    // Ordering now becomes maxHp, curHp, rarity
    if (selfHp != umHp) {
      return [@(umHp) compare:@(selfHp)];
    } else {
      if (self.curHealth != um.curHealth) {
        return [@(um.curHealth) compare:@(self.curHealth)];
      } else {
        if (self.staticMonster.quality != um.staticMonster.quality) {
          return [@(um.staticMonster.quality) compare:@(self.staticMonster.quality)];
        } else {
          return [@(self.monsterId) compare:@(um.monsterId)];
        }
      }
    }
  }
}

- (FullUserMonsterProto *)convertToProto {
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

@end

@implementation UserMonsterHealingItem

- (id) initWithHealingProto:(UserMonsterHealingProto *)proto {
  if ((self = [super init])){
    self.userId = proto.userId;
    self.userMonsterId = proto.userMonsterId;
    self.queueTime = proto.hasQueuedTimeMillis ? [NSDate dateWithTimeIntervalSince1970:proto.queuedTimeMillis/1000.0] : nil;
    self.healthProgress = proto.healthProgress;
    self.priority = proto.priority;
  }
  return self;
}

+ (id) userMonsterHealingItemWithProto:(UserMonsterHealingProto *)proto {
  return [[self alloc] initWithHealingProto:proto];
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
  return self.userMonsterId;
}

- (NSString *) description {
  return [NSString stringWithFormat:@"%p: %d, %@", self, self.userMonsterId, self.queueTime];
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
  float curPerc = baseLevel-(int)baseLevel;
  
  if (self.feeders.count == 0) {
    return curPerc;
  }
  
  EnhancementItem *feeder = [self.feeders objectAtIndex:0];
  int expGained = [gl calculateExperienceIncrease:self.baseMonster feeder:feeder];
  float newLevel = [gl calculateLevelForMonster:base.monsterId experience:base.experience+expGained];
  return curPerc+feeder.currentPercentage*(newLevel-baseLevel);
}

- (float) finalPercentageFromCurrentLevel {
  Globals *gl = [Globals sharedGlobals];
  UserMonster *base = self.baseMonster.userMonster;
  int expGained = [gl calculateExperienceIncrease:self];
  float newLevel = [gl calculateLevelForMonster:base.monsterId experience:base.experience+expGained];
  return newLevel-base.level;
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

+ (id) evolutionWithEvoItem:(EvoItem *)evo time:(NSDate *)time {
  return [[self alloc] initWithEvoItem:evo time:time];
}

- (id) initWithUserEvolutionProto:(UserMonsterEvolutionProto *)proto {
  if ((self = [super init])) {
    self.userMonsterId1 = proto.userMonsterIdsList.count > 0 ? [proto.userMonsterIdsList[0] intValue] : 0;
    self.userMonsterId2 = proto.userMonsterIdsList.count > 1 ? [proto.userMonsterIdsList[1] intValue] : 0;
    self.catalystMonsterId = proto.catalystUserMonsterId;
    self.startTime = [NSDate dateWithTimeIntervalSince1970:proto.startTime/1000.];
  }
  return self;
}

- (id) initWithEvoItem:(EvoItem *)evo time:(NSDate *)time {
  if ((self = [super init])) {
    self.userMonsterId1 = evo.userMonster1.userMonsterId;
    self.userMonsterId2 = evo.userMonster2.userMonsterId;
    self.catalystMonsterId = evo.catalystMonster.userMonsterId;
    self.startTime = time;
  }
  return self;
}

- (NSDate *) endTime {
  GameState *gs = [GameState sharedGameState];
  UserMonster *um = [gs myMonsterWithUserMonsterId:self.userMonsterId1];
  return [self.startTime dateByAddingTimeInterval:um.staticMonster.minutesToEvolve*60];
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

- (id) initWithUserMonster:(UserMonster *)um1 andUserMonster:(UserMonster *)um2 catalystMonster:(UserMonster *)catalystMonster {
  if ((self = [super init])) {
    self.userMonster1 = um1;
    self.userMonster2 = um2;
    self.catalystMonster = catalystMonster;
  }
  return self;
}

- (BOOL) isEqual:(EvoItem *)object {
  return [self.userMonster1 isEqual:object.userMonster1] && [self.userMonster2 isEqual:object.userMonster2] && [self.catalystMonster isEqual:object.catalystMonster];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"1:%d, 2:%d, C:%d", self.userMonster1.userMonsterId, self.userMonster2.userMonsterId, self.catalystMonster.userMonsterId];
}

- (NSUInteger) hash {
  return self.userMonster1.userMonsterId+self.userMonster2.userMonsterId+self.catalystMonster.userMonsterId;
}

@end

@implementation EnhancementItem

+ (id) itemWithUserEnhancementItemProto:(UserEnhancementItemProto *)proto {
  return [[self alloc] initWithUserEnhancementItemProto:proto];
}

- (id) initWithUserEnhancementItemProto:(UserEnhancementItemProto *)proto {
  if ((self = [super init])) {
    self.userMonsterId = proto.userMonsterId;
    self.expectedStartTime = proto.hasExpectedStartTimeMillis ? [NSDate dateWithTimeIntervalSince1970:proto.expectedStartTimeMillis/1000.] : nil;
    self.enhancementCost = proto.enhancingCost;
  }
  return self;
}

- (float) currentPercentage {
  int totalTime = self.secondsForCompletion;
  float timeCompleted = totalTime - [self.expectedEndTime timeIntervalSinceNow];
  return timeCompleted/totalTime;
}

- (int) secondsForCompletion {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  return [gl calculateSecondsForEnhancement:gs.userEnhancement.baseMonster feeder:self];
}

- (NSDate *) expectedEndTime {
  return [self.expectedStartTime dateByAddingTimeInterval:self.secondsForCompletion];
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
  return self.userMonsterId;
}

- (NSString *) description {
  return [NSString stringWithFormat:@"Id %d: %@", self.userMonsterId, self.expectedStartTime];
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
    self.purchaseTime = proto.hasPurchaseTime ? [NSDate dateWithTimeIntervalSince1970:proto.purchaseTime/1000.0] : nil;
    self.lastRetrieved = proto.hasLastRetrieved ? [NSDate dateWithTimeIntervalSince1970:proto.lastRetrieved/1000.0] : nil;
    self.fbInviteStructLvl = proto.fbInviteStructLvl;
  }
  return self;
}

+ (id) userStructWithProto:(FullUserStructureProto *)proto {
  return [[self alloc] initWithStructProto:proto];
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

- (NSDate *) buildCompleteDate {
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

@implementation UserNotification

- (id) initReferralNotificationAtStartup:(StartupResponseProto_ReferralNotificationProto *)proto {
  if ((self = [super init])) {
    self.otherPlayer = proto.referred;
    self.time = [NSDate dateWithTimeIntervalSince1970:proto.recruitTime/1000.0];
    self.type = kNotificationReferral;
  }
  return self;
}

- (id) initWithReferralResponse:(ReferralCodeUsedResponseProto *)proto {
  if ((self = [super init])) {
    self.otherPlayer = proto.referredPlayer;
    self.time = [NSDate date];
    self.type = kNotificationReferral;
  }
  return self;
}

- (id) initWithPrivateChatPost:(PrivateChatPostProto *)proto {
  if ((self = [super init])) {
    self.otherPlayer = proto.poster.minUserProto;
    self.time = [NSDate dateWithTimeIntervalSince1970:proto.timeOfPost/1000.];
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
    self.date = [NSDate dateWithTimeIntervalSince1970:p.timeOfChat/1000.];
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
    self.lastExpandTime = proto.hasExpandStartTime ? [NSDate dateWithTimeIntervalSince1970:proto.expandStartTime/1000.0] : nil;
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
  NSMutableArray *rewards = [NSMutableArray array];
  
  int silverAmount = 0, expAmount = 0;
  for (TaskStageProto *tsp in proto.tspList) {
    for (TaskStageMonsterProto *tsm in tsp.stageMonstersList) {
      silverAmount += tsm.cashReward;
      expAmount += tsm.expReward;
      
      if (tsm.puzzlePieceDropped) {
        Reward *r = [[Reward alloc] initWithMonsterId:tsm.monsterId isPuzzlePiece:YES];
        [rewards addObject:r];
      }
    }
  }
  
  if (silverAmount) {
    Reward *r = [[Reward alloc] initWithSilverAmount:silverAmount];
    [rewards addObject:r];
  }
  
//  if (expAmount) {
//    Reward *r = [[Reward alloc] initWithExpAmount:expAmount];
//    [rewards addObject:r];
//  }
  
  return rewards;
}

+ (NSArray *) createRewardsForQuest:(FullQuestProto *)quest {
  NSMutableArray *rewards = [NSMutableArray array];
  
  if (quest.diamondReward) {
    Reward *r = [[Reward alloc] initWithGoldAmount:quest.diamondReward];
    [rewards addObject:r];
  }
  
  if (quest.monsterIdReward) {
    Reward *r = [[Reward alloc] initWithMonsterId:quest.monsterIdReward isPuzzlePiece:!quest.isCompleteMonster];
    [rewards addObject:r];
  }
  
  if (quest.coinReward) {
    Reward *r = [[Reward alloc] initWithSilverAmount:quest.coinReward];
    [rewards addObject:r];
  }
  
  if (quest.expReward) {
    Reward *r = [[Reward alloc] initWithExpAmount:quest.expReward];
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

@implementation UserQuest

- (id) initWithProto:(FullUserQuestProto *)proto {
  if ((self = [super init])) {
    self.userId = proto.userId;
    self.questId = proto.questId;
    self.isRedeemed = proto.isRedeemed;
    self.isComplete = proto.isComplete;
    self.progress = proto.progress;
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
