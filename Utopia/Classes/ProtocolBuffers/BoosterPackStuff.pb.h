// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "Reward.pb.h"
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
@class GiftProto;
@class GiftProto_Builder;
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
@class MinimumUserProtoWithMaxResources;
@class MinimumUserProtoWithMaxResources_Builder;
@class MinimumUserProto_Builder;
@class MonsterBattleDialogueProto;
@class MonsterBattleDialogueProto_Builder;
@class MonsterLevelInfoProto;
@class MonsterLevelInfoProto_Builder;
@class MonsterProto;
@class MonsterProto_Builder;
@class RareBoosterPurchaseProto;
@class RareBoosterPurchaseProto_Builder;
@class RewardProto;
@class RewardProto_Builder;
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
@class UserGiftProto;
@class UserGiftProto_Builder;
@class UserItemProto;
@class UserItemProto_Builder;
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
@class UserSecretGiftProto;
@class UserSecretGiftProto_Builder;
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

typedef NS_ENUM(SInt32, BoosterPackProto_BoosterPackType) {
  BoosterPackProto_BoosterPackTypeNoType = 1,
  BoosterPackProto_BoosterPackTypeBasic = 2,
  BoosterPackProto_BoosterPackTypeUltimate = 3,
  BoosterPackProto_BoosterPackTypeStarter = 4,
  BoosterPackProto_BoosterPackTypeRigged = 5,
};

BOOL BoosterPackProto_BoosterPackTypeIsValidValue(BoosterPackProto_BoosterPackType value);


@interface BoosterPackStuffRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface RareBoosterPurchaseProto : PBGeneratedMessage {
@private
  BOOL hasTimeOfPurchase_:1;
  BOOL hasMonsterId_:1;
  BOOL hasUser_:1;
  BOOL hasBooster_:1;
  uint64_t timeOfPurchase;
  int32_t monsterId;
  MinimumUserProto* user;
  BoosterPackProto* booster;
}
- (BOOL) hasUser;
- (BOOL) hasBooster;
- (BOOL) hasTimeOfPurchase;
- (BOOL) hasMonsterId;
@property (readonly, strong) MinimumUserProto* user;
@property (readonly, strong) BoosterPackProto* booster;
@property (readonly) uint64_t timeOfPurchase;
@property (readonly) int32_t monsterId;

