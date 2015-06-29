// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "Item.pb.h"
#import "MonsterStuff.pb.h"
#import "SharedEnumConfig.pb.h"
#import "Task.pb.h"
#import "User.pb.h"
// @@protoc_insertion_point(imports)

@class BattleItemFactoryProto;
@class BattleItemFactoryProto_Builder;
@class BeginDungeonRequestProto;
@class BeginDungeonRequestProto_Builder;
@class BeginDungeonResponseProto;
@class BeginDungeonResponseProto_Builder;
@class ClanHouseProto;
@class ClanHouseProto_Builder;
@class ClanMemberTeamDonationProto;
@class ClanMemberTeamDonationProto_Builder;
@class ColorProto;
@class ColorProto_Builder;
@class CoordinateProto;
@class CoordinateProto_Builder;
@class DefaultLanguagesProto;
@class DefaultLanguagesProto_Builder;
@class DialogueProto;
@class DialogueProto_Builder;
@class DialogueProto_SpeechSegmentProto;
@class DialogueProto_SpeechSegmentProto_Builder;
@class EndDungeonRequestProto;
@class EndDungeonRequestProto_Builder;
@class EndDungeonResponseProto;
@class EndDungeonResponseProto_Builder;
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
@class ItemGemPriceProto;
@class ItemGemPriceProto_Builder;
@class ItemProto;
@class ItemProto_Builder;
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
@class MinimumUserProtoWithMaxResources;
@class MinimumUserProtoWithMaxResources_Builder;
@class MinimumUserProto_Builder;
@class MinimumUserTaskProto;
@class MinimumUserTaskProto_Builder;
@class MoneyTreeProto;
@class MoneyTreeProto_Builder;
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
@class PrivateChatDefaultLanguageProto;
@class PrivateChatDefaultLanguageProto_Builder;
@class PrivateChatPostProto;
@class PrivateChatPostProto_Builder;
@class PvpBoardHouseProto;
@class PvpBoardHouseProto_Builder;
@class PvpBoardObstacleProto;
@class PvpBoardObstacleProto_Builder;
@class QuestJobProto;
@class QuestJobProto_Builder;
@class ResearchHouseProto;
@class ResearchHouseProto_Builder;
@class ResidenceProto;
@class ResidenceProto_Builder;
@class ResourceGeneratorProto;
@class ResourceGeneratorProto_Builder;
@class ResourceStorageProto;
@class ResourceStorageProto_Builder;
@class ReviveInDungeonRequestProto;
@class ReviveInDungeonRequestProto_Builder;
@class ReviveInDungeonResponseProto;
@class ReviveInDungeonResponseProto_Builder;
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
@class TranslatedTextProto;
@class TranslatedTextProto_Builder;
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
@class UserItemProto;
@class UserItemProto_Builder;
@class UserItemUsageProto;
@class UserItemUsageProto_Builder;
@class UserMonsterCurrentExpProto;
@class UserMonsterCurrentExpProto_Builder;
@class UserMonsterCurrentHealthProto;
@class UserMonsterCurrentHealthProto_Builder;
@class UserMonsterEvolutionProto;
@class UserMonsterEvolutionProto_Builder;
@class UserMonsterHealingProto;
@class UserMonsterHealingProto_Builder;
@class UserMonsterSnapshotProto;
@class UserMonsterSnapshotProto_Builder;
@class UserObstacleProto;
@class UserObstacleProto_Builder;
@class UserPersistentEventProto;
@class UserPersistentEventProto_Builder;
@class UserPvpBoardObstacleProto;
@class UserPvpBoardObstacleProto_Builder;
@class UserPvpLeagueProto;
@class UserPvpLeagueProto_Builder;
@class UserQuestJobProto;
@class UserQuestJobProto_Builder;
@class UserTaskCompletedProto;
@class UserTaskCompletedProto_Builder;
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


