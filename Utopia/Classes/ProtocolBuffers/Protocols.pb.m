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
    [BattleItemRoot registerAllExtensions:registry];
    [BoardRoot registerAllExtensions:registry];
    [BoosterPackStuffRoot registerAllExtensions:registry];
    [ChatRoot registerAllExtensions:registry];
    [CityRoot registerAllExtensions:registry];
    [ClanRoot registerAllExtensions:registry];
    [DevRoot registerAllExtensions:registry];
    [EventAchievementRoot registerAllExtensions:registry];
    [EventApnsRoot registerAllExtensions:registry];
    [EventBattleItemRoot registerAllExtensions:registry];
    [EventBoosterPackRoot registerAllExtensions:registry];
    [EventChatRoot registerAllExtensions:registry];
    [EventCityRoot registerAllExtensions:registry];
    [EventClanRoot registerAllExtensions:registry];
    [EventDevRoot registerAllExtensions:registry];
    [EventDungeonRoot registerAllExtensions:registry];
    [EventInAppPurchaseRoot registerAllExtensions:registry];
    [EventItemRoot registerAllExtensions:registry];
    [EventLeaderBoardRoot registerAllExtensions:registry];
    [EventMiniEventRoot registerAllExtensions:registry];
    [EventMiniJobRoot registerAllExtensions:registry];
    [EventMonsterRoot registerAllExtensions:registry];
    [EventPvpRoot registerAllExtensions:registry];
    [EventQuestRoot registerAllExtensions:registry];
    [EventReferralRoot registerAllExtensions:registry];
    [EventResearchRoot registerAllExtensions:registry];
    [EventRewardRoot registerAllExtensions:registry];
    [EventStartupRoot registerAllExtensions:registry];
    [EventStaticDataRoot registerAllExtensions:registry];
    [EventStructureRoot registerAllExtensions:registry];
    [EventTournamentRoot registerAllExtensions:registry];
    [EventUserRoot registerAllExtensions:registry];
    [InAppPurchaseRoot registerAllExtensions:registry];
    [ItemRoot registerAllExtensions:registry];
    [LeaderBoardRoot registerAllExtensions:registry];
    [MiniEventRoot registerAllExtensions:registry];
    [MiniJobConfigRoot registerAllExtensions:registry];
    [MonsterStuffRoot registerAllExtensions:registry];
    [PrerequisiteRoot registerAllExtensions:registry];
    [QuestRoot registerAllExtensions:registry];
    [ResearchRoot registerAllExtensions:registry];
    [RewardRoot registerAllExtensions:registry];
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
    case EventProtocolRequestCRemoveUserItemUsedEvent:
    case EventProtocolRequestCTradeItemForResourcesEvent:
    case EventProtocolRequestCRedeemSecretGiftEvent:
    case EventProtocolRequestCSetDefendingMsgEvent:
    case EventProtocolRequestCBeginClanAvengingEvent:
    case EventProtocolRequestCEndClanAvengingEvent:
    case EventProtocolRequestCAvengeClanMateEvent:
    case EventProtocolRequestCUpdateClientTaskStateEvent:
    case EventProtocolRequestCSolicitTeamDonationEvent:
    case EventProtocolRequestCFulfillTeamDonationSolicitationEvent:
    case EventProtocolRequestCVoidTeamDonationSolicitationEvent:
    case EventProtocolRequestCRetrieveUserMonsterTeamEvent:
    case EventProtocolRequestCDestroyMoneyTreeStructureEvent:
    case EventProtocolRequestCLogoutEvent:
    case EventProtocolRequestCDevEvent:
    case EventProtocolRequestCPerformResearchEvent:
    case EventProtocolRequestCFinishPerformingResearchEvent:
    case EventProtocolRequestCCustomizePvpBoardObstacleEvent:
    case EventProtocolRequestCCreateBattleItemEvent:
    case EventProtocolRequestCDiscardBattleItemEvent:
    case EventProtocolRequestCCompleteBattleItemEvent:
    case EventProtocolRequestCRedeemMiniEventRewardEvent:
    case EventProtocolRequestCRetrieveMiniEventEvent:
    case EventProtocolRequestCUpdateMiniEventEvent:
    case EventProtocolRequestCTranslateSelectMessagesEvent:
    case EventProtocolRequestCUpdateUserStrengthEvent:
    case EventProtocolRequestCRefreshMiniJobEvent:
    case EventProtocolRequestCSetTangoIdEvent:
    case EventProtocolRequestCSendTangoGiftEvent:
    case EventProtocolRequestCDeleteGiftEvent:
    case EventProtocolRequestCCollectGiftEvent:
    case EventProtocolRequestCRetrieveBattleReplayEvent:
    case EventProtocolRequestCCollectClanGiftsEvent:
    case EventProtocolRequestCDeleteClanGiftsEvent:
    case EventProtocolRequestCReceivedClanGiftsEvent:
    case EventProtocolRequestCRetrieveStrengthLeaderBoardEvent:
    case EventProtocolRequestCPurchaseItemsWithGemsEvent:
    case EventProtocolRequestCReconnectEvent:
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
    case EventProtocolResponseSRemoveUserItemUsedEvent:
    case EventProtocolResponseSTradeItemForResourcesEvent:
    case EventProtocolResponseSRedeemSecretGiftEvent:
    case EventProtocolResponseSSetDefendingMsgEvent:
    case EventProtocolResponseSBeginClanAvengingEvent:
    case EventProtocolResponseSEndClanAvengingEvent:
    case EventProtocolResponseSAvengeClanMateEvent:
    case EventProtocolResponseSUpdateClientTaskStateEvent:
    case EventProtocolResponseSSolicitTeamDonationEvent:
    case EventProtocolResponseSFulfillTeamDonationSolicitationEvent:
    case EventProtocolResponseSVoidTeamDonationSolicitationEvent:
    case EventProtocolResponseSRetrieveUserMonsterTeamEvent:
    case EventProtocolResponseSDestroyMoneyTreeStructureEvent:
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
    case EventProtocolResponseSReceivedGiftEvent:
    case EventProtocolResponseSDevEvent:
    case EventProtocolResponseSPerformResearchEvent:
    case EventProtocolResponseSFinishPerformingResearchEvent:
    case EventProtocolResponseSCustomizePvpBoardObstacleEvent:
    case EventProtocolResponseSCreateBattleItemEvent:
    case EventProtocolResponseSDiscardBattleItemEvent:
    case EventProtocolResponseSCompleteBattleItemEvent:
    case EventProtocolResponseSRedeemMiniEventRewardEvent:
    case EventProtocolResponseSRetrieveMiniEventEvent:
    case EventProtocolResponseSUpdateMiniEventEvent:
    case EventProtocolResponseSTranslateSelectMessagesEvent:
    case EventProtocolResponseSUpdateUserStrengthEvent:
    case EventProtocolResponseSRefreshMiniJobEvent:
    case EventProtocolResponseSSetTangoIdEvent:
    case EventProtocolResponseSSendTangoGiftEvent:
    case EventProtocolResponseSDeleteGiftEvent:
    case EventProtocolResponseSCollectGiftEvent:
    case EventProtocolResponseSRetrieveBattleReplayEvent:
    case EventProtocolResponseSCollectClanGiftsEvent:
    case EventProtocolResponseSDeleteClanGiftsEvent:
    case EventProtocolResponseSReceivedClanGiftsEvent:
    case EventProtocolResponseSRetrieveStrengthLeaderBoardEvent:
    case EventProtocolResponseSReconnectEvent:
    case EventProtocolResponseSPurchaseItemsWithGemsEvent:
      return YES;
    default:
      return NO;
  }
}
@interface EventProto ()
@property int32_t eventType;
@property int32_t tagNum;
@property (strong) NSString* eventUuid;
@property (strong) NSData* eventBytes;
@end

