//
//  OutgoingEventController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/29/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "OutgoingEventController.h"
#import "LNSynthesizeSingleton.h"
#import "GameState.h"
#import "SocketCommunication.h"
#import "Globals.h"
#import "MissionMap.h"
#import "HomeMap.h"
#import "GenericPopupController.h"
#import "SoundEngine.h"
#import "OtherUpdates.h"
#import "GameViewController.h"
#import "Downloader.h"
#import "PersistentEventProto+Time.h"
#import "FullQuestProto+JobAccess.h"
#import "FacebookDelegate.h"

#define CODE_PREFIX @"#~#"
#define PURGE_CODE @"purgecache"
#define CASH_CODE @"fastcash"
#define OIL_CODE @"oilspill"
#define CASH_AND_OIL_CODE @"greedisgood"
#define GEMS_CODE @"gemsgalore"
#define RESET_CODE @"cleanslate"
#define UNMUTE_CODE @"allears"
#define UNLOCK_BUILDINGS_CODE @"unlockdown"
#define SKIP_QUESTS_CODE @"quickquests"
#define FB_LOGOUT_CODE @"unfb"

#define  LVL6_SHARED_SECRET @"mister8conrad3chan9is1a2very4great5man"

@implementation OutgoingEventController

LN_SYNTHESIZE_SINGLETON_FOR_CLASS(OutgoingEventController);

- (uint64_t) getCurrentMilliseconds {
  return ((uint64_t)[[MSDate date] timeIntervalSince1970])*1000;
}

- (void) registerClanEventDelegate:(id)delegate {
  [[SocketCommunication sharedSocketCommunication] addClanEventObserver:delegate];
}

- (void) unregisterClanEventDelegate:(id)delegate {
  [[SocketCommunication sharedSocketCommunication] removeClanEventObserver:delegate];
}

- (void) createUserWithName:(NSString *)name facebookId:(NSString *)facebookId email:(NSString *)email otherFbInfo:(NSDictionary *)otherFbInfo structs:(NSArray *)structs cash:(int)cash oil:(int)oil gems:(int)gems delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  NSString *jsonString = nil;
  if (otherFbInfo) {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:otherFbInfo
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
      NSLog(@"Got an error: %@", error);
    } else {
      jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
  }
  
  int tag = [sc sendUserCreateMessageWithName:name facebookId:facebookId email:email otherFbInfo:jsonString structs:structs cash:cash oil:oil gems:gems];
  [sc setDelegate:delegate forTag:tag];
  
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
  
  [Analytics userCreateWithCashChange:cash cashBalance:cash oilChange:oil oilBalance:oil gemChange:gems gemBalance:gems];
}

- (void) startupWithFacebookId:(NSString *)facebookId isFreshRestart:(BOOL)isFreshRestart delegate:(id)delegate {
  int tag = [[SocketCommunication sharedSocketCommunication] sendStartupMessageWithFacebookId:facebookId isFreshRestart:isFreshRestart clientTime:[self getCurrentMilliseconds]];
  [[GameState sharedGameState] addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
}

- (void) logout {
  GameState *gs = [GameState sharedGameState];
  if (gs.connected && gs.userId > 0) {
    [[SocketCommunication sharedSocketCommunication] sendLogoutMessage];
  }
}

#pragma mark - Home map

- (UserStruct *) purchaseNormStruct:(int)structId atX:(int)x atY:(int)y allowGems:(BOOL)allowGems {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  StructureInfoProto *fsp = [[gs structWithId:structId] structInfo];
  UserStruct *us = nil;
  
  int cur = [gl calculateCurrentQuantityOfStructId:structId structs:gs.myStructs];
  int max = [gl calculateMaxQuantityOfStructId:structId withTownHall:(TownHallProto *)gs.myTownHall.staticStruct];
  if (cur >= max) {
    [Globals popupMessage:@"You are already at the max of this struct"];
    return us;
  }
  
  int thLevel = [[[[gs myTownHall] staticStruct] structInfo] level];
  if (fsp.prerequisiteTownHallLvl > thLevel) {
    [Globals popupMessage:@"Town hall not high enough for this building"];
    return us;
  }
  
  // Check that no other building is being built
  for (UserStruct *u in gs.myStructs) {
    if (!u.isComplete) {
      [Globals popupMessage:@"You can only construct one building at a time!"];
      return us;
    }
  }
  for (UserObstacle *u in gs.myObstacles) {
    if (u.endTime) {
      [Globals popupMessage:@"You are removing an obstacle at the moment!"];
      return us;
    }
  }
  
  int cost = fsp.buildCost;
  BOOL isOilBuilding = fsp.buildResourceType == ResourceTypeOil;
  int curAmount = isOilBuilding ? gs.oil : gs.cash;
  int gemCost = 0;
  
  if (allowGems && cost > curAmount) {
    gemCost = [gl calculateGemConversionForResourceType:fsp.buildResourceType amount:cost-curAmount];
    cost = curAmount;
  }
  
  if (cost > curAmount || gemCost > gs.gems) {
    [Globals popupMessage:@"Trying to build without enough resources."];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendPurchaseNormStructureMessage:structId x:x y:y time:[self getCurrentMilliseconds] resourceType:fsp.buildResourceType resourceChange:-cost gemCost:gemCost];
    
    [gs saveHealthProgressesFromIndex:0];
    
    us = [[UserStruct alloc] init];
    // UserStructId will come in the response
    us.userId = [[GameState sharedGameState] userId];
    us.structId = structId;
    us.isComplete = NO;
    us.coordinates = CGPointMake(x, y);
    us.orientation = 0;
    us.purchaseTime = [MSDate date];
    us.lastRetrieved = nil;
    
    AddStructUpdate *asu = [AddStructUpdate updateWithTag:tag userStruct:us];
    FullUserUpdate *su = [(isOilBuilding ? [OilUpdate class] : [SilverUpdate class]) updateWithTag:tag change:-cost];
    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:-gemCost];
    [gs addUnrespondedUpdates:asu, su, gu, nil];
    
    [gs readjustAllMonsterHealingProtos];
    
    int cashChange = isOilBuilding ? 0 : -cost;
    int oilChange = isOilBuilding ? -cost : 0;
    [Analytics buyBuilding:fsp.structId cashChange:cashChange cashBalance:gs.cash oilChange:oilChange oilBalance:gs.oil gemChange:-gemCost gemBalance:gs.gems];
  }
  return us;
}

- (void) upgradeNormStruct:(UserStruct *)userStruct allowGems:(BOOL)allowGems {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  StructureInfoProto *nextFsp = userStruct.staticStructForNextLevel.structInfo;
  
  int thLevel = [[[[gs myTownHall] staticStruct] structInfo] level];
  if (nextFsp.prerequisiteTownHallLvl > thLevel) {
    [Globals popupMessage:@"Town hall not high enough for this building"];
    return;
  }
  
  // Check that no other building is being upgraded
  for (UserStruct *us in gs.myStructs) {
    if (!us.isComplete) {
      [Globals popupMessage:@"You can only construct one building at a time!"];
      return;
    }
  }
  
  if (userStruct.userStructId == 0) {
    [Globals popupMessage:@"Hold on, we are still processing your building purchase."];
  } else if (userStruct.userId != gs.userId) {
    [Globals popupMessage:@"This is not your building!"];
  } else if (!nextFsp) {
    [Globals popupMessage:@"This building is not upgradable"];
  } else {
    int cost = nextFsp.buildCost;
    BOOL isOilBuilding = nextFsp.buildResourceType == ResourceTypeOil;
    int curAmount = isOilBuilding ? gs.oil : gs.cash;
    int gemCost = 0;
    
    if (allowGems && cost > curAmount) {
      gemCost = [gl calculateGemConversionForResourceType:nextFsp.buildResourceType amount:cost-curAmount];
      cost = curAmount;
    }
    
    if (cost > curAmount || gemCost > gs.gems) {
      [Globals popupMessage:@"Trying to upgrade without enough resources."];
    } else {
      int64_t ms = [self getCurrentMilliseconds];
      int tag = [sc sendUpgradeNormStructureMessage:userStruct.userStructId time:ms resourceType:nextFsp.buildResourceType resourceChange:-cost gemCost:gemCost];
      
      [gs saveHealthProgressesFromIndex:0];
      
      userStruct.isComplete = NO;
      userStruct.purchaseTime = [MSDate dateWithTimeIntervalSince1970:ms/1000.0];
      userStruct.structId = nextFsp.structId;
      
      // Update game state
      FullUserUpdate *su = [(isOilBuilding ? [OilUpdate class] : [SilverUpdate class]) updateWithTag:tag change:-cost];
      GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:-gemCost];
      [gs addUnrespondedUpdates:su, gu, nil];
      
      [gs readjustAllMonsterHealingProtos];
      
      int cashChange = isOilBuilding ? 0 : -cost;
      int oilChange = isOilBuilding ? -cost : 0;
      [Analytics upgradeBuilding:nextFsp.structId cashChange:cashChange cashBalance:gs.cash oilChange:oilChange oilBalance:gs.oil gemChange:-gemCost gemBalance:gs.gems];
    }
  }
}

- (void) moveNormStruct:(UserStruct *)userStruct atX:(int)x atY:(int)y {
  CGPoint newCoord = CGPointMake(x, y);
  if (!CGPointEqualToPoint(userStruct.coordinates, newCoord)) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendMoveNormStructureMessage:userStruct.userStructId x:x y:y];
    userStruct.coordinates = CGPointMake(x, y);
    
    [[GameState sharedGameState] addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
  }
}

- (int) retrieveFromNormStructure:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  ResourceGeneratorProto *gen = (ResourceGeneratorProto *)userStruct.staticStruct;
  StructureInfoProto *fsp = gen.structInfo;
  int amountCollected = 0;
  
  if (userStruct.userStructId == 0) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (fsp.structType != StructureInfoProto_StructTypeResourceGenerator) {
    [Globals popupMessage:@"This building is not a resource generator"];
  } else if (userStruct.userId != gs.userId) {
    [Globals popupMessage:@"This is not your building!"];
  } else if (userStruct.isComplete && userStruct.lastRetrieved) {
    int64_t ms = [self getCurrentMilliseconds];
    int numRes = userStruct.numResourcesAvailable;
    int maxCollect = gen.resourceType == ResourceTypeCash ? gs.maxCash-gs.cash : gs.maxOil-gs.oil;
    amountCollected = MIN(numRes, maxCollect);
    
    if (amountCollected > 0) {
      ms -= (int)((numRes-amountCollected)/gen.productionRate*3600*1000);
      
      int tag = [sc retrieveCurrencyFromStruct:userStruct.userStructId time:ms amountCollected:amountCollected];
      userStruct.lastRetrieved = [MSDate dateWithTimeIntervalSince1970:ms/1000.0];
      
      // Update game state
      FullUserUpdate *up = nil;
      int oilChange = 0, cashChange = 0;
      if (gen.resourceType == ResourceTypeCash) {
        up = [SilverUpdate updateWithTag:tag change:amountCollected];
        cashChange = amountCollected;
      } else if (gen.resourceType == ResourceTypeOil) {
        up = [OilUpdate updateWithTag:tag change:amountCollected];
        oilChange = amountCollected;
      }
      [gs addUnrespondedUpdate:up];
      
      [Analytics retrieveCurrency:fsp.structId cashChange:cashChange cashBalance:gs.cash oilChange:oilChange oilBalance:gs.oil];
    }
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Building %d is not ready to be retrieved", userStruct.userStructId]];
  }
  return amountCollected;
}

