// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "Chat.pb.h"
#import "CustomMenu.pb.h"
#import "Reward.pb.h"
#import "SharedEnumConfig.pb.h"
#import "User.pb.h"
// @@protoc_insertion_point(imports)

@class ClanMemberTeamDonationProto;
@class ClanMemberTeamDonationProto_Builder;
@class ColorProto;
@class ColorProto_Builder;
@class CustomMenuProto;
@class CustomMenuProto_Builder;
@class DefaultLanguagesProto;
@class DefaultLanguagesProto_Builder;
@class FullUserMonsterProto;
@class FullUserMonsterProto_Builder;
@class FullUserProto;
@class FullUserProto_Builder;
@class GiftProto;
@class GiftProto_Builder;
@class GroupChatMessageProto;
@class GroupChatMessageProto_Builder;
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
@class PrivateChatDefaultLanguageProto;
@class PrivateChatDefaultLanguageProto_Builder;
@class PrivateChatPostProto;
@class PrivateChatPostProto_Builder;
@class RewardProto;
@class RewardProto_Builder;
@class SalesDisplayItemProto;
@class SalesDisplayItemProto_Builder;
@class SalesItemProto;
@class SalesItemProto_Builder;
@class SalesPackageProto;
@class SalesPackageProto_Builder;
@class StaticUserLevelInfoProto;
@class StaticUserLevelInfoProto_Builder;
@class TranslatedTextProto;
@class TranslatedTextProto_Builder;
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


@interface SalesRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface SalesPackageProto : PBGeneratedMessage {
@private
  BOOL hasPrice_:1;
  BOOL hasTimeStart_:1;
  BOOL hasTimeEnd_:1;
  BOOL hasSalesPackageId_:1;
  BOOL hasSuccId_:1;
  BOOL hasPriority_:1;
  BOOL hasSalesProductId_:1;
  BOOL hasUuid_:1;
  BOOL hasAnimatingIcon_:1;
  BOOL hasSlamIcon_:1;
  BOOL hasTitleColor_:1;
  int64_t price;
  int64_t timeStart;
  int64_t timeEnd;
  int32_t salesPackageId;
  int32_t succId;
  int32_t priority;
  NSString* salesProductId;
  NSString* uuid;
  NSString* animatingIcon;
  NSString* slamIcon;
  NSString* titleColor;
  NSMutableArray * mutableSipList;
  NSMutableArray * mutableSdipList;
  NSMutableArray * mutableCmpList;
}
- (BOOL) hasSalesPackageId;
- (BOOL) hasSalesProductId;
- (BOOL) hasPrice;
- (BOOL) hasUuid;
- (BOOL) hasSuccId;
- (BOOL) hasTimeStart;
- (BOOL) hasTimeEnd;
- (BOOL) hasAnimatingIcon;
- (BOOL) hasSlamIcon;
- (BOOL) hasTitleColor;
- (BOOL) hasPriority;
@property (readonly) int32_t salesPackageId;
@property (readonly, strong) NSString* salesProductId;
@property (readonly) int64_t price;
@property (readonly, strong) NSString* uuid;
@property (readonly, strong) NSArray * sipList;
@property (readonly, strong) NSArray * sdipList;
@property (readonly, strong) NSArray * cmpList;
@property (readonly) int32_t succId;
@property (readonly) int64_t timeStart;
@property (readonly) int64_t timeEnd;
@property (readonly, strong) NSString* animatingIcon;
@property (readonly, strong) NSString* slamIcon;
@property (readonly, strong) NSString* titleColor;
@property (readonly) int32_t priority;
- (SalesItemProto*)sipAtIndex:(NSUInteger)index;
- (SalesDisplayItemProto*)sdipAtIndex:(NSUInteger)index;
- (CustomMenuProto*)cmpAtIndex:(NSUInteger)index;