@implementation EventProto

- (BOOL) hasEventType {
  return !!hasEventType_;
}
- (void) setHasEventType:(BOOL) value_ {
  hasEventType_ = !!value_;
}
@synthesize eventType;
- (BOOL) hasTagNum {
  return !!hasTagNum_;
}
- (void) setHasTagNum:(BOOL) value_ {
  hasTagNum_ = !!value_;
}
@synthesize tagNum;
- (BOOL) hasEventUuid {
  return !!hasEventUuid_;
}
- (void) setHasEventUuid:(BOOL) value_ {
  hasEventUuid_ = !!value_;
}
@synthesize eventUuid;
- (BOOL) hasEventBytes {
  return !!hasEventBytes_;
}
- (void) setHasEventBytes:(BOOL) value_ {
  hasEventBytes_ = !!value_;
}
@synthesize eventBytes;
- (id) init {
  if ((self = [super init])) {
    self.eventType = 0;
    self.tagNum = 0;
    self.eventUuid = @"";
    self.eventBytes = [NSData data];
  }
  return self;
}
static EventProto* defaultEventProtoInstance = nil;
+ (void) initialize {
  if (self == [EventProto class]) {
    defaultEventProtoInstance = [[EventProto alloc] init];
  }
}
+ (EventProto*) defaultInstance {
  return defaultEventProtoInstance;
}
- (EventProto*) defaultInstance {
  return defaultEventProtoInstance;
}
- (BOOL) isInitialized {
  return YES;
}
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output {
  if (self.hasEventType) {
    [output writeInt32:1 value:self.eventType];
  }
  if (self.hasTagNum) {
    [output writeInt32:2 value:self.tagNum];
  }
  if (self.hasEventUuid) {
    [output writeString:3 value:self.eventUuid];
  }
  if (self.hasEventBytes) {
    [output writeData:4 value:self.eventBytes];
  }
  [self.unknownFields writeToCodedOutputStream:output];
}
- (SInt32) serializedSize {
  __block SInt32 size_ = memoizedSerializedSize;
  if (size_ != -1) {
    return size_;
  }

  size_ = 0;
  if (self.hasEventType) {
    size_ += computeInt32Size(1, self.eventType);
  }
  if (self.hasTagNum) {
    size_ += computeInt32Size(2, self.tagNum);
  }
  if (self.hasEventUuid) {
    size_ += computeStringSize(3, self.eventUuid);
  }
  if (self.hasEventBytes) {
    size_ += computeDataSize(4, self.eventBytes);
  }
  size_ += self.unknownFields.serializedSize;
  memoizedSerializedSize = size_;
  return size_;
}
+ (EventProto*) parseFromData:(NSData*) data {
  return (EventProto*)[[[EventProto builder] mergeFromData:data] build];
}
+ (EventProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (EventProto*)[[[EventProto builder] mergeFromData:data extensionRegistry:extensionRegistry] build];
}
+ (EventProto*) parseFromInputStream:(NSInputStream*) input {
  return (EventProto*)[[[EventProto builder] mergeFromInputStream:input] build];
}
+ (EventProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (EventProto*)[[[EventProto builder] mergeFromInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (EventProto*) parseFromCodedInputStream:(PBCodedInputStream*) input {
  return (EventProto*)[[[EventProto builder] mergeFromCodedInputStream:input] build];
}
+ (EventProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (EventProto*)[[[EventProto builder] mergeFromCodedInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (EventProto_Builder*) builder {
  return [[EventProto_Builder alloc] init];
}
+ (EventProto_Builder*) builderWithPrototype:(EventProto*) prototype {
  return [[EventProto builder] mergeFrom:prototype];
}
- (EventProto_Builder*) builder {
  return [EventProto builder];
}
- (EventProto_Builder*) toBuilder {
  return [EventProto builderWithPrototype:self];
}
- (void) writeDescriptionTo:(NSMutableString*) output withIndent:(NSString*) indent {
  if (self.hasEventType) {
    [output appendFormat:@"%@%@: %@\n", indent, @"eventType", [NSNumber numberWithInteger:self.eventType]];
  }
  if (self.hasTagNum) {
    [output appendFormat:@"%@%@: %@\n", indent, @"tagNum", [NSNumber numberWithInteger:self.tagNum]];
  }
  if (self.hasEventUuid) {
    [output appendFormat:@"%@%@: %@\n", indent, @"eventUuid", self.eventUuid];
  }
  if (self.hasEventBytes) {
    [output appendFormat:@"%@%@: %@\n", indent, @"eventBytes", self.eventBytes];
  }
  [self.unknownFields writeDescriptionTo:output withIndent:indent];
}
- (BOOL) isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[EventProto class]]) {
    return NO;
  }
  EventProto *otherMessage = other;
  return
      self.hasEventType == otherMessage.hasEventType &&
      (!self.hasEventType || self.eventType == otherMessage.eventType) &&
      self.hasTagNum == otherMessage.hasTagNum &&
      (!self.hasTagNum || self.tagNum == otherMessage.tagNum) &&
      self.hasEventUuid == otherMessage.hasEventUuid &&
      (!self.hasEventUuid || [self.eventUuid isEqual:otherMessage.eventUuid]) &&
      self.hasEventBytes == otherMessage.hasEventBytes &&
      (!self.hasEventBytes || [self.eventBytes isEqual:otherMessage.eventBytes]) &&
      (self.unknownFields == otherMessage.unknownFields || (self.unknownFields != nil && [self.unknownFields isEqual:otherMessage.unknownFields]));
}
- (NSUInteger) hash {
  __block NSUInteger hashCode = 7;
  if (self.hasEventType) {
    hashCode = hashCode * 31 + [[NSNumber numberWithInteger:self.eventType] hash];
  }
  if (self.hasTagNum) {
    hashCode = hashCode * 31 + [[NSNumber numberWithInteger:self.tagNum] hash];
  }
  if (self.hasEventUuid) {
    hashCode = hashCode * 31 + [self.eventUuid hash];
  }
  if (self.hasEventBytes) {
    hashCode = hashCode * 31 + [self.eventBytes hash];
  }
  hashCode = hashCode * 31 + [self.unknownFields hash];
  return hashCode;
}
@end

@interface EventProto_Builder()
@property (strong) EventProto* result;
@end

@implementation EventProto_Builder
@synthesize result;
- (id) init {
  if ((self = [super init])) {
    self.result = [[EventProto alloc] init];
  }
  return self;
}
- (PBGeneratedMessage*) internalGetResult {
  return result;
}
- (EventProto_Builder*) clear {
  self.result = [[EventProto alloc] init];
  return self;
}
- (EventProto_Builder*) clone {
  return [EventProto builderWithPrototype:result];
}
- (EventProto*) defaultInstance {
  return [EventProto defaultInstance];
}
- (EventProto*) build {
  [self checkInitialized];
  return [self buildPartial];
}
- (EventProto*) buildPartial {
  EventProto* returnMe = result;
  self.result = nil;
  return returnMe;
}
- (EventProto_Builder*) mergeFrom:(EventProto*) other {
  if (other == [EventProto defaultInstance]) {
    return self;
  }
  if (other.hasEventType) {
    [self setEventType:other.eventType];
  }
  if (other.hasTagNum) {
    [self setTagNum:other.tagNum];
  }
  if (other.hasEventUuid) {
    [self setEventUuid:other.eventUuid];
  }
  if (other.hasEventBytes) {
    [self setEventBytes:other.eventBytes];
  }
  [self mergeUnknownFields:other.unknownFields];
  return self;
}
- (EventProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input {
  return [self mergeFromCodedInputStream:input extensionRegistry:[PBExtensionRegistry emptyRegistry]];
}
- (EventProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  PBUnknownFieldSetBuilder* unknownFields = [PBUnknownFieldSet builderWithUnknownFields:self.unknownFields];
  while (YES) {
    SInt32 tag = [input readTag];
    switch (tag) {
      case 0:
        [self setUnknownFields:[unknownFields build]];
        return self;
      default: {
        if (![self parseUnknownField:input unknownFields:unknownFields extensionRegistry:extensionRegistry tag:tag]) {
          [self setUnknownFields:[unknownFields build]];
          return self;
        }
        break;
      }
      case 8: {
        [self setEventType:[input readInt32]];
        break;
      }
      case 16: {
        [self setTagNum:[input readInt32]];
        break;
      }
      case 26: {
        [self setEventUuid:[input readString]];
        break;
      }
      case 34: {
        [self setEventBytes:[input readData]];
        break;
      }
    }
  }
}
- (BOOL) hasEventType {
  return result.hasEventType;
}
- (int32_t) eventType {
  return result.eventType;
}
- (EventProto_Builder*) setEventType:(int32_t) value {
  result.hasEventType = YES;
  result.eventType = value;
  return self;
}
- (EventProto_Builder*) clearEventType {
  result.hasEventType = NO;
  result.eventType = 0;
  return self;
}
- (BOOL) hasTagNum {
  return result.hasTagNum;
}
- (int32_t) tagNum {
  return result.tagNum;
}
- (EventProto_Builder*) setTagNum:(int32_t) value {
  result.hasTagNum = YES;
  result.tagNum = value;
  return self;
}
- (EventProto_Builder*) clearTagNum {
  result.hasTagNum = NO;
  result.tagNum = 0;
  return self;
}
- (BOOL) hasEventUuid {
  return result.hasEventUuid;
}
- (NSString*) eventUuid {
  return result.eventUuid;
}
- (EventProto_Builder*) setEventUuid:(NSString*) value {
  result.hasEventUuid = YES;
  result.eventUuid = value;
  return self;
}
- (EventProto_Builder*) clearEventUuid {
  result.hasEventUuid = NO;
  result.eventUuid = @"";
  return self;
}
- (BOOL) hasEventBytes {
  return result.hasEventBytes;
}
- (NSData*) eventBytes {
  return result.eventBytes;
}
- (EventProto_Builder*) setEventBytes:(NSData*) value {
  result.hasEventBytes = YES;
  result.eventBytes = value;
  return self;
}
- (EventProto_Builder*) clearEventBytes {
  result.hasEventBytes = NO;
  result.eventBytes = [NSData data];
  return self;
}
@end


// @@protoc_insertion_point(global_scope)
