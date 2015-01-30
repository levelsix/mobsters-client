// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

// @@protoc_insertion_point(imports)

@class SkillPropertyProto;
@class SkillPropertyProto_Builder;
@class SkillProto;
@class SkillProto_Builder;
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

typedef NS_ENUM(SInt32, SkillType) {
  SkillTypeNoSkill = 1,
  SkillTypeCakeDrop = 2,
  SkillTypeJelly = 3,
  SkillTypeQuickAttack = 4,
  SkillTypeBombs = 5,
  SkillTypeShield = 6,
  SkillTypePoison = 7,
  SkillTypeRoidRage = 8,
  SkillTypeMomentum = 9,
  SkillTypeThickSkin = 10,
  SkillTypeCritAndEvade = 11,
  SkillTypeShuffle = 12,
  SkillTypeHeadshot = 13,
  SkillTypeMud = 14,
  SkillTypeLifeSteal = 15,
  SkillTypeCounterStrike = 16,
  SkillTypeFlameStrike = 17,
  SkillTypeConfusion = 18,
  SkillTypeStaticField = 19,
  SkillTypeBlindingLight = 20,
  SkillTypePoisonPowder = 21,
  SkillTypeSkewer = 22,
  SkillTypeKnockout = 23,
  SkillTypeShallowGrave = 24,
  SkillTypeHammerTime = 25,
  SkillTypeBloodRage = 26,
<<<<<<< HEAD
  SkillTypeTakeAim = 27,
<<<<<<< HEAD
  SkillTypeHellFire = 28,
  SkillTypeEnergize = 29,
  SkillTypeRightHook = 30,
<<<<<<< HEAD
  SkillTypeCurse = 31,
  SkillTypeInsurance = 32,
  SkillTypeFlameBreak = 33,
=======
=======
=======
>>>>>>> donate msg vc done
>>>>>>> donate msg vc done
>>>>>>> donate msg vc done
};

BOOL SkillTypeIsValidValue(SkillType value);

typedef NS_ENUM(SInt32, SkillActivationType) {
  SkillActivationTypeUserActivated = 1,
  SkillActivationTypeAutoActivated = 2,
  SkillActivationTypePassive = 3,
};

BOOL SkillActivationTypeIsValidValue(SkillActivationType value);


@interface SkillRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface SkillProto : PBGeneratedMessage {
@private
  BOOL hasSkillId_:1;
  BOOL hasOrbCost_:1;
  BOOL hasPredecId_:1;
  BOOL hasSucId_:1;
  BOOL hasName_:1;
  BOOL hasDesc_:1;
  BOOL hasImgNamePrefix_:1;
  BOOL hasType_:1;
  BOOL hasActivationType_:1;
  int32_t skillId;
  int32_t orbCost;
  int32_t predecId;
  int32_t sucId;
  NSString* name;
  NSString* desc;
  NSString* imgNamePrefix;
  SkillType type;
  SkillActivationType activationType;
  NSMutableArray * mutablePropertiesList;
}
- (BOOL) hasSkillId;
- (BOOL) hasName;
- (BOOL) hasOrbCost;
- (BOOL) hasType;
- (BOOL) hasActivationType;
- (BOOL) hasPredecId;
- (BOOL) hasSucId;
- (BOOL) hasDesc;
- (BOOL) hasImgNamePrefix;
@property (readonly) int32_t skillId;
@property (readonly, strong) NSString* name;
@property (readonly) int32_t orbCost;
@property (readonly) SkillType type;
@property (readonly) SkillActivationType activationType;
@property (readonly) int32_t predecId;
@property (readonly) int32_t sucId;
@property (readonly, strong) NSArray * propertiesList;
@property (readonly, strong) NSString* desc;
@property (readonly, strong) NSString* imgNamePrefix;
- (SkillPropertyProto*)propertiesAtIndex:(NSUInteger)index;