+ (SalesPackageProto*) defaultInstance;
- (SalesPackageProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (SalesPackageProto_Builder*) builder;
+ (SalesPackageProto_Builder*) builder;
+ (SalesPackageProto_Builder*) builderWithPrototype:(SalesPackageProto*) prototype;
- (SalesPackageProto_Builder*) toBuilder;

+ (SalesPackageProto*) parseFromData:(NSData*) data;
+ (SalesPackageProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SalesPackageProto*) parseFromInputStream:(NSInputStream*) input;
+ (SalesPackageProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SalesPackageProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (SalesPackageProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface SalesPackageProto_Builder : PBGeneratedMessageBuilder {
@private
  SalesPackageProto* result;
}

- (SalesPackageProto*) defaultInstance;

- (SalesPackageProto_Builder*) clear;
- (SalesPackageProto_Builder*) clone;

- (SalesPackageProto*) build;
- (SalesPackageProto*) buildPartial;

- (SalesPackageProto_Builder*) mergeFrom:(SalesPackageProto*) other;
- (SalesPackageProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (SalesPackageProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSalesPackageId;
- (int32_t) salesPackageId;
- (SalesPackageProto_Builder*) setSalesPackageId:(int32_t) value;
- (SalesPackageProto_Builder*) clearSalesPackageId;

- (BOOL) hasSalesProductId;
- (NSString*) salesProductId;
- (SalesPackageProto_Builder*) setSalesProductId:(NSString*) value;
- (SalesPackageProto_Builder*) clearSalesProductId;

- (BOOL) hasPrice;
- (int64_t) price;
- (SalesPackageProto_Builder*) setPrice:(int64_t) value;
- (SalesPackageProto_Builder*) clearPrice;

- (BOOL) hasUuid;
- (NSString*) uuid;
- (SalesPackageProto_Builder*) setUuid:(NSString*) value;
- (SalesPackageProto_Builder*) clearUuid;

- (NSMutableArray *)sipList;
- (SalesItemProto*)sipAtIndex:(NSUInteger)index;
- (SalesPackageProto_Builder *)addSip:(SalesItemProto*)value;
- (SalesPackageProto_Builder *)addAllSip:(NSArray *)array;
- (SalesPackageProto_Builder *)clearSip;

- (NSMutableArray *)sdipList;
- (SalesDisplayItemProto*)sdipAtIndex:(NSUInteger)index;
- (SalesPackageProto_Builder *)addSdip:(SalesDisplayItemProto*)value;
- (SalesPackageProto_Builder *)addAllSdip:(NSArray *)array;
- (SalesPackageProto_Builder *)clearSdip;

- (NSMutableArray *)cmpList;
- (CustomMenuProto*)cmpAtIndex:(NSUInteger)index;
- (SalesPackageProto_Builder *)addCmp:(CustomMenuProto*)value;
- (SalesPackageProto_Builder *)addAllCmp:(NSArray *)array;
- (SalesPackageProto_Builder *)clearCmp;

- (BOOL) hasSuccId;
- (int32_t) succId;
- (SalesPackageProto_Builder*) setSuccId:(int32_t) value;
- (SalesPackageProto_Builder*) clearSuccId;

- (BOOL) hasTimeStart;
- (int64_t) timeStart;
- (SalesPackageProto_Builder*) setTimeStart:(int64_t) value;
- (SalesPackageProto_Builder*) clearTimeStart;

- (BOOL) hasTimeEnd;
- (int64_t) timeEnd;
- (SalesPackageProto_Builder*) setTimeEnd:(int64_t) value;
- (SalesPackageProto_Builder*) clearTimeEnd;

- (BOOL) hasAnimatingIcon;
- (NSString*) animatingIcon;
- (SalesPackageProto_Builder*) setAnimatingIcon:(NSString*) value;
- (SalesPackageProto_Builder*) clearAnimatingIcon;

- (BOOL) hasSlamIcon;
- (NSString*) slamIcon;
- (SalesPackageProto_Builder*) setSlamIcon:(NSString*) value;
- (SalesPackageProto_Builder*) clearSlamIcon;

- (BOOL) hasTitleColor;
- (NSString*) titleColor;
- (SalesPackageProto_Builder*) setTitleColor:(NSString*) value;
- (SalesPackageProto_Builder*) clearTitleColor;

- (BOOL) hasPriority;
- (int32_t) priority;
- (SalesPackageProto_Builder*) setPriority:(int32_t) value;
- (SalesPackageProto_Builder*) clearPriority;
@end

@interface SalesItemProto : PBGeneratedMessage {
@private
  BOOL hasSalesItemId_:1;
  BOOL hasSalesPackageId_:1;
  BOOL hasReward_:1;
  int32_t salesItemId;
  int32_t salesPackageId;
  RewardProto* reward;
}
- (BOOL) hasSalesItemId;
- (BOOL) hasSalesPackageId;
- (BOOL) hasReward;
@property (readonly) int32_t salesItemId;
@property (readonly) int32_t salesPackageId;
@property (readonly, strong) RewardProto* reward;

+ (SalesItemProto*) defaultInstance;
- (SalesItemProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (SalesItemProto_Builder*) builder;
+ (SalesItemProto_Builder*) builder;
+ (SalesItemProto_Builder*) builderWithPrototype:(SalesItemProto*) prototype;
- (SalesItemProto_Builder*) toBuilder;

+ (SalesItemProto*) parseFromData:(NSData*) data;
+ (SalesItemProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SalesItemProto*) parseFromInputStream:(NSInputStream*) input;
+ (SalesItemProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SalesItemProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (SalesItemProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface SalesItemProto_Builder : PBGeneratedMessageBuilder {
@private
  SalesItemProto* result;
}

- (SalesItemProto*) defaultInstance;

- (SalesItemProto_Builder*) clear;
- (SalesItemProto_Builder*) clone;

- (SalesItemProto*) build;
- (SalesItemProto*) buildPartial;

- (SalesItemProto_Builder*) mergeFrom:(SalesItemProto*) other;
- (SalesItemProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (SalesItemProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSalesItemId;
- (int32_t) salesItemId;
- (SalesItemProto_Builder*) setSalesItemId:(int32_t) value;
- (SalesItemProto_Builder*) clearSalesItemId;

- (BOOL) hasSalesPackageId;
- (int32_t) salesPackageId;
- (SalesItemProto_Builder*) setSalesPackageId:(int32_t) value;
- (SalesItemProto_Builder*) clearSalesPackageId;

- (BOOL) hasReward;
- (RewardProto*) reward;
- (SalesItemProto_Builder*) setReward:(RewardProto*) value;
- (SalesItemProto_Builder*) setReward_Builder:(RewardProto_Builder*) builderForValue;
- (SalesItemProto_Builder*) mergeReward:(RewardProto*) value;
- (SalesItemProto_Builder*) clearReward;
@end

@interface SalesDisplayItemProto : PBGeneratedMessage {
@private
  BOOL hasSalesItemId_:1;
  BOOL hasSalesPackageId_:1;
  BOOL hasReward_:1;
  int32_t salesItemId;
  int32_t salesPackageId;
  RewardProto* reward;
}
- (BOOL) hasSalesItemId;
- (BOOL) hasSalesPackageId;
- (BOOL) hasReward;
@property (readonly) int32_t salesItemId;
@property (readonly) int32_t salesPackageId;
@property (readonly, strong) RewardProto* reward;

+ (SalesDisplayItemProto*) defaultInstance;
- (SalesDisplayItemProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (SalesDisplayItemProto_Builder*) builder;
+ (SalesDisplayItemProto_Builder*) builder;
+ (SalesDisplayItemProto_Builder*) builderWithPrototype:(SalesDisplayItemProto*) prototype;
- (SalesDisplayItemProto_Builder*) toBuilder;

+ (SalesDisplayItemProto*) parseFromData:(NSData*) data;
+ (SalesDisplayItemProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SalesDisplayItemProto*) parseFromInputStream:(NSInputStream*) input;
+ (SalesDisplayItemProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SalesDisplayItemProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (SalesDisplayItemProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface SalesDisplayItemProto_Builder : PBGeneratedMessageBuilder {
@private
  SalesDisplayItemProto* result;
}

- (SalesDisplayItemProto*) defaultInstance;

- (SalesDisplayItemProto_Builder*) clear;
- (SalesDisplayItemProto_Builder*) clone;

- (SalesDisplayItemProto*) build;
- (SalesDisplayItemProto*) buildPartial;

- (SalesDisplayItemProto_Builder*) mergeFrom:(SalesDisplayItemProto*) other;
- (SalesDisplayItemProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (SalesDisplayItemProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSalesItemId;
- (int32_t) salesItemId;
- (SalesDisplayItemProto_Builder*) setSalesItemId:(int32_t) value;
- (SalesDisplayItemProto_Builder*) clearSalesItemId;

- (BOOL) hasSalesPackageId;
- (int32_t) salesPackageId;
- (SalesDisplayItemProto_Builder*) setSalesPackageId:(int32_t) value;
- (SalesDisplayItemProto_Builder*) clearSalesPackageId;

- (BOOL) hasReward;
- (RewardProto*) reward;
- (SalesDisplayItemProto_Builder*) setReward:(RewardProto*) value;
- (SalesDisplayItemProto_Builder*) setReward_Builder:(RewardProto_Builder*) builderForValue;
- (SalesDisplayItemProto_Builder*) mergeReward:(RewardProto*) value;
- (SalesDisplayItemProto_Builder*) clearReward;
@end


// @@protoc_insertion_point(global_scope)
