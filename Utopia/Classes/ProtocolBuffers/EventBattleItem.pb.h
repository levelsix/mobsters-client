// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "BattleItem.pb.h"
#import "User.pb.h"
// @@protoc_insertion_point(imports)

@class BattleItemFactoryProto;
@class BattleItemFactoryProto_Builder;
@class BattleItemProto;
@class BattleItemProto_Builder;
@class BattleItemQueueForUserProto;
@class BattleItemQueueForUserProto_Builder;
@class ClanHouseProto;
@class ClanHouseProto_Builder;
@class CompleteBattleItemRequestProto;
@class CompleteBattleItemRequestProto_Builder;
@class CompleteBattleItemResponseProto;
@class CompleteBattleItemResponseProto_Builder;
@class CoordinateProto;
@class CoordinateProto_Builder;
@class CreateBattleItemRequestProto;
@class CreateBattleItemRequestProto_Builder;
@class CreateBattleItemResponseProto;
@class CreateBattleItemResponseProto_Builder;
@class DiscardBattleItemRequestProto;
@class DiscardBattleItemRequestProto_Builder;
@class DiscardBattleItemResponseProto;
@class DiscardBattleItemResponseProto_Builder;
@class EvoChamberProto;
@class EvoChamberProto_Builder;
@class FullUserProto;
@class FullUserProto_Builder;
@class FullUserStructureProto;
@class FullUserStructureProto_Builder;
@class HospitalProto;
@class HospitalProto_Builder;
@class ItemGemPriceProto;
@class ItemGemPriceProto_Builder;
@class ItemProto;
@class ItemProto_Builder;
@class LabProto;
@class LabProto_Builder;
@class MiniJobCenterProto;
@class MiniJobCenterProto_Builder;
@class MinimumClanProto;
@class MinimumClanProto_Builder;
@class MinimumObstacleProto;
@class MinimumObstacleProto_Builder;
@class MinimumUserProto;
@class MinimumUserProtoWithFacebookId;
@class MinimumUserProtoWithFacebookId_Builder;
@class MinimumUserProtoWithMaxResources;
@class MinimumUserProtoWithMaxResources_Builder;
@class MinimumUserProto_Builder;
@class MoneyTreeProto;
@class MoneyTreeProto_Builder;
@class ObstacleProto;
@class ObstacleProto_Builder;
@class PvpBoardHouseProto;
@class PvpBoardHouseProto_Builder;
@class PvpBoardObstacleProto;
@class PvpBoardObstacleProto_Builder;
@class ResearchHouseProto;
@class ResearchHouseProto_Builder;
@class ResidenceProto;
@class ResidenceProto_Builder;
@class ResourceGeneratorProto;
@class ResourceGeneratorProto_Builder;
@class ResourceStorageProto;
@class ResourceStorageProto_Builder;
@class StaticUserLevelInfoProto;
@class StaticUserLevelInfoProto_Builder;
@class StructureInfoProto;
@class StructureInfoProto_Builder;
@class TeamCenterProto;
@class TeamCenterProto_Builder;
@class TownHallProto;
@class TownHallProto_Builder;
@class TutorialStructProto;
@class TutorialStructProto_Builder;
@class UserBattleItemProto;
@class UserBattleItemProto_Builder;
@class UserFacebookInviteForSlotProto;
@class UserFacebookInviteForSlotProto_Builder;
@class UserItemProto;
@class UserItemProto_Builder;
@class UserItemUsageProto;
@class UserItemUsageProto_Builder;
@class UserObstacleProto;
@class UserObstacleProto_Builder;
@class UserPvpBoardObstacleProto;
@class UserPvpBoardObstacleProto_Builder;
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

typedef NS_ENUM(SInt32, CreateBattleItemResponseProto_CreateBattleItemStatus) {
  CreateBattleItemResponseProto_CreateBattleItemStatusSuccess = 1,
  CreateBattleItemResponseProto_CreateBattleItemStatusFailOther = 2,
  CreateBattleItemResponseProto_CreateBattleItemStatusFailInsufficientFunds = 3,
};

