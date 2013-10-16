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
#import "GameLayer.h"
#import "MissionMap.h"
#import "HomeMap.h"
#import "GenericPopupController.h"
#import "SoundEngine.h"
#import "OtherUpdates.h"
#import "OAHMAC_SHA1SignatureProvider.h"
#import "GameViewController.h"
#import "EquipDeltaView.h"
#import "Downloader.h"

#define CODE_PREFIX @"#~#"
#define PURGE_CODE @"purgecache"

#define  LVL6_SHARED_SECRET @"mister8conrad3chan9is1a2very4great5man"

@implementation OutgoingEventController

SYNTHESIZE_SINGLETON_FOR_CLASS(OutgoingEventController);

- (uint64_t) getCurrentMilliseconds {
  return ((uint64_t)[[NSDate date] timeIntervalSince1970])*1000;
}

- (void) createUser {
  //  GameState *gs = [GameState sharedGameState];
  //  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  //
  //  Globals *gl = [Globals sharedGlobals];
  //  int tag = [sc sendUserCreateMessageWithName:gs.name
  //                                         type:gs.type
  //                                          lat:gs.location.latitude
  //                                          lon:gs.location.longitude
  //                                 referralCode:tc.referralCode
  //                                  deviceToken:gs.deviceToken
  //                                       attack:gs.attack
  //                                      defense:gs.defense
  //                                       energy:tc.initEnergy+gl.skillPointsGainedOnLevelup
  //                                      stamina:tc.initStamina
  //                                      structX:tc.structCoords.x
  //                                      structY:tc.structCoords.y
  //                                 usedDiamonds:YES];
  //
  //  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) startupWithDelegate:(id)delegate {
  int tag = [[SocketCommunication sharedSocketCommunication] sendStartupMessage:[self getCurrentMilliseconds]];
  [[GameState sharedGameState] addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
}

- (void) logout {
  GameState *gs = [GameState sharedGameState];
  if (gs.connected && gs.userId > 0) {
    [[SocketCommunication sharedSocketCommunication] sendLogoutMessage];
  }
}

- (UserStruct *) purchaseNormStruct:(int)structId atX:(int)x atY:(int)y {
  GameState *gs = [GameState sharedGameState];
  FullStructureProto *fsp = [gs structWithId:structId];
  UserStruct *us = nil;
  
  // Check that no other building is being built
  for (UserStruct *u in gs.myStructs) {
    if (u.state == kBuilding) {
      [Globals popupMessage:@"You can only construct one building at a time!"];
      return us;
    }
  }
  
  if (gs.silver >= fsp.coinPrice && gs.gold >= fsp.diamondPrice) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendPurchaseNormStructureMessage:structId x:x y:y time:[self getCurrentMilliseconds]];
    us = [[UserStruct alloc] init];
    
    // UserStructId will come in the response
    us.userId = [[GameState sharedGameState] userId];
    us.structId = structId;
    us.level = 1;
    us.isComplete = NO;
    us.coordinates = CGPointMake(x, y);
    us.orientation = 0;
    us.purchaseTime = [NSDate date];
    us.lastRetrieved = nil;
    
    AddStructUpdate *asu = [AddStructUpdate updateWithTag:tag userStruct:us];
    SilverUpdate *su = [SilverUpdate updateWithTag:tag change:-fsp.coinPrice];
    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:-fsp.diamondPrice];
    [gs addUnrespondedUpdates:asu, su, gu, nil];
    
    [Analytics normStructPurchase:structId];
  } else {
    [Globals popupMessage:@"Not enough money to purchase this building"];
  }
  return us;
}

- (void) moveNormStruct:(UserStruct *)userStruct atX:(int)x atY:(int)y {
  CGPoint newCoord = CGPointMake(x, y);
  if (!CGPointEqualToPoint(userStruct.coordinates, newCoord)) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendMoveNormStructureMessage:userStruct.userStructId x:x y:y];
    userStruct.coordinates = CGPointMake(x, y);
    
    [[GameState sharedGameState] addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
  }
}

- (void) rotateNormStruct:(UserStruct *)userStruct to:(StructOrientation)orientation {
  if (userStruct.orientation != orientation) {
    [[SocketCommunication sharedSocketCommunication] sendRotateNormStructureMessage:userStruct.userStructId orientation:orientation];
    userStruct.orientation = orientation;
  }
}

