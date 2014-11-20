// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

// @@protoc_insertion_point(imports)

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

typedef NS_ENUM(SInt32, DayOfWeek) {
  DayOfWeekSunday = 1,
  DayOfWeekMonday = 2,
  DayOfWeekTuesday = 3,
  DayOfWeekWednesday = 4,
  DayOfWeekThursday = 5,
  DayOfWeekFriday = 6,
  DayOfWeekSaturday = 7,
  DayOfWeekNoDayOfWeek = 8,
};

BOOL DayOfWeekIsValidValue(DayOfWeek value);

typedef NS_ENUM(SInt32, Element) {
  ElementFire = 1,
  ElementEarth = 2,
  ElementWater = 3,
  ElementLight = 4,
  ElementDark = 5,
  ElementRock = 6,
  ElementNoElement = 7,
};

BOOL ElementIsValidValue(Element value);

typedef NS_ENUM(SInt32, Quality) {
  QualityNoQuality = 1,
  QualityCommon = 2,
  QualityRare = 3,
  QualitySuper = 4,
  QualityUltra = 5,
  QualityEpic = 6,
  QualityLegendary = 7,
  QualityEvo = 8,
};

BOOL QualityIsValidValue(Quality value);

typedef NS_ENUM(SInt32, GameActionType) {
  GameActionTypeNoHelp = 1,
  GameActionTypeUpgradeStruct = 2,
  GameActionTypeHeal = 3,
  GameActionTypeEvolve = 4,
  GameActionTypeMiniJob = 5,
  GameActionTypeEnhanceTime = 6,
  GameActionTypeRemoveObstacle = 7,
};

BOOL GameActionTypeIsValidValue(GameActionType value);

typedef NS_ENUM(SInt32, GameType) {
  GameTypeNoType = 1,
  GameTypeStructure = 2,
  GameTypeResearch = 3,
  GameTypeSkill = 4,
};

BOOL GameTypeIsValidValue(GameType value);


@interface SharedEnumConfigRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end


// @@protoc_insertion_point(global_scope)