BOOL CreateBattleItemResponseProto_CreateBattleItemStatusIsValidValue(CreateBattleItemResponseProto_CreateBattleItemStatus value);

typedef NS_ENUM(SInt32, CompleteBattleItemResponseProto_CompleteBattleItemStatus) {
  CompleteBattleItemResponseProto_CompleteBattleItemStatusSuccess = 1,
  CompleteBattleItemResponseProto_CompleteBattleItemStatusFailOther = 2,
  CompleteBattleItemResponseProto_CompleteBattleItemStatusFailInvalidBattleItems = 3,
  CompleteBattleItemResponseProto_CompleteBattleItemStatusFailInsufficientFunds = 4,
};

BOOL CompleteBattleItemResponseProto_CompleteBattleItemStatusIsValidValue(CompleteBattleItemResponseProto_CompleteBattleItemStatus value);

typedef NS_ENUM(SInt32, DiscardBattleItemResponseProto_DiscardBattleItemStatus) {
  DiscardBattleItemResponseProto_DiscardBattleItemStatusSuccess = 1,
  DiscardBattleItemResponseProto_DiscardBattleItemStatusFailOther = 2,
  DiscardBattleItemResponseProto_DiscardBattleItemStatusFailBattleItemsDontExist = 3,
};

BOOL DiscardBattleItemResponseProto_DiscardBattleItemStatusIsValidValue(DiscardBattleItemResponseProto_DiscardBattleItemStatus value);


@interface EventBattleItemRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface CreateBattleItemRequestProto : PBGeneratedMessage {
@private
  BOOL hasGemCostForCreating_:1;
  BOOL hasSender_:1;
  BOOL hasCashChange_:1;
  BOOL hasOilChange_:1;
  int32_t gemCostForCreating;
  MinimumUserProtoWithMaxResources* sender;
  int32_t cashChange;
  int32_t oilChange;
  NSMutableArray * mutableBiqfuDeleteList;
  NSMutableArray * mutableBiqfuUpdateList;
  NSMutableArray * mutableBiqfuNewList;
}
- (BOOL) hasSender;
- (BOOL) hasCashChange;
- (BOOL) hasOilChange;
- (BOOL) hasGemCostForCreating;
@property (readonly, strong) MinimumUserProtoWithMaxResources* sender;
@property (readonly, strong) NSArray * biqfuDeleteList;
@property (readonly, strong) NSArray * biqfuUpdateList;
@property (readonly, strong) NSArray * biqfuNewList;
@property (readonly) int32_t cashChange;
@property (readonly) int32_t oilChange;
@property (readonly) int32_t gemCostForCreating;
- (BattleItemQueueForUserProto*)biqfuDeleteAtIndex:(NSUInteger)index;
- (BattleItemQueueForUserProto*)biqfuUpdateAtIndex:(NSUInteger)index;
- (BattleItemQueueForUserProto*)biqfuNewAtIndex:(NSUInteger)index;

