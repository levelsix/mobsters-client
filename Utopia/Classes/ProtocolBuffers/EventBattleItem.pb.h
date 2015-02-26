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
@class MinimumUserProtoWithLevel;
@class MinimumUserProtoWithLevel_Builder;
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
  CreateBattleItemResponseProto_CreateBattleItemStatusFailAtMaxPowerLimit = 4,
  CreateBattleItemResponseProto_CreateBattleItemStatusFailAllMonstersNonexistent = 5,
  CreateBattleItemResponseProto_CreateBattleItemStatusFailCreatingNotComplete = 6,
};

BOOL CreateBattleItemResponseProto_CreateBattleItemStatusIsValidValue(CreateBattleItemResponseProto_CreateBattleItemStatus value);

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
  BOOL hasIsSpeedup_:1;
  BOOL hasGemCostForCreating_:1;
  BOOL hasGemsForSpeedup_:1;
  BOOL hasSender_:1;
  BOOL hasCashChange_:1;
  BOOL hasOilChange_:1;
  BOOL isSpeedup_:1;
  int32_t gemCostForCreating;
  int32_t gemsForSpeedup;
  MinimumUserProto* sender;
  int32_t cashChange;
  int32_t oilChange;
  NSMutableArray * mutableUmhDeleteList;
  NSMutableArray * mutableUmhRemovedList;
  NSMutableArray * mutableUmhUpdateList;
  NSMutableArray * mutableUmhNewList;
}
- (BOOL) hasSender;
- (BOOL) hasCashChange;
- (BOOL) hasOilChange;
- (BOOL) hasGemCostForCreating;
- (BOOL) hasIsSpeedup;
- (BOOL) hasGemsForSpeedup;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly, strong) NSArray * umhDeleteList;
@property (readonly, strong) NSArray * umhRemovedList;
@property (readonly, strong) NSArray * umhUpdateList;
@property (readonly, strong) NSArray * umhNewList;
@property (readonly) int32_t cashChange;
@property (readonly) int32_t oilChange;
@property (readonly) int32_t gemCostForCreating;
- (BOOL) isSpeedup;
@property (readonly) int32_t gemsForSpeedup;
- (BattleItemQueueForUserProto*)umhDeleteAtIndex:(NSUInteger)index;
- (BattleItemQueueForUserProto*)umhRemovedAtIndex:(NSUInteger)index;
- (BattleItemQueueForUserProto*)umhUpdateAtIndex:(NSUInteger)index;
- (BattleItemQueueForUserProto*)umhNewAtIndex:(NSUInteger)index;

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
- (MinimumUserProto*) sender;
- (CreateBattleItemRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (CreateBattleItemRequestProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (CreateBattleItemRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (CreateBattleItemRequestProto_Builder*) clearSender;

- (NSMutableArray *)umhDeleteList;
- (BattleItemQueueForUserProto*)umhDeleteAtIndex:(NSUInteger)index;
- (CreateBattleItemRequestProto_Builder *)addUmhDelete:(BattleItemQueueForUserProto*)value;
- (CreateBattleItemRequestProto_Builder *)addAllUmhDelete:(NSArray *)array;
- (CreateBattleItemRequestProto_Builder *)clearUmhDelete;

- (NSMutableArray *)umhRemovedList;
- (BattleItemQueueForUserProto*)umhRemovedAtIndex:(NSUInteger)index;
- (CreateBattleItemRequestProto_Builder *)addUmhRemoved:(BattleItemQueueForUserProto*)value;
- (CreateBattleItemRequestProto_Builder *)addAllUmhRemoved:(NSArray *)array;
- (CreateBattleItemRequestProto_Builder *)clearUmhRemoved;

- (NSMutableArray *)umhUpdateList;
- (BattleItemQueueForUserProto*)umhUpdateAtIndex:(NSUInteger)index;
- (CreateBattleItemRequestProto_Builder *)addUmhUpdate:(BattleItemQueueForUserProto*)value;
- (CreateBattleItemRequestProto_Builder *)addAllUmhUpdate:(NSArray *)array;
- (CreateBattleItemRequestProto_Builder *)clearUmhUpdate;

- (NSMutableArray *)umhNewList;
- (BattleItemQueueForUserProto*)umhNewAtIndex:(NSUInteger)index;
- (CreateBattleItemRequestProto_Builder *)addUmhNew:(BattleItemQueueForUserProto*)value;
- (CreateBattleItemRequestProto_Builder *)addAllUmhNew:(NSArray *)array;
- (CreateBattleItemRequestProto_Builder *)clearUmhNew;

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

- (BOOL) hasIsSpeedup;
- (BOOL) isSpeedup;
- (CreateBattleItemRequestProto_Builder*) setIsSpeedup:(BOOL) value;
- (CreateBattleItemRequestProto_Builder*) clearIsSpeedup;

- (BOOL) hasGemsForSpeedup;
- (int32_t) gemsForSpeedup;
- (CreateBattleItemRequestProto_Builder*) setGemsForSpeedup:(int32_t) value;
- (CreateBattleItemRequestProto_Builder*) clearGemsForSpeedup;
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

@interface DiscardBattleItemRequestProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  MinimumUserProto* sender;
  NSMutableArray * mutableDiscardedBattleItemsList;
}
- (BOOL) hasSender;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly, strong) NSArray * discardedBattleItemsList;
- (UserBattleItemProto*)discardedBattleItemsAtIndex:(NSUInteger)index;

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

- (NSMutableArray *)discardedBattleItemsList;
- (UserBattleItemProto*)discardedBattleItemsAtIndex:(NSUInteger)index;
- (DiscardBattleItemRequestProto_Builder *)addDiscardedBattleItems:(UserBattleItemProto*)value;
- (DiscardBattleItemRequestProto_Builder *)addAllDiscardedBattleItems:(NSArray *)array;
- (DiscardBattleItemRequestProto_Builder *)clearDiscardedBattleItems;
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