- (void) instaUpgrade:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  Globals *gl = [Globals sharedGlobals];
  
  int timeLeft = userStruct.timeLeftForBuildComplete;
  
  int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
  if (userStruct.userStructId == 0) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (userStruct.userId != gs.userId) {
    [Globals popupMessage:@"This is not your building!"];
  } else if (gs.gems < gemCost) {
    [Globals popupMessage:@"Not enough diamonds to speed up upgrade"];
  } else if (!userStruct.isComplete) {
    int64_t ms = [self getCurrentMilliseconds];
    int tag = [sc sendFinishNormStructBuildWithDiamondsMessage:userStruct.userStructId gemCost:gemCost time:[self getCurrentMilliseconds]];
    
    [gs saveHealthProgressesFromIndex:0];
    
    userStruct.isComplete = YES;
    userStruct.lastRetrieved = [MSDate dateWithTimeIntervalSince1970:ms/1000.0];
    
    // Update game state
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-gemCost]];
    
    [gs readjustAllMonsterHealingProtos];
    
    if (userStruct.staticStruct.structInfo.structType == StructureInfoProto_StructTypeMiniJob) {
      gs.lastMiniJobSpawnTime = nil;
      [gs beginMiniJobTimer];
    }
    
    [Analytics instantFinish:@"buildingWait" gemChange:-gemCost gemBalance:gs.gems];
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Building %d is not upgrading", userStruct.userStructId]];
  }
}

- (void) normStructWaitComplete:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (userStruct.userStructId == 0) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (userStruct.userId != gs.userId) {
    [Globals popupMessage:@"This is not your building!"];
  } else if (!userStruct.isComplete) {
    MSDate *date = userStruct.buildCompleteDate;
    
    if ([date compare:[MSDate date]] == NSOrderedDescending) {
      [Globals popupMessage:@"Something went wrong, building should still be waiting"];
      return;
    }
    userStruct.lastRetrieved = date;
    userStruct.isComplete = YES;
    
    int64_t ms = [self getCurrentMilliseconds];
    int tag = [sc sendNormStructBuildsCompleteMessage:[NSArray arrayWithObject:[NSNumber numberWithInt:userStruct.userStructId]] time:ms];
    
    [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
    
    if (userStruct.staticStruct.structInfo.structType == StructureInfoProto_StructTypeMiniJob) {
      gs.lastMiniJobSpawnTime = nil;
      [gs beginMiniJobTimer];
    }
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Building %d is not upgrading or constructing", userStruct.userStructId]];
  }
}

- (void) spawnObstacles:(NSArray *)obstacles delegate:(id)delegate {
  if (obstacles.count) {
    GameState *gs = [GameState sharedGameState];
    
    NSMutableArray *mins = [NSMutableArray array];
    for (UserObstacle *ob in obstacles) {
      MinimumObstacleProto_Builder *min = [MinimumObstacleProto builder];
      min.obstacleId = ob.obstacleId;
      min.coordinate = [[[[CoordinateProto builder] setX:ob.coordinates.x] setY:ob.coordinates.y] build];
      min.orientation = ob.orientation;
      [mins addObject:min.build];
    }
    [gs.myObstacles addObjectsFromArray:obstacles];
    
    int64_t ms = [self getCurrentMilliseconds];
    int tag = [[SocketCommunication sharedSocketCommunication] sendSpawnObstacleMessage:mins clientTime:ms];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
    gs.lastObstacleCreateTime = [MSDate dateWithTimeIntervalSince1970:ms/1000.];
  }
}

- (void) beginObstacleRemoval:(UserObstacle *)obstacle spendGems:(BOOL)spendGems {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  ObstacleProto *op = obstacle.staticObstacle;
  
  for (UserStruct *u in gs.myStructs) {
    if (!u.isComplete) {
      [Globals popupMessage:@"You can only construct one building at a time!"];
      return;
    }
  }
  for (UserObstacle *u in gs.myObstacles) {
    if (u.endTime) {
      [Globals popupMessage:@"You are removing an obstacle at the moment!"];
      return;
    }
  }
  
  if (!obstacle.userObstacleId) {
    [Globals popupMessage:@"Attempting to remove obstacle without id."];
  } else {
    int cost = op.cost;
    BOOL isOilBuilding = op.removalCostType == ResourceTypeOil;
    int curAmount = isOilBuilding ? gs.oil : gs.cash;
    int gemCost = 0;
    
    if (spendGems && cost > curAmount) {
      gemCost = [gl calculateGemConversionForResourceType:op.removalCostType amount:cost-curAmount];
      cost = curAmount;
    }
    
    if (cost > curAmount || gemCost > gs.gems) {
      [Globals popupMessage:@"Trying to build without enough resources."];
    } else {
      uint64_t ms = [self getCurrentMilliseconds];
      int tag = [[SocketCommunication sharedSocketCommunication] sendBeginObstacleRemovalMessage:obstacle.userObstacleId resType:op.removalCostType resChange:-cost gemsSpent:gemCost clientTime:ms];
      
      obstacle.removalTime = [MSDate dateWithTimeIntervalSince1970:ms/1000.];
      
      // Update game state
      FullUserUpdate *su = [(isOilBuilding ? [OilUpdate class] : [SilverUpdate class]) updateWithTag:tag change:-cost];
      GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:-gemCost];
      [gs addUnrespondedUpdates:su, gu, nil];
      
      int cashChange = isOilBuilding ? 0 : -cost;
      int oilChange = isOilBuilding ? -cost : 0;
      [Analytics removeObstacle:op.obstacleId cashChange:cashChange cashBalance:gs.cash oilChange:oilChange oilBalance:gs.oil gemChange:-gemCost gemBalance:gs.gems];
    }
  }
}

- (BOOL) obstacleRemovalComplete:(UserObstacle *)obstacle speedup:(BOOL)speedup {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int timeLeft = obstacle.endTime.timeIntervalSinceNow;
  if (!obstacle.userObstacleId) {
    [Globals popupMessage:@"Attempting to complete obstacle removal without id."];
  } else if (timeLeft > 0 && !speedup) {
    [Globals popupMessage:@"Attempting to complete obstacle before time."];
  } else {
    int numGems = 0;
    if (speedup) {
      numGems = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
    }
    
    if (gs.gems < numGems) {
      [Globals popupMessage:@"Attempting to speedup without enough gems."];
    } else {
      int64_t ms = [self getCurrentMilliseconds];
      
      BOOL shouldResetTime = gs.myObstacles.count >= gl.maxObstacles;
      
      int tag = [[SocketCommunication sharedSocketCommunication] sendObstacleRemovalCompleteMessage:obstacle.userObstacleId speedup:numGems > 0 gemsSpent:numGems maxObstacles:shouldResetTime clientTime:ms];
      [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-numGems]];
      
      obstacle.removalTime = nil;
      [gs.myObstacles removeObject:obstacle];
      
      if (shouldResetTime) {
        gs.lastObstacleCreateTime = [MSDate dateWithTimeIntervalSince1970:ms/1000.];
      }
      
      if (numGems) {
        [Analytics instantFinish:@"obstacleWait" gemChange:-numGems gemBalance:gs.gems];
      }
      
      return YES;
    }
  }
  return NO;
}

#pragma mark - Loading Cities

- (void) loadPlayerCity:(int)userId withDelegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  
  int tag = [[SocketCommunication sharedSocketCommunication] sendLoadPlayerCityMessage:userId];
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
}

- (void) loadNeutralCity:(int)cityId withDelegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  FullCityProto *city = [gs cityWithId:cityId];
  
  int tag = [[SocketCommunication sharedSocketCommunication] sendLoadCityMessage:city.cityId];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
}

#pragma mark - Quests

- (UserQuest *) acceptQuest:(int)questId {
  GameState *gs = [GameState sharedGameState];
  NSNumber *questIdNum = [NSNumber numberWithInt:questId];
  FullQuestProto *fqp = [gs.availableQuests objectForKey:questIdNum];
  
  if (fqp) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendQuestAcceptMessage:questId];
    [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
    
    [gs.availableQuests removeObjectForKey:questIdNum];
    [gs.inProgressIncompleteQuests setObject:fqp forKey:questIdNum];
    
    UserQuest *uq = [[UserQuest alloc] init];
    uq.userId = gs.userId;
    uq.questId = questId;
    [gs.myQuests setObject:uq forKey:@(questId)];
    
    return uq;
  } else {
    [Globals popupMessage:@"Attempting to accept unavailable quest"];
  }
  return nil;
}

- (void) questProgress:(int)questId jobIds:(NSArray *)jobIds {
  GameState *gs = [GameState sharedGameState];
  UserQuest *uq = [gs myQuestWithId:questId];
  
  if (uq) {
    NSMutableArray *arr = [NSMutableArray array];
    for (NSNumber *num in jobIds) {
      UserQuestJob *uqj = [uq jobForId:num.intValue];
      UserQuestJobProto *proto = [uqj convertToProto];
      [arr addObject:proto];
    }
    [[SocketCommunication sharedSocketCommunication] sendQuestProgressMessage:questId isComplete:uq.isComplete userQuestJobs:arr userMonsterIds:nil];
    
    if (uq.isComplete) {
      NSNumber *questIdNum = [NSNumber numberWithInt:questId];
      FullQuestProto *fqp = [gs.inProgressIncompleteQuests objectForKey:questIdNum];
      if (fqp) {
        [gs.inProgressIncompleteQuests removeObjectForKey:questIdNum];
        [gs.inProgressCompleteQuests setObject:fqp forKey:questIdNum];
      }
    }
  } else {
    [Globals popupMessage:@"Attempting to progress nonexistent quest"];
  }
}

