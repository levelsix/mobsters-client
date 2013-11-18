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
  
  int goldPrice = fsp.isPremiumCurrency ? fsp.buildPrice : 0;
  int silverPrice = fsp.isPremiumCurrency ? 0 : fsp.buildPrice;
  if (gs.silver >= silverPrice && gs.gold >= goldPrice) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendPurchaseNormStructureMessage:structId x:x y:y time:[self getCurrentMilliseconds]];
    us = [[UserStruct alloc] init];
    
    // UserStructId will come in the response
    us.userId = [[GameState sharedGameState] userId];
    us.structId = structId;
    us.isComplete = NO;
    us.coordinates = CGPointMake(x, y);
    us.orientation = 0;
    us.purchaseTime = [NSDate date];
    us.lastRetrieved = nil;
    
    AddStructUpdate *asu = [AddStructUpdate updateWithTag:tag userStruct:us];
    SilverUpdate *su = [SilverUpdate updateWithTag:tag change:-silverPrice];
    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:-goldPrice];
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
  FullStructureProto *fsp = userStruct.fsp;
  
  if (userStruct.userStructId == 0) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (userStruct.userId != gs.userId) {
    [Globals popupMessage:@"This is not your building!"];
  } else {
    int tag = [sc sendSellNormStructureMessage:userStruct.userStructId];
    
    SellStructUpdate *ssu = [SellStructUpdate updateWithTag:tag userStruct:userStruct];
    SilverUpdate *su = [SilverUpdate updateWithTag:tag change:fsp.isPremiumCurrency ? 0 : fsp.sellPrice];
    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:fsp.isPremiumCurrency ? fsp.sellPrice : 0];
    
    [gs addUnrespondedUpdates:ssu, su, gu, nil];
    
    [Analytics normStructSell:userStruct.structId level:fsp.level];
  }
}