- (void) sellNormStruct:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  Globals *gl = [Globals sharedGlobals];
  
  if (userStruct.userStructId == 0) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (userStruct.userId != gs.userId) {
    [Globals popupMessage:@"This is not your building!"];
  } else {
    int tag = [sc sendSellNormStructureMessage:userStruct.userStructId];
    
    SellStructUpdate *ssu = [SellStructUpdate updateWithTag:tag userStruct:userStruct];
    SilverUpdate *su = [SilverUpdate updateWithTag:tag change:[gl calculateStructSilverSellCost:userStruct]];
    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:[gl calculateStructGoldSellCost:userStruct]];
    
    [gs addUnrespondedUpdates:ssu, su, gu, nil];
    
    [Analytics normStructSell:userStruct.structId level:userStruct.level];
  }
}

- (void) retrieveFromNormStructure:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  Globals *gl = [Globals sharedGlobals];
  
  if (userStruct.userStructId == 0) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (userStruct.userId != gs.userId) {
    [Globals popupMessage:@"This is not your building!"];
  } else if (userStruct.isComplete && userStruct.lastRetrieved) {
    int64_t ms = [self getCurrentMilliseconds];
    int tag = [sc retrieveCurrencyFromStruct:userStruct.userStructId time:ms];
    userStruct.lastRetrieved = [NSDate dateWithTimeIntervalSince1970:ms/1000.0];
    
    // Update game state
    [gs addUnrespondedUpdate:[SilverUpdate updateWithTag:tag change:[gl calculateIncomeForUserStruct:userStruct]]];
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Building %d is not ready to be retrieved", userStruct.userStructId]];
  }
}

- (void) instaUpgrade:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  Globals *gl = [Globals sharedGlobals];
  
  int timeLeft = userStruct.lastUpgradeTime.timeIntervalSinceNow + [gl calculateMinutesToUpgrade:userStruct]*60;
  
  if (userStruct.userStructId == 0) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (userStruct.userId != gs.userId) {
    [Globals popupMessage:@"This is not your building!"];
  } else if (gs.gold < [gl calculateDiamondCostForInstaUpgrade:userStruct timeLeft:timeLeft]) {
    [Globals popupMessage:@"Not enough diamonds to speed up upgrade"];
  } else if (!userStruct.isComplete && userStruct.lastUpgradeTime) {
    int64_t ms = [self getCurrentMilliseconds];
    int tag = [sc sendFinishNormStructBuildWithDiamondsMessage:userStruct.userStructId time:[self getCurrentMilliseconds]];
    userStruct.isComplete = YES;
    userStruct.lastRetrieved = [NSDate dateWithTimeIntervalSince1970:ms/1000.0];
    userStruct.level++;
    
    // Update game state
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-[gl calculateDiamondCostForInstaUpgrade:userStruct timeLeft:timeLeft]]];
    
    [Analytics normStructInstaUpgrade:userStruct.structId level:userStruct.level];
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Building %d is not upgrading", userStruct.userStructId]];
  }
}

- (void) normStructWaitComplete:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:userStruct.structId];
  
  if (userStruct.userStructId == 0) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (userStruct.userId != gs.userId) {
    [Globals popupMessage:@"This is not your building!"];
  } else if (!userStruct.isComplete) {
    NSDate *date;
    if (userStruct.state == kBuilding) {
      date = [NSDate dateWithTimeInterval:fsp.minutesToUpgradeBase*60 sinceDate:userStruct.purchaseTime];
    } else if (userStruct.state == kUpgrading) {
      date = [NSDate dateWithTimeInterval:[gl calculateMinutesToUpgrade:userStruct]*60 sinceDate:userStruct.lastUpgradeTime];
    } else {
      [Globals popupMessage:@"Something went wrong, building should still be waiting"];
      return;
    }
    
    if ([date compare:[NSDate date]] == NSOrderedDescending) {
      [Globals popupMessage:@"Something went wrong, building should still be waiting"];
      return;
    }
    userStruct.lastRetrieved = date;
    userStruct.isComplete = YES;
    
    int64_t ms = [self getCurrentMilliseconds];
    int tag = [sc sendNormStructBuildsCompleteMessage:[NSArray arrayWithObject:[NSNumber numberWithInt:userStruct.userStructId]] time:ms];
    
    if (userStruct.lastUpgradeTime) {
      // Building was upgraded, not constructed
      userStruct.level++;
    }
    
    [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Building %d is not upgrading or constructing", userStruct.userStructId]];
  }
}