- (UserQuest *) donateForQuest:(int)questId jobId:(int)jobId monsterIds:(NSArray *)monsterIds {
  GameState *gs = [GameState sharedGameState];
  UserQuest *uq = [gs myQuestWithId:questId];
  FullQuestProto *fqp = [gs questForId:uq.questId];
  QuestJobProto *jp = [fqp jobForId:jobId];
  
  if (monsterIds.count < jp.quantity) {
    [Globals popupMessage:@"Attempting to donate without enough of monster."];
  } else if (uq) {
    NSMutableArray *toRemove = [NSMutableArray array];
    for (NSNumber *num in monsterIds) {
      UserMonster *um = [gs myMonsterWithUserMonsterId:num.intValue];
      if (um && um.isComplete) {
        [toRemove addObject:um];
      } else {
        [Globals popupMessage:@"One of the monsters can not be found."];
        return nil;
      }
    }
    [gs.myMonsters removeObjectsInArray:toRemove];
    
    [uq setIsCompleteForQuestJobId:jobId];
    
    BOOL isQuestComplete = YES;
    for (QuestJobProto *qj in fqp.jobsList) {
      UserQuestJob *uqj = [uq jobForId:qj.questJobId];
      if (!uqj.isComplete) {
        isQuestComplete = NO;
      }
    }
    uq.isComplete = isQuestComplete;
    
    NSNumber *questIdNum = [NSNumber numberWithInt:questId];
    FullQuestProto *fqp = [gs.inProgressIncompleteQuests objectForKey:questIdNum];
    if (fqp) {
      [gs.inProgressIncompleteQuests removeObjectForKey:questIdNum];
      [gs.inProgressCompleteQuests setObject:fqp forKey:questIdNum];
    }
    
    UserQuestJob *uqj = [uq jobForId:jobId];
    [[SocketCommunication sharedSocketCommunication] sendQuestProgressMessage:questId isComplete:uq.isComplete userQuestJobs:@[[uqj convertToProto]] userMonsterIds:monsterIds];
    
    int numLeft = 0;
    for (UserMonster *um in gs.myMonsters) {
      if (um.monsterId == jp.staticDataId) {
        numLeft++;
      }
    }
    
    [Analytics donateMonsters:jp.staticDataId amountDonated:(int)toRemove.count numLeft:numLeft questJobId:jp.questJobId];
    return uq;
  } else {
    [Globals popupMessage:@"Attempting to donate for quest"];
  }
  
  return nil;
}

- (void) redeemQuest:(int)questId delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  NSNumber *questIdNum = [NSNumber numberWithInt:questId];
  FullQuestProto *fqp = [gs.inProgressCompleteQuests objectForKey:questIdNum];
  
  if (fqp) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendQuestRedeemMessage:questId];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
    
    [gs.inProgressCompleteQuests removeObjectForKey:questIdNum];
    SilverUpdate *su = [SilverUpdate updateWithTag:tag change:fqp.cashReward];
    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:fqp.gemReward];
    OilUpdate *ou = [OilUpdate updateWithTag:tag change:fqp.oilReward];
    ExperienceUpdate *eu = [ExperienceUpdate updateWithTag:tag change:fqp.expReward];
    
    [gs addUnrespondedUpdates:su, ou, gu, eu, nil];
    
    [Analytics redeemQuest:questId cashChange:fqp.cashReward cashBalance:gs.cash oilChange:fqp.oilReward oilBalance:gs.oil gemChange:fqp.gemReward gemBalance:gs.gems];
  } else {
    [Globals popupMessage:@"Attempting to redeem quest that is not in progress"];
  }
}

#pragma mark - Achievements

- (void) achievementProgress:(NSArray *)userAchievements {
  NSMutableArray *arr = [NSMutableArray array];
  for (UserAchievement *ua in userAchievements) {
    [arr addObject:[ua convertToProto]];
  }
  [[SocketCommunication sharedSocketCommunication] sendAchievementProgressMessage:arr clientTime:[self getCurrentMilliseconds]];
}

- (void) redeemAchievement:(int)achievementId delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  AchievementProto *ap = [gs achievementWithId:achievementId];
  UserAchievement *ua = [gs.myAchievements objectForKey:@(achievementId)];
  
  if (!ua.isComplete) {
    [Globals popupMessage:@"Attempting to redeem achievement that is not complete."];
  } else if (ua.isRedeemed) {
    [Globals popupMessage:@"Attempting to redeem achievement that has already been redeemed."];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendAchievementRedeemMessage:achievementId clientTime:[self getCurrentMilliseconds]];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
    
    ua.isRedeemed = YES;
    
    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:ap.gemReward];
    [gs addUnrespondedUpdate:gu];
    
    [Analytics redeemAchievement:achievementId gemChange:ap.gemReward gemBalance:gs.gems];
  }
}

#pragma mark - Retrieving users

- (void) retrieveUsersForUserIds:(NSArray *)userIds includeCurMonsterTeam:(BOOL)includeCurMonsterTeam delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  int tag = [[SocketCommunication sharedSocketCommunication] sendRetrieveUsersForUserIds:[[NSSet setWithArray:userIds] allObjects] includeCurMonsterTeam:includeCurMonsterTeam];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

#pragma mark - IAP

- (void) inAppPurchase:(NSString *)receipt goldAmt:(int)gold silverAmt:(int)silver product:(SKProduct *)product delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  if (gs.connected) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendInAppPurchaseMessage:receipt product:product];
    [gs addUnrespondedUpdates:[GoldUpdate updateWithTag:tag change:gold], [SilverUpdate updateWithTag:tag change:silver], nil];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
    
    if ([product.productIdentifier rangeOfString:@"bsale"].length > 0) {
      gs.numBeginnerSalesPurchased++;
    }
    
    [Analytics iapPurchased:product.productIdentifier gemChange:gold gemBalance:gs.gems];
  }
  
  NSString *key = IAP_DEFAULTS_KEY;
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *arr = [defaults arrayForKey:key];
  NSMutableArray *mut = arr ? [arr mutableCopy] : [NSMutableArray array];
  [mut addObject:receipt];
  [defaults setObject:mut forKey:IAP_DEFAULTS_KEY];
  [defaults synchronize];
}

#pragma mark - User changes

- (void) exchangeGemsForResources:(int)gems resources:(int)resources percFill:(int)percFill resType:(ResourceType)resType delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  
  if (gs.gems < gems) {
    [Globals popupMessage:@"Trying to exchange too many gems.."];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendExchangeGemsForResourcesMessage:gems resources:resources resType:resType clientTime:[self getCurrentMilliseconds]];
    
    FullUserUpdate *up = nil;
    int oilChange = 0, cashChange = 0;
    NSString *res = nil;
    if (resType == ResourceTypeCash) {
      up = [SilverUpdate updateWithTag:tag change:resources];
      cashChange = resources;
      res = @"cash";
    } else if (resType == ResourceTypeOil) {
      up = [OilUpdate updateWithTag:tag change:resources];
      oilChange = resources;
      res = @"oil";
    }
    [gs addUnrespondedUpdates:[GoldUpdate updateWithTag:tag change:-gems], up, nil];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
    
    [Analytics fillStorage:res percAmount:percFill cashChange:cashChange cashBalance:gs.cash oilChange:oilChange oilBalance:gs.oil gemChange:-gems gemBalance:gs.gems];
  }
}

- (void) levelUp {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (gs.level >= gl.maxLevelForUser) {
    [Globals popupMessage:@"Trying to level up when already at maximum level."];
  } else if (gs.experience >= [gs expNeededForLevel:gs.level+1]) {
    int nextLevel = gs.level+1;
    while (gs.experience >= [gs expNeededForLevel:nextLevel+1]) {
      nextLevel++;
    }
    
    int tag = [[SocketCommunication sharedSocketCommunication] sendLevelUpMessage:nextLevel];
    
    LevelUpdate *lu = [LevelUpdate updateWithTag:tag change:nextLevel-gs.level];
    [gs addUnrespondedUpdate:lu];
  } else {
    [Globals popupMessage:@"Trying to level up without enough experience"];
  }
}

- (void) enableApns:(NSString *)deviceToken {
  GameState *gs = [GameState sharedGameState];
  if (!gs.connected || gs.isTutorial || [gs.deviceToken isEqualToString:deviceToken]) {
    return;
  }
  
  if (deviceToken.length == 0) {
    deviceToken = nil;
  }
  
  gs.deviceToken = deviceToken;
  
  int tag = [[SocketCommunication sharedSocketCommunication] sendAPNSMessage:deviceToken];
  
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) setGameCenterId:(NSString *)gameCenterId {
  GameState *gs = [GameState sharedGameState];
  if (!gs.connected || gs.isTutorial || [gs.gameCenterId isEqualToString:gameCenterId]) {
    return;
  }
  
  [[SocketCommunication sharedSocketCommunication] sendSetGameCenterMessage:gameCenterId];
}

- (void) setFacebookId:(NSString *)facebookId email:(NSString *)email otherFbInfo:(NSDictionary *)otherFbInfo delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  if (gs.facebookId) {
    [Globals popupMessage:@"Trying to set new facebook id when there is one already.."];
    return;
  }
  
  NSString *jsonString = nil;
  if (otherFbInfo) {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:otherFbInfo
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
      LNLog(@"Got an error: %@", error);
    } else {
      jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
  }
  int tag = [[SocketCommunication sharedSocketCommunication] sendSetFacebookIdMessage:facebookId email:email otherFbInfo:jsonString];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  
  gs.facebookId = facebookId;
}

- (void) setAvatarMonster:(int)avatarMonsterId {
  GameState *gs = [GameState sharedGameState];
  if (gs.avatarMonsterId != avatarMonsterId) {
    [[SocketCommunication sharedSocketCommunication] sendSetAvatarMonsterMessage:avatarMonsterId];
    
    gs.avatarMonsterId = avatarMonsterId;
    [[SocketCommunication sharedSocketCommunication] rebuildSender];
  }
}

#pragma mark - Chat