- (void) retrieveFromNormStructure:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  SocketCommunication *sc = [SocketCommunication sharedSocketCommunication];
  
  if (userStruct.userStructId == 0) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (userStruct.userId != gs.userId) {
    [Globals popupMessage:@"This is not your building!"];
  } else if (userStruct.isComplete && userStruct.lastRetrieved) {
    int64_t ms = [self getCurrentMilliseconds];
    int tag = [sc retrieveCurrencyFromStruct:userStruct.userStructId time:ms];
    userStruct.lastRetrieved = [NSDate dateWithTimeIntervalSince1970:ms/1000.0];
    
    // Update game state
    [gs addUnrespondedUpdate:[SilverUpdate updateWithTag:tag change:userStruct.fsp.income]];
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Building %d is not ready to be retrieved", userStruct.userStructId]];
  }
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
  } else if (gs.gold < gemCost) {
    [Globals popupMessage:@"Not enough diamonds to speed up upgrade"];
  } else if (!userStruct.isComplete) {
    int64_t ms = [self getCurrentMilliseconds];
    int tag = [sc sendFinishNormStructBuildWithDiamondsMessage:userStruct.userStructId gemCost:gemCost time:[self getCurrentMilliseconds]];
    userStruct.isComplete = YES;
    userStruct.lastRetrieved = [NSDate dateWithTimeIntervalSince1970:ms/1000.0];
    
    // Update game state
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-[gl calculateGemSpeedupCostForTimeLeft:timeLeft]]];
    
    [Analytics normStructInstaUpgrade:userStruct.structId level:userStruct.fsp.level];
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
    NSDate *date = userStruct.buildCompleteDate;
    
    if ([date compare:[NSDate date]] == NSOrderedDescending) {
      [Globals popupMessage:@"Something went wrong, building should still be waiting"];
      return;
    }
    userStruct.lastRetrieved = date;
    userStruct.isComplete = YES;
    
    int64_t ms = [self getCurrentMilliseconds];
    int tag = [sc sendNormStructBuildsCompleteMessage:[NSArray arrayWithObject:[NSNumber numberWithInt:userStruct.userStructId]] time:ms];
    
    [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"Building %d is not upgrading or constructing", userStruct.userStructId]];
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
  
  if (userStruct.userStructId == 0) {
    [Globals popupMessage:@"Waiting for confirmation of purchase!"];
  } else if (userStruct.userId != gs.userId) {
    [Globals popupMessage:@"This is not your building!"];
  } else if (!nextFsp) {
    [Globals popupMessage:@"This building is not upgradable"];
  } else {
    int goldCost = nextFsp.isPremiumCurrency ? nextFsp.buildPrice : 0;
    int silverCost = nextFsp.isPremiumCurrency ? 0 : nextFsp.buildPrice;
    if (goldCost > gs.gold || silverCost > gs.silver) {
      [Globals popupMessage:@"Trying to upgrade without enough resources."];
    } else {
      int64_t ms = [self getCurrentMilliseconds];
      int tag = [sc sendUpgradeNormStructureMessage:userStruct.userStructId time:ms];
      userStruct.isComplete = NO;
      userStruct.purchaseTime = [NSDate dateWithTimeIntervalSince1970:ms/1000.0];
      userStruct.structId = nextFsp.structId;
      
      // Update game state
      SilverUpdate *su = [SilverUpdate updateWithTag:tag change:-silverCost];
      GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:-goldCost];
      [gs addUnrespondedUpdates:su, gu, nil];
    }
  }
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
  FullQuestProto *fqp = [gs.availableQuests objectForKey:questIdNum];
  
  if (fqp) {
    int tag = [[SocketCommunication sharedSocketCommunication] sendQuestAcceptMessage:questId];
    [gs addUnrespondedUpdate:[NoUpdate updateWithTag:tag]];
    
    [gs.availableQuests removeObjectForKey:questIdNum];
    [gs.inProgressIncompleteQuests setObject:fqp forKey:questIdNum];
    
    UserQuest *uq = [[UserQuest alloc] init];
    uq.userId = gs.userId;
    uq.questId = questId;
    uq.progress = 0;
    [gs addToMyQuests:[NSArray arrayWithObject:uq]];
    
    [Analytics questAccept:questId];
    
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
    [[SocketCommunication sharedSocketCommunication] sendQuestProgressMessage:questId progress:uq.progress isComplete:uq.isComplete userMonsterIds:nil];
    
    if (uq.isComplete) {
      NSNumber *questIdNum = [NSNumber numberWithInt:questId];
      FullQuestProto *fqp = [gs.inProgressIncompleteQuests objectForKey:questIdNum];
      if (fqp) {
        [gs.inProgressIncompleteQuests removeObjectForKey:questIdNum];
        [gs.inProgressCompleteQuests setObject:fqp forKey:questIdNum];
      }
    }
  } else {
    [Globals popupMessage:@"Attempting to progress nonexistant quest"];
  }
}

- (UserQuest *) donateForQuest:(int)questId monsterIds:(NSArray *)monsterIds {
  GameState *gs = [GameState sharedGameState];
  UserQuest *uq = [gs myQuestWithId:questId];
  FullQuestProto *fqp = [gs questForId:uq.questId];
  
  if (monsterIds.count < fqp.quantity) {
    [Globals popupMessage:@"Attempting to donate without enough of monster."];
  }
  if (uq) {
    for (NSNumber *num in monsterIds) {
      UserMonster *um = [gs myMonsterWithUserMonsterId:num.intValue];
      if (um && um.isComplete) {
        [gs.myMonsters removeObject:um];
      } else {
        [Globals popupMessage:@"One of the monsters can not be found."];
        return nil;
      }
    }
    
    uq.isComplete = YES;
    
    NSNumber *questIdNum = [NSNumber numberWithInt:questId];
    FullQuestProto *fqp = [gs.inProgressIncompleteQuests objectForKey:questIdNum];
    if (fqp) {
      [gs.inProgressIncompleteQuests removeObjectForKey:questIdNum];
      [gs.inProgressCompleteQuests setObject:fqp forKey:questIdNum];
    }
    
    [[SocketCommunication sharedSocketCommunication] sendQuestProgressMessage:questId progress:uq.progress isComplete:uq.isComplete userMonsterIds:monsterIds];
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
    SilverUpdate *su = [SilverUpdate updateWithTag:tag change:fqp.coinReward];
    GoldUpdate *gu = [GoldUpdate updateWithTag:tag change:fqp.diamondReward];
    ExperienceUpdate *eu = [ExperienceUpdate updateWithTag:tag change:fqp.expReward];
    
    [gs addUnrespondedUpdates:su, gu, eu, nil];
    
    [Analytics questRedeem:questId];
  } else {
    [Globals popupMessage:@"Attempting to redeem quest that is not in progress"];
  }
}

