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
#import "MiniEventManager.h"
#import "ChatView.h"
#import "TangoDelegate.h"

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
    case EventProtocolResponseSTradeItemForSpeedUpsEvent:
      responseClass = [TradeItemForSpeedUpsResponseProto class];
      break;
    case EventProtocolResponseSRemoveUserItemUsedEvent:
      responseClass = [RemoveUserItemUsedResponseProto class];
      break;
    case EventProtocolResponseSTradeItemForResourcesEvent:
      responseClass = [TradeItemForResourcesResponseProto class];
      break;
    case EventProtocolResponseSRedeemSecretGiftEvent:
      responseClass = [RedeemSecretGiftResponseProto class];
      break;
    case EventProtocolResponseSSetDefendingMsgEvent:
      responseClass = [SetDefendingMsgResponseProto class];
      break;
    case EventProtocolResponseSBeginClanAvengingEvent:
      responseClass = [BeginClanAvengingResponseProto class];
      break;
    case EventProtocolResponseSEndClanAvengingEvent:
      responseClass = [EndClanAvengingResponseProto class];
      break;
    case EventProtocolResponseSAvengeClanMateEvent:
      responseClass = [AvengeClanMateResponseProto class];
      break;
    case EventProtocolResponseSUpdateClientTaskStateEvent:
      responseClass = [UpdateClientTaskStateResponseProto class];
      break;
    case EventProtocolResponseSSolicitTeamDonationEvent:
      responseClass = [SolicitTeamDonationResponseProto class];
      break;
    case EventProtocolResponseSFulfillTeamDonationSolicitationEvent:
      responseClass = [FulfillTeamDonationSolicitationResponseProto class];
      break;
    case EventProtocolResponseSVoidTeamDonationSolicitationEvent:
      responseClass = [VoidTeamDonationSolicitationResponseProto class];
      break;
    case EventProtocolResponseSRetrieveUserMonsterTeamEvent:
      responseClass = [RetrieveUserMonsterTeamResponseProto class];
      break;
    case EventProtocolResponseSCustomizePvpBoardObstacleEvent:
      responseClass = [CustomizePvpBoardObstacleResponseProto class];
      break;
    case EventProtocolResponseSCreateBattleItemEvent:
      responseClass = [CreateBattleItemResponseProto class];
      break;
    case EventProtocolResponseSCompleteBattleItemEvent:
      responseClass = [CompleteBattleItemResponseProto class];
      break;
    case EventProtocolResponseSDiscardBattleItemEvent:
      responseClass = [DiscardBattleItemResponseProto class];
      break;
    case EventProtocolResponseSPerformResearchEvent:
      responseClass = [PerformResearchResponseProto class];
      break;
    case EventProtocolResponseSFinishPerformingResearchEvent:
      responseClass = [FinishPerformingResearchResponseProto class];
      break;
    case EventProtocolResponseSUpdateUserStrengthEvent:
      responseClass = [UpdateUserStrengthResponseProto class];
      break;
    case EventProtocolResponseSTranslateSelectMessagesEvent:
      responseClass = [TranslateSelectMessagesResponseProto class];
      break;
    case EventProtocolResponseSRedeemMiniEventRewardEvent:
      responseClass = [RedeemMiniEventRewardResponseProto class];
      break;
    case EventProtocolResponseSRetrieveMiniEventEvent:
      responseClass = [RetrieveMiniEventResponseProto class];
      break;
    case EventProtocolResponseSUpdateMiniEventEvent:
      responseClass = [UpdateMiniEventResponseProto class];
      break;
    case EventProtocolResponseSRefreshMiniJobEvent:
      responseClass = [RefreshMiniJobResponseProto class];
      break;
    case EventProtocolResponseSSendTangoGiftEvent:
      responseClass = [SendTangoGiftResponseProto class];
      break;
    case EventProtocolResponseSCollectClanGiftsEvent:
      responseClass = [CollectClanGiftsResponseProto class];
      break;
    case EventProtocolResponseSClearExpiredClanGiftsEvent:
      responseClass = [ClearExpiredClanGiftsResponseProto class];
      break;
    case EventProtocolResponseSReceivedClanGiftsEvent:
      responseClass = [ReceivedClanGiftResponseProto class];
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
  
  gs.userHasEnteredBattleThisSession = NO;
  
  [MSDate setServerTime:proto.serverTimeMillis];
  
  if (gs.isTutorial) {
    return;
  }
  
  gl.appStoreLink = proto.appStoreUrl;
  gl.reviewPageURL = proto.reviewPageUrl;
  gl.reviewPageConfirmationMessage = proto.reviewPageConfirmationMessage;
  
  if (proto.updateStatus == StartupResponseProto_UpdateStatusMajorUpdate) {
    [GenericPopupController displayNotificationViewWithText:@"We've added a slew of new features! Update now to check them out." title:@"Update Now" okayButton:@"Update" target:gl selector:@selector(openAppStoreLink)];
    return;
  } else if (proto.updateStatus == StartupResponseProto_UpdateStatusMinorUpdate) {
    [GenericPopupController displayConfirmationWithDescription:@"An update is available. Head over to the App Store to download it now!" title:@"Update Available" okayButton:@"Update" cancelButton:@"Later" target:gl selector:@selector(openAppStoreLink)];
  }
  
  [gl updateConstants:proto.startupConstants];
  [gs updateStaticData:proto.staticDataStuffProto];
  
  gs.connected = YES;
  
  if (proto.startupStatus == StartupResponseProto_StartupStatusUserInDb) {
    if (!proto.sender.hasUserUuid || proto.sender.userUuid.length == 0) {
      LNLog(@"Received user id 0..");
      return;
    }
    
    // Remove structs so that the capacities don't get calculated till load player city
    [gs.myStructs removeAllObjects];
    
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
    
    // Make sure researchUtil happens before monsters or else the monsters will not have any research benefits
    gs.itemUtil = [[ItemUtil alloc] initWithItemProtos:proto.userItemsList itemUsageProtos:proto.itemsInUseList];
    gs.researchUtil = [[ResearchUtil alloc] initWithResearches:proto.userResearchsList];
    gs.mySecretGifts = [proto.giftsList mutableCopy];
    
    //    [Globals asyncDownloadBundles];
    [gs.myMonsters removeAllObjects];
    [gs addToMyMonsters:proto.usersMonstersList];
    
    [gs.monsterHealingQueues removeAllObjects];
    [gs addAllMonsterHealingProtos:proto.monstersHealingList];
    
    [gs.mySales removeAllObjects];
    [gs.mySales addObjectsFromArray:proto.salesPackagesList];
    
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
    
    gs.battleItemUtil = [[BattleItemUtil alloc] init];
    [gs.battleItemUtil updateWithQueueProtos:proto.battleItemQueueList itemProtos:proto.battleItemList];
    [gs beginBattleItemTimer];
    
    [gs addToCompleteTasks:proto.completedTasksList];
    
    [gs.myMiniJobs removeAllObjects];
    [gs addToMiniJobs:proto.userMiniJobProtosList isNew:NO];
    
    [gs beginResearchTimer];
    
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
      cm.isRead = YES;
      [gs addChatMessage:cm scope:ChatScopeGlobal];
    }
    for (PrivateChatPostProto *pcpp in proto.pcppList) {
      [gs addPrivateChat:pcpp];
    }
    
    [gs.privateChatLanguages removeAllObjects];
    gs.globalLanguage = proto.userDefaultLanguages.globalDefaultLanguage;
    gs.globalTranslationOn = proto.userDefaultLanguages.globalTranslateOn;
    for (PrivateChatDefaultLanguageProto *pcdl in proto.userDefaultLanguages.privateDefaultLanguageList) {
      [gs.privateChatLanguages setValue:@(pcdl.defaultLanguage) forKey:pcdl.senderUserId];
      [gs.privateTranslationOn setValue:@(pcdl.translateOn) forKey:pcdl.senderUserId];
    }
    
    if (proto.recentNbattlesList.count) {
      gs.battleHistory = [proto.recentNbattlesList mutableCopy];
    } else {
      gs.battleHistory = [NSMutableArray array];
    }

    [gs updateClanData:proto.clanData];

    [gs.clanGifts removeAllObjects];
    [gs.clanGifts addObjectsFromArray:proto.userClanGiftsList];
    
    gs.myPvpBoardObstacles = [proto.userPvpBoardObstaclesList mutableCopy];

    [[MiniEventManager sharedInstance] handleUserMiniEventReceivedOnStartup:proto.hasUserMiniEvent ? proto.userMiniEvent : nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults boolForKey:[Globals userConfimredPushNotificationsKey]]) {
      //this case is just the register the user if they have already accepted to register in a previous session
      [Globals registerUserForPushNotifications];
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
  
  [Globals backgroundDownloadFiles:proto.startupConstants.fileDownloadProtoList];
  
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
  
  NSInteger idx = [arr indexOfObject:proto.receipt];
  
  if (idx != NSNotFound) {
    // Remove the receipt and then the uuid
    [arr removeObjectAtIndex:idx];
    [arr removeObjectAtIndex:idx];
  }
  
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
    [gs removeNonFullUserUpdatesForTag:tag];
    
    if (proto.rewards.updatedOrNewMonstersList) {
      [gs addToMyMonsters:proto.rewards.updatedOrNewMonstersList];
    }
    
    if (proto.rewards.updatedUserItemsList) {
      [gs.itemUtil addToMyItems:proto.rewards.updatedUserItemsList];
    }
    
    if (proto.updatedMoneyTreeList) {
      [gs addToMyStructs:proto.updatedMoneyTreeList];
    }
    
    // Replace the sales
    if (proto.hasPurchasedSalesPackage) {
      SalesPackageProto *spp = proto.purchasedSalesPackage;
      SalesPackageProto *nextSpp = proto.successorSalesPackage;
      NSString *uuid = spp.uuid;
      NSString *nextUuid = nextSpp.uuid;
      
      NSInteger idx = -1;
      BOOL alreadyHasSuccessorPack = NO;
      for (SalesPackageProto *s in gs.mySales) {
        if ([s.uuid isEqualToString:uuid]) {
          idx = [gs.mySales indexOfObject:s];
        }
        
        if ([s.uuid isEqualToString:nextUuid]) {
          alreadyHasSuccessorPack = YES;
        }
      }
      
      if (idx != -1) {
        if (proto.hasSuccessorSalesPackage && !alreadyHasSuccessorPack) {
          [gs.mySales replaceObjectAtIndex:idx withObject:nextSpp];
        } else {
          [gs.mySales removeObjectAtIndex:idx];
        }
      }
    }
    
    // Post notification so all UI with that bar can update
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:IAP_SUCCESS_NOTIFICATION object:nil userInfo:@{IAP_RESPONSE_KEY : proto}]];
    
    SKPaymentTransaction *lastTransaction = iap.lastTransaction;
    SKProduct *prod = [iap.products objectForKey:lastTransaction.payment.productIdentifier];
    NSString *uuid = proto.purchasedSalesPackage.uuid;
    if (lastTransaction && prod) {
      NSString *encodedReceipt = [iap base64forData:lastTransaction.transactionReceipt];
      if ([encodedReceipt isEqualToString:proto.receipt]) {
        [Analytics iapWithSKProduct:prod forTransacton:lastTransaction amountUS:proto.packagePrice uuid:uuid];
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
  
  LNLog(@"Move norm struct response received with status: %d.", (int)proto.status);
  
  if (proto.status != MoveOrRotateNormStructureResponseProto_MoveOrRotateNormStructureStatusSuccess) {
    [Globals popupMessage:@"Server failed to change building location or orientation."];
  } else {
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
      
      for (HospitalQueue *hq in gs.monsterHealingQueues.allValues) {
        [hq readjustAllMonsterHealingProtos];
      }
      
      [gs beginHealingTimer];
      [gs beginMiniJobTimerShowFreeSpeedupImmediately:YES];
      [gs beginEnhanceTimer];
      [gs beginResearchTimer];
      
      [gs removeNonFullUserUpdatesForTag:tag];
      
      [gs.clanHelpUtil cleanupRogueClanHelps];
      [gs.itemUtil cleanupRogueItemUsages];
      
      [gs checkMaxResourceCapacities];
      [gs recalculateStrength];
      
      // Check for unresponded in app purchases
      NSString *key = IAP_DEFAULTS_KEY;
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
      NSArray *arr = [defaults arrayForKey:key];
      [defaults removeObjectForKey:key];
      for (int i = 0; i+1 < arr.count; i++) {
        NSString *receipt = arr[i];
        NSString *uuid = arr[i+1];
        
        LNLog(@"Sending over unresponded receipt.");
        [[OutgoingEventController sharedOutgoingEventController] inAppPurchase:receipt goldAmt:0 silverAmt:0 product:nil saleUuid:uuid delegate:nil];
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

- (void) handleSetDefendingMsgResponseProto:(FullEvent *)fe {
  SetDefendingMsgResponseProto *proto = (SetDefendingMsgResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Set defending message response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == SetDefendingMsgResponseProto_SetDefendingMsgStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to set defending message."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleUpdateUserStrengthResponseProto:(FullEvent *)fe {
  UpdateUserStrengthResponseProto *proto = (UpdateUserStrengthResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Update user strength response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == UpdateUserStrengthResponseProto_UpdateUserStrengthStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to update user strength message."];
    
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
    ChatMessage *cm = [[ChatMessage alloc] initWithProto:proto.message];
    [gs addChatMessage:cm scope:proto.scope];
    
    Globals *gl = [Globals sharedGlobals];
    if (![gl isUserUuidMuted:proto.sender.minUserProto.userUuid]) {
      NSString *key = proto.scope == ChatScopeClan ? CLAN_CHAT_RECEIVED_NOTIFICATION : GLOBAL_CHAT_RECEIVED_NOTIFICATION;
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
    //add here
    //okay I will
    if (![gs.privateChatLanguages valueForKey:proto.post.poster.minUserProto.userUuid]) {
      [gs.privateChatLanguages setValue:@(proto.translationSetting.defaultLanguage) forKey:proto.post.poster.minUserProto.userUuid];
      [gs.privateTranslationOn setValue:@(proto.translationSetting.translateOn) forKey:proto.post.poster.minUserProto.userUuid];
    }
    
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
      
      [AchievementUtil checkClanJoined];
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
        
        [AchievementUtil checkClanJoined];
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
      
      [AchievementUtil checkClanJoined];
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
      
      [gs updateClanData:nil];
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
      
      [gs updateClanData:nil];
      
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
  LNLog(@"Solicit clan help response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == SolicitClanHelpResponseProto_SolicitClanHelpStatusSuccess) {
    [gs.clanHelpUtil addClanHelpProtos:proto.helpProtoList fromUser:nil];
  } else {
    [Globals popupMessage:@"Server failed to solicit clan help."];
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
  
  LNLog(@"End clan help response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == EndClanHelpResponseProto_EndClanHelpStatusSuccess) {
    [gs.clanHelpUtil removeClanHelpUuids:proto.clanHelpUuidsList];
  } else {
    [Globals popupMessage:@"Server failed to end clan help."];
  }
}

#pragma mark - Clan Avenge

- (void) handleBeginClanAvengingResponseProto:(FullEvent *)fe {
  BeginClanAvengingResponseProto *proto = (BeginClanAvengingResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Begin clan avenge response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == BeginClanAvengingResponseProto_BeginClanAvengingStatusSuccess) {
    [gs addClanAvengings:proto.clanAvengingsList];
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to begin clan avenge."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleAvengeClanMateResponseProto:(FullEvent *)fe {
  AvengeClanMateResponseProto *proto = (AvengeClanMateResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Avenge clan mate response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == AvengeClanMateResponseProto_AvengeClanMateStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to avenge clan mate."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleEndClanAvengingResponseProto:(FullEvent *)fe {
  EndClanAvengingResponseProto *proto = (EndClanAvengingResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"End clan avenge response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == EndClanAvengingResponseProto_EndClanAvengingStatusSuccess) {
    [gs removeClanAvengings:proto.clanAvengeUuidsList];
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to end clan avenge."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

#pragma mark - Clan Team Donation

- (void) handleSolicitTeamDonationResponseProto:(FullEvent *)fe {
  SolicitTeamDonationResponseProto *proto = (SolicitTeamDonationResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Solicit team donation response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == SolicitClanHelpResponseProto_SolicitClanHelpStatusSuccess) {
    [gs.clanTeamDonateUtil addClanTeamDonations:@[proto.solicitation]];
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to solicit team donation."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleFulfillTeamDonationSolicitationResponseProto:(FullEvent *)fe {
  FulfillTeamDonationSolicitationResponseProto *proto = (FulfillTeamDonationSolicitationResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Fulfill team donation response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == FulfillTeamDonationSolicitationResponseProto_FulfillTeamDonationSolicitationStatusSuccess) {
    [gs.clanTeamDonateUtil addClanTeamDonations:@[proto.solicitation]];
    
    UserMonsterSnapshotProto *snap = [proto.solicitation.donationsList firstObject];
    UserMonster *um = [gs myMonsterWithUserMonsterUuid:snap.monsterForUserUuid];
    um.curHealth = 0;
    
    // So that hospital bubbles reload
    [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    if (proto.status == FulfillTeamDonationSolicitationResponseProto_FulfillTeamDonationSolicitationStatusFailAlreadyFulfilled) {
      [Globals addAlertNotification:@"Sorry, this team donation request has already been fulfilled."];
    } else {
      [Globals popupMessage:@"Server failed to fulfill team donation."];
    }
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleVoidTeamDonationSolicitationResponseProto:(FullEvent *)fe {
  VoidTeamDonationSolicitationResponseProto *proto = (VoidTeamDonationSolicitationResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Void team donation response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == VoidTeamDonationSolicitationResponseProto_VoidTeamDonationSolicitationStatusSuccess) {
    [gs.clanTeamDonateUtil removeClanTeamDonationWithUuids:proto.clanTeamDonateUuidList];
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to void team donation."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

#pragma mark - Clan Gifts

- (void) handleReceivedClanGiftResponseProto:(FullEvent *)fe {
  ReceivedClanGiftResponseProto *proto = (ReceivedClanGiftResponseProto *)fe.event;
  
  GameState *gs = [GameState sharedGameState];
  if (![proto.sender.userUuid isEqualToString:gs.userUuid]) {
    LNLog(@"Recieving Clan Gifts");
    
    [gs.clanGifts addObjectsFromArray:proto.userClanGiftsList];
    [Globals addClanGiftNotification:proto.userClanGiftsList];
    [[NSNotificationCenter defaultCenter] postNotificationName:CLAN_GIFTS_CHANGED_NOTIFICATION object:nil];
  }
  
}

- (void) handleCollectClanGiftsResponseProto:(FullEvent *)fe {
  CollectClanGiftsResponseProto *proto = (CollectClanGiftsResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Collect Clan Gifts response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == CollectClanGiftsResponseProto_CollectClanGiftsStatusSuccess) {
    // Gems, oil, and cash are updated through UpdateUserClientResponseEvent. Don't do anything here
    if (proto.reward.updatedOrNewMonstersList.count) {
      [gs addToMyMonsters:proto.reward.updatedOrNewMonstersList];
    }
    
    if (proto.reward.updatedUserItemsList.count) {
      [gs.itemUtil addToMyItems:proto.reward.updatedUserItemsList];
    }
  } else {
    [Globals popupMessage:@"Server failed to redeem clan gift(s)."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleClearExpiredClanGiftsResponseProto:(FullEvent *)fe {
  ClearExpiredClanGiftsResponseProto *proto = (ClearExpiredClanGiftsResponseProto *)fe.event;
  
  LNLog(@"Clear Expired Clan Gifts received with status %d.", (int)proto.status);
  
  if (proto.status == ClearExpiredClanGiftsResponseProto_ClearExpiredClanGiftsStatusSuccess) {
    
  } else {
    [Globals popupMessage:@"Server fail to clear expired gift(s)."];
  }
}

#pragma mark - Speedups/Items

- (void) handleTradeItemForSpeedUpsResponseProto:(FullEvent *)fe {
  TradeItemForSpeedUpsResponseProto *proto = (TradeItemForSpeedUpsResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Trade item for speed ups response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == TradeItemForSpeedUpsResponseProto_TradeItemForSpeedUpsStatusSuccess) {
    [gs.itemUtil addToMyItemUsages:proto.itemsUsedList];
  } else {
    [Globals popupMessage:@"Server failed to trade item for speed up."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleRemoveUserItemUsedResponseProto:(FullEvent *)fe {
  RemoveUserItemUsedResponseProto *proto = (RemoveUserItemUsedResponseProto *)fe.event;
  
  LNLog(@"Remove user item usage response received with status %d.", (int)proto.status);
  
  if (proto.status == RemoveUserItemUsedResponseProto_RemoveUserItemUsedStatusSuccess) {
  } else {
    [Globals popupMessage:@"Server failed to remove user item usages."];
  }
}

- (void) handleTradeItemForResourcesResponseProto:(FullEvent *)fe {
  TradeItemForResourcesResponseProto *proto = (TradeItemForResourcesResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Trade item for resources response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == TradeItemForResourcesResponseProto_TradeItemForResourcesStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to trade item for resources."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleRedeemSecretGiftResponseProto:(FullEvent *)fe {
  RedeemSecretGiftResponseProto *proto = (RedeemSecretGiftResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Redeem secret gift response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == RedeemSecretGiftResponseProto_RedeemSecretGiftStatusSuccess) {
    [gs.mySecretGifts addObjectsFromArray:proto.nuGiftsList];
  } else {
    [Globals popupMessage:@"Server failed to redeem secret gift response."];
    
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
    [gs addToMyMonsters:proto.fumpList];
    
    if (proto.hasUip) {
      [gs.itemUtil addToMyItems:@[proto.uip]];
    }
    
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
    // Gems, oil, and cash are updated through UpdateUserClientResponseEvent. Don't do anything here
    if (proto.reward.updatedOrNewMonstersList.count) {
      [gs addToMyMonsters:proto.reward.updatedOrNewMonstersList];
    }
    
    if (proto.reward.updatedUserItemsList) {
      [gs.itemUtil addToMyItems:proto.reward.updatedUserItemsList];
    }

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
    // Gems, oil, and cash are updated through UpdateUserClientResponseEvent. Don't do anything here
    if (proto.rewards.updatedOrNewMonstersList.count) {
      [gs addToMyMonsters:proto.rewards.updatedOrNewMonstersList];
    }
    
    if (proto.rewards.updatedUserItemsList) {
      [gs.itemUtil addToMyItems:proto.rewards.updatedUserItemsList];
    }
    
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
      [gs addToCompleteTasks:@[proto.utcp]];
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

- (void) handleUpdateClientTaskStateResponseProto:(FullEvent *)fe {
  UpdateClientTaskStateResponseProto *proto = (UpdateClientTaskStateResponseProto *)fe.event;
  LNLog(@"Update client task state received with status %d.", (int)proto.status);
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
    if (proto.attackerAttacked) {
      if ([proto.sender.minUserProto.userUuid isEqualToString:gs.userUuid]) {
        [gs addToMyMonsters:proto.updatedOrNewList];
      }
      
      if (proto.hasBattleThatJustEnded) {
        [gs.battleHistory addObject:proto.battleThatJustEnded];
        [[NSNotificationCenter defaultCenter] postNotificationName:NEW_BATTLE_HISTORY_NOTIFICATION object:proto.battleThatJustEnded];
      }
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to end pvp battle."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleRetrieveUserMonsterTeamResponseProto:(FullEvent *)fe {
  RetrieveUserMonsterTeamResponseProto *proto = (RetrieveUserMonsterTeamResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Retrieve user monster team response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == RetrieveUserMonsterTeamResponseProto_RetrieveUserMonsterTeamStatusSuccess) {
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to retrieve user monster team."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleCustomizePvpBoardObstacleResponseProto:(FullEvent *)fe {
  CustomizePvpBoardObstacleResponseProto *proto = (CustomizePvpBoardObstacleResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Customize PvP board obstacle response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == CustomizePvpBoardObstacleResponseProto_CustomizePvpBoardObstacleStatusSuccess) {
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to customize PvP board obstacle."];
    
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

#pragma mark - Battle Item

- (void) handleCreateBattleItemResponseProto:(FullEvent *)fe {
  CreateBattleItemResponseProto *proto = (CreateBattleItemResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Create battle response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == CreateBattleItemResponseProto_CreateBattleItemStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to alter battle item queue."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleCompleteBattleItemResponseProto:(FullEvent *)fe {
  CompleteBattleItemResponseProto *proto = (CompleteBattleItemResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Complete battle response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == CompleteBattleItemResponseProto_CompleteBattleItemStatusSuccess) {
    [gs.battleItemUtil addToMyItems:proto.ubiUpdatedList];
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to complete battle item."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleDiscardBattleItemResponseProto:(FullEvent *)fe {
  DiscardBattleItemResponseProto *proto = (DiscardBattleItemResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Discard battle response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == DiscardBattleItemResponseProto_DiscardBattleItemStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to discard battle item."];
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
  
  LNLog(@"Achievement progress response received with status %d.", (int)proto.status);
  
  if (proto.status == AchievementProgressResponseProto_AchievementProgressStatusSuccess) {
  } else {
    [Globals popupMessage:@"Server failed to progress achievement."];
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
    if (proto.rewards.updatedOrNewMonstersList) {
      [gs addToMyMonsters:proto.rewards.updatedOrNewMonstersList];
    }
    
    if (proto.rewards.updatedUserItemsList) {
      [gs.itemUtil addToMyItems:proto.rewards.updatedUserItemsList];
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to redeem mini job."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleRefreshMiniJobResponseProto:(FullEvent *)fe {
  GameState *gs = [GameState sharedGameState];
  RefreshMiniJobResponseProto *proto = (RefreshMiniJobResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Finish refreshing miniJobs with status %d.", (int)proto.status);
  
  if(proto.status == RefreshMiniJobResponseProto_RefreshMiniJobStatusSuccess) {
    
    NSMutableArray *newJobsList = [NSMutableArray arrayWithArray:proto.miniJobsList];
    
    for (int i = 0; i < gs.myMiniJobs.count; i++) {
      UserMiniJob *umj = gs.myMiniJobs[i];
      if(!umj.timeStarted) {
        [gs.myMiniJobs removeObjectAtIndex:i];
        i--;
      }
    }
    
    [gs addToMiniJobs:newJobsList isNew:YES];
  } else {
    [Globals popupMessage:@"Server failed to redeem mini job refresh."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
  
}

#pragma mark - Research

- (void) handlePerformResearchResponseProto:(FullEvent *)fe {
  PerformResearchResponseProto *proto = (PerformResearchResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Perform research response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == PerformResearchResponseProto_PerformResearchStatusSuccess) {
    [gs.researchUtil currentResearch].userResearchUuid = proto.userResearchUuid;
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to redeem research."];
    
    [gs.researchUtil cancelCurrentResearch];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleFinishPerformingResearchResponseProto:(FullEvent *)fe {
  FinishPerformingResearchResponseProto *proto = (FinishPerformingResearchResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Finish performing research received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == FinishPerformingResearchResponseProto_FinishPerformingResearchStatusSuccess) {
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to redeem research."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

#pragma mark - Mini Event

- (void) handleRedeemMiniEventRewardResponseProto:(FullEvent *)fe {
  RedeemMiniEventRewardResponseProto *proto = (RedeemMiniEventRewardResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Redeem mini event reward response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == RedeemMiniEventRewardResponseProto_RedeemMiniEventRewardStatusSuccess) {
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to redeem mini event reward."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleRetrieveMiniEventResponseProto:(FullEvent *)fe {
  RetrieveMiniEventResponseProto *proto = (RetrieveMiniEventResponseProto *)fe.event;
  
  LNLog(@"Retrieve mini event response received with status %d.", (int)proto.status);
  
  if (proto.status == RetrieveMiniEventResponseProto_RetrieveMiniEventStatusSuccess) {
  } else {
    [Globals popupMessage:@"Server failed to retrieve mini event."];
  }
}

- (void) handleUpdateMiniEventResponseProto:(FullEvent *)fe {
  UpdateMiniEventResponseProto *proto = (UpdateMiniEventResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Update mini event response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == UpdateMiniEventResponseProto_UpdateMiniEventStatusSuccess) {
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to update mini event."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

#pragma mark - Translation

- (void) handleTranslateSelectMessagesResponseProto:(FullEvent *)fe {
  TranslateSelectMessagesResponseProto *proto = (TranslateSelectMessagesResponseProto *)fe.event;
  
  LNLog(@"Translate select messages response received with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == TranslateSelectMessagesResponseProto_TranslateSelectMessagesStatusSuccess) {
    for (PrivateChatPostProto *pcpp in proto.messagesTranslatedList) {
      [gs addPrivateChat:pcpp];
    }
  } else {
    [Globals popupMessage:@"Server failed to translate messages."];
  }
}

#pragma mark - Tango Gift

// This is all temporary until we have time to make a better UX experience
- (void) handleSendTangoGiftResponseProto:(FullEvent *)fe {
  #ifdef TOONSQUAD
  SendTangoGiftResponseProto *proto = (SendTangoGiftResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Send Tango Gift Response recieved with status %d.", (int)proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == SendTangoGiftResponseProto_SendTangoGiftStatusSuccess) {
    
    int totalInvitesSent = (int)proto.tangoUserIdsInToonSquadList.count + (int)proto.tangoUserIdsNotInToonSquadList.count;
    
    [TangoDelegate fetchCachedFriends:^(NSArray *friends) {
      Globals *gl = [Globals sharedGlobals];
      
      int totalPossibleInvites = (int)friends.count;
      
      int rewardAmount = MAX(gl.tangoMaxGemReward - (totalPossibleInvites - totalInvitesSent), gl.tangoMinGemReward);
      rewardAmount = MIN(gl.tangoMaxGemReward, rewardAmount);
      
      [Globals addPurpleAlertNotification:[NSString stringWithFormat:@"You Collected %d Gems for sharing gifts with your friends", rewardAmount] isImmediate:YES];
      
      if (proto.tangoUserIdsInToonSquadList) {
        //[TangoDelegate sendGiftsToTangoUsers:proto.tangoUserIdsInToonSquadList];
      }
    }];
  } else {
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
#endif
}

@end