- (void) sendGroupChat:(GroupChatScope)scope message:(NSString *)msg {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (msg.length > gl.maxLengthOfChatString) {
    [Globals popupMessage:@"Attempting to send msg that exceeds appropriate length"];
  } else {
    NSRange r = [msg rangeOfString:CODE_PREFIX];
    if (r.length > 0) {
      NSString *code = [msg stringByReplacingCharactersInRange:r withString:@""];
      
#ifndef APPSTORE
      @try {
        int cashAmt = 0, oilAmt = 0, gemsAmt = 0;
        NSString *reason = nil;
        if ((r = [code rangeOfString:CASH_CODE]).length > 0) {
          r.length++;
          code = [code stringByReplacingCharactersInRange:r withString:@""];
          cashAmt = code.intValue;
          reason = CASH_CODE;
          msg = [NSString stringWithFormat:@"Awarded %d cash.", cashAmt];
        } else if ((r = [code rangeOfString:OIL_CODE]).length > 0) {
          r.length++;
          code = [code stringByReplacingCharactersInRange:r withString:@""];
          oilAmt = code.intValue;
          reason = OIL_CODE;
          msg = [NSString stringWithFormat:@"Awarded %d oil.", oilAmt];
        } else if ((r = [code rangeOfString:CASH_AND_OIL_CODE]).length > 0) {
          r.length++;
          code = [code stringByReplacingCharactersInRange:r withString:@""];
          cashAmt = code.intValue;
          oilAmt = code.intValue;
          reason = CASH_AND_OIL_CODE;
          msg = [NSString stringWithFormat:@"Awarded %d cash and oil.", cashAmt];
        } else if ((r = [code rangeOfString:GEMS_CODE]).length > 0) {
          r.length++;
          code = [code stringByReplacingCharactersInRange:r withString:@""];
          gemsAmt = code.intValue;
          reason = GEMS_CODE;
          msg = [NSString stringWithFormat:@"Awarded %d gems.", gemsAmt];
        }
        
        if (cashAmt || oilAmt || gemsAmt) {
          [[OutgoingEventController sharedOutgoingEventController] updateUserCurrencyWithCashChange:cashAmt oilChange:oilAmt gemChange:gemsAmt reason:reason];
        } else if (reason) {
          @throw [NSException exceptionWithName:@"thrown" reason:@"to get msg" userInfo:nil];
        }
      }
      @catch (NSException *exception) {
        msg = @"You must enter a quantity of currency!";
      }
      
      if ([code isEqualToString:UNLOCK_BUILDINGS_CODE]) {
        msg = @"Unlocked all dungeons.";
        [gs unlockAllTasks];
      } else if ([code isEqualToString:SKIP_QUESTS_CODE]) {
        msg = @"Quests can now be skipped.";
        gs.allowQuestSkipping = YES;
      }
#endif
      
      if ([code isEqualToString:PURGE_CODE]) {
        [[Downloader sharedDownloader] purgeAllDownloadedData];
        msg = @"All downloaded data has been purged.";
      } else if ([code isEqualToString:RESET_CODE]) {
        msg = @"Resetting account...";
        [[OutgoingEventController sharedOutgoingEventController] updateUserCurrencyWithCashChange:1234 oilChange:1234 gemChange:1234 reason:RESET_CODE];
      } else if ([code isEqualToString:FB_LOGOUT_CODE]) {
        msg = @"Logged out of Facebook.";
        [FacebookDelegate logout];
      } else if ([code isEqualToString:UNMUTE_CODE]) {
        msg = @"Unmuted all players.";
        [gl unmuteAllPlayers];
      }
      
      else if (!msg) {
        msg = @"Unaccepted code.";
      }
    } else {
      [[SocketCommunication sharedSocketCommunication] sendGroupChatMessage:scope message:msg clientTime:[self getCurrentMilliseconds]];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.35f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
      [gs addChatMessage:gs.minUserWithLevel message:msg scope:scope isAdmin:(scope == GroupChatScopeGlobal ? gs.isAdmin : NO)];
      
      NSString *key = scope == GroupChatScopeClan ? CLAN_CHAT_RECEIVED_NOTIFICATION : GLOBAL_CHAT_RECEIVED_NOTIFICATION;
      [[NSNotificationCenter defaultCenter] postNotificationName:key object:nil];
    });
  }
}

- (void) privateChatPost:(int)recipientId content:(NSString *)content {
  GameState *gs = [GameState sharedGameState];
  if (recipientId == gs.userId) {
    [Globals popupMessage:@"You are not allowed to send private chats to yourself."];
  } else {
    [[SocketCommunication sharedSocketCommunication] sendPrivateChatPostMessage:recipientId content:content];
  }
}

- (void) retrievePrivateChatPosts:(int)otherUserId delegate:(id)delegate {
  int tag = [[SocketCommunication sharedSocketCommunication] sendRetrievePrivateChatPostsMessage:otherUserId];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
}

#pragma mark - Clans

- (void) createClan:(NSString *)clanName tag:(NSString *)clanTag description:(NSString *)description requestOnly:(BOOL)requestOnly iconId:(int)iconId useGems:(BOOL)useGems delegate:(id)delegate {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  
  if (clanName.length <= 0 || clanName.length > gl.maxCharLengthForClanName) {
    [Globals popupMessage:@"Attempting to create clan with inappropriate clan name length."];
  } else if (clanTag.length <= 0 || clanTag.length > gl.maxCharLengthForClanTag) {
    [Globals popupMessage:@"Attempting to create clan with inappropriate clan tag length."];
  } else if (!useGems && gs.cash < gl.coinPriceToCreateClan) {
    [Globals popupMessage:@"Attempting to create clan without enough cash."];
  } else {
    int cost = gl.coinPriceToCreateClan;
    int curAmount = gs.cash;
    int gemCost = 0;
    
    if (useGems && cost > curAmount) {
      gemCost = [gl calculateGemConversionForResourceType:ResourceTypeCash amount:cost-curAmount];
      cost = curAmount;
    }
    
    if (cost > curAmount || gemCost > gs.gems) {
      [Globals popupMessage:@"Trying to create clan without enough resources."];
    } else {
      int tag = [[SocketCommunication sharedSocketCommunication] sendCreateClanMessage:clanName tag:clanTag description:description requestOnly:requestOnly iconId:iconId cashChange:-cost gemsSpent:gemCost];
      [gs addUnrespondedUpdates:[SilverUpdate updateWithTag:tag change:-cost], [GoldUpdate updateWithTag:tag change:-gemCost], nil];
      [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
      
      [Analytics createClan:clanName cashChange:-cost cashBalance:gs.cash gemChange:-gemCost gemBalance:gs.gems];
    }
  }
}

- (void) leaveClanWithDelegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  
  // Make sure clan controller checks member size and clan leader
  if (gs.clan) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendLeaveClanMessage];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  } else {
    [Globals popupMessage:@"Attempting to leave clan without being in clan."];
  }
}

- (void) requestJoinClan:(int)clanId delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  
  if (gs.clan) {
    [Globals popupMessage:@"You can't submit a clan request while you're already in a clan."];
  } else if ([gs.requestedClans containsObject:[NSNumber numberWithInt:clanId]]) {
    [Globals popupMessage:@"You already have a pending request with this clan!"];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendRequestJoinClanMessage:clanId];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  }
}

- (void) retractRequestToJoinClan:(int)clanId delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  
  if (gs.clan || ![gs.requestedClans containsObject:[NSNumber numberWithInt:clanId]]) {
    [Globals popupMessage:@"You no longer have a request pending to this clan!"];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendRetractRequestJoinClanMessage:clanId];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  }
}

- (void) approveOrRejectRequestToJoinClan:(int)requesterId accept:(BOOL)accept delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  
  if (!gs.clan) {
    [Globals popupMessage:@"Attempting to respond to clan request while not clan leader."];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendApproveOrRejectRequestToJoinClan:requesterId accept:accept];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  }
}

- (void) transferClanOwnership:(int)newClanOwnerId delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  
  if (!gs.clan) {
    [Globals popupMessage:@"Attempting to transfer clan ownership while not clan leader."];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendTransferClanOwnership:newClanOwnerId];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  }
}

- (void) changeClanSettingsIsDescription:(BOOL)isDescription description:(NSString *)description isRequestType:(BOOL)isRequestType requestRequired:(BOOL)requestRequired isIcon:(BOOL)isIcon iconId:(int)iconId delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (!gs.clan) {
    [Globals popupMessage:@"Attempting to change clan settings while not in a clan."];
  } else if (isDescription && (description.length <= 0 || description.length > gl.maxCharLengthForClanDescription)) {
    [Globals popupMessage:@"Attempting to change clan description with inappropriate length"];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendChangeClanDescription:isDescription description:description isRequestType:isRequestType requestRequired:requestRequired isIcon:isIcon iconId:iconId];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  }
}

- (void) promoteOrDemoteMember:(int)memberId newStatus:(UserClanStatus)status delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  
  if (!gs.clan) {
    [Globals popupMessage:@"Attempting to change member status while not in a clan."];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendPromoteDemoteClanMemberMessage:memberId newStatus:status];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  }
}

- (void) bootPlayerFromClan:(int)playerId delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  
  if (!gs.clan) {
    [Globals popupMessage:@"Attempting to boot player while not clan leader."];
  } else {
    // Make sure clan is not engaged in a clan tower war
    int tag = [[SocketCommunication sharedSocketCommunication] sendBootPlayerFromClan:playerId];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  }
}

- (void) retrieveClanInfo:(NSString *)clanName clanId:(int)clanId grabType:(RetrieveClanInfoRequestProto_ClanInfoGrabType)grabType isForBrowsingList:(BOOL)isForBrowsingList  beforeClanId:(int)beforeClanId delegate:(id)delegate {
  int tag = [[SocketCommunication sharedSocketCommunication] sendRetrieveClanInfoMessage:clanName clanId:clanId grabType:grabType isForBrowsingList:isForBrowsingList beforeClanId:beforeClanId];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  
  GameState *gs = [GameState sharedGameState];
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

#pragma mark Clan Raids

- (void) beginClanRaid:(PersistentClanEventProto *)event delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  BOOL isFirstStage = gs.curClanRaidInfo.clanRaidId == 0 || gs.curClanRaidInfo.currentStage.stageNum == 1;
  int tag = [[SocketCommunication sharedSocketCommunication] sendBeginClanRaidMessage:event.clanRaidId eventId:event.clanEventId isFirstStage:isFirstStage curTime:[self getCurrentMilliseconds] userMonsters:nil];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
}

- (void) setClanRaidTeam:(NSArray *)userMonsters delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  BOOL isFirstStage = gs.curClanRaidInfo.currentStage.stageNum == 1;
  
  NSMutableArray *arr = [NSMutableArray array];
  for (UserMonster *um in userMonsters) {
    [arr addObject:[um convertToProto]];
  }
  
  int tag = [[SocketCommunication sharedSocketCommunication] sendBeginClanRaidMessage:gs.curClanRaidInfo.clanRaidId eventId:gs.curClanRaidInfo.clanEventId isFirstStage:isFirstStage curTime:[self getCurrentMilliseconds] userMonsters:arr];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
}

