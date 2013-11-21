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
  if (gs.connected && gs.userUuid) {
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
  
  int gemsPrice = fsp.isPremiumCurrency ? fsp.buildPrice : 0;
  int cashPrice = fsp.isPremiumCurrency ? 0 : fsp.buildPrice;
  if (gs.cash >= cashPrice && gs.gems >= gemsPrice) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendPurchaseNormStructureMessage:structId x:x y:y time:[self getCurrentMilliseconds]];
    us = [[UserStruct alloc] init];
    
    // UserStructId will come in the response
    us.userUuid = [[GameState sharedGameState] userUuid];
    us.structId = structId;
    us.isComplete = NO;
    us.coordinates = CGPointMake(x, y);
    us.orientation = 0;
    us.purchaseTime = [NSDate date];
    us.lastRetrieved = nil;
    
    AddStructUpdate *asu = [AddStructUpdate updateWithTag:tag userStruct:us];
    CashUpdate *su = [CashUpdate updateWithTag:tag change:-cashPrice];
    GemUpdate *gu = [GemUpdate updateWithTag:tag change:-gemsPrice];
    [gs addUnrespondedUpdates:asu, su, gu, nil];
  } else {
    [Globals popupMessage:@"Not enough money to purchase this building"];
  }
  return us;
}

- (void) moveNormStruct:(UserStruct *)userStruct atX:(int)x atY:(int)y {
  CGPoint newCoord = CGPointMake(x, y);
  if (!CGPointEqualToPoint(userStruct.coordinates, newCoord)) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendMoveNormStructureMessage:userStruct.userStructUuid x:x y:y];
    userStruct.coordinates = CGPointMake(x, y);
    
    [[GameState sharedGameState] addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
  }
}

- (void) rotateNormStruct:(UserStruct *)userStruct to:(StructOrientation)orientation {
  if (userStruct.orientation != orientation) {
    [[SocketCommunication sharedSocketCommunication] sendRotateNormStructureMessage:userStruct.userStructUuid orientation:orientation];
    userStruct.orientation = orientation;
  }
}

- (void) sellNormStruct:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  FullStructureProto *fsp = userStruct.fsp;
  
  if (!userStruct.userStructUuid) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (![userStruct.userUuid isEqualToString:gs.userUuid]) {
    [Globals popupMessage:@"This is not your building!"];
  } else {
    int tag = [sc sendSellNormStructureMessage:userStruct.userStructUuid];
    
    SellStructUpdate *ssu = [SellStructUpdate updateWithTag:tag userStruct:userStruct];
    CashUpdate *su = [CashUpdate updateWithTag:tag change:fsp.isPremiumCurrency ? 0 : fsp.sellPrice];
    GemUpdate *gu = [GemUpdate updateWithTag:tag change:fsp.isPremiumCurrency ? fsp.sellPrice : 0];
    
    [gs addUnrespondedUpdates:ssu, su, gu, nil];
  }
}

- (void) retrieveFromNormStructure:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (!userStruct.userStructUuid) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (![userStruct.userUuid isEqualToString:gs.userUuid]) {
    [Globals popupMessage:@"This is not your building!"];
  } else if (userStruct.isComplete && userStruct.lastRetrieved) {
    int64_t ms = [self getCurrentMilliseconds];
    int tag = [sc retrieveCurrencyFromStruct:userStruct.userStructUuid time:ms];
    userStruct.lastRetrieved = [NSDate dateWithTimeIntervalSince1970:ms/1000.0];
    
    // Update game state
    [gs addUnrespondedUpdate:[CashUpdate updateWithTag:tag change:userStruct.fsp.income]];
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Building %@ is not ready to be retrieved", userStruct.userStructUuid]];
  }
}

- (void) instaUpgrade:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  Globals *gl = [Globals sharedGlobals];
  
  int timeLeft = userStruct.timeLeftForBuildComplete;
  
  int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
  if (!userStruct.userStructUuid) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (![userStruct.userUuid isEqualToString:gs.userUuid]) {
    [Globals popupMessage:@"This is not your building!"];
  } else if (gs.gems < gemCost) {
    [Globals popupMessage:@"Not enough diamonds to speed up upgrade"];
  } else if (!userStruct.isComplete) {
    int64_t ms = [self getCurrentMilliseconds];
    int tag = [sc sendFinishNormStructBuildWithDiamondsMessage:userStruct.userStructUuid gemCost:gemCost time:[self getCurrentMilliseconds]];
    userStruct.isComplete = YES;
    userStruct.lastRetrieved = [NSDate dateWithTimeIntervalSince1970:ms/1000.0];
    
    // Update game state
    [gs addUnrespondedUpdate:[GemUpdate updateWithTag:tag change:-[gl calculateGemSpeedupCostForTimeLeft:timeLeft]]];
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Building %@ is not upgrading", userStruct.userStructUuid]];
  }
}

