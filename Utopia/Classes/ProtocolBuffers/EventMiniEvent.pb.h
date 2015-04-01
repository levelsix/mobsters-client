// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "MiniEvent.pb.h"
#import "Reward.pb.h"
#import "User.pb.h"
// @@protoc_insertion_point(imports)

@class ClanMemberTeamDonationProto;
@class ClanMemberTeamDonationProto_Builder;
@class FullUserMonsterProto;
@class FullUserMonsterProto_Builder;
@class FullUserProto;
@class FullUserProto_Builder;
@class ItemGemPriceProto;
@class ItemGemPriceProto_Builder;
@class ItemProto;
@class ItemProto_Builder;
@class MiniEventForPlayerLevelProto;
@class MiniEventForPlayerLevelProto_Builder;
@class MiniEventGoalProto;
@class MiniEventGoalProto_Builder;
@class MiniEventLeaderboardRewardProto;
@class MiniEventLeaderboardRewardProto_Builder;
@class MiniEventProto;
@class MiniEventProto_Builder;
@class MiniEventTierRewardProto;
@class MiniEventTierRewardProto_Builder;
@class MinimumClanProto;
@class MinimumClanProto_Builder;
@class MinimumUserMonsterProto;
@class MinimumUserMonsterProto_Builder;
@class MinimumUserMonsterSellProto;
@class MinimumUserMonsterSellProto_Builder;
@class MinimumUserProto;
@class MinimumUserProtoWithFacebookId;
@class MinimumUserProtoWithFacebookId_Builder;
@class MinimumUserProtoWithLevel;
@class MinimumUserProtoWithLevel_Builder;
@class MinimumUserProtoWithMaxResources;
@class MinimumUserProtoWithMaxResources_Builder;
@class MinimumUserProto_Builder;
@class MonsterBattleDialogueProto;
@class MonsterBattleDialogueProto_Builder;
@class MonsterLevelInfoProto;
@class MonsterLevelInfoProto_Builder;
@class MonsterProto;
@class MonsterProto_Builder;
@class RedeemMiniEventRewardRequestProto;
@class RedeemMiniEventRewardRequestProto_Builder;
@class RedeemMiniEventRewardResponseProto;
@class RedeemMiniEventRewardResponseProto_Builder;
@class RetrieveMiniEventRequestProto;
@class RetrieveMiniEventRequestProto_Builder;
@class RetrieveMiniEventResponseProto;
@class RetrieveMiniEventResponseProto_Builder;
@class RewardProto;
@class RewardProto_Builder;
@class StaticUserLevelInfoProto;
@class StaticUserLevelInfoProto_Builder;
@class UpdateMiniEventRequestProto;
@class UpdateMiniEventRequestProto_Builder;
@class UpdateMiniEventResponseProto;
@class UpdateMiniEventResponseProto_Builder;
@class UserCurrentMonsterTeamProto;
@class UserCurrentMonsterTeamProto_Builder;
@class UserEnhancementItemProto;
@class UserEnhancementItemProto_Builder;
@class UserEnhancementProto;
@class UserEnhancementProto_Builder;
@class UserFacebookInviteForSlotProto;
@class UserFacebookInviteForSlotProto_Builder;
@class UserItemProto;
@class UserItemProto_Builder;
@class UserItemSecretGiftProto;
@class UserItemSecretGiftProto_Builder;
@class UserItemUsageProto;
@class UserItemUsageProto_Builder;
@class UserMiniEventGoalProto;
@class UserMiniEventGoalProto_Builder;
@class UserMiniEventProto;
@class UserMiniEventProto_Builder;
@class UserMonsterCurrentExpProto;
@class UserMonsterCurrentExpProto_Builder;
@class UserMonsterCurrentHealthProto;
@class UserMonsterCurrentHealthProto_Builder;
@class UserMonsterEvolutionProto;
@class UserMonsterEvolutionProto_Builder;
@class UserMonsterHealingProto;
@class UserMonsterHealingProto_Builder;
@class UserMonsterSnapshotProto;
@class UserMonsterSnapshotProto_Builder;
@class UserPvpLeagueProto;
@class UserPvpLeagueProto_Builder;
@class UserRewardProto;
@class UserRewardProto_Builder;
#ifndef __has_feature
  #define __has_feature(x) 0 // Compatibility with non-clang compilers.
#endif // __has_feature

#ifndef NS_RETURNS_NOT_RETAINED
  #if __has_feature(attribute_ns_returns_not_retained)
    #define NS_RETURNS_NOT_RETAINED __attribute__((ns_returns_not_retained))
  #else
    #define NS_RETURNS_NOT_RETAINED
  #endif