- (void) dealDamageToClanRaidMonster:(int)dmg attacker:(BattlePlayer *)attacker curTeam:(NSArray *)curTeam {
  GameState *gs = [GameState sharedGameState];
  
  NSMutableArray *mut = [NSMutableArray array];
  NSMutableArray *ums = [NSMutableArray array];
  FullUserMonsterProto *attackerProto = nil;
  for (BattlePlayer *player in curTeam) {
    UserMonsterCurrentHealthProto_Builder *b = [UserMonsterCurrentHealthProto builder];
    b.userMonsterId = player.userMonsterId;
    b.currentHealth = player.curHealth;
    [mut addObject:b.build];
    
    UserMonster *um = [gs myMonsterWithUserMonsterId:player.userMonsterId];
    um.curHealth = player.curHealth;
    
    [ums addObject:[um convertToProto]];
    
    if (um.userMonsterId == attacker.userMonsterId) {
      attackerProto = [um convertToProto];
    }
  }
  
  UserCurrentMonsterTeamProto *team = [[[[UserCurrentMonsterTeamProto builder] addAllCurrentTeam:ums] setUserId:gs.userId] build];
  PersistentClanEventClanInfoProto *info = gs.curClanRaidInfo;
  [[SocketCommunication sharedSocketCommunication] sendAttackClanRaidMonsterMessage:info clientTime:[self getCurrentMilliseconds] damageDealt:dmg curTeam:team monsterHealths:mut attacker:attackerProto];
}

#pragma mark - Gacha

- (void) purchaseBoosterPack:(int)boosterPackId delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  BoosterPackProto *bpp = [gs boosterPackForId:boosterPackId];
  if (!bpp) {
    [Globals popupMessage:@"Unable to find booster pack."];
  } else if (bpp.gemPrice > gs.gems) {
    [Globals popupMessage:@"Attempting to spin without enough gems."];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendPurchaseBoosterPackMessage:boosterPackId clientTime:[self getCurrentMilliseconds]];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-bpp.gemPrice]];
  }
}

#pragma mark - Dungeons

- (void) beginDungeon:(int)taskId withDelegate:(id)delegate {
  [self beginDungeon:taskId isEvent:NO eventId:0 useGems:NO withDelegate:delegate];
}

- (void) beginDungeon:(int)taskId enemyElement:(Element)element withDelegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  int tag = [[SocketCommunication sharedSocketCommunication] sendBeginDungeonMessage:[self getCurrentMilliseconds] taskId:taskId isEvent:NO eventId:0 gems:0 enemyElement:element shouldForceElem:YES alreadyCompletedMiniTutorialTask:NO questIds:gs.inProgressIncompleteQuests.allKeys];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
}

- (void) beginDungeon:(int)taskId isEvent:(BOOL)isEvent eventId:(int)eventId useGems:(BOOL)useGems withDelegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int gems = 0;
  if (isEvent) {
    PersistentEventProto *pe = [gs persistentEventWithId:eventId];
    NSTimeInterval time = pe.cooldownEndTime.timeIntervalSinceNow;
    if (!pe) {
      [Globals popupMessage:@"Trying to enter event dungeon without event"];
      return;
    } else if (!pe.isRunning) {
      [Globals popupMessage:@"Trying to enter event dungeon that isn't running"];
      return;
    } else if (!useGems && time > 0) {
      [Globals popupMessage:@"Trying to enter event dungeon before cooldown time"];
      return;
    }
    
    if (useGems) {
      gems = [gl calculateGemSpeedupCostForTimeLeft:time];
      if (gs.gems < gems) {
        [Globals popupMessage:@"Trying to enter dungeon without enough gems"];
        return;
      }
    }
  }
  
  BOOL mini = taskId == gl.miniTutorialConstants.miniTutorialTaskId && [gs.completedTasks containsObject:@(taskId)];
  int tag = [[SocketCommunication sharedSocketCommunication] sendBeginDungeonMessage:[self getCurrentMilliseconds] taskId:taskId isEvent:isEvent eventId:eventId gems:gems enemyElement:ElementFire shouldForceElem:NO alreadyCompletedMiniTutorialTask:mini questIds:nil];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-gems]];
  
  [gs.eventCooldownTimes setObject:[MSDate date] forKey:@(eventId)];
  
  if (gems) {
    [Analytics enterDungeon:taskId gemChange:-gems gemBalance:gs.gems];
  }
}

- (void) updateMonsterHealth:(uint64_t)userMonsterId curHealth:(int)curHealth {
  if (userMonsterId <= 0) {
    [Globals popupMessage:@"Trying to update invalid user monster"];
  } else if (curHealth < 0) {
    [Globals popupMessage:@"Trying to set health less than 0"];
  } else {
    GameState *gs = [GameState sharedGameState];
    UserMonster *userMonster = [gs myMonsterWithUserMonsterId:userMonsterId];
    userMonster.curHealth = curHealth;
    UserMonsterCurrentHealthProto *m = [[[[UserMonsterCurrentHealthProto builder]
                                          setCurrentHealth:userMonster.curHealth]
                                         setUserMonsterId:userMonster.userMonsterId]
                                        build];
    [[SocketCommunication sharedSocketCommunication] sendUpdateMonsterHealthMessage:[self getCurrentMilliseconds] monsterHealths:@[m] isForTask:NO userTaskId:0 taskStageId:0];
  }
}

- (void) progressDungeon:(NSArray *)curHealths dungeonInfo:(BeginDungeonResponseProto *)dungeonInfo newStageNum:(int)newStageNum {
  NSMutableArray *arr = [NSMutableArray array];
  for (BattlePlayer *bp in curHealths) {
    UserMonsterCurrentHealthProto *m = [[[[UserMonsterCurrentHealthProto builder]
                                          setCurrentHealth:bp.curHealth]
                                         setUserMonsterId:bp.userMonsterId]
                                        build];
    [arr addObject:m];
  }
  
  if (newStageNum < dungeonInfo.tspList.count) {
    TaskStageProto *tsp = dungeonInfo.tspList[newStageNum];
    [[SocketCommunication sharedSocketCommunication] sendUpdateMonsterHealthMessage:[self getCurrentMilliseconds] monsterHealths:arr isForTask:YES userTaskId:dungeonInfo.userTaskId taskStageId:tsp.stageId];
  } else {
    [Globals popupMessage:@"Attempting to progress dungeon with invalid stage num."];
  }
}

- (void) endDungeon:(BeginDungeonResponseProto *)dungeonInfo userWon:(BOOL)userWon delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  BOOL isFirstTime = ![gs.completedTasks containsObject:@(dungeonInfo.taskId)];
  int tag = [[SocketCommunication sharedSocketCommunication] sendEndDungeonMessage:dungeonInfo.userTaskId userWon:userWon isFirstTimeCompleted:isFirstTime time:[self getCurrentMilliseconds]];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  
  if (userWon) {
    int silverAmount = 0, oilAmount = 0, expAmount = 0;
    for (TaskStageProto *tsp in dungeonInfo.tspList) {
      for (TaskStageMonsterProto *tsm in tsp.stageMonstersList) {
        silverAmount += tsm.cashReward;
        oilAmount += tsm.oilReward;
        expAmount += tsm.expReward;
      }
    }
    
    SilverUpdate *su = [SilverUpdate updateWithTag:tag change:silverAmount];
    OilUpdate *ou = [OilUpdate updateWithTag:tag change:oilAmount];
    ExperienceUpdate *eu = [ExperienceUpdate updateWithTag:tag change:expAmount];
    [gs addUnrespondedUpdates: su, ou, eu, nil];
    
    [Analytics endDungeon:dungeonInfo.taskId cashChange:silverAmount cashBalance:gs.cash oilChange:oilAmount oilBalance:gs.oil];
  }
}

- (void) reviveInDungeon:(uint64_t)userTaskId taskId:(int)taskId myTeam:(NSArray *)team {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int gemCost = [gl calculateGemCostToHealTeamDuringBattle:team];
  
  if (gs.gems < gemCost) {
    [Globals popupMessage:@"Trying to revive without enough gold"];
  } else {
    NSMutableArray *arr = [NSMutableArray array];
    for (BattlePlayer *pl in team) {
      UserMonsterCurrentHealthProto *pr = [[[[UserMonsterCurrentHealthProto builder] setCurrentHealth:pl.maxHealth] setUserMonsterId:pl.userMonsterId] build];
      [arr addObject:pr];
      
      pl.curHealth = pl.maxHealth;
      
      UserMonster *um = [gs myMonsterWithUserMonsterId:pl.userMonsterId];
      um.curHealth = pl.curHealth;
    }
    
    int tag = [[SocketCommunication sharedSocketCommunication] sendReviveInDungeonMessage:userTaskId clientTime:[self getCurrentMilliseconds] userHealths:arr gems:gemCost];
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-gemCost]];
    
    [Analytics continueDungeon:taskId gemChange:-gemCost gemBalance:gs.gems];
  }
}

#pragma mark - PVP

- (void) queueUpEvent:(NSArray *)seenUserIds withDelegate:(id)delegate {
  seenUserIds = seenUserIds ? seenUserIds : [NSArray array];
  int tag = [[SocketCommunication sharedSocketCommunication] sendQueueUpMessage:seenUserIds clientTime:[self getCurrentMilliseconds]];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
}

- (BOOL) viewNextPvpGuy:(BOOL)useGems {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  TownHallProto *thp = (TownHallProto *)gs.myTownHall.staticStruct;
  
  int cashCost = thp.pvpQueueCashCost;
  int gemCost = 0;
  
  if (useGems && cashCost > gs.cash) {
    gemCost = [gl calculateGemConversionForResourceType:ResourceTypeCash amount:cashCost-gs.cash];
    cashCost = gs.cash;
  }
  
  if (cashCost > gs.cash || gemCost > gs.gems) {
    [Globals popupMessage:@"Trying to view next pvp guy without enough resources."];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendUpdateUserCurrencyMessageWithCashSpent:cashCost oilSpent:0 gemsSpent:gemCost clientTime:[self getCurrentMilliseconds] reason:@"Viewed New Pvp Guy"];
    
    SilverUpdate *su = [SilverUpdate updateWithTag:tag change:-cashCost];
    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:-gemCost];
    [gs addUnrespondedUpdates:su, gu, nil];
    
    [Analytics nextPvpWithCashChange:-cashCost cashBalance:gs.cash gemChange:-gemCost gemBalance:gs.gems];
    
    return YES;
  }
  return NO;
}

- (void) beginPvpBattle:(PvpProto *)proto isRevenge:(BOOL)isRevenge previousBattleTime:(uint64_t)previousBattleTime {
  GameState *gs = [GameState sharedGameState];
  [[SocketCommunication sharedSocketCommunication] sendBeginPvpBattleMessage:proto senderElo:gs.elo isRevenge:isRevenge previousBattleTime:previousBattleTime clientTime:[self getCurrentMilliseconds]];
  
  if (isRevenge) {
    PvpHistoryProto *pvp = nil;
    for (PvpHistoryProto *potential in gs.battleHistory) {
      if (potential.attacker.userId == proto.defender.minUserProto.userId &&
          potential.battleEndTime == previousBattleTime) {
        pvp = potential;
      }
    }
    
    if (pvp) {
      PvpHistoryProto_Builder *bldr = [PvpHistoryProto builderWithPrototype:pvp];
      bldr.exactedRevenge = YES;
      [gs.battleHistory replaceObjectAtIndex:[gs.battleHistory indexOfObject:pvp] withObject:bldr.build];
    }
  }
}

