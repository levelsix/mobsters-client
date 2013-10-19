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
    self.enhancementPercentage = proto.enhancementPercentage;
    self.curHealth = proto.currentHealth;
  }
  return self;
}

+ (id) userMonsterWithProto:(FullUserMonsterProto *)proto {
  return [[self alloc] initWithMonsterProto:proto];
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

@implementation UserStruct

@synthesize userStructId, userId, structId, level, isComplete, coordinates, orientation, purchaseTime, lastRetrieved, lastUpgradeTime;

- (id) initWithStructProto:(FullUserStructureProto *)proto {
  if ((self = [super init])) {
    self.userStructId = proto.userStructId;
    self.userId = proto.userId;
    self.structId = proto.structId;
    self.level = proto.level;
    self.isComplete = proto.isComplete;
    self.coordinates = CGPointMake(proto.coordinates.x, proto.coordinates.y);
    self.orientation = proto.orientation;
    self.purchaseTime = proto.hasPurchaseTime ? [NSDate dateWithTimeIntervalSince1970:proto.purchaseTime/1000.0] : nil;
    self.lastRetrieved = proto.hasLastRetrieved ? [NSDate dateWithTimeIntervalSince1970:proto.lastRetrieved/1000.0] : nil;
    self.lastUpgradeTime = proto.hasLastUpgradeTime ? [NSDate dateWithTimeIntervalSince1970:proto.lastUpgradeTime/1000.0] : nil;
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

@implementation UserJob

@synthesize jobId, jobType;
@synthesize title, subtitle;
@synthesize numCompleted, total;

- (id) initWithTask:(FullTaskProto *)p {
  if ((self = [super init])) {
    self.jobId = p.taskId;
    self.jobType = kTask;
    self.title = p.name;
  }
  return self;
}

- (id) initWithBuildStructJob:(BuildStructJobProto *)p {
  if ((self = [super init])) {
    GameState *gs = [GameState sharedGameState];
    FullStructureProto *s = [gs structWithId:p.structId];
    self.jobId = p.buildStructJobId;
    self.jobType = kBuildStructJob;
    self.title = [NSString stringWithFormat:@"Build %@%@", s.name, p.quantityRequired == 1 ? @"" : [NSString stringWithFormat:@" (%d)", p.quantityRequired]];
    self.total = p.quantityRequired;
  }
  return self;
}

- (id) initWithUpgradeStructJob:(UpgradeStructJobProto *)p {
  if ((self = [super init])) {
    GameState *gs = [GameState sharedGameState];
    FullStructureProto *s = [gs structWithId:p.structId];
    self.jobId = p.upgradeStructJobId;
    self.jobType = kUpgradeStructJob;
    self.title = [NSString stringWithFormat:@"Upgrade %@ to Level %d", s.name, p.levelReq];
    self.total = p.levelReq;
  }
  return self;
}

- (id) initWithCoinRetrieval:(int)amount questId:(int)questId {
  if ((self = [super init])) {
    self.jobId = questId;
    self.jobType = kCoinRetrievalJob;
    self.title = [NSString stringWithFormat:@"Collect %d silver from your income buildings", amount];
    self.total = amount;
  }
  return self;
}

- (id) initWithSpecialQuestAction:(SpecialQuestAction)sqa questId:(int)questId {
  if ((self = [super init])) {
    self.jobId = questId;
    self.jobType = kSpecialJob;
    
    NSString *desc = nil;
    switch (sqa) {
      case SpecialQuestActionRequestJoinClan:
        desc = @"Request to Join 1 Clan";
        break;
        
      default:
        break;
    }
    self.title = desc;
    
    self.total = 1;
  }
  return self;
}

+ (NSArray *)jobsForQuest:(FullQuestProto *)fqp {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *jobs = [NSMutableArray array];
  UserJob *job = nil;
  
  for (NSNumber *n in fqp.taskReqsList) {
    job = [[UserJob alloc] initWithTask:[gs taskWithId:n.intValue]];
    [jobs addObject:job];
  }
  
  for (NSNumber *n in fqp.buildStructJobsReqsList) {
    job = [[UserJob alloc] initWithBuildStructJob:[gs.staticBuildStructJobs objectForKey:n]];
    [jobs addObject:job];
  }
  
  for (NSNumber *n in fqp.upgradeStructJobsReqsList) {
    job = [[UserJob alloc] initWithUpgradeStructJob:[gs.staticUpgradeStructJobs objectForKey:n]];
    [jobs addObject:job];
  }
  
  if (fqp.coinRetrievalReq > 0) {
    job = [[UserJob alloc] initWithCoinRetrieval:fqp.coinRetrievalReq questId:fqp.questId];
    [jobs addObject:job];
  }
  
  if (fqp.hasSpecialQuestActionReq) {
    job = [[UserJob alloc] initWithSpecialQuestAction:fqp.specialQuestActionReq questId:fqp.questId];
    [jobs addObject:job];
  }
  
  return jobs;
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