+ (CreateBattleItemRequestProto*) defaultInstance;
- (CreateBattleItemRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (CreateBattleItemRequestProto_Builder*) builder;
+ (CreateBattleItemRequestProto_Builder*) builder;
+ (CreateBattleItemRequestProto_Builder*) builderWithPrototype:(CreateBattleItemRequestProto*) prototype;
- (CreateBattleItemRequestProto_Builder*) toBuilder;

+ (CreateBattleItemRequestProto*) parseFromData:(NSData*) data;
+ (CreateBattleItemRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CreateBattleItemRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (CreateBattleItemRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CreateBattleItemRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (CreateBattleItemRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface CreateBattleItemRequestProto_Builder : PBGeneratedMessageBuilder {
@private
  CreateBattleItemRequestProto* result;
}

- (CreateBattleItemRequestProto*) defaultInstance;

- (CreateBattleItemRequestProto_Builder*) clear;
- (CreateBattleItemRequestProto_Builder*) clone;

- (CreateBattleItemRequestProto*) build;
- (CreateBattleItemRequestProto*) buildPartial;

- (CreateBattleItemRequestProto_Builder*) mergeFrom:(CreateBattleItemRequestProto*) other;
- (CreateBattleItemRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (CreateBattleItemRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProtoWithMaxResources*) sender;
- (CreateBattleItemRequestProto_Builder*) setSender:(MinimumUserProtoWithMaxResources*) value;
- (CreateBattleItemRequestProto_Builder*) setSender_Builder:(MinimumUserProtoWithMaxResources_Builder*) builderForValue;
- (CreateBattleItemRequestProto_Builder*) mergeSender:(MinimumUserProtoWithMaxResources*) value;
- (CreateBattleItemRequestProto_Builder*) clearSender;

- (NSMutableArray *)biqfuDeleteList;
- (BattleItemQueueForUserProto*)biqfuDeleteAtIndex:(NSUInteger)index;
- (CreateBattleItemRequestProto_Builder *)addBiqfuDelete:(BattleItemQueueForUserProto*)value;
- (CreateBattleItemRequestProto_Builder *)addAllBiqfuDelete:(NSArray *)array;
- (CreateBattleItemRequestProto_Builder *)clearBiqfuDelete;

- (NSMutableArray *)biqfuUpdateList;
- (BattleItemQueueForUserProto*)biqfuUpdateAtIndex:(NSUInteger)index;
- (CreateBattleItemRequestProto_Builder *)addBiqfuUpdate:(BattleItemQueueForUserProto*)value;
- (CreateBattleItemRequestProto_Builder *)addAllBiqfuUpdate:(NSArray *)array;
- (CreateBattleItemRequestProto_Builder *)clearBiqfuUpdate;

- (NSMutableArray *)biqfuNewList;
- (BattleItemQueueForUserProto*)biqfuNewAtIndex:(NSUInteger)index;
- (CreateBattleItemRequestProto_Builder *)addBiqfuNew:(BattleItemQueueForUserProto*)value;
- (CreateBattleItemRequestProto_Builder *)addAllBiqfuNew:(NSArray *)array;
- (CreateBattleItemRequestProto_Builder *)clearBiqfuNew;

- (BOOL) hasCashChange;
- (int32_t) cashChange;
- (CreateBattleItemRequestProto_Builder*) setCashChange:(int32_t) value;
- (CreateBattleItemRequestProto_Builder*) clearCashChange;

- (BOOL) hasOilChange;
- (int32_t) oilChange;
- (CreateBattleItemRequestProto_Builder*) setOilChange:(int32_t) value;
- (CreateBattleItemRequestProto_Builder*) clearOilChange;

- (BOOL) hasGemCostForCreating;
- (int32_t) gemCostForCreating;
- (CreateBattleItemRequestProto_Builder*) setGemCostForCreating:(int32_t) value;
- (CreateBattleItemRequestProto_Builder*) clearGemCostForCreating;
@end

@interface CreateBattleItemResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  CreateBattleItemResponseProto_CreateBattleItemStatus status;
  NSMutableArray * mutableUserBattleItemsList;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly, strong) NSArray * userBattleItemsList;
@property (readonly) CreateBattleItemResponseProto_CreateBattleItemStatus status;
- (UserBattleItemProto*)userBattleItemsAtIndex:(NSUInteger)index;

+ (CreateBattleItemResponseProto*) defaultInstance;
- (CreateBattleItemResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (CreateBattleItemResponseProto_Builder*) builder;
+ (CreateBattleItemResponseProto_Builder*) builder;
+ (CreateBattleItemResponseProto_Builder*) builderWithPrototype:(CreateBattleItemResponseProto*) prototype;
- (CreateBattleItemResponseProto_Builder*) toBuilder;

+ (CreateBattleItemResponseProto*) parseFromData:(NSData*) data;
+ (CreateBattleItemResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CreateBattleItemResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (CreateBattleItemResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CreateBattleItemResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (CreateBattleItemResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface CreateBattleItemResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  CreateBattleItemResponseProto* result;
}

- (CreateBattleItemResponseProto*) defaultInstance;

- (CreateBattleItemResponseProto_Builder*) clear;
- (CreateBattleItemResponseProto_Builder*) clone;

- (CreateBattleItemResponseProto*) build;
- (CreateBattleItemResponseProto*) buildPartial;

- (CreateBattleItemResponseProto_Builder*) mergeFrom:(CreateBattleItemResponseProto*) other;
- (CreateBattleItemResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (CreateBattleItemResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (CreateBattleItemResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (CreateBattleItemResponseProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (CreateBattleItemResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (CreateBattleItemResponseProto_Builder*) clearSender;

- (NSMutableArray *)userBattleItemsList;
- (UserBattleItemProto*)userBattleItemsAtIndex:(NSUInteger)index;
- (CreateBattleItemResponseProto_Builder *)addUserBattleItems:(UserBattleItemProto*)value;
- (CreateBattleItemResponseProto_Builder *)addAllUserBattleItems:(NSArray *)array;
- (CreateBattleItemResponseProto_Builder *)clearUserBattleItems;

- (BOOL) hasStatus;
- (CreateBattleItemResponseProto_CreateBattleItemStatus) status;
- (CreateBattleItemResponseProto_Builder*) setStatus:(CreateBattleItemResponseProto_CreateBattleItemStatus) value;
- (CreateBattleItemResponseProto_Builder*) clearStatusList;
@end

@interface CompleteBattleItemRequestProto : PBGeneratedMessage {
@private
  BOOL hasIsSpeedup_:1;
  BOOL hasGemsForSpeedup_:1;
  BOOL hasSender_:1;
  BOOL isSpeedup_:1;
  int32_t gemsForSpeedup;
  MinimumUserProto* sender;
  NSMutableArray * mutableBiqfuCompletedList;
}
- (BOOL) hasSender;
- (BOOL) hasIsSpeedup;
- (BOOL) hasGemsForSpeedup;
@property (readonly, strong) MinimumUserProto* sender;
- (BOOL) isSpeedup;
@property (readonly) int32_t gemsForSpeedup;
@property (readonly, strong) NSArray * biqfuCompletedList;
- (BattleItemQueueForUserProto*)biqfuCompletedAtIndex:(NSUInteger)index;

+ (CompleteBattleItemRequestProto*) defaultInstance;
- (CompleteBattleItemRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (CompleteBattleItemRequestProto_Builder*) builder;
+ (CompleteBattleItemRequestProto_Builder*) builder;
+ (CompleteBattleItemRequestProto_Builder*) builderWithPrototype:(CompleteBattleItemRequestProto*) prototype;
- (CompleteBattleItemRequestProto_Builder*) toBuilder;

+ (CompleteBattleItemRequestProto*) parseFromData:(NSData*) data;
+ (CompleteBattleItemRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CompleteBattleItemRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (CompleteBattleItemRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CompleteBattleItemRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (CompleteBattleItemRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface CompleteBattleItemRequestProto_Builder : PBGeneratedMessageBuilder {
@private
  CompleteBattleItemRequestProto* result;
}

- (CompleteBattleItemRequestProto*) defaultInstance;

- (CompleteBattleItemRequestProto_Builder*) clear;
- (CompleteBattleItemRequestProto_Builder*) clone;

- (CompleteBattleItemRequestProto*) build;
- (CompleteBattleItemRequestProto*) buildPartial;

- (CompleteBattleItemRequestProto_Builder*) mergeFrom:(CompleteBattleItemRequestProto*) other;
- (CompleteBattleItemRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (CompleteBattleItemRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (CompleteBattleItemRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (CompleteBattleItemRequestProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (CompleteBattleItemRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (CompleteBattleItemRequestProto_Builder*) clearSender;

- (BOOL) hasIsSpeedup;
- (BOOL) isSpeedup;
- (CompleteBattleItemRequestProto_Builder*) setIsSpeedup:(BOOL) value;
- (CompleteBattleItemRequestProto_Builder*) clearIsSpeedup;

- (BOOL) hasGemsForSpeedup;
- (int32_t) gemsForSpeedup;
- (CompleteBattleItemRequestProto_Builder*) setGemsForSpeedup:(int32_t) value;
- (CompleteBattleItemRequestProto_Builder*) clearGemsForSpeedup;

- (NSMutableArray *)biqfuCompletedList;
- (BattleItemQueueForUserProto*)biqfuCompletedAtIndex:(NSUInteger)index;
- (CompleteBattleItemRequestProto_Builder *)addBiqfuCompleted:(BattleItemQueueForUserProto*)value;
- (CompleteBattleItemRequestProto_Builder *)addAllBiqfuCompleted:(NSArray *)array;
- (CompleteBattleItemRequestProto_Builder *)clearBiqfuCompleted;
@end

@interface CompleteBattleItemResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  CompleteBattleItemResponseProto_CompleteBattleItemStatus status;
  NSMutableArray * mutableUbiUpdatedList;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) CompleteBattleItemResponseProto_CompleteBattleItemStatus status;
@property (readonly, strong) NSArray * ubiUpdatedList;
- (UserBattleItemProto*)ubiUpdatedAtIndex:(NSUInteger)index;

+ (CompleteBattleItemResponseProto*) defaultInstance;
- (CompleteBattleItemResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (CompleteBattleItemResponseProto_Builder*) builder;
+ (CompleteBattleItemResponseProto_Builder*) builder;
+ (CompleteBattleItemResponseProto_Builder*) builderWithPrototype:(CompleteBattleItemResponseProto*) prototype;
- (CompleteBattleItemResponseProto_Builder*) toBuilder;

+ (CompleteBattleItemResponseProto*) parseFromData:(NSData*) data;
+ (CompleteBattleItemResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CompleteBattleItemResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (CompleteBattleItemResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CompleteBattleItemResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (CompleteBattleItemResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface CompleteBattleItemResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  CompleteBattleItemResponseProto* result;
}

- (CompleteBattleItemResponseProto*) defaultInstance;

- (CompleteBattleItemResponseProto_Builder*) clear;
- (CompleteBattleItemResponseProto_Builder*) clone;

- (CompleteBattleItemResponseProto*) build;
- (CompleteBattleItemResponseProto*) buildPartial;

- (CompleteBattleItemResponseProto_Builder*) mergeFrom:(CompleteBattleItemResponseProto*) other;
- (CompleteBattleItemResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (CompleteBattleItemResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (CompleteBattleItemResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (CompleteBattleItemResponseProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (CompleteBattleItemResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (CompleteBattleItemResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (CompleteBattleItemResponseProto_CompleteBattleItemStatus) status;
- (CompleteBattleItemResponseProto_Builder*) setStatus:(CompleteBattleItemResponseProto_CompleteBattleItemStatus) value;
- (CompleteBattleItemResponseProto_Builder*) clearStatusList;

- (NSMutableArray *)ubiUpdatedList;
- (UserBattleItemProto*)ubiUpdatedAtIndex:(NSUInteger)index;
- (CompleteBattleItemResponseProto_Builder *)addUbiUpdated:(UserBattleItemProto*)value;
- (CompleteBattleItemResponseProto_Builder *)addAllUbiUpdated:(NSArray *)array;
- (CompleteBattleItemResponseProto_Builder *)clearUbiUpdated;
@end

@interface DiscardBattleItemRequestProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  MinimumUserProto* sender;
  PBAppendableArray * mutableDiscardedBattleItemIdsList;
}
- (BOOL) hasSender;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly, strong) PBArray * discardedBattleItemIdsList;
- (int32_t)discardedBattleItemIdsAtIndex:(NSUInteger)index;

+ (DiscardBattleItemRequestProto*) defaultInstance;
- (DiscardBattleItemRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (DiscardBattleItemRequestProto_Builder*) builder;
+ (DiscardBattleItemRequestProto_Builder*) builder;
+ (DiscardBattleItemRequestProto_Builder*) builderWithPrototype:(DiscardBattleItemRequestProto*) prototype;
- (DiscardBattleItemRequestProto_Builder*) toBuilder;

+ (DiscardBattleItemRequestProto*) parseFromData:(NSData*) data;
+ (DiscardBattleItemRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (DiscardBattleItemRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (DiscardBattleItemRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (DiscardBattleItemRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (DiscardBattleItemRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface DiscardBattleItemRequestProto_Builder : PBGeneratedMessageBuilder {
@private
  DiscardBattleItemRequestProto* result;
}

- (DiscardBattleItemRequestProto*) defaultInstance;

- (DiscardBattleItemRequestProto_Builder*) clear;
- (DiscardBattleItemRequestProto_Builder*) clone;

- (DiscardBattleItemRequestProto*) build;
- (DiscardBattleItemRequestProto*) buildPartial;

- (DiscardBattleItemRequestProto_Builder*) mergeFrom:(DiscardBattleItemRequestProto*) other;
- (DiscardBattleItemRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (DiscardBattleItemRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (DiscardBattleItemRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (DiscardBattleItemRequestProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (DiscardBattleItemRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (DiscardBattleItemRequestProto_Builder*) clearSender;

- (PBAppendableArray *)discardedBattleItemIdsList;
- (int32_t)discardedBattleItemIdsAtIndex:(NSUInteger)index;
- (DiscardBattleItemRequestProto_Builder *)addDiscardedBattleItemIds:(int32_t)value;
- (DiscardBattleItemRequestProto_Builder *)addAllDiscardedBattleItemIds:(NSArray *)array;
- (DiscardBattleItemRequestProto_Builder *)setDiscardedBattleItemIdsValues:(const int32_t *)values count:(NSUInteger)count;
- (DiscardBattleItemRequestProto_Builder *)clearDiscardedBattleItemIds;
@end

@interface DiscardBattleItemResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  DiscardBattleItemResponseProto_DiscardBattleItemStatus status;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) DiscardBattleItemResponseProto_DiscardBattleItemStatus status;

+ (DiscardBattleItemResponseProto*) defaultInstance;
- (DiscardBattleItemResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (DiscardBattleItemResponseProto_Builder*) builder;
+ (DiscardBattleItemResponseProto_Builder*) builder;
+ (DiscardBattleItemResponseProto_Builder*) builderWithPrototype:(DiscardBattleItemResponseProto*) prototype;
- (DiscardBattleItemResponseProto_Builder*) toBuilder;

+ (DiscardBattleItemResponseProto*) parseFromData:(NSData*) data;
+ (DiscardBattleItemResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (DiscardBattleItemResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (DiscardBattleItemResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (DiscardBattleItemResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (DiscardBattleItemResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface DiscardBattleItemResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  DiscardBattleItemResponseProto* result;
}

- (DiscardBattleItemResponseProto*) defaultInstance;

- (DiscardBattleItemResponseProto_Builder*) clear;
- (DiscardBattleItemResponseProto_Builder*) clone;

- (DiscardBattleItemResponseProto*) build;
- (DiscardBattleItemResponseProto*) buildPartial;

- (DiscardBattleItemResponseProto_Builder*) mergeFrom:(DiscardBattleItemResponseProto*) other;
- (DiscardBattleItemResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (DiscardBattleItemResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (DiscardBattleItemResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (DiscardBattleItemResponseProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (DiscardBattleItemResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (DiscardBattleItemResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (DiscardBattleItemResponseProto_DiscardBattleItemStatus) status;
- (DiscardBattleItemResponseProto_Builder*) setStatus:(DiscardBattleItemResponseProto_DiscardBattleItemStatus) value;
- (DiscardBattleItemResponseProto_Builder*) clearStatusList;
@end


// @@protoc_insertion_point(global_scope)
