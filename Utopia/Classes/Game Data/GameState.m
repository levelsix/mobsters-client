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

#define TagLog(...) //LNLog(__VA_ARGS__)

#define PURGE_EQUIP_KEY @"Purge Equip Images"

@implementation GameState

SYNTHESIZE_SINGLETON_FOR_CLASS(GameState);

- (id) init {
  if ((self = [super init])) {
    _connected = NO;
    _staticTasks = [[NSMutableDictionary alloc] init];
    _staticCities = [[NSMutableDictionary alloc] init];
    _staticQuests = [[NSMutableDictionary alloc] init];
    _staticStructs = [[NSMutableDictionary alloc] init];
    _staticMonsters = [[NSMutableDictionary alloc] init];
    _staticDefeatTypeJobs = [[NSMutableDictionary alloc] init];
    _staticBuildStructJobs = [[NSMutableDictionary alloc] init];
    _staticUpgradeStructJobs = [[NSMutableDictionary alloc] init];
    _staticBosses = [[NSMutableDictionary alloc] init];
    _notifications = [[NSMutableArray alloc] init];
    _myStructs = [[NSMutableArray alloc] init];
    _myMonsters = [[NSMutableArray alloc] init];
    _myCities = [[NSMutableDictionary alloc] init];
    _globalChatMessages = [[NSMutableArray alloc] init];
    _clanChatMessages = [[NSMutableArray alloc] init];
    _rareBoosterPurchases = [[NSMutableArray alloc] init];
    
    _availableQuests = [[NSMutableDictionary alloc] init];
    _inProgressCompleteQuests = [[NSMutableDictionary alloc] init];
    _inProgressIncompleteQuests = [[NSMutableDictionary alloc] init];
    
    _privateChats = [[NSMutableArray alloc] init];
    
    _unrespondedUpdates = [[NSMutableArray alloc] init];
    
    _requestedClans = [[NSMutableArray alloc] init];
    
    _silver = 10000;
    _gold = 50;
    _level = 12;
    _experience = 30;
    _expRequiredForNextLevel = 40;
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
  self.gold = user.diamonds;
  self.silver = user.coins;
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
  
  self.lastLogoutTime = [NSDate dateWithTimeIntervalSince1970:user.lastLogoutTime/1000.0];
  
  for (id<GameStateUpdate> gsu in _unrespondedUpdates) {
    if ([gsu respondsToSelector:@selector(update)]) {
      [gsu update];
    }
  }
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
  [dict retain];
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
      } else if (dict == _staticQuests) {
        [sc sendRetrieveStaticDataMessageWithStructIds:nil taskIds:nil questIds:arr cityIds:nil buildStructJobIds:nil defeatTypeJobIds:nil possessEquipJobIds:nil upgradeStructJobIds:nil events:NO bossIds:nil];
        LNLog(@"Quests");
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
      } else if (dict == _staticBosses) {
        [sc sendRetrieveStaticDataMessageWithStructIds:nil taskIds:nil questIds:nil cityIds:nil buildStructJobIds:nil defeatTypeJobIds:nil possessEquipJobIds:nil upgradeStructJobIds:nil events:NO bossIds:arr];
        LNLog(@"Bosses");
      }
      LNLog(@"%@)", s);
    } else if (!ad.isActive || numTimes > 10000) {
      [dict release];
      return nil;
    }
    //    NSAssert(numTimes < 1000000, @"Waiting too long for static data.. Probably not retrieved!", itemId);
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    // Need this in case game state gets deallocated while waiting for static data
    p = [dict objectForKey:num];
  }
  // Retain and autorelease in case data gets purged
  [p retain];
  [dict release];
  return [p autorelease];
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

- (FullTaskProto *) bossWithId:(int)bossId {
  if (bossId == 0) {
    [Globals popupMessage:@"Attempted to access boss 0"];
    return nil;
  }
  return [self getStaticDataFrom:_staticBosses withId:bossId];
}

- (void) addToMyMonsters:(NSArray *)monsters {
  for (FullUserMonsterProto *mon in monsters) {
    [self.myMonsters addObject:[UserMonster userMonsterWithProto:mon]];
  }
}

- (void) addToMyStructs:(NSArray *)structs {
  for (FullUserStructureProto *st in structs) {
    [self.myStructs addObject:[UserStruct userStructWithProto:st]];
  }
  
  int x = -6, y = 5;
  for (UserStruct *us in self.myStructs) {
    if (us.coordinates.x == CENTER_TILE_X && us.coordinates.y == CENTER_TILE_Y) {
      [[OutgoingEventController sharedOutgoingEventController] moveNormStruct:us atX:CENTER_TILE_X+x atY:CENTER_TILE_Y+y];
      
      switch (x) {
        case -6:
          x = -3;
          break;
        case -3:
          x = 2;
          break;
        case 2:
          x = 5;
          break;
        case 5:
          x = -6;
          y -= 3;
          if (y == -1) y -= 2;
          
        default:
          break;
      }
    }
  }
}