+ (RareBoosterPurchaseProto*) defaultInstance;
- (RareBoosterPurchaseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (RareBoosterPurchaseProto_Builder*) builder;
+ (RareBoosterPurchaseProto_Builder*) builder;
+ (RareBoosterPurchaseProto_Builder*) builderWithPrototype:(RareBoosterPurchaseProto*) prototype;
- (RareBoosterPurchaseProto_Builder*) toBuilder;

+ (RareBoosterPurchaseProto*) parseFromData:(NSData*) data;
+ (RareBoosterPurchaseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RareBoosterPurchaseProto*) parseFromInputStream:(NSInputStream*) input;
+ (RareBoosterPurchaseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RareBoosterPurchaseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (RareBoosterPurchaseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface RareBoosterPurchaseProto_Builder : PBGeneratedMessageBuilder {
@private
  RareBoosterPurchaseProto* result;
}

- (RareBoosterPurchaseProto*) defaultInstance;

- (RareBoosterPurchaseProto_Builder*) clear;
- (RareBoosterPurchaseProto_Builder*) clone;

- (RareBoosterPurchaseProto*) build;
- (RareBoosterPurchaseProto*) buildPartial;

- (RareBoosterPurchaseProto_Builder*) mergeFrom:(RareBoosterPurchaseProto*) other;
- (RareBoosterPurchaseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (RareBoosterPurchaseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasUser;
- (MinimumUserProto*) user;
- (RareBoosterPurchaseProto_Builder*) setUser:(MinimumUserProto*) value;
- (RareBoosterPurchaseProto_Builder*) setUser_Builder:(MinimumUserProto_Builder*) builderForValue;
- (RareBoosterPurchaseProto_Builder*) mergeUser:(MinimumUserProto*) value;
- (RareBoosterPurchaseProto_Builder*) clearUser;

- (BOOL) hasBooster;
- (BoosterPackProto*) booster;
- (RareBoosterPurchaseProto_Builder*) setBooster:(BoosterPackProto*) value;
- (RareBoosterPurchaseProto_Builder*) setBooster_Builder:(BoosterPackProto_Builder*) builderForValue;
- (RareBoosterPurchaseProto_Builder*) mergeBooster:(BoosterPackProto*) value;
- (RareBoosterPurchaseProto_Builder*) clearBooster;

- (BOOL) hasTimeOfPurchase;
- (uint64_t) timeOfPurchase;
- (RareBoosterPurchaseProto_Builder*) setTimeOfPurchase:(uint64_t) value;
- (RareBoosterPurchaseProto_Builder*) clearTimeOfPurchase;

- (BOOL) hasMonsterId;
- (int32_t) monsterId;
- (RareBoosterPurchaseProto_Builder*) setMonsterId:(int32_t) value;
- (RareBoosterPurchaseProto_Builder*) clearMonsterId;
@end

@interface BoosterPackProto : PBGeneratedMessage {
@private
  BOOL hasBoosterPackId_:1;
  BOOL hasGemPrice_:1;
  BOOL hasGachaCreditsPrice_:1;
  BOOL hasBoosterPackName_:1;
  BOOL hasListBackgroundImgName_:1;
  BOOL hasListDescription_:1;
  BOOL hasNavBarImgName_:1;
  BOOL hasNavTitleImgName_:1;
  BOOL hasMachineImgName_:1;
  BOOL hasType_:1;
  int32_t boosterPackId;
  int32_t gemPrice;
  int32_t gachaCreditsPrice;
  NSString* boosterPackName;
  NSString* listBackgroundImgName;
  NSString* listDescription;
  NSString* navBarImgName;
  NSString* navTitleImgName;
  NSString* machineImgName;
  BoosterPackProto_BoosterPackType type;
  NSMutableArray * mutableSpecialItemsList;
  NSMutableArray * mutableDisplayItemsList;
}
- (BOOL) hasBoosterPackId;
- (BOOL) hasBoosterPackName;
- (BOOL) hasGemPrice;
- (BOOL) hasGachaCreditsPrice;
- (BOOL) hasListBackgroundImgName;
- (BOOL) hasListDescription;
- (BOOL) hasNavBarImgName;
- (BOOL) hasNavTitleImgName;
- (BOOL) hasMachineImgName;
- (BOOL) hasType;
@property (readonly) int32_t boosterPackId;
@property (readonly, strong) NSString* boosterPackName;
@property (readonly) int32_t gemPrice;
@property (readonly) int32_t gachaCreditsPrice;
@property (readonly, strong) NSArray * specialItemsList;
@property (readonly, strong) NSString* listBackgroundImgName;
@property (readonly, strong) NSString* listDescription;
@property (readonly, strong) NSString* navBarImgName;
@property (readonly, strong) NSString* navTitleImgName;
@property (readonly, strong) NSString* machineImgName;
@property (readonly, strong) NSArray * displayItemsList;
@property (readonly) BoosterPackProto_BoosterPackType type;
- (BoosterItemProto*)specialItemsAtIndex:(NSUInteger)index;
- (BoosterDisplayItemProto*)displayItemsAtIndex:(NSUInteger)index;

+ (BoosterPackProto*) defaultInstance;
- (BoosterPackProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (BoosterPackProto_Builder*) builder;
+ (BoosterPackProto_Builder*) builder;
+ (BoosterPackProto_Builder*) builderWithPrototype:(BoosterPackProto*) prototype;
- (BoosterPackProto_Builder*) toBuilder;

+ (BoosterPackProto*) parseFromData:(NSData*) data;
+ (BoosterPackProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BoosterPackProto*) parseFromInputStream:(NSInputStream*) input;
+ (BoosterPackProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BoosterPackProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (BoosterPackProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface BoosterPackProto_Builder : PBGeneratedMessageBuilder {
@private
  BoosterPackProto* result;
}

- (BoosterPackProto*) defaultInstance;

- (BoosterPackProto_Builder*) clear;
- (BoosterPackProto_Builder*) clone;

- (BoosterPackProto*) build;
- (BoosterPackProto*) buildPartial;

- (BoosterPackProto_Builder*) mergeFrom:(BoosterPackProto*) other;
- (BoosterPackProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (BoosterPackProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasBoosterPackId;
- (int32_t) boosterPackId;
- (BoosterPackProto_Builder*) setBoosterPackId:(int32_t) value;
- (BoosterPackProto_Builder*) clearBoosterPackId;

- (BOOL) hasBoosterPackName;
- (NSString*) boosterPackName;
- (BoosterPackProto_Builder*) setBoosterPackName:(NSString*) value;
- (BoosterPackProto_Builder*) clearBoosterPackName;

- (BOOL) hasGemPrice;
- (int32_t) gemPrice;
- (BoosterPackProto_Builder*) setGemPrice:(int32_t) value;
- (BoosterPackProto_Builder*) clearGemPrice;

- (BOOL) hasGachaCreditsPrice;
- (int32_t) gachaCreditsPrice;
- (BoosterPackProto_Builder*) setGachaCreditsPrice:(int32_t) value;
- (BoosterPackProto_Builder*) clearGachaCreditsPrice;

- (NSMutableArray *)specialItemsList;
- (BoosterItemProto*)specialItemsAtIndex:(NSUInteger)index;
- (BoosterPackProto_Builder *)addSpecialItems:(BoosterItemProto*)value;
- (BoosterPackProto_Builder *)addAllSpecialItems:(NSArray *)array;
- (BoosterPackProto_Builder *)clearSpecialItems;

- (BOOL) hasListBackgroundImgName;
- (NSString*) listBackgroundImgName;
- (BoosterPackProto_Builder*) setListBackgroundImgName:(NSString*) value;
- (BoosterPackProto_Builder*) clearListBackgroundImgName;

- (BOOL) hasListDescription;
- (NSString*) listDescription;
- (BoosterPackProto_Builder*) setListDescription:(NSString*) value;
- (BoosterPackProto_Builder*) clearListDescription;

- (BOOL) hasNavBarImgName;
- (NSString*) navBarImgName;
- (BoosterPackProto_Builder*) setNavBarImgName:(NSString*) value;
- (BoosterPackProto_Builder*) clearNavBarImgName;

- (BOOL) hasNavTitleImgName;
- (NSString*) navTitleImgName;
- (BoosterPackProto_Builder*) setNavTitleImgName:(NSString*) value;
- (BoosterPackProto_Builder*) clearNavTitleImgName;

- (BOOL) hasMachineImgName;
- (NSString*) machineImgName;
- (BoosterPackProto_Builder*) setMachineImgName:(NSString*) value;
- (BoosterPackProto_Builder*) clearMachineImgName;

- (NSMutableArray *)displayItemsList;
- (BoosterDisplayItemProto*)displayItemsAtIndex:(NSUInteger)index;
- (BoosterPackProto_Builder *)addDisplayItems:(BoosterDisplayItemProto*)value;
- (BoosterPackProto_Builder *)addAllDisplayItems:(NSArray *)array;
- (BoosterPackProto_Builder *)clearDisplayItems;

- (BOOL) hasType;
- (BoosterPackProto_BoosterPackType) type;
- (BoosterPackProto_Builder*) setType:(BoosterPackProto_BoosterPackType) value;
- (BoosterPackProto_Builder*) clearTypeList;
@end

@interface BoosterItemProto : PBGeneratedMessage {
@private
  BOOL hasIsSpecial_:1;
  BOOL hasChanceToAppear_:1;
  BOOL hasBoosterItemId_:1;
  BOOL hasBoosterPackId_:1;
  BOOL hasReward_:1;
  BOOL isSpecial_:1;
  Float32 chanceToAppear;
  int32_t boosterItemId;
  int32_t boosterPackId;
  RewardProto* reward;
}
- (BOOL) hasBoosterItemId;
- (BOOL) hasBoosterPackId;
- (BOOL) hasIsSpecial;
- (BOOL) hasChanceToAppear;
- (BOOL) hasReward;
@property (readonly) int32_t boosterItemId;
@property (readonly) int32_t boosterPackId;
- (BOOL) isSpecial;
@property (readonly) Float32 chanceToAppear;
@property (readonly, strong) RewardProto* reward;

+ (BoosterItemProto*) defaultInstance;
- (BoosterItemProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (BoosterItemProto_Builder*) builder;
+ (BoosterItemProto_Builder*) builder;
+ (BoosterItemProto_Builder*) builderWithPrototype:(BoosterItemProto*) prototype;
- (BoosterItemProto_Builder*) toBuilder;

+ (BoosterItemProto*) parseFromData:(NSData*) data;
+ (BoosterItemProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BoosterItemProto*) parseFromInputStream:(NSInputStream*) input;
+ (BoosterItemProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BoosterItemProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (BoosterItemProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface BoosterItemProto_Builder : PBGeneratedMessageBuilder {
@private
  BoosterItemProto* result;
}

- (BoosterItemProto*) defaultInstance;

- (BoosterItemProto_Builder*) clear;
- (BoosterItemProto_Builder*) clone;

- (BoosterItemProto*) build;
- (BoosterItemProto*) buildPartial;

- (BoosterItemProto_Builder*) mergeFrom:(BoosterItemProto*) other;
- (BoosterItemProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (BoosterItemProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasBoosterItemId;
- (int32_t) boosterItemId;
- (BoosterItemProto_Builder*) setBoosterItemId:(int32_t) value;
- (BoosterItemProto_Builder*) clearBoosterItemId;

- (BOOL) hasBoosterPackId;
- (int32_t) boosterPackId;
- (BoosterItemProto_Builder*) setBoosterPackId:(int32_t) value;
- (BoosterItemProto_Builder*) clearBoosterPackId;

- (BOOL) hasIsSpecial;
- (BOOL) isSpecial;
- (BoosterItemProto_Builder*) setIsSpecial:(BOOL) value;
- (BoosterItemProto_Builder*) clearIsSpecial;

- (BOOL) hasChanceToAppear;
- (Float32) chanceToAppear;
- (BoosterItemProto_Builder*) setChanceToAppear:(Float32) value;
- (BoosterItemProto_Builder*) clearChanceToAppear;

- (BOOL) hasReward;
- (RewardProto*) reward;
- (BoosterItemProto_Builder*) setReward:(RewardProto*) value;
- (BoosterItemProto_Builder*) setReward_Builder:(RewardProto_Builder*) builderForValue;
- (BoosterItemProto_Builder*) mergeReward:(RewardProto*) value;
- (BoosterItemProto_Builder*) clearReward;
@end

@interface BoosterDisplayItemProto : PBGeneratedMessage {
@private
  BOOL hasBoosterPackId_:1;
  BOOL hasReward_:1;
  int32_t boosterPackId;
  RewardProto* reward;
}
- (BOOL) hasBoosterPackId;
- (BOOL) hasReward;
@property (readonly) int32_t boosterPackId;
@property (readonly, strong) RewardProto* reward;

+ (BoosterDisplayItemProto*) defaultInstance;
- (BoosterDisplayItemProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (BoosterDisplayItemProto_Builder*) builder;
+ (BoosterDisplayItemProto_Builder*) builder;
+ (BoosterDisplayItemProto_Builder*) builderWithPrototype:(BoosterDisplayItemProto*) prototype;
- (BoosterDisplayItemProto_Builder*) toBuilder;

+ (BoosterDisplayItemProto*) parseFromData:(NSData*) data;
+ (BoosterDisplayItemProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BoosterDisplayItemProto*) parseFromInputStream:(NSInputStream*) input;
+ (BoosterDisplayItemProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BoosterDisplayItemProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (BoosterDisplayItemProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface BoosterDisplayItemProto_Builder : PBGeneratedMessageBuilder {
@private
  BoosterDisplayItemProto* result;
}

- (BoosterDisplayItemProto*) defaultInstance;

- (BoosterDisplayItemProto_Builder*) clear;
- (BoosterDisplayItemProto_Builder*) clone;

- (BoosterDisplayItemProto*) build;
- (BoosterDisplayItemProto*) buildPartial;

- (BoosterDisplayItemProto_Builder*) mergeFrom:(BoosterDisplayItemProto*) other;
- (BoosterDisplayItemProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (BoosterDisplayItemProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasBoosterPackId;
- (int32_t) boosterPackId;
- (BoosterDisplayItemProto_Builder*) setBoosterPackId:(int32_t) value;
- (BoosterDisplayItemProto_Builder*) clearBoosterPackId;

- (BOOL) hasReward;
- (RewardProto*) reward;
- (BoosterDisplayItemProto_Builder*) setReward:(RewardProto*) value;
- (BoosterDisplayItemProto_Builder*) setReward_Builder:(RewardProto_Builder*) builderForValue;
- (BoosterDisplayItemProto_Builder*) mergeReward:(RewardProto*) value;
- (BoosterDisplayItemProto_Builder*) clearReward;
@end


// @@protoc_insertion_point(global_scope)
