// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "Protocols.pb.h"

@implementation ProtocolsRoot
static PBExtensionRegistry* extensionRegistry = nil;
+ (PBExtensionRegistry*) extensionRegistry {
  return extensionRegistry;
}

+ (void) initialize {
  if (self == [ProtocolsRoot class]) {
    PBMutableExtensionRegistry* registry = [PBMutableExtensionRegistry registry];
    [self registerAllExtensions:registry];
    [BattleRoot registerAllExtensions:registry];
    [BoosterPackStuffRoot registerAllExtensions:registry];
    [ChatRoot registerAllExtensions:registry];
    [CityRoot registerAllExtensions:registry];
    [ClanRoot registerAllExtensions:registry];
    [EventApnsRoot registerAllExtensions:registry];
    [EventBoosterPackRoot registerAllExtensions:registry];
    [EventChatRoot registerAllExtensions:registry];
    [EventCityRoot registerAllExtensions:registry];
    [EventClanRoot registerAllExtensions:registry];
    [EventDungeonRoot registerAllExtensions:registry];
    [EventInAppPurchaseRoot registerAllExtensions:registry];
    [EventMonsterRoot registerAllExtensions:registry];
    [EventPvpRoot registerAllExtensions:registry];
    [EventQuestRoot registerAllExtensions:registry];
    [EventReferralRoot registerAllExtensions:registry];
    [EventStartupRoot registerAllExtensions:registry];
    [EventStaticDataRoot registerAllExtensions:registry];
    [EventStructureRoot registerAllExtensions:registry];
    [EventTournamentRoot registerAllExtensions:registry];
    [EventUserRoot registerAllExtensions:registry];
    [InAppPurchaseRoot registerAllExtensions:registry];
    [MonsterStuffRoot registerAllExtensions:registry];
    [QuestRoot registerAllExtensions:registry];
    [StaticDataRoot registerAllExtensions:registry];
    [StructureRoot registerAllExtensions:registry];
    [TaskRoot registerAllExtensions:registry];
    [TournamentStuffRoot registerAllExtensions:registry];
    [UserRoot registerAllExtensions:registry];
    extensionRegistry = [registry retain];
  }
}
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry {
}
@end