- (void) addToAvailableQuests:(NSArray *)quests {
  if (quests.count > 0) {
    for (FullQuestProto *fqp in quests) {
      [self.availableQuests setObject:fqp forKey:[NSNumber numberWithInt:fqp.questId]];
      [[OutgoingEventController sharedOutgoingEventController] acceptQuest:fqp.questId];
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
  [cm release];
}

- (void) addChatMessage:(ChatMessage *)cm scope:(GroupChatScope) scope {
}

- (void) addBoosterPurchase:(RareBoosterPurchaseProto *)bp {
  [self.rareBoosterPurchases insertObject:bp atIndex:0];
}

- (UserMonster *) myMonsterWithUserMonsterId:(int)userMonsterId {
  for (UserMonster *um in self.myMonsters) {
    if (userMonsterId == um.userMonsterId) {
      return um;
    }
  }
  return nil;
}

- (UserStruct *) myStructWithId:(int)structId {
  for (UserStruct *us in self.myStructs) {
    if (us.structId == structId) {
      return us;
    }
  }
  return nil;
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

- (void) addToStaticBosses:(NSArray *)arr {
  for (FullBossProto *p in arr) {
    [self.staticBosses setObject:p forKey:[NSNumber numberWithInt:p.bossId]];
  }
}

- (void) addToStaticQuests:(NSArray *)arr {
  for (FullQuestProto *p in arr) {
    [self.staticQuests setObject:p forKey:[NSNumber numberWithInt:p.questId]];
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

- (FullQuestProto *) questForQuestId:(int)questId {
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
      
      _expansionTimer = [[NSTimer timerWithTimeInterval:endTime.timeIntervalSinceNow target:self selector:@selector(expansionWaitTimeComplete:) userInfo:ue repeats:NO] retain];
      if ([endTime compare:[NSDate date]] == NSOrderedDescending) {
        [[NSRunLoop mainRunLoop] addTimer:_expansionTimer forMode:NSRunLoopCommonModes];
      } else {
        [self expansionWaitTimeComplete:_expansionTimer];
        [_expansionTimer release];
        _expansionTimer = nil;
      }
    }
  }
}

- (void) expansionWaitTimeComplete:(NSTimer *)timer {
  UserExpansion *exp = [timer userInfo];
  [[OutgoingEventController sharedOutgoingEventController] expansionWaitComplete:NO atX:exp.xPosition atY:exp.yPosition];
  
  if ([HomeMap isInitialized]) {
    [[HomeMap sharedHomeMap] refresh];
  }
}

- (void) stopExpansionTimer {
  if (_expansionTimer) {
    [_expansionTimer invalidate];
    [_expansionTimer release];
    _expansionTimer = nil;
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
  [_staticQuests removeAllObjects];
  [_staticBuildStructJobs removeAllObjects];
  [_staticDefeatTypeJobs removeAllObjects];
  [_staticUpgradeStructJobs removeAllObjects];
  
  // Reretrieve necessary data
  [[OutgoingEventController sharedOutgoingEventController] retrieveAllStaticData];
}

- (void) reretrieveStaticData {
  [[SocketCommunication sharedSocketCommunication] sendRetrieveStaticDataMessageWithStructIds:_staticStructs.allKeys taskIds:_staticTasks.allKeys questIds:_staticQuests.allKeys cityIds:_staticCities.allKeys buildStructJobIds:_staticBuildStructJobs.allKeys defeatTypeJobIds:_staticDefeatTypeJobs.allKeys possessEquipJobIds:nil upgradeStructJobIds:_staticUpgradeStructJobs.allKeys events:YES bossIds:_staticBosses.allKeys];
  
  self.staticTasks = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticCities = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticQuests = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticStructs = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticDefeatTypeJobs = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticBuildStructJobs = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticUpgradeStructJobs = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticBosses = [[[NSMutableDictionary alloc] init] autorelease];
  self.boosterPacks = nil;
}

- (void) clearAllData {
  _connected = NO;
  self.staticTasks = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticCities = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticQuests = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticStructs = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticBosses = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticDefeatTypeJobs = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticBuildStructJobs = [[[NSMutableDictionary alloc] init] autorelease];
  self.staticUpgradeStructJobs = [[[NSMutableDictionary alloc] init] autorelease];
  self.notifications = [[[NSMutableArray alloc] init] autorelease];
  self.myStructs = [[[NSMutableArray alloc] init] autorelease];
  self.myCities = [[[NSMutableDictionary alloc] init] autorelease];
  self.clanChatMessages = [[[NSMutableArray alloc] init] autorelease];
  self.globalChatMessages = [[[NSMutableArray alloc] init] autorelease];
  self.rareBoosterPurchases = [[[NSMutableArray alloc] init] autorelease];
  
  self.availableQuests = [[[NSMutableDictionary alloc] init] autorelease];
  self.inProgressCompleteQuests = [[[NSMutableDictionary alloc] init] autorelease];
  self.inProgressIncompleteQuests = [[[NSMutableDictionary alloc] init] autorelease];
  
  self.carpenterStructs = nil;
  self.boosterPacks = nil;
  
  self.unrespondedUpdates = [[[NSMutableArray alloc] init] autorelease];
  
  self.requestedClans = [[[NSMutableArray alloc] init] autorelease];
  
  self.userExpansions = nil;
  
  self.clan = nil;
  self.userId = 0;
}

@end
