// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "BoosterPackStuff.pb.h"
#import "MonsterStuff.pb.h"
#import "User.pb.h"
// @@protoc_insertion_point(imports)

@class BoosterDisplayItemProto;
@class BoosterDisplayItemProto_Builder;
@class BoosterItemProto;
@class BoosterItemProto_Builder;
@class BoosterPackProto;
@class BoosterPackProto_Builder;
@class ClanMemberTeamDonationProto;
@class ClanMemberTeamDonationProto_Builder;
@class FullUserMonsterProto;
@class FullUserMonsterProto_Builder;
@class FullUserProto;
@class FullUserProto_Builder;
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
@class StaticUserLevelInfoProto;
@class StaticUserLevelInfoProto_Builder;
@class UserCurrentMonsterTeamProto;
@class UserCurrentMonsterTeamProto_Builder;
@class UserEnhancementItemProto;
@class UserEnhancementItemProto_Builder;
@class UserEnhancementProto;
@class UserEnhancementProto_Builder;
@class UserFacebookInviteForSlotProto;
@class UserFacebookInviteForSlotProto_Builder;
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
  PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatusFailInsufficientGems = 2,
  PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatusFailOther = 3,
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
  BOOL hasClientTime_:1;
  BOOL hasBoosterPackId_:1;
  BOOL hasSender_:1;
  BOOL dailyFreeBoosterPack_:1;
  int64_t clientTime;
  int32_t boosterPackId;
  MinimumUserProto* sender;
}
- (BOOL) hasSender;
- (BOOL) hasBoosterPackId;
- (BOOL) hasClientTime;
- (BOOL) hasDailyFreeBoosterPack;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) int32_t boosterPackId;
@property (readonly) int64_t clientTime;
- (BOOL) dailyFreeBoosterPack;

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
@end

@interface PurchaseBoosterPackResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasPrize_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  BoosterItemProto* prize;
  PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatus status;
  NSMutableArray * mutableUpdatedOrNewList;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
- (BOOL) hasPrize;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatus status;
@property (readonly, strong) NSArray * updatedOrNewList;
@property (readonly, strong) BoosterItemProto* prize;
- (FullUserMonsterProto*)updatedOrNewAtIndex:(NSUInteger)index;

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

- (NSMutableArray *)updatedOrNewList;
- (FullUserMonsterProto*)updatedOrNewAtIndex:(NSUInteger)index;
- (PurchaseBoosterPackResponseProto_Builder *)addUpdatedOrNew:(FullUserMonsterProto*)value;
- (PurchaseBoosterPackResponseProto_Builder *)addAllUpdatedOrNew:(NSArray *)array;
- (PurchaseBoosterPackResponseProto_Builder *)clearUpdatedOrNew;

- (BOOL) hasPrize;
- (BoosterItemProto*) prize;
- (PurchaseBoosterPackResponseProto_Builder*) setPrize:(BoosterItemProto*) value;
- (PurchaseBoosterPackResponseProto_Builder*) setPrize_Builder:(BoosterItemProto_Builder*) builderForValue;
- (PurchaseBoosterPackResponseProto_Builder*) mergePrize:(BoosterItemProto*) value;
- (PurchaseBoosterPackResponseProto_Builder*) clearPrize;
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
