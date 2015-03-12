// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "SharedEnumConfig.pb.h"
#import "Structure.pb.h"
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
@class EvoChamberProto;
@class EvoChamberProto_Builder;
@class FullUserStructureProto;
@class FullUserStructureProto_Builder;
@class HospitalProto;
@class HospitalProto_Builder;
@class LabProto;
@class LabProto_Builder;
@class MiniJobCenterProto;
@class MiniJobCenterProto_Builder;
@class MinimumObstacleProto;
@class MinimumObstacleProto_Builder;
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
@class UserObstacleProto;
@class UserObstacleProto_Builder;
@class UserPvpBoardObstacleProto;
@class UserPvpBoardObstacleProto_Builder;
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

typedef NS_ENUM(SInt32, BattleItemType) {
  BattleItemTypeAntidote = 1,
  BattleItemTypeHammer = 2,
};

BOOL BattleItemTypeIsValidValue(BattleItemType value);

typedef NS_ENUM(SInt32, BattleItemCategory) {
  BattleItemCategoryPotion = 1,
  BattleItemCategoryPuzzle = 2,
};

BOOL BattleItemCategoryIsValidValue(BattleItemCategory value);


@interface BattleItemRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface UserBattleItemProto : PBGeneratedMessage {
@private
  BOOL hasBattleItemId_:1;
  BOOL hasQuantity_:1;
  BOOL hasUserBattleItemId_:1;
  BOOL hasUserUuid_:1;
  int32_t battleItemId;
  int32_t quantity;
  NSString* userBattleItemId;
  NSString* userUuid;
}
- (BOOL) hasUserBattleItemId;
- (BOOL) hasUserUuid;
- (BOOL) hasBattleItemId;
- (BOOL) hasQuantity;
@property (readonly, strong) NSString* userBattleItemId;
@property (readonly, strong) NSString* userUuid;
@property (readonly) int32_t battleItemId;
@property (readonly) int32_t quantity;