#endif

typedef NS_ENUM(SInt32, RetrieveMiniEventResponseProto_RetrieveMiniEventStatus) {
  RetrieveMiniEventResponseProto_RetrieveMiniEventStatusSuccess = 1,
  RetrieveMiniEventResponseProto_RetrieveMiniEventStatusFailOther = 2,
};

BOOL RetrieveMiniEventResponseProto_RetrieveMiniEventStatusIsValidValue(RetrieveMiniEventResponseProto_RetrieveMiniEventStatus value);

typedef NS_ENUM(SInt32, UpdateMiniEventResponseProto_UpdateMiniEventStatus) {
  UpdateMiniEventResponseProto_UpdateMiniEventStatusSuccess = 1,
  UpdateMiniEventResponseProto_UpdateMiniEventStatusFailOther = 2,
};

BOOL UpdateMiniEventResponseProto_UpdateMiniEventStatusIsValidValue(UpdateMiniEventResponseProto_UpdateMiniEventStatus value);

typedef NS_ENUM(SInt32, RedeemMiniEventRewardRequestProto_RewardTier) {
  RedeemMiniEventRewardRequestProto_RewardTierTierOne = 1,
  RedeemMiniEventRewardRequestProto_RewardTierTierTwo = 2,
  RedeemMiniEventRewardRequestProto_RewardTierTierThree = 3,
};

BOOL RedeemMiniEventRewardRequestProto_RewardTierIsValidValue(RedeemMiniEventRewardRequestProto_RewardTier value);

typedef NS_ENUM(SInt32, RedeemMiniEventRewardResponseProto_RedeemMiniEventRewardStatus) {
  RedeemMiniEventRewardResponseProto_RedeemMiniEventRewardStatusSuccess = 1,
  RedeemMiniEventRewardResponseProto_RedeemMiniEventRewardStatusFailOther = 2,
};

BOOL RedeemMiniEventRewardResponseProto_RedeemMiniEventRewardStatusIsValidValue(RedeemMiniEventRewardResponseProto_RedeemMiniEventRewardStatus value);


@interface EventMiniEventRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface RetrieveMiniEventRequestProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  MinimumUserProto* sender;
}
- (BOOL) hasSender;
@property (readonly, strong) MinimumUserProto* sender;