+ (SkillProto*) defaultInstance;
- (SkillProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (SkillProto_Builder*) builder;
+ (SkillProto_Builder*) builder;
+ (SkillProto_Builder*) builderWithPrototype:(SkillProto*) prototype;
- (SkillProto_Builder*) toBuilder;

+ (SkillProto*) parseFromData:(NSData*) data;
+ (SkillProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SkillProto*) parseFromInputStream:(NSInputStream*) input;
+ (SkillProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SkillProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (SkillProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface SkillProto_Builder : PBGeneratedMessageBuilder {
@private
  SkillProto* result;
}

- (SkillProto*) defaultInstance;

- (SkillProto_Builder*) clear;
- (SkillProto_Builder*) clone;

- (SkillProto*) build;
- (SkillProto*) buildPartial;

- (SkillProto_Builder*) mergeFrom:(SkillProto*) other;
- (SkillProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (SkillProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSkillId;
- (int32_t) skillId;
- (SkillProto_Builder*) setSkillId:(int32_t) value;
- (SkillProto_Builder*) clearSkillId;

- (BOOL) hasName;
- (NSString*) name;
- (SkillProto_Builder*) setName:(NSString*) value;
- (SkillProto_Builder*) clearName;

- (BOOL) hasOrbCost;
- (int32_t) orbCost;
- (SkillProto_Builder*) setOrbCost:(int32_t) value;
- (SkillProto_Builder*) clearOrbCost;

- (BOOL) hasType;
- (SkillType) type;
- (SkillProto_Builder*) setType:(SkillType) value;
- (SkillProto_Builder*) clearTypeList;

- (BOOL) hasActivationType;
- (SkillActivationType) activationType;
- (SkillProto_Builder*) setActivationType:(SkillActivationType) value;
- (SkillProto_Builder*) clearActivationTypeList;

- (BOOL) hasPredecId;
- (int32_t) predecId;
- (SkillProto_Builder*) setPredecId:(int32_t) value;
- (SkillProto_Builder*) clearPredecId;

- (BOOL) hasSucId;
- (int32_t) sucId;
- (SkillProto_Builder*) setSucId:(int32_t) value;
- (SkillProto_Builder*) clearSucId;

- (NSMutableArray *)propertiesList;
- (SkillPropertyProto*)propertiesAtIndex:(NSUInteger)index;
- (SkillProto_Builder *)addProperties:(SkillPropertyProto*)value;
- (SkillProto_Builder *)addAllProperties:(NSArray *)array;
- (SkillProto_Builder *)clearProperties;

- (BOOL) hasDesc;
- (NSString*) desc;
- (SkillProto_Builder*) setDesc:(NSString*) value;
- (SkillProto_Builder*) clearDesc;

- (BOOL) hasImgNamePrefix;
- (NSString*) imgNamePrefix;
- (SkillProto_Builder*) setImgNamePrefix:(NSString*) value;
- (SkillProto_Builder*) clearImgNamePrefix;
@end

@interface SkillPropertyProto : PBGeneratedMessage {
@private
  BOOL hasSkillValue_:1;
  BOOL hasSkillPropertyId_:1;
  BOOL hasName_:1;
  Float32 skillValue;
  int32_t skillPropertyId;
  NSString* name;
}
- (BOOL) hasSkillPropertyId;
- (BOOL) hasName;
- (BOOL) hasSkillValue;
@property (readonly) int32_t skillPropertyId;
@property (readonly, strong) NSString* name;
@property (readonly) Float32 skillValue;

+ (SkillPropertyProto*) defaultInstance;
- (SkillPropertyProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (SkillPropertyProto_Builder*) builder;
+ (SkillPropertyProto_Builder*) builder;
+ (SkillPropertyProto_Builder*) builderWithPrototype:(SkillPropertyProto*) prototype;
- (SkillPropertyProto_Builder*) toBuilder;

+ (SkillPropertyProto*) parseFromData:(NSData*) data;
+ (SkillPropertyProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SkillPropertyProto*) parseFromInputStream:(NSInputStream*) input;
+ (SkillPropertyProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SkillPropertyProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (SkillPropertyProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface SkillPropertyProto_Builder : PBGeneratedMessageBuilder {
@private
  SkillPropertyProto* result;
}

- (SkillPropertyProto*) defaultInstance;

- (SkillPropertyProto_Builder*) clear;
- (SkillPropertyProto_Builder*) clone;

- (SkillPropertyProto*) build;
- (SkillPropertyProto*) buildPartial;

- (SkillPropertyProto_Builder*) mergeFrom:(SkillPropertyProto*) other;
- (SkillPropertyProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (SkillPropertyProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSkillPropertyId;
- (int32_t) skillPropertyId;
- (SkillPropertyProto_Builder*) setSkillPropertyId:(int32_t) value;
- (SkillPropertyProto_Builder*) clearSkillPropertyId;

- (BOOL) hasName;
- (NSString*) name;
- (SkillPropertyProto_Builder*) setName:(NSString*) value;
- (SkillPropertyProto_Builder*) clearName;

- (BOOL) hasSkillValue;
- (Float32) skillValue;
- (SkillPropertyProto_Builder*) setSkillValue:(Float32) value;
- (SkillPropertyProto_Builder*) clearSkillValue;
@end


// @@protoc_insertion_point(global_scope)
