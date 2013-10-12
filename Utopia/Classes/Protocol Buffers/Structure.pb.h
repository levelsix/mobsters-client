// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

@class CoordinateProto;
@class CoordinateProto_Builder;
@class FullStructureProto;
@class FullStructureProto_Builder;
@class FullUserStructureProto;
@class FullUserStructureProto_Builder;
typedef enum {
  StructOrientationPosition1 = 1,
  StructOrientationPosition2 = 2,
} StructOrientation;

BOOL StructOrientationIsValidValue(StructOrientation value);


@interface StructureRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface FullStructureProto : PBGeneratedMessage {
@private
  BOOL hasStructId_:1;
  BOOL hasIncome_:1;
  BOOL hasMinutesToGain_:1;
  BOOL hasMinutesToBuild_:1;
  BOOL hasMinutesToUpgradeBase_:1;
  BOOL hasCoinPrice_:1;
  BOOL hasDiamondPrice_:1;
  BOOL hasMinLevel_:1;
  BOOL hasXLength_:1;
  BOOL hasYLength_:1;
  BOOL hasInstaUpgradeDiamondCostBase_:1;
  BOOL hasImgVerticalPixelOffset_:1;
  BOOL hasName_:1;
  int32_t structId;
  int32_t income;
  int32_t minutesToGain;
  int32_t minutesToBuild;
  int32_t minutesToUpgradeBase;
  int32_t coinPrice;
  int32_t diamondPrice;
  int32_t minLevel;
  int32_t xLength;
  int32_t yLength;
  int32_t instaUpgradeDiamondCostBase;
  int32_t imgVerticalPixelOffset;
  NSString* name;
}
- (BOOL) hasStructId;
- (BOOL) hasName;
- (BOOL) hasIncome;
- (BOOL) hasMinutesToGain;
- (BOOL) hasMinutesToBuild;
- (BOOL) hasMinutesToUpgradeBase;
- (BOOL) hasCoinPrice;
- (BOOL) hasDiamondPrice;
- (BOOL) hasMinLevel;
- (BOOL) hasXLength;
- (BOOL) hasYLength;
- (BOOL) hasInstaUpgradeDiamondCostBase;
- (BOOL) hasImgVerticalPixelOffset;
@property (readonly) int32_t structId;
@property (readonly, retain) NSString* name;
@property (readonly) int32_t income;
@property (readonly) int32_t minutesToGain;
@property (readonly) int32_t minutesToBuild;
@property (readonly) int32_t minutesToUpgradeBase;
@property (readonly) int32_t coinPrice;
@property (readonly) int32_t diamondPrice;
@property (readonly) int32_t minLevel;
@property (readonly) int32_t xLength;
@property (readonly) int32_t yLength;
@property (readonly) int32_t instaUpgradeDiamondCostBase;
@property (readonly) int32_t imgVerticalPixelOffset;