- (void) normStructWaitComplete:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (!userStruct.userStructUuid) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (![userStruct.userUuid isEqualToString:gs.userUuid]) {
    [Globals popupMessage:@"This is not your building!"];
  } else if (!userStruct.isComplete) {
    NSDate *date = userStruct.buildCompleteDate;
    
    if ([date compare:[NSDate date]] == NSOrderedDescending) {
      [Globals popupMessage:@"Something went wrong, building should still be waiting"];
      return;
    }
    userStruct.lastRetrieved = date;
    userStruct.isComplete = YES;
    
    int64_t ms = [self getCurrentMilliseconds];
    int tag = [sc sendNormStructBuildsCompleteMessage:[NSArray arrayWithObject:userStruct.userStructUuid] time:ms];
    
    [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Building %@ is not upgrading or constructing", userStruct.userStructUuid]];
  }
}

- (void) upgradeNormStruct:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  FullStructureProto *nextFsp = userStruct.fspForNextLevel;
  
  // Check that no other building is being upgraded
  for (UserStruct *us in gs.myStructs) {
    if (us.state == kBuilding) {
      [Globals popupMessage:@"You can only construct one building at a time!"];
      return;
    }
  }
  
  if (!userStruct.userStructUuid) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (![userStruct.userUuid isEqualToString:gs.userUuid]) {
    [Globals popupMessage:@"This is not your building!"];
  } else if (!nextFsp) {
    [Globals popupMessage:@"This building is not upgradable"];
  } else {
    int gemCost = nextFsp.isPremiumCurrency ? nextFsp.buildPrice : 0;
    int cashCost = nextFsp.isPremiumCurrency ? 0 : nextFsp.buildPrice;
    if (gemCost > gs.gems || cashCost > gs.cash) {
      [Globals popupMessage:@"Trying to upgrade without enough resources."];
    } else {
      int64_t ms = [self getCurrentMilliseconds];
      int tag = [sc sendUpgradeNormStructureMessage:userStruct.userStructUuid time:ms];
      userStruct.isComplete = NO;
      userStruct.purchaseTime = [NSDate dateWithTimeIntervalSince1970:ms/1000.0];
      userStruct.structId = nextFsp.structId;
      
      // Update game state
      CashUpdate *su = [CashUpdate updateWithTag:tag change:-cashCost];
      GemUpdate *gu = [GemUpdate updateWithTag:tag change:-gemCost];
      [gs addUnrespondedUpdates:su, gu, nil];
    }
  }
}

- (void) loadPlayerCity:(NSString *)userUuid withDelegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  
  int tag = [[SocketCommunication sharedSocketCommunication] sendLoadPlayerCityMessage:userUuid];
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
}

- (void) loadNeutralCity:(int)cityId withDelegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  FullCityProto *city = [gs cityWithId:cityId];
  
  int tag = [[SocketCommunication sharedSocketCommunication] sendLoadCityMessage:city.cityId];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
}

- (void) levelUp {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (gs.level >= gl.maxLevelForUser) {
    [Globals popupMessage:@"Trying to level up when already at maximum level."];
  } else if (gs.experience >= [gs expNeededForLevel:gs.level+1]) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendLevelUpMessage];
    
    LevelUpdate *lu = [LevelUpdate updateWithTag:tag change:1];
    [gs addUnrespondedUpdate:lu];
  } else {
    [Globals popupMessage:@"Trying to level up without enough experience"];
  }
}

- (UserQuest *) acceptQuest:(int)questId {
  GameState *gs = [GameState sharedGameState];
  NSNumber *questIdNum = [NSNumber numberWithInt:questId];
  QuestProto *fqp = [gs.availableQuests objectForKey:questIdNum];
  
  if (fqp) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendQuestAcceptMessage:questId];
    [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
    
    [gs.availableQuests removeObjectForKey:questIdNum];
    [gs.inProgressIncompleteQuests setObject:fqp forKey:questIdNum];
    
    UserQuest *uq = [[UserQuest alloc] init];
    uq.userUuid = gs.userUuid;
    uq.questId = questId;
    uq.progress = 0;
    [gs addToMyQuests:[NSArray arrayWithObject:uq]];
    
    return uq;
  } else {
    [Globals popupMessage:@"Attempting to accept unavailable quest"];
  }
  return nil;
}