- (void) upgradeNormStruct:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  FullStructureProto *fsp = [gs structWithId:userStruct.structId];
  
  // Check that no other building is being upgraded
  for (UserStruct *us in gs.myStructs) {
    if (us.state == kUpgrading) {
      [Globals popupMessage:@"You can only upgrade one building at a time!"];
      return;
    }
  }
  
  if (userStruct.userStructId == 0) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (userStruct.userId != gs.userId) {
    [Globals popupMessage:@"This is not your building!"];
  } else if (userStruct.isComplete) {
    int cost = [[Globals sharedGlobals] calculateUpgradeCost:userStruct];
    BOOL isGoldBuilding = fsp.diamondPrice > 0;
    if (isGoldBuilding) {
      if (cost > gs.gold) {
        [Globals popupMessage:@"Trying to upgrade without enough gold"];
      } else {
        int64_t ms = [self getCurrentMilliseconds];
        int tag = [sc sendUpgradeNormStructureMessage:userStruct.userStructId time:ms];
        userStruct.isComplete = NO;
        userStruct.lastUpgradeTime = [NSDate dateWithTimeIntervalSince1970:ms/1000.0];\
        
        // Update game state
        [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-cost]];
        
        [Analytics normStructInstaUpgrade:userStruct.structId level:userStruct.level+1];
      }
    } else {
      if (cost > gs.silver) {
        [Globals popupMessage:@"Trying to upgrade without enough silver"];
      } else {
        int64_t ms = [self getCurrentMilliseconds];
        int tag = [sc sendUpgradeNormStructureMessage:userStruct.userStructId time:ms];
        userStruct.isComplete = NO;
        userStruct.lastUpgradeTime = [NSDate dateWithTimeIntervalSince1970:ms/1000.0];\
        
        // Update game state
        [gs addUnrespondedUpdate:[SilverUpdate updateWithTag:tag change:-cost]];
        
        [Analytics normStructInstaUpgrade:userStruct.structId level:userStruct.level+1];
      }
    }
    
  } else {
    [Globals popupMessage:@"This building is not upgradable"];
  }
}

