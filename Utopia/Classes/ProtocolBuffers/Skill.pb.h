// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

// @@protoc_insertion_point(imports)

@class SkillPropertyProto;
@class SkillPropertyProto_Builder;
@class SkillProto;
@class SkillProto_Builder;
@class SkillSideEffectProto;
@class SkillSideEffectProto_Builder;
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
  SkillTypeTakeAim = 27,
  SkillTypeHellFire = 28,
  SkillTypeEnergize = 29,
  SkillTypeRightHook = 30,
  SkillTypeCurse = 31,
  SkillTypeInsurance = 32,
  SkillTypeFlameBreak = 33,
  SkillTypePoisonSkewer = 34,
  SkillTypePoisonFire = 35,
};

BOOL SkillTypeIsValidValue(SkillType value);

typedef NS_ENUM(SInt32, SkillActivationType) {
  SkillActivationTypeUserActivated = 1,
  SkillActivationTypeAutoActivated = 2,
  SkillActivationTypePassive = 3,
};

BOOL SkillActivationTypeIsValidValue(SkillActivationType value);

typedef NS_ENUM(SInt32, SideEffectType) {
  SideEffectTypeNoSideEffect = 1,
  SideEffectTypePoisoned = 2,
<<<<<<< HEAD
  SideEffectTypeCursed = 3,
=======
>>>>>>> falling gems icon done
};

BOOL SideEffectTypeIsValidValue(SideEffectType value);

typedef NS_ENUM(SInt32, SideEffectTraitType) {
  SideEffectTraitTypeNoTrait = 1,
  SideEffectTraitTypeBuff = 2,
  SideEffectTraitTypeNerf = 3,
};

BOOL SideEffectTraitTypeIsValidValue(SideEffectTraitType value);

typedef NS_ENUM(SInt32, SideEffectPositionType) {
  SideEffectPositionTypeBelowCharacter = 1,
  SideEffectPositionTypeAboveCharacter = 2,
};

BOOL SideEffectPositionTypeIsValidValue(SideEffectPositionType value);

typedef NS_ENUM(SInt32, SideEffectBlendMode) {
  SideEffectBlendModeNormalFullOpacity = 1,
};

BOOL SideEffectBlendModeIsValidValue(SideEffectBlendMode value);


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
  BOOL hasSkillEffectDuration_:1;
  BOOL hasName_:1;
  BOOL hasDefDesc_:1;
  BOOL hasOffDesc_:1;
  BOOL hasImgNamePrefix_:1;
  BOOL hasType_:1;
  BOOL hasActivationType_:1;
  int32_t skillId;
  int32_t orbCost;
  int32_t predecId;
  int32_t sucId;
  int32_t skillEffectDuration;
  NSString* name;
  NSString* defDesc;
  NSString* offDesc;
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
- (BOOL) hasDefDesc;
- (BOOL) hasOffDesc;
- (BOOL) hasImgNamePrefix;
- (BOOL) hasSkillEffectDuration;
@property (readonly) int32_t skillId;
@property (readonly, strong) NSString* name;
@property (readonly) int32_t orbCost;
@property (readonly) SkillType type;
@property (readonly) SkillActivationType activationType;
@property (readonly) int32_t predecId;
@property (readonly) int32_t sucId;
@property (readonly, strong) NSArray * propertiesList;
@property (readonly, strong) NSString* defDesc;
@property (readonly, strong) NSString* offDesc;
@property (readonly, strong) NSString* imgNamePrefix;
@property (readonly) int32_t skillEffectDuration;
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

- (BOOL) hasDefDesc;
- (NSString*) defDesc;
- (SkillProto_Builder*) setDefDesc:(NSString*) value;
- (SkillProto_Builder*) clearDefDesc;

- (BOOL) hasOffDesc;
- (NSString*) offDesc;
- (SkillProto_Builder*) setOffDesc:(NSString*) value;
- (SkillProto_Builder*) clearOffDesc;

