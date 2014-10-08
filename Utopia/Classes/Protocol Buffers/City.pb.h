// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "Structure.pb.h"
#import "User.pb.h"
// @@protoc_insertion_point(imports)

@class CityElementProto;
@class CityElementProto_Builder;
@class CityExpansionCostProto;
@class CityExpansionCostProto_Builder;
@class ClanHouseProto;
@class ClanHouseProto_Builder;
@class CoordinateProto;
@class CoordinateProto_Builder;
@class EvoChamberProto;
@class EvoChamberProto_Builder;
@class FullCityProto;
@class FullCityProto_Builder;
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
@class ObstacleProto;
@class ObstacleProto_Builder;
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
@class UserCityExpansionDataProto;
@class UserCityExpansionDataProto_Builder;
@class UserFacebookInviteForSlotProto;
@class UserFacebookInviteForSlotProto_Builder;
@class UserObstacleProto;
@class UserObstacleProto_Builder;
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

typedef enum {
  CityElementProto_CityElemTypeBuilding = 1,
  CityElementProto_CityElemTypeDecoration = 2,
  CityElementProto_CityElemTypePersonNeutralEnemy = 3,
  CityElementProto_CityElemTypeBoss = 4,
} CityElementProto_CityElemType;

BOOL CityElementProto_CityElemTypeIsValidValue(CityElementProto_CityElemType value);


@interface CityRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface UserCityExpansionDataProto : PBGeneratedMessage {
@private
  BOOL hasIsExpanding_:1;
  BOOL hasExpandStartTime_:1;
  BOOL hasUserId_:1;
  BOOL hasXPosition_:1;
  BOOL hasYPosition_:1;
  BOOL isExpanding_:1;
  int64_t expandStartTime;
  int32_t userId;
  int32_t xPosition;
  int32_t yPosition;
}
- (BOOL) hasUserId;
- (BOOL) hasXPosition;
- (BOOL) hasYPosition;
- (BOOL) hasIsExpanding;
- (BOOL) hasExpandStartTime;
@property (readonly) int32_t userId;
@property (readonly) int32_t xPosition;
@property (readonly) int32_t yPosition;
- (BOOL) isExpanding;
@property (readonly) int64_t expandStartTime;

