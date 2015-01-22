// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "SharedEnumConfig.pb.h"
#import "Structure.pb.h"
// @@protoc_insertion_point(imports)

@class AchievementProto;
@class AchievementProto_Builder;
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
@class ObstacleProto;
@class ObstacleProto_Builder;
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
@class UserAchievementProto;
@class UserAchievementProto_Builder;
@class UserObstacleProto;
@class UserObstacleProto_Builder;
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

typedef NS_ENUM(SInt32, AchievementProto_AchievementType) {
  AchievementProto_AchievementTypeNoAchievement = 17,
  AchievementProto_AchievementTypeCollectResource = 1,
  AchievementProto_AchievementTypeCreateGrenade = 2,
  AchievementProto_AchievementTypeCreateRainbow = 3,
  AchievementProto_AchievementTypeCreateRocket = 4,
  AchievementProto_AchievementTypeDefeatMonsters = 5,
  AchievementProto_AchievementTypeDestroyOrbs = 6,
  AchievementProto_AchievementTypeEnhancePoints = 7,
  AchievementProto_AchievementTypeHealMonsters = 8,
  AchievementProto_AchievementTypeJoinLeague = 9,
  AchievementProto_AchievementTypeMakeCombo = 10,
  AchievementProto_AchievementTypeRemoveObstacle = 11,
  AchievementProto_AchievementTypeSellMonster = 12,
  AchievementProto_AchievementTypeStealResource = 13,
  AchievementProto_AchievementTypeTakeDamage = 14,
  AchievementProto_AchievementTypeUpgradeBuilding = 15,
  AchievementProto_AchievementTypeWinPvpBattle = 16,
  AchievementProto_AchievementTypeJoinClan = 18,
  AchievementProto_AchievementTypeSolicitHelp = 19,
  AchievementProto_AchievementTypeGiveHelp = 20,
};

BOOL AchievementProto_AchievementTypeIsValidValue(AchievementProto_AchievementType value);


@interface AchievementStuffRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface AchievementProto : PBGeneratedMessage {
@private
  BOOL hasAchievementId_:1;
  BOOL hasGemReward_:1;
  BOOL hasLvl_:1;
  BOOL hasStaticDataId_:1;
  BOOL hasQuantity_:1;
  BOOL hasPriority_:1;
  BOOL hasPrerequisiteId_:1;
  BOOL hasSuccessorId_:1;
  BOOL hasName_:1;
  BOOL hasDescription_:1;
  BOOL hasAchievementType_:1;
  BOOL hasResourceType_:1;
  BOOL hasElement_:1;
  BOOL hasQuality_:1;
  int32_t achievementId;
  int32_t gemReward;
  int32_t lvl;
  int32_t staticDataId;
  int32_t quantity;
  int32_t priority;
  int32_t prerequisiteId;
  int32_t successorId;
  NSString* name;
  NSString* description;
  AchievementProto_AchievementType achievementType;
  ResourceType resourceType;
  Element element;
  Quality quality;
}
- (BOOL) hasAchievementId;
- (BOOL) hasName;
- (BOOL) hasDescription;
- (BOOL) hasGemReward;
- (BOOL) hasLvl;
- (BOOL) hasAchievementType;
- (BOOL) hasResourceType;
- (BOOL) hasElement;
- (BOOL) hasQuality;
- (BOOL) hasStaticDataId;
- (BOOL) hasQuantity;
- (BOOL) hasPriority;
- (BOOL) hasPrerequisiteId;
- (BOOL) hasSuccessorId;
@property (readonly) int32_t achievementId;
@property (readonly, strong) NSString* name;
@property (readonly, strong) NSString* description;
@property (readonly) int32_t gemReward;
@property (readonly) int32_t lvl;
@property (readonly) AchievementProto_AchievementType achievementType;
@property (readonly) ResourceType resourceType;
@property (readonly) Element element;
@property (readonly) Quality quality;
@property (readonly) int32_t staticDataId;
@property (readonly) int32_t quantity;
@property (readonly) int32_t priority;
@property (readonly) int32_t prerequisiteId;
@property (readonly) int32_t successorId;

