// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "SharedEnumConfig.pb.h"
// @@protoc_insertion_point(imports)

@implementation SharedEnumConfigRoot
static PBExtensionRegistry* extensionRegistry = nil;
+ (PBExtensionRegistry*) extensionRegistry {
  return extensionRegistry;
}

+ (void) initialize {
  if (self == [SharedEnumConfigRoot class]) {
    PBMutableExtensionRegistry* registry = [PBMutableExtensionRegistry registry];
    [self registerAllExtensions:registry];
    extensionRegistry = registry;
  }
}
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry {
}
@end

BOOL DayOfWeekIsValidValue(DayOfWeek value) {
  switch (value) {
    case DayOfWeekSunday:
    case DayOfWeekMonday:
    case DayOfWeekTuesday:
    case DayOfWeekWednesday:
    case DayOfWeekThursday:
    case DayOfWeekFriday:
    case DayOfWeekSaturday:
    case DayOfWeekNoDayOfWeek:
      return YES;
    default:
      return NO;
  }
}
BOOL ElementIsValidValue(Element value) {
  switch (value) {
    case ElementFire:
    case ElementEarth:
    case ElementWater:
    case ElementLight:
    case ElementDark:
    case ElementRock:
    case ElementNoElement:
      return YES;
    default:
      return NO;
  }
}
BOOL QualityIsValidValue(Quality value) {
  switch (value) {
    case QualityNoQuality:
    case QualityCommon:
    case QualityRare:
    case QualitySuper:
    case QualityUltra:
    case QualityEpic:
    case QualityLegendary:
    case QualityEvo:
      return YES;
    default:
      return NO;
  }
}
BOOL GameActionTypeIsValidValue(GameActionType value) {
  switch (value) {
    case GameActionTypeNoHelp:
    case GameActionTypeUpgradeStruct:
    case GameActionTypeHeal:
    case GameActionTypeEvolve:
    case GameActionTypeMiniJob:
    case GameActionTypeEnhanceTime:
    case GameActionTypeRemoveObstacle:
    case GameActionTypeCombineMonster:
    case GameActionTypeEnterPersistentEvent:
    case GameActionTypeGameActionTypeResearch:
    case GameActionTypeCreateBattleItem:
      return YES;
    default:
      return NO;
  }
}
BOOL GameTypeIsValidValue(GameType value) {
  switch (value) {
    case GameTypeNoType:
    case GameTypeStructure:
    case GameTypeResearch:
    case GameTypeSkill:
    case GameTypeTask:
    case GameTypeBattleItem:
    case GameTypeBoardObstacle:
      return YES;
    default:
      return NO;
  }
}

// @@protoc_insertion_point(global_scope)