- (void) questProgress:(int)questId {
  GameState *gs = [GameState sharedGameState];
  UserQuest *uq = [gs myQuestWithId:questId];
  
  if (uq) {
    [[SocketCommunication sharedSocketCommunication] sendQuestProgressMessage:questId progress:uq.progress isComplete:uq.isComplete userMonsterUuids:nil];
    
    if (uq.isComplete) {
      NSNumber *questIdNum = [NSNumber numberWithInt:questId];
      QuestProto *fqp = [gs.inProgressIncompleteQuests objectForKey:questIdNum];
      if (fqp) {
        [gs.inProgressIncompleteQuests removeObjectForKey:questIdNum];
        [gs.inProgressCompleteQuests setObject:fqp forKey:questIdNum];
      }
    }
  } else {
    [Globals popupMessage:@"Attempting to progress nonexistant quest"];
  }
}

- (UserQuest *) donateForQuest:(int)questId monsterUuids:(NSArray *)monsterUuids {
  GameState *gs = [GameState sharedGameState];
  UserQuest *uq = [gs myQuestWithId:questId];
  QuestProto *fqp = [gs questForId:uq.questId];
  
  if (monsterUuids.count < fqp.quantity) {
    [Globals popupMessage:@"Attempting to donate without enough of monster."];
  }
  if (uq) {
    for (NSString *umUuid in monsterUuids) {
      UserMonster *um = [gs myMonsterWithUserMonsterUuid:umUuid];
      if (um && um.isComplete) {
        [gs.myMonsters removeObject:um];
      } else {
        [Globals popupMessage:@"One of the monsters can not be found."];
        return nil;
      }
    }
    
    uq.isComplete = YES;
    
    NSNumber *questIdNum = [NSNumber numberWithInt:questId];
    QuestProto *fqp = [gs.inProgressIncompleteQuests objectForKey:questIdNum];
    if (fqp) {
      [gs.inProgressIncompleteQuests removeObjectForKey:questIdNum];
      [gs.inProgressCompleteQuests setObject:fqp forKey:questIdNum];
    }
    
    [[SocketCommunication sharedSocketCommunication] sendQuestProgressMessage:questId progress:uq.progress isComplete:uq.isComplete userMonsterUuids:monsterUuids];
    return uq;
  } else {
    [Globals popupMessage:@"Attempting to donate for quest"];
  }
  
  return nil;
}

- (void) redeemQuest:(int)questId delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  NSNumber *questIdNum = [NSNumber numberWithInt:questId];
  QuestProto *fqp = [gs.inProgressCompleteQuests objectForKey:questIdNum];
  
  if (fqp) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendQuestRedeemMessage:questId];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
    
    [gs.inProgressCompleteQuests removeObjectForKey:questIdNum];
    CashUpdate *su = [CashUpdate updateWithTag:tag change:fqp.cashReward];
    GemUpdate *gu = [GemUpdate updateWithTag:tag change:fqp.gemReward];
    ExperienceUpdate *eu = [ExperienceUpdate updateWithTag:tag change:fqp.expReward];
    
    [gs addUnrespondedUpdates:su, gu, eu, nil];
  } else {
    [Globals popupMessage:@"Attempting to redeem quest that is not in progress"];
  }
}

- (void) retrieveUsersForUserUuids:(NSArray *)userUuids includeCurMonsterTeam:(BOOL)includeCurMonsterTeam delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  int tag = [[SocketCommunication sharedSocketCommunication] sendRetrieveUsersForUserUuids:[[NSSet setWithArray:userUuids] allObjects] includeCurMonsterTeam:includeCurMonsterTeam];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) inAppPurchase:(NSString *)receipt goldAmt:(int)gold cashAmt:(int)cash product:(SKProduct *)product {
  GameState *gs = [GameState sharedGameState];
  if (gs.connected) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendInAppPurchaseMessage:receipt product:product];
    [[GameState sharedGameState] addUnrespondedUpdates:[GemUpdate updateWithTag:tag change:gold], [CashUpdate updateWithTag:tag change:cash], nil];
    
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
  
  while (!gs.userUuid || !gs.connected) {
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
      [gs addChatMessage:gs.minUserWithLevel message:msg scope:scope isAdmin:(scope == GroupChatScopeGlobal ? gs.isAdmin : NO)];
    });
  }
}