BOOL EventProtocolRequestIsValidValue(EventProtocolRequest value) {
  switch (value) {
    case EventProtocolRequestCStartupEvent:
    case EventProtocolRequestCInAppPurchaseEvent:
    case EventProtocolRequestCPurchaseNormStructureEvent:
    case EventProtocolRequestCMoveOrRotateNormStructureEvent:
    case EventProtocolRequestCSetFacebookIdEvent:
    case EventProtocolRequestCUpgradeNormStructureEvent:
    case EventProtocolRequestCRetrieveCurrencyFromNormStructureEvent:
    case EventProtocolRequestCFinishNormStructWaittimeWithDiamondsEvent:
    case EventProtocolRequestCNormStructWaitCompleteEvent:
    case EventProtocolRequestCLoadPlayerCityEvent:
    case EventProtocolRequestCQuestAcceptEvent:
    case EventProtocolRequestCQuestProgressEvent:
    case EventProtocolRequestCQuestRedeemEvent:
    case EventProtocolRequestCPurchaseCityExpansionEvent:
    case EventProtocolRequestCExpansionWaitCompleteEvent:
    case EventProtocolRequestCLevelUpEvent:
    case EventProtocolRequestCEnableApnsEvent:
    case EventProtocolRequestCUserCreateEvent:
    case EventProtocolRequestCLoadCityEvent:
    case EventProtocolRequestCRetrieveUsersForUserIdsEvent:
    case EventProtocolRequestCEarnFreeDiamondsEvent:
    case EventProtocolRequestCSendGroupChatEvent:
    case EventProtocolRequestCCreateClanEvent:
    case EventProtocolRequestCLeaveClanEvent:
    case EventProtocolRequestCRequestJoinClanEvent:
    case EventProtocolRequestCRetractRequestJoinClanEvent:
    case EventProtocolRequestCApproveOrRejectRequestToJoinClanEvent:
    case EventProtocolRequestCTransferClanOwnership:
    case EventProtocolRequestCRetrieveClanInfoEvent:
    case EventProtocolRequestCChangeClanDescriptionEvent:
    case EventProtocolRequestCBootPlayerFromClanEvent:
    case EventProtocolRequestCPickLockBoxEvent:
    case EventProtocolRequestCRetrieveTournamentRankingsEvent:
    case EventProtocolRequestCSubmitMonsterEnhancementEvent:
    case EventProtocolRequestCPurchaseBoosterPackEvent:
    case EventProtocolRequestCChangeClanJoinTypeEvent:
    case EventProtocolRequestCPrivateChatPostEvent:
    case EventProtocolRequestCRetrievePrivateChatPostEvent:
    case EventProtocolRequestCRedeemUserLockBoxItemsEvent:
    case EventProtocolRequestCBeginDungeonEvent:
    case EventProtocolRequestCEndDungeonEvent:
    case EventProtocolRequestCReviveInDungeonEvent:
    case EventProtocolRequestCQueueUpEvent:
    case EventProtocolRequestCUpdateMonsterHealthEvent:
    case EventProtocolRequestCHealMonsterEvent:
    case EventProtocolRequestCHealMonsterWaitTimeCompleteEvent:
    case EventProtocolRequestCAddMonsterToBattleTeamEvent:
    case EventProtocolRequestCRemoveMonsterFromBattleTeamEvent:
    case EventProtocolRequestCIncreaseMonsterInventorySlotEvent:
    case EventProtocolRequestCEnhancementWaitTimeCompleteEvent:
    case EventProtocolRequestCCombineUserMonsterPiecesEvent:
    case EventProtocolRequestCSellUserMonsterEvent:
    case EventProtocolRequestCInviteFbFriendsForSlotsEvent:
    case EventProtocolRequestCAcceptAndRejectFbInviteForSlotsEvent:
    case EventProtocolRequestCLogoutEvent:
      return YES;
    default:
      return NO;
  }
}
BOOL EventProtocolResponseIsValidValue(EventProtocolResponse value) {
  switch (value) {
    case EventProtocolResponseSStartupEvent:
    case EventProtocolResponseSInAppPurchaseEvent:
    case EventProtocolResponseSPurchaseNormStructureEvent:
    case EventProtocolResponseSMoveOrRotateNormStructureEvent:
    case EventProtocolResponseSSetFacebookIdEvent:
    case EventProtocolResponseSUpgradeNormStructureEvent:
    case EventProtocolResponseSRetrieveCurrencyFromNormStructureEvent:
    case EventProtocolResponseSFinishNormStructWaittimeWithDiamondsEvent:
    case EventProtocolResponseSNormStructWaitCompleteEvent:
    case EventProtocolResponseSLoadPlayerCityEvent:
    case EventProtocolResponseSQuestAcceptEvent:
    case EventProtocolResponseSQuestProgressEvent:
    case EventProtocolResponseSQuestRedeemEvent:
    case EventProtocolResponseSPurchaseCityExpansionEvent:
    case EventProtocolResponseSExpansionWaitCompleteEvent:
    case EventProtocolResponseSLevelUpEvent:
    case EventProtocolResponseSEnableApnsEvent:
    case EventProtocolResponseSUserCreateEvent:
    case EventProtocolResponseSLoadCityEvent:
    case EventProtocolResponseSRetrieveUsersForUserIdsEvent:
    case EventProtocolResponseSEarnFreeDiamondsEvent:
    case EventProtocolResponseSSendGroupChatEvent:
    case EventProtocolResponseSCreateClanEvent:
    case EventProtocolResponseSLeaveClanEvent:
    case EventProtocolResponseSRequestJoinClanEvent:
    case EventProtocolResponseSRetractRequestJoinClanEvent:
    case EventProtocolResponseSApproveOrRejectRequestToJoinClanEvent:
    case EventProtocolResponseSTransferClanOwnership:
    case EventProtocolResponseSRetrieveClanInfoEvent:
    case EventProtocolResponseSChangeClanDescriptionEvent:
    case EventProtocolResponseSBootPlayerFromClanEvent:
    case EventProtocolResponseSPickLockBoxEvent:
    case EventProtocolResponseSRetrieveTournamentRankingsEvent:
    case EventProtocolResponseSSubmitMonsterEnhancementEvent:
    case EventProtocolResponseSPurchaseBoosterPackEvent:
    case EventProtocolResponseSChangeClanJoinTypeEvent:
    case EventProtocolResponseSPrivateChatPostEvent:
    case EventProtocolResponseSRetrievePrivateChatPostEvent:
    case EventProtocolResponseSRedeemUserLockBoxItemsEvent:
    case EventProtocolResponseSBeginDungeonEvent:
    case EventProtocolResponseSEndDungeonEvent:
    case EventProtocolResponseSReviveInDungeonEvent:
    case EventProtocolResponseSQueueUpEvent:
    case EventProtocolResponseSUpdateMonsterHealthEvent:
    case EventProtocolResponseSHealMonsterEvent:
    case EventProtocolResponseSHealMonsterWaitTimeCompleteEvent:
    case EventProtocolResponseSAddMonsterToBattleTeamEvent:
    case EventProtocolResponseSRemoveMonsterFromBattleTeamEvent:
    case EventProtocolResponseSIncreaseMonsterInventorySlotEvent:
    case EventProtocolResponseSEnhancementWaitTimeCompleteEvent:
    case EventProtocolResponseSCombineUserMonsterPiecesEvent:
    case EventProtocolResponseSSellUserMonsterEvent:
    case EventProtocolResponseSInviteFbFriendsForSlotsEvent:
    case EventProtocolResponseSAcceptAndRejectFbInviteForSlotsEvent:
    case EventProtocolResponseSUpdateClientUserEvent:
    case EventProtocolResponseSReferralCodeUsedEvent:
    case EventProtocolResponseSPurgeStaticDataEvent:
    case EventProtocolResponseSReceivedGroupChatEvent:
    case EventProtocolResponseSSendAdminMessageEvent:
    case EventProtocolResponseSGeneralNotificationEvent:
    case EventProtocolResponseSReceivedRareBoosterPurchaseEvent:
      return YES;
    default:
      return NO;
  }
}
