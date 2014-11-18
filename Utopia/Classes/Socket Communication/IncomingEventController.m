//
//  EventController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/3/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "IncomingEventController.h"
#import "Protocols.pb.h"
#import "LNSynthesizeSingleton.h"
#import "GameState.h"
#import "Globals.h"
#import "OutgoingEventController.h"
#import "HomeMap.h"
#import "MissionMap.h"
#import "GameViewController.h"
#import "GenericPopupController.h"
#import "FullEvent.h"
#import "AppDelegate.h"
#import "IAPHelper.h"
#import "ClanViewController.h"
#import "SocketCommunication.h"
#import "DungeonBattleLayer.h"
#import "GameCenterDelegate.h"
#import "FacebookDelegate.h"
#import "UnreadNotifications.h"

#define QUEST_REDEEM_KIIP_REWARD @"quest_redeem"

@implementation IncomingEventController

LN_SYNTHESIZE_SINGLETON_FOR_CLASS(IncomingEventController);

- (Class) getClassForType: (EventProtocolResponse) type {
  // This is very hacky but I suppose necessary.. :/
  Class responseClass;
  switch (type) {
    case EventProtocolResponseSUserCreateEvent:
      responseClass = [UserCreateResponseProto class];
      break;
    case EventProtocolResponseSStartupEvent:
      responseClass = [StartupResponseProto class];
      break;
    case EventProtocolResponseSLevelUpEvent:
      responseClass = [LevelUpResponseProto class];
      break;
    case EventProtocolResponseSInAppPurchaseEvent:
      responseClass = [InAppPurchaseResponseProto class];
      break;
    case EventProtocolResponseSUpdateClientUserEvent:
      responseClass = [UpdateClientUserResponseProto class];
      break;
    case EventProtocolResponseSPurchaseNormStructureEvent:
      responseClass = [PurchaseNormStructureResponseProto class];
      break;
    case EventProtocolResponseSMoveOrRotateNormStructureEvent:
      responseClass = [MoveOrRotateNormStructureResponseProto class];
      break;
    case EventProtocolResponseSUpgradeNormStructureEvent:
      responseClass = [UpgradeNormStructureResponseProto class];
      break;
    case EventProtocolResponseSNormStructWaitCompleteEvent:
      responseClass = [NormStructWaitCompleteResponseProto class];
      break;
    case EventProtocolResponseSFinishNormStructWaittimeWithDiamondsEvent:
      responseClass = [FinishNormStructWaittimeWithDiamondsResponseProto class];
      break;
    case EventProtocolResponseSRetrieveCurrencyFromNormStructureEvent:
      responseClass = [RetrieveCurrencyFromNormStructureResponseProto class];
      break;
    case EventProtocolResponseSLoadPlayerCityEvent:
      responseClass = [LoadPlayerCityResponseProto class];
      break;
    case EventProtocolResponseSLoadCityEvent:
      responseClass = [LoadCityResponseProto class];
      break;
    case EventProtocolResponseSQuestAcceptEvent:
      responseClass = [QuestAcceptResponseProto class];
      break;
    case EventProtocolResponseSQuestRedeemEvent:
      responseClass = [QuestRedeemResponseProto class];
      break;
    case EventProtocolResponseSQuestProgressEvent:
      responseClass = [QuestProgressResponseProto class];
      break;
    case EventProtocolResponseSRetrieveUsersForUserIdsEvent:
      responseClass = [RetrieveUsersForUserIdsResponseProto class];
      break;
    case EventProtocolResponseSReferralCodeUsedEvent:
      responseClass = [ReferralCodeUsedResponseProto class];
      break;
    case EventProtocolResponseSEnableApnsEvent:
      responseClass = [EnableAPNSResponseProto class];
      break;
    case EventProtocolResponseSEarnFreeDiamondsEvent:
      responseClass = [EarnFreeDiamondsResponseProto class];
      break;
    case EventProtocolResponseSPurgeStaticDataEvent:
      responseClass = [PurgeClientStaticDataResponseProto class];
      break;
    case EventProtocolResponseSSendGroupChatEvent:
      responseClass = [SendGroupChatResponseProto class];
      break;
    case EventProtocolResponseSReceivedGroupChatEvent:
      responseClass = [ReceivedGroupChatResponseProto class];
      break;
    case EventProtocolResponseSCreateClanEvent:
      responseClass = [CreateClanResponseProto class];
      break;
    case EventProtocolResponseSApproveOrRejectRequestToJoinClanEvent:
      responseClass = [ApproveOrRejectRequestToJoinClanResponseProto class];
      break;
    case EventProtocolResponseSLeaveClanEvent:
      responseClass = [LeaveClanResponseProto class];
      break;
    case EventProtocolResponseSRequestJoinClanEvent:
      responseClass = [RequestJoinClanResponseProto class];
      break;
    case EventProtocolResponseSRetractRequestJoinClanEvent:
      responseClass = [RetractRequestJoinClanResponseProto class];
      break;
    case EventProtocolResponseSRetrieveClanInfoEvent:
      responseClass = [RetrieveClanInfoResponseProto class];
      break;
    case EventProtocolResponseSTransferClanOwnership:
      responseClass = [TransferClanOwnershipResponseProto class];
      break;
    case EventProtocolResponseSChangeClanSettingsEvent:
      responseClass = [ChangeClanSettingsResponseProto class];
      break;
    case EventProtocolResponseSPromoteDemoteClanMemberEvent:
      responseClass = [PromoteDemoteClanMemberResponseProto class];
      break;
    case EventProtocolResponseSBootPlayerFromClanEvent:
      responseClass = [BootPlayerFromClanResponseProto class];
      break;
    case EventProtocolResponseSExpansionWaitCompleteEvent:
      responseClass = [ExpansionWaitCompleteResponseProto class];
      break;
    case EventProtocolResponseSPurchaseCityExpansionEvent:
      responseClass = [PurchaseCityExpansionResponseProto class];
      break;
    case EventProtocolResponseSSendAdminMessageEvent:
      responseClass = [SendAdminMessageResponseProto class];
      break;
    case EventProtocolResponseSGeneralNotificationEvent:
      responseClass = [GeneralNotificationResponseProto class];
      break;
    case EventProtocolResponseSRetrieveTournamentRankingsEvent:
      responseClass = [RetrieveTournamentRankingsResponseProto class];
      break;
    case EventProtocolResponseSSubmitMonsterEnhancementEvent:
      responseClass = [SubmitMonsterEnhancementResponseProto class];
      break;
    case EventProtocolResponseSEnhancementWaitTimeCompleteEvent:
      responseClass = [EnhancementWaitTimeCompleteResponseProto class];
      break;
    case EventProtocolResponseSPurchaseBoosterPackEvent:
      responseClass = [PurchaseBoosterPackResponseProto class];
      break;
    case EventProtocolResponseSReceivedRareBoosterPurchaseEvent:
      responseClass = [ReceivedRareBoosterPurchaseResponseProto class];
      break;
    case EventProtocolResponseSPrivateChatPostEvent:
      responseClass = [PrivateChatPostResponseProto class];
      break;
    case EventProtocolResponseSRetrievePrivateChatPostEvent:
      responseClass = [RetrievePrivateChatPostsResponseProto class];
      break;
    case EventProtocolResponseSBeginDungeonEvent:
      responseClass = [BeginDungeonResponseProto class];
      break;
    case EventProtocolResponseSReviveInDungeonEvent:
      responseClass = [ReviveInDungeonResponseProto class];
      break;
    case EventProtocolResponseSEndDungeonEvent:
      responseClass = [EndDungeonResponseProto class];
      break;
    case EventProtocolResponseSHealMonsterEvent:
      responseClass = [HealMonsterResponseProto class];
      break;
    case EventProtocolResponseSAddMonsterToBattleTeamEvent:
      responseClass = [AddMonsterToBattleTeamResponseProto class];
      break;
    case EventProtocolResponseSIncreaseMonsterInventorySlotEvent:
      responseClass = [IncreaseMonsterInventorySlotResponseProto class];
      break;
    case EventProtocolResponseSRemoveMonsterFromBattleTeamEvent:
      responseClass = [RemoveMonsterFromBattleTeamResponseProto class];
      break;
    case EventProtocolResponseSUpdateMonsterHealthEvent:
      responseClass = [UpdateMonsterHealthResponseProto class];
      break;
    case EventProtocolResponseSCombineUserMonsterPiecesEvent:
      responseClass = [CombineUserMonsterPiecesResponseProto class];
      break;
    case EventProtocolResponseSSellUserMonsterEvent:
      responseClass = [SellUserMonsterResponseProto class];
      break;
    case EventProtocolResponseSInviteFbFriendsForSlotsEvent:
      responseClass = [InviteFbFriendsForSlotsResponseProto class];
      break;
    case EventProtocolResponseSAcceptAndRejectFbInviteForSlotsEvent:
      responseClass = [AcceptAndRejectFbInviteForSlotsResponseProto class];
      break;
    case EventProtocolResponseSExchangeGemsForResourcesEvent:
      responseClass = [ExchangeGemsForResourcesResponseProto class];
      break;
    case EventProtocolResponseSEvolveMonsterEvent:
      responseClass = [EvolveMonsterResponseProto class];
      break;
    case EventProtocolResponseSEvolutionFinishedEvent:
      responseClass = [EvolutionFinishedResponseProto class];
      break;
    case EventProtocolResponseSQueueUpEvent:
      responseClass = [QueueUpResponseProto class];
      break;
    case EventProtocolResponseSUpdateUserCurrencyEvent:
      responseClass = [UpdateUserCurrencyResponseProto class];
      break;
    case EventProtocolResponseSBeginPvpBattleEvent:
      responseClass = [BeginPvpBattleResponseProto class];
      break;
    case EventProtocolResponseSBeginClanRaidEvent:
      responseClass = [BeginClanRaidResponseProto class];
      break;
    case EventProtocolResponseSAttackClanRaidMonsterEvent:
      responseClass = [AttackClanRaidMonsterResponseProto class];
      break;
    case EventProtocolResponseSSetGameCenterIdEvent:
      responseClass = [SetGameCenterIdResponseProto class];
      break;
    case EventProtocolResponseSSetFacebookIdEvent:
      responseClass = [SetFacebookIdResponseProto class];
      break;
    case EventProtocolResponseSEndPvpBattleEvent:
      responseClass = [EndPvpBattleResponseProto class];
      break;
    case EventProtocolResponseSForceLogoutEvent:
      responseClass = [ForceLogoutResponseProto class];
      break;
    case EventProtocolResponseSSpawnObstacleEvent:
      responseClass = [SpawnObstacleResponseProto class];
      break;
    case EventProtocolResponseSBeginObstacleRemovalEvent:
      responseClass = [BeginObstacleRemovalResponseProto class];
      break;
    case EventProtocolResponseSObstacleRemovalCompleteEvent:
      responseClass = [ObstacleRemovalCompleteResponseProto class];
      break;
    case EventProtocolResponseSAchievementProgressEvent:
      responseClass = [AchievementProgressResponseProto class];
      break;
    case EventProtocolResponseSAchievementRedeemEvent:
      responseClass = [AchievementRedeemResponseProto class];
      break;
    case EventProtocolResponseSSpawnMiniJobEvent:
      responseClass = [SpawnMiniJobResponseProto class];
      break;
    case EventProtocolResponseSBeginMiniJobEvent:
      responseClass = [BeginMiniJobResponseProto class];
      break;
    case EventProtocolResponseSCompleteMiniJobEvent:
      responseClass = [CompleteMiniJobResponseProto class];
      break;
    case EventProtocolResponseSRedeemMiniJobEvent:
      responseClass = [RedeemMiniJobResponseProto class];
      break;
    case EventProtocolResponseSSetAvatarMonsterEvent:
      responseClass = [SetAvatarMonsterResponseProto class];
      break;
    case EventProtocolResponseSDevEvent:
      responseClass = [DevResponseProto class];
      break;
    case EventProtocolResponseSRestrictUserMonsterEvent:
      responseClass = [RestrictUserMonsterResponseProto class];
      break;
    case EventProtocolResponseSUnrestrictUserMonsterEvent:
      responseClass = [UnrestrictUserMonsterResponseProto class];
      break;
    case EventProtocolResponseSEnhanceMonsterEvent:
      responseClass = [EnhanceMonsterResponseProto class];
      break;
    case EventProtocolResponseSTradeItemForBoosterEvent:
      responseClass = [TradeItemForBoosterResponseProto class];
      break;
    case EventProtocolResponseSSolicitClanHelpEvent:
      responseClass = [SolicitClanHelpResponseProto class];
      break;
    case EventProtocolResponseSGiveClanHelpEvent:
      responseClass = [GiveClanHelpResponseProto class];
      break;
    case EventProtocolResponseSEndClanHelpEvent:
      responseClass = [EndClanHelpResponseProto class];
      break;
    case EventProtocolResponseSCollectMonsterEnhancementEvent:
      responseClass = [CollectMonsterEnhancementResponseProto class];
      break;
    case EventProtocolResponseSRetrieveClanDataEvent:
      responseClass = [RetrieveClanDataResponseProto class];
      break;
      
    default:
      responseClass = nil;
      break;
  }
  return responseClass;
}

