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
#import "ActivityFeedController.h"
#import "AppDelegate.h"
#import "HomeMap.h"
#import "ClanViewController.h"
#import "Downloader.h"
#import "GameLayer.h"
#import "SocketCommunication.h"

#define TagLog(...) //LNLog(__VA_ARGS__)

#define PURGE_EQUIP_KEY @"Purge Equip Images"

@implementation GameState

SYNTHESIZE_SINGLETON_FOR_CLASS(GameState);

- (id) init {
  if ((self = [super init])) {
    _connected = NO;
    _staticTasks = [[NSMutableDictionary alloc] init];
    _staticCities = [[NSMutableDictionary alloc] init];
    _staticStructs = [[NSMutableDictionary alloc] init];
    _staticMonsters = [[NSMutableDictionary alloc] init];
    _staticDefeatTypeJobs = [[NSMutableDictionary alloc] init];
    _staticBuildStructJobs = [[NSMutableDictionary alloc] init];
    _staticUpgradeStructJobs = [[NSMutableDictionary alloc] init];
    _notifications = [[NSMutableArray alloc] init];
    _myStructs = [[NSMutableArray alloc] init];
    _myMonsters = [[NSMutableArray alloc] init];
    _myQuests = [[NSMutableDictionary alloc] init];
    _globalChatMessages = [[NSMutableArray alloc] init];
    _clanChatMessages = [[NSMutableArray alloc] init];
    _rareBoosterPurchases = [[NSMutableArray alloc] init];
    _monsterHealingQueue = [[NSMutableArray alloc] init];
    _requestsFromFriends = [[NSMutableArray alloc] init];
    _usersUsedForExtraSlots = [[NSMutableArray alloc] init];
    
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
//  if (time == 0) {
//    // Special case: if time is 0, let it go through automatically
//    _lastUserUpdate = 0;
//  } else if (time <= _lastUserUpdate) {
//    LNLog(@"Did not update. This Update time = %lld, Last Update time = %lld.", time, _lastUserUpdate);
//    return;
//  } else {
//    _lastUserUpdate = time;
//    NSLog(@"Updated time to %lld.", time);
//  }
  
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
  self.experience = user.experience;
  self.tasksCompleted = user.tasksCompleted;
  self.battlesWon = user.battlesWon;
  self.battlesLost = user.battlesLost;
  self.flees = user.flees;
  self.referralCode = user.referralCode;
  self.numReferrals = user.numReferrals;
  self.isAdmin = user.isAdmin;
  self.hasReceivedfbReward = user.hasReceivedfbReward;
  self.numBeginnerSalesPurchased = user.numBeginnerSalesPurchased;
  self.hasActiveShield = user.hasActiveShield;
  self.createTime = [NSDate dateWithTimeIntervalSince1970:user.createTime/1000.0];
  self.numAdditionalMonsterSlots = user.numAdditionalMonsterSlots;
  self.facebookId = user.facebookId;
  
  self.lastLogoutTime = [NSDate dateWithTimeIntervalSince1970:user.lastLogoutTime/1000.0];
  
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
  fup.battlesWon = self.battlesWon;
  fup.battlesLost = self.battlesLost;
  fup.flees = self.flees;
  fup.referralCode = self.referralCode;
  fup.numReferrals = self.numReferrals;
  fup.isAdmin = self.isAdmin;
  fup.hasReceivedfbReward = self.hasReceivedfbReward;
  fup.numBeginnerSalesPurchased = self.numBeginnerSalesPurchased;
  fup.hasActiveShield = self.hasActiveShield;
  fup.createTime = self.createTime.timeIntervalSince1970*1000.;
  fup.numAdditionalMonsterSlots = self.numAdditionalMonsterSlots;
  fup.lastLogoutTime = self.lastLogoutTime.timeIntervalSince1970*1000.;
  fup.facebookId = self.facebookId;
  
  return [fup build];
}

- (MinimumUserProto *) minUser {
  MinimumUserProto_Builder *mup = [[[MinimumUserProto builder] setName:_name] setUserId:_userId];
  if (_clan != nil) {
    mup.clan = _clan;
  }
  return mup.build;
}

- (id) getStaticDataFrom:(NSDictionary *)dict withId:(int)itemId {
  AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  if (itemId == 0) {
    [Globals popupMessage:@"Attempted to access static item 0"];
    return nil;
  }
  NSNumber *num = [NSNumber numberWithInt:itemId];
  id p = [dict objectForKey:num];
  int numTimes = 1;
  while (!p) {
    numTimes++;
    if (numTimes == 50 || (numTimes %= 100) == 99) {
      LNLog(@"Lotsa wait time for this. Re-retrieving.");
      
      LNLog(@"Re-retrieving item: %d. Current things:", itemId);
      
      NSString *s = @"(";
      for (NSNumber *num in dict.allKeys) {
        s = [s stringByAppendingFormat:@"%d,", num.intValue];
      }
      
      // Lets try to retrieve the data by forcing a call
      SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
      NSArray *arr = [NSArray arrayWithObject:[NSNumber numberWithInt:itemId]];
      if (dict == _staticStructs) {
        [sc sendRetrieveStaticDataMessageWithStructIds:arr taskIds:nil questIds:nil cityIds:nil buildStructJobIds:nil defeatTypeJobIds:nil possessEquipJobIds:nil upgradeStructJobIds:nil events:NO bossIds:nil];
        LNLog(@"Structures");
      } else if (dict == _staticTasks) {
        [sc sendRetrieveStaticDataMessageWithStructIds:nil taskIds:arr questIds:nil cityIds:nil buildStructJobIds:nil defeatTypeJobIds:nil possessEquipJobIds:nil upgradeStructJobIds:nil events:NO bossIds:nil];
        LNLog(@"Tasks");
      } else if (dict == _staticCities) {
        [sc sendRetrieveStaticDataMessageWithStructIds:nil taskIds:nil questIds:nil cityIds:arr buildStructJobIds:nil defeatTypeJobIds:nil possessEquipJobIds:nil upgradeStructJobIds:nil events:NO bossIds:nil];
        LNLog(@"Cities");
      } else if (dict == _staticBuildStructJobs) {
        [sc sendRetrieveStaticDataMessageWithStructIds:nil taskIds:nil questIds:nil cityIds:nil buildStructJobIds:arr defeatTypeJobIds:nil possessEquipJobIds:nil upgradeStructJobIds:nil events:NO bossIds:nil];
        LNLog(@"Build Struct Jobs");
      } else if (dict == _staticDefeatTypeJobs) {
        [sc sendRetrieveStaticDataMessageWithStructIds:nil taskIds:nil questIds:nil cityIds:nil buildStructJobIds:nil defeatTypeJobIds:arr possessEquipJobIds:nil upgradeStructJobIds:nil events:NO bossIds:nil];
        LNLog(@"Defeat Type Jobs");
      } else if (dict == _staticUpgradeStructJobs) {
        [sc sendRetrieveStaticDataMessageWithStructIds:nil taskIds:nil questIds:nil cityIds:nil buildStructJobIds:nil defeatTypeJobIds:nil possessEquipJobIds:nil upgradeStructJobIds:arr events:NO bossIds:nil];
        LNLog(@"Upgrade Struct Jobs");
      }
      LNLog(@"%@)", s);
    } else if (!ad.isActive || numTimes > 10000) {
      return nil;
    }
    //    NSAssert(numTimes < 1000000, @"Waiting too long for static data.. Probably not retrieved!", itemId);
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    // Need this in case game state gets deallocated while waiting for static data
    p = [dict objectForKey:num];
  }
  return p;
}

- (FullStructureProto *) structWithId:(int)structId {
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
  return [self.staticCities objectForKey:[NSNumber numberWithInt:cityId]];//[self getStaticDataFrom:_staticCities withId:cityId];
}

- (FullTaskProto *) taskWithId:(int)taskId {
  if (taskId == 0) {
    [Globals popupMessage:@"Attempted to access task 0"];
    return nil;
  }
  return [self getStaticDataFrom:_staticTasks withId:taskId];
}

- (void) addToMyMonsters:(NSArray *)monsters {
  for (FullUserMonsterProto *mon in monsters) {
    UserMonster *um = [UserMonster userMonsterWithProto:mon];
    int index = [self.myMonsters indexOfObject:um];
    if (index != NSNotFound) {
      [self.myMonsters replaceObjectAtIndex:index withObject:um];
    } else {
      [self.myMonsters addObject:um];
    }
  }
  [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
}

- (void) addToMyStructs:(NSArray *)structs {
  for (FullUserStructureProto *st in structs) {
    [self.myStructs addObject:[UserStruct userStructWithProto:st]];
  }
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
  }
}

- (void) addToInProgressCompleteQuests:(NSArray *)quests {
  for (FullQuestProto *fqp in quests) {
    [self.inProgressCompleteQuests setObject:fqp forKey:[NSNumber numberWithInt:fqp.questId]];
  }
}

- (void) addToInProgressIncompleteQuests:(NSArray *)quests {
  for (FullQuestProto *fqp in quests) {
    [self.inProgressIncompleteQuests setObject:fqp forKey:[NSNumber numberWithInt:fqp.questId]];
  }
}

- (void) addToStaticLevelInfos:(NSArray *)lurep {
  self.staticLevelInfos = [NSMutableDictionary dictionary];
  for (StaticLevelInfoProto *exp in lurep) {
    NSNumber *level = [NSNumber numberWithInt:exp.level];
    [self.staticLevelInfos setObject:exp forKey:level];
  }
}

- (void) addInventorySlotsRequests:(NSArray *)users {
  for (MinimumUserProtoWithFacebookId *user in users) {
    RequestFromFriend *req = [RequestFromFriend requestForInventorySlotsWithUser:user];
    [self.requestsFromFriends addObject:req];
  }
}

- (void) addUsersUsedForExtraSlots:(NSArray *)users {
  for (MinimumUserProtoWithFacebookId *user in users) {
    [self.usersUsedForExtraSlots addObject:user.facebookId];
  }
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
  
  if ([ActivityFeedController isInitialized]) {
    [[[ActivityFeedController sharedActivityFeedController] activityTableView] reloadData];
  }
}

- (void) addChatMessage:(MinimumUserProto *)sender message:(NSString *)msg scope:(GroupChatScope)scope isAdmin:(BOOL)isAdmin {
  ChatMessage *cm = [[ChatMessage alloc] init];
  cm.sender = sender;
  cm.message = msg;
  cm.date = [NSDate date];
  cm.isAdmin = isAdmin;
  [self addChatMessage:cm scope:scope];
}

- (void) addChatMessage:(ChatMessage *)cm scope:(GroupChatScope) scope {
}

- (void) addBoosterPurchase:(RareBoosterPurchaseProto *)bp {
  [self.rareBoosterPurchases insertObject:bp atIndex:0];
}

- (void) addUserMonsterHealingItemToEndOfQueue:(UserMonsterHealingItem *)item {
  if (self.monsterHealingQueue.count == 0) {
    item.expectedStartTime = [NSDate date];
  } else {
    UserMonsterHealingItem *prevItem = [self.monsterHealingQueue lastObject];
    item.expectedStartTime = prevItem.expectedEndTime;
  }
  
  [self.monsterHealingQueue addObject:item];
  
  [self beginHealingTimer];
}

- (void) removeUserMonsterHealingItem:(UserMonsterHealingItem *)item {
  int index = [self.monsterHealingQueue indexOfObject:item];
  int total = self.monsterHealingQueue.count;
  
  if (index != NSNotFound) {
    if (total > index+1) {
      UserMonsterHealingItem *next = [self.monsterHealingQueue objectAtIndex:index+1];
      if (index == 0) {
        next.expectedStartTime = [NSDate date];
      } else {
        UserMonsterHealingItem *prev = [self.monsterHealingQueue objectAtIndex:index-1];
        next.expectedStartTime = prev.expectedEndTime;
      }
      
      for (int i = index+2; i < total; i++) {
        UserMonsterHealingItem *next2 = [self.monsterHealingQueue objectAtIndex:i];
        UserMonsterHealingItem *next1 = [self.monsterHealingQueue objectAtIndex:i-1];
        next2.expectedStartTime = next1.expectedEndTime;
        
      }
    }
  }
  [self.monsterHealingQueue removeObject:item];
  
  [self beginHealingTimer];
}

- (void) addAllMonsterHealingProtos:(NSArray *)items {
  [self.monsterHealingQueue removeAllObjects];
  
  for (UserMonsterHealingProto *proto in items) {
    [self.monsterHealingQueue addObject:[UserMonsterHealingItem userMonsterHealingItemWithProto:proto]];
  }
  
  [self.monsterHealingQueue sortUsingComparator:^NSComparisonResult(UserMonsterHealingItem *obj1, UserMonsterHealingItem *obj2) {
    return [obj1.expectedStartTime compare:obj2.expectedStartTime];
  }];
  
  [[SocketCommunication sharedSocketCommunication] reloadHealQueueSnapshot];
  
  [self beginHealingTimer];
}

- (void) addEnhancingItemToEndOfQueue:(EnhancementItem *)item {
  if (self.userEnhancement.feeders.count == 0) {
    item.expectedStartTime = [NSDate date];
  } else {
    EnhancementItem *prevItem = [self.userEnhancement.feeders lastObject];
    item.expectedStartTime = prevItem.expectedEndTime;
  }
  
  [self.userEnhancement.feeders addObject:item];
  
  [self beginEnhanceTimer];
}

- (void) removeEnhancingItem:(EnhancementItem *)item {
  NSMutableArray *feeders = self.userEnhancement.feeders;
  int index = [feeders indexOfObject:item];
  int total = feeders.count;
  
  if (index != NSNotFound) {
    if (total > index+1) {
      EnhancementItem *next = [feeders objectAtIndex:index+1];
      if (index == 0) {
        next.expectedStartTime = [NSDate date];
      } else {
        EnhancementItem *prev = [feeders objectAtIndex:index-1];
        next.expectedStartTime = prev.expectedEndTime;
      }
      
      for (int i = index+2; i < total; i++) {
        EnhancementItem *next2 = [feeders objectAtIndex:i];
        EnhancementItem *next1 = [feeders objectAtIndex:i-1];
        next2.expectedStartTime = next1.expectedEndTime;
        
      }
    }
  }
  [feeders removeObject:item];
  
  [self beginEnhanceTimer];
}

- (void) addEnhancementProto:(UserEnhancementProto *)proto {
  if (proto) {
    self.userEnhancement = [UserEnhancement enhancementWithUserEnhancementProto:proto];
    [[SocketCommunication sharedSocketCommunication] reloadEnhancementSnapshot];
    
    if (self.userEnhancement.feeders.count == 0) {
      [[OutgoingEventController sharedOutgoingEventController] removeBaseEnhanceMonster];
    }
    
    [self beginEnhanceTimer];
  }
}

- (UserMonster *) myMonsterWithUserMonsterId:(int)userMonsterId {
  for (UserMonster *um in self.myMonsters) {
    if (userMonsterId == um.userMonsterId) {
      return um;
    }
  }
  return nil;
}

- (UserMonster *) myMonsterWithSlotNumber:(int)slotNum {
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

- (UserStruct *) myStructWithId:(int)structId {
  for (UserStruct *us in self.myStructs) {
    if (us.structId == structId) {
      return us;
    }
  }
  return nil;
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

- (void) addToStaticMonsters:(NSArray *)arr {
  for (MonsterProto *p in arr) {
    [self.staticMonsters setObject:p forKey:[NSNumber numberWithInt:p.monsterId]];
  }
}

- (void) addToStaticStructs:(NSArray *)arr {
  for (FullStructureProto *p in arr) {
    [self.staticStructs setObject:p forKey:[NSNumber numberWithInt:p.structId]];
  }
}

- (void) addToStaticTasks:(NSArray *)arr {
  for (FullTaskProto *p in arr) {
    [self.staticTasks setObject:p forKey:[NSNumber numberWithInt:p.taskId]];
  }
}

- (void) addToStaticCities:(NSArray *)arr {
  for (FullCityProto *p in arr) {
    [self.staticCities setObject:p forKey:[NSNumber numberWithInt:p.cityId]];
  }
}

- (void) addToStaticBuildStructJobs:(NSArray *)arr {
  for (BuildStructJobProto *p in arr) {
    [self.staticBuildStructJobs setObject:p forKey:[NSNumber numberWithInt:p.buildStructJobId]];
  }
}

- (void) addToStaticUpgradeStructJobs:(NSArray *)arr {
  for (UpgradeStructJobProto *p in arr) {
    [self.staticUpgradeStructJobs setObject:p forKey:[NSNumber numberWithInt:p.upgradeStructJobId]];
  }
}

- (FullQuestProto *) questForId:(int)questId {
  NSNumber *num = [NSNumber numberWithInt:questId];
  FullQuestProto *fqp = [_availableQuests objectForKey:num];
  fqp = fqp ? fqp : [_inProgressCompleteQuests objectForKey:num];
  fqp = fqp ? fqp : [_inProgressIncompleteQuests objectForKey:num];
  return fqp;
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

- (int) maxCashForLevel:(int)level {
  StaticLevelInfoProto *slip = [self.staticLevelInfos objectForKey:[NSNumber numberWithInt:level]];
  return slip.maxCash;
}

- (int) expNeededForLevel:(int)level {
  StaticLevelInfoProto *slip = [self.staticLevelInfos objectForKey:[NSNumber numberWithInt:level]];
  return slip.requiredExperience;
}

- (int) currentExpForLevel {
  int thisLevel = [self expNeededForLevel:self.level];
  return self.experience-thisLevel;
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
      count ++;
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

- (void) beginExpansionTimer {
  [self stopExpansionTimer];
  Globals *gl = [Globals sharedGlobals];
  
  for (UserExpansion *ue in self.userExpansions) {
    if (ue.isExpanding) {
      float seconds = [gl calculateNumMinutesForNewExpansion]*60;
      NSDate *endTime = [ue.lastExpandTime dateByAddingTimeInterval:seconds];
      
      _expansionTimer = [NSTimer timerWithTimeInterval:endTime.timeIntervalSinceNow target:self selector:@selector(expansionWaitTimeComplete:) userInfo:ue repeats:NO];
      if ([endTime compare:[NSDate date]] == NSOrderedDescending) {
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

- (void) beginHealingTimer {
  [self stopHealingTimer];
  
  if (self.monsterHealingQueue.count > 0) {
    UserMonsterHealingItem *item = [self.monsterHealingQueue objectAtIndex:0];
    if ([item.expectedEndTime timeIntervalSinceNow] <= 0) {
      [self healingWaitTimeComplete];
    } else {
      _healingTimer = [NSTimer timerWithTimeInterval:item.expectedEndTime.timeIntervalSinceNow target:self selector:@selector(healingWaitTimeComplete) userInfo:nil repeats:NO];
      [[NSRunLoop mainRunLoop] addTimer:_healingTimer forMode:NSRunLoopCommonModes];
    }
  }
}

- (void) healingWaitTimeComplete {
  NSMutableArray *arr = [NSMutableArray array];
  for (UserMonsterHealingItem *item in self.monsterHealingQueue) {
    if ([item.expectedEndTime timeIntervalSinceNow] <= 0) {
      [arr addObject:item];
    }
  }
  
  if (arr.count > 0) {
    [[OutgoingEventController sharedOutgoingEventController] healQueueWaitTimeComplete:arr];
    [[NSNotificationCenter defaultCenter] postNotificationName:HEAL_WAIT_COMPLETE_NOTIFICATION object:nil];
    [self beginHealingTimer];
  }
}

- (void) stopHealingTimer {
  if (_healingTimer) {
    [_healingTimer invalidate];
    _healingTimer = nil;
  }
}

- (void) beginEnhanceTimer {
  [self stopEnhanceTimer];
  
  if (self.userEnhancement.feeders.count > 0) {
    EnhancementItem *item = [self.userEnhancement.feeders objectAtIndex:0];
    if ([item.expectedEndTime timeIntervalSinceNow] <= 0) {
      [self enhancingWaitTimeComplete];
    } else {
      _enhanceTimer = [NSTimer timerWithTimeInterval:item.expectedEndTime.timeIntervalSinceNow target:self selector:@selector(enhancingWaitTimeComplete) userInfo:nil repeats:NO];
      [[NSRunLoop mainRunLoop] addTimer:_enhanceTimer forMode:NSRunLoopCommonModes];
      
      NSLog(@"Began timer for %d secs", (int)item.expectedEndTime.timeIntervalSinceNow);
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
    NSLog(@"Firing wait time complete for %d items", arr.count);
    
    [[OutgoingEventController sharedOutgoingEventController] enhanceQueueWaitTimeComplete:arr];
    [[NSNotificationCenter defaultCenter] postNotificationName:ENHANCE_WAIT_COMPLETE_NOTIFICATION object:nil];
    [self beginEnhanceTimer];
  }
}

- (void) stopEnhanceTimer {
  if (_enhanceTimer) {
    NSLog(@"Stopping timer..");
    [_enhanceTimer invalidate];
    _enhanceTimer = nil;
  }
}

- (void) addToRequestedClans:(NSArray *)arr {
  for (FullUserClanProto *uc in arr) {
    if (uc.status == UserClanStatusRequesting) {
      [self.requestedClans addObject:[NSNumber numberWithInt:uc.clanId]];
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

- (BOOL) hasBeginnerShield {
  return [Globals userHasBeginnerShield:self.createTime.timeIntervalSince1970*1000 hasActiveShield:self.hasActiveShield];
}

- (void) purgeStaticData {
  [_staticBuildStructJobs removeAllObjects];
  [_staticDefeatTypeJobs removeAllObjects];
  [_staticUpgradeStructJobs removeAllObjects];
  
  // Reretrieve necessary data
  [[OutgoingEventController sharedOutgoingEventController] retrieveAllStaticData];
}

- (void) reretrieveStaticData {
  [[SocketCommunication sharedSocketCommunication] sendRetrieveStaticDataMessageWithStructIds:_staticStructs.allKeys taskIds:_staticTasks.allKeys questIds:nil cityIds:_staticCities.allKeys buildStructJobIds:_staticBuildStructJobs.allKeys defeatTypeJobIds:_staticDefeatTypeJobs.allKeys possessEquipJobIds:nil upgradeStructJobIds:_staticUpgradeStructJobs.allKeys events:YES bossIds:nil];
  
  self.staticTasks = [[NSMutableDictionary alloc] init];
  self.staticCities = [[NSMutableDictionary alloc] init];
  self.staticStructs = [[NSMutableDictionary alloc] init];
  self.staticDefeatTypeJobs = [[NSMutableDictionary alloc] init];
  self.staticBuildStructJobs = [[NSMutableDictionary alloc] init];
  self.staticUpgradeStructJobs = [[NSMutableDictionary alloc] init];
  self.boosterPacks = nil;
}

- (void) clearAllData {
  _connected = NO;
  self.staticTasks = [[NSMutableDictionary alloc] init];
  self.staticCities = [[NSMutableDictionary alloc] init];
  self.staticStructs = [[NSMutableDictionary alloc] init];
  self.staticDefeatTypeJobs = [[NSMutableDictionary alloc] init];
  self.staticBuildStructJobs = [[NSMutableDictionary alloc] init];
  self.staticUpgradeStructJobs = [[NSMutableDictionary alloc] init];
  self.notifications = [[NSMutableArray alloc] init];
  self.myStructs = [[NSMutableArray alloc] init];
  self.clanChatMessages = [[NSMutableArray alloc] init];
  self.globalChatMessages = [[NSMutableArray alloc] init];
  self.rareBoosterPurchases = [[NSMutableArray alloc] init];
  self.monsterHealingQueue = [[NSMutableArray alloc] init];
  self.requestsFromFriends = [[NSMutableArray alloc] init];
  
  self.availableQuests = [[NSMutableDictionary alloc] init];
  self.inProgressCompleteQuests = [[NSMutableDictionary alloc] init];
  self.inProgressIncompleteQuests = [[NSMutableDictionary alloc] init];
  
  self.carpenterStructs = nil;
  self.boosterPacks = nil;
  
  self.unrespondedUpdates = [[NSMutableArray alloc] init];

  self.requestedClans = [[NSMutableArray alloc] init];
  
  [self stopExpansionTimer];
  [self stopHealingTimer];
  
  self.userExpansions = nil;
  
  self.clan = nil;
  self.userId = 0;
}

@end
