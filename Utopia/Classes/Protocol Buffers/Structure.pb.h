// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

@class CoordinateProto;
@class CoordinateProto_Builder;
@class FullUserStructureProto;
@class FullUserStructureProto_Builder;
@class HospitalProto;
@class HospitalProto_Builder;
@class LabProto;
@class LabProto_Builder;
@class ResidenceProto;
@class ResidenceProto_Builder;
@class ResourceGeneratorProto;
@class ResourceGeneratorProto_Builder;
@class ResourceStorageProto;
@class ResourceStorageProto_Builder;
@class StructureInfoProto;
@class StructureInfoProto_Builder;
@class TownHallProto;
@class TownHallProto_Builder;
@class TutorialStructProto;
@class TutorialStructProto_Builder;
typedef enum {
  ResourceTypeCash = 1,
  ResourceTypeOil = 2,
  ResourceTypeGems = 3,
  ResourceTypeMonster = 20,
} ResourceType;

BOOL ResourceTypeIsValidValue(ResourceType value);

typedef enum {
  StructOrientationPosition1 = 1,
  StructOrientationPosition2 = 2,
} StructOrientation;

BOOL StructOrientationIsValidValue(StructOrientation value);

typedef enum {
  StructureInfoProto_StructTypeResourceGenerator = 1,
  StructureInfoProto_StructTypeResourceStorage = 2,
  StructureInfoProto_StructTypeHospital = 3,
  StructureInfoProto_StructTypeResidence = 4,
  StructureInfoProto_StructTypeTownHall = 5,
  StructureInfoProto_StructTypeLab = 6,
  StructureInfoProto_StructTypeEvo = 7,
} StructureInfoProto_StructType;

BOOL StructureInfoProto_StructTypeIsValidValue(StructureInfoProto_StructType value);


@interface StructureRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface StructureInfoProto : PBGeneratedMessage {
@private
  BOOL hasImgVerticalPixelOffset_:1;
  BOOL hasStructId_:1;
  BOOL hasLevel_:1;
  BOOL hasBuildCost_:1;
  BOOL hasMinutesToBuild_:1;
  BOOL hasPrerequisiteTownHallLvl_:1;
  BOOL hasWidth_:1;
  BOOL hasHeight_:1;
  BOOL hasPredecessorStructId_:1;
  BOOL hasSuccessorStructId_:1;
  BOOL hasName_:1;
  BOOL hasImgName_:1;
  BOOL hasDescription_:1;
  BOOL hasShortDescription_:1;
  BOOL hasStructType_:1;
  BOOL hasBuildResourceType_:1;
  Float32 imgVerticalPixelOffset;
  int32_t structId;
  int32_t level;
  int32_t buildCost;
  int32_t minutesToBuild;
  int32_t prerequisiteTownHallLvl;
  int32_t width;
  int32_t height;
  int32_t predecessorStructId;
  int32_t successorStructId;
  NSString* name;
  NSString* imgName;
  NSString* description;
  NSString* shortDescription;
  StructureInfoProto_StructType structType;
  ResourceType buildResourceType;
}
- (BOOL) hasStructId;
- (BOOL) hasName;
- (BOOL) hasLevel;
- (BOOL) hasStructType;
- (BOOL) hasBuildResourceType;
- (BOOL) hasBuildCost;
- (BOOL) hasMinutesToBuild;
- (BOOL) hasPrerequisiteTownHallLvl;
- (BOOL) hasWidth;
- (BOOL) hasHeight;
- (BOOL) hasPredecessorStructId;
- (BOOL) hasSuccessorStructId;
- (BOOL) hasImgName;
- (BOOL) hasImgVerticalPixelOffset;
- (BOOL) hasDescription;
- (BOOL) hasShortDescription;
@property (readonly) int32_t structId;
@property (readonly, retain) NSString* name;
@property (readonly) int32_t level;
@property (readonly) StructureInfoProto_StructType structType;
@property (readonly) ResourceType buildResourceType;
@property (readonly) int32_t buildCost;
@property (readonly) int32_t minutesToBuild;
@property (readonly) int32_t prerequisiteTownHallLvl;
@property (readonly) int32_t width;
@property (readonly) int32_t height;
@property (readonly) int32_t predecessorStructId;
@property (readonly) int32_t successorStructId;
@property (readonly, retain) NSString* imgName;
@property (readonly) Float32 imgVerticalPixelOffset;
@property (readonly, retain) NSString* description;
@property (readonly, retain) NSString* shortDescription;