- (void) endPvpBattleMessage:(PvpProto *)proto userAttacked:(BOOL)userAttacked userWon:(BOOL)userWon delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  int oilGained = userWon ? proto.prospectiveOilWinnings : 0;
  int cashGained = userWon ? proto.prospectiveCashWinnings : 0;
  int tag = [[SocketCommunication sharedSocketCommunication] sendEndPvpBattleMessage:proto.defender.minUserProto.userId userAttacked:userAttacked userWon:userWon oilChange:oilGained cashChange:cashGained clientTime:[self getCurrentMilliseconds]];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  [gs addUnrespondedUpdates:[OilUpdate updateWithTag:tag change:oilGained], [SilverUpdate updateWithTag:tag change:cashGained], nil];
  
  if (userWon) {
    [Analytics endPvpWithCashChange:cashGained cashBalance:gs.cash oilChange:oilGained oilBalance:gs.oil];
  }
}

#pragma mark - Team

- (BOOL) removeMonsterFromTeam:(uint64_t)userMonsterId {
  GameState *gs = [GameState sharedGameState];
  UserMonster *um = [gs myMonsterWithUserMonsterId:userMonsterId];
  
  if (!um || !um.teamSlot) {
    [Globals popupMessage:@"Trying to remove invalid monster."];
  } else {
    um.teamSlot = 0;
    
    [[SocketCommunication sharedSocketCommunication] sendRemoveMonsterFromTeam:userMonsterId];
    return YES;
  }
  return NO;
}

- (BOOL) addMonsterToTeam:(uint64_t)userMonsterId {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  UserMonster *um = [gs myMonsterWithUserMonsterId:userMonsterId];
  NSArray *curMembers = [gs allMonstersOnMyTeam];
  
  if (!um || um.teamSlot || !um.isComplete) {
    [Globals popupMessage:@"Trying to add invalid monster."];
  } else {
    UserMonster *potentialUm = nil;
    int teamSlot = 1;
    while (teamSlot <= gl.maxTeamSize) {
      BOOL found = NO;
      for (UserMonster *m in curMembers) {
        if (m.teamSlot == teamSlot) {
          if (![m isAvailable]) {
            potentialUm = m;
          }
          found = YES;
        }
      }
      
      if (!found) {
        potentialUm = nil;
        break;
      }
      teamSlot++;
    }
    if (teamSlot <= gl.maxTeamSize || potentialUm) {
      if (potentialUm) {
        teamSlot = potentialUm.teamSlot;
        potentialUm.teamSlot = 0;
      }
      um.teamSlot = teamSlot;
      
      [[SocketCommunication sharedSocketCommunication] sendAddMonsterToTeam:userMonsterId teamSlot:teamSlot];
      return YES;
    } else {
      [Globals addAlertNotification:@"Team is already at max size!"];
    }
  }
  return NO;
}

#pragma mark - Bonus slots (fb)

- (void) increaseInventorySlots:(UserStruct *)us withGems:(BOOL)gems delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  ResidenceProto *curRes = (ResidenceProto *)us.staticStruct;
  ResidenceProto *fbRes = (ResidenceProto *)us.staticStructForNextFbLevel;
  
  if (curRes.structInfo.structType != StructureInfoProto_StructTypeResidence) {
    [Globals popupMessage:@"Trying to buy slots for non-residence"];
  } else if (us.fbInviteStructLvl >= curRes.structInfo.level) {
    [Globals popupMessage:@"Trying to increase slots past max."];
  } else if (gems && gs.gems < fbRes.numGemsRequired) {
    [Globals popupMessage:@"Trying to increase inventory without enough gold"];
  } else {
    int tag = 0;
    if (gems) {
      NSArray *arr = [gs acceptedFbRequestsForUserStructId:us.userStructId fbStructLevel:us.fbInviteStructLvl+1];
      for (RequestFromFriend *req in arr) {
        [gs.fbAcceptedRequestsFromMe removeObject:req];
      }
      
      tag = [[SocketCommunication sharedSocketCommunication] sendBuyInventorySlotsWithGems:us.userStructId];
    } else {
      NSArray *reqs = [gs acceptedFbRequestsForUserStructId:us.userStructId fbStructLevel:us.fbInviteStructLvl+1];
      
      if (reqs.count < fbRes.numAcceptedFbInvites) {
        [Globals popupMessage:@"Trying to increase inventory without enough accepted invites."];
        return;
      }
      
      NSArray *realReqs = [reqs subarrayWithRange:NSMakeRange(0, fbRes.numAcceptedFbInvites)];
      NSArray *rejectedReqs = [reqs subarrayWithRange:NSMakeRange(fbRes.numAcceptedFbInvites, reqs.count-fbRes.numAcceptedFbInvites)];
      
      uint64_t date = [self getCurrentMilliseconds];
      for (RequestFromFriend *inv in realReqs) {
        UserFacebookInviteForSlotProto_Builder *bldr = [UserFacebookInviteForSlotProto builderWithPrototype:inv.invite];
        bldr.redeemedTime = date;
        inv.invite = [bldr build];
      }
      
      for (RequestFromFriend *inv in rejectedReqs) {
        [gs.fbAcceptedRequestsFromMe removeObject:inv];
      }
      
      NSMutableArray *invs = [NSMutableArray array];
      for (RequestFromFriend *req in realReqs) {
        [invs addObject:@(req.invite.inviteId)];
      }
      
      tag = [[SocketCommunication sharedSocketCommunication] sendBuyInventorySlots:us.userStructId withFriendInvites:invs];
    }
    us.fbInviteStructLvl++;
    
    int gemsSpent = gems ? -fbRes.numGemsRequired : 0;
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:gemsSpent]];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
    
    int invSize = [gs maxInventorySlots];
    [Analytics bonusSlots:fbRes.occupationName askedFriends:!gems invChange:fbRes.numBonusMonsterSlots invBalance:invSize gemChange:gemsSpent gemBalance:gs.gems];
  }
}

- (void) inviteAllFacebookFriends:(NSArray *)fbFriends forStruct:(UserStruct *)us {
  NSMutableArray *invs = [NSMutableArray array];
  for (NSString *fbId in fbFriends) {
    InviteFbFriendsForSlotsRequestProto_FacebookInviteStructure_Builder *bldr = [InviteFbFriendsForSlotsRequestProto_FacebookInviteStructure builder];
    bldr.fbFriendId = [NSString stringWithFormat:@"%@", fbId];
    bldr.userStructId = us.userStructId;
    bldr.userStructFbLvl = us.fbInviteStructLvl+1;
    [invs addObject:bldr.build];
  }
  
  [[SocketCommunication sharedSocketCommunication] sendInviteFbFriendsForSlotsMessage:invs];
}

- (void) acceptAndRejectInvitesWithAcceptIds:(NSArray *)acceptIds rejectIds:(NSArray *)rejectIds {
  if (acceptIds.count > 0 || rejectIds.count > 0) {
    GameState *gs = [GameState sharedGameState];
    NSMutableArray *toRemove = [NSMutableArray array];
    for (RequestFromFriend *req in gs.fbUnacceptedRequestsFromFriends) {
      NSNumber *num = @(req.invite.inviteId);
      if ([acceptIds containsObject:num] || [rejectIds containsObject:num]) {
        [toRemove addObject:req];
      }
    }
    for (id req in toRemove) {
      [gs.fbUnacceptedRequestsFromFriends removeObject:req];
    }
    
    [[SocketCommunication sharedSocketCommunication] sendAcceptAndRejectFbInviteForSlotsMessageAndAcceptIds:acceptIds rejectIds:rejectIds];
  }
}

#pragma mark - Combining monsters

- (void) combineMonsters:(NSArray *)userMonsterIds {
  GameState *gs = [GameState sharedGameState];
  for (NSNumber *umId in userMonsterIds) {
    UserMonster *um = [gs myMonsterWithUserMonsterId:umId.intValue];
    um.isComplete = YES;
  }
  [[SocketCommunication sharedSocketCommunication] sendCombineUserMonsterPiecesMessage:userMonsterIds gemCost:0];
}

- (BOOL) combineMonsterWithSpeedup:(uint64_t)userMonsterId {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserMonster *um = [gs myMonsterWithUserMonsterId:userMonsterId];
  int timeLeft = um.timeLeftForCombining;
  int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
  
  if (gs.gems < goldCost) {
    [Globals popupMessage:@"Trying to speedup combine monster without enough gems"];
  } else {
    um.isComplete = YES;
    
    int tag = [[SocketCommunication sharedSocketCommunication] sendCombineUserMonsterPiecesMessage:[NSArray arrayWithObject:[NSNumber numberWithUnsignedLongLong:userMonsterId]] gemCost:goldCost];
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-goldCost]];
    
    [gs beginCombineTimer];
    
    [Analytics instantFinish:@"combineWait" gemChange:-goldCost gemBalance:gs.gems];
    
    return YES;
  }
  return NO;
}

#pragma mark - Healing

- (BOOL) addMonsterToHealingQueue:(uint64_t)userMonsterId useGems:(BOOL)useGems {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  UserMonster *um = [gs myMonsterWithUserMonsterId:userMonsterId];
  
  int maxHealth = [gl calculateMaxHealthForMonster:um];
  int silverCost = [gl calculateCostToHealMonster:um];
  if (um.curHealth >= maxHealth) {
    [Globals popupMessage:@"This monster is already at full health."];
  } else if (!useGems && gs.cash < silverCost) {
    [Globals popupMessage:@"Trying to heal item without enough cash."];
  } else {
    int gemCost = 0;
    if (useGems && gs.cash < silverCost) {
      gemCost = [gl calculateGemConversionForResourceType:ResourceTypeCash amount:silverCost-gs.cash];
      silverCost = gs.cash;
    }
    
    UserMonsterHealingItem *item = [[UserMonsterHealingItem alloc] init];
    item.userMonsterId = userMonsterId;
    item.userId = gs.userId;
    [gs addUserMonsterHealingItemToEndOfQueue:item];
    
    int tag = [[SocketCommunication sharedSocketCommunication] setHealQueueDirtyWithCoinChange:-silverCost gemCost:gemCost];
    SilverUpdate *su = [SilverUpdate updateWithTag:tag change:-silverCost];
    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:-gemCost];
    [gs addUnrespondedUpdates:su, gu, nil];
    
    [Analytics healMonster:um.monsterId cashChange:-silverCost cashBalance:gs.cash gemChange:-gemCost gemBalance:gs.gems];
    
    return YES;
  }
  return NO;
}