- (BOOL) hasImgNamePrefix;
- (NSString*) imgNamePrefix;
- (SkillProto_Builder*) setImgNamePrefix:(NSString*) value;
- (SkillProto_Builder*) clearImgNamePrefix;

- (BOOL) hasSkillEffectDuration;
- (int32_t) skillEffectDuration;
- (SkillProto_Builder*) setSkillEffectDuration:(int32_t) value;
- (SkillProto_Builder*) clearSkillEffectDuration;
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

@interface SkillSideEffectProto : PBGeneratedMessage {
@private
  BOOL hasSkillSideEffectId_:1;
  BOOL hasImgPixelOffsetX_:1;
  BOOL hasImgPixelOffsetY_:1;
  BOOL hasPfxPixelOffsetX_:1;
  BOOL hasPfxPixelOffsetY_:1;
  BOOL hasName_:1;
  BOOL hasDesc_:1;
  BOOL hasImgName_:1;
  BOOL hasIconImgName_:1;
  BOOL hasPfxName_:1;
  BOOL hasPfxColor_:1;
  BOOL hasType_:1;
  BOOL hasTraitType_:1;
  BOOL hasPositionType_:1;
  BOOL hasBlendMode_:1;
  int32_t skillSideEffectId;
  int32_t imgPixelOffsetX;
  int32_t imgPixelOffsetY;
  int32_t pfxPixelOffsetX;
  int32_t pfxPixelOffsetY;
  NSString* name;
  NSString* desc;
  NSString* imgName;
  NSString* iconImgName;
  NSString* pfxName;
  NSString* pfxColor;
  SideEffectType type;
  SideEffectTraitType traitType;
  SideEffectPositionType positionType;
  SideEffectBlendMode blendMode;
}
- (BOOL) hasSkillSideEffectId;
- (BOOL) hasName;
- (BOOL) hasDesc;
- (BOOL) hasType;
- (BOOL) hasTraitType;
- (BOOL) hasImgName;
- (BOOL) hasImgPixelOffsetX;
- (BOOL) hasImgPixelOffsetY;
- (BOOL) hasIconImgName;
- (BOOL) hasPfxName;
- (BOOL) hasPfxColor;
- (BOOL) hasPositionType;
- (BOOL) hasPfxPixelOffsetX;
- (BOOL) hasPfxPixelOffsetY;
- (BOOL) hasBlendMode;
@property (readonly) int32_t skillSideEffectId;
@property (readonly, strong) NSString* name;
@property (readonly, strong) NSString* desc;
@property (readonly) SideEffectType type;
@property (readonly) SideEffectTraitType traitType;
@property (readonly, strong) NSString* imgName;
@property (readonly) int32_t imgPixelOffsetX;
@property (readonly) int32_t imgPixelOffsetY;
@property (readonly, strong) NSString* iconImgName;
@property (readonly, strong) NSString* pfxName;
@property (readonly, strong) NSString* pfxColor;
@property (readonly) SideEffectPositionType positionType;
@property (readonly) int32_t pfxPixelOffsetX;
@property (readonly) int32_t pfxPixelOffsetY;
@property (readonly) SideEffectBlendMode blendMode;