- (void) createClan:(NSString *)clanName tag:(NSString *)clanTag description:(NSString *)description requestOnly:(BOOL)requestOnly delegate:(id)delegate {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  
  if (clanName.length <= 0 || clanName.length > gl.maxCharLengthForClanName) {
    [Globals popupMessage:@"Attempting to create clan with inappropriate clan name length."];
  } else if (clanTag.length <= 0 || clanTag.length > gl.maxCharLengthForClanTag) {
    [Globals popupMessage:@"Attempting to create clan with inappropriate clan tag length."];
  } else if (gs.gems < gl.cashPriceToCreateClan) {
    [Globals popupMessage:@"Attempting to create clan without enough gold."];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendCreateClanMessage:clanName tag:clanTag description:description requestOnly:requestOnly];
    [gs addUnrespondedUpdate:[CashUpdate updateWithTag:tag change:-gl.cashPriceToCreateClan]];
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

- (void) requestJoinClan:(NSString *)clanUuid delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  
  if (gs.clan) {
    [Globals popupMessage:@"Attempting to request to join clan while in a clan."];
  } else if ([gs.requestedClans containsObject:clanUuid]) {
    [Globals popupMessage:@"Attempting to send multiple requests to join clan."];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendRequestJoinClanMessage:clanUuid];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  }
}

- (void) retractRequestToJoinClan:(NSString *)clanUuid delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  
  if (gs.clan) {
    [Globals popupMessage:@"Attempting to retract clan request while in a clan."];
  } else if (![gs.requestedClans containsObject:clanUuid]) {
    [Globals popupMessage:@"Attempting to retract invalid clan request."];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendRetractRequestJoinClanMessage:clanUuid];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  }
}

- (void) approveOrRejectRequestToJoinClan:(NSString *)requesterUuid accept:(BOOL)accept delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  
  if (!gs.clan || ![gs.clan.ownerUuid isEqualToString:gs.userUuid]) {
    [Globals popupMessage:@"Attempting to respond to clan request while not clan leader."];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendApproveOrRejectRequestToJoinClan:requesterUuid accept:accept];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  }
}

- (void) transferClanOwnership:(NSString *)newClanOwnerUuid delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  
  if (!gs.clan || ![gs.clan.ownerUuid isEqualToString:gs.userUuid]) {
    [Globals popupMessage:@"Attempting to transfer clan ownership while not clan leader."];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendTransferClanOwnership:newClanOwnerUuid];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  }
}

- (void) changeClanDescription:(NSString *)description delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (!gs.clan || ![gs.clan.ownerUuid isEqualToString:gs.userUuid]) {
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
  
  if (!gs.clan || ![gs.clan.ownerUuid isEqualToString:gs.userUuid]) {
    [Globals popupMessage:@"Attempting to change clan join type while not clan leader."];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendChangeClanJoinType:requestRequired];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  }
}

- (void) bootPlayerFromClan:(NSString *)playerUuid delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  
  if (!gs.clan || ![gs.clan.ownerUuid isEqualToString:gs.userUuid]) {
    [Globals popupMessage:@"Attempting to boot player while not clan leader."];
  } else {
    // Make sure clan is not engaged in a clan tower war
    int tag = [[SocketCommunication sharedSocketCommunication] sendBootPlayerFromClan:playerUuid];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  }
}