+ (UserCityExpansionDataProto*) defaultInstance;
- (UserCityExpansionDataProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (UserCityExpansionDataProto_Builder*) builder;
+ (UserCityExpansionDataProto_Builder*) builder;
+ (UserCityExpansionDataProto_Builder*) builderWithPrototype:(UserCityExpansionDataProto*) prototype;
- (UserCityExpansionDataProto_Builder*) toBuilder;

+ (UserCityExpansionDataProto*) parseFromData:(NSData*) data;
+ (UserCityExpansionDataProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserCityExpansionDataProto*) parseFromInputStream:(NSInputStream*) input;
+ (UserCityExpansionDataProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserCityExpansionDataProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (UserCityExpansionDataProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface UserCityExpansionDataProto_Builder : PBGeneratedMessageBuilder {
@private
  UserCityExpansionDataProto* result;
}

- (UserCityExpansionDataProto*) defaultInstance;

- (UserCityExpansionDataProto_Builder*) clear;
- (UserCityExpansionDataProto_Builder*) clone;

- (UserCityExpansionDataProto*) build;
- (UserCityExpansionDataProto*) buildPartial;

- (UserCityExpansionDataProto_Builder*) mergeFrom:(UserCityExpansionDataProto*) other;
- (UserCityExpansionDataProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (UserCityExpansionDataProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasUserId;
- (int32_t) userId;
- (UserCityExpansionDataProto_Builder*) setUserId:(int32_t) value;
- (UserCityExpansionDataProto_Builder*) clearUserId;

- (BOOL) hasXPosition;
- (int32_t) xPosition;
- (UserCityExpansionDataProto_Builder*) setXPosition:(int32_t) value;
- (UserCityExpansionDataProto_Builder*) clearXPosition;

- (BOOL) hasYPosition;
- (int32_t) yPosition;
- (UserCityExpansionDataProto_Builder*) setYPosition:(int32_t) value;
- (UserCityExpansionDataProto_Builder*) clearYPosition;

- (BOOL) hasIsExpanding;
- (BOOL) isExpanding;
- (UserCityExpansionDataProto_Builder*) setIsExpanding:(BOOL) value;
- (UserCityExpansionDataProto_Builder*) clearIsExpanding;

- (BOOL) hasExpandStartTime;
- (int64_t) expandStartTime;
- (UserCityExpansionDataProto_Builder*) setExpandStartTime:(int64_t) value;
- (UserCityExpansionDataProto_Builder*) clearExpandStartTime;
@end

@interface CityExpansionCostProto : PBGeneratedMessage {
@private
  BOOL hasExpansionNum_:1;
  BOOL hasExpansionCostCash_:1;
  BOOL hasNumMinutesToExpand_:1;
  int32_t expansionNum;
  int32_t expansionCostCash;
  int32_t numMinutesToExpand;
}
- (BOOL) hasExpansionNum;
- (BOOL) hasExpansionCostCash;
- (BOOL) hasNumMinutesToExpand;
@property (readonly) int32_t expansionNum;
@property (readonly) int32_t expansionCostCash;
@property (readonly) int32_t numMinutesToExpand;

+ (CityExpansionCostProto*) defaultInstance;
- (CityExpansionCostProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (CityExpansionCostProto_Builder*) builder;
+ (CityExpansionCostProto_Builder*) builder;
+ (CityExpansionCostProto_Builder*) builderWithPrototype:(CityExpansionCostProto*) prototype;
- (CityExpansionCostProto_Builder*) toBuilder;

+ (CityExpansionCostProto*) parseFromData:(NSData*) data;
+ (CityExpansionCostProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CityExpansionCostProto*) parseFromInputStream:(NSInputStream*) input;
+ (CityExpansionCostProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CityExpansionCostProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (CityExpansionCostProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface CityExpansionCostProto_Builder : PBGeneratedMessageBuilder {
@private
  CityExpansionCostProto* result;
}

- (CityExpansionCostProto*) defaultInstance;

- (CityExpansionCostProto_Builder*) clear;
- (CityExpansionCostProto_Builder*) clone;

- (CityExpansionCostProto*) build;
- (CityExpansionCostProto*) buildPartial;

- (CityExpansionCostProto_Builder*) mergeFrom:(CityExpansionCostProto*) other;
- (CityExpansionCostProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (CityExpansionCostProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasExpansionNum;
- (int32_t) expansionNum;
- (CityExpansionCostProto_Builder*) setExpansionNum:(int32_t) value;
- (CityExpansionCostProto_Builder*) clearExpansionNum;

- (BOOL) hasExpansionCostCash;
- (int32_t) expansionCostCash;
- (CityExpansionCostProto_Builder*) setExpansionCostCash:(int32_t) value;
- (CityExpansionCostProto_Builder*) clearExpansionCostCash;

- (BOOL) hasNumMinutesToExpand;
- (int32_t) numMinutesToExpand;
- (CityExpansionCostProto_Builder*) setNumMinutesToExpand:(int32_t) value;
- (CityExpansionCostProto_Builder*) clearNumMinutesToExpand;
@end

@interface CityElementProto : PBGeneratedMessage {
@private
  BOOL hasXLength_:1;
  BOOL hasYLength_:1;
  BOOL hasCityId_:1;
  BOOL hasAssetId_:1;
  BOOL hasImgId_:1;
  BOOL hasCoords_:1;
  BOOL hasSpriteCoords_:1;
  BOOL hasType_:1;
  BOOL hasOrientation_:1;
  Float32 xLength;
  Float32 yLength;
  int32_t cityId;
  int32_t assetId;
  NSString* imgId;
  CoordinateProto* coords;
  CoordinateProto* spriteCoords;
  CityElementProto_CityElemType type;
  StructOrientation orientation;
}
- (BOOL) hasCityId;
- (BOOL) hasAssetId;
- (BOOL) hasType;
- (BOOL) hasCoords;
- (BOOL) hasXLength;
- (BOOL) hasYLength;
- (BOOL) hasImgId;
- (BOOL) hasOrientation;
- (BOOL) hasSpriteCoords;
@property (readonly) int32_t cityId;
@property (readonly) int32_t assetId;
@property (readonly) CityElementProto_CityElemType type;
@property (readonly, strong) CoordinateProto* coords;
@property (readonly) Float32 xLength;
@property (readonly) Float32 yLength;
@property (readonly, strong) NSString* imgId;
@property (readonly) StructOrientation orientation;
@property (readonly, strong) CoordinateProto* spriteCoords;

+ (CityElementProto*) defaultInstance;
- (CityElementProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (CityElementProto_Builder*) builder;
+ (CityElementProto_Builder*) builder;
+ (CityElementProto_Builder*) builderWithPrototype:(CityElementProto*) prototype;
- (CityElementProto_Builder*) toBuilder;

+ (CityElementProto*) parseFromData:(NSData*) data;
+ (CityElementProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CityElementProto*) parseFromInputStream:(NSInputStream*) input;
+ (CityElementProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CityElementProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (CityElementProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface CityElementProto_Builder : PBGeneratedMessageBuilder {
@private
  CityElementProto* result;
}

- (CityElementProto*) defaultInstance;

- (CityElementProto_Builder*) clear;
- (CityElementProto_Builder*) clone;

- (CityElementProto*) build;
- (CityElementProto*) buildPartial;

- (CityElementProto_Builder*) mergeFrom:(CityElementProto*) other;
- (CityElementProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (CityElementProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasCityId;
- (int32_t) cityId;
- (CityElementProto_Builder*) setCityId:(int32_t) value;
- (CityElementProto_Builder*) clearCityId;

- (BOOL) hasAssetId;
- (int32_t) assetId;
- (CityElementProto_Builder*) setAssetId:(int32_t) value;
- (CityElementProto_Builder*) clearAssetId;

- (BOOL) hasType;
- (CityElementProto_CityElemType) type;
- (CityElementProto_Builder*) setType:(CityElementProto_CityElemType) value;
- (CityElementProto_Builder*) clearType;

- (BOOL) hasCoords;
- (CoordinateProto*) coords;
- (CityElementProto_Builder*) setCoords:(CoordinateProto*) value;
- (CityElementProto_Builder*) setCoords_Builder:(CoordinateProto_Builder*) builderForValue;
- (CityElementProto_Builder*) mergeCoords:(CoordinateProto*) value;
- (CityElementProto_Builder*) clearCoords;

- (BOOL) hasXLength;
- (Float32) xLength;
- (CityElementProto_Builder*) setXLength:(Float32) value;
- (CityElementProto_Builder*) clearXLength;

- (BOOL) hasYLength;
- (Float32) yLength;
- (CityElementProto_Builder*) setYLength:(Float32) value;
- (CityElementProto_Builder*) clearYLength;

- (BOOL) hasImgId;
- (NSString*) imgId;
- (CityElementProto_Builder*) setImgId:(NSString*) value;
- (CityElementProto_Builder*) clearImgId;

- (BOOL) hasOrientation;
- (StructOrientation) orientation;
- (CityElementProto_Builder*) setOrientation:(StructOrientation) value;
- (CityElementProto_Builder*) clearOrientation;

- (BOOL) hasSpriteCoords;
- (CoordinateProto*) spriteCoords;
- (CityElementProto_Builder*) setSpriteCoords:(CoordinateProto*) value;
- (CityElementProto_Builder*) setSpriteCoords_Builder:(CoordinateProto_Builder*) builderForValue;
- (CityElementProto_Builder*) mergeSpriteCoords:(CoordinateProto*) value;
- (CityElementProto_Builder*) clearSpriteCoords;
@end

@interface FullCityProto : PBGeneratedMessage {
@private
  BOOL hasCityId_:1;
  BOOL hasName_:1;
  BOOL hasMapImgName_:1;
  BOOL hasRoadImgName_:1;
  BOOL hasMapTmxName_:1;
  BOOL hasAttackMapLabelImgName_:1;
  BOOL hasCenter_:1;
  BOOL hasRoadImgCoords_:1;
  int32_t cityId;
  NSString* name;
  NSString* mapImgName;
  NSString* roadImgName;
  NSString* mapTmxName;
  NSString* attackMapLabelImgName;
  CoordinateProto* center;
  CoordinateProto* roadImgCoords;
  PBAppendableArray * mutableTaskIdsList;
}
- (BOOL) hasCityId;
- (BOOL) hasName;
- (BOOL) hasMapImgName;
- (BOOL) hasCenter;
- (BOOL) hasRoadImgName;
- (BOOL) hasMapTmxName;
- (BOOL) hasRoadImgCoords;
- (BOOL) hasAttackMapLabelImgName;
@property (readonly) int32_t cityId;
@property (readonly, strong) NSString* name;
@property (readonly, strong) NSString* mapImgName;
@property (readonly, strong) CoordinateProto* center;
@property (readonly, strong) NSString* roadImgName;
@property (readonly, strong) NSString* mapTmxName;
@property (readonly, strong) CoordinateProto* roadImgCoords;
@property (readonly, strong) PBArray * taskIdsList;
@property (readonly, strong) NSString* attackMapLabelImgName;
- (int32_t)taskIdsAtIndex:(NSUInteger)index;

+ (FullCityProto*) defaultInstance;
- (FullCityProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (FullCityProto_Builder*) builder;
+ (FullCityProto_Builder*) builder;
+ (FullCityProto_Builder*) builderWithPrototype:(FullCityProto*) prototype;
- (FullCityProto_Builder*) toBuilder;

+ (FullCityProto*) parseFromData:(NSData*) data;
+ (FullCityProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FullCityProto*) parseFromInputStream:(NSInputStream*) input;
+ (FullCityProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FullCityProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (FullCityProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface FullCityProto_Builder : PBGeneratedMessageBuilder {
@private
  FullCityProto* result;
}

- (FullCityProto*) defaultInstance;

- (FullCityProto_Builder*) clear;
- (FullCityProto_Builder*) clone;

- (FullCityProto*) build;
- (FullCityProto*) buildPartial;

- (FullCityProto_Builder*) mergeFrom:(FullCityProto*) other;
- (FullCityProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (FullCityProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasCityId;
- (int32_t) cityId;
- (FullCityProto_Builder*) setCityId:(int32_t) value;
- (FullCityProto_Builder*) clearCityId;

- (BOOL) hasName;
- (NSString*) name;
- (FullCityProto_Builder*) setName:(NSString*) value;
- (FullCityProto_Builder*) clearName;

- (BOOL) hasMapImgName;
- (NSString*) mapImgName;
- (FullCityProto_Builder*) setMapImgName:(NSString*) value;
- (FullCityProto_Builder*) clearMapImgName;

- (BOOL) hasCenter;
- (CoordinateProto*) center;
- (FullCityProto_Builder*) setCenter:(CoordinateProto*) value;
- (FullCityProto_Builder*) setCenter_Builder:(CoordinateProto_Builder*) builderForValue;
- (FullCityProto_Builder*) mergeCenter:(CoordinateProto*) value;
- (FullCityProto_Builder*) clearCenter;

- (BOOL) hasRoadImgName;
- (NSString*) roadImgName;
- (FullCityProto_Builder*) setRoadImgName:(NSString*) value;
- (FullCityProto_Builder*) clearRoadImgName;

- (BOOL) hasMapTmxName;
- (NSString*) mapTmxName;
- (FullCityProto_Builder*) setMapTmxName:(NSString*) value;
- (FullCityProto_Builder*) clearMapTmxName;

- (BOOL) hasRoadImgCoords;
- (CoordinateProto*) roadImgCoords;
- (FullCityProto_Builder*) setRoadImgCoords:(CoordinateProto*) value;
- (FullCityProto_Builder*) setRoadImgCoords_Builder:(CoordinateProto_Builder*) builderForValue;
- (FullCityProto_Builder*) mergeRoadImgCoords:(CoordinateProto*) value;
- (FullCityProto_Builder*) clearRoadImgCoords;

- (PBAppendableArray *)taskIdsList;
- (int32_t)taskIdsAtIndex:(NSUInteger)index;
- (FullCityProto_Builder *)addTaskIds:(int32_t)value;
- (FullCityProto_Builder *)addAllTaskIds:(NSArray *)array;
- (FullCityProto_Builder *)setTaskIdsValues:(const int32_t *)values count:(NSUInteger)count;
- (FullCityProto_Builder *)clearTaskIds;

- (BOOL) hasAttackMapLabelImgName;
- (NSString*) attackMapLabelImgName;
- (FullCityProto_Builder*) setAttackMapLabelImgName:(NSString*) value;
- (FullCityProto_Builder*) clearAttackMapLabelImgName;
@end


// @@protoc_insertion_point(global_scope)
