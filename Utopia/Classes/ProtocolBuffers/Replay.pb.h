// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "Board.pb.h"
#import "SharedEnumConfig.pb.h"
#import "Skill.pb.h"
#import "Structure.pb.h"
// @@protoc_insertion_point(imports)

@class BattleItemFactoryProto;
@class BattleItemFactoryProto_Builder;
@class BoardLayoutProto;
@class BoardLayoutProto_Builder;
@class BoardPropertyProto;
@class BoardPropertyProto_Builder;
@class ClanHouseProto;
@class ClanHouseProto_Builder;
@class CombatReplayMonsterSnapshot;
@class CombatReplayMonsterSnapshot_Builder;
@class CombatReplayOrbProto;
@class CombatReplayOrbProto_Builder;
@class CombatReplayProto;
@class CombatReplayProto_Builder;
@class CombatReplayScheduleProto;
@class CombatReplayScheduleProto_Builder;
@class CombatReplaySkillStepProto;
@class CombatReplaySkillStepProto_Builder;
@class CombatReplayStepProto;
@class CombatReplayStepProto_Builder;
@class CoordinateProto;
@class CoordinateProto_Builder;
@class EvoChamberProto;
@class EvoChamberProto_Builder;
@class FullUserStructureProto;
@class FullUserStructureProto_Builder;
@class HospitalProto;
@class HospitalProto_Builder;
@class ItemGemPriceProto;
@class ItemGemPriceProto_Builder;
@class ItemProto;
@class ItemProto_Builder;
@class LabProto;
@class LabProto_Builder;
@class MiniJobCenterProto;
@class MiniJobCenterProto_Builder;
@class MinimumCombatReplayProto;
@class MinimumCombatReplayProto_Builder;
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
@class SkillPropertyProto;
@class SkillPropertyProto_Builder;
@class SkillProto;
@class SkillProto_Builder;
@class SkillSideEffectProto;
@class SkillSideEffectProto_Builder;
@class StructureInfoProto;
@class StructureInfoProto_Builder;
@class TeamCenterProto;
@class TeamCenterProto_Builder;
@class TownHallProto;
@class TownHallProto_Builder;
@class TutorialStructProto;
@class TutorialStructProto_Builder;
@class UserItemProto;
@class UserItemProto_Builder;
@class UserItemSecretGiftProto;
@class UserItemSecretGiftProto_Builder;
@class UserItemUsageProto;
@class UserItemUsageProto_Builder;
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

typedef NS_ENUM(SInt32, CombatReplayStepType) {
  CombatReplayStepTypeBattleInitialization = 1,
  CombatReplayStepTypeSpawnEnemy = 2,
  CombatReplayStepTypeNextTurn = 3,
  CombatReplayStepTypePlayerTurn = 4,
  CombatReplayStepTypePlayerMove = 5,
  CombatReplayStepTypePlayerAttack = 6,
  CombatReplayStepTypeEnemyTurn = 7,
  CombatReplayStepTypePlayerSwap = 8,
  CombatReplayStepTypePlayerDeath = 9,
  CombatReplayStepTypePlayerRevive = 10,
  CombatReplayStepTypeEnemyDeath = 11,
  CombatReplayStepTypePlayerVictory = 12,
  CombatReplayStepTypePlayerRun = 13,
  CombatReplayStepTypePlayerLose = 14,
};

BOOL CombatReplayStepTypeIsValidValue(CombatReplayStepType value);