- (void) retrieveClanInfo:(NSString *)clanName clanUuid:(NSString *)clanUuid grabType:(RetrieveClanInfoRequestProto_ClanInfoGrabType)grabType isForBrowsingList:(BOOL)isForBrowsingList delegate:(id)delegate {
  int tag = [[SocketCommunication sharedSocketCommunication] sendRetrieveClanInfoMessage:clanName clanUuid:clanUuid grabType:grabType isForBrowsingList:isForBrowsingList];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  
  GameState *gs = [GameState sharedGameState];
  [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
}

- (void) purchaseCityExpansionAtX:(int)x atY:(int)y {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int cashCost = [gl calculateCashCostForNewExpansion];
  if (gs.cash < cashCost) {
    [Globals popupMessage:@"Attempting to expand without enough cash"];
  } else if (gs.isExpanding) {
    [Globals popupMessage:@"Attempting to expand while already expanding"];
  } else {
    uint64_t ms = [self getCurrentMilliseconds];
    int tag = [[SocketCommunication sharedSocketCommunication] sendPurchaseCityExpansionMessageAtX:x atY:y timeOfPurchase:ms];
    [gs addUnrespondedUpdate:[CashUpdate updateWithTag:tag change:-cashCost]];
    
    UserExpansion *ue = [[UserExpansion alloc] init];
    ue.userUuid = gs.userUuid;
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
  int gemCost = speedUp ? [gl calculateGemSpeedupCostForTimeLeft:timeLeft] : 0;
  if (gs.gems < gemCost) {
    [Globals popupMessage:@"Attempting to speedup without enough gold"];
  } else if (!ue.isExpanding) {
    [Globals popupMessage:@"Attempting to complete expansion while not expanding"];
  } else if (!speedUp && [[NSDate date] compare:[ue.lastExpandTime dateByAddingTimeInterval:[gl calculateNumMinutesForNewExpansion]*60]] == NSOrderedAscending) {
    [Globals popupMessage:@"Attempting to complete expansion before it is ready"];
  } else {
    uint64_t ms = [self getCurrentMilliseconds];
    int tag = [[SocketCommunication sharedSocketCommunication] sendExpansionWaitCompleteMessage:speedUp gemCost:gemCost curTime:ms atX:x atY:y];
    [gs addUnrespondedUpdate:[GemUpdate updateWithTag:tag change:-gemCost]];
    
    ue.isExpanding = NO;
    
    [gs stopExpansionTimer];
  }
}

- (void) purchaseBoosterPack:(int)boosterPackId delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  BoosterPackProto *bpp = [gs boosterPackForId:boosterPackId];
  if (!bpp) {
    [Globals popupMessage:@"Unable to find booster pack."];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendPurchaseBoosterPackMessage:boosterPackId clientTime:[self getCurrentMilliseconds]];
    [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
    [gs addUnrespondedUpdate:[GemUpdate updateWithTag:tag change:-bpp.gemPrice]];
  }
}

- (void) privateChatPost:(NSString *)recipientUuid content:(NSString *)content {
  GameState *gs = [GameState sharedGameState];
  if ([recipientUuid isEqualToString:gs.userUuid]) {
    [Globals popupMessage:@"You are not allowed to send private chats to yourself."];
  } else {
    [[SocketCommunication sharedSocketCommunication] sendPrivateChatPostMessage:recipientUuid content:content];
  }
}

- (void) retrievePrivateChatPosts:(NSString *)otherUserUuid delegate:(id)delegate {
  int tag = [[SocketCommunication sharedSocketCommunication] sendRetrievePrivateChatPostsMessage:otherUserUuid];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
}

- (void) beginDungeon:(int)taskId withDelegate:(id)delegate {
  int tag = [[SocketCommunication sharedSocketCommunication] sendBeginDungeonMessage:[self getCurrentMilliseconds] taskId:taskId];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
}

- (void) updateMonsterHealth:(NSString *)userMonsterUuid curHealth:(int)curHealth {
  if (userMonsterUuid) {
    [Globals popupMessage:@"Trying to update invalid user monster"];
  } else if (curHealth < 0) {
    [Globals popupMessage:@"Trying to set health less than 0"];
  } else {
    GameState *gs = [GameState sharedGameState];
    UserMonster *userMonster = [gs myMonsterWithUserMonsterUuid:userMonsterUuid];
    
    if (!userMonster) {
      [Globals popupMessage:@"Trying to update monster health for invalid monster"];
    } else {
      userMonster.curHealth = curHealth;
      UserMonsterCurrentHealthProto *m = [[[[UserMonsterCurrentHealthProto builder]
                                            setCurrentHealth:userMonster.curHealth]
                                           setUserMonsterUuid:userMonster.userMonsterUuid]
                                          build];
      [[SocketCommunication sharedSocketCommunication] sendUpdateMonsterHealthMessage:[self getCurrentMilliseconds] monsterHealth:m];
    }
  }
}

- (void) endDungeon:(BeginDungeonResponseProto *)dungeonInfo userWon:(BOOL)userWon delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  BOOL isFirstTime = ![gs.completedTasks containsObject:@(dungeonInfo.taskId)];
  int tag = [[SocketCommunication sharedSocketCommunication] sendEndDungeonMessage:dungeonInfo.userTaskUuid userWon:userWon isFirstTimeCompleted:isFirstTime time:[self getCurrentMilliseconds]];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  
  if (userWon) {
    int cashAmount = 0, expAmount = 0;
    for (TaskStageProto *tsp in dungeonInfo.tspList) {
      for (TaskStageMonsterProto *tsm in tsp.stageMonstersList) {
        cashAmount += tsm.cashReward;
        expAmount += tsm.expReward;
      }
    }
    
    CashUpdate *su = [CashUpdate updateWithTag:tag change:cashAmount];
    ExperienceUpdate *eu = [ExperienceUpdate updateWithTag:tag change:expAmount];
    [gs addUnrespondedUpdates: su, eu, nil];
  }
}