- (void) retrieveAllStaticData {
  // First go through equips
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  BOOL shouldSend = NO;
  
  NSArray *structs = [gs myStructs];
  NSDictionary *sStructs = [gs staticStructs];
  NSMutableSet *rStructs = [NSMutableSet set];
  for (FullStructureProto *str in structs) {
    NSNumber *structId = [NSNumber numberWithInt:str.structId];
    if (![sStructs objectForKey:structId]) {
      [rStructs addObject:structId];
      shouldSend = YES;
    }
  }
  
  NSMutableSet *rTasks = [NSMutableSet set];
  NSDictionary *sTasks = [gs staticTasks];
  NSMutableSet *rBuildStructJobs = [NSMutableSet set];
  NSDictionary *sBuildStructJobs = [gs staticBuildStructJobs];
  NSMutableSet *rUpgradeStructJobs = [NSMutableSet set];
  NSDictionary *sUpgradeStructJobs = [gs staticUpgradeStructJobs];
  
  NSArray *questDictionaries = [NSArray arrayWithObjects:gs.availableQuests, gs.inProgressCompleteQuests, gs.inProgressIncompleteQuests, nil];
  for (NSDictionary *dict in questDictionaries) {
    for (FullQuestProto *fqp in [dict allValues]) {
      for (NSNumber *num in fqp.taskReqsList) {
        if (![sTasks objectForKey:num]) {
          [rTasks addObject:num];
        }
      }
      for (NSNumber *num in fqp.buildStructJobsReqsList) {
        if (![sBuildStructJobs objectForKey:num]) {
          [rBuildStructJobs addObject:num];
          shouldSend = YES;
        }
      }
      for (NSNumber *num in fqp.upgradeStructJobsReqsList) {
        if (![sUpgradeStructJobs objectForKey:num]) {
          [rUpgradeStructJobs addObject:num];
          shouldSend = YES;
        }
      }
    }
  }
  
  for (UpgradeStructJobProto *p in [gs.staticUpgradeStructJobs allValues]) {
    NSNumber *n = [NSNumber numberWithInt:p.structId];
    if (![sStructs objectForKey:n]) {
      [rStructs addObject:n];
      shouldSend = YES;
    }
  }
  
  for (BuildStructJobProto *p in [gs.staticBuildStructJobs allValues]) {
    NSNumber *n = [NSNumber numberWithInt:p.structId];
    if (![sStructs objectForKey:n]) {
      [rStructs addObject:n];
      shouldSend = YES;
    }
  }
  
  if (shouldSend) {
    int tag = [sc sendRetrieveStaticDataMessageWithStructIds:nil /*[rStructs allObjects]*/ taskIds:[rTasks allObjects] questIds:nil cityIds:nil buildStructJobIds:[rBuildStructJobs allObjects] defeatTypeJobIds:nil possessEquipJobIds:nil upgradeStructJobIds:[rUpgradeStructJobs allObjects] events:YES bossIds:nil];
    [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
  }
}

- (void) retrieveBoosterPacks {
  GameState *gs = [GameState sharedGameState];
  int tag = [[SocketCommunication sharedSocketCommunication] sendRetrieveBoosterPackMessage];
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

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
  
  // Load any tasks we don't have as well
  NSDictionary *sTasks = [gs staticTasks];
  NSMutableSet *rTasks = [NSMutableSet set];
  for (NSNumber *taskId in city.taskIdsList) {
    if (![sTasks objectForKey:taskId]) {
      [rTasks addObject:taskId];
    }
  }
  
  if (rTasks.count > 0) {
    [[SocketCommunication sharedSocketCommunication] sendRetrieveStaticDataMessageWithStructIds:nil taskIds:[rTasks allObjects] questIds:nil cityIds:nil buildStructJobIds:nil defeatTypeJobIds:nil possessEquipJobIds:nil upgradeStructJobIds:nil events:NO bossIds:nil];
  }
}

- (void) levelUp {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (gs.level >= gl.maxLevelForUser) {
    [Globals popupMessage:@"Trying to level up when already at maximum level."];
  } else if (gs.experience >= gs.expRequiredForNextLevel) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendLevelUpMessage];
    
    LevelUpdate *lu = [LevelUpdate updateWithTag:tag change:1];
    ExpForNextLevelUpdate *efnlu = [ExpForNextLevelUpdate updateWithTag:tag prevLevel:gs.expRequiredForCurrentLevel curLevel:gs.expRequiredForNextLevel nextLevel:10000000];
    [gs addUnrespondedUpdates:lu, efnlu, nil];
  } else {
    [Globals popupMessage:@"Trying to level up without enough experience"];
  }
}

- (void) acceptQuest:(int)questId {
  GameState *gs = [GameState sharedGameState];
  NSNumber *questIdNum = [NSNumber numberWithInt:questId];
  FullQuestProto *fqp = [gs.availableQuests objectForKey:questIdNum];
  
  if (fqp) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendQuestAcceptMessage:questId];
    [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
    
    [gs.availableQuests removeObjectForKey:questIdNum];
    [gs.inProgressIncompleteQuests setObject:fqp forKey:questIdNum];
    
    [Analytics questAccept:questId];
  } else {
    [Globals popupMessage:@"Attempting to accept unavailable quest"];
  }
}

- (void) redeemQuest:(int)questId {
  GameState *gs = [GameState sharedGameState];
  NSNumber *questIdNum = [NSNumber numberWithInt:questId];
  FullQuestProto *fqp = [gs.inProgressCompleteQuests objectForKey:questIdNum];
  
  if (fqp) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendQuestRedeemMessage:questId];
    
    [gs.inProgressCompleteQuests removeObjectForKey:questIdNum];
    SilverUpdate *su = [SilverUpdate updateWithTag:tag change:fqp.coinsGained];
    ExperienceUpdate *eu = [ExperienceUpdate updateWithTag:tag change:fqp.expGained];
    
    [gs addUnrespondedUpdates:su, eu, nil];
    
    [Analytics questRedeem:questId];
  } else {
    [Globals popupMessage:@"Attempting to redeem quest that is not in progress"];
  }
}