+ (UserBattleItemProto*) defaultInstance;
- (UserBattleItemProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (UserBattleItemProto_Builder*) builder;
+ (UserBattleItemProto_Builder*) builder;
+ (UserBattleItemProto_Builder*) builderWithPrototype:(UserBattleItemProto*) prototype;
- (UserBattleItemProto_Builder*) toBuilder;

+ (UserBattleItemProto*) parseFromData:(NSData*) data;
+ (UserBattleItemProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserBattleItemProto*) parseFromInputStream:(NSInputStream*) input;
+ (UserBattleItemProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserBattleItemProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (UserBattleItemProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface UserBattleItemProto_Builder : PBGeneratedMessageBuilder {
@private
  UserBattleItemProto* result;
}

- (UserBattleItemProto*) defaultInstance;

- (UserBattleItemProto_Builder*) clear;
- (UserBattleItemProto_Builder*) clone;

- (UserBattleItemProto*) build;
- (UserBattleItemProto*) buildPartial;

- (UserBattleItemProto_Builder*) mergeFrom:(UserBattleItemProto*) other;
- (UserBattleItemProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (UserBattleItemProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasUserBattleItemId;
- (NSString*) userBattleItemId;
- (UserBattleItemProto_Builder*) setUserBattleItemId:(NSString*) value;
- (UserBattleItemProto_Builder*) clearUserBattleItemId;

- (BOOL) hasUserUuid;
- (NSString*) userUuid;
- (UserBattleItemProto_Builder*) setUserUuid:(NSString*) value;
- (UserBattleItemProto_Builder*) clearUserUuid;

- (BOOL) hasBattleItemId;
- (int32_t) battleItemId;
- (UserBattleItemProto_Builder*) setBattleItemId:(int32_t) value;
- (UserBattleItemProto_Builder*) clearBattleItemId;

- (BOOL) hasQuantity;
- (int32_t) quantity;
- (UserBattleItemProto_Builder*) setQuantity:(int32_t) value;
- (UserBattleItemProto_Builder*) clearQuantity;
@end

@interface BattleItemProto : PBGeneratedMessage {
@private
  BOOL hasBattleItemId_:1;
  BOOL hasCreateCost_:1;
  BOOL hasPowerAmount_:1;
  BOOL hasPriority_:1;
  BOOL hasMinutesToCreate_:1;
  BOOL hasInBattleGemCost_:1;
  BOOL hasName_:1;
  BOOL hasImgName_:1;
  BOOL hasDescription_:1;
  BOOL hasImageName_:1;
  BOOL hasBattleItemType_:1;
  BOOL hasBattleItemCategory_:1;
  BOOL hasCreateResourceType_:1;
  int32_t battleItemId;
  int32_t createCost;
  int32_t powerAmount;
  int32_t priority;
  int32_t minutesToCreate;
  int32_t inBattleGemCost;
  NSString* name;
  NSString* imgName;
  NSString* description;
  NSString* imageName;
  BattleItemType battleItemType;
  BattleItemCategory battleItemCategory;
  ResourceType createResourceType;
}
- (BOOL) hasBattleItemId;
- (BOOL) hasName;
- (BOOL) hasImgName;
- (BOOL) hasBattleItemType;
- (BOOL) hasBattleItemCategory;
- (BOOL) hasCreateResourceType;
- (BOOL) hasCreateCost;
- (BOOL) hasDescription;
- (BOOL) hasPowerAmount;
- (BOOL) hasImageName;
- (BOOL) hasPriority;
- (BOOL) hasMinutesToCreate;
- (BOOL) hasInBattleGemCost;
@property (readonly) int32_t battleItemId;
@property (readonly, strong) NSString* name;
@property (readonly, strong) NSString* imgName;
@property (readonly) BattleItemType battleItemType;
@property (readonly) BattleItemCategory battleItemCategory;
@property (readonly) ResourceType createResourceType;
@property (readonly) int32_t createCost;
@property (readonly, strong) NSString* description;
@property (readonly) int32_t powerAmount;
@property (readonly, strong) NSString* imageName;
@property (readonly) int32_t priority;
@property (readonly) int32_t minutesToCreate;
@property (readonly) int32_t inBattleGemCost;

+ (BattleItemProto*) defaultInstance;
- (BattleItemProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (BattleItemProto_Builder*) builder;
+ (BattleItemProto_Builder*) builder;
+ (BattleItemProto_Builder*) builderWithPrototype:(BattleItemProto*) prototype;
- (BattleItemProto_Builder*) toBuilder;

+ (BattleItemProto*) parseFromData:(NSData*) data;
+ (BattleItemProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BattleItemProto*) parseFromInputStream:(NSInputStream*) input;
+ (BattleItemProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BattleItemProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (BattleItemProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface BattleItemProto_Builder : PBGeneratedMessageBuilder {
@private
  BattleItemProto* result;
}

- (BattleItemProto*) defaultInstance;

- (BattleItemProto_Builder*) clear;
- (BattleItemProto_Builder*) clone;

- (BattleItemProto*) build;
- (BattleItemProto*) buildPartial;

- (BattleItemProto_Builder*) mergeFrom:(BattleItemProto*) other;
- (BattleItemProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (BattleItemProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasBattleItemId;
- (int32_t) battleItemId;
- (BattleItemProto_Builder*) setBattleItemId:(int32_t) value;
- (BattleItemProto_Builder*) clearBattleItemId;

- (BOOL) hasName;
- (NSString*) name;
- (BattleItemProto_Builder*) setName:(NSString*) value;
- (BattleItemProto_Builder*) clearName;

- (BOOL) hasImgName;
- (NSString*) imgName;
- (BattleItemProto_Builder*) setImgName:(NSString*) value;
- (BattleItemProto_Builder*) clearImgName;

- (BOOL) hasBattleItemType;
- (BattleItemType) battleItemType;
- (BattleItemProto_Builder*) setBattleItemType:(BattleItemType) value;
- (BattleItemProto_Builder*) clearBattleItemTypeList;

- (BOOL) hasBattleItemCategory;
- (BattleItemCategory) battleItemCategory;
- (BattleItemProto_Builder*) setBattleItemCategory:(BattleItemCategory) value;
- (BattleItemProto_Builder*) clearBattleItemCategoryList;

- (BOOL) hasCreateResourceType;
- (ResourceType) createResourceType;
- (BattleItemProto_Builder*) setCreateResourceType:(ResourceType) value;
- (BattleItemProto_Builder*) clearCreateResourceTypeList;

- (BOOL) hasCreateCost;
- (int32_t) createCost;
- (BattleItemProto_Builder*) setCreateCost:(int32_t) value;
- (BattleItemProto_Builder*) clearCreateCost;

- (BOOL) hasDescription;
- (NSString*) description;
- (BattleItemProto_Builder*) setDescription:(NSString*) value;
- (BattleItemProto_Builder*) clearDescription;

- (BOOL) hasPowerAmount;
- (int32_t) powerAmount;
- (BattleItemProto_Builder*) setPowerAmount:(int32_t) value;
- (BattleItemProto_Builder*) clearPowerAmount;

- (BOOL) hasImageName;
- (NSString*) imageName;
- (BattleItemProto_Builder*) setImageName:(NSString*) value;
- (BattleItemProto_Builder*) clearImageName;

- (BOOL) hasPriority;
- (int32_t) priority;
- (BattleItemProto_Builder*) setPriority:(int32_t) value;
- (BattleItemProto_Builder*) clearPriority;

- (BOOL) hasMinutesToCreate;
- (int32_t) minutesToCreate;
- (BattleItemProto_Builder*) setMinutesToCreate:(int32_t) value;
- (BattleItemProto_Builder*) clearMinutesToCreate;

- (BOOL) hasInBattleGemCost;
- (int32_t) inBattleGemCost;
- (BattleItemProto_Builder*) setInBattleGemCost:(int32_t) value;
- (BattleItemProto_Builder*) clearInBattleGemCost;
@end

@interface BattleItemQueueForUserProto : PBGeneratedMessage {
@private
  BOOL hasElapsedTime_:1;
  BOOL hasExpectedStartTime_:1;
  BOOL hasPriority_:1;
  BOOL hasBattleItemId_:1;
  BOOL hasUserUuid_:1;
  Float32 elapsedTime;
  int64_t expectedStartTime;
  int32_t priority;
  int32_t battleItemId;
  NSString* userUuid;
}
- (BOOL) hasPriority;
- (BOOL) hasUserUuid;
- (BOOL) hasBattleItemId;
- (BOOL) hasExpectedStartTime;
- (BOOL) hasElapsedTime;
@property (readonly) int32_t priority;
@property (readonly, strong) NSString* userUuid;
@property (readonly) int32_t battleItemId;
@property (readonly) int64_t expectedStartTime;
@property (readonly) Float32 elapsedTime;

+ (BattleItemQueueForUserProto*) defaultInstance;
- (BattleItemQueueForUserProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (BattleItemQueueForUserProto_Builder*) builder;
+ (BattleItemQueueForUserProto_Builder*) builder;
+ (BattleItemQueueForUserProto_Builder*) builderWithPrototype:(BattleItemQueueForUserProto*) prototype;
- (BattleItemQueueForUserProto_Builder*) toBuilder;

+ (BattleItemQueueForUserProto*) parseFromData:(NSData*) data;
+ (BattleItemQueueForUserProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BattleItemQueueForUserProto*) parseFromInputStream:(NSInputStream*) input;
+ (BattleItemQueueForUserProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BattleItemQueueForUserProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (BattleItemQueueForUserProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface BattleItemQueueForUserProto_Builder : PBGeneratedMessageBuilder {
@private
  BattleItemQueueForUserProto* result;
}

- (BattleItemQueueForUserProto*) defaultInstance;

- (BattleItemQueueForUserProto_Builder*) clear;
- (BattleItemQueueForUserProto_Builder*) clone;

- (BattleItemQueueForUserProto*) build;
- (BattleItemQueueForUserProto*) buildPartial;

- (BattleItemQueueForUserProto_Builder*) mergeFrom:(BattleItemQueueForUserProto*) other;
- (BattleItemQueueForUserProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (BattleItemQueueForUserProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasPriority;
- (int32_t) priority;
- (BattleItemQueueForUserProto_Builder*) setPriority:(int32_t) value;
- (BattleItemQueueForUserProto_Builder*) clearPriority;

- (BOOL) hasUserUuid;
- (NSString*) userUuid;
- (BattleItemQueueForUserProto_Builder*) setUserUuid:(NSString*) value;
- (BattleItemQueueForUserProto_Builder*) clearUserUuid;

- (BOOL) hasBattleItemId;
- (int32_t) battleItemId;
- (BattleItemQueueForUserProto_Builder*) setBattleItemId:(int32_t) value;
- (BattleItemQueueForUserProto_Builder*) clearBattleItemId;

- (BOOL) hasExpectedStartTime;
- (int64_t) expectedStartTime;
- (BattleItemQueueForUserProto_Builder*) setExpectedStartTime:(int64_t) value;
- (BattleItemQueueForUserProto_Builder*) clearExpectedStartTime;

- (BOOL) hasElapsedTime;
- (Float32) elapsedTime;
- (BattleItemQueueForUserProto_Builder*) setElapsedTime:(Float32) value;
- (BattleItemQueueForUserProto_Builder*) clearElapsedTime;
@end


// @@protoc_insertion_point(global_scope)
