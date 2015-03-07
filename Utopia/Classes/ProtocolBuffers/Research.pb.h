// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "Structure.pb.h"
// @@protoc_insertion_point(imports)

@class BattleItemFactoryProto;
@class BattleItemFactoryProto_Builder;
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
@class ResearchPropertyProto;
@class ResearchPropertyProto_Builder;
@class ResearchProto;
@class ResearchProto_Builder;
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
@class UserObstacleProto;
@class UserObstacleProto_Builder;
@class UserPvpBoardObstacleProto;
@class UserPvpBoardObstacleProto_Builder;
@class UserResearchProto;
@class UserResearchProto_Builder;
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

typedef NS_ENUM(SInt32, ResearchType) {
  ResearchTypeNoResearch = 1,
  ResearchTypeCost = 2,
  ResearchTypeSpeed = 3,
  ResearchTypeIncreaseQueueSize = 4,
  ResearchTypeIncreaseNumCanBuild = 5,
  ResearchTypeXpBonus = 6,
  ResearchTypeIncreaseCashProduction = 7,
  ResearchTypeIncreaseOilProduction = 8,
  ResearchTypeIncreaseAttack = 9,
  ResearchTypeIncreaseHp = 10,
};

BOOL ResearchTypeIsValidValue(ResearchType value);

typedef NS_ENUM(SInt32, ResearchDomain) {
  ResearchDomainNoDomain = 1,
  ResearchDomainRestorative = 2,
  ResearchDomainLevelup = 3,
  ResearchDomainResources = 4,
  ResearchDomainBattle = 5,
};

BOOL ResearchDomainIsValidValue(ResearchDomain value);


@interface ResearchRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface ResearchProto : PBGeneratedMessage {
@private
  BOOL hasResearchId_:1;
  BOOL hasPredId_:1;
  BOOL hasSuccId_:1;
  BOOL hasDurationMin_:1;
  BOOL hasCostAmt_:1;
  BOOL hasLevel_:1;
  BOOL hasIconImgName_:1;
  BOOL hasName_:1;
  BOOL hasDesc_:1;
  BOOL hasResearchType_:1;
  BOOL hasResearchDomain_:1;
  BOOL hasCostType_:1;
  int32_t researchId;
  int32_t predId;
  int32_t succId;
  int32_t durationMin;
  int32_t costAmt;
  int32_t level;
  NSString* iconImgName;
  NSString* name;
  NSString* desc;
  ResearchType researchType;
  ResearchDomain researchDomain;
  ResourceType costType;
  NSMutableArray * mutablePropertiesList;
}
- (BOOL) hasResearchId;
- (BOOL) hasResearchType;
- (BOOL) hasResearchDomain;
- (BOOL) hasIconImgName;
- (BOOL) hasName;
- (BOOL) hasPredId;
- (BOOL) hasSuccId;
- (BOOL) hasDesc;
- (BOOL) hasDurationMin;
- (BOOL) hasCostAmt;
- (BOOL) hasCostType;
- (BOOL) hasLevel;
@property (readonly) int32_t researchId;
@property (readonly) ResearchType researchType;
@property (readonly) ResearchDomain researchDomain;
@property (readonly, strong) NSString* iconImgName;
@property (readonly, strong) NSString* name;
@property (readonly) int32_t predId;
@property (readonly) int32_t succId;
@property (readonly, strong) NSString* desc;
@property (readonly) int32_t durationMin;
@property (readonly) int32_t costAmt;
@property (readonly) ResourceType costType;
@property (readonly, strong) NSArray * propertiesList;
@property (readonly) int32_t level;
- (ResearchPropertyProto*)propertiesAtIndex:(NSUInteger)index;