- (BOOL) removeMonsterFromTeam:(NSString *)userMonsterUuid {
  GameState *gs = [GameState sharedGameState];
  UserMonster *um = [gs myMonsterWithUserMonsterUuid:userMonsterUuid];
  
  if (!um || !um.teamSlot) {
    [Globals popupMessage:@"Trying to remove invalid monster."];
  } else {
    um.teamSlot = 0;
    
    [[SocketCommunication sharedSocketCommunication] sendRemoveMonsterFromTeam:userMonsterUuid];
    return YES;
  }
  return NO;
}

- (BOOL) addMonsterToTeam:(NSString *)userMonsterUuid {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  UserMonster *um = [gs myMonsterWithUserMonsterUuid:userMonsterUuid];
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
          if ([m isHealing] || [m isEnhancing] || [m isSacrificing]) {
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
      
      [[SocketCommunication sharedSocketCommunication] sendAddMonsterToTeam:userMonsterUuid teamSlot:teamSlot];
      return YES;
    } else {
      [Globals popupMessage:@"Team is already at max size!"];
    }
  }
  return NO;
}

- (void) buyInventorySlots {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (gs.gems < gl.inventoryIncreaseSizeCost) {
    [Globals popupMessage:@"Trying to increase inventory without enough gold"];
  } else {
    gs.numAdditionalMonsterSlots += gl.inventoryIncreaseSizeAmount;
    int tag = [[SocketCommunication sharedSocketCommunication] buyInventorySlots];
    [gs addUnrespondedUpdate:[GemUpdate updateWithTag:tag change:-gl.inventoryIncreaseSizeCost]];
  }
}

- (void) inviteAllFacebookFriends:(NSArray *)fbFriends {
  [[SocketCommunication sharedSocketCommunication] sendInviteFbFriendsForSlotsMessage:fbFriends];
}

- (void) acceptAndRejectInvitesWithAcceptUuids:(NSArray *)acceptUuids rejectUuids:(NSArray *)rejectUuids {
  [[SocketCommunication sharedSocketCommunication] sendAcceptAndRejectFbInviteForSlotsMessageAndAcceptUuids:acceptUuids rejectUuids:rejectUuids];
}

- (void) combineMonsters:(NSArray *)userMonsterUuids {
  GameState *gs = [GameState sharedGameState];
  for (NSString *umUuid in userMonsterUuids) {
    UserMonster *um = [gs myMonsterWithUserMonsterUuid:umUuid];
    um.isComplete = YES;
  }
  [[SocketCommunication sharedSocketCommunication] sendCombineUserMonsterPiecesMessage:userMonsterUuids gemCost:0];
}

- (BOOL) combineMonsterWithSpeedup:(NSString *)userMonsterUuid {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserMonster *um = [gs myMonsterWithUserMonsterUuid:userMonsterUuid];
  int timeLeft = um.timeLeftForCombining;
  int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
  
  if (gs.gems < goldCost) {
    [Globals popupMessage:@"Trying to speedup combine monster without enough gems"];
  } else {
    um.isComplete = YES;
    
    int tag = [[SocketCommunication sharedSocketCommunication] sendCombineUserMonsterPiecesMessage:[NSArray arrayWithObject:userMonsterUuid] gemCost:goldCost];
    [gs addUnrespondedUpdate:[GemUpdate updateWithTag:tag change:-goldCost]];
    
    [gs beginCombineTimer];
    
    return YES;
  }
  return NO;
}

- (BOOL) addMonsterToHealingQueue:(NSString *)userMonsterUuid {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  UserMonster *um = [gs myMonsterWithUserMonsterUuid:userMonsterUuid];
  
  int maxHealth = [gl calculateMaxHealthForMonster:um];
  int cashCost = [gl calculateCostToHealMonster:um];
  if (um.curHealth >= maxHealth) {
    [Globals popupMessage:@"This monster is already at full health."];
  } else if (gs.cash < cashCost) {
    [Globals popupMessage:@"Trying to heal item without enough cash."];
  } else {
    UserMonsterHealingItem *item = [[UserMonsterHealingItem alloc] init];
    item.userMonsterUuid = userMonsterUuid;
    item.userUuid = gs.userUuid;
    [gs addUserMonsterHealingItemToEndOfQueue:item];
    
    int tag = [[SocketCommunication sharedSocketCommunication] setHealQueueDirtyWithCoinChange:-cashCost gemCost:0];
    [gs addUnrespondedUpdate:[CashUpdate updateWithTag:tag change:-cashCost]];
    return YES;
  }
  return NO;
}

