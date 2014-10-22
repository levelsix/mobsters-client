// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "MonsterStuff.pb.h"
#import "Quest.pb.h"
#import "SharedEnumConfig.pb.h"
// @@protoc_insertion_point(imports)

@class ClanHouseProto;
@class ClanHouseProto_Builder;
@class ColorProto;
@class ColorProto_Builder;
@class CoordinateProto;
@class CoordinateProto_Builder;
@class DialogueProto;
@class DialogueProto_Builder;
@class DialogueProto_SpeechSegmentProto;
@class DialogueProto_SpeechSegmentProto_Builder;
@class EvoChamberProto;
@class EvoChamberProto_Builder;
@class FullQuestProto;
@class FullQuestProto_Builder;
@class FullTaskProto;
@class FullTaskProto_Builder;
@class FullUserMonsterProto;
@class FullUserMonsterProto_Builder;
@class FullUserProto;
@class FullUserProto_Builder;
@class FullUserQuestProto;
@class FullUserQuestProto_Builder;
@class FullUserStructureProto;
@class FullUserStructureProto_Builder;
@class GroupChatMessageProto;
@class GroupChatMessageProto_Builder;
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
@class MinimumUserMonsterProto;
@class MinimumUserMonsterProto_Builder;
@class MinimumUserMonsterSellProto;
@class MinimumUserMonsterSellProto_Builder;
@class MinimumUserProto;
@class MinimumUserProtoWithFacebookId;
@class MinimumUserProtoWithFacebookId_Builder;
@class MinimumUserProtoWithLevel;
@class MinimumUserProtoWithLevel_Builder;
@class MinimumUserProtoWithMaxResources;
@class MinimumUserProtoWithMaxResources_Builder;
@class MinimumUserProto_Builder;
@class MinimumUserTaskProto;
@class MinimumUserTaskProto_Builder;
@class MonsterBattleDialogueProto;
@class MonsterBattleDialogueProto_Builder;
@class MonsterLevelInfoProto;
@class MonsterLevelInfoProto_Builder;
@class MonsterProto;
@class MonsterProto_Builder;
@class ObstacleProto;
@class ObstacleProto_Builder;
@class PersistentEventProto;
@class PersistentEventProto_Builder;
@class PrivateChatPostProto;
@class PrivateChatPostProto_Builder;
@class QuestJobProto;
@class QuestJobProto_Builder;
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
@class TaskMapElementProto;
@class TaskMapElementProto_Builder;
@class TaskStageMonsterProto;
@class TaskStageMonsterProto_Builder;
@class TaskStageProto;
@class TaskStageProto_Builder;
@class TeamCenterProto;
@class TeamCenterProto_Builder;
@class TownHallProto;
@class TownHallProto_Builder;
@class TutorialStructProto;
@class TutorialStructProto_Builder;
@class UserCurrentMonsterTeamProto;
@class UserCurrentMonsterTeamProto_Builder;
@class UserEnhancementItemProto;
@class UserEnhancementItemProto_Builder;
@class UserEnhancementProto;
@class UserEnhancementProto_Builder;
@class UserFacebookInviteForSlotProto;
@class UserFacebookInviteForSlotProto_Builder;
@class UserMonsterCurrentExpProto;
@class UserMonsterCurrentExpProto_Builder;
@class UserMonsterCurrentHealthProto;
@class UserMonsterCurrentHealthProto_Builder;
@class UserMonsterEvolutionProto;
@class UserMonsterEvolutionProto_Builder;
@class UserMonsterHealingProto;
@class UserMonsterHealingProto_Builder;
@class UserObstacleProto;
@class UserObstacleProto_Builder;
@class UserPersistentEventProto;
@class UserPersistentEventProto_Builder;
@class UserPvpLeagueProto;
@class UserPvpLeagueProto_Builder;
@class UserQuestJobProto;
@class UserQuestJobProto_Builder;
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
  TaskStageMonsterProto_MonsterTypeRegular = 1,
  TaskStageMonsterProto_MonsterTypeMiniBoss = 2,
  TaskStageMonsterProto_MonsterTypeBoss = 3,
} TaskStageMonsterProto_MonsterType;

BOOL TaskStageMonsterProto_MonsterTypeIsValidValue(TaskStageMonsterProto_MonsterType value);

typedef enum {
  PersistentEventProto_EventTypeEnhance = 1,
  PersistentEventProto_EventTypeEvolution = 2,
} PersistentEventProto_EventType;

BOOL PersistentEventProto_EventTypeIsValidValue(PersistentEventProto_EventType value);


@interface TaskRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface TaskStageProto : PBGeneratedMessage {
@private
  BOOL hasStageId_:1;
  int32_t stageId;
  NSMutableArray * mutableStageMonstersList;
}
- (BOOL) hasStageId;
@property (readonly) int32_t stageId;
@property (readonly, strong) NSArray * stageMonstersList;
- (TaskStageMonsterProto*)stageMonstersAtIndex:(NSUInteger)index;