@interface EventDungeonRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface BeginDungeonRequestProto : PBGeneratedMessage {
@private
  BOOL hasUserBeatAllCityTasks_:1;
  BOOL hasIsEvent_:1;
  BOOL hasForceEnemyElem_:1;
  BOOL hasAlreadyCompletedMiniTutorialTask_:1;
  BOOL hasHasBeatenTaskBefore_:1;
  BOOL hasClientTime_:1;
  BOOL hasTaskId_:1;
  BOOL hasPersistentEventId_:1;
  BOOL hasGemsSpent_:1;
  BOOL hasSender_:1;
  BOOL hasElem_:1;
  BOOL userBeatAllCityTasks_:1;
  BOOL isEvent_:1;
  BOOL forceEnemyElem_:1;
  BOOL alreadyCompletedMiniTutorialTask_:1;
  BOOL hasBeatenTaskBefore_:1;
  int64_t clientTime;
  int32_t taskId;
  int32_t persistentEventId;
  int32_t gemsSpent;
  MinimumUserProto* sender;
  Element elem;
  PBAppendableArray * mutableQuestIdsList;
}
- (BOOL) hasSender;
- (BOOL) hasClientTime;
- (BOOL) hasTaskId;
- (BOOL) hasUserBeatAllCityTasks;
- (BOOL) hasIsEvent;
- (BOOL) hasPersistentEventId;
- (BOOL) hasGemsSpent;
- (BOOL) hasElem;
- (BOOL) hasForceEnemyElem;
- (BOOL) hasAlreadyCompletedMiniTutorialTask;
- (BOOL) hasHasBeatenTaskBefore;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) int64_t clientTime;
@property (readonly) int32_t taskId;
- (BOOL) userBeatAllCityTasks;
- (BOOL) isEvent;
@property (readonly) int32_t persistentEventId;
@property (readonly) int32_t gemsSpent;
@property (readonly, strong) PBArray * questIdsList;
@property (readonly) Element elem;
- (BOOL) forceEnemyElem;
- (BOOL) alreadyCompletedMiniTutorialTask;
- (BOOL) hasBeatenTaskBefore;
- (int32_t)questIdsAtIndex:(NSUInteger)index;

