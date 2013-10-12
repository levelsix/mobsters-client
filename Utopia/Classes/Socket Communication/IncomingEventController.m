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
#import "GameLayer.h"
#import "MissionMap.h"
#import "GameViewController.h"
#import "ActivityFeedController.h"
#import "GenericPopupController.h"
#import "FullEvent.h"
#import "AppDelegate.h"
#import "IAPHelper.h"
#import "ClanViewController.h"
#import "SocketCommunication.h"
#import "DungeonBattleLayer.h"

#define QUEST_REDEEM_KIIP_REWARD @"quest_redeem"

@implementation IncomingEventController

SYNTHESIZE_SINGLETON_FOR_CLASS(IncomingEventController);

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
    case EventProtocolResponseSSellNormStructureEvent:
      responseClass = [SellNormStructureResponseProto class];
      break;
    case EventProtocolResponseSLoadPlayerCityEvent:
      responseClass = [LoadPlayerCityResponseProto class];
      break;
    case EventProtocolResponseSLoadNeutralCityEvent:
      responseClass = [LoadCityResponseProto class];
      break;
    case EventProtocolResponseSRetrieveStaticDataEvent:
      responseClass = [RetrieveStaticDataResponseProto class];
      break;
    case EventProtocolResponseSQuestAcceptEvent:
      responseClass = [QuestAcceptResponseProto class];
      break;
    case EventProtocolResponseSQuestRedeemEvent:
      responseClass = [QuestRedeemResponseProto class];
      break;
    case EventProtocolResponseSUserQuestDetailsEvent:
      responseClass = [UserQuestDetailsResponseProto class];
      break;
    case EventProtocolResponseSQuestCompleteEvent:
      responseClass = [QuestCompleteResponseProto class];
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
    case EventProtocolResponseSChangeClanDescriptionEvent:
      responseClass = [ChangeClanDescriptionResponseProto class];
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
    case EventProtocolResponseSRetrieveLeaderboardRankingsEvent:
      responseClass = [RetrieveLeaderboardEventRankingsResponseProto class];
      break;
    case EventProtocolResponseSSubmitEquipEnhancementEvent:
      responseClass = [SubmitMonsterEnhancementResponseProto class];
      break;
    case EventProtocolResponseSRetrieveBoosterPackEvent:
      responseClass = [RetrieveBoosterPackResponseProto class];
      break;
    case EventProtocolResponseSPurchaseBoosterPackEvent:
      responseClass = [PurchaseBoosterPackResponseProto class];
      break;
    case EventProtocolResponseSChangeClanJoinTypeEvent:
      responseClass = [ChangeClanJoinTypeResponseProto class];
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
      responseClass = [EndDungeonRequestProto class];
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
  
  if (proto.updateStatus == StartupResponseProto_UpdateStatusMajorUpdate) {
    [GenericPopupController displayMajorUpdatePopup:proto.appStoreUrl];
    return;
  } else if (proto.updateStatus == StartupResponseProto_UpdateStatusMinorUpdate) {
    GenericPopupController *gpc = [GenericPopupController sharedGenericPopupController];
    gpc.appStoreLink = proto.appStoreUrl;
    [GenericPopupController displayConfirmationWithDescription:@"An update is available. Head over to the App Store to download it now!" title:@"Update Available" okayButton:@"Update" cancelButton:@"Later" target:gpc selector:@selector(openAppStoreLink)];
  }
  
  gl.reviewPageURL = proto.reviewPageUrl;
  gl.reviewPageConfirmationMessage = proto.reviewPageConfirmationMessage;
  
  [gl updateConstants:proto.startupConstants];
  if (proto.startupStatus == StartupResponseProto_StartupStatusUserInDb) {
    if (proto.sender.userId == 0) {
      LNLog(@"Received user id 0..");
      return;
    }
    
    // Update user before creating map
    [gs updateUser:proto.sender timestamp:0];
    
    // Setup the userid queue
    [[SocketCommunication sharedSocketCommunication] initUserIdMessageQueue];
    
    [gs setPlayerHasBoughtInAppPurchase:proto.playerHasBoughtInAppPurchase];
    
//    [Globals asyncDownloadBundles];
    
    OutgoingEventController *oec = [OutgoingEventController sharedOutgoingEventController];
    
    [gs.myCities removeAllObjects];
    [gs.staticCities removeAllObjects];
    [gs addToStaticCities:proto.allCitiesList];
    [gs.inProgressCompleteQuests removeAllObjects];
    [gs addToInProgressCompleteQuests:proto.inProgressCompleteQuestsList];
    [gs.inProgressIncompleteQuests removeAllObjects];
    [gs addToInProgressIncompleteQuests:proto.inProgressIncompleteQuestsList];
    // Put this after inprogress complete because available quests will be autoaccepted
    [gs.availableQuests removeAllObjects];
    [gs addToAvailableQuests:proto.availableQuestsList];
    [oec loadPlayerCity:gs.userId];
    [oec retrieveAllStaticData];
    [gs.staticStructs removeAllObjects];
    [gs addToStaticStructs:proto.staticStructsList];
    
    [gs addToRequestedClans:proto.userClanInfoList];
    
    gs.privateChats = proto.pcppList ? [proto.pcppList mutableCopy] : [NSMutableArray array];
    [gs.privateChats sortUsingComparator:^NSComparisonResult(PrivateChatPostProto *obj1, PrivateChatPostProto *obj2) {
      if (obj1.timeOfPost < obj2.timeOfPost) {
        return NSOrderedDescending;
      } else if (obj1.timeOfPost > obj2.timeOfPost) {
        return NSOrderedAscending;
      } else {
        return NSOrderedSame;
      }
    }];
    
    for (GroupChatMessageProto *msg in proto.globalChatsList) {
      ChatMessage *cm = [[ChatMessage alloc] initWithProto:msg];
      [gs addChatMessage:cm scope:GroupChatScopeGlobal];
      [cm release];
    }
    for (GroupChatMessageProto *msg in proto.clanChatsList) {
      ChatMessage *cm = [[ChatMessage alloc] initWithProto:msg];
      [gs addChatMessage:cm scope:GroupChatScopeClan];
      [cm release];
    }
    
    for (RareBoosterPurchaseProto *rbp in proto.rareBoosterPurchasesList) {
//      NSLog(@"%@ got %@ from %@.", rbp.user.name, rbp.equip.name, rbp.booster.name);
//      [gs addBoosterPurchase:rbp];
    }
    
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] registerForPushNotifications];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] removeLocalNotifications];
    
    [[GameViewController sharedGameViewController] loadGame:NO];
    
    // Display generic popups for strings that haven't been seen before
    NSUserDefaults *standardDefault = [NSUserDefaults standardUserDefaults];
    NSMutableArray *stringsStored = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"myCurrentString"]mutableCopy] autorelease];
    NSMutableArray *incomingStrings = [NSMutableArray arrayWithArray:proto.noticesToPlayersList];
    
    if (stringsStored == NULL){
      stringsStored = [[[NSMutableArray alloc]init] autorelease];
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
    [[GameViewController sharedGameViewController] loadGame:YES];
    
    gs.connected = YES;
    gs.expRequiredForCurrentLevel = 0;
  }
  
  [gs removeNonFullUserUpdatesForTag:tag];
  
  [[GameViewController sharedGameViewController] startupComplete];
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
  NSMutableArray *arr = [[[defaults arrayForKey:key] mutableCopy] autorelease];
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
      [Globals popupMessage:@"Sorry! The In App Purchase failed! Please 	email at support@lvl6.com"];
      [Analytics inAppPurchaseFailed];
    }
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    // Post notification so all UI with that bar can update
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:IAP_SUCCESS_NOTIFICATION object:nil]];
    [gs removeNonFullUserUpdatesForTag:tag];
    [Analytics purchasedGoldPackage:proto.packageName price:proto.packagePrice goldAmount:proto.diamondsGained];
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
      if (u.userStructId == 0) {
        us = u;
        break;
      }
    }
    
    if (proto.status == PurchaseCityExpansionResponseProto_PurchaseCityExpansionStatusSuccess) {
      if (proto.hasUserStructId) {
        us.userStructId = proto.userStructId;
      } else {
        // This should never happen
        LNLog(@"Received success in purchase with no userStructId");
      }
    } else {
      [Globals popupMessage:[NSString stringWithFormat:@"Something went wrong in the purchase. Error Status: %d", proto.status]];
      [[[GameState sharedGameState] myStructs] removeObject:us];
      [[HomeMap sharedHomeMap] refresh];
    }
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    if (proto.status == PurchaseNormStructureResponseProto_PurchaseNormStructureStatusClientTooApartFromServerTime) {
      [self handleTimeOutOfSync];
    } else {
      [Globals popupMessage:@"Server failed to purchase building."];
    }
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
    if (proto.status == UpgradeNormStructureResponseProto_UpgradeNormStructureStatusClientTooApartFromServerTime) {
      [self handleTimeOutOfSync];
    } else {
      [gs removeNonFullUserUpdatesForTag:tag];
    }
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
    if (proto.status == NormStructWaitCompleteResponseProto_NormStructWaitCompleteStatusClientTooApartFromServerTime) {
      [self handleTimeOutOfSync];
    } else {
      [gs removeNonFullUserUpdatesForTag:tag];
    }
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
    if (proto.status == FinishNormStructWaittimeWithDiamondsResponseProto_FinishNormStructWaittimeStatusClientTooApartFromServerTime) {
      [self handleTimeOutOfSync];
    } else {
      [gs removeNonFullUserUpdatesForTag:tag];
    }
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
  
  [[GameViewController sharedGameViewController] loadPlayerCityComplete];
  
  if (proto.status == LoadPlayerCityResponseProto_LoadPlayerCityStatusSuccess) {
    if (proto.cityOwner.userId == gs.userId) {
      gs.connected = YES;
      
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
      
      [[OutgoingEventController sharedOutgoingEventController] retrieveAllStaticData];
      
      if (![[HomeMap sharedHomeMap] loading]) {
        [[GameViewController sharedGameViewController] startGame];
      }
      
      [gs removeNonFullUserUpdatesForTag:tag];
      
      //      [[GameLayer sharedGameLayer] performBattleLossTutorial];
      
      // Check for unresponded in app purchases
      NSString *key = IAP_DEFAULTS_KEY;
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
      NSArray *arr = [defaults arrayForKey:key];
      [defaults removeObjectForKey:key];
      for (NSString *receipt in arr) {
        LNLog(@"Sending over unresponded receipt.");
        [[OutgoingEventController sharedOutgoingEventController] inAppPurchase:receipt goldAmt:0 silverAmt:0 product:nil];
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
    [[GameLayer sharedGameLayer] loadMissionMapWithProto:proto];//performSelectorInBackground:@selector(loadMissionMapWithProto:) withObject:proto];
    [[OutgoingEventController sharedOutgoingEventController] retrieveAllStaticData];
    [gs removeNonFullUserUpdatesForTag:tag];
  } else if (proto.status == LoadCityResponseProto_LoadCityStatusNotAccessibleToUser) {
    [Globals popupMessage:@"Trying to reach inaccessible city.."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to send back static data."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleRetrieveStaticDataResponseProto:(FullEvent *)fe {
  RetrieveStaticDataResponseProto *proto = (RetrieveStaticDataResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Retrieve static data response received with status %d", proto.status);
  GameState *gs = [GameState sharedGameState];
  
  if (proto.status == RetrieveStaticDataResponseProto_RetrieveStaticDataStatusSuccess) {
    [gs addToStaticBuildStructJobs:proto.buildStructJobsList];
    [gs addToStaticCities:proto.citiesList];
    [gs addToStaticQuests:proto.questsList];
    [gs addToStaticStructs:proto.structsList];
    [gs addToStaticTasks:proto.tasksList];
    [gs addToStaticUpgradeStructJobs:proto.upgradeStructJobsList];
    
    [[OutgoingEventController sharedOutgoingEventController] retrieveAllStaticData];
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to send back static data."];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleRetrieveBoosterPackResponseProto:(FullEvent *)fe {
  RetrieveBoosterPackResponseProto *proto = (RetrieveBoosterPackResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Retrieve booster pack response received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == RetrieveBoosterPackResponseProto_RetrieveBoosterPackStatusSuccess) {
    [gs addStaticBoosterPacks:proto.packsList];
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to send back booster packs.."];
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
    [[OutgoingEventController sharedOutgoingEventController] retrieveQuestLog];
    
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
    [[OutgoingEventController sharedOutgoingEventController] retrieveAllStaticData];
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to redeem quest"];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleUserQuestDetailsResponseProto:(FullEvent *)fe {
  UserQuestDetailsResponseProto *proto = (UserQuestDetailsResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Quest log details response received with status %d", proto.status);
  GameState *gs = [GameState sharedGameState];
  if (proto.status == UserQuestDetailsResponseProto_UserQuestDetailsStatusSuccess) {
    [[OutgoingEventController sharedOutgoingEventController] retrieveAllStaticData];
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    [Globals popupMessage:@"Server failed to send quest log details"];
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handleQuestCompleteResponseProto:(FullEvent *)fe {
  QuestCompleteResponseProto *proto = (QuestCompleteResponseProto *)fe.event;
  
  LNLog(@"Received quest complete response for quest %d.", proto.questId);
  
  GameState *gs = [GameState sharedGameState];
  NSNumber *questNum = [NSNumber numberWithInt:proto.questId];
  FullQuestProto *fqp = [gs.inProgressIncompleteQuests objectForKey:questNum];
  
  if (fqp) {
    [gs.inProgressCompleteQuests setObject:fqp forKey:questNum];
    [gs.inProgressIncompleteQuests removeObjectForKey:questNum];
    
    //GameMap *map = [Globals mapForQuest:fqp];
    //[map reloadQuestGivers];
    
    [Analytics questComplete:proto.questId];
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
  [un release];
  
  [Analytics receivedNotification];
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
  EarnFreeDiamondsResponseProto *proto = (EarnFreeDiamondsResponseProto *)fe.event;
  int tag = fe.tag;
  
  LNLog(@"Earn free diamonds response received with status %d.", proto.status);
  
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
  
  [[GameState sharedGameState] reretrieveStaticData];
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
  if (proto.sender.userId != gs.userId) {
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
    if (proto.requesterId == gs.userId) {
      [gs.requestedClans removeAllObjects];
      if (proto.accept) {
        gs.clan = proto.minClan;
        [[SocketCommunication sharedSocketCommunication] rebuildSender];
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
    if (proto.sender.userId == gs.userId) {
      [gs.requestedClans removeAllObjects];
      gs.clan = nil;
      [[SocketCommunication sharedSocketCommunication] rebuildSender];
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
    if (proto.sender.userId == gs.userId) {
      [gs.requestedClans addObject:[NSNumber numberWithInt:proto.clanId]];
    }
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else if (proto.status == RequestJoinClanResponseProto_RequestJoinClanStatusJoinSuccess) {
    if (proto.sender.userId == gs.userId) {
      [gs.requestedClans removeAllObjects];
      gs.clan = proto.minClan;
      [[SocketCommunication sharedSocketCommunication] rebuildSender];
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
    if (proto.sender.userId == gs.userId) {
      [gs.requestedClans removeObject:[NSNumber numberWithInt:proto.clanId]];
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
    if (proto.playerToBoot == gs.userId) {
      gs.clan = nil;
      [[SocketCommunication sharedSocketCommunication] rebuildSender];
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
    if (proto.status == ExpansionWaitCompleteResponseProto_ExpansionWaitCompleteStatusClientTooApartFromServerTime) {
      [self handleTimeOutOfSync];
    } else {
      [Globals popupMessage:@"Server failed to complete expansion wait time."];
    }
    
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
  RetrieveLeaderboardEventRankingsResponseProto *proto = (RetrieveLeaderboardEventRankingsResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Retrieve tournament response received with status %d and %d rankings.", proto.status, proto.resultPlayersList.count);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == RetrieveLeaderboardEventRankingsResponseProto_RetrieveLeaderboardStatusSuccess) {
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
  if (proto.status == SubmitMonsterEnhancementResponseProto_EnhanceMonsterStatusSuccess) {
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
    if (proto.status == SubmitMonsterEnhancementResponseProto_EnhanceMonsterStatusClientTooApartFromServerTime) {
      [self handleTimeOutOfSync];
    } else {
      [Globals popupMessage:@"Server failed to submit monster enhancement."];
    }
    
    [gs removeAndUndoAllUpdatesForTag:tag];
  }
}

- (void) handlePurchaseBoosterPackResponseProto:(FullEvent *)fe {
  PurchaseBoosterPackResponseProto *proto = (PurchaseBoosterPackResponseProto *)fe.event;
  int tag = fe.tag;
  LNLog(@"Purchase booster pack received with status %d.", proto.status);
  
  GameState *gs = [GameState sharedGameState];
  if (proto.status == PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatusSuccess) {
    
    [gs removeNonFullUserUpdatesForTag:tag];
  } else {
      if (proto.status == PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatusClientTooApartFromServerTime) {
        [self handleTimeOutOfSync];
      } else {
        [Globals popupMessage:@"Server failed to purchase booster pack."];
      }
    
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
  
//  [[ChatMenuController sharedChatMenuController] receivedPrivateChatPost:proto];
}

- (void) handleRetrievePrivateChatPostsResponseProto:(FullEvent *)fe {
  RetrievePrivateChatPostsResponseProto *proto = (RetrievePrivateChatPostsResponseProto *)fe.event;
  LNLog(@"Retrieve private chats received with status %d and %d posts.", proto.status, proto.postsList.count);
}

- (void) handleBeginDungeonResponseProto:(FullEvent *)fe {
  BeginDungeonResponseProto *proto = (BeginDungeonResponseProto *)fe.event;
  LNLog(@"Begin dungeon response received with status %d.", proto.status);
  
  if (proto.status == BeginDungeonResponseProto_BeginDungeonStatusSuccess) {
    [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:0.5 scene:[DungeonBattleLayer sceneWithBeginDungeonResponseProto:proto] withColor:ccBLACK]];
  } else {
    [Globals popupMessage:@"Server failed to enter dungeon."];
  }
}

@end
