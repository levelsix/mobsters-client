// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "BoosterPackStuff.pb.h"
#import "Reward.pb.h"
#import "User.pb.h"
// @@protoc_insertion_point(imports)

@class BoosterDisplayItemProto;
@class BoosterDisplayItemProto_Builder;
@class BoosterItemProto;
@class BoosterItemProto_Builder;
@class BoosterPackProto;
@class BoosterPackProto_Builder;
@class ClanGiftProto;
@class ClanGiftProto_Builder;
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
@class PurchaseBoosterPackRequestProto;
@class PurchaseBoosterPackRequestProto_Builder;
@class PurchaseBoosterPackResponseProto;
@class PurchaseBoosterPackResponseProto_Builder;
@class RareBoosterPurchaseProto;
@class RareBoosterPurchaseProto_Builder;
@class ReceivedRareBoosterPurchaseResponseProto;
@class ReceivedRareBoosterPurchaseResponseProto_Builder;
@class RewardProto;
@class RewardProto_Builder;
@class StaticUserLevelInfoProto;
@class StaticUserLevelInfoProto_Builder;
@class TangoGiftProto;
@class TangoGiftProto_Builder;
@class UserClanGiftProto;
@class UserClanGiftProto_Builder;
@class UserCurrentMonsterTeamProto;
@class UserCurrentMonsterTeamProto_Builder;
@class UserEnhancementItemProto;
@class UserEnhancementItemProto_Builder;
@class UserEnhancementProto;
@class UserEnhancementProto_Builder;
@class UserFacebookInviteForSlotProto;
@class UserFacebookInviteForSlotProto_Builder;
@class UserGiftProto;
@class UserGiftProto_Builder;
@class UserItemProto;
@class UserItemProto_Builder;
@class UserItemSecretGiftProto;
@class UserItemSecretGiftProto_Builder;
@class UserItemUsageProto;
@class UserItemUsageProto_Builder;
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
@class UserTangoGiftProto;
@class UserTangoGiftProto_Builder;
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

typedef NS_ENUM(SInt32, PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatus) {
  PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatusSuccess = 1,
  PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatusFailInsufficientGachaCredits = 2,
  PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatusFailOther = 3,
  PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatusFailInsufficientGems = 4,
};

BOOL PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatusIsValidValue(PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatus value);


@interface EventBoosterPackRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface PurchaseBoosterPackRequestProto : PBGeneratedMessage {
@private
  BOOL hasDailyFreeBoosterPack_:1;
  BOOL hasBuyingInBulk_:1;
  BOOL hasClientTime_:1;
  BOOL hasBoosterPackId_:1;
  BOOL hasGemsSpent_:1;
  BOOL hasGachaCreditsChange_:1;
  BOOL hasSender_:1;
  BOOL dailyFreeBoosterPack_:1;
  BOOL buyingInBulk_:1;
  int64_t clientTime;
  int32_t boosterPackId;
  int32_t gemsSpent;
  int32_t gachaCreditsChange;
  MinimumUserProto* sender;
}
- (BOOL) hasSender;
- (BOOL) hasBoosterPackId;
- (BOOL) hasClientTime;
- (BOOL) hasDailyFreeBoosterPack;
- (BOOL) hasBuyingInBulk;
- (BOOL) hasGemsSpent;
- (BOOL) hasGachaCreditsChange;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) int32_t boosterPackId;
@property (readonly) int64_t clientTime;
- (BOOL) dailyFreeBoosterPack;
- (BOOL) buyingInBulk;
@property (readonly) int32_t gemsSpent;
@property (readonly) int32_t gachaCreditsChange;

+ (PurchaseBoosterPackRequestProto*) defaultInstance;
- (PurchaseBoosterPackRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PurchaseBoosterPackRequestProto_Builder*) builder;
+ (PurchaseBoosterPackRequestProto_Builder*) builder;
+ (PurchaseBoosterPackRequestProto_Builder*) builderWithPrototype:(PurchaseBoosterPackRequestProto*) prototype;
- (PurchaseBoosterPackRequestProto_Builder*) toBuilder;