@interface ReplayRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface CombatReplayProto : PBGeneratedMessage {
@private
  BOOL hasBoardWidth_:1;
  BOOL hasBoardHeight_:1;
  BOOL hasCash_:1;
  BOOL hasOil_:1;
  BOOL hasReplayUuid_:1;
  BOOL hasGroundImgPrefix_:1;
  BOOL hasBoard_:1;
  int32_t boardWidth;
  int32_t boardHeight;
  int32_t cash;
  int32_t oil;
  NSString* replayUuid;
  NSString* groundImgPrefix;
  BoardLayoutProto* board;
  NSMutableArray * mutablePlayerTeamList;
  NSMutableArray * mutableEnemyTeamList;
  NSMutableArray * mutableStepsList;
  NSMutableArray * mutableOrbsList;
  NSMutableArray * mutablePvpObstaclesList;
}
- (BOOL) hasReplayUuid;
- (BOOL) hasGroundImgPrefix;
- (BOOL) hasBoard;
- (BOOL) hasBoardWidth;
- (BOOL) hasBoardHeight;
- (BOOL) hasCash;
- (BOOL) hasOil;
@property (readonly, strong) NSString* replayUuid;
@property (readonly, strong) NSString* groundImgPrefix;
@property (readonly, strong) NSArray * playerTeamList;
@property (readonly, strong) NSArray * enemyTeamList;
@property (readonly, strong) NSArray * stepsList;
@property (readonly, strong) BoardLayoutProto* board;
@property (readonly, strong) NSArray * orbsList;
@property (readonly) int32_t boardWidth;
@property (readonly) int32_t boardHeight;
@property (readonly, strong) NSArray * pvpObstaclesList;
@property (readonly) int32_t cash;
@property (readonly) int32_t oil;
- (CombatReplayMonsterSnapshot*)playerTeamAtIndex:(NSUInteger)index;
- (CombatReplayMonsterSnapshot*)enemyTeamAtIndex:(NSUInteger)index;
- (CombatReplayStepProto*)stepsAtIndex:(NSUInteger)index;
- (CombatReplayOrbProto*)orbsAtIndex:(NSUInteger)index;
- (PvpBoardObstacleProto*)pvpObstaclesAtIndex:(NSUInteger)index;