- (void) retrieveUsersForUserIds:(NSArray *)userIds includeCurMonsterTeam:(BOOL)includeCurMonsterTeam delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  int tag = [[SocketCommunication sharedSocketCommunication] sendRetrieveUsersForUserIds:[[NSSet setWithArray:userIds] allObjects] includeCurMonsterTeam:includeCurMonsterTeam];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
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
  } else if (gs.gold < gl.coinPriceToCreateClan) {
    [Globals popupMessage:@"Attempting to create clan without enough gold."];
  } else {
    int tag = [[SocketCommunication sharedSocketCommunication] sendCreateClanMessage:clanName tag:clanTag description:description requestOnly:requestOnly];
    [gs addUnrespondedUpdate:[SilverUpdate updateWithTag:tag change:-gl.coinPriceToCreateClan]];
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
  int goldCost = speedUp ? [gl calculateGemSpeedupCostForTimeLeft:timeLeft] : 0;
  if (gs.gold < goldCost) {
    [Globals popupMessage:@"Attempting to speedup without enough gold"];
  } else if (!ue.isExpanding) {
    [Globals popupMessage:@"Attempting to complete expansion while not expanding"];
  } else if (!speedUp && [[NSDate date] compare:[ue.lastExpandTime dateByAddingTimeInterval:[gl calculateNumMinutesForNewExpansion]*60]] == NSOrderedAscending) {
    [Globals popupMessage:@"Attempting to complete expansion before it is ready"];
  } else {
    uint64_t ms = [self getCurrentMilliseconds];
    int tag = [[SocketCommunication sharedSocketCommunication] sendExpansionWaitCompleteMessage:speedUp gemCost:goldCost curTime:ms atX:x atY:y];
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-goldCost]];
    
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
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-bpp.gemPrice]];
  }
}

- (void) privateChatPost:(int)recipientId content:(NSString *)content {
  [[SocketCommunication sharedSocketCommunication] sendPrivateChatPostMessage:recipientId content:content];
}

- (void) retrievePrivateChatPosts:(int)otherUserId delegate:(id)delegate {
  int tag = [[SocketCommunication sharedSocketCommunication] sendRetrievePrivateChatPostsMessage:otherUserId];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
}

- (void) beginDungeon:(int)taskId withDelegate:(id)delegate {
  int tag = [[SocketCommunication sharedSocketCommunication] sendBeginDungeonMessage:[self getCurrentMilliseconds] taskId:taskId];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
}

- (void) updateMonsterHealth:(int)userMonsterId curHealth:(int)curHealth {
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
    [[SocketCommunication sharedSocketCommunication] sendUpdateMonsterHealthMessage:[self getCurrentMilliseconds] monsterHealth:m];
  }
}

- (void) endDungeon:(BeginDungeonResponseProto *)dungeonInfo userWon:(BOOL)userWon delegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  BOOL isFirstTime = ![gs.completedTasks containsObject:@(dungeonInfo.taskId)];
  int tag = [[SocketCommunication sharedSocketCommunication] sendEndDungeonMessage:dungeonInfo.userTaskId userWon:userWon isFirstTimeCompleted:isFirstTime time:[self getCurrentMilliseconds]];
  [[SocketCommunication sharedSocketCommunication] setDelegate:delegate forTag:tag];
  
  if (userWon) {
    int silverAmount = 0, expAmount = 0;
    for (TaskStageProto *tsp in dungeonInfo.tspList) {
      for (TaskStageMonsterProto *tsm in tsp.stageMonstersList) {
        silverAmount += tsm.cashReward;
        expAmount += tsm.expReward;
      }
    }
    
    SilverUpdate *su = [SilverUpdate updateWithTag:tag change:silverAmount];
    ExperienceUpdate *eu = [ExperienceUpdate updateWithTag:tag change:expAmount];
    [gs addUnrespondedUpdates: su, eu, nil];
  }
}