+ (FullStructureProto*) defaultInstance;
- (FullStructureProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (FullStructureProto_Builder*) builder;
+ (FullStructureProto_Builder*) builder;
+ (FullStructureProto_Builder*) builderWithPrototype:(FullStructureProto*) prototype;

+ (FullStructureProto*) parseFromData:(NSData*) data;
+ (FullStructureProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FullStructureProto*) parseFromInputStream:(NSInputStream*) input;
+ (FullStructureProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FullStructureProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (FullStructureProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface FullStructureProto_Builder : PBGeneratedMessage_Builder {
@private
  FullStructureProto* result;
}

- (FullStructureProto*) defaultInstance;

- (FullStructureProto_Builder*) clear;
- (FullStructureProto_Builder*) clone;

- (FullStructureProto*) build;
- (FullStructureProto*) buildPartial;

- (FullStructureProto_Builder*) mergeFrom:(FullStructureProto*) other;
- (FullStructureProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (FullStructureProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasStructId;
- (int32_t) structId;
- (FullStructureProto_Builder*) setStructId:(int32_t) value;
- (FullStructureProto_Builder*) clearStructId;

- (BOOL) hasName;
- (NSString*) name;
- (FullStructureProto_Builder*) setName:(NSString*) value;
- (FullStructureProto_Builder*) clearName;

- (BOOL) hasIncome;
- (int32_t) income;
- (FullStructureProto_Builder*) setIncome:(int32_t) value;
- (FullStructureProto_Builder*) clearIncome;

- (BOOL) hasMinutesToGain;
- (int32_t) minutesToGain;
- (FullStructureProto_Builder*) setMinutesToGain:(int32_t) value;
- (FullStructureProto_Builder*) clearMinutesToGain;

- (BOOL) hasMinutesToBuild;
- (int32_t) minutesToBuild;
- (FullStructureProto_Builder*) setMinutesToBuild:(int32_t) value;
- (FullStructureProto_Builder*) clearMinutesToBuild;

- (BOOL) hasMinutesToUpgradeBase;
- (int32_t) minutesToUpgradeBase;
- (FullStructureProto_Builder*) setMinutesToUpgradeBase:(int32_t) value;
- (FullStructureProto_Builder*) clearMinutesToUpgradeBase;

- (BOOL) hasCoinPrice;
- (int32_t) coinPrice;
- (FullStructureProto_Builder*) setCoinPrice:(int32_t) value;
- (FullStructureProto_Builder*) clearCoinPrice;

- (BOOL) hasDiamondPrice;
- (int32_t) diamondPrice;
- (FullStructureProto_Builder*) setDiamondPrice:(int32_t) value;
- (FullStructureProto_Builder*) clearDiamondPrice;

- (BOOL) hasMinLevel;
- (int32_t) minLevel;
- (FullStructureProto_Builder*) setMinLevel:(int32_t) value;
- (FullStructureProto_Builder*) clearMinLevel;

- (BOOL) hasXLength;
- (int32_t) xLength;
- (FullStructureProto_Builder*) setXLength:(int32_t) value;
- (FullStructureProto_Builder*) clearXLength;

- (BOOL) hasYLength;
- (int32_t) yLength;
- (FullStructureProto_Builder*) setYLength:(int32_t) value;
- (FullStructureProto_Builder*) clearYLength;

- (BOOL) hasInstaUpgradeDiamondCostBase;
- (int32_t) instaUpgradeDiamondCostBase;
- (FullStructureProto_Builder*) setInstaUpgradeDiamondCostBase:(int32_t) value;
- (FullStructureProto_Builder*) clearInstaUpgradeDiamondCostBase;

- (BOOL) hasImgVerticalPixelOffset;
- (int32_t) imgVerticalPixelOffset;
- (FullStructureProto_Builder*) setImgVerticalPixelOffset:(int32_t) value;
- (FullStructureProto_Builder*) clearImgVerticalPixelOffset;
@end

@interface FullUserStructureProto : PBGeneratedMessage {
@private
  BOOL hasIsComplete_:1;
  BOOL hasLastRetrieved_:1;
  BOOL hasPurchaseTime_:1;
  BOOL hasLastUpgradeTime_:1;
  BOOL hasUserStructId_:1;
  BOOL hasUserId_:1;
  BOOL hasStructId_:1;
  BOOL hasLevel_:1;
  BOOL hasCoordinates_:1;
  BOOL hasOrientation_:1;
  BOOL isComplete_:1;
  int64_t lastRetrieved;
  int64_t purchaseTime;
  int64_t lastUpgradeTime;
  int32_t userStructId;
  int32_t userId;
  int32_t structId;
  int32_t level;
  CoordinateProto* coordinates;
  StructOrientation orientation;
}
- (BOOL) hasUserStructId;
- (BOOL) hasUserId;
- (BOOL) hasStructId;
- (BOOL) hasLastRetrieved;
- (BOOL) hasCoordinates;
- (BOOL) hasLevel;
- (BOOL) hasPurchaseTime;
- (BOOL) hasLastUpgradeTime;
- (BOOL) hasIsComplete;
- (BOOL) hasOrientation;
@property (readonly) int32_t userStructId;
@property (readonly) int32_t userId;
@property (readonly) int32_t structId;
@property (readonly) int64_t lastRetrieved;
@property (readonly, retain) CoordinateProto* coordinates;
@property (readonly) int32_t level;
@property (readonly) int64_t purchaseTime;
@property (readonly) int64_t lastUpgradeTime;
- (BOOL) isComplete;
@property (readonly) StructOrientation orientation;

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

- (BOOL) hasCoordinates;
- (CoordinateProto*) coordinates;
- (FullUserStructureProto_Builder*) setCoordinates:(CoordinateProto*) value;
- (FullUserStructureProto_Builder*) setCoordinatesBuilder:(CoordinateProto_Builder*) builderForValue;
- (FullUserStructureProto_Builder*) mergeCoordinates:(CoordinateProto*) value;
- (FullUserStructureProto_Builder*) clearCoordinates;

- (BOOL) hasLevel;
- (int32_t) level;
- (FullUserStructureProto_Builder*) setLevel:(int32_t) value;
- (FullUserStructureProto_Builder*) clearLevel;

- (BOOL) hasPurchaseTime;
- (int64_t) purchaseTime;
- (FullUserStructureProto_Builder*) setPurchaseTime:(int64_t) value;
- (FullUserStructureProto_Builder*) clearPurchaseTime;

- (BOOL) hasLastUpgradeTime;
- (int64_t) lastUpgradeTime;
- (FullUserStructureProto_Builder*) setLastUpgradeTime:(int64_t) value;
- (FullUserStructureProto_Builder*) clearLastUpgradeTime;

- (BOOL) hasIsComplete;
- (BOOL) isComplete;
- (FullUserStructureProto_Builder*) setIsComplete:(BOOL) value;
- (FullUserStructureProto_Builder*) clearIsComplete;

- (BOOL) hasOrientation;
- (StructOrientation) orientation;
- (FullUserStructureProto_Builder*) setOrientation:(StructOrientation) value;
- (FullUserStructureProto_Builder*) clearOrientation;
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