- (BOOL) removeMonsterFromHealingQueue:(UserMonsterHealingItem *)item {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserMonster *um = [gs myMonsterWithUserMonsterUuid:item.userMonsterUuid];
  
  int cashCost = [gl calculateCostToHealMonster:um];
  if (![gs.monsterHealingQueue containsObject:item]) {
    [Globals popupMessage:@"This item is not in the healing queue."];
  } else {
    [gs removeUserMonsterHealingItem:item];
    
    int tag = [[SocketCommunication sharedSocketCommunication] setHealQueueDirtyWithCoinChange:cashCost gemCost:0];
    [gs addUnrespondedUpdate:[CashUpdate updateWithTag:tag change:cashCost]];
    return YES;
  }
  return NO;
}

- (BOOL) speedupHealingQueue {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int timeLeft = [gl calculateTimeLeftToHealAllMonstersInQueue];
  int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
  
  if (gs.gems < gemCost) {
    [Globals popupMessage:@"Trying to speedup heal queue without enough gold"];
  } else {
    NSMutableArray *arr = [NSMutableArray array];
    for (UserMonsterHealingItem *item in gs.monsterHealingQueue) {
      UserMonster *um = [gs myMonsterWithUserMonsterUuid:item.userMonsterUuid];
      um.curHealth = [gl calculateMaxHealthForMonster:um];
      
      UserMonsterCurrentHealthProto_Builder *monsterHealth = [UserMonsterCurrentHealthProto builder];
      monsterHealth.userMonsterUuid = um.userMonsterUuid;
      monsterHealth.currentHealth = um.curHealth;
      [arr addObject:monsterHealth.build];
      
      [gs.recentlyHealedMonsterUuids addObject:um.userMonsterUuid];
    }
    
    int tag = [[SocketCommunication sharedSocketCommunication] sendHealQueueSpeedup:arr goldCost:gemCost];
    [gs addUnrespondedUpdate:[GemUpdate updateWithTag:tag change:-gemCost]];
    
    // Remove after to let the queue update to not be affected
    [gs.monsterHealingQueue removeAllObjects];
    [gs stopHealingTimer];
    return YES;
  }
  return NO;
}

- (void) healQueueWaitTimeComplete:(NSArray *)healingItems {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSMutableArray *arr = [NSMutableArray array];
  for (UserMonsterHealingItem *item in healingItems) {
    if ([item.expectedEndTime timeIntervalSinceNow] > 0) {
      [Globals popupMessage:@"Trying to finish healing item before time."];
    } else {
      UserMonster *um = [gs myMonsterWithUserMonsterUuid:item.userMonsterUuid];
      um.curHealth = [gl calculateMaxHealthForMonster:um];
      
      UserMonsterCurrentHealthProto_Builder *monsterHealth = [UserMonsterCurrentHealthProto builder];
      monsterHealth.userMonsterUuid = um.userMonsterUuid;
      monsterHealth.currentHealth = um.curHealth;
      [arr addObject:monsterHealth.build];
      
      [gs.recentlyHealedMonsterUuids addObject:um.userMonsterUuid];
    }
  }
  
  [[SocketCommunication sharedSocketCommunication] sendHealQueueWaitTimeComplete:arr];
  
  // Remove after to let the queue update to not be affected
  [gs.monsterHealingQueue removeObjectsInArray:healingItems];
  [gs beginHealingTimer];
}

- (BOOL) setBaseEnhanceMonster:(NSString *)userMonsterUuid {
  GameState *gs = [GameState sharedGameState];
  UserMonster *um = [gs myMonsterWithUserMonsterUuid:userMonsterUuid];
  
  if (gs.userEnhancement) {
    [Globals popupMessage:@"Trying to set base monster while already enhancing."];
  } else if ([um isHealing]) {
    [Globals popupMessage:@"Trying to enhance item that is healing."];
  } else {
    EnhancementItem *ei = [[EnhancementItem alloc] init];
    ei.userMonsterUuid = userMonsterUuid;
    
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
    int cashIncrease = 0;
    for (EnhancementItem *item in gs.userEnhancement.feeders) {
      cashIncrease += [gl calculateCashCostForEnhancement:gs.userEnhancement.baseMonster feeder:item];
    }
    
    int tag = [[SocketCommunication sharedSocketCommunication] setEnhanceQueueDirtyWithCoinChange:cashIncrease gemCost:0];
    [gs addUnrespondedUpdate:[CashUpdate updateWithTag:tag change:cashIncrease]];
    
    gs.userEnhancement = nil;
    [gs stopEnhanceTimer];
    
    return YES;
  }
  return NO;
}