+ (ResearchProto*) defaultInstance;
- (ResearchProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (ResearchProto_Builder*) builder;
+ (ResearchProto_Builder*) builder;
+ (ResearchProto_Builder*) builderWithPrototype:(ResearchProto*) prototype;
- (ResearchProto_Builder*) toBuilder;

+ (ResearchProto*) parseFromData:(NSData*) data;
+ (ResearchProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ResearchProto*) parseFromInputStream:(NSInputStream*) input;
+ (ResearchProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ResearchProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (ResearchProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface ResearchProto_Builder : PBGeneratedMessageBuilder {
@private
  ResearchProto* result;
}

- (ResearchProto*) defaultInstance;

- (ResearchProto_Builder*) clear;
- (ResearchProto_Builder*) clone;

- (ResearchProto*) build;
- (ResearchProto*) buildPartial;

- (ResearchProto_Builder*) mergeFrom:(ResearchProto*) other;
- (ResearchProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (ResearchProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasResearchId;
- (int32_t) researchId;
- (ResearchProto_Builder*) setResearchId:(int32_t) value;
- (ResearchProto_Builder*) clearResearchId;

- (BOOL) hasResearchType;
- (ResearchType) researchType;
- (ResearchProto_Builder*) setResearchType:(ResearchType) value;
- (ResearchProto_Builder*) clearResearchTypeList;

- (BOOL) hasResearchDomain;
- (ResearchDomain) researchDomain;
- (ResearchProto_Builder*) setResearchDomain:(ResearchDomain) value;
- (ResearchProto_Builder*) clearResearchDomainList;

- (BOOL) hasIconImgName;
- (NSString*) iconImgName;
- (ResearchProto_Builder*) setIconImgName:(NSString*) value;
- (ResearchProto_Builder*) clearIconImgName;

- (BOOL) hasName;
- (NSString*) name;
- (ResearchProto_Builder*) setName:(NSString*) value;
- (ResearchProto_Builder*) clearName;

- (BOOL) hasPredId;
- (int32_t) predId;
- (ResearchProto_Builder*) setPredId:(int32_t) value;
- (ResearchProto_Builder*) clearPredId;

- (BOOL) hasSuccId;
- (int32_t) succId;
- (ResearchProto_Builder*) setSuccId:(int32_t) value;
- (ResearchProto_Builder*) clearSuccId;

- (BOOL) hasDesc;
- (NSString*) desc;
- (ResearchProto_Builder*) setDesc:(NSString*) value;
- (ResearchProto_Builder*) clearDesc;

- (BOOL) hasDurationMin;
- (int32_t) durationMin;
- (ResearchProto_Builder*) setDurationMin:(int32_t) value;
- (ResearchProto_Builder*) clearDurationMin;

- (BOOL) hasCostAmt;
- (int32_t) costAmt;
- (ResearchProto_Builder*) setCostAmt:(int32_t) value;
- (ResearchProto_Builder*) clearCostAmt;

- (BOOL) hasCostType;
- (ResourceType) costType;
- (ResearchProto_Builder*) setCostType:(ResourceType) value;
- (ResearchProto_Builder*) clearCostTypeList;

- (NSMutableArray *)propertiesList;
- (ResearchPropertyProto*)propertiesAtIndex:(NSUInteger)index;
- (ResearchProto_Builder *)addProperties:(ResearchPropertyProto*)value;
- (ResearchProto_Builder *)addAllProperties:(NSArray *)array;
- (ResearchProto_Builder *)clearProperties;

- (BOOL) hasLevel;
- (int32_t) level;
- (ResearchProto_Builder*) setLevel:(int32_t) value;
- (ResearchProto_Builder*) clearLevel;
@end

@interface ResearchPropertyProto : PBGeneratedMessage {
@private
  BOOL hasResearchValue_:1;
  BOOL hasResearchPropertyId_:1;
  BOOL hasResearchId_:1;
  BOOL hasName_:1;
  Float32 researchValue;
  int32_t researchPropertyId;
  int32_t researchId;
  NSString* name;
}
- (BOOL) hasResearchPropertyId;
- (BOOL) hasName;
- (BOOL) hasResearchValue;
- (BOOL) hasResearchId;
@property (readonly) int32_t researchPropertyId;
@property (readonly, strong) NSString* name;
@property (readonly) Float32 researchValue;
@property (readonly) int32_t researchId;

+ (ResearchPropertyProto*) defaultInstance;
- (ResearchPropertyProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (ResearchPropertyProto_Builder*) builder;
+ (ResearchPropertyProto_Builder*) builder;
+ (ResearchPropertyProto_Builder*) builderWithPrototype:(ResearchPropertyProto*) prototype;
- (ResearchPropertyProto_Builder*) toBuilder;

+ (ResearchPropertyProto*) parseFromData:(NSData*) data;
+ (ResearchPropertyProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ResearchPropertyProto*) parseFromInputStream:(NSInputStream*) input;
+ (ResearchPropertyProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ResearchPropertyProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (ResearchPropertyProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface ResearchPropertyProto_Builder : PBGeneratedMessageBuilder {
@private
  ResearchPropertyProto* result;
}

- (ResearchPropertyProto*) defaultInstance;

- (ResearchPropertyProto_Builder*) clear;
- (ResearchPropertyProto_Builder*) clone;

- (ResearchPropertyProto*) build;
- (ResearchPropertyProto*) buildPartial;

- (ResearchPropertyProto_Builder*) mergeFrom:(ResearchPropertyProto*) other;
- (ResearchPropertyProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (ResearchPropertyProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasResearchPropertyId;
- (int32_t) researchPropertyId;
- (ResearchPropertyProto_Builder*) setResearchPropertyId:(int32_t) value;
- (ResearchPropertyProto_Builder*) clearResearchPropertyId;

- (BOOL) hasName;
- (NSString*) name;
- (ResearchPropertyProto_Builder*) setName:(NSString*) value;
- (ResearchPropertyProto_Builder*) clearName;

- (BOOL) hasResearchValue;
- (Float32) researchValue;
- (ResearchPropertyProto_Builder*) setResearchValue:(Float32) value;
- (ResearchPropertyProto_Builder*) clearResearchValue;

- (BOOL) hasResearchId;
- (int32_t) researchId;
- (ResearchPropertyProto_Builder*) setResearchId:(int32_t) value;
- (ResearchPropertyProto_Builder*) clearResearchId;
@end

@interface UserResearchProto : PBGeneratedMessage {
@private
  BOOL hasComplete_:1;
  BOOL hasTimePurchased_:1;
  BOOL hasResearchId_:1;
  BOOL hasUserResearchUuid_:1;
  BOOL hasUserUuid_:1;
  BOOL complete_:1;
  int64_t timePurchased;
  int32_t researchId;
  NSString* userResearchUuid;
  NSString* userUuid;
}
- (BOOL) hasUserResearchUuid;
- (BOOL) hasUserUuid;
- (BOOL) hasResearchId;
- (BOOL) hasTimePurchased;
- (BOOL) hasComplete;
@property (readonly, strong) NSString* userResearchUuid;
@property (readonly, strong) NSString* userUuid;
@property (readonly) int32_t researchId;
@property (readonly) int64_t timePurchased;
- (BOOL) complete;

+ (UserResearchProto*) defaultInstance;
- (UserResearchProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (UserResearchProto_Builder*) builder;
+ (UserResearchProto_Builder*) builder;
+ (UserResearchProto_Builder*) builderWithPrototype:(UserResearchProto*) prototype;
- (UserResearchProto_Builder*) toBuilder;

+ (UserResearchProto*) parseFromData:(NSData*) data;
+ (UserResearchProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserResearchProto*) parseFromInputStream:(NSInputStream*) input;
+ (UserResearchProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserResearchProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (UserResearchProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface UserResearchProto_Builder : PBGeneratedMessageBuilder {
@private
  UserResearchProto* result;
}

- (UserResearchProto*) defaultInstance;

- (UserResearchProto_Builder*) clear;
- (UserResearchProto_Builder*) clone;

- (UserResearchProto*) build;
- (UserResearchProto*) buildPartial;

- (UserResearchProto_Builder*) mergeFrom:(UserResearchProto*) other;
- (UserResearchProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (UserResearchProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasUserResearchUuid;
- (NSString*) userResearchUuid;
- (UserResearchProto_Builder*) setUserResearchUuid:(NSString*) value;
- (UserResearchProto_Builder*) clearUserResearchUuid;

- (BOOL) hasUserUuid;
- (NSString*) userUuid;
- (UserResearchProto_Builder*) setUserUuid:(NSString*) value;
- (UserResearchProto_Builder*) clearUserUuid;

- (BOOL) hasResearchId;
- (int32_t) researchId;
- (UserResearchProto_Builder*) setResearchId:(int32_t) value;
- (UserResearchProto_Builder*) clearResearchId;

- (BOOL) hasTimePurchased;
- (int64_t) timePurchased;
- (UserResearchProto_Builder*) setTimePurchased:(int64_t) value;
- (UserResearchProto_Builder*) clearTimePurchased;

- (BOOL) hasComplete;
- (BOOL) complete;
- (UserResearchProto_Builder*) setComplete:(BOOL) value;
- (UserResearchProto_Builder*) clearComplete;
@end


// @@protoc_insertion_point(global_scope)
