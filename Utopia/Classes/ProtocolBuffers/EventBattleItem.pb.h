// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "BattleItem.pb.h"
#import "SharedEnumConfig.pb.h"
#import "User.pb.h"
// @@protoc_insertion_point(imports)

@class BattleItemProto;
@class BattleItemProto_Builder;
@class BattleItemQueueForUserProto;
@class BattleItemQueueForUserProto_Builder;
@class CompleteBattleItemRequestProto;
@class CompleteBattleItemRequestProto_Builder;
@class CompleteBattleItemResponseProto;
@class CompleteBattleItemResponseProto_Builder;
@class CreateBattleItemRequestProto;
@class CreateBattleItemRequestProto_Builder;
@class CreateBattleItemResponseProto;
@class CreateBattleItemResponseProto_Builder;
@class DiscardBattleItemRequestProto;
@class DiscardBattleItemRequestProto_Builder;
@class DiscardBattleItemResponseProto;
@class DiscardBattleItemResponseProto_Builder;
@class FullUserProto;
@class FullUserProto_Builder;
@class MinimumClanProto;
@class MinimumClanProto_Builder;
@class MinimumUserProto;
@class MinimumUserProtoWithFacebookId;
@class MinimumUserProtoWithFacebookId_Builder;
@class MinimumUserProtoWithMaxResources;
@class MinimumUserProtoWithMaxResources_Builder;
@class MinimumUserProto_Builder;
@class StaticUserLevelInfoProto;
@class StaticUserLevelInfoProto_Builder;
@class UserBattleItemProto;
@class UserBattleItemProto_Builder;
@class UserFacebookInviteForSlotProto;
@class UserFacebookInviteForSlotProto_Builder;
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


@interface EventBattleItemRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface CreateBattleItemRequestProto : PBGeneratedMessage {
@private
  BOOL hasClientTime_:1;
  BOOL hasGemCostForCreating_:1;
  BOOL hasSender_:1;
  BOOL hasCashChange_:1;
  BOOL hasOilChange_:1;
  int64_t clientTime;
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
- (BOOL) hasClientTime;
@property (readonly, strong) MinimumUserProtoWithMaxResources* sender;
@property (readonly, strong) NSArray * biqfuDeleteList;
@property (readonly, strong) NSArray * biqfuUpdateList;
@property (readonly, strong) NSArray * biqfuNewList;
@property (readonly) int32_t cashChange;
@property (readonly) int32_t oilChange;
@property (readonly) int32_t gemCostForCreating;
@property (readonly) int64_t clientTime;
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

- (BOOL) hasClientTime;
- (int64_t) clientTime;
- (CreateBattleItemRequestProto_Builder*) setClientTime:(int64_t) value;
- (CreateBattleItemRequestProto_Builder*) clearClientTime;
@end

@interface CreateBattleItemResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  ResponseStatus status;
  NSMutableArray * mutableUserBattleItemsList;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly, strong) NSArray * userBattleItemsList;
@property (readonly) ResponseStatus status;
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
- (ResponseStatus) status;
- (CreateBattleItemResponseProto_Builder*) setStatus:(ResponseStatus) value;
- (CreateBattleItemResponseProto_Builder*) clearStatusList;
@end

@interface CompleteBattleItemRequestProto : PBGeneratedMessage {
@private
  BOOL hasIsSpeedup_:1;
  BOOL hasClientTime_:1;
  BOOL hasGemsForSpeedup_:1;
  BOOL hasSender_:1;
  BOOL isSpeedup_:1;
  int64_t clientTime;
  int32_t gemsForSpeedup;
  MinimumUserProto* sender;
  NSMutableArray * mutableBiqfuCompletedList;
}
- (BOOL) hasSender;
- (BOOL) hasIsSpeedup;
- (BOOL) hasGemsForSpeedup;
- (BOOL) hasClientTime;
@property (readonly, strong) MinimumUserProto* sender;
- (BOOL) isSpeedup;
@property (readonly) int32_t gemsForSpeedup;
@property (readonly, strong) NSArray * biqfuCompletedList;
@property (readonly) int64_t clientTime;
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

- (BOOL) hasClientTime;
- (int64_t) clientTime;
- (CompleteBattleItemRequestProto_Builder*) setClientTime:(int64_t) value;
- (CompleteBattleItemRequestProto_Builder*) clearClientTime;
@end

@interface CompleteBattleItemResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  ResponseStatus status;
  NSMutableArray * mutableUbiUpdatedList;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) ResponseStatus status;
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
- (ResponseStatus) status;
- (CompleteBattleItemResponseProto_Builder*) setStatus:(ResponseStatus) value;
- (CompleteBattleItemResponseProto_Builder*) clearStatusList;

- (NSMutableArray *)ubiUpdatedList;
- (UserBattleItemProto*)ubiUpdatedAtIndex:(NSUInteger)index;
- (CompleteBattleItemResponseProto_Builder *)addUbiUpdated:(UserBattleItemProto*)value;
- (CompleteBattleItemResponseProto_Builder *)addAllUbiUpdated:(NSArray *)array;
- (CompleteBattleItemResponseProto_Builder *)clearUbiUpdated;
@end

@interface DiscardBattleItemRequestProto : PBGeneratedMessage {
@private
  BOOL hasClientTime_:1;
  BOOL hasSender_:1;
  int64_t clientTime;
  MinimumUserProto* sender;
  PBAppendableArray * mutableDiscardedBattleItemIdsList;
}
- (BOOL) hasSender;
- (BOOL) hasClientTime;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly, strong) PBArray * discardedBattleItemIdsList;
@property (readonly) int64_t clientTime;
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

- (BOOL) hasClientTime;
- (int64_t) clientTime;
- (DiscardBattleItemRequestProto_Builder*) setClientTime:(int64_t) value;
- (DiscardBattleItemRequestProto_Builder*) clearClientTime;
@end

@interface DiscardBattleItemResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  ResponseStatus status;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) ResponseStatus status;

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
- (ResponseStatus) status;
- (DiscardBattleItemResponseProto_Builder*) setStatus:(ResponseStatus) value;
- (DiscardBattleItemResponseProto_Builder*) clearStatusList;
@end


// @@protoc_insertion_point(global_scope)