- (BOOL) addMonsterToEnhancingQueue:(NSString *)userMonsterUuid {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  UserMonster *um = [gs myMonsterWithUserMonsterUuid:userMonsterUuid];
  UserEnhancement *ue = gs.userEnhancement;
  
  EnhancementItem *newItem = [[EnhancementItem alloc] init];
  newItem.userMonsterUuid = userMonsterUuid;
  
  int cashCost = [gl calculateCashCostForEnhancement:ue.baseMonster feeder:newItem];
  if (!ue) {
    [Globals popupMessage:@"Trying to add feeder without base monster."];
  } else if ([um isHealing]) {
    [Globals popupMessage:@"Trying to sacrifice item that is healing."];
  } else if (gs.cash < cashCost) {
    [Globals popupMessage:@"Trying to enhance item without enough cash."];
  } else {
    [gs addEnhancingItemToEndOfQueue:newItem];
    
    um.teamSlot = 0;
    
    int tag = [[SocketCommunication sharedSocketCommunication] setEnhanceQueueDirtyWithCoinChange:-cashCost gemCost:0];
    [gs addUnrespondedUpdate:[CashUpdate updateWithTag:tag change:-cashCost]];
    
    return YES;
  }
  return NO;
}

- (BOOL) removeMonsterFromEnhancingQueue:(EnhancementItem *)item {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (![gs.userEnhancement.feeders containsObject:item]) {
    [Globals popupMessage:@"This item is not in the enhancing queue."];
  } else {
    [gs removeEnhancingItem:item];
    
    int cashChange = [gl calculateCashCostForEnhancement:gs.userEnhancement.baseMonster feeder:item];
    int tag = [[SocketCommunication sharedSocketCommunication] setEnhanceQueueDirtyWithCoinChange:cashChange gemCost:0];
    [gs addUnrespondedUpdate:[CashUpdate updateWithTag:tag change:cashChange]];
    
    return YES;
  }
  return NO;
}

- (BOOL) speedupEnhancingQueue {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int timeLeft = [gl calculateTimeLeftForEnhancement:gs.userEnhancement];
  int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
  
  if (gs.gems < gemCost) {
    [Globals popupMessage:@"Trying to speedup enhance queue without enough gold"];
  } else {
    NSMutableArray *arr = [NSMutableArray array];
    EnhancementItem *base = gs.userEnhancement.baseMonster;
    for (EnhancementItem *item in gs.userEnhancement.feeders) {
      UserMonster *um = [gs myMonsterWithUserMonsterUuid:item.userMonsterUuid];
      base.userMonster.experience += [gl calculateExperienceIncrease:base feeder:item];
      [arr addObject:um.userMonsterUuid];
      [gs.myMonsters removeObject:um];
    }
    
    UserMonster *baseMonster = base.userMonster;
    UserMonsterCurrentExpProto_Builder *bldr = [UserMonsterCurrentExpProto builder];
    bldr.userMonsterUuid = baseMonster.userMonsterUuid;
    bldr.expectedExperience = baseMonster.experience;
    bldr.expectedLevel = baseMonster.level;
    
    int tag = [[SocketCommunication sharedSocketCommunication] sendEnhanceQueueSpeedup:bldr.build userMonsterUuids:arr goldCost:gemCost];
    [gs addUnrespondedUpdate:[GemUpdate updateWithTag:tag change:-gemCost]];
    
    // Remove after to let the queue update to not be affected
    [self removeBaseEnhanceMonster];
    
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
    if ([item.expectedEndTime timeIntervalSinceNow] > 0) {
      [Globals popupMessage:@"Trying to finish enhancing item before time."];
    } else {
      UserMonster *um = [gs myMonsterWithUserMonsterUuid:item.userMonsterUuid];
      base.userMonster.experience += [gl calculateExperienceIncrease:base feeder:item];
      [arr addObject:um.userMonsterUuid];
      [gs.myMonsters removeObject:um];
    }
  }
  
  UserMonster *baseMonster = base.userMonster;
  UserMonsterCurrentExpProto_Builder *bldr = [UserMonsterCurrentExpProto builder];
  bldr.userMonsterUuid = baseMonster.userMonsterUuid;
  bldr.expectedExperience = baseMonster.experience;
  bldr.expectedLevel = baseMonster.level;
  
  [[SocketCommunication sharedSocketCommunication] sendEnhanceQueueWaitTimeComplete:bldr.build userMonsterUuids:arr];
  
  // Remove after to let the queue update to not be affected
  [gs.userEnhancement.feeders removeObjectsInArray:enhancingItems];
  
  if (gs.userEnhancement.feeders.count == 0) {
    [self removeBaseEnhanceMonster];
  } else {
    [gs beginEnhanceTimer];
  }
}

@end
