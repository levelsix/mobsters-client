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

- (BOOL) isSacrificing {
  GameState *gs = [GameState sharedGameState];
  for (EnhancementItem *ei in gs.userEnhancement.feeders) {
    if (self.userMonsterId == ei.userMonsterId) {
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

- (BOOL) isEqual:(UserMonster *)object {
  if (![object respondsToSelector:@selector(userMonsterId)]) {
    return NO;
  }
  return object.userMonsterId == self.userMonsterId;
}

@end

@implementation UserMonsterHealingItem

- (id) initWithHealingProto:(UserMonsterHealingProto *)proto {
  if ((self = [super init])){
    self.userId = proto.userId;
    self.userMonsterId = proto.userMonsterId;
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
  UserMonster *um = [gs myMonsterWithUserMonsterId:self.userMonsterId];
  int totalTime = self.secondsForCompletion;
  int timeCompleted = totalTime - [self.expectedEndTime timeIntervalSinceNow];
  int totalHealth = [gl calculateMaxHealthForMonster:um];
  float basePerc = um.curHealth/((float)totalHealth);
  return basePerc+(1.f-basePerc)*timeCompleted/totalTime;
}

- (int) secondsForCompletion {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  UserMonster *um = [gs myMonsterWithUserMonsterId:self.userMonsterId];
  return [gl calculateSecondsToHealMonster:um];
}

- (NSDate *) expectedEndTime {
  return [self.expectedStartTime dateByAddingTimeInterval:self.secondsForCompletion];
}

- (UserMonsterHealingProto *) convertToProto {
  return [[[[[UserMonsterHealingProto builder]
             setUserId:self.userId]
            setUserMonsterId:self.userMonsterId]
           setExpectedStartTimeMillis:self.expectedStartTime.timeIntervalSince1970*1000]
          build];
}

- (id) copy {
  UserMonsterHealingItem *item = [[UserMonsterHealingItem alloc] init];
  item.userId = self.userId;
  item.userMonsterId = self.userMonsterId;
  item.expectedStartTime = [self.expectedStartTime copy];
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
  return [NSString stringWithFormat:@"%p: %d, %@", self, self.userMonsterId, self.expectedStartTime];
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
    self.userMonsterId = proto.userMonsterId;
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
  return [gs myMonsterWithUserMonsterId:self.userMonsterId];
}

- (UserEnhancementItemProto *) convertToProto {
  UserEnhancementItemProto_Builder *bldr = [UserEnhancementItemProto builder];
  bldr.userMonsterId = self.userMonsterId;
  if (self.expectedStartTime) {
    bldr.expectedStartTimeMillis = self.expectedStartTime.timeIntervalSince1970*1000;
  }
  return bldr.build;
}

- (id) copy {
  EnhancementItem *item = [[EnhancementItem alloc] init];
  item.userMonsterId = self.userMonsterId;
  item.expectedStartTime = [self.expectedStartTime copy];
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

@synthesize userStructId, userId, structId, level, isComplete, coordinates, orientation, purchaseTime, lastRetrieved, lastUpgradeTime;

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
  }
  return self;
}

+ (id) userStructWithProto:(FullUserStructureProto *)proto {
  return [[self alloc] initWithStructProto:proto];
}

- (FullStructureProto *) fsp {
  return [[GameState sharedGameState] structWithId:structId];
}

- (UserStructState) state {
  NSDate *now = [NSDate date];
  NSDate *done;
  FullStructureProto *fsp = self.fsp;
  
  if (!isComplete) {
    if (lastUpgradeTime) {
      return kUpgrading;
    } else {
      return kBuilding;
    }
  }
  
  done = [NSDate dateWithTimeInterval:fsp.minutesToGain*60 sinceDate:lastRetrieved];
  if ([now compare:done] == NSOrderedDescending) {
    return kRetrieving;
  }
  return kWaitingForIncome;
}

- (NSString *) description {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:self.structId];
  return [NSString stringWithFormat:@"%p: %@, %@", self, fsp.name, NSStringFromCGPoint(coordinates)];
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
    self.otherPlayer = proto.poster;
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
  
  if (expAmount) {
    Reward *r = [[Reward alloc] initWithExpAmount:expAmount];
    [rewards addObject:r];
  }
  
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

+ (id) requestForInventorySlotsWithUser:(MinimumUserProtoWithFacebookId *)user {
  return [[self alloc] initInventorySlotsRequestWithUser:user];
}

- (id) initInventorySlotsRequestWithUser:(MinimumUserProtoWithFacebookId *)user {
  if ((self = [super init])) {
    self.user = user;
    self.type = RequestFromFriendInventorySlots;
  }
  return self;
}

@end