+ (BeginDungeonRequestProto*) defaultInstance;
- (BeginDungeonRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (BeginDungeonRequestProto_Builder*) builder;
+ (BeginDungeonRequestProto_Builder*) builder;
+ (BeginDungeonRequestProto_Builder*) builderWithPrototype:(BeginDungeonRequestProto*) prototype;
- (BeginDungeonRequestProto_Builder*) toBuilder;

+ (BeginDungeonRequestProto*) parseFromData:(NSData*) data;
+ (BeginDungeonRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BeginDungeonRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (BeginDungeonRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BeginDungeonRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (BeginDungeonRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface BeginDungeonRequestProto_Builder : PBGeneratedMessageBuilder {
@private
  BeginDungeonRequestProto* result;
}

- (BeginDungeonRequestProto*) defaultInstance;

- (BeginDungeonRequestProto_Builder*) clear;
- (BeginDungeonRequestProto_Builder*) clone;

- (BeginDungeonRequestProto*) build;
- (BeginDungeonRequestProto*) buildPartial;

- (BeginDungeonRequestProto_Builder*) mergeFrom:(BeginDungeonRequestProto*) other;
- (BeginDungeonRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (BeginDungeonRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (BeginDungeonRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (BeginDungeonRequestProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (BeginDungeonRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (BeginDungeonRequestProto_Builder*) clearSender;

- (BOOL) hasClientTime;
- (int64_t) clientTime;
- (BeginDungeonRequestProto_Builder*) setClientTime:(int64_t) value;
- (BeginDungeonRequestProto_Builder*) clearClientTime;

- (BOOL) hasTaskId;
- (int32_t) taskId;
- (BeginDungeonRequestProto_Builder*) setTaskId:(int32_t) value;
- (BeginDungeonRequestProto_Builder*) clearTaskId;

- (BOOL) hasUserBeatAllCityTasks;
- (BOOL) userBeatAllCityTasks;
- (BeginDungeonRequestProto_Builder*) setUserBeatAllCityTasks:(BOOL) value;
- (BeginDungeonRequestProto_Builder*) clearUserBeatAllCityTasks;

- (BOOL) hasIsEvent;
- (BOOL) isEvent;
- (BeginDungeonRequestProto_Builder*) setIsEvent:(BOOL) value;
- (BeginDungeonRequestProto_Builder*) clearIsEvent;

- (BOOL) hasPersistentEventId;
- (int32_t) persistentEventId;
- (BeginDungeonRequestProto_Builder*) setPersistentEventId:(int32_t) value;
- (BeginDungeonRequestProto_Builder*) clearPersistentEventId;

- (BOOL) hasGemsSpent;
- (int32_t) gemsSpent;
- (BeginDungeonRequestProto_Builder*) setGemsSpent:(int32_t) value;
- (BeginDungeonRequestProto_Builder*) clearGemsSpent;

- (PBAppendableArray *)questIdsList;
- (int32_t)questIdsAtIndex:(NSUInteger)index;
- (BeginDungeonRequestProto_Builder *)addQuestIds:(int32_t)value;
- (BeginDungeonRequestProto_Builder *)addAllQuestIds:(NSArray *)array;
- (BeginDungeonRequestProto_Builder *)setQuestIdsValues:(const int32_t *)values count:(NSUInteger)count;
- (BeginDungeonRequestProto_Builder *)clearQuestIds;

- (BOOL) hasElem;
- (Element) elem;
- (BeginDungeonRequestProto_Builder*) setElem:(Element) value;
- (BeginDungeonRequestProto_Builder*) clearElemList;

- (BOOL) hasForceEnemyElem;
- (BOOL) forceEnemyElem;
- (BeginDungeonRequestProto_Builder*) setForceEnemyElem:(BOOL) value;
- (BeginDungeonRequestProto_Builder*) clearForceEnemyElem;

- (BOOL) hasAlreadyCompletedMiniTutorialTask;
- (BOOL) alreadyCompletedMiniTutorialTask;
- (BeginDungeonRequestProto_Builder*) setAlreadyCompletedMiniTutorialTask:(BOOL) value;
- (BeginDungeonRequestProto_Builder*) clearAlreadyCompletedMiniTutorialTask;

- (BOOL) hasHasBeatenTaskBefore;
- (BOOL) hasBeatenTaskBefore;
- (BeginDungeonRequestProto_Builder*) setHasBeatenTaskBefore:(BOOL) value;
- (BeginDungeonRequestProto_Builder*) clearHasBeatenTaskBefore;
@end

@interface BeginDungeonResponseProto : PBGeneratedMessage {
@private
  BOOL hasTaskId_:1;
  BOOL hasUserTaskUuid_:1;
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  int32_t taskId;
  NSString* userTaskUuid;
  MinimumUserProto* sender;
  ResponseStatus status;
  NSMutableArray * mutableTspList;
}
- (BOOL) hasSender;
- (BOOL) hasUserTaskUuid;
- (BOOL) hasTaskId;
- (BOOL) hasStatus;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly, strong) NSArray * tspList;
@property (readonly, strong) NSString* userTaskUuid;
@property (readonly) int32_t taskId;
@property (readonly) ResponseStatus status;
- (TaskStageProto*)tspAtIndex:(NSUInteger)index;

+ (BeginDungeonResponseProto*) defaultInstance;
- (BeginDungeonResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (BeginDungeonResponseProto_Builder*) builder;
+ (BeginDungeonResponseProto_Builder*) builder;
+ (BeginDungeonResponseProto_Builder*) builderWithPrototype:(BeginDungeonResponseProto*) prototype;
- (BeginDungeonResponseProto_Builder*) toBuilder;

+ (BeginDungeonResponseProto*) parseFromData:(NSData*) data;
+ (BeginDungeonResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BeginDungeonResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (BeginDungeonResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BeginDungeonResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (BeginDungeonResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface BeginDungeonResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  BeginDungeonResponseProto* result;
}

- (BeginDungeonResponseProto*) defaultInstance;

- (BeginDungeonResponseProto_Builder*) clear;
- (BeginDungeonResponseProto_Builder*) clone;

- (BeginDungeonResponseProto*) build;
- (BeginDungeonResponseProto*) buildPartial;

- (BeginDungeonResponseProto_Builder*) mergeFrom:(BeginDungeonResponseProto*) other;
- (BeginDungeonResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (BeginDungeonResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (BeginDungeonResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (BeginDungeonResponseProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (BeginDungeonResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (BeginDungeonResponseProto_Builder*) clearSender;

- (NSMutableArray *)tspList;
- (TaskStageProto*)tspAtIndex:(NSUInteger)index;
- (BeginDungeonResponseProto_Builder *)addTsp:(TaskStageProto*)value;
- (BeginDungeonResponseProto_Builder *)addAllTsp:(NSArray *)array;
- (BeginDungeonResponseProto_Builder *)clearTsp;

- (BOOL) hasUserTaskUuid;
- (NSString*) userTaskUuid;
- (BeginDungeonResponseProto_Builder*) setUserTaskUuid:(NSString*) value;
- (BeginDungeonResponseProto_Builder*) clearUserTaskUuid;

- (BOOL) hasTaskId;
- (int32_t) taskId;
- (BeginDungeonResponseProto_Builder*) setTaskId:(int32_t) value;
- (BeginDungeonResponseProto_Builder*) clearTaskId;

- (BOOL) hasStatus;
- (ResponseStatus) status;
- (BeginDungeonResponseProto_Builder*) setStatus:(ResponseStatus) value;
- (BeginDungeonResponseProto_Builder*) clearStatusList;
@end

@interface EndDungeonRequestProto : PBGeneratedMessage {
@private
  BOOL hasUserWon_:1;
  BOOL hasFirstTimeUserWonTask_:1;
  BOOL hasUserBeatAllCityTasks_:1;
  BOOL hasClientTime_:1;
  BOOL hasUserTaskUuid_:1;
  BOOL hasSender_:1;
  BOOL userWon_:1;
  BOOL firstTimeUserWonTask_:1;
  BOOL userBeatAllCityTasks_:1;
  int64_t clientTime;
  NSString* userTaskUuid;
  MinimumUserProtoWithMaxResources* sender;
  NSMutableArray * mutableDroplessTsfuUuidsList;
}
- (BOOL) hasSender;
- (BOOL) hasUserTaskUuid;
- (BOOL) hasUserWon;
- (BOOL) hasClientTime;
- (BOOL) hasFirstTimeUserWonTask;
- (BOOL) hasUserBeatAllCityTasks;
@property (readonly, strong) MinimumUserProtoWithMaxResources* sender;
@property (readonly, strong) NSString* userTaskUuid;
- (BOOL) userWon;
@property (readonly) int64_t clientTime;
- (BOOL) firstTimeUserWonTask;
- (BOOL) userBeatAllCityTasks;
@property (readonly, strong) NSArray * droplessTsfuUuidsList;
- (NSString*)droplessTsfuUuidsAtIndex:(NSUInteger)index;

+ (EndDungeonRequestProto*) defaultInstance;
- (EndDungeonRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (EndDungeonRequestProto_Builder*) builder;
+ (EndDungeonRequestProto_Builder*) builder;
+ (EndDungeonRequestProto_Builder*) builderWithPrototype:(EndDungeonRequestProto*) prototype;
- (EndDungeonRequestProto_Builder*) toBuilder;

+ (EndDungeonRequestProto*) parseFromData:(NSData*) data;
+ (EndDungeonRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (EndDungeonRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (EndDungeonRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (EndDungeonRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (EndDungeonRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface EndDungeonRequestProto_Builder : PBGeneratedMessageBuilder {
@private
  EndDungeonRequestProto* result;
}

- (EndDungeonRequestProto*) defaultInstance;

- (EndDungeonRequestProto_Builder*) clear;
- (EndDungeonRequestProto_Builder*) clone;

- (EndDungeonRequestProto*) build;
- (EndDungeonRequestProto*) buildPartial;

- (EndDungeonRequestProto_Builder*) mergeFrom:(EndDungeonRequestProto*) other;
- (EndDungeonRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (EndDungeonRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProtoWithMaxResources*) sender;
- (EndDungeonRequestProto_Builder*) setSender:(MinimumUserProtoWithMaxResources*) value;
- (EndDungeonRequestProto_Builder*) setSender_Builder:(MinimumUserProtoWithMaxResources_Builder*) builderForValue;
- (EndDungeonRequestProto_Builder*) mergeSender:(MinimumUserProtoWithMaxResources*) value;
- (EndDungeonRequestProto_Builder*) clearSender;

- (BOOL) hasUserTaskUuid;
- (NSString*) userTaskUuid;
- (EndDungeonRequestProto_Builder*) setUserTaskUuid:(NSString*) value;
- (EndDungeonRequestProto_Builder*) clearUserTaskUuid;

- (BOOL) hasUserWon;
- (BOOL) userWon;
- (EndDungeonRequestProto_Builder*) setUserWon:(BOOL) value;
- (EndDungeonRequestProto_Builder*) clearUserWon;

- (BOOL) hasClientTime;
- (int64_t) clientTime;
- (EndDungeonRequestProto_Builder*) setClientTime:(int64_t) value;
- (EndDungeonRequestProto_Builder*) clearClientTime;

- (BOOL) hasFirstTimeUserWonTask;
- (BOOL) firstTimeUserWonTask;
- (EndDungeonRequestProto_Builder*) setFirstTimeUserWonTask:(BOOL) value;
- (EndDungeonRequestProto_Builder*) clearFirstTimeUserWonTask;

- (BOOL) hasUserBeatAllCityTasks;
- (BOOL) userBeatAllCityTasks;
- (EndDungeonRequestProto_Builder*) setUserBeatAllCityTasks:(BOOL) value;
- (EndDungeonRequestProto_Builder*) clearUserBeatAllCityTasks;

- (NSMutableArray *)droplessTsfuUuidsList;
- (NSString*)droplessTsfuUuidsAtIndex:(NSUInteger)index;
- (EndDungeonRequestProto_Builder *)addDroplessTsfuUuids:(NSString*)value;
- (EndDungeonRequestProto_Builder *)addAllDroplessTsfuUuids:(NSArray *)array;
- (EndDungeonRequestProto_Builder *)clearDroplessTsfuUuids;
@end

@interface EndDungeonResponseProto : PBGeneratedMessage {
@private
  BOOL hasUserWon_:1;
  BOOL hasTaskId_:1;
  BOOL hasTaskMapSectionName_:1;
  BOOL hasSender_:1;
  BOOL hasUserItem_:1;
  BOOL hasUtcp_:1;
  BOOL hasStatus_:1;
  BOOL userWon_:1;
  int32_t taskId;
  NSString* taskMapSectionName;
  MinimumUserProtoWithMaxResources* sender;
  UserItemProto* userItem;
  UserTaskCompletedProto* utcp;
  ResponseStatus status;
  NSMutableArray * mutableUpdatedOrNewList;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
- (BOOL) hasTaskId;
- (BOOL) hasUserWon;
- (BOOL) hasUserItem;
- (BOOL) hasTaskMapSectionName;
- (BOOL) hasUtcp;
@property (readonly, strong) MinimumUserProtoWithMaxResources* sender;
@property (readonly) ResponseStatus status;
@property (readonly, strong) NSArray * updatedOrNewList;
@property (readonly) int32_t taskId;
- (BOOL) userWon;
@property (readonly, strong) UserItemProto* userItem;
@property (readonly, strong) NSString* taskMapSectionName;
@property (readonly, strong) UserTaskCompletedProto* utcp;
- (FullUserMonsterProto*)updatedOrNewAtIndex:(NSUInteger)index;

+ (EndDungeonResponseProto*) defaultInstance;
- (EndDungeonResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (EndDungeonResponseProto_Builder*) builder;
+ (EndDungeonResponseProto_Builder*) builder;
+ (EndDungeonResponseProto_Builder*) builderWithPrototype:(EndDungeonResponseProto*) prototype;
- (EndDungeonResponseProto_Builder*) toBuilder;

+ (EndDungeonResponseProto*) parseFromData:(NSData*) data;
+ (EndDungeonResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (EndDungeonResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (EndDungeonResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (EndDungeonResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (EndDungeonResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface EndDungeonResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  EndDungeonResponseProto* result;
}

- (EndDungeonResponseProto*) defaultInstance;

- (EndDungeonResponseProto_Builder*) clear;
- (EndDungeonResponseProto_Builder*) clone;

- (EndDungeonResponseProto*) build;
- (EndDungeonResponseProto*) buildPartial;

- (EndDungeonResponseProto_Builder*) mergeFrom:(EndDungeonResponseProto*) other;
- (EndDungeonResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (EndDungeonResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProtoWithMaxResources*) sender;
- (EndDungeonResponseProto_Builder*) setSender:(MinimumUserProtoWithMaxResources*) value;
- (EndDungeonResponseProto_Builder*) setSender_Builder:(MinimumUserProtoWithMaxResources_Builder*) builderForValue;
- (EndDungeonResponseProto_Builder*) mergeSender:(MinimumUserProtoWithMaxResources*) value;
- (EndDungeonResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (ResponseStatus) status;
- (EndDungeonResponseProto_Builder*) setStatus:(ResponseStatus) value;
- (EndDungeonResponseProto_Builder*) clearStatusList;

- (NSMutableArray *)updatedOrNewList;
- (FullUserMonsterProto*)updatedOrNewAtIndex:(NSUInteger)index;
- (EndDungeonResponseProto_Builder *)addUpdatedOrNew:(FullUserMonsterProto*)value;
- (EndDungeonResponseProto_Builder *)addAllUpdatedOrNew:(NSArray *)array;
- (EndDungeonResponseProto_Builder *)clearUpdatedOrNew;

- (BOOL) hasTaskId;
- (int32_t) taskId;
- (EndDungeonResponseProto_Builder*) setTaskId:(int32_t) value;
- (EndDungeonResponseProto_Builder*) clearTaskId;

- (BOOL) hasUserWon;
- (BOOL) userWon;
- (EndDungeonResponseProto_Builder*) setUserWon:(BOOL) value;
- (EndDungeonResponseProto_Builder*) clearUserWon;

- (BOOL) hasUserItem;
- (UserItemProto*) userItem;
- (EndDungeonResponseProto_Builder*) setUserItem:(UserItemProto*) value;
- (EndDungeonResponseProto_Builder*) setUserItem_Builder:(UserItemProto_Builder*) builderForValue;
- (EndDungeonResponseProto_Builder*) mergeUserItem:(UserItemProto*) value;
- (EndDungeonResponseProto_Builder*) clearUserItem;

- (BOOL) hasTaskMapSectionName;
- (NSString*) taskMapSectionName;
- (EndDungeonResponseProto_Builder*) setTaskMapSectionName:(NSString*) value;
- (EndDungeonResponseProto_Builder*) clearTaskMapSectionName;

- (BOOL) hasUtcp;
- (UserTaskCompletedProto*) utcp;
- (EndDungeonResponseProto_Builder*) setUtcp:(UserTaskCompletedProto*) value;
- (EndDungeonResponseProto_Builder*) setUtcp_Builder:(UserTaskCompletedProto_Builder*) builderForValue;
- (EndDungeonResponseProto_Builder*) mergeUtcp:(UserTaskCompletedProto*) value;
- (EndDungeonResponseProto_Builder*) clearUtcp;
@end

@interface ReviveInDungeonRequestProto : PBGeneratedMessage {
@private
  BOOL hasClientTime_:1;
  BOOL hasGemsSpent_:1;
  BOOL hasUserTaskUuid_:1;
  BOOL hasSender_:1;
  int64_t clientTime;
  int32_t gemsSpent;
  NSString* userTaskUuid;
  MinimumUserProto* sender;
  NSMutableArray * mutableReviveMeList;
}
- (BOOL) hasSender;
- (BOOL) hasUserTaskUuid;
- (BOOL) hasClientTime;
- (BOOL) hasGemsSpent;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly, strong) NSString* userTaskUuid;
@property (readonly) int64_t clientTime;
@property (readonly, strong) NSArray * reviveMeList;
@property (readonly) int32_t gemsSpent;
- (UserMonsterCurrentHealthProto*)reviveMeAtIndex:(NSUInteger)index;

+ (ReviveInDungeonRequestProto*) defaultInstance;
- (ReviveInDungeonRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (ReviveInDungeonRequestProto_Builder*) builder;
+ (ReviveInDungeonRequestProto_Builder*) builder;
+ (ReviveInDungeonRequestProto_Builder*) builderWithPrototype:(ReviveInDungeonRequestProto*) prototype;
- (ReviveInDungeonRequestProto_Builder*) toBuilder;

+ (ReviveInDungeonRequestProto*) parseFromData:(NSData*) data;
+ (ReviveInDungeonRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ReviveInDungeonRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (ReviveInDungeonRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ReviveInDungeonRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (ReviveInDungeonRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface ReviveInDungeonRequestProto_Builder : PBGeneratedMessageBuilder {
@private
  ReviveInDungeonRequestProto* result;
}

- (ReviveInDungeonRequestProto*) defaultInstance;

- (ReviveInDungeonRequestProto_Builder*) clear;
- (ReviveInDungeonRequestProto_Builder*) clone;

- (ReviveInDungeonRequestProto*) build;
- (ReviveInDungeonRequestProto*) buildPartial;

- (ReviveInDungeonRequestProto_Builder*) mergeFrom:(ReviveInDungeonRequestProto*) other;
- (ReviveInDungeonRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (ReviveInDungeonRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (ReviveInDungeonRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (ReviveInDungeonRequestProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (ReviveInDungeonRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (ReviveInDungeonRequestProto_Builder*) clearSender;

- (BOOL) hasUserTaskUuid;
- (NSString*) userTaskUuid;
- (ReviveInDungeonRequestProto_Builder*) setUserTaskUuid:(NSString*) value;
- (ReviveInDungeonRequestProto_Builder*) clearUserTaskUuid;

- (BOOL) hasClientTime;
- (int64_t) clientTime;
- (ReviveInDungeonRequestProto_Builder*) setClientTime:(int64_t) value;
- (ReviveInDungeonRequestProto_Builder*) clearClientTime;

- (NSMutableArray *)reviveMeList;
- (UserMonsterCurrentHealthProto*)reviveMeAtIndex:(NSUInteger)index;
- (ReviveInDungeonRequestProto_Builder *)addReviveMe:(UserMonsterCurrentHealthProto*)value;
- (ReviveInDungeonRequestProto_Builder *)addAllReviveMe:(NSArray *)array;
- (ReviveInDungeonRequestProto_Builder *)clearReviveMe;

- (BOOL) hasGemsSpent;
- (int32_t) gemsSpent;
- (ReviveInDungeonRequestProto_Builder*) setGemsSpent:(int32_t) value;
- (ReviveInDungeonRequestProto_Builder*) clearGemsSpent;
@end

@interface ReviveInDungeonResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  ResponseStatus status;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) ResponseStatus status;

+ (ReviveInDungeonResponseProto*) defaultInstance;
- (ReviveInDungeonResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (ReviveInDungeonResponseProto_Builder*) builder;
+ (ReviveInDungeonResponseProto_Builder*) builder;
+ (ReviveInDungeonResponseProto_Builder*) builderWithPrototype:(ReviveInDungeonResponseProto*) prototype;
- (ReviveInDungeonResponseProto_Builder*) toBuilder;

+ (ReviveInDungeonResponseProto*) parseFromData:(NSData*) data;
+ (ReviveInDungeonResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ReviveInDungeonResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (ReviveInDungeonResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ReviveInDungeonResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (ReviveInDungeonResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface ReviveInDungeonResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  ReviveInDungeonResponseProto* result;
}

- (ReviveInDungeonResponseProto*) defaultInstance;

- (ReviveInDungeonResponseProto_Builder*) clear;
- (ReviveInDungeonResponseProto_Builder*) clone;

- (ReviveInDungeonResponseProto*) build;
- (ReviveInDungeonResponseProto*) buildPartial;

- (ReviveInDungeonResponseProto_Builder*) mergeFrom:(ReviveInDungeonResponseProto*) other;
- (ReviveInDungeonResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (ReviveInDungeonResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (ReviveInDungeonResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (ReviveInDungeonResponseProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (ReviveInDungeonResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (ReviveInDungeonResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (ResponseStatus) status;
- (ReviveInDungeonResponseProto_Builder*) setStatus:(ResponseStatus) value;
- (ReviveInDungeonResponseProto_Builder*) clearStatusList;
@end


// @@protoc_insertion_point(global_scope)