- (void) retrieveQuestLog {
  GameState *gs = [GameState sharedGameState];
  int tag = [[SocketCommunication sharedSocketCommunication] sendUserQuestDetailsMessage:0];
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) retrieveQuestDetails:(int)questId {
  if (questId == 0) {
    [Globals popupMessage:@"Attempting to retrieve information about quest 0"];
    return;
  }
  NSNumber *num = [NSNumber numberWithInt:questId];
  GameState *gs = [GameState sharedGameState];
  if ([gs.inProgressCompleteQuests.allKeys containsObject:num] || [gs.inProgressIncompleteQuests.allKeys containsObject:num]) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendUserQuestDetailsMessage:questId];
    [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
  } else {
    [Globals popupMessage:@"Attempting to retrieve information about un-accepted quest"];
  }
}

- (void) retrieveUsersForUserIds:(NSArray *)userIds {
  GameState *gs = [GameState sharedGameState];
  int tag = [[SocketCommunication sharedSocketCommunication] sendRetrieveUsersForUserIds:[[NSSet setWithArray:userIds] allObjects]];
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) inAppPurchase:(NSString *)receipt goldAmt:(int)gold silverAmt:(int)silver product:(SKProduct *)product {
  GameState *gs = [GameState sharedGameState];
  if (gs.connected) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendInAppPurchaseMessage:receipt product:product];
    [[GameState sharedGameState] addUnrespondedUpdates:[GoldUpdate updateWithTag:tag change:gold], [SilverUpdate updateWithTag:tag change:silver], nil];
    
    if ([product.productIdentifier rangeOfString:@"bsale"].length > 0) {
      gs.numBeginnerSalesPurchased++;
    }
  }
  
  NSString *key = IAP_DEFAULTS_KEY;
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *arr = [defaults arrayForKey:key];
  NSMutableArray *mut = arr ? [arr mutableCopy] : [NSMutableArray array];
  [mut addObject:receipt];
  [defaults setObject:mut forKey:IAP_DEFAULTS_KEY];
  [defaults synchronize];
}

- (void) enableApns:(NSData *)deviceToken {
  GameState *gs = [GameState sharedGameState];
  
  NSString *str = nil;
  if (deviceToken) {
    str = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
  }
  
  gs.deviceToken = str;
  
  while (gs.userId == 0) {
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.f]];
    
    if (gs.isTutorial) {
      return;
    }
  }
  
  int tag = [[SocketCommunication sharedSocketCommunication] sendAPNSMessage:str];
  
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) fbConnectReward {
  GameState *gs = [GameState sharedGameState];
  int i = 0;
  while (gs.userId == 0) {
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.f]];
    
    i++;
    if (gs.isTutorial || i > 30) {
      return;
    }
  }
  
  if (!gs.hasReceivedfbReward) {
    [[SocketCommunication sharedSocketCommunication] sendEarnFreeDiamondsFBConnectMessageClientTime:[self getCurrentMilliseconds]];
  }
}

- (void) retrieveTournamentRanking:(int)eventId afterRank:(int)afterRank {
  [[SocketCommunication sharedSocketCommunication] sendRetrieveTournamentRankingsMessage:eventId afterThisRank:afterRank];
}

- (void) sendGroupChat:(GroupChatScope)scope message:(NSString *)msg {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (msg.length > gl.maxLengthOfChatString) {
    [Globals popupMessage:@"Attempting to send msg that exceeds appropriate length"];
  } else {
    NSRange r = [msg rangeOfString:CODE_PREFIX];
    if (r.length > 0) {
      NSString *code = [msg stringByReplacingCharactersInRange:r withString:@""];
      if ([code isEqualToString:PURGE_CODE]) {
        [[Downloader sharedDownloader] purgeAllDownloadedData];
        msg = @"All downloaded data has been purged.";
      } else {
        msg = @"Unaccepted code.";
      }
    } else {
      [[SocketCommunication sharedSocketCommunication] sendGroupChatMessage:scope message:msg clientTime:[self getCurrentMilliseconds]];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.35f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
      [gs addChatMessage:gs.minUser message:msg scope:scope isAdmin:(scope == GroupChatScopeGlobal ? gs.isAdmin : NO)];
    });
    //  } else {
    //    [Globals popupMessage:@"Attempting to send chat without any speakers"];
    //  }
  }
}