- (BOOL) removeMonsterFromTeam:(int)userMonsterId {
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

- (BOOL) addMonsterToTeam:(int)userMonsterId {
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
      
      [[SocketCommunication sharedSocketCommunication] sendAddMonsterToTeam:userMonsterId teamSlot:teamSlot];
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
  
  if (gs.gold < gl.inventoryIncreaseSizeCost) {
    [Globals popupMessage:@"Trying to increase inventory without enough gold"];
  } else {
    gs.numAdditionalMonsterSlots += gl.inventoryIncreaseSizeAmount;
    int tag = [[SocketCommunication sharedSocketCommunication] buyInventorySlots];
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-gl.inventoryIncreaseSizeCost]];
  }
}

- (void) inviteAllFacebookFriends:(NSArray *)fbFriends {
  [[SocketCommunication sharedSocketCommunication] sendInviteFbFriendsForSlotsMessage:fbFriends];
}

- (void) acceptAndRejectInvitesWithAcceptIds:(NSArray *)acceptIds rejectIds:(NSArray *)rejectIds {
  [[SocketCommunication sharedSocketCommunication] sendAcceptAndRejectFbInviteForSlotsMessageAndAcceptIds:acceptIds rejectIds:rejectIds];
}

- (void) combineMonsters:(NSArray *)userMonsterIds {
  GameState *gs = [GameState sharedGameState];
  for (NSNumber *umId in userMonsterIds) {
    UserMonster *um = [gs myMonsterWithUserMonsterId:umId.intValue];
    um.isComplete = YES;
  }
  [[SocketCommunication sharedSocketCommunication] sendCombineUserMonsterPiecesMessage:userMonsterIds gemCost:0];
}

- (BOOL) combineMonsterWithSpeedup:(int)userMonsterId {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserMonster *um = [gs myMonsterWithUserMonsterId:userMonsterId];
  int timeLeft = um.timeLeftForCombining;
  int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
  
  if (gs.gold < goldCost) {
    [Globals popupMessage:@"Trying to speedup combine monster without enough gems"];
  } else {
    um.isComplete = YES;
    
    int tag = [[SocketCommunication sharedSocketCommunication] sendCombineUserMonsterPiecesMessage:[NSArray arrayWithObject:[NSNumber numberWithInt:userMonsterId]] gemCost:goldCost];
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-goldCost]];
    
    [gs beginCombineTimer];
    
    return YES;
  }
  return NO;
}

- (BOOL) addMonsterToHealingQueue:(int)userMonsterId {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  UserMonster *um = [gs myMonsterWithUserMonsterId:userMonsterId];
  
  int maxHealth = [gl calculateMaxHealthForMonster:um];
  int silverCost = [gl calculateCostToHealMonster:um];
  if (um.curHealth >= maxHealth) {
    [Globals popupMessage:@"This monster is already at full health."];
  } else if (gs.silver < silverCost) {
    [Globals popupMessage:@"Trying to heal item without enough cash."];
  } else {
    UserMonsterHealingItem *item = [[UserMonsterHealingItem alloc] init];
    item.userMonsterId = userMonsterId;
    item.userId = gs.userId;
    [gs addUserMonsterHealingItemToEndOfQueue:item];
    
    int tag = [[SocketCommunication sharedSocketCommunication] setHealQueueDirtyWithCoinChange:-silverCost gemCost:0];
    [gs addUnrespondedUpdate:[SilverUpdate updateWithTag:tag change:-silverCost]];
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
    
    int tag = [[SocketCommunication sharedSocketCommunication] setHealQueueDirtyWithCoinChange:silverCost gemCost:0];
    [gs addUnrespondedUpdate:[SilverUpdate updateWithTag:tag change:silverCost]];
    return YES;
  }
  return NO;
}

