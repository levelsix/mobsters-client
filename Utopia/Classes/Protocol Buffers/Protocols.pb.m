// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "Protocols.pb.h"
// @@protoc_insertion_point(imports)

@implementation ProtocolsRoot
static PBExtensionRegistry* extensionRegistry = nil;
+ (PBExtensionRegistry*) extensionRegistry {
  return extensionRegistry;
}

+ (void) initialize {
  if (self == [ProtocolsRoot class]) {
    PBMutableExtensionRegistry* registry = [PBMutableExtensionRegistry registry];
    [self registerAllExtensions:registry];
    [AchievementStuffRoot registerAllExtensions:registry];
    [BattleRoot registerAllExtensions:registry];
    [BoosterPackStuffRoot registerAllExtensions:registry];
    [ChatRoot registerAllExtensions:registry];
    [CityRoot registerAllExtensions:registry];
    [ClanRoot registerAllExtensions:registry];
    [DevRoot registerAllExtensions:registry];
    [EventAchievementRoot registerAllExtensions:registry];
    [EventApnsRoot registerAllExtensions:registry];
    [EventBoosterPackRoot registerAllExtensions:registry];
    [EventChatRoot registerAllExtensions:registry];
    [EventCityRoot registerAllExtensions:registry];
    [EventClanRoot registerAllExtensions:registry];
    [EventDevRoot registerAllExtensions:registry];
    [EventDungeonRoot registerAllExtensions:registry];
    [EventInAppPurchaseRoot registerAllExtensions:registry];
    [EventItemRoot registerAllExtensions:registry];
    [EventMiniJobRoot registerAllExtensions:registry];
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
    [ItemRoot registerAllExtensions:registry];
    [MiniJobConfigRoot registerAllExtensions:registry];
    [MonsterStuffRoot registerAllExtensions:registry];
    [PrerequisiteRoot registerAllExtensions:registry];
    [QuestRoot registerAllExtensions:registry];
    [SharedEnumConfigRoot registerAllExtensions:registry];
    [SkillRoot registerAllExtensions:registry];
    [StaticDataRoot registerAllExtensions:registry];
    [StructureRoot registerAllExtensions:registry];
    [TaskRoot registerAllExtensions:registry];
    [TournamentStuffRoot registerAllExtensions:registry];
    [UserRoot registerAllExtensions:registry];
    extensionRegistry = registry;
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
    case EventProtocolRequestCExchangeGemsForResourcesEvent:
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
    case EventProtocolRequestCChangeClanSettingsEvent:
    case EventProtocolRequestCBootPlayerFromClanEvent:
    case EventProtocolRequestCPickLockBoxEvent:
    case EventProtocolRequestCRetrieveTournamentRankingsEvent:
    case EventProtocolRequestCSubmitMonsterEnhancementEvent:
    case EventProtocolRequestCEvolveMonsterEvent:
    case EventProtocolRequestCPurchaseBoosterPackEvent:
    case EventProtocolRequestCEvolutionFinishedEvent:
    case EventProtocolRequestCAchievementProgressEvent:
    case EventProtocolRequestCPrivateChatPostEvent:
    case EventProtocolRequestCRetrievePrivateChatPostEvent:
    case EventProtocolRequestCRedeemUserLockBoxItemsEvent:
    case EventProtocolRequestCBeginDungeonEvent:
    case EventProtocolRequestCEndDungeonEvent:
    case EventProtocolRequestCReviveInDungeonEvent:
    case EventProtocolRequestCQueueUpEvent:
    case EventProtocolRequestCUpdateMonsterHealthEvent:
    case EventProtocolRequestCHealMonsterEvent:
    case EventProtocolRequestCAchievementRedeemEvent:
    case EventProtocolRequestCAddMonsterToBattleTeamEvent:
    case EventProtocolRequestCRemoveMonsterFromBattleTeamEvent:
    case EventProtocolRequestCIncreaseMonsterInventorySlotEvent:
    case EventProtocolRequestCEnhancementWaitTimeCompleteEvent:
    case EventProtocolRequestCCombineUserMonsterPiecesEvent:
    case EventProtocolRequestCSellUserMonsterEvent:
    case EventProtocolRequestCInviteFbFriendsForSlotsEvent:
    case EventProtocolRequestCAcceptAndRejectFbInviteForSlotsEvent:
    case EventProtocolRequestCUpdateUserCurrencyEvent:
    case EventProtocolRequestCBeginPvpBattleEvent:
    case EventProtocolRequestCEndPvpBattleEvent:
    case EventProtocolRequestCBeginClanRaidEvent:
    case EventProtocolRequestCAttackClanRaidMonsterEvent:
    case EventProtocolRequestCRecordClanRaidStatsEvent:
    case EventProtocolRequestCPromoteDemoteClanMemberEvent:
    case EventProtocolRequestCSetGameCenterIdEvent:
    case EventProtocolRequestCSpawnObstacleEvent:
    case EventProtocolRequestCBeginObstacleRemovalEvent:
    case EventProtocolRequestCObstacleRemovalCompleteEvent:
    case EventProtocolRequestCSpawnMiniJobEvent:
    case EventProtocolRequestCBeginMiniJobEvent:
    case EventProtocolRequestCCompleteMiniJobEvent:
    case EventProtocolRequestCRedeemMiniJobEvent:
    case EventProtocolRequestCSetAvatarMonsterEvent:
    case EventProtocolRequestCRestrictUserMonsterEvent:
    case EventProtocolRequestCUnrestrictUserMonsterEvent:
    case EventProtocolRequestCEnhanceMonsterEvent:
    case EventProtocolRequestCTradeItemForBoosterEvent:
    case EventProtocolRequestCSolicitClanHelpEvent:
    case EventProtocolRequestCGiveClanHelpEvent:
    case EventProtocolRequestCEndClanHelpEvent:
    case EventProtocolRequestCInviteToClanEvent:
    case EventProtocolRequestCAcceptOrRejectClanInviteEvent:
    case EventProtocolRequestCCollectMonsterEnhancementEvent:
    case EventProtocolRequestCTradeItemForSpeedUpsEvent:
    case EventProtocolRequestCLogoutEvent:
    case EventProtocolRequestCDevEvent:
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
    case EventProtocolResponseSExchangeGemsForResourcesEvent:
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
    case EventProtocolResponseSChangeClanSettingsEvent:
    case EventProtocolResponseSBootPlayerFromClanEvent:
    case EventProtocolResponseSPickLockBoxEvent:
    case EventProtocolResponseSRetrieveTournamentRankingsEvent:
    case EventProtocolResponseSSubmitMonsterEnhancementEvent:
    case EventProtocolResponseSEvolveMonsterEvent:
    case EventProtocolResponseSPurchaseBoosterPackEvent:
    case EventProtocolResponseSEvolutionFinishedEvent:
    case EventProtocolResponseSAchievementProgressEvent:
    case EventProtocolResponseSPrivateChatPostEvent:
    case EventProtocolResponseSRetrievePrivateChatPostEvent:
    case EventProtocolResponseSRedeemUserLockBoxItemsEvent:
    case EventProtocolResponseSBeginDungeonEvent:
    case EventProtocolResponseSEndDungeonEvent:
    case EventProtocolResponseSReviveInDungeonEvent:
    case EventProtocolResponseSQueueUpEvent:
    case EventProtocolResponseSUpdateMonsterHealthEvent:
    case EventProtocolResponseSHealMonsterEvent:
    case EventProtocolResponseSAchievementRedeemEvent:
    case EventProtocolResponseSAddMonsterToBattleTeamEvent:
    case EventProtocolResponseSRemoveMonsterFromBattleTeamEvent:
    case EventProtocolResponseSIncreaseMonsterInventorySlotEvent:
    case EventProtocolResponseSEnhancementWaitTimeCompleteEvent:
    case EventProtocolResponseSCombineUserMonsterPiecesEvent:
    case EventProtocolResponseSSellUserMonsterEvent:
    case EventProtocolResponseSInviteFbFriendsForSlotsEvent:
    case EventProtocolResponseSAcceptAndRejectFbInviteForSlotsEvent:
    case EventProtocolResponseSUpdateUserCurrencyEvent:
    case EventProtocolResponseSBeginPvpBattleEvent:
    case EventProtocolResponseSEndPvpBattleEvent:
    case EventProtocolResponseSBeginClanRaidEvent:
    case EventProtocolResponseSAttackClanRaidMonsterEvent:
    case EventProtocolResponseSRecordClanRaidStatsEvent:
    case EventProtocolResponseSPromoteDemoteClanMemberEvent:
    case EventProtocolResponseSSetGameCenterIdEvent:
    case EventProtocolResponseSSpawnObstacleEvent:
    case EventProtocolResponseSBeginObstacleRemovalEvent:
    case EventProtocolResponseSObstacleRemovalCompleteEvent:
    case EventProtocolResponseSSpawnMiniJobEvent:
    case EventProtocolResponseSBeginMiniJobEvent:
    case EventProtocolResponseSCompleteMiniJobEvent:
    case EventProtocolResponseSRedeemMiniJobEvent:
    case EventProtocolResponseSSetAvatarMonsterEvent:
    case EventProtocolResponseSRestrictUserMonsterEvent:
    case EventProtocolResponseSUnrestrictUserMonsterEvent:
    case EventProtocolResponseSEnhanceMonsterEvent:
    case EventProtocolResponseSTradeItemForBoosterEvent:
    case EventProtocolResponseSSolicitClanHelpEvent:
    case EventProtocolResponseSGiveClanHelpEvent:
    case EventProtocolResponseSEndClanHelpEvent:
    case EventProtocolResponseSInviteToClanEvent:
    case EventProtocolResponseSAcceptOrRejectClanInviteEvent:
    case EventProtocolResponseSCollectMonsterEnhancementEvent:
    case EventProtocolResponseSTradeItemForSpeedUpsEvent:
    case EventProtocolResponseSUpdateClientUserEvent:
    case EventProtocolResponseSReferralCodeUsedEvent:
    case EventProtocolResponseSPurgeStaticDataEvent:
    case EventProtocolResponseSReceivedGroupChatEvent:
    case EventProtocolResponseSSendAdminMessageEvent:
    case EventProtocolResponseSGeneralNotificationEvent:
    case EventProtocolResponseSReceivedRareBoosterPurchaseEvent:
    case EventProtocolResponseSAwardClanRaidStageRewardEvent:
    case EventProtocolResponseSForceLogoutEvent:
    case EventProtocolResponseSRetrieveClanDataEvent:
    case EventProtocolResponseSDevEvent:
      return YES;
    default:
      return NO;
  }
}

// @@protoc_insertion_point(global_scope)