+ (CombatReplayProto*) defaultInstance;
- (CombatReplayProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (CombatReplayProto_Builder*) builder;
+ (CombatReplayProto_Builder*) builder;
+ (CombatReplayProto_Builder*) builderWithPrototype:(CombatReplayProto*) prototype;
- (CombatReplayProto_Builder*) toBuilder;

+ (CombatReplayProto*) parseFromData:(NSData*) data;
+ (CombatReplayProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CombatReplayProto*) parseFromInputStream:(NSInputStream*) input;
+ (CombatReplayProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CombatReplayProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (CombatReplayProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface CombatReplayProto_Builder : PBGeneratedMessageBuilder {
@private
  CombatReplayProto* result;
}

- (CombatReplayProto*) defaultInstance;

- (CombatReplayProto_Builder*) clear;
- (CombatReplayProto_Builder*) clone;

- (CombatReplayProto*) build;
- (CombatReplayProto*) buildPartial;

- (CombatReplayProto_Builder*) mergeFrom:(CombatReplayProto*) other;
- (CombatReplayProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (CombatReplayProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasReplayUuid;
- (NSString*) replayUuid;
- (CombatReplayProto_Builder*) setReplayUuid:(NSString*) value;
- (CombatReplayProto_Builder*) clearReplayUuid;

- (BOOL) hasGroundImgPrefix;
- (NSString*) groundImgPrefix;
- (CombatReplayProto_Builder*) setGroundImgPrefix:(NSString*) value;
- (CombatReplayProto_Builder*) clearGroundImgPrefix;

- (NSMutableArray *)playerTeamList;
- (CombatReplayMonsterSnapshot*)playerTeamAtIndex:(NSUInteger)index;
- (CombatReplayProto_Builder *)addPlayerTeam:(CombatReplayMonsterSnapshot*)value;
- (CombatReplayProto_Builder *)addAllPlayerTeam:(NSArray *)array;
- (CombatReplayProto_Builder *)clearPlayerTeam;

- (NSMutableArray *)enemyTeamList;
- (CombatReplayMonsterSnapshot*)enemyTeamAtIndex:(NSUInteger)index;
- (CombatReplayProto_Builder *)addEnemyTeam:(CombatReplayMonsterSnapshot*)value;
- (CombatReplayProto_Builder *)addAllEnemyTeam:(NSArray *)array;
- (CombatReplayProto_Builder *)clearEnemyTeam;

- (NSMutableArray *)stepsList;
- (CombatReplayStepProto*)stepsAtIndex:(NSUInteger)index;
- (CombatReplayProto_Builder *)addSteps:(CombatReplayStepProto*)value;
- (CombatReplayProto_Builder *)addAllSteps:(NSArray *)array;
- (CombatReplayProto_Builder *)clearSteps;

- (BOOL) hasBoard;
- (BoardLayoutProto*) board;
- (CombatReplayProto_Builder*) setBoard:(BoardLayoutProto*) value;
- (CombatReplayProto_Builder*) setBoard_Builder:(BoardLayoutProto_Builder*) builderForValue;
- (CombatReplayProto_Builder*) mergeBoard:(BoardLayoutProto*) value;
- (CombatReplayProto_Builder*) clearBoard;

- (NSMutableArray *)orbsList;
- (CombatReplayOrbProto*)orbsAtIndex:(NSUInteger)index;
- (CombatReplayProto_Builder *)addOrbs:(CombatReplayOrbProto*)value;
- (CombatReplayProto_Builder *)addAllOrbs:(NSArray *)array;
- (CombatReplayProto_Builder *)clearOrbs;

- (BOOL) hasBoardWidth;
- (int32_t) boardWidth;
- (CombatReplayProto_Builder*) setBoardWidth:(int32_t) value;
- (CombatReplayProto_Builder*) clearBoardWidth;

- (BOOL) hasBoardHeight;
- (int32_t) boardHeight;
- (CombatReplayProto_Builder*) setBoardHeight:(int32_t) value;
- (CombatReplayProto_Builder*) clearBoardHeight;

- (NSMutableArray *)pvpObstaclesList;
- (PvpBoardObstacleProto*)pvpObstaclesAtIndex:(NSUInteger)index;
- (CombatReplayProto_Builder *)addPvpObstacles:(PvpBoardObstacleProto*)value;
- (CombatReplayProto_Builder *)addAllPvpObstacles:(NSArray *)array;
- (CombatReplayProto_Builder *)clearPvpObstacles;

- (BOOL) hasCash;
- (int32_t) cash;
- (CombatReplayProto_Builder*) setCash:(int32_t) value;
- (CombatReplayProto_Builder*) clearCash;

- (BOOL) hasOil;
- (int32_t) oil;
- (CombatReplayProto_Builder*) setOil:(int32_t) value;
- (CombatReplayProto_Builder*) clearOil;
@end

@interface MinimumCombatReplayProto : PBGeneratedMessage {
@private
  BOOL hasFirstAttackerMonsterId_:1;
  BOOL hasReplayUuid_:1;
  BOOL hasGroundImgPrefix_:1;
  int32_t firstAttackerMonsterId;
  NSString* replayUuid;
  NSString* groundImgPrefix;
}
- (BOOL) hasReplayUuid;
- (BOOL) hasGroundImgPrefix;
- (BOOL) hasFirstAttackerMonsterId;
@property (readonly, strong) NSString* replayUuid;
@property (readonly, strong) NSString* groundImgPrefix;
@property (readonly) int32_t firstAttackerMonsterId;

+ (MinimumCombatReplayProto*) defaultInstance;
- (MinimumCombatReplayProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (MinimumCombatReplayProto_Builder*) builder;
+ (MinimumCombatReplayProto_Builder*) builder;
+ (MinimumCombatReplayProto_Builder*) builderWithPrototype:(MinimumCombatReplayProto*) prototype;
- (MinimumCombatReplayProto_Builder*) toBuilder;

+ (MinimumCombatReplayProto*) parseFromData:(NSData*) data;
+ (MinimumCombatReplayProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (MinimumCombatReplayProto*) parseFromInputStream:(NSInputStream*) input;
+ (MinimumCombatReplayProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (MinimumCombatReplayProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (MinimumCombatReplayProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface MinimumCombatReplayProto_Builder : PBGeneratedMessageBuilder {
@private
  MinimumCombatReplayProto* result;
}

- (MinimumCombatReplayProto*) defaultInstance;

- (MinimumCombatReplayProto_Builder*) clear;
- (MinimumCombatReplayProto_Builder*) clone;

- (MinimumCombatReplayProto*) build;
- (MinimumCombatReplayProto*) buildPartial;

- (MinimumCombatReplayProto_Builder*) mergeFrom:(MinimumCombatReplayProto*) other;
- (MinimumCombatReplayProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (MinimumCombatReplayProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasReplayUuid;
- (NSString*) replayUuid;
- (MinimumCombatReplayProto_Builder*) setReplayUuid:(NSString*) value;
- (MinimumCombatReplayProto_Builder*) clearReplayUuid;

- (BOOL) hasGroundImgPrefix;
- (NSString*) groundImgPrefix;
- (MinimumCombatReplayProto_Builder*) setGroundImgPrefix:(NSString*) value;
- (MinimumCombatReplayProto_Builder*) clearGroundImgPrefix;

- (BOOL) hasFirstAttackerMonsterId;
- (int32_t) firstAttackerMonsterId;
- (MinimumCombatReplayProto_Builder*) setFirstAttackerMonsterId:(int32_t) value;
- (MinimumCombatReplayProto_Builder*) clearFirstAttackerMonsterId;
@end

@interface CombatReplayStepProto : PBGeneratedMessage {
@private
  BOOL hasStepIndex_:1;
  BOOL hasItemId_:1;
  BOOL hasModifiedDamage_:1;
  BOOL hasUnmodifiedDamage_:1;
  BOOL hasSwapIndex_:1;
  BOOL hasSchedule_:1;
  BOOL hasMovePos1_:1;
  BOOL hasMovePos2_:1;
  BOOL hasVinePos_:1;
  BOOL hasType_:1;
  int32_t stepIndex;
  int32_t itemId;
  int32_t modifiedDamage;
  int32_t unmodifiedDamage;
  int32_t swapIndex;
  CombatReplayScheduleProto* schedule;
  uint32_t movePos1;
  uint32_t movePos2;
  uint32_t vinePos;
  CombatReplayStepType type;
  NSMutableArray * mutableSkillsList;
}
- (BOOL) hasStepIndex;
- (BOOL) hasType;
- (BOOL) hasItemId;
- (BOOL) hasMovePos1;
- (BOOL) hasMovePos2;
- (BOOL) hasModifiedDamage;
- (BOOL) hasUnmodifiedDamage;
- (BOOL) hasSchedule;
- (BOOL) hasSwapIndex;
- (BOOL) hasVinePos;
@property (readonly) int32_t stepIndex;
@property (readonly) CombatReplayStepType type;
@property (readonly) int32_t itemId;
@property (readonly) uint32_t movePos1;
@property (readonly) uint32_t movePos2;
@property (readonly) int32_t modifiedDamage;
@property (readonly) int32_t unmodifiedDamage;
@property (readonly, strong) CombatReplayScheduleProto* schedule;
@property (readonly, strong) NSArray * skillsList;
@property (readonly) int32_t swapIndex;
@property (readonly) uint32_t vinePos;
- (CombatReplaySkillStepProto*)skillsAtIndex:(NSUInteger)index;

+ (CombatReplayStepProto*) defaultInstance;
- (CombatReplayStepProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (CombatReplayStepProto_Builder*) builder;
+ (CombatReplayStepProto_Builder*) builder;
+ (CombatReplayStepProto_Builder*) builderWithPrototype:(CombatReplayStepProto*) prototype;
- (CombatReplayStepProto_Builder*) toBuilder;

+ (CombatReplayStepProto*) parseFromData:(NSData*) data;
+ (CombatReplayStepProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CombatReplayStepProto*) parseFromInputStream:(NSInputStream*) input;
+ (CombatReplayStepProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CombatReplayStepProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (CombatReplayStepProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface CombatReplayStepProto_Builder : PBGeneratedMessageBuilder {
@private
  CombatReplayStepProto* result;
}

- (CombatReplayStepProto*) defaultInstance;

- (CombatReplayStepProto_Builder*) clear;
- (CombatReplayStepProto_Builder*) clone;

- (CombatReplayStepProto*) build;
- (CombatReplayStepProto*) buildPartial;

- (CombatReplayStepProto_Builder*) mergeFrom:(CombatReplayStepProto*) other;
- (CombatReplayStepProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (CombatReplayStepProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasStepIndex;
- (int32_t) stepIndex;
- (CombatReplayStepProto_Builder*) setStepIndex:(int32_t) value;
- (CombatReplayStepProto_Builder*) clearStepIndex;

- (BOOL) hasType;
- (CombatReplayStepType) type;
- (CombatReplayStepProto_Builder*) setType:(CombatReplayStepType) value;
- (CombatReplayStepProto_Builder*) clearTypeList;

- (BOOL) hasItemId;
- (int32_t) itemId;
- (CombatReplayStepProto_Builder*) setItemId:(int32_t) value;
- (CombatReplayStepProto_Builder*) clearItemId;

- (BOOL) hasMovePos1;
- (uint32_t) movePos1;
- (CombatReplayStepProto_Builder*) setMovePos1:(uint32_t) value;
- (CombatReplayStepProto_Builder*) clearMovePos1;

- (BOOL) hasMovePos2;
- (uint32_t) movePos2;
- (CombatReplayStepProto_Builder*) setMovePos2:(uint32_t) value;
- (CombatReplayStepProto_Builder*) clearMovePos2;

- (BOOL) hasModifiedDamage;
- (int32_t) modifiedDamage;
- (CombatReplayStepProto_Builder*) setModifiedDamage:(int32_t) value;
- (CombatReplayStepProto_Builder*) clearModifiedDamage;

- (BOOL) hasUnmodifiedDamage;
- (int32_t) unmodifiedDamage;
- (CombatReplayStepProto_Builder*) setUnmodifiedDamage:(int32_t) value;
- (CombatReplayStepProto_Builder*) clearUnmodifiedDamage;

- (BOOL) hasSchedule;
- (CombatReplayScheduleProto*) schedule;
- (CombatReplayStepProto_Builder*) setSchedule:(CombatReplayScheduleProto*) value;
- (CombatReplayStepProto_Builder*) setSchedule_Builder:(CombatReplayScheduleProto_Builder*) builderForValue;
- (CombatReplayStepProto_Builder*) mergeSchedule:(CombatReplayScheduleProto*) value;
- (CombatReplayStepProto_Builder*) clearSchedule;

- (NSMutableArray *)skillsList;
- (CombatReplaySkillStepProto*)skillsAtIndex:(NSUInteger)index;
- (CombatReplayStepProto_Builder *)addSkills:(CombatReplaySkillStepProto*)value;
- (CombatReplayStepProto_Builder *)addAllSkills:(NSArray *)array;
- (CombatReplayStepProto_Builder *)clearSkills;

- (BOOL) hasSwapIndex;
- (int32_t) swapIndex;
- (CombatReplayStepProto_Builder*) setSwapIndex:(int32_t) value;
- (CombatReplayStepProto_Builder*) clearSwapIndex;

- (BOOL) hasVinePos;
- (uint32_t) vinePos;
- (CombatReplayStepProto_Builder*) setVinePos:(uint32_t) value;
- (CombatReplayStepProto_Builder*) clearVinePos;
@end

@interface CombatReplaySkillStepProto : PBGeneratedMessage {
@private
  BOOL hasBelongsToPlayer_:1;
  BOOL hasSkillId_:1;
  BOOL hasOwnerMonsterId_:1;
  BOOL belongsToPlayer_:1;
  int32_t skillId;
  int32_t ownerMonsterId;
}
- (BOOL) hasSkillId;
- (BOOL) hasBelongsToPlayer;
- (BOOL) hasOwnerMonsterId;
@property (readonly) int32_t skillId;
- (BOOL) belongsToPlayer;
@property (readonly) int32_t ownerMonsterId;

+ (CombatReplaySkillStepProto*) defaultInstance;
- (CombatReplaySkillStepProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (CombatReplaySkillStepProto_Builder*) builder;
+ (CombatReplaySkillStepProto_Builder*) builder;
+ (CombatReplaySkillStepProto_Builder*) builderWithPrototype:(CombatReplaySkillStepProto*) prototype;
- (CombatReplaySkillStepProto_Builder*) toBuilder;

+ (CombatReplaySkillStepProto*) parseFromData:(NSData*) data;
+ (CombatReplaySkillStepProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CombatReplaySkillStepProto*) parseFromInputStream:(NSInputStream*) input;
+ (CombatReplaySkillStepProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CombatReplaySkillStepProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (CombatReplaySkillStepProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface CombatReplaySkillStepProto_Builder : PBGeneratedMessageBuilder {
@private
  CombatReplaySkillStepProto* result;
}

- (CombatReplaySkillStepProto*) defaultInstance;

- (CombatReplaySkillStepProto_Builder*) clear;
- (CombatReplaySkillStepProto_Builder*) clone;

- (CombatReplaySkillStepProto*) build;
- (CombatReplaySkillStepProto*) buildPartial;

- (CombatReplaySkillStepProto_Builder*) mergeFrom:(CombatReplaySkillStepProto*) other;
- (CombatReplaySkillStepProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (CombatReplaySkillStepProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSkillId;
- (int32_t) skillId;
- (CombatReplaySkillStepProto_Builder*) setSkillId:(int32_t) value;
- (CombatReplaySkillStepProto_Builder*) clearSkillId;

- (BOOL) hasBelongsToPlayer;
- (BOOL) belongsToPlayer;
- (CombatReplaySkillStepProto_Builder*) setBelongsToPlayer:(BOOL) value;
- (CombatReplaySkillStepProto_Builder*) clearBelongsToPlayer;

- (BOOL) hasOwnerMonsterId;
- (int32_t) ownerMonsterId;
- (CombatReplaySkillStepProto_Builder*) setOwnerMonsterId:(int32_t) value;
- (CombatReplaySkillStepProto_Builder*) clearOwnerMonsterId;
@end

@interface CombatReplayScheduleProto : PBGeneratedMessage {
@private
  BOOL hasTotalTurns_:1;
  BOOL hasStartingTurn_:1;
  int32_t totalTurns;
  int32_t startingTurn;
  PBAppendableArray * mutablePlayerTurnsList;
}
- (BOOL) hasTotalTurns;
- (BOOL) hasStartingTurn;
@property (readonly) int32_t totalTurns;
@property (readonly, strong) PBArray * playerTurnsList;
@property (readonly) int32_t startingTurn;
- (int32_t)playerTurnsAtIndex:(NSUInteger)index;

+ (CombatReplayScheduleProto*) defaultInstance;
- (CombatReplayScheduleProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (CombatReplayScheduleProto_Builder*) builder;
+ (CombatReplayScheduleProto_Builder*) builder;
+ (CombatReplayScheduleProto_Builder*) builderWithPrototype:(CombatReplayScheduleProto*) prototype;
- (CombatReplayScheduleProto_Builder*) toBuilder;

+ (CombatReplayScheduleProto*) parseFromData:(NSData*) data;
+ (CombatReplayScheduleProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CombatReplayScheduleProto*) parseFromInputStream:(NSInputStream*) input;
+ (CombatReplayScheduleProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CombatReplayScheduleProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (CombatReplayScheduleProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface CombatReplayScheduleProto_Builder : PBGeneratedMessageBuilder {
@private
  CombatReplayScheduleProto* result;
}

- (CombatReplayScheduleProto*) defaultInstance;

- (CombatReplayScheduleProto_Builder*) clear;
- (CombatReplayScheduleProto_Builder*) clone;

- (CombatReplayScheduleProto*) build;
- (CombatReplayScheduleProto*) buildPartial;

- (CombatReplayScheduleProto_Builder*) mergeFrom:(CombatReplayScheduleProto*) other;
- (CombatReplayScheduleProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (CombatReplayScheduleProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasTotalTurns;
- (int32_t) totalTurns;
- (CombatReplayScheduleProto_Builder*) setTotalTurns:(int32_t) value;
- (CombatReplayScheduleProto_Builder*) clearTotalTurns;

- (PBAppendableArray *)playerTurnsList;
- (int32_t)playerTurnsAtIndex:(NSUInteger)index;
- (CombatReplayScheduleProto_Builder *)addPlayerTurns:(int32_t)value;
- (CombatReplayScheduleProto_Builder *)addAllPlayerTurns:(NSArray *)array;
- (CombatReplayScheduleProto_Builder *)setPlayerTurnsValues:(const int32_t *)values count:(NSUInteger)count;
- (CombatReplayScheduleProto_Builder *)clearPlayerTurns;

- (BOOL) hasStartingTurn;
- (int32_t) startingTurn;
- (CombatReplayScheduleProto_Builder*) setStartingTurn:(int32_t) value;
- (CombatReplayScheduleProto_Builder*) clearStartingTurn;
@end

@interface CombatReplayOrbProto : PBGeneratedMessage {
@private
  BOOL hasInitialOrb_:1;
  BOOL hasSpawnedRow_:1;
  BOOL hasSpawnedCol_:1;
  BOOL hasSpecial_:1;
  BOOL hasPower_:1;
  BOOL hasOrbId_:1;
  BOOL hasSpawnedElement_:1;
  BOOL initialOrb_:1;
  int32_t spawnedRow;
  int32_t spawnedCol;
  int32_t special;
  int32_t power;
  int32_t orbId;
  Element spawnedElement;
}
- (BOOL) hasSpawnedRow;
- (BOOL) hasSpawnedCol;
- (BOOL) hasSpawnedElement;
- (BOOL) hasInitialOrb;
- (BOOL) hasSpecial;
- (BOOL) hasPower;
- (BOOL) hasOrbId;
@property (readonly) int32_t spawnedRow;
@property (readonly) int32_t spawnedCol;
@property (readonly) Element spawnedElement;
- (BOOL) initialOrb;
@property (readonly) int32_t special;
@property (readonly) int32_t power;
@property (readonly) int32_t orbId;

+ (CombatReplayOrbProto*) defaultInstance;
- (CombatReplayOrbProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (CombatReplayOrbProto_Builder*) builder;
+ (CombatReplayOrbProto_Builder*) builder;
+ (CombatReplayOrbProto_Builder*) builderWithPrototype:(CombatReplayOrbProto*) prototype;
- (CombatReplayOrbProto_Builder*) toBuilder;

+ (CombatReplayOrbProto*) parseFromData:(NSData*) data;
+ (CombatReplayOrbProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CombatReplayOrbProto*) parseFromInputStream:(NSInputStream*) input;
+ (CombatReplayOrbProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CombatReplayOrbProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (CombatReplayOrbProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface CombatReplayOrbProto_Builder : PBGeneratedMessageBuilder {
@private
  CombatReplayOrbProto* result;
}

- (CombatReplayOrbProto*) defaultInstance;

- (CombatReplayOrbProto_Builder*) clear;
- (CombatReplayOrbProto_Builder*) clone;

- (CombatReplayOrbProto*) build;
- (CombatReplayOrbProto*) buildPartial;

- (CombatReplayOrbProto_Builder*) mergeFrom:(CombatReplayOrbProto*) other;
- (CombatReplayOrbProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (CombatReplayOrbProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSpawnedRow;
- (int32_t) spawnedRow;
- (CombatReplayOrbProto_Builder*) setSpawnedRow:(int32_t) value;
- (CombatReplayOrbProto_Builder*) clearSpawnedRow;

- (BOOL) hasSpawnedCol;
- (int32_t) spawnedCol;
- (CombatReplayOrbProto_Builder*) setSpawnedCol:(int32_t) value;
- (CombatReplayOrbProto_Builder*) clearSpawnedCol;

- (BOOL) hasSpawnedElement;
- (Element) spawnedElement;
- (CombatReplayOrbProto_Builder*) setSpawnedElement:(Element) value;
- (CombatReplayOrbProto_Builder*) clearSpawnedElementList;

- (BOOL) hasInitialOrb;
- (BOOL) initialOrb;
- (CombatReplayOrbProto_Builder*) setInitialOrb:(BOOL) value;
- (CombatReplayOrbProto_Builder*) clearInitialOrb;

- (BOOL) hasSpecial;
- (int32_t) special;
- (CombatReplayOrbProto_Builder*) setSpecial:(int32_t) value;
- (CombatReplayOrbProto_Builder*) clearSpecial;

- (BOOL) hasPower;
- (int32_t) power;
- (CombatReplayOrbProto_Builder*) setPower:(int32_t) value;
- (CombatReplayOrbProto_Builder*) clearPower;

- (BOOL) hasOrbId;
- (int32_t) orbId;
- (CombatReplayOrbProto_Builder*) setOrbId:(int32_t) value;
- (CombatReplayOrbProto_Builder*) clearOrbId;
@end

@interface CombatReplayMonsterSnapshot : PBGeneratedMessage {
@private
  BOOL hasMonsterId_:1;
  BOOL hasStartingHealth_:1;
  BOOL hasMaxHealth_:1;
  BOOL hasLevel_:1;
  BOOL hasSlotNum_:1;
  BOOL hasDroppedLoot_:1;
  BOOL hasSkillSnapshot_:1;
  int32_t monsterId;
  int32_t startingHealth;
  int32_t maxHealth;
  int32_t level;
  int32_t slotNum;
  int32_t droppedLoot;
  SkillProto* skillSnapshot;
}
- (BOOL) hasMonsterId;
- (BOOL) hasStartingHealth;
- (BOOL) hasMaxHealth;
- (BOOL) hasSkillSnapshot;
- (BOOL) hasLevel;
- (BOOL) hasSlotNum;
- (BOOL) hasDroppedLoot;
@property (readonly) int32_t monsterId;
@property (readonly) int32_t startingHealth;
@property (readonly) int32_t maxHealth;
@property (readonly, strong) SkillProto* skillSnapshot;
@property (readonly) int32_t level;
@property (readonly) int32_t slotNum;
@property (readonly) int32_t droppedLoot;

+ (CombatReplayMonsterSnapshot*) defaultInstance;
- (CombatReplayMonsterSnapshot*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (CombatReplayMonsterSnapshot_Builder*) builder;
+ (CombatReplayMonsterSnapshot_Builder*) builder;
+ (CombatReplayMonsterSnapshot_Builder*) builderWithPrototype:(CombatReplayMonsterSnapshot*) prototype;
- (CombatReplayMonsterSnapshot_Builder*) toBuilder;

+ (CombatReplayMonsterSnapshot*) parseFromData:(NSData*) data;
+ (CombatReplayMonsterSnapshot*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CombatReplayMonsterSnapshot*) parseFromInputStream:(NSInputStream*) input;
+ (CombatReplayMonsterSnapshot*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CombatReplayMonsterSnapshot*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (CombatReplayMonsterSnapshot*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface CombatReplayMonsterSnapshot_Builder : PBGeneratedMessageBuilder {
@private
  CombatReplayMonsterSnapshot* result;
}

- (CombatReplayMonsterSnapshot*) defaultInstance;

- (CombatReplayMonsterSnapshot_Builder*) clear;
- (CombatReplayMonsterSnapshot_Builder*) clone;

- (CombatReplayMonsterSnapshot*) build;
- (CombatReplayMonsterSnapshot*) buildPartial;

- (CombatReplayMonsterSnapshot_Builder*) mergeFrom:(CombatReplayMonsterSnapshot*) other;
- (CombatReplayMonsterSnapshot_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (CombatReplayMonsterSnapshot_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasMonsterId;
- (int32_t) monsterId;
- (CombatReplayMonsterSnapshot_Builder*) setMonsterId:(int32_t) value;
- (CombatReplayMonsterSnapshot_Builder*) clearMonsterId;

- (BOOL) hasStartingHealth;
- (int32_t) startingHealth;
- (CombatReplayMonsterSnapshot_Builder*) setStartingHealth:(int32_t) value;
- (CombatReplayMonsterSnapshot_Builder*) clearStartingHealth;

- (BOOL) hasMaxHealth;
- (int32_t) maxHealth;
- (CombatReplayMonsterSnapshot_Builder*) setMaxHealth:(int32_t) value;
- (CombatReplayMonsterSnapshot_Builder*) clearMaxHealth;

- (BOOL) hasSkillSnapshot;
- (SkillProto*) skillSnapshot;
- (CombatReplayMonsterSnapshot_Builder*) setSkillSnapshot:(SkillProto*) value;
- (CombatReplayMonsterSnapshot_Builder*) setSkillSnapshot_Builder:(SkillProto_Builder*) builderForValue;
- (CombatReplayMonsterSnapshot_Builder*) mergeSkillSnapshot:(SkillProto*) value;
- (CombatReplayMonsterSnapshot_Builder*) clearSkillSnapshot;

- (BOOL) hasLevel;
- (int32_t) level;
- (CombatReplayMonsterSnapshot_Builder*) setLevel:(int32_t) value;
- (CombatReplayMonsterSnapshot_Builder*) clearLevel;

- (BOOL) hasSlotNum;
- (int32_t) slotNum;
- (CombatReplayMonsterSnapshot_Builder*) setSlotNum:(int32_t) value;
- (CombatReplayMonsterSnapshot_Builder*) clearSlotNum;

- (BOOL) hasDroppedLoot;
- (int32_t) droppedLoot;
- (CombatReplayMonsterSnapshot_Builder*) setDroppedLoot:(int32_t) value;
- (CombatReplayMonsterSnapshot_Builder*) clearDroppedLoot;
@end


// @@protoc_insertion_point(global_scope)