+ (StructureInfoProto*) defaultInstance;
- (StructureInfoProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (StructureInfoProto_Builder*) builder;
+ (StructureInfoProto_Builder*) builder;
+ (StructureInfoProto_Builder*) builderWithPrototype:(StructureInfoProto*) prototype;

+ (StructureInfoProto*) parseFromData:(NSData*) data;
+ (StructureInfoProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (StructureInfoProto*) parseFromInputStream:(NSInputStream*) input;
+ (StructureInfoProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (StructureInfoProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (StructureInfoProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface StructureInfoProto_Builder : PBGeneratedMessage_Builder {
@private
  StructureInfoProto* result;
}

- (StructureInfoProto*) defaultInstance;

- (StructureInfoProto_Builder*) clear;
- (StructureInfoProto_Builder*) clone;

- (StructureInfoProto*) build;
- (StructureInfoProto*) buildPartial;

- (StructureInfoProto_Builder*) mergeFrom:(StructureInfoProto*) other;
- (StructureInfoProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (StructureInfoProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasStructId;
- (int32_t) structId;
- (StructureInfoProto_Builder*) setStructId:(int32_t) value;
- (StructureInfoProto_Builder*) clearStructId;

- (BOOL) hasName;
- (NSString*) name;
- (StructureInfoProto_Builder*) setName:(NSString*) value;
- (StructureInfoProto_Builder*) clearName;

- (BOOL) hasLevel;
- (int32_t) level;
- (StructureInfoProto_Builder*) setLevel:(int32_t) value;
- (StructureInfoProto_Builder*) clearLevel;

- (BOOL) hasStructType;
- (StructureInfoProto_StructType) structType;
- (StructureInfoProto_Builder*) setStructType:(StructureInfoProto_StructType) value;
- (StructureInfoProto_Builder*) clearStructType;

- (BOOL) hasBuildResourceType;
- (ResourceType) buildResourceType;
- (StructureInfoProto_Builder*) setBuildResourceType:(ResourceType) value;
- (StructureInfoProto_Builder*) clearBuildResourceType;

- (BOOL) hasBuildCost;
- (int32_t) buildCost;
- (StructureInfoProto_Builder*) setBuildCost:(int32_t) value;
- (StructureInfoProto_Builder*) clearBuildCost;

- (BOOL) hasMinutesToBuild;
- (int32_t) minutesToBuild;
- (StructureInfoProto_Builder*) setMinutesToBuild:(int32_t) value;
- (StructureInfoProto_Builder*) clearMinutesToBuild;

- (BOOL) hasPrerequisiteTownHallLvl;
- (int32_t) prerequisiteTownHallLvl;
- (StructureInfoProto_Builder*) setPrerequisiteTownHallLvl:(int32_t) value;
- (StructureInfoProto_Builder*) clearPrerequisiteTownHallLvl;

- (BOOL) hasWidth;
- (int32_t) width;
- (StructureInfoProto_Builder*) setWidth:(int32_t) value;
- (StructureInfoProto_Builder*) clearWidth;

- (BOOL) hasHeight;
- (int32_t) height;
- (StructureInfoProto_Builder*) setHeight:(int32_t) value;
- (StructureInfoProto_Builder*) clearHeight;

- (BOOL) hasPredecessorStructId;
- (int32_t) predecessorStructId;
- (StructureInfoProto_Builder*) setPredecessorStructId:(int32_t) value;
- (StructureInfoProto_Builder*) clearPredecessorStructId;

- (BOOL) hasSuccessorStructId;
- (int32_t) successorStructId;
- (StructureInfoProto_Builder*) setSuccessorStructId:(int32_t) value;
- (StructureInfoProto_Builder*) clearSuccessorStructId;

- (BOOL) hasImgName;
- (NSString*) imgName;
- (StructureInfoProto_Builder*) setImgName:(NSString*) value;
- (StructureInfoProto_Builder*) clearImgName;

- (BOOL) hasImgVerticalPixelOffset;
- (Float32) imgVerticalPixelOffset;
- (StructureInfoProto_Builder*) setImgVerticalPixelOffset:(Float32) value;
- (StructureInfoProto_Builder*) clearImgVerticalPixelOffset;

- (BOOL) hasDescription;
- (NSString*) description;
- (StructureInfoProto_Builder*) setDescription:(NSString*) value;
- (StructureInfoProto_Builder*) clearDescription;

- (BOOL) hasShortDescription;
- (NSString*) shortDescription;
- (StructureInfoProto_Builder*) setShortDescription:(NSString*) value;
- (StructureInfoProto_Builder*) clearShortDescription;
@end

@interface ResourceGeneratorProto : PBGeneratedMessage {
@private
  BOOL hasProductionRate_:1;
  BOOL hasCapacity_:1;
  BOOL hasStructInfo_:1;
  BOOL hasResourceType_:1;
  Float32 productionRate;
  int32_t capacity;
  StructureInfoProto* structInfo;
  ResourceType resourceType;
}
- (BOOL) hasStructInfo;
- (BOOL) hasResourceType;
- (BOOL) hasProductionRate;
- (BOOL) hasCapacity;
@property (readonly, retain) StructureInfoProto* structInfo;
@property (readonly) ResourceType resourceType;
@property (readonly) Float32 productionRate;
@property (readonly) int32_t capacity;

+ (ResourceGeneratorProto*) defaultInstance;
- (ResourceGeneratorProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (ResourceGeneratorProto_Builder*) builder;
+ (ResourceGeneratorProto_Builder*) builder;
+ (ResourceGeneratorProto_Builder*) builderWithPrototype:(ResourceGeneratorProto*) prototype;

+ (ResourceGeneratorProto*) parseFromData:(NSData*) data;
+ (ResourceGeneratorProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ResourceGeneratorProto*) parseFromInputStream:(NSInputStream*) input;
+ (ResourceGeneratorProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ResourceGeneratorProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (ResourceGeneratorProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface ResourceGeneratorProto_Builder : PBGeneratedMessage_Builder {
@private
  ResourceGeneratorProto* result;
}

- (ResourceGeneratorProto*) defaultInstance;

- (ResourceGeneratorProto_Builder*) clear;
- (ResourceGeneratorProto_Builder*) clone;

- (ResourceGeneratorProto*) build;
- (ResourceGeneratorProto*) buildPartial;

- (ResourceGeneratorProto_Builder*) mergeFrom:(ResourceGeneratorProto*) other;
- (ResourceGeneratorProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (ResourceGeneratorProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasStructInfo;
- (StructureInfoProto*) structInfo;
- (ResourceGeneratorProto_Builder*) setStructInfo:(StructureInfoProto*) value;
- (ResourceGeneratorProto_Builder*) setStructInfoBuilder:(StructureInfoProto_Builder*) builderForValue;
- (ResourceGeneratorProto_Builder*) mergeStructInfo:(StructureInfoProto*) value;
- (ResourceGeneratorProto_Builder*) clearStructInfo;

- (BOOL) hasResourceType;
- (ResourceType) resourceType;
- (ResourceGeneratorProto_Builder*) setResourceType:(ResourceType) value;
- (ResourceGeneratorProto_Builder*) clearResourceType;

- (BOOL) hasProductionRate;
- (Float32) productionRate;
- (ResourceGeneratorProto_Builder*) setProductionRate:(Float32) value;
- (ResourceGeneratorProto_Builder*) clearProductionRate;

- (BOOL) hasCapacity;
- (int32_t) capacity;
- (ResourceGeneratorProto_Builder*) setCapacity:(int32_t) value;
- (ResourceGeneratorProto_Builder*) clearCapacity;
@end

@interface ResourceStorageProto : PBGeneratedMessage {
@private
  BOOL hasCapacity_:1;
  BOOL hasStructInfo_:1;
  BOOL hasResourceType_:1;
  int32_t capacity;
  StructureInfoProto* structInfo;
  ResourceType resourceType;
}
- (BOOL) hasStructInfo;
- (BOOL) hasResourceType;
- (BOOL) hasCapacity;
@property (readonly, retain) StructureInfoProto* structInfo;
@property (readonly) ResourceType resourceType;
@property (readonly) int32_t capacity;

+ (ResourceStorageProto*) defaultInstance;
- (ResourceStorageProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (ResourceStorageProto_Builder*) builder;
+ (ResourceStorageProto_Builder*) builder;
+ (ResourceStorageProto_Builder*) builderWithPrototype:(ResourceStorageProto*) prototype;

+ (ResourceStorageProto*) parseFromData:(NSData*) data;
+ (ResourceStorageProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ResourceStorageProto*) parseFromInputStream:(NSInputStream*) input;
+ (ResourceStorageProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ResourceStorageProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (ResourceStorageProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface ResourceStorageProto_Builder : PBGeneratedMessage_Builder {
@private
  ResourceStorageProto* result;
}

- (ResourceStorageProto*) defaultInstance;

- (ResourceStorageProto_Builder*) clear;
- (ResourceStorageProto_Builder*) clone;

- (ResourceStorageProto*) build;
- (ResourceStorageProto*) buildPartial;

- (ResourceStorageProto_Builder*) mergeFrom:(ResourceStorageProto*) other;
- (ResourceStorageProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (ResourceStorageProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasStructInfo;
- (StructureInfoProto*) structInfo;
- (ResourceStorageProto_Builder*) setStructInfo:(StructureInfoProto*) value;
- (ResourceStorageProto_Builder*) setStructInfoBuilder:(StructureInfoProto_Builder*) builderForValue;
- (ResourceStorageProto_Builder*) mergeStructInfo:(StructureInfoProto*) value;
- (ResourceStorageProto_Builder*) clearStructInfo;

- (BOOL) hasResourceType;
- (ResourceType) resourceType;
- (ResourceStorageProto_Builder*) setResourceType:(ResourceType) value;
- (ResourceStorageProto_Builder*) clearResourceType;

- (BOOL) hasCapacity;
- (int32_t) capacity;
- (ResourceStorageProto_Builder*) setCapacity:(int32_t) value;
- (ResourceStorageProto_Builder*) clearCapacity;
@end

@interface HospitalProto : PBGeneratedMessage {
@private
  BOOL hasHealthPerSecond_:1;
  BOOL hasQueueSize_:1;
  BOOL hasStructInfo_:1;
  Float32 healthPerSecond;
  int32_t queueSize;
  StructureInfoProto* structInfo;
}
- (BOOL) hasStructInfo;
- (BOOL) hasQueueSize;
- (BOOL) hasHealthPerSecond;
@property (readonly, retain) StructureInfoProto* structInfo;
@property (readonly) int32_t queueSize;
@property (readonly) Float32 healthPerSecond;

+ (HospitalProto*) defaultInstance;
- (HospitalProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (HospitalProto_Builder*) builder;
+ (HospitalProto_Builder*) builder;
+ (HospitalProto_Builder*) builderWithPrototype:(HospitalProto*) prototype;

+ (HospitalProto*) parseFromData:(NSData*) data;
+ (HospitalProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (HospitalProto*) parseFromInputStream:(NSInputStream*) input;
+ (HospitalProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (HospitalProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (HospitalProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface HospitalProto_Builder : PBGeneratedMessage_Builder {
@private
  HospitalProto* result;
}

- (HospitalProto*) defaultInstance;

- (HospitalProto_Builder*) clear;
- (HospitalProto_Builder*) clone;

- (HospitalProto*) build;
- (HospitalProto*) buildPartial;

- (HospitalProto_Builder*) mergeFrom:(HospitalProto*) other;
- (HospitalProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (HospitalProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasStructInfo;
- (StructureInfoProto*) structInfo;
- (HospitalProto_Builder*) setStructInfo:(StructureInfoProto*) value;
- (HospitalProto_Builder*) setStructInfoBuilder:(StructureInfoProto_Builder*) builderForValue;
- (HospitalProto_Builder*) mergeStructInfo:(StructureInfoProto*) value;
- (HospitalProto_Builder*) clearStructInfo;

- (BOOL) hasQueueSize;
- (int32_t) queueSize;
- (HospitalProto_Builder*) setQueueSize:(int32_t) value;
- (HospitalProto_Builder*) clearQueueSize;

- (BOOL) hasHealthPerSecond;
- (Float32) healthPerSecond;
- (HospitalProto_Builder*) setHealthPerSecond:(Float32) value;
- (HospitalProto_Builder*) clearHealthPerSecond;
@end

@interface LabProto : PBGeneratedMessage {
@private
  BOOL hasPointsPerSecond_:1;
  BOOL hasQueueSize_:1;
  BOOL hasStructInfo_:1;
  Float32 pointsPerSecond;
  int32_t queueSize;
  StructureInfoProto* structInfo;
}
- (BOOL) hasStructInfo;
- (BOOL) hasQueueSize;
- (BOOL) hasPointsPerSecond;
@property (readonly, retain) StructureInfoProto* structInfo;
@property (readonly) int32_t queueSize;
@property (readonly) Float32 pointsPerSecond;

+ (LabProto*) defaultInstance;
- (LabProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (LabProto_Builder*) builder;
+ (LabProto_Builder*) builder;
+ (LabProto_Builder*) builderWithPrototype:(LabProto*) prototype;

+ (LabProto*) parseFromData:(NSData*) data;
+ (LabProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (LabProto*) parseFromInputStream:(NSInputStream*) input;
+ (LabProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (LabProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (LabProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface LabProto_Builder : PBGeneratedMessage_Builder {
@private
  LabProto* result;
}

- (LabProto*) defaultInstance;

- (LabProto_Builder*) clear;
- (LabProto_Builder*) clone;

- (LabProto*) build;
- (LabProto*) buildPartial;

- (LabProto_Builder*) mergeFrom:(LabProto*) other;
- (LabProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (LabProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasStructInfo;
- (StructureInfoProto*) structInfo;
- (LabProto_Builder*) setStructInfo:(StructureInfoProto*) value;
- (LabProto_Builder*) setStructInfoBuilder:(StructureInfoProto_Builder*) builderForValue;
- (LabProto_Builder*) mergeStructInfo:(StructureInfoProto*) value;
- (LabProto_Builder*) clearStructInfo;

- (BOOL) hasQueueSize;
- (int32_t) queueSize;
- (LabProto_Builder*) setQueueSize:(int32_t) value;
- (LabProto_Builder*) clearQueueSize;

- (BOOL) hasPointsPerSecond;
- (Float32) pointsPerSecond;
- (LabProto_Builder*) setPointsPerSecond:(Float32) value;
- (LabProto_Builder*) clearPointsPerSecond;
@end

@interface ResidenceProto : PBGeneratedMessage {
@private
  BOOL hasNumMonsterSlots_:1;
  BOOL hasNumBonusMonsterSlots_:1;
  BOOL hasNumGemsRequired_:1;
  BOOL hasNumAcceptedFbInvites_:1;
  BOOL hasOccupationName_:1;
  BOOL hasStructInfo_:1;
  int32_t numMonsterSlots;
  int32_t numBonusMonsterSlots;
  int32_t numGemsRequired;
  int32_t numAcceptedFbInvites;
  NSString* occupationName;
  StructureInfoProto* structInfo;
}
- (BOOL) hasStructInfo;
- (BOOL) hasNumMonsterSlots;
- (BOOL) hasNumBonusMonsterSlots;
- (BOOL) hasNumGemsRequired;
- (BOOL) hasNumAcceptedFbInvites;
- (BOOL) hasOccupationName;
@property (readonly, retain) StructureInfoProto* structInfo;
@property (readonly) int32_t numMonsterSlots;
@property (readonly) int32_t numBonusMonsterSlots;
@property (readonly) int32_t numGemsRequired;
@property (readonly) int32_t numAcceptedFbInvites;
@property (readonly, retain) NSString* occupationName;

+ (ResidenceProto*) defaultInstance;
- (ResidenceProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (ResidenceProto_Builder*) builder;
+ (ResidenceProto_Builder*) builder;
+ (ResidenceProto_Builder*) builderWithPrototype:(ResidenceProto*) prototype;

+ (ResidenceProto*) parseFromData:(NSData*) data;
+ (ResidenceProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ResidenceProto*) parseFromInputStream:(NSInputStream*) input;
+ (ResidenceProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ResidenceProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (ResidenceProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface ResidenceProto_Builder : PBGeneratedMessage_Builder {
@private
  ResidenceProto* result;
}

- (ResidenceProto*) defaultInstance;

- (ResidenceProto_Builder*) clear;
- (ResidenceProto_Builder*) clone;

- (ResidenceProto*) build;
- (ResidenceProto*) buildPartial;

- (ResidenceProto_Builder*) mergeFrom:(ResidenceProto*) other;
- (ResidenceProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (ResidenceProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasStructInfo;
- (StructureInfoProto*) structInfo;
- (ResidenceProto_Builder*) setStructInfo:(StructureInfoProto*) value;
- (ResidenceProto_Builder*) setStructInfoBuilder:(StructureInfoProto_Builder*) builderForValue;
- (ResidenceProto_Builder*) mergeStructInfo:(StructureInfoProto*) value;
- (ResidenceProto_Builder*) clearStructInfo;

- (BOOL) hasNumMonsterSlots;
- (int32_t) numMonsterSlots;
- (ResidenceProto_Builder*) setNumMonsterSlots:(int32_t) value;
- (ResidenceProto_Builder*) clearNumMonsterSlots;

- (BOOL) hasNumBonusMonsterSlots;
- (int32_t) numBonusMonsterSlots;
- (ResidenceProto_Builder*) setNumBonusMonsterSlots:(int32_t) value;
- (ResidenceProto_Builder*) clearNumBonusMonsterSlots;

- (BOOL) hasNumGemsRequired;
- (int32_t) numGemsRequired;
- (ResidenceProto_Builder*) setNumGemsRequired:(int32_t) value;
- (ResidenceProto_Builder*) clearNumGemsRequired;

- (BOOL) hasNumAcceptedFbInvites;
- (int32_t) numAcceptedFbInvites;
- (ResidenceProto_Builder*) setNumAcceptedFbInvites:(int32_t) value;
- (ResidenceProto_Builder*) clearNumAcceptedFbInvites;

- (BOOL) hasOccupationName;
- (NSString*) occupationName;
- (ResidenceProto_Builder*) setOccupationName:(NSString*) value;
- (ResidenceProto_Builder*) clearOccupationName;
@end

@interface TownHallProto : PBGeneratedMessage {
@private
  BOOL hasNumResourceOneGenerators_:1;
  BOOL hasNumResourceOneStorages_:1;
  BOOL hasNumResourceTwoGenerators_:1;
  BOOL hasNumResourceTwoStorages_:1;
  BOOL hasNumHospitals_:1;
  BOOL hasNumResidences_:1;
  BOOL hasNumMonsterSlots_:1;
  BOOL hasNumLabs_:1;
  BOOL hasPvpQueueCashCost_:1;
  BOOL hasResourceCapacity_:1;
  BOOL hasStructInfo_:1;
  int32_t numResourceOneGenerators;
  int32_t numResourceOneStorages;
  int32_t numResourceTwoGenerators;
  int32_t numResourceTwoStorages;
  int32_t numHospitals;
  int32_t numResidences;
  int32_t numMonsterSlots;
  int32_t numLabs;
  int32_t pvpQueueCashCost;
  int32_t resourceCapacity;
  StructureInfoProto* structInfo;
}
- (BOOL) hasStructInfo;
- (BOOL) hasNumResourceOneGenerators;
- (BOOL) hasNumResourceOneStorages;
- (BOOL) hasNumResourceTwoGenerators;
- (BOOL) hasNumResourceTwoStorages;
- (BOOL) hasNumHospitals;
- (BOOL) hasNumResidences;
- (BOOL) hasNumMonsterSlots;
- (BOOL) hasNumLabs;
- (BOOL) hasPvpQueueCashCost;
- (BOOL) hasResourceCapacity;
@property (readonly, retain) StructureInfoProto* structInfo;
@property (readonly) int32_t numResourceOneGenerators;
@property (readonly) int32_t numResourceOneStorages;
@property (readonly) int32_t numResourceTwoGenerators;
@property (readonly) int32_t numResourceTwoStorages;
@property (readonly) int32_t numHospitals;
@property (readonly) int32_t numResidences;
@property (readonly) int32_t numMonsterSlots;
@property (readonly) int32_t numLabs;
@property (readonly) int32_t pvpQueueCashCost;
@property (readonly) int32_t resourceCapacity;

+ (TownHallProto*) defaultInstance;
- (TownHallProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (TownHallProto_Builder*) builder;
+ (TownHallProto_Builder*) builder;
+ (TownHallProto_Builder*) builderWithPrototype:(TownHallProto*) prototype;

+ (TownHallProto*) parseFromData:(NSData*) data;
+ (TownHallProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (TownHallProto*) parseFromInputStream:(NSInputStream*) input;
+ (TownHallProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (TownHallProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (TownHallProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface TownHallProto_Builder : PBGeneratedMessage_Builder {
@private
  TownHallProto* result;
}

- (TownHallProto*) defaultInstance;

- (TownHallProto_Builder*) clear;
- (TownHallProto_Builder*) clone;

- (TownHallProto*) build;
- (TownHallProto*) buildPartial;

- (TownHallProto_Builder*) mergeFrom:(TownHallProto*) other;
- (TownHallProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (TownHallProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasStructInfo;
- (StructureInfoProto*) structInfo;
- (TownHallProto_Builder*) setStructInfo:(StructureInfoProto*) value;
- (TownHallProto_Builder*) setStructInfoBuilder:(StructureInfoProto_Builder*) builderForValue;
- (TownHallProto_Builder*) mergeStructInfo:(StructureInfoProto*) value;
- (TownHallProto_Builder*) clearStructInfo;

- (BOOL) hasNumResourceOneGenerators;
- (int32_t) numResourceOneGenerators;
- (TownHallProto_Builder*) setNumResourceOneGenerators:(int32_t) value;
- (TownHallProto_Builder*) clearNumResourceOneGenerators;

- (BOOL) hasNumResourceOneStorages;
- (int32_t) numResourceOneStorages;
- (TownHallProto_Builder*) setNumResourceOneStorages:(int32_t) value;
- (TownHallProto_Builder*) clearNumResourceOneStorages;

- (BOOL) hasNumResourceTwoGenerators;
- (int32_t) numResourceTwoGenerators;
- (TownHallProto_Builder*) setNumResourceTwoGenerators:(int32_t) value;
- (TownHallProto_Builder*) clearNumResourceTwoGenerators;

- (BOOL) hasNumResourceTwoStorages;
- (int32_t) numResourceTwoStorages;
- (TownHallProto_Builder*) setNumResourceTwoStorages:(int32_t) value;
- (TownHallProto_Builder*) clearNumResourceTwoStorages;

- (BOOL) hasNumHospitals;
- (int32_t) numHospitals;
- (TownHallProto_Builder*) setNumHospitals:(int32_t) value;
- (TownHallProto_Builder*) clearNumHospitals;

- (BOOL) hasNumResidences;
- (int32_t) numResidences;
- (TownHallProto_Builder*) setNumResidences:(int32_t) value;
- (TownHallProto_Builder*) clearNumResidences;

- (BOOL) hasNumMonsterSlots;
- (int32_t) numMonsterSlots;
- (TownHallProto_Builder*) setNumMonsterSlots:(int32_t) value;
- (TownHallProto_Builder*) clearNumMonsterSlots;

- (BOOL) hasNumLabs;
- (int32_t) numLabs;
- (TownHallProto_Builder*) setNumLabs:(int32_t) value;
- (TownHallProto_Builder*) clearNumLabs;

- (BOOL) hasPvpQueueCashCost;
- (int32_t) pvpQueueCashCost;
- (TownHallProto_Builder*) setPvpQueueCashCost:(int32_t) value;
- (TownHallProto_Builder*) clearPvpQueueCashCost;

- (BOOL) hasResourceCapacity;
- (int32_t) resourceCapacity;
- (TownHallProto_Builder*) setResourceCapacity:(int32_t) value;
- (TownHallProto_Builder*) clearResourceCapacity;
@end

@interface FullUserStructureProto : PBGeneratedMessage {
@private
  BOOL hasIsComplete_:1;
  BOOL hasLastRetrieved_:1;
  BOOL hasPurchaseTime_:1;
  BOOL hasUserStructId_:1;
  BOOL hasUserId_:1;
  BOOL hasStructId_:1;
  BOOL hasFbInviteStructLvl_:1;
  BOOL hasCoordinates_:1;
  BOOL hasOrientation_:1;
  BOOL isComplete_:1;
  int64_t lastRetrieved;
  int64_t purchaseTime;
  int32_t userStructId;
  int32_t userId;
  int32_t structId;
  int32_t fbInviteStructLvl;
  CoordinateProto* coordinates;
  StructOrientation orientation;
}
- (BOOL) hasUserStructId;
- (BOOL) hasUserId;
- (BOOL) hasStructId;
- (BOOL) hasLastRetrieved;
- (BOOL) hasPurchaseTime;
- (BOOL) hasIsComplete;
- (BOOL) hasCoordinates;
- (BOOL) hasOrientation;
- (BOOL) hasFbInviteStructLvl;
@property (readonly) int32_t userStructId;
@property (readonly) int32_t userId;
@property (readonly) int32_t structId;
@property (readonly) int64_t lastRetrieved;
@property (readonly) int64_t purchaseTime;
- (BOOL) isComplete;
@property (readonly, retain) CoordinateProto* coordinates;
@property (readonly) StructOrientation orientation;
@property (readonly) int32_t fbInviteStructLvl;

+ (FullUserStructureProto*) defaultInstance;
- (FullUserStructureProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (FullUserStructureProto_Builder*) builder;
+ (FullUserStructureProto_Builder*) builder;
+ (FullUserStructureProto_Builder*) builderWithPrototype:(FullUserStructureProto*) prototype;

+ (FullUserStructureProto*) parseFromData:(NSData*) data;
+ (FullUserStructureProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FullUserStructureProto*) parseFromInputStream:(NSInputStream*) input;
+ (FullUserStructureProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FullUserStructureProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (FullUserStructureProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface FullUserStructureProto_Builder : PBGeneratedMessage_Builder {
@private
  FullUserStructureProto* result;
}

- (FullUserStructureProto*) defaultInstance;

- (FullUserStructureProto_Builder*) clear;
- (FullUserStructureProto_Builder*) clone;

- (FullUserStructureProto*) build;
- (FullUserStructureProto*) buildPartial;

- (FullUserStructureProto_Builder*) mergeFrom:(FullUserStructureProto*) other;
- (FullUserStructureProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (FullUserStructureProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasUserStructId;
- (int32_t) userStructId;
- (FullUserStructureProto_Builder*) setUserStructId:(int32_t) value;
- (FullUserStructureProto_Builder*) clearUserStructId;

- (BOOL) hasUserId;
- (int32_t) userId;
- (FullUserStructureProto_Builder*) setUserId:(int32_t) value;
- (FullUserStructureProto_Builder*) clearUserId;

- (BOOL) hasStructId;
- (int32_t) structId;
- (FullUserStructureProto_Builder*) setStructId:(int32_t) value;
- (FullUserStructureProto_Builder*) clearStructId;

- (BOOL) hasLastRetrieved;
- (int64_t) lastRetrieved;
- (FullUserStructureProto_Builder*) setLastRetrieved:(int64_t) value;
- (FullUserStructureProto_Builder*) clearLastRetrieved;

- (BOOL) hasPurchaseTime;
- (int64_t) purchaseTime;
- (FullUserStructureProto_Builder*) setPurchaseTime:(int64_t) value;
- (FullUserStructureProto_Builder*) clearPurchaseTime;

- (BOOL) hasIsComplete;
- (BOOL) isComplete;
- (FullUserStructureProto_Builder*) setIsComplete:(BOOL) value;
- (FullUserStructureProto_Builder*) clearIsComplete;

- (BOOL) hasCoordinates;
- (CoordinateProto*) coordinates;
- (FullUserStructureProto_Builder*) setCoordinates:(CoordinateProto*) value;
- (FullUserStructureProto_Builder*) setCoordinatesBuilder:(CoordinateProto_Builder*) builderForValue;
- (FullUserStructureProto_Builder*) mergeCoordinates:(CoordinateProto*) value;
- (FullUserStructureProto_Builder*) clearCoordinates;

- (BOOL) hasOrientation;
- (StructOrientation) orientation;
- (FullUserStructureProto_Builder*) setOrientation:(StructOrientation) value;
- (FullUserStructureProto_Builder*) clearOrientation;

- (BOOL) hasFbInviteStructLvl;
- (int32_t) fbInviteStructLvl;
- (FullUserStructureProto_Builder*) setFbInviteStructLvl:(int32_t) value;
- (FullUserStructureProto_Builder*) clearFbInviteStructLvl;
@end

@interface CoordinateProto : PBGeneratedMessage {
@private
  BOOL hasX_:1;
  BOOL hasY_:1;
  Float32 x;
  Float32 y;
}
- (BOOL) hasX;
- (BOOL) hasY;
@property (readonly) Float32 x;
@property (readonly) Float32 y;

+ (CoordinateProto*) defaultInstance;
- (CoordinateProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (CoordinateProto_Builder*) builder;
+ (CoordinateProto_Builder*) builder;
+ (CoordinateProto_Builder*) builderWithPrototype:(CoordinateProto*) prototype;

+ (CoordinateProto*) parseFromData:(NSData*) data;
+ (CoordinateProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CoordinateProto*) parseFromInputStream:(NSInputStream*) input;
+ (CoordinateProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CoordinateProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (CoordinateProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface CoordinateProto_Builder : PBGeneratedMessage_Builder {
@private
  CoordinateProto* result;
}

- (CoordinateProto*) defaultInstance;

- (CoordinateProto_Builder*) clear;
- (CoordinateProto_Builder*) clone;

- (CoordinateProto*) build;
- (CoordinateProto*) buildPartial;

- (CoordinateProto_Builder*) mergeFrom:(CoordinateProto*) other;
- (CoordinateProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (CoordinateProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasX;
- (Float32) x;
- (CoordinateProto_Builder*) setX:(Float32) value;
- (CoordinateProto_Builder*) clearX;

- (BOOL) hasY;
- (Float32) y;
- (CoordinateProto_Builder*) setY:(Float32) value;
- (CoordinateProto_Builder*) clearY;
@end

@interface TutorialStructProto : PBGeneratedMessage {
@private
  BOOL hasStructId_:1;
  BOOL hasCoordinate_:1;
  int32_t structId;
  CoordinateProto* coordinate;
}
- (BOOL) hasStructId;
- (BOOL) hasCoordinate;
@property (readonly) int32_t structId;
@property (readonly, retain) CoordinateProto* coordinate;

+ (TutorialStructProto*) defaultInstance;
- (TutorialStructProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (TutorialStructProto_Builder*) builder;
+ (TutorialStructProto_Builder*) builder;
+ (TutorialStructProto_Builder*) builderWithPrototype:(TutorialStructProto*) prototype;

+ (TutorialStructProto*) parseFromData:(NSData*) data;
+ (TutorialStructProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (TutorialStructProto*) parseFromInputStream:(NSInputStream*) input;
+ (TutorialStructProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (TutorialStructProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (TutorialStructProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface TutorialStructProto_Builder : PBGeneratedMessage_Builder {
@private
  TutorialStructProto* result;
}

- (TutorialStructProto*) defaultInstance;

- (TutorialStructProto_Builder*) clear;
- (TutorialStructProto_Builder*) clone;

- (TutorialStructProto*) build;
- (TutorialStructProto*) buildPartial;

- (TutorialStructProto_Builder*) mergeFrom:(TutorialStructProto*) other;
- (TutorialStructProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (TutorialStructProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasStructId;
- (int32_t) structId;
- (TutorialStructProto_Builder*) setStructId:(int32_t) value;
- (TutorialStructProto_Builder*) clearStructId;

- (BOOL) hasCoordinate;
- (CoordinateProto*) coordinate;
- (TutorialStructProto_Builder*) setCoordinate:(CoordinateProto*) value;
- (TutorialStructProto_Builder*) setCoordinateBuilder:(CoordinateProto_Builder*) builderForValue;
- (TutorialStructProto_Builder*) mergeCoordinate:(CoordinateProto*) value;
- (TutorialStructProto_Builder*) clearCoordinate;
@end