- (BOOL) removeMonsterFromHealingQueue:(UserMonsterHealingItem *)item {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserMonster *um = [gs myMonsterWithUserMonsterId:item.userMonsterId];
  
  int silverCost = [gl calculateCostToHealMonster:um];
  if (![gs.monsterHealingQueue containsObject:item]) {
    [Globals popupMessage:@"This item is not in the healing queue."];
  } else {
    [gs removeUserMonsterHealingItem:item];
    
    silverCost = MIN(silverCost, MAX(0, gs.maxCash-gs.cash));
    int tag = [[SocketCommunication sharedSocketCommunication] setHealQueueDirtyWithCoinChange:silverCost gemCost:0];
    [gs addUnrespondedUpdate:[SilverUpdate updateWithTag:tag change:silverCost]];
    
    [Analytics cancelHealMonster:um.monsterId cashChange:silverCost cashBalance:gs.cash];
    
    return YES;
  }
  return NO;
}

- (BOOL) speedupHealingQueue {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int timeLeft = gs.monsterHealingQueueEndTime.timeIntervalSinceNow;
  int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
  
  if (gs.gems < goldCost) {
    [Globals popupMessage:@"Trying to speedup heal queue without enough gold"];
  } else {
    NSMutableArray *arr = [NSMutableArray array];
    for (UserMonsterHealingItem *item in gs.monsterHealingQueue) {
      UserMonster *um = [gs myMonsterWithUserMonsterId:item.userMonsterId];
      um.curHealth = [gl calculateMaxHealthForMonster:um];
      
      UserMonsterCurrentHealthProto_Builder *monsterHealth = [UserMonsterCurrentHealthProto builder];
      monsterHealth.userMonsterId = um.userMonsterId;
      monsterHealth.currentHealth = um.curHealth;
      [arr addObject:monsterHealth.build];
      
      [gs.recentlyHealedMonsterIds addObject:@(um.userMonsterId)];
    }
    
    int tag = [[SocketCommunication sharedSocketCommunication] sendHealQueueSpeedup:arr goldCost:goldCost];
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-goldCost]];
    
    // Remove after to let the queue update to not be affected
    [gs.monsterHealingQueue removeAllObjects];
    [gs stopHealingTimer];
    
    [Analytics instantFinish:@"healWait" gemChange:-goldCost gemBalance:gs.gems];
    
    return YES;
  }
  return NO;
}

- (void) healQueueWaitTimeComplete:(NSArray *)healingItems {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *arr = [NSMutableArray array];
  for (UserMonsterHealingItem *item in healingItems) {
    if ([item.endTime timeIntervalSinceNow] > 0) {
      [Globals popupMessage:@"Trying to finish healing item before time."];
    } else {
      UserMonster *um = [gs myMonsterWithUserMonsterId:item.userMonsterId];
      um.curHealth = [gl calculateMaxHealthForMonster:um];
      
      UserMonsterCurrentHealthProto_Builder *monsterHealth = [UserMonsterCurrentHealthProto builder];
      monsterHealth.userMonsterId = um.userMonsterId;
      monsterHealth.currentHealth = um.curHealth;
      [arr addObject:monsterHealth.build];
      
      [gs.recentlyHealedMonsterIds addObject:@(um.userMonsterId)];
    }
  }
  
  [[SocketCommunication sharedSocketCommunication] sendHealQueueWaitTimeComplete:arr];
  
  // Remove after to let the queue update to not be affected
  [gs.monsterHealingQueue removeObjectsInArray:healingItems];
  [gs beginHealingTimer];
}

- (void) sellUserMonsters:(NSArray *)userMonsterIds {
  GameState *gs = [GameState sharedGameState];
  
  int numCompleteMonsters = 0;
  for (UserMonster *um in gs.myMonsters) {
    if (um.isComplete) {
      numCompleteMonsters++;
    }
  }
  int numCompleteTryingToSell = 0;
  NSMutableArray *sellProtos = [NSMutableArray array];
  NSMutableArray *monstersToRemove = [NSMutableArray array];
  int moneyGained = 0;
  for (NSNumber *umId in userMonsterIds) {
    uint64_t userMonsterId = umId.longLongValue;
    UserMonster *um = [gs myMonsterWithUserMonsterId:userMonsterId];
    
    if (um) {
      if (um.isComplete) {
        numCompleteTryingToSell++;
      }
      
      moneyGained += um.sellPrice;
      
      MinimumUserMonsterSellProto *sell = [[[[MinimumUserMonsterSellProto builder] setUserMonsterId:userMonsterId] setCashAmount:um.sellPrice] build];
      [sellProtos addObject:sell];
      [monstersToRemove addObject:um];
    } else {
      [Globals popupMessage:@"Trying to sell nonexistant monster"];
      return;
    }
  }
  
  if (numCompleteTryingToSell == numCompleteMonsters) {
    [Globals popupMessage:@"You can't sell your last monster!"];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendSellUserMonstersMessage:sellProtos];
    [gs addUnrespondedUpdate:[SilverUpdate updateWithTag:tag change:moneyGained]];
    
    [gs.myMonsters removeObjectsInArray:monstersToRemove];
  }
}

#pragma mark - Enhancing

- (BOOL) setBaseEnhanceMonster:(uint64_t)userMonsterId {
  GameState *gs = [GameState sharedGameState];
  UserMonster *um = [gs myMonsterWithUserMonsterId:userMonsterId];
  
  if (gs.userEnhancement) {
    [Globals popupMessage:@"Trying to set base monster while already enhancing."];
  } else if (![um isAvailable]) {
    [Globals popupMessage:@"Trying to enhance item that is unavailable."];
  } else {
    EnhancementItem *ei = [[EnhancementItem alloc] init];
    ei.userMonsterId = userMonsterId;
    
    UserEnhancement *ue = [[UserEnhancement alloc] init];
    ue.baseMonster = ei;
    ue.feeders = [NSMutableArray array];
    gs.userEnhancement = ue;
    
    return YES;
  }
  return NO;
}

- (BOOL) removeBaseEnhanceMonster {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (!gs.userEnhancement) {
    [Globals popupMessage:@"Trying to remove base monster without one."];
  }  else {
    int oilIncrease = 0;
    for (EnhancementItem *item in gs.userEnhancement.feeders) {
      int oilCost = [gl calculateOilCostForEnhancement:gs.userEnhancement feeder:item];
      
      oilIncrease += oilCost;
    }
    
    int tag = [[SocketCommunication sharedSocketCommunication] setEnhanceQueueDirtyWithOilChange:oilIncrease gemCost:0];
    [gs addUnrespondedUpdate:[OilUpdate updateWithTag:tag change:oilIncrease]];
    
    gs.userEnhancement = nil;
    [gs stopEnhanceTimer];
    
    int baseMonsterId = gs.userEnhancement.baseMonster.userMonster.monsterId;
    [Analytics cancelEnhanceMonster:baseMonsterId feederId:0 oilChange:oilIncrease oilBalance:gs.oil];
    
    return YES;
  }
  return NO;
}

- (BOOL) addMonsterToEnhancingQueue:(uint64_t)userMonsterId useGems:(BOOL)useGems {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  UserMonster *um = [gs myMonsterWithUserMonsterId:userMonsterId];
  UserEnhancement *ue = gs.userEnhancement;
  
  EnhancementItem *newItem = [[EnhancementItem alloc] init];
  newItem.userMonsterId = userMonsterId;
  
  int oilCost = [gl calculateOilCostForEnhancement:ue feeder:newItem];
  
  newItem.enhancementCost = oilCost;
  
  if (!ue) {
    [Globals popupMessage:@"Trying to add feeder without base monster."];
  } else if (![um isAvailable]) {
    [Globals popupMessage:@"Trying to sacrifice monster that is not available."];
  } else if (!useGems && gs.oil < oilCost) {
    [Globals popupMessage:@"Trying to enhance item without enough oil."];
  } else {
    int gemCost = 0;
    if (useGems && gs.oil < oilCost) {
      gemCost = [gl calculateGemConversionForResourceType:ResourceTypeOil amount:oilCost-gs.oil];
      oilCost = gs.oil;
    }
    
    if (gs.gems < gemCost) {
      [Globals popupMessage:@"Trying to enhance without enough gems."];
    } else {
      [gs addEnhancingItemToEndOfQueue:newItem];
      
      um.teamSlot = 0;
      
      int tag = [[SocketCommunication sharedSocketCommunication] setEnhanceQueueDirtyWithOilChange:-oilCost gemCost:gemCost];
      OilUpdate *oil = [OilUpdate updateWithTag:tag change:-oilCost];
      GoldUpdate *gold = [GoldUpdate updateWithTag:tag change:-gemCost];
      [gs addUnrespondedUpdates:oil, gold, nil];
      
      int baseMonsterId = ue.baseMonster.userMonster.monsterId;
      [Analytics enhanceMonster:baseMonsterId feederId:um.monsterId oilChange:-oilCost oilBalance:gs.oil gemChange:-gemCost gemBalance:gs.gems];
      
      return YES;
    }
  }
  return NO;
}

- (BOOL) removeMonsterFromEnhancingQueue:(EnhancementItem *)item {
  GameState *gs = [GameState sharedGameState];
  
  if (![gs.userEnhancement.feeders containsObject:item]) {
    [Globals popupMessage:@"This item is not in the enhancing queue."];
  } else {
    [gs removeEnhancingItem:item];
    
    int oilChange = item.enhancementCost;
    oilChange = MIN(oilChange, MAX(0, gs.maxOil-gs.oil));
    int tag = [[SocketCommunication sharedSocketCommunication] setEnhanceQueueDirtyWithOilChange:oilChange gemCost:0];
    [gs addUnrespondedUpdate:[OilUpdate updateWithTag:tag change:oilChange]];
    
    int baseMonsterId = gs.userEnhancement.baseMonster.userMonster.monsterId;
    int feederId = item.userMonster.monsterId;
    [Analytics cancelEnhanceMonster:baseMonsterId feederId:feederId oilChange:oilChange oilBalance:gs.oil];
    
    return YES;
  }
  return NO;
}