+ (TaskStageProto*) defaultInstance;
- (TaskStageProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (TaskStageProto_Builder*) builder;
+ (TaskStageProto_Builder*) builder;
+ (TaskStageProto_Builder*) builderWithPrototype:(TaskStageProto*) prototype;
- (TaskStageProto_Builder*) toBuilder;

+ (TaskStageProto*) parseFromData:(NSData*) data;
+ (TaskStageProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (TaskStageProto*) parseFromInputStream:(NSInputStream*) input;
+ (TaskStageProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (TaskStageProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (TaskStageProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface TaskStageProto_Builder : PBGeneratedMessageBuilder {
@private
  TaskStageProto* result;
}

- (TaskStageProto*) defaultInstance;

- (TaskStageProto_Builder*) clear;
- (TaskStageProto_Builder*) clone;

- (TaskStageProto*) build;
- (TaskStageProto*) buildPartial;

- (TaskStageProto_Builder*) mergeFrom:(TaskStageProto*) other;
- (TaskStageProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (TaskStageProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasStageId;
- (int32_t) stageId;
- (TaskStageProto_Builder*) setStageId:(int32_t) value;
- (TaskStageProto_Builder*) clearStageId;

- (NSMutableArray *)stageMonstersList;
- (TaskStageMonsterProto*)stageMonstersAtIndex:(NSUInteger)index;
- (TaskStageProto_Builder *)addStageMonsters:(TaskStageMonsterProto*)value;
- (TaskStageProto_Builder *)addAllStageMonsters:(NSArray *)array;
- (TaskStageProto_Builder *)clearStageMonsters;
@end

@interface FullTaskProto : PBGeneratedMessage {
@private
  BOOL hasTaskId_:1;
  BOOL hasCityId_:1;
  BOOL hasAssetNumWithinCity_:1;
  BOOL hasPrerequisiteTaskId_:1;
  BOOL hasPrerequisiteQuestId_:1;
  BOOL hasBoardWidth_:1;
  BOOL hasBoardHeight_:1;
  BOOL hasName_:1;
  BOOL hasDescription_:1;
  BOOL hasGroundImgPrefix_:1;
  BOOL hasInitialDefeatedDialogue_:1;
  int32_t taskId;
  int32_t cityId;
  int32_t assetNumWithinCity;
  int32_t prerequisiteTaskId;
  int32_t prerequisiteQuestId;
  int32_t boardWidth;
  int32_t boardHeight;
  NSString* name;
  NSString* description;
  NSString* groundImgPrefix;
  DialogueProto* initialDefeatedDialogue;
}
- (BOOL) hasTaskId;
- (BOOL) hasName;
- (BOOL) hasDescription;
- (BOOL) hasCityId;
- (BOOL) hasAssetNumWithinCity;
- (BOOL) hasPrerequisiteTaskId;
- (BOOL) hasPrerequisiteQuestId;
- (BOOL) hasBoardWidth;
- (BOOL) hasBoardHeight;
- (BOOL) hasGroundImgPrefix;
- (BOOL) hasInitialDefeatedDialogue;
@property (readonly) int32_t taskId;
@property (readonly, strong) NSString* name;
@property (readonly, strong) NSString* description;
@property (readonly) int32_t cityId;
@property (readonly) int32_t assetNumWithinCity;
@property (readonly) int32_t prerequisiteTaskId;
@property (readonly) int32_t prerequisiteQuestId;
@property (readonly) int32_t boardWidth;
@property (readonly) int32_t boardHeight;
@property (readonly, strong) NSString* groundImgPrefix;
@property (readonly, strong) DialogueProto* initialDefeatedDialogue;

+ (FullTaskProto*) defaultInstance;
- (FullTaskProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (FullTaskProto_Builder*) builder;
+ (FullTaskProto_Builder*) builder;
+ (FullTaskProto_Builder*) builderWithPrototype:(FullTaskProto*) prototype;
- (FullTaskProto_Builder*) toBuilder;

+ (FullTaskProto*) parseFromData:(NSData*) data;
+ (FullTaskProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FullTaskProto*) parseFromInputStream:(NSInputStream*) input;
+ (FullTaskProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FullTaskProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (FullTaskProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface FullTaskProto_Builder : PBGeneratedMessageBuilder {
@private
  FullTaskProto* result;
}

- (FullTaskProto*) defaultInstance;

- (FullTaskProto_Builder*) clear;
- (FullTaskProto_Builder*) clone;

- (FullTaskProto*) build;
- (FullTaskProto*) buildPartial;

- (FullTaskProto_Builder*) mergeFrom:(FullTaskProto*) other;
- (FullTaskProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (FullTaskProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasTaskId;
- (int32_t) taskId;
- (FullTaskProto_Builder*) setTaskId:(int32_t) value;
- (FullTaskProto_Builder*) clearTaskId;

- (BOOL) hasName;
- (NSString*) name;
- (FullTaskProto_Builder*) setName:(NSString*) value;
- (FullTaskProto_Builder*) clearName;

- (BOOL) hasDescription;
- (NSString*) description;
- (FullTaskProto_Builder*) setDescription:(NSString*) value;
- (FullTaskProto_Builder*) clearDescription;

- (BOOL) hasCityId;
- (int32_t) cityId;
- (FullTaskProto_Builder*) setCityId:(int32_t) value;
- (FullTaskProto_Builder*) clearCityId;

- (BOOL) hasAssetNumWithinCity;
- (int32_t) assetNumWithinCity;
- (FullTaskProto_Builder*) setAssetNumWithinCity:(int32_t) value;
- (FullTaskProto_Builder*) clearAssetNumWithinCity;

- (BOOL) hasPrerequisiteTaskId;
- (int32_t) prerequisiteTaskId;
- (FullTaskProto_Builder*) setPrerequisiteTaskId:(int32_t) value;
- (FullTaskProto_Builder*) clearPrerequisiteTaskId;

- (BOOL) hasPrerequisiteQuestId;
- (int32_t) prerequisiteQuestId;
- (FullTaskProto_Builder*) setPrerequisiteQuestId:(int32_t) value;
- (FullTaskProto_Builder*) clearPrerequisiteQuestId;

- (BOOL) hasBoardWidth;
- (int32_t) boardWidth;
- (FullTaskProto_Builder*) setBoardWidth:(int32_t) value;
- (FullTaskProto_Builder*) clearBoardWidth;

- (BOOL) hasBoardHeight;
- (int32_t) boardHeight;
- (FullTaskProto_Builder*) setBoardHeight:(int32_t) value;
- (FullTaskProto_Builder*) clearBoardHeight;

- (BOOL) hasGroundImgPrefix;
- (NSString*) groundImgPrefix;
- (FullTaskProto_Builder*) setGroundImgPrefix:(NSString*) value;
- (FullTaskProto_Builder*) clearGroundImgPrefix;

- (BOOL) hasInitialDefeatedDialogue;
- (DialogueProto*) initialDefeatedDialogue;
- (FullTaskProto_Builder*) setInitialDefeatedDialogue:(DialogueProto*) value;
- (FullTaskProto_Builder*) setInitialDefeatedDialogue_Builder:(DialogueProto_Builder*) builderForValue;
- (FullTaskProto_Builder*) mergeInitialDefeatedDialogue:(DialogueProto*) value;
- (FullTaskProto_Builder*) clearInitialDefeatedDialogue;
@end

@interface MinimumUserTaskProto : PBGeneratedMessage {
@private
  BOOL hasUserTaskId_:1;
  BOOL hasUserId_:1;
  BOOL hasTaskId_:1;
  BOOL hasCurTaskStageId_:1;
  int64_t userTaskId;
  int32_t userId;
  int32_t taskId;
  int32_t curTaskStageId;
}
- (BOOL) hasUserId;
- (BOOL) hasTaskId;
- (BOOL) hasCurTaskStageId;
- (BOOL) hasUserTaskId;
@property (readonly) int32_t userId;
@property (readonly) int32_t taskId;
@property (readonly) int32_t curTaskStageId;
@property (readonly) int64_t userTaskId;

+ (MinimumUserTaskProto*) defaultInstance;
- (MinimumUserTaskProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (MinimumUserTaskProto_Builder*) builder;
+ (MinimumUserTaskProto_Builder*) builder;
+ (MinimumUserTaskProto_Builder*) builderWithPrototype:(MinimumUserTaskProto*) prototype;
- (MinimumUserTaskProto_Builder*) toBuilder;

+ (MinimumUserTaskProto*) parseFromData:(NSData*) data;
+ (MinimumUserTaskProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (MinimumUserTaskProto*) parseFromInputStream:(NSInputStream*) input;
+ (MinimumUserTaskProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (MinimumUserTaskProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (MinimumUserTaskProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface MinimumUserTaskProto_Builder : PBGeneratedMessageBuilder {
@private
  MinimumUserTaskProto* result;
}

- (MinimumUserTaskProto*) defaultInstance;

- (MinimumUserTaskProto_Builder*) clear;
- (MinimumUserTaskProto_Builder*) clone;

- (MinimumUserTaskProto*) build;
- (MinimumUserTaskProto*) buildPartial;

- (MinimumUserTaskProto_Builder*) mergeFrom:(MinimumUserTaskProto*) other;
- (MinimumUserTaskProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (MinimumUserTaskProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasUserId;
- (int32_t) userId;
- (MinimumUserTaskProto_Builder*) setUserId:(int32_t) value;
- (MinimumUserTaskProto_Builder*) clearUserId;

- (BOOL) hasTaskId;
- (int32_t) taskId;
- (MinimumUserTaskProto_Builder*) setTaskId:(int32_t) value;
- (MinimumUserTaskProto_Builder*) clearTaskId;

- (BOOL) hasCurTaskStageId;
- (int32_t) curTaskStageId;
- (MinimumUserTaskProto_Builder*) setCurTaskStageId:(int32_t) value;
- (MinimumUserTaskProto_Builder*) clearCurTaskStageId;

- (BOOL) hasUserTaskId;
- (int64_t) userTaskId;
- (MinimumUserTaskProto_Builder*) setUserTaskId:(int64_t) value;
- (MinimumUserTaskProto_Builder*) clearUserTaskId;
@end

@interface TaskStageMonsterProto : PBGeneratedMessage {
@private
  BOOL hasPuzzlePieceDropped_:1;
  BOOL hasDmgMultiplier_:1;
  BOOL hasTsfuId_:1;
  BOOL hasTsmId_:1;
  BOOL hasMonsterId_:1;
  BOOL hasLevel_:1;
  BOOL hasExpReward_:1;
  BOOL hasCashReward_:1;
  BOOL hasOilReward_:1;
  BOOL hasPuzzlePieceMonsterId_:1;
  BOOL hasItemId_:1;
  BOOL hasDefensiveSkillId_:1;
  BOOL hasOffensiveSkillId_:1;
  BOOL hasPuzzlePieceMonsterDropLvl_:1;
  BOOL hasInitialD_:1;
  BOOL hasDefaultD_:1;
  BOOL hasMonsterType_:1;
  BOOL puzzlePieceDropped_:1;
  Float32 dmgMultiplier;
  int64_t tsfuId;
  int32_t tsmId;
  int32_t monsterId;
  int32_t level;
  int32_t expReward;
  int32_t cashReward;
  int32_t oilReward;
  int32_t puzzlePieceMonsterId;
  int32_t itemId;
  int32_t defensiveSkillId;
  int32_t offensiveSkillId;
  int32_t puzzlePieceMonsterDropLvl;
  DialogueProto* initialD;
  DialogueProto* defaultD;
  TaskStageMonsterProto_MonsterType monsterType;
}
- (BOOL) hasTsfuId;
- (BOOL) hasTsmId;
- (BOOL) hasMonsterId;
- (BOOL) hasMonsterType;
- (BOOL) hasLevel;
- (BOOL) hasExpReward;
- (BOOL) hasCashReward;
- (BOOL) hasOilReward;
- (BOOL) hasPuzzlePieceDropped;
- (BOOL) hasPuzzlePieceMonsterId;
- (BOOL) hasItemId;
- (BOOL) hasDmgMultiplier;
- (BOOL) hasDefensiveSkillId;
- (BOOL) hasOffensiveSkillId;
- (BOOL) hasPuzzlePieceMonsterDropLvl;
- (BOOL) hasInitialD;
- (BOOL) hasDefaultD;
@property (readonly) int64_t tsfuId;
@property (readonly) int32_t tsmId;
@property (readonly) int32_t monsterId;
@property (readonly) TaskStageMonsterProto_MonsterType monsterType;
@property (readonly) int32_t level;
@property (readonly) int32_t expReward;
@property (readonly) int32_t cashReward;
@property (readonly) int32_t oilReward;
- (BOOL) puzzlePieceDropped;
@property (readonly) int32_t puzzlePieceMonsterId;
@property (readonly) int32_t itemId;
@property (readonly) Float32 dmgMultiplier;
@property (readonly) int32_t defensiveSkillId;
@property (readonly) int32_t offensiveSkillId;
@property (readonly) int32_t puzzlePieceMonsterDropLvl;
@property (readonly, strong) DialogueProto* initialD;
@property (readonly, strong) DialogueProto* defaultD;

+ (TaskStageMonsterProto*) defaultInstance;
- (TaskStageMonsterProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (TaskStageMonsterProto_Builder*) builder;
+ (TaskStageMonsterProto_Builder*) builder;
+ (TaskStageMonsterProto_Builder*) builderWithPrototype:(TaskStageMonsterProto*) prototype;
- (TaskStageMonsterProto_Builder*) toBuilder;

+ (TaskStageMonsterProto*) parseFromData:(NSData*) data;
+ (TaskStageMonsterProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (TaskStageMonsterProto*) parseFromInputStream:(NSInputStream*) input;
+ (TaskStageMonsterProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (TaskStageMonsterProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (TaskStageMonsterProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface TaskStageMonsterProto_Builder : PBGeneratedMessageBuilder {
@private
  TaskStageMonsterProto* result;
}

- (TaskStageMonsterProto*) defaultInstance;

- (TaskStageMonsterProto_Builder*) clear;
- (TaskStageMonsterProto_Builder*) clone;

- (TaskStageMonsterProto*) build;
- (TaskStageMonsterProto*) buildPartial;

- (TaskStageMonsterProto_Builder*) mergeFrom:(TaskStageMonsterProto*) other;
- (TaskStageMonsterProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (TaskStageMonsterProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasTsfuId;
- (int64_t) tsfuId;
- (TaskStageMonsterProto_Builder*) setTsfuId:(int64_t) value;
- (TaskStageMonsterProto_Builder*) clearTsfuId;

- (BOOL) hasTsmId;
- (int32_t) tsmId;
- (TaskStageMonsterProto_Builder*) setTsmId:(int32_t) value;
- (TaskStageMonsterProto_Builder*) clearTsmId;

- (BOOL) hasMonsterId;
- (int32_t) monsterId;
- (TaskStageMonsterProto_Builder*) setMonsterId:(int32_t) value;
- (TaskStageMonsterProto_Builder*) clearMonsterId;

- (BOOL) hasMonsterType;
- (TaskStageMonsterProto_MonsterType) monsterType;
- (TaskStageMonsterProto_Builder*) setMonsterType:(TaskStageMonsterProto_MonsterType) value;
- (TaskStageMonsterProto_Builder*) clearMonsterType;

- (BOOL) hasLevel;
- (int32_t) level;
- (TaskStageMonsterProto_Builder*) setLevel:(int32_t) value;
- (TaskStageMonsterProto_Builder*) clearLevel;

- (BOOL) hasExpReward;
- (int32_t) expReward;
- (TaskStageMonsterProto_Builder*) setExpReward:(int32_t) value;
- (TaskStageMonsterProto_Builder*) clearExpReward;

- (BOOL) hasCashReward;
- (int32_t) cashReward;
- (TaskStageMonsterProto_Builder*) setCashReward:(int32_t) value;
- (TaskStageMonsterProto_Builder*) clearCashReward;

- (BOOL) hasOilReward;
- (int32_t) oilReward;
- (TaskStageMonsterProto_Builder*) setOilReward:(int32_t) value;
- (TaskStageMonsterProto_Builder*) clearOilReward;

- (BOOL) hasPuzzlePieceDropped;
- (BOOL) puzzlePieceDropped;
- (TaskStageMonsterProto_Builder*) setPuzzlePieceDropped:(BOOL) value;
- (TaskStageMonsterProto_Builder*) clearPuzzlePieceDropped;

- (BOOL) hasPuzzlePieceMonsterId;
- (int32_t) puzzlePieceMonsterId;
- (TaskStageMonsterProto_Builder*) setPuzzlePieceMonsterId:(int32_t) value;
- (TaskStageMonsterProto_Builder*) clearPuzzlePieceMonsterId;

- (BOOL) hasItemId;
- (int32_t) itemId;
- (TaskStageMonsterProto_Builder*) setItemId:(int32_t) value;
- (TaskStageMonsterProto_Builder*) clearItemId;

- (BOOL) hasDmgMultiplier;
- (Float32) dmgMultiplier;
- (TaskStageMonsterProto_Builder*) setDmgMultiplier:(Float32) value;
- (TaskStageMonsterProto_Builder*) clearDmgMultiplier;

- (BOOL) hasDefensiveSkillId;
- (int32_t) defensiveSkillId;
- (TaskStageMonsterProto_Builder*) setDefensiveSkillId:(int32_t) value;
- (TaskStageMonsterProto_Builder*) clearDefensiveSkillId;

- (BOOL) hasOffensiveSkillId;
- (int32_t) offensiveSkillId;
- (TaskStageMonsterProto_Builder*) setOffensiveSkillId:(int32_t) value;
- (TaskStageMonsterProto_Builder*) clearOffensiveSkillId;

- (BOOL) hasPuzzlePieceMonsterDropLvl;
- (int32_t) puzzlePieceMonsterDropLvl;
- (TaskStageMonsterProto_Builder*) setPuzzlePieceMonsterDropLvl:(int32_t) value;
- (TaskStageMonsterProto_Builder*) clearPuzzlePieceMonsterDropLvl;

- (BOOL) hasInitialD;
- (DialogueProto*) initialD;
- (TaskStageMonsterProto_Builder*) setInitialD:(DialogueProto*) value;
- (TaskStageMonsterProto_Builder*) setInitialD_Builder:(DialogueProto_Builder*) builderForValue;
- (TaskStageMonsterProto_Builder*) mergeInitialD:(DialogueProto*) value;
- (TaskStageMonsterProto_Builder*) clearInitialD;

- (BOOL) hasDefaultD;
- (DialogueProto*) defaultD;
- (TaskStageMonsterProto_Builder*) setDefaultD:(DialogueProto*) value;
- (TaskStageMonsterProto_Builder*) setDefaultD_Builder:(DialogueProto_Builder*) builderForValue;
- (TaskStageMonsterProto_Builder*) mergeDefaultD:(DialogueProto*) value;
- (TaskStageMonsterProto_Builder*) clearDefaultD;
@end

@interface PersistentEventProto : PBGeneratedMessage {
@private
  BOOL hasEventId_:1;
  BOOL hasStartHour_:1;
  BOOL hasEventDurationMinutes_:1;
  BOOL hasTaskId_:1;
  BOOL hasCooldownMinutes_:1;
  BOOL hasDayOfWeek_:1;
  BOOL hasType_:1;
  BOOL hasMonsterElement_:1;
  int32_t eventId;
  int32_t startHour;
  int32_t eventDurationMinutes;
  int32_t taskId;
  int32_t cooldownMinutes;
  DayOfWeek dayOfWeek;
  PersistentEventProto_EventType type;
  Element monsterElement;
}
- (BOOL) hasEventId;
- (BOOL) hasDayOfWeek;
- (BOOL) hasStartHour;
- (BOOL) hasEventDurationMinutes;
- (BOOL) hasTaskId;
- (BOOL) hasCooldownMinutes;
- (BOOL) hasType;
- (BOOL) hasMonsterElement;
@property (readonly) int32_t eventId;
@property (readonly) DayOfWeek dayOfWeek;
@property (readonly) int32_t startHour;
@property (readonly) int32_t eventDurationMinutes;
@property (readonly) int32_t taskId;
@property (readonly) int32_t cooldownMinutes;
@property (readonly) PersistentEventProto_EventType type;
@property (readonly) Element monsterElement;

+ (PersistentEventProto*) defaultInstance;
- (PersistentEventProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PersistentEventProto_Builder*) builder;
+ (PersistentEventProto_Builder*) builder;
+ (PersistentEventProto_Builder*) builderWithPrototype:(PersistentEventProto*) prototype;
- (PersistentEventProto_Builder*) toBuilder;

+ (PersistentEventProto*) parseFromData:(NSData*) data;
+ (PersistentEventProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PersistentEventProto*) parseFromInputStream:(NSInputStream*) input;
+ (PersistentEventProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PersistentEventProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PersistentEventProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PersistentEventProto_Builder : PBGeneratedMessageBuilder {
@private
  PersistentEventProto* result;
}

- (PersistentEventProto*) defaultInstance;

- (PersistentEventProto_Builder*) clear;
- (PersistentEventProto_Builder*) clone;

- (PersistentEventProto*) build;
- (PersistentEventProto*) buildPartial;

- (PersistentEventProto_Builder*) mergeFrom:(PersistentEventProto*) other;
- (PersistentEventProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PersistentEventProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasEventId;
- (int32_t) eventId;
- (PersistentEventProto_Builder*) setEventId:(int32_t) value;
- (PersistentEventProto_Builder*) clearEventId;

- (BOOL) hasDayOfWeek;
- (DayOfWeek) dayOfWeek;
- (PersistentEventProto_Builder*) setDayOfWeek:(DayOfWeek) value;
- (PersistentEventProto_Builder*) clearDayOfWeek;

- (BOOL) hasStartHour;
- (int32_t) startHour;
- (PersistentEventProto_Builder*) setStartHour:(int32_t) value;
- (PersistentEventProto_Builder*) clearStartHour;

- (BOOL) hasEventDurationMinutes;
- (int32_t) eventDurationMinutes;
- (PersistentEventProto_Builder*) setEventDurationMinutes:(int32_t) value;
- (PersistentEventProto_Builder*) clearEventDurationMinutes;

- (BOOL) hasTaskId;
- (int32_t) taskId;
- (PersistentEventProto_Builder*) setTaskId:(int32_t) value;
- (PersistentEventProto_Builder*) clearTaskId;

- (BOOL) hasCooldownMinutes;
- (int32_t) cooldownMinutes;
- (PersistentEventProto_Builder*) setCooldownMinutes:(int32_t) value;
- (PersistentEventProto_Builder*) clearCooldownMinutes;

- (BOOL) hasType;
- (PersistentEventProto_EventType) type;
- (PersistentEventProto_Builder*) setType:(PersistentEventProto_EventType) value;
- (PersistentEventProto_Builder*) clearType;

- (BOOL) hasMonsterElement;
- (Element) monsterElement;
- (PersistentEventProto_Builder*) setMonsterElement:(Element) value;
- (PersistentEventProto_Builder*) clearMonsterElement;
@end

@interface UserPersistentEventProto : PBGeneratedMessage {
@private
  BOOL hasCoolDownStartTime_:1;
  BOOL hasUserId_:1;
  BOOL hasEventId_:1;
  int64_t coolDownStartTime;
  int32_t userId;
  int32_t eventId;
}
- (BOOL) hasUserId;
- (BOOL) hasEventId;
- (BOOL) hasCoolDownStartTime;
@property (readonly) int32_t userId;
@property (readonly) int32_t eventId;
@property (readonly) int64_t coolDownStartTime;

+ (UserPersistentEventProto*) defaultInstance;
- (UserPersistentEventProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (UserPersistentEventProto_Builder*) builder;
+ (UserPersistentEventProto_Builder*) builder;
+ (UserPersistentEventProto_Builder*) builderWithPrototype:(UserPersistentEventProto*) prototype;
- (UserPersistentEventProto_Builder*) toBuilder;

+ (UserPersistentEventProto*) parseFromData:(NSData*) data;
+ (UserPersistentEventProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserPersistentEventProto*) parseFromInputStream:(NSInputStream*) input;
+ (UserPersistentEventProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserPersistentEventProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (UserPersistentEventProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface UserPersistentEventProto_Builder : PBGeneratedMessageBuilder {
@private
  UserPersistentEventProto* result;
}

- (UserPersistentEventProto*) defaultInstance;

- (UserPersistentEventProto_Builder*) clear;
- (UserPersistentEventProto_Builder*) clone;

- (UserPersistentEventProto*) build;
- (UserPersistentEventProto*) buildPartial;

- (UserPersistentEventProto_Builder*) mergeFrom:(UserPersistentEventProto*) other;
- (UserPersistentEventProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (UserPersistentEventProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasUserId;
- (int32_t) userId;
- (UserPersistentEventProto_Builder*) setUserId:(int32_t) value;
- (UserPersistentEventProto_Builder*) clearUserId;

- (BOOL) hasEventId;
- (int32_t) eventId;
- (UserPersistentEventProto_Builder*) setEventId:(int32_t) value;
- (UserPersistentEventProto_Builder*) clearEventId;

- (BOOL) hasCoolDownStartTime;
- (int64_t) coolDownStartTime;
- (UserPersistentEventProto_Builder*) setCoolDownStartTime:(int64_t) value;
- (UserPersistentEventProto_Builder*) clearCoolDownStartTime;
@end

@interface TaskMapElementProto : PBGeneratedMessage {
@private
  BOOL hasBoss_:1;
  BOOL hasCharImgScaleFactor_:1;
  BOOL hasMapElementId_:1;
  BOOL hasTaskId_:1;
  BOOL hasXPos_:1;
  BOOL hasYPos_:1;
  BOOL hasItemDropId_:1;
  BOOL hasCashReward_:1;
  BOOL hasOilReward_:1;
  BOOL hasCharImgVertPixelOffset_:1;
  BOOL hasCharImgHorizPixelOffset_:1;
  BOOL hasBossImgName_:1;
  BOOL hasSectionName_:1;
  BOOL hasCharacterImgName_:1;
  BOOL hasElement_:1;
  BOOL boss_:1;
  Float32 charImgScaleFactor;
  int32_t mapElementId;
  int32_t taskId;
  int32_t xPos;
  int32_t yPos;
  int32_t itemDropId;
  int32_t cashReward;
  int32_t oilReward;
  int32_t charImgVertPixelOffset;
  int32_t charImgHorizPixelOffset;
  NSString* bossImgName;
  NSString* sectionName;
  NSString* characterImgName;
  Element element;
}
- (BOOL) hasMapElementId;
- (BOOL) hasTaskId;
- (BOOL) hasXPos;
- (BOOL) hasYPos;
- (BOOL) hasElement;
- (BOOL) hasBoss;
- (BOOL) hasBossImgName;
- (BOOL) hasItemDropId;
- (BOOL) hasSectionName;
- (BOOL) hasCashReward;
- (BOOL) hasOilReward;
- (BOOL) hasCharacterImgName;
- (BOOL) hasCharImgVertPixelOffset;
- (BOOL) hasCharImgHorizPixelOffset;
- (BOOL) hasCharImgScaleFactor;
@property (readonly) int32_t mapElementId;
@property (readonly) int32_t taskId;
@property (readonly) int32_t xPos;
@property (readonly) int32_t yPos;
@property (readonly) Element element;
- (BOOL) boss;
@property (readonly, strong) NSString* bossImgName;
@property (readonly) int32_t itemDropId;
@property (readonly, strong) NSString* sectionName;
@property (readonly) int32_t cashReward;
@property (readonly) int32_t oilReward;
@property (readonly, strong) NSString* characterImgName;
@property (readonly) int32_t charImgVertPixelOffset;
@property (readonly) int32_t charImgHorizPixelOffset;
@property (readonly) Float32 charImgScaleFactor;

+ (TaskMapElementProto*) defaultInstance;
- (TaskMapElementProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (TaskMapElementProto_Builder*) builder;
+ (TaskMapElementProto_Builder*) builder;
+ (TaskMapElementProto_Builder*) builderWithPrototype:(TaskMapElementProto*) prototype;
- (TaskMapElementProto_Builder*) toBuilder;

+ (TaskMapElementProto*) parseFromData:(NSData*) data;
+ (TaskMapElementProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (TaskMapElementProto*) parseFromInputStream:(NSInputStream*) input;
+ (TaskMapElementProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (TaskMapElementProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (TaskMapElementProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface TaskMapElementProto_Builder : PBGeneratedMessageBuilder {
@private
  TaskMapElementProto* result;
}

- (TaskMapElementProto*) defaultInstance;

- (TaskMapElementProto_Builder*) clear;
- (TaskMapElementProto_Builder*) clone;

- (TaskMapElementProto*) build;
- (TaskMapElementProto*) buildPartial;

- (TaskMapElementProto_Builder*) mergeFrom:(TaskMapElementProto*) other;
- (TaskMapElementProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (TaskMapElementProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasMapElementId;
- (int32_t) mapElementId;
- (TaskMapElementProto_Builder*) setMapElementId:(int32_t) value;
- (TaskMapElementProto_Builder*) clearMapElementId;

- (BOOL) hasTaskId;
- (int32_t) taskId;
- (TaskMapElementProto_Builder*) setTaskId:(int32_t) value;
- (TaskMapElementProto_Builder*) clearTaskId;

- (BOOL) hasXPos;
- (int32_t) xPos;
- (TaskMapElementProto_Builder*) setXPos:(int32_t) value;
- (TaskMapElementProto_Builder*) clearXPos;

- (BOOL) hasYPos;
- (int32_t) yPos;
- (TaskMapElementProto_Builder*) setYPos:(int32_t) value;
- (TaskMapElementProto_Builder*) clearYPos;

- (BOOL) hasElement;
- (Element) element;
- (TaskMapElementProto_Builder*) setElement:(Element) value;
- (TaskMapElementProto_Builder*) clearElement;

- (BOOL) hasBoss;
- (BOOL) boss;
- (TaskMapElementProto_Builder*) setBoss:(BOOL) value;
- (TaskMapElementProto_Builder*) clearBoss;

- (BOOL) hasBossImgName;
- (NSString*) bossImgName;
- (TaskMapElementProto_Builder*) setBossImgName:(NSString*) value;
- (TaskMapElementProto_Builder*) clearBossImgName;

- (BOOL) hasItemDropId;
- (int32_t) itemDropId;
- (TaskMapElementProto_Builder*) setItemDropId:(int32_t) value;
- (TaskMapElementProto_Builder*) clearItemDropId;

- (BOOL) hasSectionName;
- (NSString*) sectionName;
- (TaskMapElementProto_Builder*) setSectionName:(NSString*) value;
- (TaskMapElementProto_Builder*) clearSectionName;

- (BOOL) hasCashReward;
- (int32_t) cashReward;
- (TaskMapElementProto_Builder*) setCashReward:(int32_t) value;
- (TaskMapElementProto_Builder*) clearCashReward;

- (BOOL) hasOilReward;
- (int32_t) oilReward;
- (TaskMapElementProto_Builder*) setOilReward:(int32_t) value;
- (TaskMapElementProto_Builder*) clearOilReward;

- (BOOL) hasCharacterImgName;
- (NSString*) characterImgName;
- (TaskMapElementProto_Builder*) setCharacterImgName:(NSString*) value;
- (TaskMapElementProto_Builder*) clearCharacterImgName;

- (BOOL) hasCharImgVertPixelOffset;
- (int32_t) charImgVertPixelOffset;
- (TaskMapElementProto_Builder*) setCharImgVertPixelOffset:(int32_t) value;
- (TaskMapElementProto_Builder*) clearCharImgVertPixelOffset;

- (BOOL) hasCharImgHorizPixelOffset;
- (int32_t) charImgHorizPixelOffset;
- (TaskMapElementProto_Builder*) setCharImgHorizPixelOffset:(int32_t) value;
- (TaskMapElementProto_Builder*) clearCharImgHorizPixelOffset;

- (BOOL) hasCharImgScaleFactor;
- (Float32) charImgScaleFactor;
- (TaskMapElementProto_Builder*) setCharImgScaleFactor:(Float32) value;
- (TaskMapElementProto_Builder*) clearCharImgScaleFactor;
@end


// @@protoc_insertion_point(global_scope)
