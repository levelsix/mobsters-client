//
//  GameState.m
//  Utopia
//
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "GameState.h"
#import "LNSynthesizeSingleton.h"
#import "SocketCommunication.h"
#import "Globals.h"
#import "OutgoingEventController.h"
#import "AppDelegate.h"
#import "HomeMap.h"
#import "ClanViewController.h"
#import "Downloader.h"
#import "SocketCommunication.h"
#import "UnreadNotifications.h"
#import "StaticStructure.h"
#import "QuestUtil.h"
#import "HospitalQueueSimulator.h"
#import "PersistentEventProto+Time.h"

#define TagLog(...) //LNLog(__VA_ARGS__)

#define PURGE_EQUIP_KEY @"Purge Equip Images"

@implementation GameState

LN_SYNTHESIZE_SINGLETON_FOR_CLASS(GameState);

- (id) init {
  if ((self = [super init])) {
    _connected = NO;
    _staticTasks = [[NSMutableDictionary alloc] init];
    _staticCities = [[NSMutableDictionary alloc] init];
    _staticStructs = [[NSMutableDictionary alloc] init];
    _staticMonsters = [[NSMutableDictionary alloc] init];
    _staticRaids = [[NSMutableDictionary alloc] init];
    _staticItems = [[NSMutableDictionary alloc] init];
    _staticObstacles = [[NSMutableDictionary alloc] init];
    _eventCooldownTimes = [[NSMutableDictionary alloc] init];
    _notifications = [[NSMutableArray alloc] init];
    _myStructs = [[NSMutableArray alloc] init];
    _myObstacles = [[NSMutableArray alloc] init];
    _myMonsters = [[NSMutableArray alloc] init];
    _myQuests = [[NSMutableDictionary alloc] init];
    _globalChatMessages = [[NSMutableArray alloc] init];
    _clanChatMessages = [[NSMutableArray alloc] init];
    _rareBoosterPurchases = [[NSMutableArray alloc] init];
    _monsterHealingQueue = [[NSMutableArray alloc] init];
    _recentlyHealedMonsterIds = [[NSMutableSet alloc] init];
    _fbAcceptedRequestsFromMe = [[NSMutableSet alloc] init];
    _fbUnacceptedRequestsFromFriends = [[NSMutableSet alloc] init];
    
    _availableQuests = [[NSMutableDictionary alloc] init];
    _inProgressCompleteQuests = [[NSMutableDictionary alloc] init];
    _inProgressIncompleteQuests = [[NSMutableDictionary alloc] init];
    
    _privateChats = [[NSMutableArray alloc] init];
    
    _unrespondedUpdates = [[NSMutableArray alloc] init];
    
    _requestedClans = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void) updateUser:(FullUserProto *)user timestamp:(uint64_t)time {
  // Copy over data from full user proto
  if (_userId != user.userId || ![_name isEqualToString:user.name] || (user.hasClan && ![self.clan.data isEqualToData:user.clan.data]) || (!user.hasClan && self.clan)) {
    self.userId = user.userId;
    self.name = user.name;
    if (user.hasClan) {
      self.clan = user.clan;
    } else {
      self.clan = nil;
    }
    [[SocketCommunication sharedSocketCommunication] rebuildSender];
  }
  self.level = user.level;
  self.gold = user.gems;
  self.silver = user.cash;
  self.oil = user.oil;
  self.experience = user.experience;
  self.tasksCompleted = user.tasksCompleted;
  self.referralCode = user.referralCode;
  self.numReferrals = user.numReferrals;
  self.isAdmin = user.isAdmin;
  self.hasReceivedfbReward = user.hasReceivedfbReward;
  self.numBeginnerSalesPurchased = user.numBeginnerSalesPurchased;
  self.createTime = [MSDate dateWithTimeIntervalSince1970:user.createTime/1000.0];
  self.lastObstacleCreateTime = [MSDate dateWithTimeIntervalSince1970:user.lastObstacleSpawnedTime/1000.0];
  if (user.hasFacebookId) self.facebookId = user.facebookId;
  if (user.hasGameCenterId) self.gameCenterId = user.gameCenterId;
  if (user.hasDeviceToken) self.deviceToken = user.deviceToken;
  
  self.lastLogoutTime = [MSDate dateWithTimeIntervalSince1970:user.lastLogoutTime/1000.0];
  self.lastLoginTimeNum = user.lastLoginTime;
  
  if (user.hasPvpLeagueInfo) {
    self.pvpLeague = user.pvpLeagueInfo;
    self.shieldEndTime = [MSDate dateWithTimeIntervalSince1970:user.pvpLeagueInfo.shieldEndTime/1000.0];
  }
  
  for (id<GameStateUpdate> gsu in _unrespondedUpdates) {
    if ([gsu respondsToSelector:@selector(update)]) {
      [gsu update];
    }
  }
  
  [[NSNotificationCenter defaultCenter] postNotificationName:GAMESTATE_UPDATE_NOTIFICATION object:nil];
}

- (FullUserProto *) convertToFullUserProto {
  FullUserProto_Builder *fup = [FullUserProto builder];
  fup.userId = self.userId;
  fup.name = self.name;
  if (self.clan) fup.clan = self.clan;
  fup.level = self.level;
  fup.gems = self.gold;
  fup.cash = self.silver;
  fup.experience = self.experience;
  fup.tasksCompleted = self.tasksCompleted;
  fup.pvpLeagueInfo = self.pvpLeague;
  fup.referralCode = self.referralCode;
  fup.numReferrals = self.numReferrals;
  fup.isAdmin = self.isAdmin;
  fup.hasReceivedfbReward = self.hasReceivedfbReward;
  fup.numBeginnerSalesPurchased = self.numBeginnerSalesPurchased;
  fup.createTime = self.createTime.timeIntervalSince1970*1000.;
  fup.lastLogoutTime = self.lastLogoutTime.timeIntervalSince1970*1000.;
  fup.lastObstacleSpawnedTime = self.lastObstacleCreateTime.timeIntervalSince1970*1000.;
  fup.facebookId = self.facebookId;
  fup.lastLoginTime = self.lastLoginTimeNum;
  
  return [fup build];
}

- (MinimumUserProto *) minUser {
  MinimumUserProto_Builder *mup = [[[MinimumUserProto builder] setName:_name] setUserId:_userId];
  if (_clan != nil) {
    mup.clan = _clan;
  }
  return mup.build;
}

- (MinimumUserProtoWithLevel *) minUserWithLevel {
  MinimumUserProto_Builder *mup = [[[MinimumUserProto builder] setName:_name] setUserId:_userId];
  if (_clan != nil) {
    mup.clan = _clan;
  }
  MinimumUserProtoWithLevel *mupl = [[[[MinimumUserProtoWithLevel builder] setMinUserProto:mup.build] setLevel:_level] build];
  return mupl;
}

- (id) getStaticDataFrom:(NSDictionary *)dict withId:(int)itemId {
  if (itemId == 0) {
    [Globals popupMessage:@"Attempted to access static item 0"];
    return nil;
  }
  NSNumber *num = [NSNumber numberWithInt:itemId];
  id p = [dict objectForKey:num];
  return p;
}

- (id<StaticStructure>) structWithId:(int)structId {
  if (structId == 0) {
    [Globals popupMessage:@"Attempted to access struct 0"];
    return nil;
  }
  return [self getStaticDataFrom:_staticStructs withId:structId];
}

- (MonsterProto *) monsterWithId:(int)monsterId {
  if (monsterId == 0) {
    [Globals popupMessage:@"Attempted to access monster 0"];
    return nil;
  }
  return [self getStaticDataFrom:_staticMonsters withId:monsterId];
}

- (FullCityProto *) cityWithId:(int)cityId {
  if (cityId == 0) {
    [Globals popupMessage:@"Attempted to access city 0"];
    return nil;
  }
  return [self getStaticDataFrom:_staticCities withId:cityId];
}

- (ClanRaidProto *) raidWithId:(int)raidId {
  if (raidId == 0) {
    [Globals popupMessage:@"Attempted to access raid 0"];
    return nil;
  }
  return [self getStaticDataFrom:_staticRaids withId:raidId];
}

- (FullTaskProto *) taskWithId:(int)taskId {
  if (taskId == 0) {
    [Globals popupMessage:@"Attempted to access task 0"];
    return nil;
  }
  return [self getStaticDataFrom:_staticTasks withId:taskId];
}

- (FullTaskProto *) taskWithCityId:(int)cityId assetId:(int)assetId {
  for (FullTaskProto *ftp in self.staticTasks.allValues) {
    if (ftp.cityId == cityId && ftp.assetNumWithinCity == assetId) {
      return ftp;
    }
  }
  return nil;
}

- (ItemProto *) itemForId:(int)itemId {
  if (itemId == 0) {
    [Globals popupMessage:@"Attempted to access item 0"];
    return nil;
  }
  return [self getStaticDataFrom:_staticItems withId:itemId];
}

- (ObstacleProto *) obstacleWithId:(int)obstacleId {
  if (obstacleId == 0) {
    [Globals popupMessage:@"Attempted to access obstacle 0"];
    return nil;
  }
  return [self getStaticDataFrom:_staticObstacles withId:obstacleId];
}

- (ClanIconProto *) clanIconWithId:(int)iconId {
  for (ClanIconProto *ci in self.staticClanIcons) {
    if (ci.clanIconId == iconId) {
      return ci;
    }
  }
  return nil;
}

- (PvpLeagueProto *) leagueForId:(int)leagueId {
  for (PvpLeagueProto *pvp in self.staticLeagues) {
    if (pvp.leagueId == leagueId) {
      return pvp;
    }
  }
  return nil;
}

- (PersistentEventProto *) persistentEventWithId:(int)eventId {
  for (PersistentEventProto *pe in self.persistentEvents) {
    if (pe.eventId == eventId) {
      return pe;
    }
  }
  return nil;
}

- (PersistentEventProto *) currentPersistentEventWithType:(PersistentEventProto_EventType)type {
  for (PersistentEventProto *pe in self.persistentEvents) {
    if (pe.type == type && pe.isRunning) {
      return pe;
    }
  }
  return nil;
}

- (MonsterBattleDialogueProto *) battleDialogueForMonsterId:(int)monsterId type:(MonsterBattleDialogueProto_DialogueType)type {
  NSDictionary *dict = [self.battleDialogueInfo objectForKey:@(monsterId)];
  NSArray *dialogues = [dict objectForKey:@(type)];
  
  float rand = ((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX);
  float curPerc = 0.f;
  for (MonsterBattleDialogueProto *dia in dialogues) {
    curPerc += dia.probabilityUttered;
    if (rand < curPerc) {
      return dia;
    }
  }
  return nil;
}

- (void) addToMyMonsters:(NSArray *)monsters {
  for (FullUserMonsterProto *mon in monsters) {
    UserMonster *um = [UserMonster userMonsterWithProto:mon];
    NSInteger index = [self.myMonsters indexOfObject:um];
    if (index != NSNotFound) {
      [self.myMonsters replaceObjectAtIndex:index withObject:um];
    } else {
      [self.myMonsters addObject:um];
    }
  }
  [self beginCombineTimer];
  [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
  
  [QuestUtil checkAllDonateQuests];
}

- (void) addToMyStructs:(NSArray *)structs {
  for (FullUserStructureProto *st in structs) {
    [self.myStructs addObject:[UserStruct userStructWithProto:st]];
  }
  [self checkResidencesForFbCompletion];
  [[NSNotificationCenter defaultCenter] postNotificationName:GAMESTATE_UPDATE_NOTIFICATION object:nil];
}

- (void) addToMyObstacles:(NSArray *)obstacles {
  NSMutableArray *toRemove = [NSMutableArray array];
  for (UserObstacle *uo in self.myObstacles) {
    if (uo.userObstacleId == 0) {
      [toRemove addObject:uo];
    }
  }
  [self.myObstacles removeObjectsInArray:toRemove];
  
  for (UserObstacleProto *p in obstacles) {
    [self.myObstacles addObject:[[UserObstacle alloc] initWithObstacleProto:p]];
  }
  [[NSNotificationCenter defaultCenter] postNotificationName:NEW_OBSTACLES_CREATED_NOTIFICATION object:nil];
}

- (void) addToMyQuests:(NSArray *)quests {
  for (FullUserQuestProto *uq in quests) {
    [self.myQuests setObject:[UserQuest questWithProto:uq] forKey:[NSNumber numberWithInt:uq.questId]];
  }
}

- (void) addToAvailableQuests:(NSArray *)quests {
  if (quests.count > 0) {
    for (FullQuestProto *fqp in quests) {
      [self.availableQuests setObject:fqp forKey:[NSNumber numberWithInt:fqp.questId]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QUESTS_CHANGED_NOTIFICATION object:nil];
  }
}

- (void) addToInProgressCompleteQuests:(NSArray *)quests {
  if (quests.count > 0) {
    for (FullQuestProto *fqp in quests) {
      [self.inProgressCompleteQuests setObject:fqp forKey:[NSNumber numberWithInt:fqp.questId]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QUESTS_CHANGED_NOTIFICATION object:nil];
  }
}

- (void) addToInProgressIncompleteQuests:(NSArray *)quests {
  if (quests.count > 0) {
    for (FullQuestProto *fqp in quests) {
      [self.inProgressIncompleteQuests setObject:fqp forKey:[NSNumber numberWithInt:fqp.questId]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QUESTS_CHANGED_NOTIFICATION object:nil];
  }
}

- (void) addToStaticLevelInfos:(NSArray *)lurep {
  self.staticLevelInfos = [NSMutableDictionary dictionary];
  for (StaticUserLevelInfoProto *exp in lurep) {
    NSNumber *level = [NSNumber numberWithInt:exp.level];
    [self.staticLevelInfos setObject:exp forKey:level];
  }
}

- (void) addBattleDialogueInfo:(NSArray *)mbds {
  self.battleDialogueInfo = [NSMutableDictionary dictionary];
  for (MonsterBattleDialogueProto *dia in mbds) {
    NSMutableDictionary *dict = [self.battleDialogueInfo objectForKey:@(dia.monsterId)];
    if (!dict) {
      dict = [NSMutableDictionary dictionary];
      [self.battleDialogueInfo setObject:dict forKey:@(dia.monsterId)];
    }
    
    NSMutableArray *arr = [dict objectForKey:@(dia.dialogueType)];
    if (!arr) {
      arr = [NSMutableArray array];
      [dict setObject:arr forKey:@(dia.dialogueType)];
    }
    
    [arr addObject:dia];
  }
}

- (void) addToExpansionCosts:(NSArray *)costs {
  self.expansionCosts = [NSMutableDictionary dictionary];
  for (CityExpansionCostProto *exp in costs) {
    [self.expansionCosts setObject:exp forKey:@(exp.expansionNum)];
  }
}

- (void) addToEventCooldownTimes:(NSArray *)arr {
  for (UserPersistentEventProto *u in arr) {
    MSDate *date = [MSDate dateWithTimeIntervalSince1970:u.coolDownStartTime/1000.];
    [self.eventCooldownTimes setObject:date forKey:@(u.eventId)];
  }
}

- (void) addInventorySlotsRequests:(NSArray *)invites {
  BOOL newFbInvite = NO, fbInviteAccepted = NO;
  for (UserFacebookInviteForSlotProto *invite in invites) {
    RequestFromFriend *req = [RequestFromFriend requestForInventorySlotsWithInvite:invite];
    if (!invite.timeAccepted && [invite.recipientFacebookId isEqualToString:self.facebookId]) {
      [self.fbUnacceptedRequestsFromFriends addObject:req];
      newFbInvite = YES;
    } else if (invite.timeAccepted && [invite.inviter.facebookId isEqualToString:self.facebookId]) {
      [self.fbAcceptedRequestsFromMe addObject:req];
      fbInviteAccepted = YES;
    }
  }
  
  // Check all residences
  if (fbInviteAccepted) {
    [self checkResidencesForFbCompletion];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FB_INVITE_ACCEPTED_NOTIFICATION object:nil];
  }
  
  if (newFbInvite) {
    [[NSNotificationCenter defaultCenter] postNotificationName:NEW_FB_INVITE_NOTIFICATION object:nil];
  }
}

- (void) checkResidencesForFbCompletion {
  for (UserStruct *us in self.myStructs) {
    if (us.staticStruct.structInfo.structType == StructureInfoProto_StructTypeResidence) {
      ResidenceProto *res = (ResidenceProto *)us.staticStructForNextFbLevel;
      NSArray *arr = [self acceptedFbRequestsForUserStructId:us.userStructId fbStructLevel:us.fbInviteStructLvl+1];
      if (res.numAcceptedFbInvites <= arr.count) {
        [[OutgoingEventController sharedOutgoingEventController] increaseInventorySlots:us withGems:NO delegate:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:FB_INCREASE_SLOTS_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@(us.userStructId), @"UserStructId", nil]];
      }
    }
  }
}

- (NSArray *) acceptedFbRequestsForUserStructId:(int)userStructId fbStructLevel:(int)level {
  NSMutableArray *arr = [NSMutableArray array];
  for (RequestFromFriend *req in self.fbAcceptedRequestsFromMe) {
    UserFacebookInviteForSlotProto *inv = req.invite;
    if (inv.userStructId == userStructId && inv.structFbLvl == level) {
      [arr addObject:req];
    }
  }
  return arr;
}

- (NSSet *) facebookIdsAlreadyUsed {
  NSMutableSet *set = [NSMutableSet set];
  for (RequestFromFriend *req in self.fbAcceptedRequestsFromMe) {
    [set addObject:req.invite.recipientFacebookId];
  }
  return set;
}

- (void) addNotification:(UserNotification *)un {
  [self.notifications addObject:un];
  [self.notifications sortUsingComparator:^NSComparisonResult(UserNotification *obj1, UserNotification *obj2) {
    return [obj2.time compare:obj1.time];
  }];
  
  if ([un.time compare:_lastLogoutTime] == NSOrderedDescending) {
    un.hasBeenViewed = NO;
  } else {
    un.hasBeenViewed = YES;
  }
}

- (void) addChatMessage:(MinimumUserProtoWithLevel *)sender message:(NSString *)msg scope:(GroupChatScope)scope isAdmin:(BOOL)isAdmin {
  ChatMessage *cm = [[ChatMessage alloc] init];
  cm.sender = sender;
  cm.message = msg;
  cm.date = [MSDate date];
  cm.isAdmin = isAdmin;
  [self addChatMessage:cm scope:scope];
}

- (void) addChatMessage:(ChatMessage *)cm scope:(GroupChatScope) scope {
  if (scope == GroupChatScopeGlobal) {
    [self.globalChatMessages addObject:cm];
  } else {
    [self.clanChatMessages addObject:cm];
  }
}

- (void) addPrivateChat:(PrivateChatPostProto *)post {
  int userId = post.otherUserId;
  PrivateChatPostProto *privChat = nil;
  for (PrivateChatPostProto *pcpp in self.privateChats) {
    int otherUserId = pcpp.otherUserId;
    if (userId == otherUserId) {
      privChat = pcpp;
    }
  }
  [self.privateChats removeObject:privChat];
  [self.privateChats insertObject:post atIndex:0];
}

- (void) addBoosterPurchase:(RareBoosterPurchaseProto *)bp {
  [self.rareBoosterPurchases insertObject:bp atIndex:0];
}

- (void) addUserMonsterHealingItemToEndOfQueue:(UserMonsterHealingItem *)item {
  UserMonsterHealingItem *prevItem = [self.monsterHealingQueue lastObject];
  item.priority = prevItem.priority+1;
  item.queueTime = [MSDate date];
  
  [self.monsterHealingQueue addObject:item];
  [self readjustAllMonsterHealingProtos];
  
  [QuestUtil checkAllDonateQuests];
}

- (void) removeUserMonsterHealingItem:(UserMonsterHealingItem *)item {
  NSInteger index = [self.monsterHealingQueue indexOfObject:item];
  [self saveHealthProgressesFromIndex:index];
  
  [self.monsterHealingQueue removeObject:item];
  
  [self readjustAllMonsterHealingProtos];
  
  [QuestUtil checkAllDonateQuests];
}

- (void) addAllMonsterHealingProtos:(NSArray *)items {
  [self.monsterHealingQueue removeAllObjects];
  
  for (UserMonsterHealingProto *proto in items) {
    [self.monsterHealingQueue addObject:[UserMonsterHealingItem userMonsterHealingItemWithProto:proto]];
  }
  
  [self.monsterHealingQueue sortUsingComparator:^NSComparisonResult(UserMonsterHealingItem *obj1, UserMonsterHealingItem *obj2) {
    return [@(obj1.priority) compare:@(obj2.priority)];
  }];
  
  [[SocketCommunication sharedSocketCommunication] reloadHealQueueSnapshot];
  
  [self readjustAllMonsterHealingProtos];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:HEAL_WAIT_COMPLETE_NOTIFICATION object:nil];
  
  [QuestUtil checkAllDonateQuests];
}

- (void) saveHealthProgressesFromIndex:(NSInteger)index {
  NSMutableArray *allHospitals = [NSMutableArray array];
  for (UserStruct *us in self.myStructs) {
    if ([us.staticStruct structInfo].structType == StructureInfoProto_StructTypeHospital) {
      [allHospitals addObject:us];
    }
  }
  
  HospitalQueueSimulator *sim = [[HospitalQueueSimulator alloc] initWithHospitals:allHospitals healingItems:self.monsterHealingQueue];
  [sim simulateUntilDate:[MSDate date]];
  
  for (HealingItemSim *hi in sim.healingItems) {
    UserMonsterHealingItem *item = nil;
    for (UserMonsterHealingItem *i in self.monsterHealingQueue) {
      if (!item || hi.userMonsterId == i.userMonsterId) {
        item = i;
      }
    }
    item.healthProgress = hi.healthProgress;
    item.queueTime = [MSDate date];
  }
}

- (void) readjustAllMonsterHealingProtos {
  NSArray *allHospitals = [self allHospitals];
  
  HospitalQueueSimulator *sim = [[HospitalQueueSimulator alloc] initWithHospitals:allHospitals healingItems:self.monsterHealingQueue];
  [sim simulate];
  
  MSDate *lastDate = nil;
  for (HealingItemSim *hi in sim.healingItems) {
    UserMonsterHealingItem *item = nil;
    for (UserMonsterHealingItem *i in self.monsterHealingQueue) {
      if (!item || hi.userMonsterId == i.userMonsterId) {
        item = i;
      }
    }
    item.timeDistribution = hi.timeDistribution;
    item.totalSeconds = hi.totalSeconds;
    item.endTime = hi.endTime;
    
    if (!lastDate || [lastDate compare:hi.endTime] == NSOrderedAscending) {
      lastDate = hi.endTime;
    }
  }
  self.monsterHealingQueueEndTime = lastDate;
  
  [[SocketCommunication sharedSocketCommunication] setHealQueueDirtyWithCoinChange:0 gemCost:0];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:MONSTER_QUEUE_CHANGED_NOTIFICATION object:nil];
  [self beginHealingTimer];
}

- (void) addEnhancingItemToEndOfQueue:(EnhancementItem *)item {
  if (self.userEnhancement.feeders.count == 0) {
    item.expectedStartTime = [MSDate date];
  } else {
    EnhancementItem *prevItem = [self.userEnhancement.feeders lastObject];
    item.expectedStartTime = prevItem.expectedEndTime;
  }
  
  [self.userEnhancement.feeders addObject:item];
  
  [self beginEnhanceTimer];
  
  [QuestUtil checkAllDonateQuests];
}

- (void) removeEnhancingItem:(EnhancementItem *)item {
  NSMutableArray *feeders = self.userEnhancement.feeders;
  NSInteger index = [feeders indexOfObject:item];
  NSInteger total = feeders.count;
  
  if (index != NSNotFound) {
    if (total > index+1) {
      EnhancementItem *next = [feeders objectAtIndex:index+1];
      if (index == 0) {
        next.expectedStartTime = [MSDate date];
      } else {
        EnhancementItem *prev = [feeders objectAtIndex:index-1];
        next.expectedStartTime = prev.expectedEndTime;
      }
      
      for (NSInteger i = index+2; i < total; i++) {
        EnhancementItem *next2 = [feeders objectAtIndex:i];
        EnhancementItem *next1 = [feeders objectAtIndex:i-1];
        next2.expectedStartTime = next1.expectedEndTime;
        
      }
    }
  }
  [feeders removeObject:item];
  
  [self beginEnhanceTimer];
  
  [QuestUtil checkAllDonateQuests];
}

- (void) addEnhancementProto:(UserEnhancementProto *)proto {
  if (proto) {
    self.userEnhancement = [UserEnhancement enhancementWithUserEnhancementProto:proto];
    [[SocketCommunication sharedSocketCommunication] reloadEnhancementSnapshot];
    
    if (self.userEnhancement.feeders.count == 0) {
      [[OutgoingEventController sharedOutgoingEventController] removeBaseEnhanceMonster];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ENHANCE_WAIT_COMPLETE_NOTIFICATION object:nil];
    
    [self beginEnhanceTimer];
    
    [QuestUtil checkAllDonateQuests];
  }
}

- (void) addClanRaidUserInfo:(PersistentClanEventUserInfoProto *)info {
  PersistentClanEventUserInfoProto *toRemove = nil;
  for (PersistentClanEventUserInfoProto *p in self.curClanRaidUserInfos) {
    if (p.userId == info.userId) {
      toRemove = p;
      break;
    }
  }
  
  if (toRemove) {
    [self.curClanRaidUserInfos removeObject:toRemove];
  }
  
  [self.curClanRaidUserInfos addObject:info];
}

- (UserMonster *) myMonsterWithUserMonsterId:(uint64_t)userMonsterId {
  for (UserMonster *um in self.myMonsters) {
    if (userMonsterId == um.userMonsterId) {
      return um;
    }
  }
  return nil;
}

- (UserMonster *) myMonsterWithSlotNumber:(NSInteger)slotNum {
  for (UserMonster *um in self.myMonsters) {
    if (um.teamSlot == slotNum) {
      return um;
    }
  }
  return nil;
}

- (NSArray *) allMonstersOnMyTeam {
  NSMutableArray *m = [NSMutableArray array];
  for (UserMonster *um in self.myMonsters) {
    if (um.teamSlot != 0) {
      [m addObject:um];
    }
  }
  
  [m sortUsingComparator:^NSComparisonResult(UserMonster *obj1, UserMonster *obj2) {
    if (obj1.teamSlot > obj2.teamSlot) {
      return NSOrderedDescending;
    } else {
      return NSOrderedAscending;
    }
  }];
  
  return m;
}

- (NSArray *) allBattleAvailableMonstersOnTeam {
  NSArray *arr = [self allMonstersOnMyTeam];
  NSMutableArray *m = [NSMutableArray array];
  for (UserMonster *um in arr) {
    if (![um isHealing] && ![um isEnhancing] && ![um isSacrificing]) {
      [m addObject:um];
    }
  }
  [m sortUsingComparator:^NSComparisonResult(UserMonster *obj1, UserMonster *obj2) {
    return [@(obj1.teamSlot) compare:@(obj2.teamSlot)];
  }];
  return m;
}

- (UserStruct *) myStructWithId:(int)structId {
  for (UserStruct *us in self.myStructs) {
    if (us.userStructId == structId) {
      return us;
    }
  }
  return nil;
}

- (UserStruct *) myTownHall {
  for (UserStruct *us in self.myStructs) {
    if (us.staticStruct.structInfo.structType == StructureInfoProto_StructTypeTownHall) {
      return us;
    }
  }
  return nil;
}

- (UserStruct *) myLaboratory {
  for (UserStruct *us in self.myStructs) {
    if (us.staticStruct.structInfo.structType == StructureInfoProto_StructTypeLab) {
      return us;
    }
  }
  return nil;
}

- (NSArray *) allHospitals {
  NSMutableArray *allHospitals = [NSMutableArray array];
  for (UserStruct *us in self.myStructs) {
    if ([us.staticStruct structInfo].structType == StructureInfoProto_StructTypeHospital) {
      [allHospitals addObject:us];
    }
  }
  return allHospitals;
}

- (NSArray *) myValidHospitals {
  NSMutableArray *arr = [NSMutableArray array];
  for (UserStruct *us in self.myStructs) {
    if (us.staticStruct.structInfo.structType == StructureInfoProto_StructTypeHospital && us.isComplete) {
      [arr addObject:us];
    }
  }
  [arr sortUsingComparator:^NSComparisonResult(UserStruct *obj1, UserStruct *obj2) {
    HospitalProto *hosp1 = (HospitalProto *)obj1.staticStruct;
    HospitalProto *hosp2 = (HospitalProto *)obj2.staticStruct;
    return [@(hosp2.healthPerSecond) compare:@(hosp1.healthPerSecond)];
  }];
  return arr;
}

- (int) maxHospitalQueueSize {
  int queueSize = 0;
  for (UserStruct *us in self.myValidHospitals) {
    HospitalProto *hosp = (HospitalProto *)us.staticStruct;
    queueSize += hosp.queueSize;
  }
  return queueSize;
}

- (UserQuest *) myQuestWithId:(int)questId {
  for (UserQuest *uq in self.myQuests.allValues) {
    if (uq.questId == questId) {
      return uq;
    }
  }
  return nil;
}

- (NSArray *) allCurrentQuests {
  NSMutableArray *arr = [NSMutableArray arrayWithArray:self.availableQuests.allValues];
  [arr addObjectsFromArray:self.inProgressCompleteQuests.allValues];
  [arr addObjectsFromArray:self.inProgressIncompleteQuests.allValues];
  
  [arr sortUsingComparator:^NSComparisonResult(FullQuestProto *obj1, FullQuestProto *obj2) {
    int32_t p1 = obj1.priority == 0 ? INT32_MAX : obj1.priority;
    int32_t p2 = obj2.priority == 0 ? INT32_MAX : obj2.priority;
    if (p1 < p2) {
      return NSOrderedAscending;
    } else if (p1 > p2) {
      return NSOrderedDescending;
    } else {
      if (obj1.questId < obj2.questId) {
        return NSOrderedAscending;
      }
      return NSOrderedDescending;
    }
  }];
  return arr;
}

- (void) updateStaticData:(StaticDataProto *)proto {
  // Add these before updating user or else UI will update incorrectly
  [self addToStaticLevelInfos:proto.slipList];
  
  [self.staticCities removeAllObjects];
  [self addToStaticCities:proto.allCitiesList];
  [self.staticTasks removeAllObjects];
  [self addToStaticTasks:proto.allTasksList];
  
  [self.inProgressCompleteQuests removeAllObjects];
  [self addToInProgressCompleteQuests:proto.unredeemedQuestsList];
  [self.inProgressIncompleteQuests removeAllObjects];
  [self addToInProgressIncompleteQuests:proto.inProgressQuestsList];
  // Put this after inprogress complete because available quests will be autoaccepted
  [self.availableQuests removeAllObjects];
  [self addToAvailableQuests:proto.availableQuestsList];
  
  [self addStaticBoosterPacks:proto.boosterPacksList];
  
  [self.staticStructs removeAllObjects];
  [self addToStaticStructs:proto.allGeneratorsList];
  [self addToStaticStructs:proto.allTownHallsList];
  [self addToStaticStructs:proto.allStoragesList];
  [self addToStaticStructs:proto.allHospitalsList];
  [self addToStaticStructs:proto.allResidencesList];
  [self addToStaticStructs:proto.allLabsList];
  [self addToStaticItems:proto.itemsList];
  [self addToStaticObstacles:proto.obstaclesList];
  
  [self addToExpansionCosts:proto.expansionCostsList];
  
  [self.staticMonsters removeAllObjects];
  [self addToStaticMonsters:proto.allMonstersList];
  
  [self addBattleDialogueInfo:proto.mbdsList];
  
  [self.staticRaids removeAllObjects];
  [self addToStaticRaids:proto.raidsList];
  
  self.persistentEvents = proto.persistentEventsList;
  self.persistentClanEvents = proto.persistentClanEventsList;
  
  self.staticClanIcons = proto.clanIconsList;
  self.staticLeagues = proto.leaguesList;
}

- (void) addToStaticMonsters:(NSArray *)arr {
  for (MonsterProto *p in arr) {
    [self.staticMonsters setObject:p forKey:@(p.monsterId)];
  }
}

- (void) addToStaticStructs:(NSArray *)arr {
  for (id<StaticStructure> p in arr) {
    [self.staticStructs setObject:p forKey:@(p.structInfo.structId)];
  }
}

- (void) addToStaticTasks:(NSArray *)arr {
  for (FullTaskProto *p in arr) {
    [self.staticTasks setObject:p forKey:@(p.taskId)];
  }
}

- (void) addToStaticCities:(NSArray *)arr {
  for (FullCityProto *p in arr) {
    [self.staticCities setObject:p forKey:@(p.cityId)];
  }
}

- (void) addToStaticObstacles:(NSArray *)arr {
  for (ObstacleProto *p in arr) {
    [self.staticObstacles setObject:p forKey:@(p.obstacleId)];
  }
}

- (void) addToStaticRaids:(NSArray *)arr {
  for (ClanRaidProto *p in arr) {
    [self.staticRaids setObject:p forKey:@(p.clanRaidId)];
  }
}

- (void) addToStaticItems:(NSArray *)arr {
  for (ItemProto *p in arr) {
    [self.staticItems setObject:p forKey:@(p.itemId)];
  }
}

- (FullQuestProto *) questForId:(int)questId {
  NSNumber *num = @(questId);
  FullQuestProto *fqp = [_availableQuests objectForKey:num];
  fqp = fqp ? fqp : [_inProgressCompleteQuests objectForKey:num];
  fqp = fqp ? fqp : [_inProgressIncompleteQuests objectForKey:num];
  return fqp;
}

- (BOOL) isTaskUnlocked:(int)taskId {
  if (!taskId) return NO;
  FullTaskProto *task = [self taskWithId:taskId];
  if (!task) return NO;
  return !task.prerequisiteTaskId || [self.completedTasks containsObject:@(task.prerequisiteTaskId)];
}

- (BOOL) isCityUnlocked:(int)cityId {
  FullCityProto *city = [self cityWithId:cityId];
  for (NSNumber *taskId in city.taskIdsList) {
    if ([self isTaskUnlocked:taskId.intValue]) {
      return YES;
    }
  }
  return NO;
}

- (NSArray *) taskIdsToUnlockMoreTasks {
  NSMutableArray *taskIds = [NSMutableArray array];
  for (FullTaskProto *task in self.staticTasks.allValues) {
    if ([self isTaskUnlocked:task.taskId] && ![self.completedTasks containsObject:@(task.taskId)]) {
      [taskIds addObject:@(task.taskId)];
    }
  }
  return taskIds;
}

- (void) addUnrespondedUpdate:(id<GameStateUpdate>)up {
  if (_isTutorial) {
    return;
  }
  
  [_unrespondedUpdates addObject:up];
  
  if ([up respondsToSelector:@selector(update)]) {
    [up update];
  }
  
  TagLog(@"Added %@ for tag %d", NSStringFromClass([up class]), up.tag);
  
  if ([up isKindOfClass:[FullUserUpdate class]]) {
    [[NSNotificationCenter defaultCenter] postNotificationName:GAMESTATE_UPDATE_NOTIFICATION object:nil];
  }
}

- (void) addUnrespondedUpdates:(id<GameStateUpdate>)field1, ...
{
	va_list params;
	va_start(params,field1);
	
  for (id<GameStateUpdate> arg = field1; arg != nil; arg = va_arg(params, id<GameStateUpdate>))
  {
    [self addUnrespondedUpdate:arg];
  }
  va_end(params);
}

- (void) removeAndUndoAllUpdatesForTag:(int)tag {
  NSMutableArray *updates = [NSMutableArray array];
  for (id<GameStateUpdate> update in _unrespondedUpdates) {
    if (update.tag == tag) {
      if ([update respondsToSelector:@selector(undo)]) {
        [update undo];
      }
      [updates addObject:update];
    }
  }
  
  for (id<GameStateUpdate> update in updates) {
    [_unrespondedUpdates removeObject:update];
    TagLog(@"Removed and undid %@ for tag %d", NSStringFromClass([update class]), update.tag);
  }
}

- (void) removeFullUserUpdatesForTag:(int)tag {
  NSMutableArray *updates = [NSMutableArray array];
  for (id<GameStateUpdate> update in _unrespondedUpdates) {
    if (update.tag == tag && [update isKindOfClass:[FullUserUpdate class]]) {
      [updates addObject:update];
    }
  }
  
  for (id<GameStateUpdate> update in updates) {
    [_unrespondedUpdates removeObject:update];
    TagLog(@"Removed full user %@ for tag %d", NSStringFromClass([update class]), update.tag);
  }
}

- (void) removeNonFullUserUpdatesForTag:(int)tag {
  NSMutableArray *updates = [NSMutableArray array];
  for (id<GameStateUpdate> update in _unrespondedUpdates) {
    if (update.tag == tag && ![update isKindOfClass:[FullUserUpdate class]]) {
      [updates addObject:update];
    }
  }
  
  for (id<GameStateUpdate> update in updates) {
    [_unrespondedUpdates removeObject:update];
    TagLog(@"Removed non full user %@ for tag %d", NSStringFromClass([update class]), update.tag);
  }
}

- (int) maxCash {
  int maxCash = ((TownHallProto *)self.myTownHall.staticStruct).resourceCapacity;
  for (UserStruct *us in self.myStructs) {
    ResourceStorageProto *rgp = (ResourceStorageProto *)us.staticStruct;
    StructureInfoProto *fsp = [rgp structInfo];
    if (fsp.structType == StructureInfoProto_StructTypeResourceStorage && rgp.resourceType == ResourceTypeCash) {
      if (us.isComplete) {
        maxCash += rgp.capacity;
      } else {
        ResourceStorageProto *prev = (ResourceStorageProto *)us.staticStructForPrevLevel;
        maxCash += prev.capacity;
      }
    }
  }
  return maxCash;
}

- (int) maxOil {
  int maxOil = ((TownHallProto *)self.myTownHall.staticStruct).resourceCapacity;
  for (UserStruct *us in self.myStructs) {
    ResourceStorageProto *rgp = (ResourceStorageProto *)us.staticStruct;
    StructureInfoProto *fsp = [rgp structInfo];
    if (fsp.structType == StructureInfoProto_StructTypeResourceStorage && rgp.resourceType == ResourceTypeOil) {
      if (us.isComplete) {
        maxOil += rgp.capacity;
      } else {
        ResourceStorageProto *prev = (ResourceStorageProto *)us.staticStructForPrevLevel;
        maxOil += prev.capacity;
      }
    }
  }
  return maxOil;
}

- (int) maxInventorySlots {
  int slots = 0;
  for (UserStruct *us in self.myStructs) {
    ResidenceProto *rgp = (ResidenceProto *)us.staticStruct;
    StructureInfoProto *fsp = [rgp structInfo];
    if (fsp.structType == StructureInfoProto_StructTypeResidence) {
      if (us.isComplete) {
        slots += rgp.numMonsterSlots;
      } else {
        ResidenceProto *prev = (ResidenceProto *)us.staticStructForPrevLevel;
        slots += prev.numMonsterSlots;
      }
      slots += us.numBonusSlots;
    }
  }
  return slots;
}

- (int) expNeededForLevel:(int)level {
  StaticUserLevelInfoProto *slip = [self.staticLevelInfos objectForKey:[NSNumber numberWithInt:level]];
  if (slip) {
    return slip.requiredExperience;
  } else {
    return RAND_MAX;
  }
}

- (int) currentExpForLevel {
  int thisLevel = [self expNeededForLevel:self.level];
  int nextLevel = [self expNeededForLevel:self.level+1];
  return MAX(0, MIN(nextLevel-thisLevel, self.experience-thisLevel));
}

- (int) expDeltaNeededForNextLevel {
  int thisLevel = [self expNeededForLevel:self.level];
  int nextLevel = [self expNeededForLevel:self.level+1];
  return MAX(1, nextLevel-thisLevel);
}

- (UserExpansion *) getExpansionForX:(int)x y:(int)y {
  for (UserExpansion *e in self.userExpansions) {
    if (e.xPosition == x && e.yPosition == y) {
      return e;
    }
  }
  return nil;
}

- (int) numCompletedExpansions {
  int count = 0;
  for (UserExpansion *e in self.userExpansions) {
    if (!e.isExpanding) {
      count++;
    }
  }
  return count;
}

- (BOOL) isExpanding {
  for (UserExpansion *e in self.userExpansions) {
    if (e.isExpanding) {
      return YES;
    }
  }
  return NO;
}

- (UserExpansion *) currentExpansion {
  for (UserExpansion *e in self.userExpansions) {
    if (e.isExpanding) {
      return e;
    }
  }
  return nil;
}

- (PersistentClanEventUserInfoProto *) myClanRaidInfo {
  for (PersistentClanEventUserInfoProto *info in self.curClanRaidUserInfos) {
    if (info.userId == self.userId) {
      return info;
    }
  }
  return nil;
}

- (BOOL) hasActiveShield {
  return self.shieldEndTime.timeIntervalSinceNow > 0;
}

#pragma mark -
#pragma mark Expansion Timer

- (void) beginExpansionTimer {
  [self stopExpansionTimer];
  Globals *gl = [Globals sharedGlobals];
  
  for (UserExpansion *ue in self.userExpansions) {
    if (ue.isExpanding) {
      float seconds = [gl calculateNumMinutesForNewExpansion]*60;
      MSDate *endTime = [ue.lastExpandTime dateByAddingTimeInterval:seconds];
      
      _expansionTimer = [NSTimer timerWithTimeInterval:endTime.timeIntervalSinceNow target:self selector:@selector(expansionWaitTimeComplete:) userInfo:ue repeats:NO];
      if ([endTime compare:[MSDate date]] == NSOrderedDescending) {
        [[NSRunLoop mainRunLoop] addTimer:_expansionTimer forMode:NSRunLoopCommonModes];
      } else {
        [self expansionWaitTimeComplete:_expansionTimer];
        _expansionTimer = nil;
      }
    }
  }
}

- (void) expansionWaitTimeComplete:(NSTimer *)timer {
  UserExpansion *exp = [timer userInfo];
  [[OutgoingEventController sharedOutgoingEventController] expansionWaitComplete:NO atX:exp.xPosition atY:exp.yPosition];
}

- (void) stopExpansionTimer {
  if (_expansionTimer) {
    [_expansionTimer invalidate];
    _expansionTimer = nil;
  }
}

#pragma mark Healing Timer

- (void) beginHealingTimer {
  [self stopHealingTimer];
  
  BOOL healWait = NO;
  MSDate *earliest = nil;
  for (UserMonsterHealingItem *item in self.monsterHealingQueue) {
    MSDate *endTime = item.endTime;
    if (endTime && [endTime timeIntervalSinceNow] <= 0) {
      healWait = YES;
      break;
    } else {
      if (!earliest || [earliest compare:item.endTime] == NSOrderedDescending) {
        earliest = item.endTime;
      }
    }
  }
  
  if (healWait) {
    [self healingWaitTimeComplete];
  } else if (earliest) {
    _healingTimer = [NSTimer timerWithTimeInterval:earliest.timeIntervalSinceNow target:self selector:@selector(healingWaitTimeComplete) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_healingTimer forMode:NSRunLoopCommonModes];
  }
}

- (void) healingWaitTimeComplete {
  NSMutableArray *arr = [NSMutableArray array];
  for (UserMonsterHealingItem *item in self.monsterHealingQueue) {
    MSDate *endTime = item.endTime;
    if (endTime && [endTime timeIntervalSinceNow] <= 0) {
      [arr addObject:item];
    }
  }
  
  if (arr.count > 0) {
    [self saveHealthProgressesFromIndex:0];
    [[OutgoingEventController sharedOutgoingEventController] healQueueWaitTimeComplete:arr];
    [self readjustAllMonsterHealingProtos];
    [[NSNotificationCenter defaultCenter] postNotificationName:HEAL_WAIT_COMPLETE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:MONSTER_QUEUE_CHANGED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
    [self beginHealingTimer];
  }
}

- (void) stopHealingTimer {
  if (_healingTimer) {
    [_healingTimer invalidate];
    _healingTimer = nil;
  }
}

#pragma mark Enhance Timer

- (void) beginEnhanceTimer {
  [self stopEnhanceTimer];
  
  if (self.userEnhancement.feeders.count > 0) {
    EnhancementItem *item = [self.userEnhancement.feeders objectAtIndex:0];
    if ([item.expectedEndTime timeIntervalSinceNow] <= 0) {
      [self enhancingWaitTimeComplete];
    } else {
      _enhanceTimer = [NSTimer timerWithTimeInterval:item.expectedEndTime.timeIntervalSinceNow target:self selector:@selector(enhancingWaitTimeComplete) userInfo:nil repeats:NO];
      [[NSRunLoop mainRunLoop] addTimer:_enhanceTimer forMode:NSRunLoopCommonModes];
    }
  }
}

- (void) enhancingWaitTimeComplete {
  NSMutableArray *arr = [NSMutableArray array];
  for (EnhancementItem *item in self.userEnhancement.feeders) {
    if ([item.expectedEndTime timeIntervalSinceNow] <= 0) {
      [arr addObject:item];
    }
  }
  
  if (arr.count > 0) {
    [[OutgoingEventController sharedOutgoingEventController] enhanceQueueWaitTimeComplete:arr];
    [[NSNotificationCenter defaultCenter] postNotificationName:ENHANCE_WAIT_COMPLETE_NOTIFICATION object:nil];
    [self beginEnhanceTimer];
  }
}

- (void) stopEnhanceTimer {
  if (_enhanceTimer) {
    [_enhanceTimer invalidate];
    _enhanceTimer = nil;
  }
}

#pragma mark Evolution Timer

- (void) beginEvolutionTimer {
  [self stopEnhanceTimer];
  
  if (self.userEvolution) {
    if ([self.userEvolution.endTime timeIntervalSinceNow] <= 0) {
      [self evolutionWaitTimeComplete];
    } else {
      _evolutionTimer = [NSTimer timerWithTimeInterval:self.userEvolution.endTime.timeIntervalSinceNow target:self selector:@selector(evolutionWaitTimeComplete) userInfo:nil repeats:NO];
      [[NSRunLoop mainRunLoop] addTimer:_evolutionTimer forMode:NSRunLoopCommonModes];
    }
  }
}

- (void) evolutionWaitTimeComplete {
  if (self.userEvolution && [self.userEvolution.endTime timeIntervalSinceNow] < 0) {
    [[OutgoingEventController sharedOutgoingEventController] finishEvolutionWithGems:NO withDelegate:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:EVOLUTION_WAIT_COMPLETE_NOTIFICATION object:nil];
    [self beginEvolutionTimer];
  }
}

- (void) stopEvolutionTimer {
  if (_evolutionTimer) {
    [_evolutionTimer invalidate];
    _evolutionTimer = nil;
  }
}

#pragma mark Combine Timer

- (void) beginCombineTimer {
  [self stopCombineTimer];
  
  NSTimeInterval lowestTimeLeft = 0;
  for (UserMonster *um in self.myMonsters) {
    if ([um isCombining]) {
      if (um.timeLeftForCombining <= 0) {
        [self combiningWaitTimeComplete];
        return;
      } else {
        if (lowestTimeLeft == 0) {
          lowestTimeLeft = um.timeLeftForCombining;
        } else {
          lowestTimeLeft = MIN(um.timeLeftForCombining, lowestTimeLeft);
        }
      }
    }
  }
  _combineTimer = [NSTimer timerWithTimeInterval:lowestTimeLeft target:self selector:@selector(combiningWaitTimeComplete) userInfo:nil repeats:NO];
  [[NSRunLoop mainRunLoop] addTimer:_combineTimer forMode:NSRunLoopCommonModes];
}

- (void) combiningWaitTimeComplete {
  NSMutableArray *arr = [NSMutableArray array];
  for (UserMonster *um in self.myMonsters) {
    if ([um isCombining] && um.timeLeftForCombining <= 0) {
      [arr addObject:@(um.userMonsterId)];
    }
  }
  
  if (arr.count > 0) {
    [[OutgoingEventController sharedOutgoingEventController] combineMonsters:arr];
    [[NSNotificationCenter defaultCenter] postNotificationName:COMBINE_WAIT_COMPLETE_NOTIFICATION object:nil];
    [self beginCombineTimer];
    
    [QuestUtil checkAllDonateQuests];
  }
}

- (void) stopCombineTimer {
  if (_combineTimer) {
    [_combineTimer invalidate];
    _combineTimer = nil;
  }
}

- (void) addToRequestedClans:(NSArray *)arr {
  for (FullUserClanProto *uc in arr) {
    if (uc.status == UserClanStatusRequesting) {
      [self.requestedClans addObject:[NSNumber numberWithInt:uc.clanId]];
    } else {
      self.myClanStatus = uc.status;
    }
  }
}

- (void) addStaticBoosterPacks:(NSArray *)bpps {
  self.boosterPacks = bpps;
}

- (BoosterPackProto *) boosterPackForId:(int)packId {
  for (BoosterPackProto *bpp in self.boosterPacks) {
    if (bpp.boosterPackId == packId) {
      return bpp;
    }
  }
  return nil;
}

@end
