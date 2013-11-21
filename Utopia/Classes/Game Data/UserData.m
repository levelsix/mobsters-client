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
    self.userUuid = proto.userUuid;
    self.monsterId = proto.monsterId;
    self.userMonsterUuid = proto.userMonsterUuid;
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
    if ([item.userMonsterUuid isEqualToString:self.userMonsterUuid]) {
      return YES;
    }
  }
  return NO;
}

- (BOOL) isEnhancing {
  GameState *gs = [GameState sharedGameState];
  return [self.userMonsterUuid isEqualToString:gs.userEnhancement.baseMonster.userMonsterUuid];
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

- (BOOL) isCombining {
  return !self.isComplete && self.numPieces == self.staticMonster.numPuzzlePieces;
}

- (int) timeLeftForCombining {
  return self.combineStartTime.timeIntervalSinceNow + self.staticMonster.minutesToCombinePieces*60;
}

- (BOOL) isEqual:(UserMonster *)object {
  if (![object respondsToSelector:@selector(userMonsterUuid)]) {
    return NO;
  }
  return [object.userMonsterUuid isEqualToString:self.userMonsterUuid];
}

- (NSUInteger) hash {
  return [self.userMonsterUuid hash];
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
    
    // Ordering now becomes maxHp, curHp, rarity, and then just unique id..
    if (selfHp != umHp) {
      return [@(umHp) compare:@(selfHp)];
    } else {
      if (self.curHealth != um.curHealth) {
        return [@(um.curHealth) compare:@(self.curHealth)];
      } else {
        if (self.staticMonster.quality != um.staticMonster.quality) {
          return [@(um.staticMonster.quality) compare:@(self.staticMonster.quality)];
        } else {
          return [self.userMonsterUuid compare:um.userMonsterUuid];
        }
      }
    }
  }
}

@end

@implementation UserMonsterHealingItem

- (id) initWithHealingProto:(UserMonsterHealingProto *)proto {
  if ((self = [super init])){
    self.userUuid = proto.userUuid;
    self.userMonsterUuid = proto.userMonsterUuid;
    self.expectedStartTime = proto.hasExpectedStartTimeMillis ? [NSDate dateWithTimeIntervalSince1970:proto.expectedStartTimeMillis/1000.0] : nil;
  }
  return self;
}

+ (id) userMonsterHealingItemWithProto:(UserMonsterHealingProto *)proto {
  return [[self alloc] initWithHealingProto:proto];
}

- (float) currentPercentageOfHealth {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  UserMonster *um = [gs myMonsterWithUserMonsterUuid:self.userMonsterUuid];
  int totalTime = self.secondsForCompletion;
  int timeCompleted = totalTime - [self.expectedEndTime timeIntervalSinceNow];
  int totalHealth = [gl calculateMaxHealthForMonster:um];
  float basePerc = um.curHealth/((float)totalHealth);
  return basePerc+(1.f-basePerc)*timeCompleted/totalTime;
}

- (int) secondsForCompletion {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  UserMonster *um = [gs myMonsterWithUserMonsterUuid:self.userMonsterUuid];
  return [gl calculateSecondsToHealMonster:um];
}

- (NSDate *) expectedEndTime {
  return [self.expectedStartTime dateByAddingTimeInterval:self.secondsForCompletion];
}

- (UserMonsterHealingProto *) convertToProto {
  return [[[[[UserMonsterHealingProto builder]
             setUserUuid:self.userUuid]
            setUserMonsterUuid:self.userMonsterUuid]
           setExpectedStartTimeMillis:self.expectedStartTime.timeIntervalSince1970*1000]
          build];
}

- (id) copy {
  UserMonsterHealingItem *item = [[UserMonsterHealingItem alloc] init];
  item.userUuid = self.userUuid;
  item.userMonsterUuid = self.userMonsterUuid;
  item.expectedStartTime = [self.expectedStartTime copy];
  return item;
}

- (BOOL) isEqual:(UserMonsterHealingItem *)object {
  if (![object respondsToSelector:@selector(userMonsterUuid)]) {
    return NO;
  }
  return [object.userMonsterUuid isEqualToString:self.userMonsterUuid];
}

- (NSUInteger) hash {
  return [self.userMonsterUuid hash];
}