- (void) createClan:(NSString *)clanName tag:(NSString *)clanTag description:(NSString *)description requestOnly:(BOOL)requestOnly delegate:(id)delegate {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  
  if (clanName.length <= 0 || clanName.length > gl.maxCharLengthForClanName) {
    [Globals popupMessage:@"Attempting to create clan with inappropriate clan name length."];
  } else if (clanTag.length <= 0 || clanTag.length > gl.maxCharLengthForClanTag) {
    [Globals popupMessage:@"Attempting to create clan with inappropriate clan tag length."];
  } else if (gs.gold < gl.diamondPriceToCreateClan) {
    [Globals popupMessage:@"Attempting to create clan without enough gold."];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendCreateClanMessage:clanName tag:clanTag description:description requestOnly:requestOnly];
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-gl.diamondPriceToCreateClan]];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
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
    [Globals popupMessage:@"Attempting to request to join clan while in a clan."];
  } else if ([gs.requestedClans containsObject:[NSNumber numberWithInt:clanId]]) {
    [Globals popupMessage:@"Attempting to send multiple requests to join clan."];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendRequestJoinClanMessage:clanId];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  }
}

- (void) retractRequestToJoinClan:(int)clanId delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  
  if (gs.clan) {
    [Globals popupMessage:@"Attempting to retract clan request while in a clan."];
  } else if (![gs.requestedClans containsObject:[NSNumber numberWithInt:clanId]]) {
    [Globals popupMessage:@"Attempting to retract invalid clan request."];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendRetractRequestJoinClanMessage:clanId];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  }
}

- (void) approveOrRejectRequestToJoinClan:(int)requesterId accept:(BOOL)accept delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  
  if (!gs.clan || gs.clan.ownerId != gs.userId) {
    [Globals popupMessage:@"Attempting to respond to clan request while not clan leader."];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendApproveOrRejectRequestToJoinClan:requesterId accept:accept];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  }
}

- (void) transferClanOwnership:(int)newClanOwnerId delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  
  if (!gs.clan || gs.clan.ownerId != gs.userId) {
    [Globals popupMessage:@"Attempting to transfer clan ownership while not clan leader."];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendTransferClanOwnership:newClanOwnerId];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  }
}

- (void) changeClanDescription:(NSString *)description delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (!gs.clan || gs.clan.ownerId != gs.userId) {
    [Globals popupMessage:@"Attempting to change clan description while not clan leader."];
  } else if (description.length <= 0 || description.length > gl.maxCharLengthForClanDescription) {
    [Globals popupMessage:@"Attempting to change clan description with inappropriate length"];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendChangeClanDescription:description];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  }
}

- (void) changeClanJoinType:(BOOL)requestRequired delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  
  if (!gs.clan || gs.clan.ownerId != gs.userId) {
    [Globals popupMessage:@"Attempting to change clan join type while not clan leader."];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendChangeClanJoinType:requestRequired];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  }
}

- (void) bootPlayerFromClan:(int)playerId delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  
  if (!gs.clan || gs.clan.ownerId != gs.userId) {
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

- (void) purchaseCityExpansionAtX:(int)x atY:(int)y {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int silverCost = [gl calculateSilverCostForNewExpansion];
  if (gs.silver < silverCost) {
    [Globals popupMessage:@"Attempting to expand without enough silver"];
  } else if (gs.isExpanding) {
    [Globals popupMessage:@"Attempting to expand while already expanding"];
  } else {
    uint64_t ms = [self getCurrentMilliseconds];
    int tag = [[SocketCommunication sharedSocketCommunication] sendPurchaseCityExpansionMessageAtX:x atY:y timeOfPurchase:ms];
    [gs addUnrespondedUpdate:[SilverUpdate updateWithTag:tag change:-silverCost]];
    
    UserExpansion *ue = [[UserExpansion alloc] init];
    ue.userId = gs.userId;
    ue.isExpanding = YES;
    ue.xPosition = x;
    ue.yPosition = y;
    ue.lastExpandTime = [NSDate dateWithTimeIntervalSince1970:ms/1000.0];
    [gs.userExpansions addObject:ue];
    
    [gs beginExpansionTimer];
  }
}

- (void) expansionWaitComplete:(BOOL)speedUp atX:(int)x atY:(int)y {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserExpansion *ue = [gs getExpansionForX:x y:y];
  
  int timeLeft = ue.lastExpandTime.timeIntervalSinceNow + [gl calculateNumMinutesForNewExpansion]*60;
  int goldCost = speedUp ? [gl calculateGoldCostToSpeedUpExpansionTimeLeft:timeLeft] : 0;
  if (gs.gold < goldCost) {
    [Globals popupMessage:@"Attempting to speedup without enough gold"];
  } else if (!ue.isExpanding) {
    [Globals popupMessage:@"Attempting to complete expansion while not expanding"];
  } else if (!speedUp && [[NSDate date] compare:[ue.lastExpandTime dateByAddingTimeInterval:[gl calculateNumMinutesForNewExpansion]*60]] == NSOrderedAscending) {
    [Globals popupMessage:@"Attempting to complete expansion before it is ready"];
  } else {
    uint64_t ms = [self getCurrentMilliseconds];
    int tag = [[SocketCommunication sharedSocketCommunication] sendExpansionWaitCompleteMessage:speedUp curTime:ms atX:x atY:y];
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-goldCost]];
    
    ue.isExpanding = NO;
    
    [gs stopExpansionTimer];
  }
}

