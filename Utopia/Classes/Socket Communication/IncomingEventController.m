//
//  EventController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/3/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "IncomingEventController.h"
#import "MobstersEventProtocol.pb.h"
#import "LNSynthesizeSingleton.h"
#import "GameState.h"
#import "Globals.h"
#import "OutgoingEventController.h"
#import "HomeMap.h"
#import "GameLayer.h"
#import "MissionMap.h"
#import "GameViewController.h"
#import "GenericPopupController.h"
#import "FullEvent.h"
#import "AppDelegate.h"
#import "IAPHelper.h"
#import "SocketCommunication.h"
#import "DungeonBattleLayer.h"

#define QUEST_REDEEM_KIIP_REWARD @"quest_redeem"

@implementation IncomingEventController

SYNTHESIZE_SINGLETON_FOR_CLASS(IncomingEventController);

- (Class) getClassForType:(MobstersEventProtocolResponse)type {
  // This is very hacky but I suppose necessary.. :/
  Class responseClass;
  switch (type) {
    case MobstersEventProtocolResponseSUserCreateEvent:
      responseClass = [UserCreateResponseProto class];
      break;
    case MobstersEventProtocolResponseSStartupEvent:
      responseClass = [StartupResponseProto class];
      break;
    case MobstersEventProtocolResponseSLevelUpEvent:
      responseClass = [LevelUpResponseProto class];
      break;
    case MobstersEventProtocolResponseSInAppPurchaseEvent:
      responseClass = [InAppPurchaseResponseProto class];
      break;
    case MobstersEventProtocolResponseSUpdateClientUserEvent:
      responseClass = [UpdateClientUserResponseProto class];
      break;
    case MobstersEventProtocolResponseSPurchaseNormStructureEvent:
      responseClass = [PurchaseNormStructureResponseProto class];
      break;
    case MobstersEventProtocolResponseSMoveOrRotateNormStructureEvent:
      responseClass = [MoveOrRotateNormStructureResponseProto class];
      break;
    case MobstersEventProtocolResponseSUpgradeNormStructureEvent:
      responseClass = [UpgradeNormStructureResponseProto class];
      break;
    case MobstersEventProtocolResponseSNormStructWaitCompleteEvent:
      responseClass = [NormStructWaitCompleteResponseProto class];
      break;
    case MobstersEventProtocolResponseSFinishNormStructWaittimeWithDiamondsEvent:
      responseClass = [FinishNormStructWaittimeWithDiamondsResponseProto class];
      break;
    case MobstersEventProtocolResponseSRetrieveCurrencyFromNormStructureEvent:
      responseClass = [RetrieveCurrencyFromNormStructureResponseProto class];
      break;
    case MobstersEventProtocolResponseSSellNormStructureEvent:
      responseClass = [SellNormStructureResponseProto class];
      break;
    case MobstersEventProtocolResponseSLoadPlayerCityEvent:
      responseClass = [LoadPlayerCityResponseProto class];
      break;
    case MobstersEventProtocolResponseSLoadCityEvent:
      responseClass = [LoadCityResponseProto class];
      break;
    case MobstersEventProtocolResponseSQuestAcceptEvent:
      responseClass = [QuestAcceptResponseProto class];
      break;
    case MobstersEventProtocolResponseSQuestRedeemEvent:
      responseClass = [QuestRedeemResponseProto class];
      break;
    case MobstersEventProtocolResponseSQuestProgressEvent:
      responseClass = [QuestProgressResponseProto class];
      break;
    case MobstersEventProtocolResponseSRetrieveUsersForUserIdsEvent:
      responseClass = [RetrieveUsersForUserIdsResponseProto class];
      break;
    case MobstersEventProtocolResponseSReferralCodeUsedEvent:
      responseClass = [ReferralCodeUsedResponseProto class];
      break;
    case MobstersEventProtocolResponseSEnableApnsEvent:
      responseClass = [EnableAPNSResponseProto class];
      break;
    case MobstersEventProtocolResponseSEarnFreeDiamondsEvent:
      responseClass = [EarnFreeGemsResponseProto class];
      break;
    case MobstersEventProtocolResponseSPurgeStaticDataEvent:
      responseClass = [PurgeClientStaticDataResponseProto class];
      break;
    case MobstersEventProtocolResponseSSendGroupChatEvent:
      responseClass = [SendGroupChatResponseProto class];
      break;
    case MobstersEventProtocolResponseSReceivedGroupChatEvent:
      responseClass = [ReceivedGroupChatResponseProto class];
      break;
    case MobstersEventProtocolResponseSCreateClanEvent:
      responseClass = [CreateClanResponseProto class];
      break;
    case MobstersEventProtocolResponseSApproveOrRejectRequestToJoinClanEvent:
      responseClass = [ApproveOrRejectRequestToJoinClanResponseProto class];
      break;
    case MobstersEventProtocolResponseSLeaveClanEvent:
      responseClass = [LeaveClanResponseProto class];
      break;
    case MobstersEventProtocolResponseSRequestJoinClanEvent:
      responseClass = [RequestJoinClanResponseProto class];
      break;
    case MobstersEventProtocolResponseSRetractRequestJoinClanEvent:
      responseClass = [RetractRequestJoinClanResponseProto class];
      break;
    case MobstersEventProtocolResponseSRetrieveClanInfoEvent:
      responseClass = [RetrieveClanInfoResponseProto class];
      break;
    case MobstersEventProtocolResponseSTransferClanOwnership:
      responseClass = [TransferClanOwnershipResponseProto class];
      break;
    case MobstersEventProtocolResponseSChangeClanDescriptionEvent:
      responseClass = [ChangeClanDescriptionResponseProto class];
      break;
    case MobstersEventProtocolResponseSBootPlayerFromClanEvent:
      responseClass = [BootPlayerFromClanResponseProto class];
      break;
    case MobstersEventProtocolResponseSExpansionWaitCompleteEvent:
      responseClass = [ExpansionWaitCompleteResponseProto class];
      break;
    case MobstersEventProtocolResponseSPurchaseCityExpansionEvent:
      responseClass = [PurchaseCityExpansionResponseProto class];
      break;
    case MobstersEventProtocolResponseSSendAdminMessageEvent:
      responseClass = [SendAdminMessageResponseProto class];
      break;
    case MobstersEventProtocolResponseSGeneralNotificationEvent:
      responseClass = [GeneralNotificationResponseProto class];
      break;
    case MobstersEventProtocolResponseSRetrieveTournamentRankingsEvent:
      responseClass = [RetrieveTournamentRankingsResponseProto class];
      break;
    case MobstersEventProtocolResponseSSubmitMonsterEnhancementEvent:
      responseClass = [SubmitMonsterEnhancementResponseProto class];
      break;
    case MobstersEventProtocolResponseSPurchaseBoosterPackEvent:
      responseClass = [PurchaseBoosterPackResponseProto class];
      break;
    case MobstersEventProtocolResponseSChangeClanJoinTypeEvent:
      responseClass = [ChangeClanJoinTypeResponseProto class];
      break;
    case MobstersEventProtocolResponseSReceivedRareBoosterPurchaseEvent:
      responseClass = [ReceivedRareBoosterPurchaseResponseProto class];
      break;
    case MobstersEventProtocolResponseSPrivateChatPostEvent:
      responseClass = [PrivateChatPostResponseProto class];
      break;
    case MobstersEventProtocolResponseSRetrievePrivateChatPostEvent:
      responseClass = [RetrievePrivateChatPostsResponseProto class];
      break;
    case MobstersEventProtocolResponseSBeginDungeonEvent:
      responseClass = [BeginDungeonResponseProto class];
      break;
    case MobstersEventProtocolResponseSReviveInDungeonEvent:
      responseClass = [ReviveInDungeonResponseProto class];
      break;
    case MobstersEventProtocolResponseSEndDungeonEvent:
      responseClass = [EndDungeonResponseProto class];
      break;
    case MobstersEventProtocolResponseSHealMonsterEvent:
      responseClass = [HealMonsterResponseProto class];
      break;
    case MobstersEventProtocolResponseSHealMonsterWaitTimeCompleteEvent:
      responseClass = [HealMonsterWaitTimeCompleteResponseProto class];
      break;
    case MobstersEventProtocolResponseSAddMonsterToBattleTeamEvent:
      responseClass = [AddMonsterToBattleTeamResponseProto class];
      break;
    case MobstersEventProtocolResponseSIncreaseMonsterInventorySlotEvent:
      responseClass = [IncreaseMonsterInventorySlotResponseProto class];
      break;
    case MobstersEventProtocolResponseSEnhancementWaitTimeCompleteEvent:
      responseClass = [EnhancementWaitTimeCompleteResponseProto class];
      break;
    case MobstersEventProtocolResponseSRemoveMonsterFromBattleTeamEvent:
      responseClass = [RemoveMonsterFromBattleTeamResponseProto class];
      break;
    case MobstersEventProtocolResponseSUpdateMonsterHealthEvent:
      responseClass = [UpdateMonsterHealthResponseProto class];
      break;
    case MobstersEventProtocolResponseSCombineUserMonsterPiecesEvent:
      responseClass = [CombineUserMonsterPiecesResponseProto class];
      break;
    case MobstersEventProtocolResponseSSellUserMonsterEvent:
      responseClass = [SellUserMonsterResponseProto class];
      break;
    case MobstersEventProtocolResponseSInviteFbFriendsForSlotsEvent:
      responseClass = [InviteFbFriendsForSlotsResponseProto class];
      break;
    case MobstersEventProtocolResponseSAcceptAndRejectFbInviteForSlotsEvent:
      responseClass = [AcceptAndRejectFbInviteForSlotsResponseProto class];
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

- (void) handleUserCreateResponseProto:(FullEvent *)fe {
}

- (void) handleStartupResponseProto:(FullEvent *)fe {
  StartupResponseProto *proto = (StartupResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Startup response received with status %d.", proto.startupStatus);
  
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  
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
  if (proto.startupStatus == StartupResponseProto_StartupStatusUserInDb) {
    if (!proto.sender.hasUserUuid) {
      LNLog(@"Did not receive user uuid");
    }
    
    [gs updateStaticData:proto.staticDataStuffProto];
    
    // Update user before creating map
    [gs updateUser:proto.sender timestamp:0];
    
    // Setup the userid queue
    [[SocketCommunication sharedSocketCommunication] initUserIdMessageQueue];
    
    [gs setPlayerHasBoughtInAppPurchase:proto.playerHasBoughtInAppPurchase];
    
    //    [Globals asyncDownloadBundles];
    [gs.myMonsters removeAllObjects];
    [gs addToMyMonsters:proto.usersMonstersList];
    [gs addAllMonsterHealingProtos:proto.monstersHealingList];
    
    if (proto.hasEnhancements) {
      [gs addEnhancementProto:proto.enhancements];
    }
    
    gs.completedTasks = [NSMutableSet setWithArray:proto.completedTaskIdsList];
    [gs.myQuests removeAllObjects];
    [gs addToMyQuests:proto.userQuestsList];
    
    [gs.requestsFromFriends removeAllObjects];
    [gs addInventorySlotsRequests:proto.invitesToMeForSlotsList];
    [gs.usersUsedForExtraSlots removeAllObjects];
    [gs addUsersUsedForExtraSlots:proto.usersUsedForExtraSlotsList];
    
    [gs addToRequestedClans:proto.userClanInfoList];
    
    [gs.globalChatMessages removeAllObjects];
    [gs.clanChatMessages removeAllObjects];
    [gs.privateChats removeAllObjects];
    for (GroupChatMessageProto *msg in proto.globalChatsList) {
      ChatMessage *cm = [[ChatMessage alloc] initWithProto:msg];
      [gs addChatMessage:cm scope:GroupChatScopeGlobal];
    }
    for (GroupChatMessageProto *msg in proto.clanChatsList) {
      ChatMessage *cm = [[ChatMessage alloc] initWithProto:msg];
      [gs addChatMessage:cm scope:GroupChatScopeClan];
    }
    for (PrivateChatPostProto *pcpp in proto.pcppList) {
      [gs addPrivateChat:pcpp];
    }
    
    for (RareBoosterPurchaseProto *rbp in proto.rareBoosterPurchasesList) {
      //      NSLog(@"%@ got %@ from %@.", rbp.user.name, rbp.equip.name, rbp.booster.name);
      //      [gs addBoosterPurchase:rbp];
    }
    
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] registerForPushNotifications];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] removeLocalNotifications];
    
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

- (void) handleLevelUpResponseProto:(FullEvent *)fe {
  LevelUpResponseProto *proto = (LevelUpResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Level up response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == LevelUpResponseProto_LevelUpStatusSuccess) {
    [gs addToStaticStructs:proto.newlyAvailableStructsList];
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to handle level up"];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleInAppPurchaseResponseProto:(FullEvent *)fe {
  InAppPurchaseResponseProto *proto = (InAppPurchaseResponseProto *)fe.event;
  int tag = fe.tag;
  
  GameState *gs = [GameState sharedGameState];
  
  LNLog(@"In App Purchase response received with status %d.", proto.status);
  
  NSString *key = IAP_DEFAULTS_KEY;
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *arr = [[defaults arrayForKey:key] mutableCopy];
  int origCount = arr.count;
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
  
  if (proto.status != InAppPurchaseResponseProto_InAppPurchaseStatusSuccess) {
    // Duplicate receipt might occur if you close app before response comes back
    if (proto.status != InAppPurchaseResponseProto_InAppPurchaseStatusDuplicateReceipt) {
      [Globals popupMessage:@"Sorry! The In App Purchase failed! Please email at support@lvl6.com"];
    }
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    // Post notification so all UI with that bar can update
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:IAP_SUCCESS_NOTIFICATION object:nil]];
    [gs removeNonFullUserUpdatesForTag:tag];
    [Analytics purchasedGoldPackage:proto.packageName price:proto.packagePrice goldAmount:proto.gemsGained];
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

- (void) handlePurchaseNormStructureResponseProto:(FullEvent *)fe {
  PurchaseNormStructureResponseProto *proto = (PurchaseNormStructureResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Purchase norm struct response received with status: %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == PurchaseNormStructureResponseProto_PurchaseNormStructureStatusSuccess) {
    // Get the userstruct without a userStructId
    UserStruct *us = nil;
    for (UserStruct *u in [[GameState sharedGameState] myStructs]) {
      if (u.userStructUuid == 0) {
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
      [Globals popupMessage:[NSString stringWithFormat:@"Something went wrong in the purchase. Error Status: %d", proto.status]];
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
  
  LNLog(@"Move norm struct response received with status: %d.", proto.status);
  
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
  
  LNLog(@"Upgrade norm structure response received with status %d.", proto.status);
  
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
  
  LNLog(@"Norm struct builds complete response received with status %d.", proto.status);
  
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
  
  LNLog(@"Finish norm struct with diamonds response received with status %d.", proto.status);
  
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
  
  LNLog(@"Retrieve currency response received with status: %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status != RetrieveCurrencyFromNormStructureResponseProto_RetrieveCurrencyFromNormStructureStatusSuccess) {
    if (proto.status == RetrieveCurrencyFromNormStructureResponseProto_RetrieveCurrencyFromNormStructureStatusClientTooApartFromServerTime) {
      [self handleTimeOutOfSync];
    } else {
      [Globals popupMessage:@"Server failed to retrieve from normal structure."];
    }
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    if (proto.status == RetrieveCurrencyFromNormStructureResponseProto_RetrieveCurrencyFromNormStructureStatusClientTooApartFromServerTime) {
      [self handleTimeOutOfSync];
    } else {
      [gs removeNonFullUserUpdatesForTag:tag];
    }
  }
}

- (void) handleSellNormStructureResponseProto:(FullEvent *)fe {
  SellNormStructureResponseProto *proto = (SellNormStructureResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Sell norm struct response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status != SellNormStructureResponseProto_SellNormStructureStatusSuccess) {
    [Globals popupMessage:@"Server failed to sell normal structure."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [gs removeNonFullUserUpdatesForTag:tag];
  }
}

- (void) handleLoadPlayerCityResponseProto:(FullEvent *)fe {
  LoadPlayerCityResponseProto *proto = (LoadPlayerCityResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Load player city response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  
  if (proto.status == LoadPlayerCityResponseProto_LoadPlayerCityStatusSuccess) {
    if ([proto.cityOwner.userUuid isEqualToString:gs.userUuid]) {
      [gs.myStructs removeAllObjects];
      [gs addToMyStructs:proto.ownerNormStructsList];
      
      NSMutableArray *exp = [NSMutableArray array];
      if (proto.userCityExpansionDataProtoListList.count > 0) {
        for (UserCityExpansionDataProto *e in proto.userCityExpansionDataProtoListList) {
          [exp  addObject:[UserExpansion userExpansionWithUserCityExpansionDataProto:e]];
        }
      }
      gs.userExpansions = exp;
      [gs beginExpansionTimer];
      
      [gs removeNonFullUserUpdatesForTag:tag];
      
      //      [[GameLayer sharedGameLayer] performBattleLossTutorial];
      
      // Check for unresponded in app purchases
      NSString *key = IAP_DEFAULTS_KEY;
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
      NSArray *arr = [defaults arrayForKey:key];
      [defaults removeObjectForKey:key];
      for (NSString *receipt in arr) {
        LNLog(@"Sending over unresponded receipt.");
        [[OutgoingEventController sharedOutgoingEventController] inAppPurchase:receipt goldAmt:0 cashAmt:0 product:nil];
      }
    }
  } else if (proto.status == LoadPlayerCityResponseProto_LoadPlayerCityStatusNoSuchPlayer) {
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
  
  LNLog(@"Load neutral city response received for city %d with status %d.", proto.cityId, proto.status);
  
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

- (void) handleQuestAcceptResponseProto:(FullEvent *)fe {
  QuestAcceptResponseProto *proto = (QuestAcceptResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Quest accept response received with status %d", proto.status);
  
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
  
  LNLog(@"Quest redeem response received with status %d", proto.status);
  
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
  
  LNLog(@"Received quest progress response with status %d.", proto.status);
  
  if (proto.status == QuestProgressResponseProto_QuestProgressStatusSuccess) {
  } else {
    [Globals popupMessage:@"Server sent quest complete for invalid quest"];
  }
}

- (void) handleRetrieveUsersForUserIdsResponseProto:(FullEvent *)fe {
  int tag = fe.tag;
  
  LNLog(@"Retrieve user ids for user received.");
  
  GameState *gs = [GameState sharedGameState];
  [gs removeNonFullUserUpdatesForTag:tag];
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
  
  LNLog(@"Enable apns response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == EnableAPNSResponseProto_EnableAPNSStatusSuccess) {
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleEarnFreeDiamondsResponseProto:(FullEvent *)fe {
  EarnFreeGemsResponseProto *proto = (EarnFreeGemsResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Earn free diamonds response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == EarnFreeGemsResponseProto_EarnFreeGemsStatusSuccess) {
    if (proto.freeGemsType == EarnFreeGemsTypeFbConnect) {
      Globals *gl = [Globals sharedGlobals];
      [Globals popupMessage:[NSString stringWithFormat:@"Congrats! You have received %d gold for connecting to Facebook.", gl.fbConnectRewardGems]];
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

- (void) handleSendGroupChatResponseProto:(FullEvent *)fe {
  SendGroupChatResponseProto *proto = (SendGroupChatResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Send group chat response received with status %d.", proto.status);
  
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
  }
}

- (void) handleCreateClanResponseProto:(FullEvent *)fe {
  CreateClanResponseProto *proto = (CreateClanResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Create clan response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  
  if (proto.status == CreateClanResponseProto_CreateClanStatusSuccess) {
    if (proto.hasClanInfo) {
      gs.clan = proto.clanInfo;
      [[SocketCommunication sharedSocketCommunication] rebuildSender];
      [gs.requestedClans removeAllObjects];
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
  LNLog(@"Retrieve clan response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == RetrieveClanInfoResponseProto_RetrieveClanInfoStatusSuccess) {
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to retrieve clan information."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleApproveOrRejectRequestToJoinClanResponseProto:(FullEvent *)fe {
  ApproveOrRejectRequestToJoinClanResponseProto *proto = (ApproveOrRejectRequestToJoinClanResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Approve or reject request to join clan response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == ApproveOrRejectRequestToJoinClanResponseProto_ApproveOrRejectRequestToJoinClanStatusSuccess) {
    if ([proto.requesterUuid isEqualToString:gs.userUuid]) {
      [gs.requestedClans removeAllObjects];
      if (proto.accept) {
        gs.clan = proto.minClan;
        [[SocketCommunication sharedSocketCommunication] rebuildSender];
        
        // Spur clan chat to reload
        [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_RECEIVED_NOTIFICATION object:nil];
      }
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to respond to clan request."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleLeaveClanResponseProto:(FullEvent *)fe {
  LeaveClanResponseProto *proto = (LeaveClanResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Leave clan response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == LeaveClanResponseProto_LeaveClanStatusSuccess) {
    if ([proto.sender.userUuid isEqualToString:gs.userUuid]) {
      [gs.requestedClans removeAllObjects];
      gs.clan = nil;
      [[SocketCommunication sharedSocketCommunication] rebuildSender];
      
      [gs.clanChatMessages removeAllObjects];
      [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_RECEIVED_NOTIFICATION object:nil];
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to leave clan."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleRequestJoinClanResponseProto:(FullEvent *)fe {
  RequestJoinClanResponseProto *proto = (RequestJoinClanResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Request join clan response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == RequestJoinClanResponseProto_RequestJoinClanStatusRequestSuccess) {
    if ([proto.sender.userUuid isEqualToString:gs.userUuid]) {
      [gs.requestedClans addObject:proto.clanUuid];
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else if (proto.status == RequestJoinClanResponseProto_RequestJoinClanStatusJoinSuccess) {
    if ([proto.sender.userUuid isEqualToString:gs.userUuid]) {
      [gs.requestedClans removeAllObjects];
      gs.clan = proto.minClan;
      [[SocketCommunication sharedSocketCommunication] rebuildSender];
      
      // Spur the clan chat to update
      [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_RECEIVED_NOTIFICATION object:nil];
    }
  } else {
    if (proto.status == RequestJoinClanResponseProto_RequestJoinClanStatusClanIsFull) {
      [Globals popupMessage:@"Sorry, this clan is full. Please try another."];
    } else {
      [Globals popupMessage:@"Server failed to request to join clan request."];
    }
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleRetractRequestJoinClanResponseProto:(FullEvent *)fe {
  RetractRequestJoinClanResponseProto *proto = (RetractRequestJoinClanResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Retract request to join clan response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == RetractRequestJoinClanResponseProto_RetractRequestJoinClanStatusSuccess) {
    if ([proto.sender.userUuid isEqualToString:gs.userUuid]) {
      [gs.requestedClans removeObject:proto.clanUuid];
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to retract clan request."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleTransferClanOwnershipResponseProto:(FullEvent *)fe {
  TransferClanOwnershipResponseProto *proto = (TransferClanOwnershipResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Transfer clan ownership response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == TransferClanOwnershipResponseProto_TransferClanOwnershipStatusSuccess) {
    if (proto.hasMinClan) {
      gs.clan = proto.minClan;
      [[SocketCommunication sharedSocketCommunication] rebuildSender];
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to transfer clan ownership."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleChangeClanDescriptionResponseProto:(FullEvent *)fe {
  ChangeClanDescriptionResponseProto *proto = (ChangeClanDescriptionResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Change clan description response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == ChangeClanDescriptionResponseProto_ChangeClanDescriptionStatusSuccess) {
    if (proto.hasMinClan) {
      gs.clan = proto.minClan;
      [[SocketCommunication sharedSocketCommunication] rebuildSender];
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to change clan description."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleChangeClanJoinTypeResponseProto:(FullEvent *)fe {
  ChangeClanJoinTypeResponseProto *proto = (ChangeClanJoinTypeResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Change clan join type response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == ChangeClanJoinTypeResponseProto_ChangeClanJoinTypeStatusSuccess) {
    if (proto.hasMinClan) {
      gs.clan = proto.minClan;
      [[SocketCommunication sharedSocketCommunication] rebuildSender];
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to change clan join type."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleBootPlayerFromClanResponseProto:(FullEvent *)fe {
  BootPlayerFromClanResponseProto *proto = (BootPlayerFromClanResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Boot player from clan response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == BootPlayerFromClanResponseProto_BootPlayerFromClanStatusSuccess) {
    if ([proto.playerUuidToBoot isEqualToString:gs.userUuid]) {
      gs.clan = nil;
      [[SocketCommunication sharedSocketCommunication] rebuildSender];
      
      [gs.clanChatMessages removeAllObjects];
      [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_RECEIVED_NOTIFICATION object:nil];
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to boot player from clan."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleExpansionWaitCompleteResponseProto:(FullEvent *)fe {
  ExpansionWaitCompleteResponseProto *proto = (ExpansionWaitCompleteResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Expansion wait complete response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == ExpansionWaitCompleteResponseProto_ExpansionWaitCompleteStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to complete expansion wait time."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handlePurchaseCityExpansionResponseProto:(FullEvent *)fe {
  PurchaseCityExpansionResponseProto *proto = (PurchaseCityExpansionResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Purchase city expansion response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == PurchaseCityExpansionResponseProto_PurchaseCityExpansionStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    if (proto.status == PurchaseCityExpansionResponseProto_PurchaseCityExpansionStatusClientTooApartFromServerTime) {
      [self handleTimeOutOfSync];
    } else {
      [Globals popupMessage:@"Server failed to purchase city expansion."];
    }
    
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

- (void) handleRetrieveLeaderboardRankingsResponseProto:(FullEvent *)fe {
  RetrieveTournamentRankingsResponseProto *proto = (RetrieveTournamentRankingsResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Retrieve tournament response received with status %d and %d rankings.", proto.status, proto.resultPlayersList.count);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == RetrieveTournamentRankingsResponseProto_RetrieveTournamentStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to send back leaderboard rankings."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleSubmitMonsterEnhancementResponseProto:(FullEvent *)fe {
  SubmitMonsterEnhancementResponseProto *proto = (SubmitMonsterEnhancementResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Submit monster enhancement received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == SubmitMonsterEnhancementResponseProto_SubmitMonsterEnhancementStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to submit monster enhancement."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handlePurchaseBoosterPackResponseProto:(FullEvent *)fe {
  PurchaseBoosterPackResponseProto *proto = (PurchaseBoosterPackResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Purchase booster pack received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatusSuccess) {
    [gs addToMyMonsters:proto.updatedOrNewList];
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
      [Globals popupMessage:@"Server failed to purchase booster pack."];
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleReceivedRareBoosterPurchaseResponseProto:(FullEvent *)fe {
  ReceivedRareBoosterPurchaseResponseProto *proto = (ReceivedRareBoosterPurchaseResponseProto *)fe.event;
  GameState *gs = [GameState sharedGameState];
  [gs addBoosterPurchase:proto.rareBoosterPurchase];
}

- (void) handlePrivateChatPostResponseProto:(FullEvent *)fe {
  PrivateChatPostResponseProto *proto = (PrivateChatPostResponseProto *)fe.event;
  LNLog(@"Private chat post response received with status %d.", proto.status);
  
  if (proto.status == PrivateChatPostResponseProto_PrivateChatPostStatusSuccess) {
    GameState *gs = [GameState sharedGameState];
    [gs addPrivateChat:proto.post];
  }
}

- (void) handleRetrievePrivateChatPostsResponseProto:(FullEvent *)fe {
  RetrievePrivateChatPostsResponseProto *proto = (RetrievePrivateChatPostsResponseProto *)fe.event;
  LNLog(@"Retrieve private chats received with status %d and %d posts.", proto.status, proto.postsList.count);
}

- (void) handleBeginDungeonResponseProto:(FullEvent *)fe {
  BeginDungeonResponseProto *proto = (BeginDungeonResponseProto *)fe.event;
  LNLog(@"Begin dungeon response received with status %d.", proto.status);
  
  if (proto.status == BeginDungeonResponseProto_BeginDungeonStatusSuccess) {
  } else {
    [Globals popupMessage:@"Server failed to enter dungeon."];
  }
}


- (void) handleEndDungeonResponseProto:(FullEvent *)fe {
  EndDungeonResponseProto *proto = (EndDungeonResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"End dungeon response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == EndDungeonResponseProto_EndDungeonStatusSuccess) {
    [gs addToMyMonsters:proto.updatedOrNewList];
    
    if (proto.userWon) {
      [gs.completedTasks addObject:@(proto.taskId)];
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to end dungeon."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleHealMonsterResponseProto:(FullEvent *)fe {
  HealMonsterResponseProto *proto = (HealMonsterResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Heal monster response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == HealMonsterResponseProto_HealMonsterStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to handle heal monster."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleHealMonsterWaitTimeCompleteResponseProto:(FullEvent *)fe {
  HealMonsterWaitTimeCompleteResponseProto *proto = (HealMonsterWaitTimeCompleteResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Heal wait time complete response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == HealMonsterWaitTimeCompleteResponseProto_HealMonsterWaitTimeCompleteStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to handle heal complete."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleAddMonsterToBattleTeamResponseProto:(FullEvent *)fe {
  AddMonsterToBattleTeamResponseProto *proto = (AddMonsterToBattleTeamResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Add monster to squad response received with status %d.", proto.status);
  
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
  
  LNLog(@"Remove monster from squad response received with status %d.", proto.status);
  
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
  
  LNLog(@"Increase monster inventory slots response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == IncreaseMonsterInventorySlotResponseProto_IncreaseMonsterInventorySlotStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to handle buying inventory slots."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleEnhancementWaitTimeCompleteResponseProto:(FullEvent *)fe {
  IncreaseMonsterInventorySlotResponseProto *proto = (IncreaseMonsterInventorySlotResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Enhancement wait complete response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == IncreaseMonsterInventorySlotResponseProto_IncreaseMonsterInventorySlotStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to handle enhancement wait time."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleUpdateMonsterHealthResponseProto:(FullEvent *)fe {
  UpdateMonsterHealthResponseProto *proto = (UpdateMonsterHealthResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Update monster health response received with status %d.", proto.status);
  
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
  
  LNLog(@"Combine user monster response received with status %d.", proto.status);
  
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
  
  LNLog(@"Sell user monster response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == SellUserMonsterResponseProto_SellUserMonsterStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to sell user monster."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleInviteFbFriendsForSlotsResponseProto:(FullEvent *)fe {
  InviteFbFriendsForSlotsResponseProto *proto = (InviteFbFriendsForSlotsResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Invite fb friends for slots response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == InviteFbFriendsForSlotsResponseProto_InviteFbFriendsForSlotsStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to invite fb friends for slots."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleAcceptAndRejectFbInviteForSlotsResponseProto:(FullEvent *)fe {
  AcceptAndRejectFbInviteForSlotsResponseProto *proto = (AcceptAndRejectFbInviteForSlotsResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Accept and reject fb invite for slots response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == AcceptAndRejectFbInviteForSlotsResponseProto_AcceptAndRejectFbInviteForSlotsStatusSuccess) {
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

@end