+ (AchievementProto*) defaultInstance;
- (AchievementProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (AchievementProto_Builder*) builder;
+ (AchievementProto_Builder*) builder;
+ (AchievementProto_Builder*) builderWithPrototype:(AchievementProto*) prototype;
- (AchievementProto_Builder*) toBuilder;

+ (AchievementProto*) parseFromData:(NSData*) data;
+ (AchievementProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (AchievementProto*) parseFromInputStream:(NSInputStream*) input;
+ (AchievementProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (AchievementProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (AchievementProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface AchievementProto_Builder : PBGeneratedMessageBuilder {
@private
  AchievementProto* result;
}

- (AchievementProto*) defaultInstance;

- (AchievementProto_Builder*) clear;
- (AchievementProto_Builder*) clone;

- (AchievementProto*) build;
- (AchievementProto*) buildPartial;

- (AchievementProto_Builder*) mergeFrom:(AchievementProto*) other;
- (AchievementProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (AchievementProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasAchievementId;
- (int32_t) achievementId;
- (AchievementProto_Builder*) setAchievementId:(int32_t) value;
- (AchievementProto_Builder*) clearAchievementId;

- (BOOL) hasName;
- (NSString*) name;
- (AchievementProto_Builder*) setName:(NSString*) value;
- (AchievementProto_Builder*) clearName;

- (BOOL) hasDescription;
- (NSString*) description;
- (AchievementProto_Builder*) setDescription:(NSString*) value;
- (AchievementProto_Builder*) clearDescription;

- (BOOL) hasGemReward;
- (int32_t) gemReward;
- (AchievementProto_Builder*) setGemReward:(int32_t) value;
- (AchievementProto_Builder*) clearGemReward;

- (BOOL) hasLvl;
- (int32_t) lvl;
- (AchievementProto_Builder*) setLvl:(int32_t) value;
- (AchievementProto_Builder*) clearLvl;

- (BOOL) hasAchievementType;
- (AchievementProto_AchievementType) achievementType;
- (AchievementProto_Builder*) setAchievementType:(AchievementProto_AchievementType) value;
- (AchievementProto_Builder*) clearAchievementTypeList;

- (BOOL) hasResourceType;
- (ResourceType) resourceType;
- (AchievementProto_Builder*) setResourceType:(ResourceType) value;
- (AchievementProto_Builder*) clearResourceTypeList;

- (BOOL) hasElement;
- (Element) element;
- (AchievementProto_Builder*) setElement:(Element) value;
- (AchievementProto_Builder*) clearElementList;

- (BOOL) hasQuality;
- (Quality) quality;
- (AchievementProto_Builder*) setQuality:(Quality) value;
- (AchievementProto_Builder*) clearQualityList;

- (BOOL) hasStaticDataId;
- (int32_t) staticDataId;
- (AchievementProto_Builder*) setStaticDataId:(int32_t) value;
- (AchievementProto_Builder*) clearStaticDataId;

- (BOOL) hasQuantity;
- (int32_t) quantity;
- (AchievementProto_Builder*) setQuantity:(int32_t) value;
- (AchievementProto_Builder*) clearQuantity;

- (BOOL) hasPriority;
- (int32_t) priority;
- (AchievementProto_Builder*) setPriority:(int32_t) value;
- (AchievementProto_Builder*) clearPriority;

- (BOOL) hasPrerequisiteId;
- (int32_t) prerequisiteId;
- (AchievementProto_Builder*) setPrerequisiteId:(int32_t) value;
- (AchievementProto_Builder*) clearPrerequisiteId;

- (BOOL) hasSuccessorId;
- (int32_t) successorId;
- (AchievementProto_Builder*) setSuccessorId:(int32_t) value;
- (AchievementProto_Builder*) clearSuccessorId;
@end

@interface UserAchievementProto : PBGeneratedMessage {
@private
  BOOL hasIsComplete_:1;
  BOOL hasIsRedeemed_:1;
  BOOL hasAchievementId_:1;
  BOOL hasProgress_:1;
  BOOL isComplete_:1;
  BOOL isRedeemed_:1;
  int32_t achievementId;
  int32_t progress;
}
- (BOOL) hasAchievementId;
- (BOOL) hasProgress;
- (BOOL) hasIsComplete;
- (BOOL) hasIsRedeemed;
@property (readonly) int32_t achievementId;
@property (readonly) int32_t progress;
- (BOOL) isComplete;
- (BOOL) isRedeemed;

+ (UserAchievementProto*) defaultInstance;
- (UserAchievementProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (UserAchievementProto_Builder*) builder;
+ (UserAchievementProto_Builder*) builder;
+ (UserAchievementProto_Builder*) builderWithPrototype:(UserAchievementProto*) prototype;
- (UserAchievementProto_Builder*) toBuilder;

+ (UserAchievementProto*) parseFromData:(NSData*) data;
+ (UserAchievementProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserAchievementProto*) parseFromInputStream:(NSInputStream*) input;
+ (UserAchievementProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserAchievementProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (UserAchievementProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface UserAchievementProto_Builder : PBGeneratedMessageBuilder {
@private
  UserAchievementProto* result;
}

- (UserAchievementProto*) defaultInstance;

- (UserAchievementProto_Builder*) clear;
- (UserAchievementProto_Builder*) clone;

- (UserAchievementProto*) build;
- (UserAchievementProto*) buildPartial;

- (UserAchievementProto_Builder*) mergeFrom:(UserAchievementProto*) other;
- (UserAchievementProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (UserAchievementProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasAchievementId;
- (int32_t) achievementId;
- (UserAchievementProto_Builder*) setAchievementId:(int32_t) value;
- (UserAchievementProto_Builder*) clearAchievementId;

- (BOOL) hasProgress;
- (int32_t) progress;
- (UserAchievementProto_Builder*) setProgress:(int32_t) value;
- (UserAchievementProto_Builder*) clearProgress;

- (BOOL) hasIsComplete;
- (BOOL) isComplete;
- (UserAchievementProto_Builder*) setIsComplete:(BOOL) value;
- (UserAchievementProto_Builder*) clearIsComplete;

- (BOOL) hasIsRedeemed;
- (BOOL) isRedeemed;
- (UserAchievementProto_Builder*) setIsRedeemed:(BOOL) value;
- (UserAchievementProto_Builder*) clearIsRedeemed;
@end


// @@protoc_insertion_point(global_scope)