- (BOOL) speedupHealingQueue {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int timeLeft = [gl calculateTimeLeftToHealAllMonstersInQueue];
  int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
  
  if (gs.gold < goldCost) {
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

- (BOOL) setBaseEnhanceMonster:(int)userMonsterId {
  GameState *gs = [GameState sharedGameState];
  UserMonster *um = [gs myMonsterWithUserMonsterId:userMonsterId];
  
  if (gs.userEnhancement) {
    [Globals popupMessage:@"Trying to set base monster while already enhancing."];
  } else if ([um isHealing]) {
    [Globals popupMessage:@"Trying to enhance item that is healing."];
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
    int cashIncrease = 0;
    for (EnhancementItem *item in gs.userEnhancement.feeders) {
      cashIncrease += [gl calculateSilverCostForEnhancement:gs.userEnhancement.baseMonster feeder:item];
    }
    
    int tag = [[SocketCommunication sharedSocketCommunication] setEnhanceQueueDirtyWithCoinChange:cashIncrease gemCost:0];
    [gs addUnrespondedUpdate:[SilverUpdate updateWithTag:tag change:cashIncrease]];
    
    gs.userEnhancement = nil;
    [gs stopEnhanceTimer];
    
    return YES;
  }
  return NO;
}

- (BOOL) addMonsterToEnhancingQueue:(int)userMonsterId {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  UserMonster *um = [gs myMonsterWithUserMonsterId:userMonsterId];
  UserEnhancement *ue = gs.userEnhancement;
  
  EnhancementItem *newItem = [[EnhancementItem alloc] init];
  newItem.userMonsterId = userMonsterId;
  
  int silverCost = [gl calculateSilverCostForEnhancement:ue.baseMonster feeder:newItem];
  if (!ue) {
    [Globals popupMessage:@"Trying to add feeder without base monster."];
  } else if ([um isHealing]) {
    [Globals popupMessage:@"Trying to sacrifice item that is healing."];
  } else if (gs.silver < silverCost) {
    [Globals popupMessage:@"Trying to enhance item without enough cash."];
  } else {
    [gs addEnhancingItemToEndOfQueue:newItem];
    
    um.teamSlot = 0;
    
    int tag = [[SocketCommunication sharedSocketCommunication] setEnhanceQueueDirtyWithCoinChange:-silverCost gemCost:0];
    [gs addUnrespondedUpdate:[SilverUpdate updateWithTag:tag change:-silverCost]];
    
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
    
    int silverChange = [gl calculateSilverCostForEnhancement:gs.userEnhancement.baseMonster feeder:item];
    int tag = [[SocketCommunication sharedSocketCommunication] setEnhanceQueueDirtyWithCoinChange:silverChange gemCost:0];
    [gs addUnrespondedUpdate:[SilverUpdate updateWithTag:tag change:silverChange]];
    
    return YES;
  }
  return NO;
}

- (BOOL) speedupEnhancingQueue {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int timeLeft = [gl calculateTimeLeftForEnhancement:gs.userEnhancement];
  int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft];
  
  if (gs.gold < goldCost) {
    [Globals popupMessage:@"Trying to speedup enhance queue without enough gold"];
  } else {
    NSMutableArray *arr = [NSMutableArray array];
    EnhancementItem *base = gs.userEnhancement.baseMonster;
    for (EnhancementItem *item in gs.userEnhancement.feeders) {
      UserMonster *um = [gs myMonsterWithUserMonsterId:item.userMonsterId];
      base.userMonster.experience += [gl calculateExperienceIncrease:base feeder:item];
      [arr addObject:[NSNumber numberWithInt:um.userMonsterId]];
      [gs.myMonsters removeObject:um];
    }
    
    UserMonster *baseMonster = base.userMonster;
    UserMonsterCurrentExpProto_Builder *bldr = [UserMonsterCurrentExpProto builder];
    bldr.userMonsterId = baseMonster.userMonsterId;
    bldr.expectedExperience = baseMonster.experience;
    bldr.expectedLevel = baseMonster.level;
    
    int tag = [[SocketCommunication sharedSocketCommunication] sendEnhanceQueueSpeedup:bldr.build userMonsterIds:arr goldCost:goldCost];
    [gs addUnrespondedUpdate:[GoldUpdate updateWithTag:tag change:-goldCost]];
    
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
      UserMonster *um = [gs myMonsterWithUserMonsterId:item.userMonsterId];
      base.userMonster.experience += [gl calculateExperienceIncrease:base feeder:item];
      [arr addObject:[NSNumber numberWithInt:um.userMonsterId]];
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

@end