- (NSString *) description {
  return [NSString stringWithFormat:@"%p: %@, %@", self, self.userMonsterUuid, self.expectedStartTime];
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

@implementation EnhancementItem

+ (id) itemWithUserEnhancementItemProto:(UserEnhancementItemProto *)proto {
  return [[self alloc] initWithUserEnhancementItemProto:proto];
}

- (id) initWithUserEnhancementItemProto:(UserEnhancementItemProto *)proto {
  if ((self = [super init])) {
    self.userMonsterUuid = proto.userMonsterUuid;
    self.expectedStartTime = proto.hasExpectedStartTimeMillis ? [NSDate dateWithTimeIntervalSince1970:proto.expectedStartTimeMillis/1000.] : nil;
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
  return [gs myMonsterWithUserMonsterUuid:self.userMonsterUuid];
}

- (UserEnhancementItemProto *) convertToProto {
  UserEnhancementItemProto_Builder *bldr = [UserEnhancementItemProto builder];
  bldr.userMonsterUuid = self.userMonsterUuid;
  if (self.expectedStartTime) {
    bldr.expectedStartTimeMillis = self.expectedStartTime.timeIntervalSince1970*1000;
  }
  return bldr.build;
}

- (id) copy {
  EnhancementItem *item = [[EnhancementItem alloc] init];
  item.userMonsterUuid = self.userMonsterUuid;
  item.expectedStartTime = [self.expectedStartTime copy];
  return item;
}

- (BOOL) isEqual:(UserMonsterHealingItem *)object {
  if (![object respondsToSelector:@selector(userMonsterUuid)]) {
    return NO;
  }
  return [object.userMonsterUuid isEqual:self.userMonsterUuid];
}

- (NSUInteger) hash {
  return [self.userMonsterUuid hash];
}

- (NSString *) description {
  return [NSString stringWithFormat:@"Uuid %@: %@", self.userMonsterUuid, self.expectedStartTime];
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
    self.purchaseTime = proto.hasPurchaseTime ? [NSDate dateWithTimeIntervalSince1970:proto.purchaseTime/1000.0] : nil;
    self.lastRetrieved = proto.hasLastRetrieved ? [NSDate dateWithTimeIntervalSince1970:proto.lastRetrieved/1000.0] : nil;
  }
  return self;
}

+ (id) userStructWithProto:(FullUserStructureProto *)proto {
  return [[self alloc] initWithStructProto:proto];
}

- (FullStructureProto *) fsp {
  return [[GameState sharedGameState] structWithId:self.structId];
}

- (FullStructureProto *) fspForNextLevel {
  if (self.fsp.successorStructId) {
    return [[GameState sharedGameState] structWithId:self.fsp.successorStructId];
  } else {
    return nil;
  }
}

- (int) maxLevel {
  GameState *gs = [GameState sharedGameState];
  FullStructureProto *fsp = self.fsp;
  while (fsp.successorStructId) {
    fsp = [gs structWithId:fsp.successorStructId];
  }
  return fsp.level;
}

- (UserStructState) state {
  NSDate *now = [NSDate date];
  FullStructureProto *fsp = self.fsp;
  
  if (!self.isComplete) {
    return kBuilding;
  }
  
  NSDate *done = [NSDate dateWithTimeInterval:fsp.minutesToGain*60 sinceDate:self.lastRetrieved];
  if ([now compare:done] == NSOrderedDescending) {
    return kRetrieving;
  }
  return kWaitingForIncome;
}

- (NSDate *) buildCompleteDate {
  int minutes = self.fsp.minutesToBuild;
  return [self.purchaseTime dateByAddingTimeInterval:minutes*60.f];
}

- (NSTimeInterval) timeLeftForBuildComplete {
  return [self.buildCompleteDate timeIntervalSinceNow];
}

- (NSString *) description {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:self.structId];
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
    self.userUuid = proto.userUuid;
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
  
  int cashAmount = 0, expAmount = 0;
  for (TaskStageProto *tsp in proto.tspList) {
    for (TaskStageMonsterProto *tsm in tsp.stageMonstersList) {
      cashAmount += tsm.cashReward;
      expAmount += tsm.expReward;
      
      if (tsm.puzzlePieceDropped) {
        Reward *r = [[Reward alloc] initWithMonsterId:tsm.monsterId isPuzzlePiece:YES];
        [rewards addObject:r];
      }
    }
  }
  
  if (cashAmount) {
    Reward *r = [[Reward alloc] initWithCashAmount:cashAmount];
    [rewards addObject:r];
  }
  
  if (expAmount) {
    Reward *r = [[Reward alloc] initWithExpAmount:expAmount];
    [rewards addObject:r];
  }
  
  return rewards;
}

+ (NSArray *) createRewardsForQuest:(QuestProto *)quest {
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
    Reward *r = [[Reward alloc] initWithCashAmount:quest.cashReward];
    [rewards addObject:r];
  }
  
  if (quest.expReward) {
    Reward *r = [[Reward alloc] initWithExpAmount:quest.expReward];
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

- (id) initWithCashAmount:(int)cashAmount {
  if ((self = [super init])) {
    self.type = RewardTypeCash;
    self.cashAmount = cashAmount;
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
    self.userUuid = proto.userUuid;
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

- (QuestProto *) quest {
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

@end