+ (SkillSideEffectProto*) defaultInstance;
- (SkillSideEffectProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (SkillSideEffectProto_Builder*) builder;
+ (SkillSideEffectProto_Builder*) builder;
+ (SkillSideEffectProto_Builder*) builderWithPrototype:(SkillSideEffectProto*) prototype;
- (SkillSideEffectProto_Builder*) toBuilder;

+ (SkillSideEffectProto*) parseFromData:(NSData*) data;
+ (SkillSideEffectProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SkillSideEffectProto*) parseFromInputStream:(NSInputStream*) input;
+ (SkillSideEffectProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SkillSideEffectProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (SkillSideEffectProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface SkillSideEffectProto_Builder : PBGeneratedMessageBuilder {
@private
  SkillSideEffectProto* result;
}

- (SkillSideEffectProto*) defaultInstance;

- (SkillSideEffectProto_Builder*) clear;
- (SkillSideEffectProto_Builder*) clone;

- (SkillSideEffectProto*) build;
- (SkillSideEffectProto*) buildPartial;

- (SkillSideEffectProto_Builder*) mergeFrom:(SkillSideEffectProto*) other;
- (SkillSideEffectProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (SkillSideEffectProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSkillSideEffectId;
- (int32_t) skillSideEffectId;
- (SkillSideEffectProto_Builder*) setSkillSideEffectId:(int32_t) value;
- (SkillSideEffectProto_Builder*) clearSkillSideEffectId;

- (BOOL) hasName;
- (NSString*) name;
- (SkillSideEffectProto_Builder*) setName:(NSString*) value;
- (SkillSideEffectProto_Builder*) clearName;

- (BOOL) hasDesc;
- (NSString*) desc;
- (SkillSideEffectProto_Builder*) setDesc:(NSString*) value;
- (SkillSideEffectProto_Builder*) clearDesc;

- (BOOL) hasType;
- (SideEffectType) type;
- (SkillSideEffectProto_Builder*) setType:(SideEffectType) value;
- (SkillSideEffectProto_Builder*) clearTypeList;

- (BOOL) hasTraitType;
- (SideEffectTraitType) traitType;
- (SkillSideEffectProto_Builder*) setTraitType:(SideEffectTraitType) value;
- (SkillSideEffectProto_Builder*) clearTraitTypeList;

- (BOOL) hasImgName;
- (NSString*) imgName;
- (SkillSideEffectProto_Builder*) setImgName:(NSString*) value;
- (SkillSideEffectProto_Builder*) clearImgName;

- (BOOL) hasImgPixelOffsetX;
- (int32_t) imgPixelOffsetX;
- (SkillSideEffectProto_Builder*) setImgPixelOffsetX:(int32_t) value;
- (SkillSideEffectProto_Builder*) clearImgPixelOffsetX;

- (BOOL) hasImgPixelOffsetY;
- (int32_t) imgPixelOffsetY;
- (SkillSideEffectProto_Builder*) setImgPixelOffsetY:(int32_t) value;
- (SkillSideEffectProto_Builder*) clearImgPixelOffsetY;

- (BOOL) hasIconImgName;
- (NSString*) iconImgName;
- (SkillSideEffectProto_Builder*) setIconImgName:(NSString*) value;
- (SkillSideEffectProto_Builder*) clearIconImgName;

- (BOOL) hasPfxName;
- (NSString*) pfxName;
- (SkillSideEffectProto_Builder*) setPfxName:(NSString*) value;
- (SkillSideEffectProto_Builder*) clearPfxName;

- (BOOL) hasPfxColor;
- (NSString*) pfxColor;
- (SkillSideEffectProto_Builder*) setPfxColor:(NSString*) value;
- (SkillSideEffectProto_Builder*) clearPfxColor;

- (BOOL) hasPositionType;
- (SideEffectPositionType) positionType;
- (SkillSideEffectProto_Builder*) setPositionType:(SideEffectPositionType) value;
- (SkillSideEffectProto_Builder*) clearPositionTypeList;

- (BOOL) hasPfxPixelOffsetX;
- (int32_t) pfxPixelOffsetX;
- (SkillSideEffectProto_Builder*) setPfxPixelOffsetX:(int32_t) value;
- (SkillSideEffectProto_Builder*) clearPfxPixelOffsetX;

- (BOOL) hasPfxPixelOffsetY;
- (int32_t) pfxPixelOffsetY;
- (SkillSideEffectProto_Builder*) setPfxPixelOffsetY:(int32_t) value;
- (SkillSideEffectProto_Builder*) clearPfxPixelOffsetY;

- (BOOL) hasBlendMode;
- (SideEffectBlendMode) blendMode;
- (SkillSideEffectProto_Builder*) setBlendMode:(SideEffectBlendMode) value;
- (SkillSideEffectProto_Builder*) clearBlendModeList;
@end


// @@protoc_insertion_point(global_scope)