+ (RetrieveMiniEventRequestProto*) defaultInstance;
- (RetrieveMiniEventRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (RetrieveMiniEventRequestProto_Builder*) builder;
+ (RetrieveMiniEventRequestProto_Builder*) builder;
+ (RetrieveMiniEventRequestProto_Builder*) builderWithPrototype:(RetrieveMiniEventRequestProto*) prototype;
- (RetrieveMiniEventRequestProto_Builder*) toBuilder;

+ (RetrieveMiniEventRequestProto*) parseFromData:(NSData*) data;
+ (RetrieveMiniEventRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RetrieveMiniEventRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (RetrieveMiniEventRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RetrieveMiniEventRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (RetrieveMiniEventRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface RetrieveMiniEventRequestProto_Builder : PBGeneratedMessageBuilder {
@private
  RetrieveMiniEventRequestProto* result;
}

- (RetrieveMiniEventRequestProto*) defaultInstance;

- (RetrieveMiniEventRequestProto_Builder*) clear;
- (RetrieveMiniEventRequestProto_Builder*) clone;

- (RetrieveMiniEventRequestProto*) build;
- (RetrieveMiniEventRequestProto*) buildPartial;

- (RetrieveMiniEventRequestProto_Builder*) mergeFrom:(RetrieveMiniEventRequestProto*) other;
- (RetrieveMiniEventRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (RetrieveMiniEventRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (RetrieveMiniEventRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (RetrieveMiniEventRequestProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (RetrieveMiniEventRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (RetrieveMiniEventRequestProto_Builder*) clearSender;
@end

@interface RetrieveMiniEventResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasUserMiniEvent_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  UserMiniEventProto* userMiniEvent;
  RetrieveMiniEventResponseProto_RetrieveMiniEventStatus status;
}
- (BOOL) hasSender;
- (BOOL) hasUserMiniEvent;
- (BOOL) hasStatus;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly, strong) UserMiniEventProto* userMiniEvent;
@property (readonly) RetrieveMiniEventResponseProto_RetrieveMiniEventStatus status;

+ (RetrieveMiniEventResponseProto*) defaultInstance;
- (RetrieveMiniEventResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (RetrieveMiniEventResponseProto_Builder*) builder;
+ (RetrieveMiniEventResponseProto_Builder*) builder;
+ (RetrieveMiniEventResponseProto_Builder*) builderWithPrototype:(RetrieveMiniEventResponseProto*) prototype;
- (RetrieveMiniEventResponseProto_Builder*) toBuilder;

+ (RetrieveMiniEventResponseProto*) parseFromData:(NSData*) data;
+ (RetrieveMiniEventResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RetrieveMiniEventResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (RetrieveMiniEventResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RetrieveMiniEventResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (RetrieveMiniEventResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface RetrieveMiniEventResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  RetrieveMiniEventResponseProto* result;
}

- (RetrieveMiniEventResponseProto*) defaultInstance;

- (RetrieveMiniEventResponseProto_Builder*) clear;
- (RetrieveMiniEventResponseProto_Builder*) clone;

- (RetrieveMiniEventResponseProto*) build;
- (RetrieveMiniEventResponseProto*) buildPartial;

- (RetrieveMiniEventResponseProto_Builder*) mergeFrom:(RetrieveMiniEventResponseProto*) other;
- (RetrieveMiniEventResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (RetrieveMiniEventResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (RetrieveMiniEventResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (RetrieveMiniEventResponseProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (RetrieveMiniEventResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (RetrieveMiniEventResponseProto_Builder*) clearSender;

- (BOOL) hasUserMiniEvent;
- (UserMiniEventProto*) userMiniEvent;
- (RetrieveMiniEventResponseProto_Builder*) setUserMiniEvent:(UserMiniEventProto*) value;
- (RetrieveMiniEventResponseProto_Builder*) setUserMiniEvent_Builder:(UserMiniEventProto_Builder*) builderForValue;
- (RetrieveMiniEventResponseProto_Builder*) mergeUserMiniEvent:(UserMiniEventProto*) value;
- (RetrieveMiniEventResponseProto_Builder*) clearUserMiniEvent;

- (BOOL) hasStatus;
- (RetrieveMiniEventResponseProto_RetrieveMiniEventStatus) status;
- (RetrieveMiniEventResponseProto_Builder*) setStatus:(RetrieveMiniEventResponseProto_RetrieveMiniEventStatus) value;
- (RetrieveMiniEventResponseProto_Builder*) clearStatusList;
@end

@interface UpdateMiniEventRequestProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  MinimumUserProto* sender;
  NSMutableArray * mutableUpdatedGoalsList;
}
- (BOOL) hasSender;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly, strong) NSArray * updatedGoalsList;
- (UserMiniEventGoalProto*)updatedGoalsAtIndex:(NSUInteger)index;

+ (UpdateMiniEventRequestProto*) defaultInstance;
- (UpdateMiniEventRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (UpdateMiniEventRequestProto_Builder*) builder;
+ (UpdateMiniEventRequestProto_Builder*) builder;
+ (UpdateMiniEventRequestProto_Builder*) builderWithPrototype:(UpdateMiniEventRequestProto*) prototype;
- (UpdateMiniEventRequestProto_Builder*) toBuilder;

+ (UpdateMiniEventRequestProto*) parseFromData:(NSData*) data;
+ (UpdateMiniEventRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UpdateMiniEventRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (UpdateMiniEventRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UpdateMiniEventRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (UpdateMiniEventRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface UpdateMiniEventRequestProto_Builder : PBGeneratedMessageBuilder {
@private
  UpdateMiniEventRequestProto* result;
}

- (UpdateMiniEventRequestProto*) defaultInstance;

- (UpdateMiniEventRequestProto_Builder*) clear;
- (UpdateMiniEventRequestProto_Builder*) clone;

- (UpdateMiniEventRequestProto*) build;
- (UpdateMiniEventRequestProto*) buildPartial;

- (UpdateMiniEventRequestProto_Builder*) mergeFrom:(UpdateMiniEventRequestProto*) other;
- (UpdateMiniEventRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (UpdateMiniEventRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (UpdateMiniEventRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (UpdateMiniEventRequestProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (UpdateMiniEventRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (UpdateMiniEventRequestProto_Builder*) clearSender;

- (NSMutableArray *)updatedGoalsList;
- (UserMiniEventGoalProto*)updatedGoalsAtIndex:(NSUInteger)index;
- (UpdateMiniEventRequestProto_Builder *)addUpdatedGoals:(UserMiniEventGoalProto*)value;
- (UpdateMiniEventRequestProto_Builder *)addAllUpdatedGoals:(NSArray *)array;
- (UpdateMiniEventRequestProto_Builder *)clearUpdatedGoals;
@end

@interface UpdateMiniEventResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasUpdatedUserMiniEvent_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  UserMiniEventProto* updatedUserMiniEvent;
  UpdateMiniEventResponseProto_UpdateMiniEventStatus status;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
- (BOOL) hasUpdatedUserMiniEvent;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) UpdateMiniEventResponseProto_UpdateMiniEventStatus status;
@property (readonly, strong) UserMiniEventProto* updatedUserMiniEvent;

+ (UpdateMiniEventResponseProto*) defaultInstance;
- (UpdateMiniEventResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (UpdateMiniEventResponseProto_Builder*) builder;
+ (UpdateMiniEventResponseProto_Builder*) builder;
+ (UpdateMiniEventResponseProto_Builder*) builderWithPrototype:(UpdateMiniEventResponseProto*) prototype;
- (UpdateMiniEventResponseProto_Builder*) toBuilder;

+ (UpdateMiniEventResponseProto*) parseFromData:(NSData*) data;
+ (UpdateMiniEventResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UpdateMiniEventResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (UpdateMiniEventResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UpdateMiniEventResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (UpdateMiniEventResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface UpdateMiniEventResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  UpdateMiniEventResponseProto* result;
}

- (UpdateMiniEventResponseProto*) defaultInstance;

- (UpdateMiniEventResponseProto_Builder*) clear;
- (UpdateMiniEventResponseProto_Builder*) clone;

- (UpdateMiniEventResponseProto*) build;
- (UpdateMiniEventResponseProto*) buildPartial;

- (UpdateMiniEventResponseProto_Builder*) mergeFrom:(UpdateMiniEventResponseProto*) other;
- (UpdateMiniEventResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (UpdateMiniEventResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (UpdateMiniEventResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (UpdateMiniEventResponseProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (UpdateMiniEventResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (UpdateMiniEventResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (UpdateMiniEventResponseProto_UpdateMiniEventStatus) status;
- (UpdateMiniEventResponseProto_Builder*) setStatus:(UpdateMiniEventResponseProto_UpdateMiniEventStatus) value;
- (UpdateMiniEventResponseProto_Builder*) clearStatusList;

- (BOOL) hasUpdatedUserMiniEvent;
- (UserMiniEventProto*) updatedUserMiniEvent;
- (UpdateMiniEventResponseProto_Builder*) setUpdatedUserMiniEvent:(UserMiniEventProto*) value;
- (UpdateMiniEventResponseProto_Builder*) setUpdatedUserMiniEvent_Builder:(UserMiniEventProto_Builder*) builderForValue;
- (UpdateMiniEventResponseProto_Builder*) mergeUpdatedUserMiniEvent:(UserMiniEventProto*) value;
- (UpdateMiniEventResponseProto_Builder*) clearUpdatedUserMiniEvent;
@end

@interface RedeemMiniEventRewardRequestProto : PBGeneratedMessage {
@private
  BOOL hasClientTime_:1;
  BOOL hasMefplId_:1;
  BOOL hasSender_:1;
  BOOL hasTierRedeemed_:1;
  int64_t clientTime;
  int32_t mefplId;
  MinimumUserProtoWithMaxResources* sender;
  RedeemMiniEventRewardRequestProto_RewardTier tierRedeemed;
}
- (BOOL) hasSender;
- (BOOL) hasTierRedeemed;
- (BOOL) hasMefplId;
- (BOOL) hasClientTime;
@property (readonly, strong) MinimumUserProtoWithMaxResources* sender;
@property (readonly) RedeemMiniEventRewardRequestProto_RewardTier tierRedeemed;
@property (readonly) int32_t mefplId;
@property (readonly) int64_t clientTime;

+ (RedeemMiniEventRewardRequestProto*) defaultInstance;
- (RedeemMiniEventRewardRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (RedeemMiniEventRewardRequestProto_Builder*) builder;
+ (RedeemMiniEventRewardRequestProto_Builder*) builder;
+ (RedeemMiniEventRewardRequestProto_Builder*) builderWithPrototype:(RedeemMiniEventRewardRequestProto*) prototype;
- (RedeemMiniEventRewardRequestProto_Builder*) toBuilder;

+ (RedeemMiniEventRewardRequestProto*) parseFromData:(NSData*) data;
+ (RedeemMiniEventRewardRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RedeemMiniEventRewardRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (RedeemMiniEventRewardRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RedeemMiniEventRewardRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (RedeemMiniEventRewardRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface RedeemMiniEventRewardRequestProto_Builder : PBGeneratedMessageBuilder {
@private
  RedeemMiniEventRewardRequestProto* result;
}

- (RedeemMiniEventRewardRequestProto*) defaultInstance;

- (RedeemMiniEventRewardRequestProto_Builder*) clear;
- (RedeemMiniEventRewardRequestProto_Builder*) clone;

- (RedeemMiniEventRewardRequestProto*) build;
- (RedeemMiniEventRewardRequestProto*) buildPartial;

- (RedeemMiniEventRewardRequestProto_Builder*) mergeFrom:(RedeemMiniEventRewardRequestProto*) other;
- (RedeemMiniEventRewardRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (RedeemMiniEventRewardRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProtoWithMaxResources*) sender;
- (RedeemMiniEventRewardRequestProto_Builder*) setSender:(MinimumUserProtoWithMaxResources*) value;
- (RedeemMiniEventRewardRequestProto_Builder*) setSender_Builder:(MinimumUserProtoWithMaxResources_Builder*) builderForValue;
- (RedeemMiniEventRewardRequestProto_Builder*) mergeSender:(MinimumUserProtoWithMaxResources*) value;
- (RedeemMiniEventRewardRequestProto_Builder*) clearSender;

- (BOOL) hasTierRedeemed;
- (RedeemMiniEventRewardRequestProto_RewardTier) tierRedeemed;
- (RedeemMiniEventRewardRequestProto_Builder*) setTierRedeemed:(RedeemMiniEventRewardRequestProto_RewardTier) value;
- (RedeemMiniEventRewardRequestProto_Builder*) clearTierRedeemedList;

- (BOOL) hasMefplId;
- (int32_t) mefplId;
- (RedeemMiniEventRewardRequestProto_Builder*) setMefplId:(int32_t) value;
- (RedeemMiniEventRewardRequestProto_Builder*) clearMefplId;

- (BOOL) hasClientTime;
- (int64_t) clientTime;
- (RedeemMiniEventRewardRequestProto_Builder*) setClientTime:(int64_t) value;
- (RedeemMiniEventRewardRequestProto_Builder*) clearClientTime;
@end

@interface RedeemMiniEventRewardResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  RedeemMiniEventRewardResponseProto_RedeemMiniEventRewardStatus status;
  NSMutableArray * mutableRewardsList;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) RedeemMiniEventRewardResponseProto_RedeemMiniEventRewardStatus status;
@property (readonly, strong) NSArray * rewardsList;
- (RewardProto*)rewardsAtIndex:(NSUInteger)index;

+ (RedeemMiniEventRewardResponseProto*) defaultInstance;
- (RedeemMiniEventRewardResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (RedeemMiniEventRewardResponseProto_Builder*) builder;
+ (RedeemMiniEventRewardResponseProto_Builder*) builder;
+ (RedeemMiniEventRewardResponseProto_Builder*) builderWithPrototype:(RedeemMiniEventRewardResponseProto*) prototype;
- (RedeemMiniEventRewardResponseProto_Builder*) toBuilder;

+ (RedeemMiniEventRewardResponseProto*) parseFromData:(NSData*) data;
+ (RedeemMiniEventRewardResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RedeemMiniEventRewardResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (RedeemMiniEventRewardResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RedeemMiniEventRewardResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (RedeemMiniEventRewardResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface RedeemMiniEventRewardResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  RedeemMiniEventRewardResponseProto* result;
}

- (RedeemMiniEventRewardResponseProto*) defaultInstance;

- (RedeemMiniEventRewardResponseProto_Builder*) clear;
- (RedeemMiniEventRewardResponseProto_Builder*) clone;

- (RedeemMiniEventRewardResponseProto*) build;
- (RedeemMiniEventRewardResponseProto*) buildPartial;

- (RedeemMiniEventRewardResponseProto_Builder*) mergeFrom:(RedeemMiniEventRewardResponseProto*) other;
- (RedeemMiniEventRewardResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (RedeemMiniEventRewardResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (RedeemMiniEventRewardResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (RedeemMiniEventRewardResponseProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (RedeemMiniEventRewardResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (RedeemMiniEventRewardResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (RedeemMiniEventRewardResponseProto_RedeemMiniEventRewardStatus) status;
- (RedeemMiniEventRewardResponseProto_Builder*) setStatus:(RedeemMiniEventRewardResponseProto_RedeemMiniEventRewardStatus) value;
- (RedeemMiniEventRewardResponseProto_Builder*) clearStatusList;

- (NSMutableArray *)rewardsList;
- (RewardProto*)rewardsAtIndex:(NSUInteger)index;
- (RedeemMiniEventRewardResponseProto_Builder *)addRewards:(RewardProto*)value;
- (RedeemMiniEventRewardResponseProto_Builder *)addAllRewards:(NSArray *)array;
- (RedeemMiniEventRewardResponseProto_Builder *)clearRewards;
@end


// @@protoc_insertion_point(global_scope)