- (void) handleTimeOutOfSync {
  [Globals popupMessage:@"Your time is out of sync! Please fix in Settings->General->Date & Time."];
}

#pragma mark - Startup

- (void) handleUserCreateResponseProto:(FullEvent *)fe {
  UserCreateResponseProto *proto = (UserCreateResponseProto *)fe.event;
  LNLog(@"User create response received with status %d.", (int)proto.status);
}

- (void) handleStartupResponseProto:(FullEvent *)fe {
  StartupResponseProto *proto = (StartupResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Startup response received with status %d.", (int)proto.startupStatus);
  
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  
  [MSDate setServerTime:proto.serverTimeMillis];
  
  if (gs.isTutorial) {
    return;
  }
  
  gs.connected = YES;
  
  if (proto.updateStatus == StartupResponseProto_UpdateStatusMajorUpdate) {
    [GenericPopupController displayNotificationViewWithText:@"We've added a slew of new features! Update now to check them out." title:@"Update Now" okayButton:@"Update" target:gl selector:@selector(openAppStoreLink)];
    return;
  } else if (proto.updateStatus == StartupResponseProto_UpdateStatusMinorUpdate) {
    [GenericPopupController displayConfirmationWithDescription:@"An update is available. Head over to the App Store to download it now!" title:@"Update Available" okayButton:@"Update" cancelButton:@"Later" target:gl selector:@selector(openAppStoreLink)];
  }
  
  gl.appStoreLink = proto.appStoreUrl;
  gl.reviewPageURL = proto.reviewPageUrl;
  gl.reviewPageConfirmationMessage = proto.reviewPageConfirmationMessage;
  
  [gl updateConstants:proto.startupConstants];
  [gs updateStaticData:proto.staticDataStuffProto];
  if (proto.startupStatus == StartupResponseProto_StartupStatusUserInDb) {
    if (!proto.sender.hasUserUuid || proto.sender.userUuid.length == 0) {
      LNLog(@"Received user id 0..");
    }
    
    // Update user before creating map
    [gs.unrespondedUpdates removeAllObjects];
    [gs updateUser:proto.sender timestamp:0];
    
    // Setup the userid queue
    [[SocketCommunication sharedSocketCommunication] rebuildSender];
    [[SocketCommunication sharedSocketCommunication] initUserIdMessageQueue];
    
    [gs setPlayerHasBoughtInAppPurchase:proto.playerHasBoughtInAppPurchase];
    
    [gs.myQuests removeAllObjects];
    [gs addToMyQuests:proto.userQuestsList];
    
    [gs.myAchievements removeAllObjects];
    [gs addToMyAchievements:proto.userAchievementsList];
    
    //    [Globals asyncDownloadBundles];
    [gs.myMonsters removeAllObjects];
    [gs.monsterHealingQueue removeAllObjects];
    [gs addToMyMonsters:proto.usersMonstersList];
    [gs addAllMonsterHealingProtos:proto.monstersHealingList];;
    
    if (proto.hasEnhancements) {
      [gs addEnhancementProto:proto.enhancements];
    } else {
      gs.userEnhancement = nil;
    }
    
    if (proto.hasEvolution) {
      gs.userEvolution = [UserEvolution evolutionWithUserEvolutionProto:proto.evolution];
      [gs beginEvolutionTimer];
    } else {
      gs.userEvolution = nil;
    }
    
    gs.completedTasks = [NSMutableSet setWithArray:proto.completedTaskIdsList.toNSArray];
    
    [gs.myMiniJobs removeAllObjects];
    [gs addToMiniJobs:proto.userMiniJobProtosList isNew:NO];
    
    gs.itemUtil = [[ItemUtil alloc] initWithItemProtos:proto.userItemsList itemUsageProtos:proto.itemsInUseList];
    
    [gs.fbUnacceptedRequestsFromFriends removeAllObjects];
    [gs.fbAcceptedRequestsFromMe removeAllObjects];
    [gs addInventorySlotsRequests:proto.invitesToMeForSlotsList];
    [gs addInventorySlotsRequests:proto.invitesFromMeForSlotsList];
    
    [gs addToEventCooldownTimes:proto.userEventsList];
    
    [gs.requestedClans removeAllObjects];
    [gs addToRequestedClans:proto.userClanInfoList];
    
    if (proto.hasCurRaidClanInfo) {
      gs.curClanRaidInfo = proto.curRaidClanInfo;
      gs.curClanRaidUserInfos = [proto.curRaidClanUserInfoList mutableCopy];
    } else {
      gs.curClanRaidInfo = nil;
      [gs.curClanRaidUserInfos removeAllObjects];
    }
    
    [gs.globalChatMessages removeAllObjects];
    [gs.privateChats removeAllObjects];
    for (GroupChatMessageProto *msg in proto.globalChatsList) {
      ChatMessage *cm = [[ChatMessage alloc] initWithProto:msg];
      [gs addChatMessage:cm scope:GroupChatScopeGlobal];
    }
    for (PrivateChatPostProto *pcpp in proto.pcppList) {
      [gs addPrivateChat:pcpp];
    }
    [gs updateClanData:proto.clanData];
    
    gs.battleHistory = [proto.recentNbattlesList mutableCopy];
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [ad registerForPushNotifications];
    [ad removeLocalNotifications];
    if (ad.apnsToken && ![ad.apnsToken isEqualToString:gs.deviceToken]) {
      [[OutgoingEventController sharedOutgoingEventController] enableApns:ad.apnsToken];
    }
    NSString *gcId = [GameCenterDelegate gameCenterId];
    if (gcId) {
      [[OutgoingEventController sharedOutgoingEventController] setGameCenterId:gcId];
    }
    FacebookDelegate *fd = [FacebookDelegate sharedFacebookDelegate];
    if (fd.myFacebookUser) {
      [[GameViewController baseController] canProceedWithFacebookUser:fd.myFacebookUser];
    }
    
    // Display generic popups for strings that haven't been seen before
    NSUserDefaults *standardDefault = [NSUserDefaults standardUserDefaults];
    NSMutableArray *stringsStored = [[[NSUserDefaults standardUserDefaults] objectForKey:@"myCurrentString"]mutableCopy];
    NSMutableArray *incomingStrings = [NSMutableArray arrayWithArray:proto.noticesToPlayersList];
    
    if (stringsStored == NULL){
      stringsStored = [[NSMutableArray alloc]init];
    }
    for(NSString *incomingString in incomingStrings){
      BOOL hasStringAlready = NO;
      for(NSString *currentString in stringsStored){
        if([currentString isEqualToString:incomingString]){
          hasStringAlready = YES;
          break;
        }
      }
      if (!hasStringAlready) {
        [stringsStored addObject:incomingString];
        [Globals popupMessage:incomingString];
      }
    }
    
    [standardDefault setObject:stringsStored forKey:@"myCurrentString"];
    [standardDefault synchronize];
  } else {
    // Need to create new player
  }
  
  [gs removeNonFullUserUpdatesForTag:tag];
}

- (void) handleForceLogoutResponseProto:(FullEvent *)fe {
  ForceLogoutResponseProto *proto = (ForceLogoutResponseProto *)fe.event;
  
  LNLog(@"Force logout response received with udid %@.", proto.udid);
  GameViewController *gvc = [GameViewController baseController];
  [gvc handleForceLogoutResponseProto:proto];
}

- (void) handleLevelUpResponseProto:(FullEvent *)fe {
  LevelUpResponseProto *proto = (LevelUpResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Level up response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == LevelUpResponseProto_LevelUpStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to handle level up"];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

#pragma mark - IAP

- (void) handleInAppPurchaseResponseProto:(FullEvent *)fe {
  InAppPurchaseResponseProto *proto = (InAppPurchaseResponseProto *)fe.event;
  int tag = fe.tag;
  
  GameState *gs = [GameState sharedGameState];
  
  LNLog(@"In App Purchase response received with status %d.", (int)proto.status);
  
  NSString *key = IAP_DEFAULTS_KEY;
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *arr = [[defaults arrayForKey:key] mutableCopy];
  NSInteger origCount = arr.count;
  NSString *x = nil;
  for (NSString *str in arr) {
    if ([str isEqualToString:proto.receipt]) {
      x = str;
    }
  }
  if (x) [arr removeObject:x];
  if (arr.count < origCount) {
    [defaults setObject:arr forKey:IAP_DEFAULTS_KEY];
    [defaults synchronize];
  }
  
  IAPHelper *iap = [IAPHelper sharedIAPHelper];
  if (proto.status != InAppPurchaseResponseProto_InAppPurchaseStatusSuccess) {
    SKProduct *prod = iap.products[proto.packageName];
    // Duplicate receipt might occur if you close app before response comes back
    if (proto.status != InAppPurchaseResponseProto_InAppPurchaseStatusDuplicateReceipt) {
      [Globals popupMessage:@"Sorry! The In App Purchase failed! Please email support@lvl6.com"];
      [Analytics iapFailedWithSKProduct:prod error:@"Receipt verification failed"];
    } else {
      [Analytics iapFailedWithSKProduct:prod error:@"Duplicate receipt"];
    }
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    // Post notification so all UI with that bar can update
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:IAP_SUCCESS_NOTIFICATION object:nil]];
    [gs removeNonFullUserUpdatesForTag:tag];
    
    SKPaymentTransaction *lastTransaction = iap.lastTransaction;
    SKProduct *prod = [iap.products objectForKey:lastTransaction.payment.productIdentifier];
    if (lastTransaction && prod) {
      NSString *encodedReceipt = [iap base64forData:lastTransaction.transactionReceipt];
      if ([encodedReceipt isEqualToString:proto.receipt]) {
        [Analytics iapWithSKProduct:prod forTransacton:lastTransaction amountUS:proto.packagePrice];
      }
    }
  }
}

- (void) handleExchangeGemsForResourcesResponseProto:(FullEvent *)fe {
  ExchangeGemsForResourcesResponseProto *proto = (ExchangeGemsForResourcesResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Exchange gems response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == ExchangeGemsForResourcesResponseProto_ExchangeGemsForResourcesStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleUpdateClientUserResponseProto:(FullEvent *)fe {
  UpdateClientUserResponseProto *proto = (UpdateClientUserResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Update client user response received.");
  
  GameState *gs = [GameState sharedGameState];
  [gs removeFullUserUpdatesForTag:tag];
  [gs updateUser:proto.sender timestamp:proto.timeOfUserUpdate];
}

#pragma mark - Structure

- (void) handlePurchaseNormStructureResponseProto:(FullEvent *)fe {
  PurchaseNormStructureResponseProto *proto = (PurchaseNormStructureResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Purchase norm struct response received with status: %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == PurchaseNormStructureResponseProto_PurchaseNormStructureStatusSuccess) {
    // Get the userstruct without a userStructId
    UserStruct *us = nil;
    for (UserStruct *u in [[GameState sharedGameState] myStructs]) {
      if (!u.userStructUuid) {
        us = u;
        break;
      }
    }
    
    if (proto.status == PurchaseNormStructureResponseProto_PurchaseNormStructureStatusSuccess) {
      if (proto.hasUserStructUuid) {
        us.userStructUuid = proto.userStructUuid;
      } else {
        // This should never happen
        LNLog(@"Received success in purchase with no userStructId");
      }
    } else {
      [Globals popupMessage:[NSString stringWithFormat:@"Something went wrong in the purchase. Error Status: %d", (int)proto.status]];
      [gs.myStructs removeObject:us];
    }
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to purchase building."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleMoveOrRotateNormStructureResponseProto:(FullEvent *)fe {
  MoveOrRotateNormStructureResponseProto *proto = (MoveOrRotateNormStructureResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Move norm struct response received with status: %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status != MoveOrRotateNormStructureResponseProto_MoveOrRotateNormStructureStatusSuccess) {
    [Globals popupMessage:@"Server failed to change building location or orientation."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [gs removeNonFullUserUpdatesForTag:tag];
  }
}

- (void) handleUpgradeNormStructureResponseProto:(FullEvent *)fe {
  UpgradeNormStructureResponseProto *proto = (UpgradeNormStructureResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Upgrade norm structure response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status != UpgradeNormStructureResponseProto_UpgradeNormStructureStatusSuccess) {
    [Globals popupMessage:@"Server failed to upgrade building."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [gs removeNonFullUserUpdatesForTag:tag];
  }
}

- (void) handleNormStructWaitCompleteResponseProto:(FullEvent *)fe {
  NormStructWaitCompleteResponseProto *proto = (NormStructWaitCompleteResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Norm struct builds complete response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status != NormStructWaitCompleteResponseProto_NormStructWaitCompleteStatusSuccess) {
    [Globals popupMessage:@"Server failed to complete normal structure wait time."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [gs removeNonFullUserUpdatesForTag:tag];
  }
}

- (void) handleFinishNormStructWaittimeWithDiamondsResponseProto:(FullEvent *)fe {
  FinishNormStructWaittimeWithDiamondsResponseProto *proto = (FinishNormStructWaittimeWithDiamondsResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Finish norm struct with diamonds response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status != FinishNormStructWaittimeWithDiamondsResponseProto_FinishNormStructWaittimeStatusSuccess) {
    [Globals popupMessage:@"Server failed to speed up normal structure wait time."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [gs removeNonFullUserUpdatesForTag:tag];
  }
}

- (void) handleRetrieveCurrencyFromNormStructureResponseProto:(FullEvent *)fe {
  RetrieveCurrencyFromNormStructureResponseProto *proto = (RetrieveCurrencyFromNormStructureResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Retrieve currency response received with status: %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status != RetrieveCurrencyFromNormStructureResponseProto_RetrieveCurrencyFromNormStructureStatusSuccess) {
    [Globals popupMessage:@"Server failed to retrieve from normal structure."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [gs removeNonFullUserUpdatesForTag:tag];
  }
}

#pragma mark - City

- (void) handleLoadPlayerCityResponseProto:(FullEvent *)fe {
  LoadPlayerCityResponseProto *proto = (LoadPlayerCityResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Load player city response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  
  if (proto.status == LoadPlayerCityResponseProto_LoadPlayerCityStatusSuccess) {
    if ([proto.cityOwner.userUuid isEqualToString:gs.userUuid]) {
      [gs.myStructs removeAllObjects];
      [gs addToMyStructs:proto.ownerNormStructsList];
      
      [gs.myObstacles removeAllObjects];
      [gs addToMyObstacles:proto.obstaclesList];
      
      [gs readjustAllMonsterHealingProtos];
      [gs beginHealingTimer];
      [gs beginMiniJobTimerShowFreeSpeedupImmediately:YES];
      [gs beginEnhanceTimer];
      
      [gs removeNonFullUserUpdatesForTag:tag];
      
      [gs.clanHelpUtil cleanupRogueClanHelps];
      
      // Check for unresponded in app purchases
      NSString *key = IAP_DEFAULTS_KEY;
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
      NSArray *arr = [defaults arrayForKey:key];
      [defaults removeObjectForKey:key];
      for (NSString *receipt in arr) {
        LNLog(@"Sending over unresponded receipt.");
        [[OutgoingEventController sharedOutgoingEventController] inAppPurchase:receipt goldAmt:0 silverAmt:0 product:nil delegate:nil];
      }
    }
  } else if (proto.status == LoadPlayerCityResponseProto_LoadPlayerCityStatusFailNoSuchPlayer) {
    [Globals popupMessage:@"Trying to reach a nonexistent player's city."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to load player city."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleLoadCityResponseProto:(FullEvent *)fe {
  LoadCityResponseProto *proto = (LoadCityResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Load neutral city response received for city %d with status %d.", proto.cityId, (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == LoadCityResponseProto_LoadCityStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else if (proto.status == LoadCityResponseProto_LoadCityStatusNotAccessibleToUser) {
    [Globals popupMessage:@"Trying to reach inaccessible city.."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to load neutral city."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

#pragma mark - Quest

- (void) handleQuestAcceptResponseProto:(FullEvent *)fe {
  QuestAcceptResponseProto *proto = (QuestAcceptResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Quest accept response received with status %d", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status != QuestAcceptResponseProto_QuestAcceptStatusSuccess) {
    [Globals popupMessage:@"Server failed to accept quest"];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [gs removeNonFullUserUpdatesForTag:tag];
  }
}

- (void) handleQuestRedeemResponseProto:(FullEvent *)fe {
  QuestRedeemResponseProto *proto = (QuestRedeemResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Quest redeem response received with status %d", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == QuestRedeemResponseProto_QuestRedeemStatusSuccess) {
    [[GameState sharedGameState] addToAvailableQuests:proto.newlyAvailableQuestsList];
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to redeem quest"];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleQuestProgressResponseProto:(FullEvent *)fe {
  QuestProgressResponseProto *proto = (QuestProgressResponseProto *)fe.event;
  
  LNLog(@"Received quest progress response with status %d.", (int)proto.status);
  
  if (proto.status == QuestProgressResponseProto_QuestProgressStatusSuccess) {
  } else {
    [Globals popupMessage:@"Server sent quest complete for invalid quest"];
  }
}

#pragma mark - User

- (void) handleRetrieveUsersForUserIdsResponseProto:(FullEvent *)fe {
  int tag = fe.tag;
  
  LNLog(@"Retrieve user ids for user received.");
  
  GameState *gs = [GameState sharedGameState];
  [gs removeNonFullUserUpdatesForTag:tag];
}

- (void) handleUpdateUserCurrencyResponseProto:(FullEvent *)fe {
  UpdateUserCurrencyResponseProto *proto = (UpdateUserCurrencyResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Update user currency response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == UpdateUserCurrencyResponseProto_UpdateUserCurrencyStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to update user currency."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleReferralCodeUsedResponseProto:(FullEvent *)fe {
  ReferralCodeUsedResponseProto *proto = (ReferralCodeUsedResponseProto *)fe.event;
  
  LNLog(@"Referral code used received.");
  
  GameState *gs = [GameState sharedGameState];
  UserNotification *un = [[UserNotification alloc] initWithReferralResponse:proto];
  [gs addNotification:un];
}

- (void) handleEnableAPNSResponseProto:(FullEvent *)fe {
  EnableAPNSResponseProto *proto = (EnableAPNSResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Enable apns response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == EnableAPNSResponseProto_EnableAPNSStatusSuccess) {
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleSetGameCenterIdResponseProto:(FullEvent *)fe {
  SetGameCenterIdResponseProto *proto = (SetGameCenterIdResponseProto *)fe.event;
  
  LNLog(@"Set game center response received with status %d.", (int)proto.status);
  if (proto.status != SetGameCenterIdResponseProto_SetGameCenterIdStatusSuccess) {
    [Globals popupMessage:@"Server failed to set game center id."];
  }
}

- (void) handleSetFacebookIdResponseProto:(FullEvent *)fe {
  SetFacebookIdResponseProto *proto = (SetFacebookIdResponseProto *)fe.event;
  
  LNLog(@"Set facebook id response received with status %d.", (int)proto.status);
  
  if (proto.status != SetFacebookIdResponseProto_SetFacebookIdStatusSuccess) {
    GameState *gs = [GameState sharedGameState];
    gs.facebookId = nil;
  }
}

- (void) handleEarnFreeDiamondsResponseProto:(FullEvent *)fe {
  EarnFreeDiamondsResponseProto *proto = (EarnFreeDiamondsResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Earn free diamonds response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == EarnFreeDiamondsResponseProto_EarnFreeDiamondsStatusSuccess) {
    if (proto.freeDiamondsType == EarnFreeDiamondsTypeFbConnect) {
      Globals *gl = [Globals sharedGlobals];
      [Globals popupMessage:[NSString stringWithFormat:@"Congrats! You have received %d gold for connecting to Facebook.", gl.fbConnectRewardDiamonds]];
      gs.hasReceivedfbReward = YES;
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to validate free gold."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handlePurgeClientStaticDataResponseProto:(FullEvent *)fe {
  LNLog(@"Purge static data response received.");
  
  PurgeClientStaticDataResponseProto *proto = (PurgeClientStaticDataResponseProto *)fe.event;
  GameState *gs = [GameState sharedGameState];
  [gs updateStaticData:proto.staticDataStuff];
}

- (void) handleSetAvatarMonsterResponseProto:(FullEvent *)fe {
  SetAvatarMonsterResponseProto *proto = (SetAvatarMonsterResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Set avatar monster response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == SetAvatarMonsterResponseProto_SetAvatarMonsterStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to set avatar monster."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

#pragma mark - Chat

- (void) handleSendGroupChatResponseProto:(FullEvent *)fe {
  SendGroupChatResponseProto *proto = (SendGroupChatResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Send group chat response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == SendGroupChatResponseProto_SendGroupChatStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to send group chat."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleReceivedGroupChatResponseProto:(FullEvent *)fe {
  ReceivedGroupChatResponseProto *proto = (ReceivedGroupChatResponseProto *)fe.event;
  LNLog(@"Received group chat response received.");
  
  // Chats sent from this user will be faked.
  GameState *gs = [GameState sharedGameState];
  if (![proto.sender.minUserProto.userUuid isEqualToString:gs.userUuid]) {
    [gs addChatMessage:proto.sender message:proto.chatMessage scope:proto.scope isAdmin:proto.isAdmin];
    
    Globals *gl = [Globals sharedGlobals];
    if (![gl isUserUuidMuted:proto.sender.minUserProto.userUuid]) {
      NSString *key = proto.scope == GroupChatScopeClan ? CLAN_CHAT_RECEIVED_NOTIFICATION : GLOBAL_CHAT_RECEIVED_NOTIFICATION;
      [[NSNotificationCenter defaultCenter] postNotificationName:key object:nil];
    }
  }
}

- (void) handlePrivateChatPostResponseProto:(FullEvent *)fe {
  PrivateChatPostResponseProto *proto = (PrivateChatPostResponseProto *)fe.event;
  LNLog(@"Private chat post response received with status %d.", (int)proto.status);
  
  if (proto.status == PrivateChatPostResponseProto_PrivateChatPostStatusSuccess) {
    GameState *gs = [GameState sharedGameState];
    [gs addPrivateChat:proto.post];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PRIVATE_CHAT_RECEIVED_NOTIFICATION object:nil userInfo:
     [NSDictionary dictionaryWithObject:proto.post forKey:[NSString stringWithFormat:PRIVATE_CHAT_DEFAULTS_KEY, proto.post.otherUser.userUuid]]];
  }
}

- (void) handleRetrievePrivateChatPostsResponseProto:(FullEvent *)fe {
  RetrievePrivateChatPostsResponseProto *proto = (RetrievePrivateChatPostsResponseProto *)fe.event;
  LNLog(@"Retrieve private chats received with status %d and %d posts.", (int)proto.status,  (int)proto.postsList.count);
}

#pragma mark - Clan

- (void) handleCreateClanResponseProto:(FullEvent *)fe {
  CreateClanResponseProto *proto = (CreateClanResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Create clan response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  
  if (proto.status == CreateClanResponseProto_CreateClanStatusSuccess) {
    if (proto.hasClanInfo) {
      gs.clan = proto.clanInfo;
      [[SocketCommunication sharedSocketCommunication] rebuildSender];
      [gs.requestedClans removeAllObjects];
      gs.myClanStatus = UserClanStatusLeader;
      
      [[NSNotificationCenter defaultCenter] postNotificationName:GAMESTATE_UPDATE_NOTIFICATION object:nil];
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    // Clan controller will print the messages
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleRetrieveClanInfoResponseProto:(FullEvent *)fe {
  RetrieveClanInfoResponseProto *proto = (RetrieveClanInfoResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Retrieve clan response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == RetrieveClanInfoResponseProto_RetrieveClanInfoStatusSuccess) {
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to retrieve squad information."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleApproveOrRejectRequestToJoinClanResponseProto:(FullEvent *)fe {
  ApproveOrRejectRequestToJoinClanResponseProto *proto = (ApproveOrRejectRequestToJoinClanResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Approve or reject request to join clan response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == ApproveOrRejectRequestToJoinClanResponseProto_ApproveOrRejectRequestToJoinClanStatusSuccess) {
    if ([proto.requester.userUuid isEqualToString:gs.userUuid]) {
      [gs.requestedClans removeAllObjects];
      if (proto.accept) {
        gs.clan = proto.minClan;
        [[SocketCommunication sharedSocketCommunication] rebuildSender];
        gs.myClanStatus = UserClanStatusMember;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GAMESTATE_UPDATE_NOTIFICATION object:nil];
        
        [Globals addGreenAlertNotification:[NSString stringWithFormat:@"You have just been accepted to %@!", proto.minClan.name]];
      }
    } else {
      if (proto.accept) {
        [Globals addGreenAlertNotification:[NSString stringWithFormat:@"%@ has just joined your squad. Go say hi!", proto.requester.name]];
      }
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    if (proto.status == ApproveOrRejectRequestToJoinClanResponseProto_ApproveOrRejectRequestToJoinClanStatusFailAlreadyInAClan ||
        proto.status == ApproveOrRejectRequestToJoinClanResponseProto_ApproveOrRejectRequestToJoinClanStatusFailNotAuthorized) {
      [Globals popupMessage:@"Hmm, it seems that this user has already joined another squad."];
    } else if (proto.status == ApproveOrRejectRequestToJoinClanResponseProto_ApproveOrRejectRequestToJoinClanStatusFailClanIsFull) {
      [Globals popupMessage:@"Your squad is full. Boot a member and try again."];
    } else {
      [Globals popupMessage:@"Server failed to respond to squad request."];
    }
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleRequestJoinClanResponseProto:(FullEvent *)fe {
  RequestJoinClanResponseProto *proto = (RequestJoinClanResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Request join clan response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == RequestJoinClanResponseProto_RequestJoinClanStatusSuccessRequest) {
    if ([proto.sender.userUuid isEqualToString:gs.userUuid]) {
      [gs.requestedClans addObject:proto.clanUuid];
    } else {
      if (gs.myClanStatus == UserClanStatusLeader || gs.myClanStatus == UserClanStatusJuniorLeader) {
        [Globals addGreenAlertNotification:[NSString stringWithFormat:@"%@ has just requested to join your squad!", proto.sender.name] isImmediate:NO];
      }
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else if (proto.status == RequestJoinClanResponseProto_RequestJoinClanStatusSuccessJoin) {
    if ([proto.sender.userUuid isEqualToString:gs.userUuid]) {
      [gs.requestedClans removeAllObjects];
      gs.clan = proto.minClan;
      [[SocketCommunication sharedSocketCommunication] rebuildSender];
      gs.myClanStatus = UserClanStatusMember;
      
      [[NSNotificationCenter defaultCenter] postNotificationName:GAMESTATE_UPDATE_NOTIFICATION object:nil];
    } else {
      [Globals addGreenAlertNotification:[NSString stringWithFormat:@"%@ has just joined your squad. Go say hi!", proto.requester.minUserProtoWithLevel.minUserProto.name] isImmediate:NO];
    }
  } else {
    if (proto.status == RequestJoinClanResponseProto_RequestJoinClanStatusFailClanIsFull) {
      [Globals addAlertNotification:@"Sorry, this squad is full. Please try another."];
    } else {
      [Globals popupMessage:@"Server failed to request to join squad request."];
    }
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleRetractRequestJoinClanResponseProto:(FullEvent *)fe {
  RetractRequestJoinClanResponseProto *proto = (RetractRequestJoinClanResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Retract request to join clan response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == RetractRequestJoinClanResponseProto_RetractRequestJoinClanStatusSuccess) {
    if ([proto.sender.userUuid isEqualToString:gs.userUuid]) {
      [gs.requestedClans removeObject:proto.clanUuid];
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to retract squad request."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleTransferClanOwnershipResponseProto:(FullEvent *)fe {
  TransferClanOwnershipResponseProto *proto = (TransferClanOwnershipResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Transfer clan ownership response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == TransferClanOwnershipResponseProto_TransferClanOwnershipStatusSuccess) {
    if (proto.hasMinClan) {
      gs.clan = proto.minClan;
      [[SocketCommunication sharedSocketCommunication] rebuildSender];
    }
    
    if ([proto.clanOwnerNew.userUuid isEqualToString:gs.userUuid]) {
      gs.myClanStatus = UserClanStatusLeader;
    } else if ([proto.sender.userUuid isEqualToString:gs.userUuid]) {
      gs.myClanStatus = UserClanStatusJuniorLeader;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GAMESTATE_UPDATE_NOTIFICATION object:nil];
    
    if ([proto.clanOwnerNew.userUuid isEqualToString:gs.userUuid]) {
      [Globals addGreenAlertNotification:[NSString stringWithFormat:@"You have just become the new squad leader!"] isImmediate:NO];
    } else {
      [Globals addGreenAlertNotification:[NSString stringWithFormat:@"%@ has just become the new squad leader!", proto.clanOwnerNew.name] isImmediate:NO];
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to transfer squad ownership."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleChangeClanSettingsResponseProto:(FullEvent *)fe {
  ChangeClanSettingsResponseProto *proto = (ChangeClanSettingsResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Change clan description response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == ChangeClanSettingsResponseProto_ChangeClanSettingsStatusSuccess) {
    if (proto.hasMinClan) {
      gs.clan = proto.minClan;
      [[SocketCommunication sharedSocketCommunication] rebuildSender];
      
      [[NSNotificationCenter defaultCenter] postNotificationName:GAMESTATE_UPDATE_NOTIFICATION object:nil];
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    if (proto.status == ChangeClanSettingsResponseProto_ChangeClanSettingsStatusFailNotAuthorized) {
      [Globals addAlertNotification:@"You do not have the permissions to change squad settings!"];
    } else if (proto.status == ChangeClanSettingsResponseProto_ChangeClanSettingsStatusFailNotInClan) {
      [Globals addAlertNotification:@"You can't change the settings of a squad you don't belong to!"];
    }
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handlePromoteDemoteClanMemberResponseProto:(FullEvent *)fe {
  PromoteDemoteClanMemberResponseProto *proto = (PromoteDemoteClanMemberResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Promote demote clan member response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == PromoteDemoteClanMemberResponseProto_PromoteDemoteClanMemberStatusSuccess) {
    BOOL isDemotion = proto.prevUserClanStatus < proto.userClanStatus;
    NSString *promoteOrDemote = isDemotion ? @"demoted" : @"promoted";
    NSString *position = [NSString stringWithFormat:@"%@%@", [Globals stringForClanStatus:proto.userClanStatus], isDemotion ? @"." : @"!"];
    NSString *notif = nil;
    if ([proto.victim.userUuid isEqualToString:gs.userUuid]) {
      notif = [NSString stringWithFormat:@"You have just been %@ to %@", promoteOrDemote, position];
      gs.myClanStatus = proto.userClanStatus;
    } else {
      notif = [NSString stringWithFormat:@"%@ has just been %@ to %@", proto.victim.name, promoteOrDemote, position];
    }
    
    if (isDemotion) {
      [Globals addAlertNotification:notif isImmediate:NO];
    } else {
      [Globals addGreenAlertNotification:notif isImmediate:NO];
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to promote or demote player from squad."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleLeaveClanResponseProto:(FullEvent *)fe {
  LeaveClanResponseProto *proto = (LeaveClanResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Leave clan response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == LeaveClanResponseProto_LeaveClanStatusSuccess) {
    if ([proto.sender.userUuid isEqualToString:gs.userUuid]) {
      [gs.requestedClans removeAllObjects];
      gs.clan = nil;
      [[SocketCommunication sharedSocketCommunication] rebuildSender];
      gs.myClanStatus = 0;
      
      [[NSNotificationCenter defaultCenter] postNotificationName:GAMESTATE_UPDATE_NOTIFICATION object:nil];
      
      [gs.clanChatMessages removeAllObjects];
      [[NSNotificationCenter defaultCenter] postNotificationName:CLAN_CHAT_RECEIVED_NOTIFICATION object:nil];
    } else {
      [Globals addAlertNotification:[NSString stringWithFormat:@"%@ has just left your squad.", proto.sender.name] isImmediate:NO];
      
      [gs.clanHelpUtil removeClanHelpsForUserUuid:proto.sender.userUuid];
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to leave squad."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleBootPlayerFromClanResponseProto:(FullEvent *)fe {
  BootPlayerFromClanResponseProto *proto = (BootPlayerFromClanResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Boot player from clan response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == BootPlayerFromClanResponseProto_BootPlayerFromClanStatusSuccess) {
    if ([proto.playerToBoot.userUuid isEqualToString:gs.userUuid]) {
      NSString *clanName = gs.clan.name;
      gs.clan = nil;
      [[SocketCommunication sharedSocketCommunication] rebuildSender];
      gs.myClanStatus = 0;
      
      [[NSNotificationCenter defaultCenter] postNotificationName:GAMESTATE_UPDATE_NOTIFICATION object:nil];
      
      [gs.clanChatMessages removeAllObjects];
      [[NSNotificationCenter defaultCenter] postNotificationName:CLAN_CHAT_RECEIVED_NOTIFICATION object:nil];
      
      if (clanName) {
        [Globals addAlertNotification:[NSString stringWithFormat:@"You have just been booted from %@.", clanName] isImmediate:NO];
      }
    } else {
      [Globals addAlertNotification:[NSString stringWithFormat:@"%@ has just been booted from the squad.", proto.playerToBoot.name] isImmediate:NO];
      
      [gs.clanHelpUtil removeClanHelpsForUserUuid:proto.playerToBoot.userUuid];
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to boot player from squad."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleRetrieveClanDataResponseProto:(FullEvent *)fe {
  RetrieveClanDataResponseProto *proto = (RetrieveClanDataResponseProto *)fe.event;
  LNLog(@"Retrieve clan data response received.");
  
  GameState *gs = [GameState sharedGameState];
  if ([proto.mup.userUuid isEqualToString:gs.userUuid]) {
    [gs updateClanData:proto.clanData];
  }
}

#pragma mark - Clan Help

- (void) handleSolicitClanHelpResponseProto:(FullEvent *)fe {
  SolicitClanHelpResponseProto *proto = (SolicitClanHelpResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Solicit clan help response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == SolicitClanHelpResponseProto_SolicitClanHelpStatusSuccess) {
    [gs.clanHelpUtil addClanHelpProtos:proto.helpProtoList fromUser:nil];
  } else {
    [Globals popupMessage:@"Server failed to solicit clan help."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleGiveClanHelpResponseProto:(FullEvent *)fe {
  GiveClanHelpResponseProto *proto = (GiveClanHelpResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Give clan help response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == GiveClanHelpResponseProto_GiveClanHelpStatusSuccess) {
    [gs.clanHelpUtil addClanHelpProtos:proto.clanHelpsList fromUser:proto.sender];
  } else {
    [Globals popupMessage:@"Server failed to give clan help."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleEndClanHelpResponseProto:(FullEvent *)fe {
  EndClanHelpResponseProto *proto = (EndClanHelpResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"End clan help response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == EndClanHelpResponseProto_EndClanHelpStatusSuccess) {
    [gs.clanHelpUtil removeClanHelpUuids:proto.clanHelpUuidsList];
  } else {
    [Globals popupMessage:@"Server failed to end clan help."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

#pragma mark - Misc

- (void) handleDevResponseProto:(FullEvent *)fe {
  DevResponseProto *proto = (DevResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Dev response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == DevResponseProto_DevStatusSuccess) {
#warning add back..
//    [gs addToMyMonsters:proto.fumpList];
//    [gs.itemUtil addToMyItems:@[proto.uip]];
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to execute cheat code."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleSendAdminMessageResponseProto:(FullEvent *)fe {
  SendAdminMessageResponseProto *proto = (SendAdminMessageResponseProto *)fe.event;
  
  LNLog(@"Send admin message response received");
  
  [Globals popupMessage:proto.message];
}

- (void) handleGeneralNotificationResponseProto:(FullEvent *)fe {
  GeneralNotificationResponseProto *proto = (GeneralNotificationResponseProto *)fe.event;
  
  LNLog(@"General notification received with title \"%@\".", proto.title);
  
  //  TopBar *tb = [TopBar sharedTopBar];
  //  UIColor *c = [Globals colorForColorProto:proto.rgb];
  //  UserNotification *un = [[UserNotification alloc] initWithTitle:proto.title subtitle:proto.subtitle color:c];
  //  [tb addNotificationToDisplayQueue:un];
  //  [un release];
}

#pragma mark - Enhance

- (void) handleEnhanceMonsterResponseProto:(FullEvent *)fe {
  EnhanceMonsterResponseProto *proto = (EnhanceMonsterResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Enhance monster received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == EnhanceMonsterResponseProto_EnhanceMonsterStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to enhance monster."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleSubmitMonsterEnhancementResponseProto:(FullEvent *)fe {
  SubmitMonsterEnhancementResponseProto *proto = (SubmitMonsterEnhancementResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Submit monster enhancement received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == SubmitMonsterEnhancementResponseProto_SubmitMonsterEnhancementStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to submit monster enhancement."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleEnhancementWaitTimeCompleteResponseProto:(FullEvent *)fe {
  EnhancementWaitTimeCompleteResponseProto *proto = (EnhancementWaitTimeCompleteResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Enhancement wait time complete received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == EnhancementWaitTimeCompleteResponseProto_EnhancementWaitTimeCompleteStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to complete enhance wait time."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleCollectMonsterEnhancementResponseProto:(FullEvent *)fe {
  CollectMonsterEnhancementResponseProto *proto = (CollectMonsterEnhancementResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Collect monster enhancement received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == CollectMonsterEnhancementResponseProto_CollectMonsterEnhancementStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to collect monster enhancement."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

#pragma mark - Booster pack

- (void) handlePurchaseBoosterPackResponseProto:(FullEvent *)fe {
  PurchaseBoosterPackResponseProto *proto = (PurchaseBoosterPackResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Purchase booster pack received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatusSuccess) {
    [gs addToMyMonsters:proto.updatedOrNewList];

    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to purchase booster pack."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleTradeItemForBoosterResponseProto:(FullEvent *)fe {
  TradeItemForBoosterResponseProto *proto = (TradeItemForBoosterResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Trade item for booster pack received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == TradeItemForBoosterResponseProto_TradeItemForBoosterStatusSuccess) {
    [gs addToMyMonsters:proto.updatedOrNewList];
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to redeem booster pack."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleReceivedRareBoosterPurchaseResponseProto:(FullEvent *)fe {
  ReceivedRareBoosterPurchaseResponseProto *proto = (ReceivedRareBoosterPurchaseResponseProto *)fe.event;
  GameState *gs = [GameState sharedGameState];
  [gs addBoosterPurchase:proto.rareBoosterPurchase];
}

#pragma mark - Dungeon

- (void) handleBeginDungeonResponseProto:(FullEvent *)fe {
  BeginDungeonResponseProto *proto = (BeginDungeonResponseProto *)fe.event;
  LNLog(@"Begin dungeon response received with status %d.", (int)proto.status);
  
  if (proto.status == BeginDungeonResponseProto_BeginDungeonStatusSuccess) {
  } else {
    [Globals popupMessage:@"Server failed to enter dungeon."];
  }
}

- (void) handleEndDungeonResponseProto:(FullEvent *)fe {
  EndDungeonResponseProto *proto = (EndDungeonResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"End dungeon response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == EndDungeonResponseProto_EndDungeonStatusSuccess) {
    [gs addToMyMonsters:proto.updatedOrNewList];
    
    if (proto.userWon) {
      [gs.completedTasks addObject:@(proto.taskId)];
    }
    
    if (proto.hasUserItem) {
      [gs.itemUtil addToMyItems:@[proto.userItem]];
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to end dungeon."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleReviveInDungeonResponseProto:(FullEvent *)fe {
  ReviveInDungeonResponseProto *proto = (ReviveInDungeonResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Revive in dungeon response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == ReviveInDungeonResponseProto_ReviveInDungeonStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to revive in dungeon."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

#pragma mark - PVP

- (void) handleQueueUpResponseProto:(FullEvent *)fe {
  QueueUpResponseProto *proto = (QueueUpResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Queue up response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == QueueUpResponseProto_QueueUpStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to queue up."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleBeginPvpBattleResponseProto:(FullEvent *)fe {
  BeginPvpBattleResponseProto *proto = (BeginPvpBattleResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Begin pvp battle response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == BeginPvpBattleResponseProto_BeginPvpBattleStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to begin pvp battle."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleEndPvpBattleResponseProto:(FullEvent *)fe {
  EndPvpBattleResponseProto *proto = (EndPvpBattleResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"End pvp battle response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == BeginPvpBattleResponseProto_BeginPvpBattleStatusSuccess) {
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to end pvp battle."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

#pragma mark - Healing

- (void) handleHealMonsterResponseProto:(FullEvent *)fe {
  HealMonsterResponseProto *proto = (HealMonsterResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Heal monster response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == HealMonsterResponseProto_HealMonsterStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to handle heal monster."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

#pragma mark - Team

- (void) handleAddMonsterToBattleTeamResponseProto:(FullEvent *)fe {
  AddMonsterToBattleTeamResponseProto *proto = (AddMonsterToBattleTeamResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Add monster to squad response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == AddMonsterToBattleTeamResponseProto_AddMonsterToBattleTeamStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to handle add monster."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleRemoveMonsterFromBattleTeamResponseProto:(FullEvent *)fe {
  RemoveMonsterFromBattleTeamResponseProto *proto = (RemoveMonsterFromBattleTeamResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Remove monster from squad response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == RemoveMonsterFromBattleTeamResponseProto_RemoveMonsterFromBattleTeamStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to handle remove monster."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleIncreaseMonsterInventorySlotResponseProto:(FullEvent *)fe {
  IncreaseMonsterInventorySlotResponseProto *proto = (IncreaseMonsterInventorySlotResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Increase monster inventory slots response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == IncreaseMonsterInventorySlotResponseProto_IncreaseMonsterInventorySlotStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to handle buying inventory slots."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleUpdateMonsterHealthResponseProto:(FullEvent *)fe {
  UpdateMonsterHealthResponseProto *proto = (UpdateMonsterHealthResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Update monster health response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == IncreaseMonsterInventorySlotResponseProto_IncreaseMonsterInventorySlotStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to handle update monster health."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleCombineUserMonsterPiecesResponseProto:(FullEvent *)fe {
  CombineUserMonsterPiecesResponseProto *proto = (CombineUserMonsterPiecesResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Combine user monster response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == CombineUserMonsterPiecesResponseProto_CombineUserMonsterPiecesStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to combine user monster."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleSellUserMonsterResponseProto:(FullEvent *)fe {
  SellUserMonsterResponseProto *proto = (SellUserMonsterResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Sell user monster response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == SellUserMonsterResponseProto_SellUserMonsterStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to sell user monster."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleRestrictUserMonsterResponseProto:(FullEvent *)fe {
  RestrictUserMonsterResponseProto *proto = (RestrictUserMonsterResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Restrict user monster response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == RestrictUserMonsterResponseProto_RestrictUserMonsterStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to restrict user monster."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleUnrestrictUserMonsterResponseProto:(FullEvent *)fe {
  UnrestrictUserMonsterResponseProto *proto = (UnrestrictUserMonsterResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Unrestrict user monster response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == UnrestrictUserMonsterResponseProto_UnrestrictUserMonsterStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to unrestrict user monster."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

#pragma mark - Invites

- (void) handleInviteFbFriendsForSlotsResponseProto:(FullEvent *)fe {
  InviteFbFriendsForSlotsResponseProto *proto = (InviteFbFriendsForSlotsResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Invite fb friends for slots response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == InviteFbFriendsForSlotsResponseProto_InviteFbFriendsForSlotsStatusSuccess) {
    [gs addInventorySlotsRequests:proto.invitesNewList];
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to invite fb friends for slots."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleAcceptAndRejectFbInviteForSlotsResponseProto:(FullEvent *)fe {
  AcceptAndRejectFbInviteForSlotsResponseProto *proto = (AcceptAndRejectFbInviteForSlotsResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Accept and reject fb invite for slots response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == AcceptAndRejectFbInviteForSlotsResponseProto_AcceptAndRejectFbInviteForSlotsStatusSuccess) {
    [gs addInventorySlotsRequests:proto.acceptedInvitesList];
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    if (proto.status == AcceptAndRejectFbInviteForSlotsResponseProto_AcceptAndRejectFbInviteForSlotsStatusFailAlreadyBeenUsed ||
        proto.status == AcceptAndRejectFbInviteForSlotsResponseProto_AcceptAndRejectFbInviteForSlotsStatusFailExpired) {
      // Silently fail
    } else {
      [Globals popupMessage:@"Server failed to accept/reject slot invites."];
    }
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

#pragma mark - Evolve

- (void) handleEvolveMonsterResponseProto:(FullEvent *)fe {
  EvolveMonsterResponseProto *proto = (EvolveMonsterResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Evolve monster response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == EvolveMonsterResponseProto_EvolveMonsterStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to evolve monster."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleEvolutionFinishedResponseProto:(FullEvent *)fe {
  EvolutionFinishedResponseProto *proto = (EvolutionFinishedResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Evolution finished response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == EvolutionFinishedResponseProto_EvolutionFinishedStatusSuccess) {
    [gs addToMyMonsters:@[proto.evolvedMonster]];
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to complete evolution."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

#pragma mark - Raids

- (void) handleBeginClanRaidResponseProto:(FullEvent *)fe {
  BeginClanRaidResponseProto *proto = (BeginClanRaidResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Begin clan raid response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == BeginClanRaidResponseProto_BeginClanRaidStatusSuccess) {
    if (proto.hasEventDetails) {
      gs.curClanRaidInfo = proto.eventDetails;
    }
    if (proto.hasUserDetails) {
      [gs addClanRaidUserInfo:proto.userDetails];
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to begin clan raid."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleAttackClanRaidMonsterResponseProto:(FullEvent *)fe {
  AttackClanRaidMonsterResponseProto *proto = (AttackClanRaidMonsterResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Attack clan raid monster response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == AttackClanRaidMonsterResponseProto_AttackClanRaidMonsterStatusSuccess ||
      proto.status == AttackClanRaidMonsterResponseProto_AttackClanRaidMonsterStatusSuccessMonsterJustDied) {
    NSDictionary *dict = [NSDictionary dictionaryWithObject:proto forKey:CLAN_RAID_ATTACK_KEY];
    [[NSNotificationCenter defaultCenter] postNotificationName:CLAN_RAID_ATTACK_NOTIFICATION object:nil userInfo:dict];
    
    if (proto.hasEventDetails) {
      gs.curClanRaidInfo = proto.eventDetails;
    }
    for (PersistentClanEventUserInfoProto *ui in proto.clanUsersDetailsList) {
      [gs addClanRaidUserInfo:ui];
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to attack clan raid monster."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

#pragma mark - Obstacle

- (void) handleSpawnObstacleResponseProto:(FullEvent *)fe {
  SpawnObstacleResponseProto *proto = (SpawnObstacleResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Spawn obstacle response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == SpawnObstacleResponseProto_SpawnObstacleStatusSuccess) {
    [gs addToMyObstacles:proto.spawnedObstaclesList];
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to spawn obstacles."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleBeginObstacleRemovalResponseProto:(FullEvent *)fe {
  BeginObstacleRemovalResponseProto *proto = (BeginObstacleRemovalResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Begin obstacle removal response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == BeginObstacleRemovalResponseProto_BeginObstacleRemovalStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to begin obstacle removal."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleObstacleRemovalCompleteResponseProto:(FullEvent *)fe {
  ObstacleRemovalCompleteResponseProto *proto = (ObstacleRemovalCompleteResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Obstacle removal complete response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == ObstacleRemovalCompleteResponseProto_ObstacleRemovalCompleteStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to complete obstacle removal."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

#pragma mark - Achievement

- (void) handleAchievementProgressResponseProto:(FullEvent *)fe {
  AchievementProgressResponseProto *proto = (AchievementProgressResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Achievement progress response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == AchievementProgressResponseProto_AchievementProgressStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to progress achievement."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleAchievementRedeemResponseProto:(FullEvent *)fe {
  AchievementRedeemResponseProto *proto = (AchievementRedeemResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Achievement redeem response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == AchievementRedeemResponseProto_AchievementRedeemStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to redeem achievement."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

#pragma mark - Mini Job

- (void) handleSpawnMiniJobResponseProto:(FullEvent *)fe {
  SpawnMiniJobResponseProto *proto = (SpawnMiniJobResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Spawn mini job response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == SpawnMiniJobResponseProto_SpawnMiniJobStatusSuccess) {
    [gs addToMiniJobs:proto.miniJobsList isNew:YES];
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to spawn mini job."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleBeginMiniJobResponseProto:(FullEvent *)fe {
  BeginMiniJobResponseProto *proto = (BeginMiniJobResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Begin mini job response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == BeginMiniJobResponseProto_BeginMiniJobStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to begin mini job."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleCompleteMiniJobResponseProto:(FullEvent *)fe {
  CompleteMiniJobResponseProto *proto = (CompleteMiniJobResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Complete mini job response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == CompleteMiniJobResponseProto_CompleteMiniJobStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to complete mini job."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleRedeemMiniJobResponseProto:(FullEvent *)fe {
  RedeemMiniJobResponseProto *proto = (RedeemMiniJobResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Redeem mini job response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == RedeemMiniJobResponseProto_RedeemMiniJobStatusSuccess) {
    if (proto.hasFump) {
      [gs addToMyMonsters:@[proto.fump]];
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to redeem mini job."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

@end