+ (PurchaseBoosterPackRequestProto*) parseFromData:(NSData*) data;
+ (PurchaseBoosterPackRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PurchaseBoosterPackRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (PurchaseBoosterPackRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PurchaseBoosterPackRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PurchaseBoosterPackRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PurchaseBoosterPackRequestProto_Builder : PBGeneratedMessageBuilder {
@private
  PurchaseBoosterPackRequestProto* result;
}

- (PurchaseBoosterPackRequestProto*) defaultInstance;

- (PurchaseBoosterPackRequestProto_Builder*) clear;
- (PurchaseBoosterPackRequestProto_Builder*) clone;

- (PurchaseBoosterPackRequestProto*) build;
- (PurchaseBoosterPackRequestProto*) buildPartial;

- (PurchaseBoosterPackRequestProto_Builder*) mergeFrom:(PurchaseBoosterPackRequestProto*) other;
- (PurchaseBoosterPackRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PurchaseBoosterPackRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (PurchaseBoosterPackRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (PurchaseBoosterPackRequestProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (PurchaseBoosterPackRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (PurchaseBoosterPackRequestProto_Builder*) clearSender;

- (BOOL) hasBoosterPackId;
- (int32_t) boosterPackId;
- (PurchaseBoosterPackRequestProto_Builder*) setBoosterPackId:(int32_t) value;
- (PurchaseBoosterPackRequestProto_Builder*) clearBoosterPackId;

- (BOOL) hasClientTime;
- (int64_t) clientTime;
- (PurchaseBoosterPackRequestProto_Builder*) setClientTime:(int64_t) value;
- (PurchaseBoosterPackRequestProto_Builder*) clearClientTime;

- (BOOL) hasDailyFreeBoosterPack;
- (BOOL) dailyFreeBoosterPack;
- (PurchaseBoosterPackRequestProto_Builder*) setDailyFreeBoosterPack:(BOOL) value;
- (PurchaseBoosterPackRequestProto_Builder*) clearDailyFreeBoosterPack;

- (BOOL) hasBuyingInBulk;
- (BOOL) buyingInBulk;
- (PurchaseBoosterPackRequestProto_Builder*) setBuyingInBulk:(BOOL) value;
- (PurchaseBoosterPackRequestProto_Builder*) clearBuyingInBulk;

- (BOOL) hasGemsSpent;
- (int32_t) gemsSpent;
- (PurchaseBoosterPackRequestProto_Builder*) setGemsSpent:(int32_t) value;
- (PurchaseBoosterPackRequestProto_Builder*) clearGemsSpent;

- (BOOL) hasGachaCreditsChange;
- (int32_t) gachaCreditsChange;
- (PurchaseBoosterPackRequestProto_Builder*) setGachaCreditsChange:(int32_t) value;
- (PurchaseBoosterPackRequestProto_Builder*) clearGachaCreditsChange;
@end

@interface PurchaseBoosterPackResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasReward_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  UserRewardProto* reward;
  PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatus status;
  NSMutableArray * mutablePrizeList;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
- (BOOL) hasReward;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatus status;
@property (readonly, strong) NSArray * prizeList;
@property (readonly, strong) UserRewardProto* reward;
- (BoosterItemProto*)prizeAtIndex:(NSUInteger)index;

+ (PurchaseBoosterPackResponseProto*) defaultInstance;
- (PurchaseBoosterPackResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PurchaseBoosterPackResponseProto_Builder*) builder;
+ (PurchaseBoosterPackResponseProto_Builder*) builder;
+ (PurchaseBoosterPackResponseProto_Builder*) builderWithPrototype:(PurchaseBoosterPackResponseProto*) prototype;
- (PurchaseBoosterPackResponseProto_Builder*) toBuilder;

+ (PurchaseBoosterPackResponseProto*) parseFromData:(NSData*) data;
+ (PurchaseBoosterPackResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PurchaseBoosterPackResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (PurchaseBoosterPackResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PurchaseBoosterPackResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PurchaseBoosterPackResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PurchaseBoosterPackResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  PurchaseBoosterPackResponseProto* result;
}

- (PurchaseBoosterPackResponseProto*) defaultInstance;

- (PurchaseBoosterPackResponseProto_Builder*) clear;
- (PurchaseBoosterPackResponseProto_Builder*) clone;

- (PurchaseBoosterPackResponseProto*) build;
- (PurchaseBoosterPackResponseProto*) buildPartial;

- (PurchaseBoosterPackResponseProto_Builder*) mergeFrom:(PurchaseBoosterPackResponseProto*) other;
- (PurchaseBoosterPackResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PurchaseBoosterPackResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (PurchaseBoosterPackResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (PurchaseBoosterPackResponseProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (PurchaseBoosterPackResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (PurchaseBoosterPackResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatus) status;
- (PurchaseBoosterPackResponseProto_Builder*) setStatus:(PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatus) value;
- (PurchaseBoosterPackResponseProto_Builder*) clearStatusList;

- (NSMutableArray *)prizeList;
- (BoosterItemProto*)prizeAtIndex:(NSUInteger)index;
- (PurchaseBoosterPackResponseProto_Builder *)addPrize:(BoosterItemProto*)value;
- (PurchaseBoosterPackResponseProto_Builder *)addAllPrize:(NSArray *)array;
- (PurchaseBoosterPackResponseProto_Builder *)clearPrize;

- (BOOL) hasReward;
- (UserRewardProto*) reward;
- (PurchaseBoosterPackResponseProto_Builder*) setReward:(UserRewardProto*) value;
- (PurchaseBoosterPackResponseProto_Builder*) setReward_Builder:(UserRewardProto_Builder*) builderForValue;
- (PurchaseBoosterPackResponseProto_Builder*) mergeReward:(UserRewardProto*) value;
- (PurchaseBoosterPackResponseProto_Builder*) clearReward;
@end

@interface ReceivedRareBoosterPurchaseResponseProto : PBGeneratedMessage {
@private
  BOOL hasRareBoosterPurchase_:1;
  RareBoosterPurchaseProto* rareBoosterPurchase;
}
- (BOOL) hasRareBoosterPurchase;
@property (readonly, strong) RareBoosterPurchaseProto* rareBoosterPurchase;

+ (ReceivedRareBoosterPurchaseResponseProto*) defaultInstance;
- (ReceivedRareBoosterPurchaseResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (ReceivedRareBoosterPurchaseResponseProto_Builder*) builder;
+ (ReceivedRareBoosterPurchaseResponseProto_Builder*) builder;
+ (ReceivedRareBoosterPurchaseResponseProto_Builder*) builderWithPrototype:(ReceivedRareBoosterPurchaseResponseProto*) prototype;
- (ReceivedRareBoosterPurchaseResponseProto_Builder*) toBuilder;

+ (ReceivedRareBoosterPurchaseResponseProto*) parseFromData:(NSData*) data;
+ (ReceivedRareBoosterPurchaseResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ReceivedRareBoosterPurchaseResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (ReceivedRareBoosterPurchaseResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ReceivedRareBoosterPurchaseResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (ReceivedRareBoosterPurchaseResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface ReceivedRareBoosterPurchaseResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  ReceivedRareBoosterPurchaseResponseProto* result;
}

- (ReceivedRareBoosterPurchaseResponseProto*) defaultInstance;

- (ReceivedRareBoosterPurchaseResponseProto_Builder*) clear;
- (ReceivedRareBoosterPurchaseResponseProto_Builder*) clone;

- (ReceivedRareBoosterPurchaseResponseProto*) build;
- (ReceivedRareBoosterPurchaseResponseProto*) buildPartial;

- (ReceivedRareBoosterPurchaseResponseProto_Builder*) mergeFrom:(ReceivedRareBoosterPurchaseResponseProto*) other;
- (ReceivedRareBoosterPurchaseResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (ReceivedRareBoosterPurchaseResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasRareBoosterPurchase;
- (RareBoosterPurchaseProto*) rareBoosterPurchase;
- (ReceivedRareBoosterPurchaseResponseProto_Builder*) setRareBoosterPurchase:(RareBoosterPurchaseProto*) value;
- (ReceivedRareBoosterPurchaseResponseProto_Builder*) setRareBoosterPurchase_Builder:(RareBoosterPurchaseProto_Builder*) builderForValue;
- (ReceivedRareBoosterPurchaseResponseProto_Builder*) mergeRareBoosterPurchase:(RareBoosterPurchaseProto*) value;
- (ReceivedRareBoosterPurchaseResponseProto_Builder*) clearRareBoosterPurchase;
@end


// @@protoc_insertion_point(global_scope)