- (BOOL) speedupEnhancingQueue {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int timeLeft = [gl calculateTimeLeftForEnhancement:gs.userEnhancement];
  int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
  
  if (gs.gems < goldCost) {
    [Globals popupMessage:@"Trying to speedup enhance queue without enough gold"];
  } else {
    NSMutableArray *arr = [NSMutableArray array];
    EnhancementItem *base = gs.userEnhancement.baseMonster;
    for (EnhancementItem *item in gs.userEnhancement.feeders) {
      UserMonster *um = [gs myMonsterWithUserMonsterId:item.userMonsterId];
      base.userMonster.experience += [gl calculateExperienceIncrease:base feeder:item];
      [arr addObject:[NSNumber numberWithUnsignedLongLong:um.userMonsterId]];
      [gs.myMonsters removeObject:um];
    }
    
    UserMonster *baseMonster = base.userMonster;
    UserMonsterCurrentExpProto_Builder *bldr = [UserMonsterCurrentExpProto builder];
    bldr.userMonsterId = baseMonster.userMonsterId;
    bldr.expectedExperience = baseMonster.experience;
    bldr.expectedLevel = baseMonster.level;
    
    int tag = [[SocketCommunication sharedSocketCommunication] sendEnhanceQueueSpeedup:bldr.build userMonsterIds:arr goldCost:goldCost];
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-goldCost]];
    
    [gs.userEnhancement.feeders removeAllObjects];
    
    [Analytics instantFinish:@"enhanceWait" gemChange:-goldCost gemBalance:gs.gems];
    
    return YES;
  }
  return NO;
}

- (void) enhanceQueueWaitTimeComplete:(NSArray *)enhancingItems {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *arr = [NSMutableArray array];
  EnhancementItem *base = gs.userEnhancement.baseMonster;
  for (EnhancementItem *item in enhancingItems) {
    MSDate *endTime = [gs.userEnhancement expectedEndTimeForItem:item];
    if ([endTime timeIntervalSinceNow] > 0) {
      [Globals popupMessage:@"Trying to finish enhancing item before time."];
    } else {
      UserMonster *um = [gs myMonsterWithUserMonsterId:item.userMonsterId];
      base.userMonster.experience += [gl calculateExperienceIncrease:base feeder:item];
      [arr addObject:[NSNumber numberWithUnsignedLongLong:um.userMonsterId]];
      [gs.myMonsters removeObject:um];
    }
  }
  
  UserMonster *baseMonster = base.userMonster;
  UserMonsterCurrentExpProto_Builder *bldr = [UserMonsterCurrentExpProto builder];
  bldr.userMonsterId = baseMonster.userMonsterId;
  bldr.expectedExperience = baseMonster.experience;
  bldr.expectedLevel = baseMonster.level;
  
  [[SocketCommunication sharedSocketCommunication] sendEnhanceQueueWaitTimeComplete:bldr.build userMonsterIds:arr];
  
  // Remove after to let the queue update to not be affected
  [gs.userEnhancement.feeders removeObjectsInArray:enhancingItems];
  
  if (gs.userEnhancement.feeders.count == 0) {
    [self removeBaseEnhanceMonster];
  } else {
    [gs beginEnhanceTimer];
  }
}

#pragma mark - Evolving

- (BOOL) evolveMonster:(EvoItem *)evoItem useGems:(BOOL)gems {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  UserEvolution *evo = [UserEvolution evolutionWithEvoItem:evoItem time:[MSDate date]];
  int oilCost = evoItem.userMonster1.staticMonster.evolutionCost;
  
  if (!evoItem.userMonster1 || !evoItem.userMonster2 || !evoItem.catalystMonster) {
    [Globals popupMessage:@"Trying to evolve without proper monsters."];
  } else if (evoItem.userMonster1.level < evoItem.userMonster1.staticMonster.maxLevel ||
             evoItem.userMonster2.level < evoItem.userMonster2.staticMonster.maxLevel) {
    [Globals popupMessage:@"Trying to evolve without max monsters."];
  } else if (!gems && gs.oil < oilCost) {
    [Globals popupMessage:@"Trying to enhance item without enough oil."];
  } else {
    int gemCost = 0;
    if (gems && gs.oil < oilCost) {
      gemCost = [gl calculateGemConversionForResourceType:ResourceTypeOil amount:oilCost-gs.oil];
      oilCost = gs.oil;
    }
    
    if (gs.gems < gemCost) {
      [Globals popupMessage:@"Trying to evolve without enough gems."];
    } else {
      evoItem.userMonster1.teamSlot = 0;
      evoItem.userMonster2.teamSlot = 0;
      evoItem.catalystMonster.teamSlot = 0;
      
      int tag = [[SocketCommunication sharedSocketCommunication] sendEvolveMonsterMessageWithEvolution:[evo convertToProto] gemCost:gemCost oilChange:-oilCost];
      OilUpdate *oil = [OilUpdate updateWithTag:tag change:-oilCost];
      GoldUpdate *gold = [GoldUpdate updateWithTag:tag change:-gemCost];
      [gs addUnrespondedUpdates:oil, gold, nil];
      
      gs.userEvolution = evo;
      [gs beginEvolutionTimer];
      
      [Analytics evolveMonster:evoItem.userMonster1.monsterId oilChange:-oilCost oilBalance:gs.oil gemChange:-gemCost gemBalance:gs.gems];
      
      return YES;
    }
  }
  
  return NO;
}

- (void) finishEvolutionWithGems:(BOOL)gems withDelegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserEvolution *ue = gs.userEvolution;
  
  if (!gs.userEvolution) {
    [Globals popupMessage:@"Trying to finish evolution without one."];
  } else {
    int timeLeft = gs.userEvolution.endTime.timeIntervalSinceNow;
    int numGems = 0;
    if (gems) {
      numGems = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
    }
    
    int tag = [[SocketCommunication sharedSocketCommunication] sendEvolutionFinishedMessageWithGems:numGems];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-numGems]];
    
    [gs.myMonsters removeObject:[gs myMonsterWithUserMonsterId:ue.userMonsterId1]];
    [gs.myMonsters removeObject:[gs myMonsterWithUserMonsterId:ue.userMonsterId2]];
    [gs.myMonsters removeObject:[gs myMonsterWithUserMonsterId:ue.catalystMonsterId]];
    gs.userEvolution = nil;
    
    [gs beginEvolutionTimer];
    
    if (gems) {
      [Analytics instantFinish:@"evolveWait" gemChange:-numGems gemBalance:gs.gems];
    }
  }
}

- (void) updateUserCurrencyWithCashChange:(int)cashChange oilChange:(int)oilChange gemChange:(int)gemChange reason:(NSString *)reason {
  GameState *gs = [GameState sharedGameState];
  int tag = [[SocketCommunication sharedSocketCommunication] sendUpdateUserCurrencyMessageWithCashSpent:cashChange oilSpent:oilChange gemsSpent:gemChange clientTime:[self getCurrentMilliseconds] reason:reason];
  
  SilverUpdate *su = [SilverUpdate updateWithTag:tag change:cashChange];
  OilUpdate *ou = [OilUpdate updateWithTag:tag change:oilChange];
  GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:gemChange];
  [gs addUnrespondedUpdates:su, ou, gu, nil];
}

#pragma mark - Mini Jobs

- (void) spawnMiniJob:(int)numToSpawn structId:(int)structId {
  uint64_t ms = [self getCurrentMilliseconds];
  [[SocketCommunication sharedSocketCommunication] sendSpawnMiniJobMessage:numToSpawn clientTime:ms structId:structId];
  
  GameState *gs = [GameState sharedGameState];
  gs.lastMiniJobSpawnTime = [MSDate dateWithTimeIntervalSince1970:ms/1000.];
}

- (void) beginMiniJob:(UserMiniJob *)userMiniJob userMonsterIds:(NSArray *)userMonsterIds delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  uint64_t ms = [self getCurrentMilliseconds];
  int tag = [[SocketCommunication sharedSocketCommunication] sendBeginMiniJobMessage:userMiniJob.userMiniJobId userMonsterIds:userMonsterIds clientTime:ms];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  
  userMiniJob.timeStarted = [MSDate dateWithTimeIntervalSince1970:ms/1000.];
  userMiniJob.userMonsterIds = userMonsterIds;
  
  [gs beginMiniJobTimer];
}

- (void) completeMiniJob:(UserMiniJob *)userMiniJob isSpeedup:(BOOL)isSpeedup gemCost:(int)gemCost delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  
  if (!(userMiniJob.timeStarted && !userMiniJob.timeCompleted)) {
    [Globals popupMessage:@"Trying to complete invalid mini job."];
    return;
  } else if (gs.gems < gemCost) {
    [Globals popupMessage:@"Trying to speedup without enough gems."];
  } else {
    uint64_t ms = [self getCurrentMilliseconds];
    int tag = [[SocketCommunication sharedSocketCommunication] sendCompleteMiniJobMessage:userMiniJob.userMiniJobId isSpeedUp:isSpeedup gemCost:gemCost clientTime:ms];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
    
    userMiniJob.timeCompleted = [MSDate dateWithTimeIntervalSince1970:ms/1000.];
    
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-gemCost]];
    
    [gs beginMiniJobTimer];
    
    if (isSpeedup) {
      [Analytics instantFinish:@"miniJobWait" gemChange:-gemCost gemBalance:gs.gems];
    }
  }
}

- (void) redeemMiniJob:(UserMiniJob *)userMiniJob delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  if (userMiniJob.timeCompleted) {
    uint64_t ms = [self getCurrentMilliseconds];
    
    NSDictionary *damages = [userMiniJob damageDealtPerUserMonsterId];
    
    // Create monster healths
    NSMutableArray *monsterHealths = [NSMutableArray array];
    for (NSNumber *umId in userMiniJob.userMonsterIds) {
      UserMonster *um = [gs myMonsterWithUserMonsterId:umId.longLongValue];
      int damage = [damages[@(um.userMonsterId)] intValue];
      um.curHealth -= damage;
      
      UserMonsterCurrentHealthProto_Builder *bldr = [UserMonsterCurrentHealthProto builder];
      bldr.userMonsterId = um.userMonsterId;
      bldr.currentHealth = um.curHealth;
      [monsterHealths addObject:bldr.build];
    }
    
    int tag = [[SocketCommunication sharedSocketCommunication] sendRedeemMiniJobMessage:userMiniJob.userMiniJobId clientTime:ms monsterHealths:monsterHealths];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
    
    GameState *gs = [GameState sharedGameState];
    [gs.myMiniJobs removeObject:userMiniJob];
    
    int cashChange = userMiniJob.miniJob.cashReward, gemChange = userMiniJob.miniJob.gemReward, oilChange = userMiniJob.miniJob.oilReward;
    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:gemChange];
    SilverUpdate *su = [SilverUpdate updateWithTag:tag change:cashChange];
    OilUpdate *ou = [OilUpdate updateWithTag:tag change:oilChange];
    [gs addUnrespondedUpdates:gu, su, ou, nil];
    
    [gs beginMiniJobTimer];
    
    [Analytics redeemMiniJob:userMiniJob.miniJob.miniJobId cashChange:cashChange cashBalance:gs.cash oilChange:oilChange oilBalance:gs.oil];
  }
}

@end