- (void) submitMonsterEnhancement:(int)enhancingId feeders:(NSArray *)feeders {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *userMonsters = [NSMutableArray array];
  Globals *gl = [Globals sharedGlobals];
  UserMonster *um = [gs myMonsterWithUserMonsterId:enhancingId];
  int silverCost = 0;
  
  if (feeders.count <= 0) {
    [Globals popupMessage:@"Attempting to submit enhancement without any feeder monsters."];
  } else {
    if (um) {
      for (NSNumber *n in feeders) {
        UserMonster *m = nil;//[gs myEquipWithUserEquipId:n.intValue];
        if (m) {
          [userMonsters addObject:m];
        } else {
          [Globals popupMessage:@"One or more monsters cannot be found."];
          return;
        }
      }
      
      silverCost = [gl calculateSilverCostForEnhancement:um feeders:userMonsters];
      if (gs.silver < silverCost) {
        [Globals popupMessage:@"Attempting to submit monster enhancement without enough silver"];
        return;
      }
      
      [userMonsters addObject:um];
      
      if (userMonsters.count != feeders.count+1) {
        [Globals popupMessage:@"Attempting to enhance with a repeated equip."];
        return;
      }
    } else {
      [Globals popupMessage:@"One or more equips cannot be found."];
      return;
    }
    
    int tag = [[SocketCommunication sharedSocketCommunication] sendSubmitMonsterEnhancementMessage:enhancingId feeders:feeders clientTime:[self getCurrentMilliseconds]];
    [gs addUnrespondedUpdate:[SilverUpdate updateWithTag:tag change:-silverCost]];
  }
}

- (void) purchaseBoosterPack:(int)boosterPackId {
  GameState *gs = [GameState sharedGameState];
  BoosterPackProto *bpp = [gs boosterPackForId:boosterPackId];
  if (!bpp) {
    [Globals popupMessage:@"Unable to find booster pack."];
  } else {
    FullUserUpdate *u = nil;
    int tag = [[SocketCommunication sharedSocketCommunication] sendPurchaseBoosterPackMessage:boosterPackId clientTime:[self getCurrentMilliseconds]];
    
    int price = bpp.price;
    
    if (bpp.costsCoins) {
      u = [SilverUpdate updateWithTag:tag change:-price];
    } else {
      u = [GoldUpdate updateWithTag:tag change:-price];
    }
    [gs addUnrespondedUpdate:u];
  }
}

- (void) privateChatPost:(int)recipientId content:(NSString *)content {
  [[SocketCommunication sharedSocketCommunication] sendPrivateChatPostMessage:recipientId content:content];
}

- (void) retrievePrivateChatPosts:(int)otherUserId {
  [[SocketCommunication sharedSocketCommunication] sendRetrievePrivateChatPostsMessage:otherUserId];
}

- (void) beginDungeon:(int)taskId {
  [[SocketCommunication sharedSocketCommunication] sendBeginDungeonMessage:[self getCurrentMilliseconds] taskId:taskId];
}

@end
