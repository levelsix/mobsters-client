// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "MonsterStuff.pb.h"
#import "Quest.pb.h"
#import "User.pb.h"
// @@protoc_insertion_point(imports)

@class BattleItemFactoryProto;
@class BattleItemFactoryProto_Builder;
@class ChatTranslationsProto;
@class ChatTranslationsProto_Builder;
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
@class EvoChamberProto;
@class EvoChamberProto_Builder;
@class FullQuestProto;
@class FullQuestProto_Builder;
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
@class MinimumUserProtoWithLevel;
@class MinimumUserProtoWithLevel_Builder;
@class MinimumUserProtoWithMaxResources;
@class MinimumUserProtoWithMaxResources_Builder;
@class MinimumUserProto_Builder;
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
@class PrivateChatDefaultLanguageProto;
@class PrivateChatDefaultLanguageProto_Builder;
@class PrivateChatPostProto;
@class PrivateChatPostProto_Builder;
@class PvpBoardHouseProto;
@class PvpBoardHouseProto_Builder;
@class PvpBoardObstacleProto;
@class PvpBoardObstacleProto_Builder;
@class QuestAcceptRequestProto;
@class QuestAcceptRequestProto_Builder;
@class QuestAcceptResponseProto;
@class QuestAcceptResponseProto_Builder;
@class QuestJobProto;
@class QuestJobProto_Builder;
@class QuestProgressRequestProto;
@class QuestProgressRequestProto_Builder;
@class QuestProgressResponseProto;
@class QuestProgressResponseProto_Builder;
@class QuestRedeemRequestProto;
@class QuestRedeemRequestProto_Builder;
@class QuestRedeemResponseProto;
@class QuestRedeemResponseProto_Builder;
@class ResearchHouseProto;
@class ResearchHouseProto_Builder;
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
@class UserItemSecretGiftProto;
@class UserItemSecretGiftProto_Builder;
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
@class UserPvpBoardObstacleProto;
@class UserPvpBoardObstacleProto_Builder;
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

typedef NS_ENUM(SInt32, QuestAcceptResponseProto_QuestAcceptStatus) {
  QuestAcceptResponseProto_QuestAcceptStatusSuccess = 1,
  QuestAcceptResponseProto_QuestAcceptStatusFailNotAvailToUser = 2,
  QuestAcceptResponseProto_QuestAcceptStatusFailAlreadyAccepted = 3,
  QuestAcceptResponseProto_QuestAcceptStatusFailOther = 4,
};

BOOL QuestAcceptResponseProto_QuestAcceptStatusIsValidValue(QuestAcceptResponseProto_QuestAcceptStatus value);

typedef NS_ENUM(SInt32, QuestProgressResponseProto_QuestProgressStatus) {
  QuestProgressResponseProto_QuestProgressStatusSuccess = 1,
  QuestProgressResponseProto_QuestProgressStatusFailNoQuestExists = 2,
  QuestProgressResponseProto_QuestProgressStatusFailDeleteAmountDoesNotMatchQuest = 3,
  QuestProgressResponseProto_QuestProgressStatusFailNonexistentUserMonsters = 4,
  QuestProgressResponseProto_QuestProgressStatusFailIncompleteUserMonsters = 5,
  QuestProgressResponseProto_QuestProgressStatusFailQuestJobIncomplete = 7,
  QuestProgressResponseProto_QuestProgressStatusFailOther = 6,
};

BOOL QuestProgressResponseProto_QuestProgressStatusIsValidValue(QuestProgressResponseProto_QuestProgressStatus value);

typedef NS_ENUM(SInt32, QuestRedeemResponseProto_QuestRedeemStatus) {
  QuestRedeemResponseProto_QuestRedeemStatusSuccess = 1,
  QuestRedeemResponseProto_QuestRedeemStatusFailNotComplete = 2,
  QuestRedeemResponseProto_QuestRedeemStatusFailOther = 3,
};

BOOL QuestRedeemResponseProto_QuestRedeemStatusIsValidValue(QuestRedeemResponseProto_QuestRedeemStatus value);


@interface EventQuestRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface QuestAcceptRequestProto : PBGeneratedMessage {
@private
  BOOL hasQuestId_:1;
  BOOL hasSender_:1;
  int32_t questId;
  MinimumUserProto* sender;
}
- (BOOL) hasSender;
- (BOOL) hasQuestId;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) int32_t questId;

+ (QuestAcceptRequestProto*) defaultInstance;
- (QuestAcceptRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (QuestAcceptRequestProto_Builder*) builder;
+ (QuestAcceptRequestProto_Builder*) builder;
+ (QuestAcceptRequestProto_Builder*) builderWithPrototype:(QuestAcceptRequestProto*) prototype;
- (QuestAcceptRequestProto_Builder*) toBuilder;

+ (QuestAcceptRequestProto*) parseFromData:(NSData*) data;
+ (QuestAcceptRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestAcceptRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (QuestAcceptRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestAcceptRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (QuestAcceptRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface QuestAcceptRequestProto_Builder : PBGeneratedMessageBuilder {
@private
  QuestAcceptRequestProto* result;
}

- (QuestAcceptRequestProto*) defaultInstance;

- (QuestAcceptRequestProto_Builder*) clear;
- (QuestAcceptRequestProto_Builder*) clone;

- (QuestAcceptRequestProto*) build;
- (QuestAcceptRequestProto*) buildPartial;

- (QuestAcceptRequestProto_Builder*) mergeFrom:(QuestAcceptRequestProto*) other;
- (QuestAcceptRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (QuestAcceptRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (QuestAcceptRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (QuestAcceptRequestProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (QuestAcceptRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (QuestAcceptRequestProto_Builder*) clearSender;

- (BOOL) hasQuestId;
- (int32_t) questId;
- (QuestAcceptRequestProto_Builder*) setQuestId:(int32_t) value;
- (QuestAcceptRequestProto_Builder*) clearQuestId;
@end

@interface QuestAcceptResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  QuestAcceptResponseProto_QuestAcceptStatus status;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) QuestAcceptResponseProto_QuestAcceptStatus status;

+ (QuestAcceptResponseProto*) defaultInstance;
- (QuestAcceptResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (QuestAcceptResponseProto_Builder*) builder;
+ (QuestAcceptResponseProto_Builder*) builder;
+ (QuestAcceptResponseProto_Builder*) builderWithPrototype:(QuestAcceptResponseProto*) prototype;
- (QuestAcceptResponseProto_Builder*) toBuilder;

+ (QuestAcceptResponseProto*) parseFromData:(NSData*) data;
+ (QuestAcceptResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestAcceptResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (QuestAcceptResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestAcceptResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (QuestAcceptResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface QuestAcceptResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  QuestAcceptResponseProto* result;
}

- (QuestAcceptResponseProto*) defaultInstance;

- (QuestAcceptResponseProto_Builder*) clear;
- (QuestAcceptResponseProto_Builder*) clone;

- (QuestAcceptResponseProto*) build;
- (QuestAcceptResponseProto*) buildPartial;

- (QuestAcceptResponseProto_Builder*) mergeFrom:(QuestAcceptResponseProto*) other;
- (QuestAcceptResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (QuestAcceptResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (QuestAcceptResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (QuestAcceptResponseProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (QuestAcceptResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (QuestAcceptResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (QuestAcceptResponseProto_QuestAcceptStatus) status;
- (QuestAcceptResponseProto_Builder*) setStatus:(QuestAcceptResponseProto_QuestAcceptStatus) value;
- (QuestAcceptResponseProto_Builder*) clearStatusList;
@end

@interface QuestProgressRequestProto : PBGeneratedMessage {
@private
  BOOL hasIsComplete_:1;
  BOOL hasQuestId_:1;
  BOOL hasSender_:1;
  BOOL isComplete_:1;
  int32_t questId;
  MinimumUserProto* sender;
  NSMutableArray * mutableDeleteUserMonsterUuidsList;
  NSMutableArray * mutableUserQuestJobsList;
}
- (BOOL) hasSender;
- (BOOL) hasQuestId;
- (BOOL) hasIsComplete;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) int32_t questId;
- (BOOL) isComplete;
@property (readonly, strong) NSArray * userQuestJobsList;
@property (readonly, strong) NSArray * deleteUserMonsterUuidsList;
- (UserQuestJobProto*)userQuestJobsAtIndex:(NSUInteger)index;
- (NSString*)deleteUserMonsterUuidsAtIndex:(NSUInteger)index;

+ (QuestProgressRequestProto*) defaultInstance;
- (QuestProgressRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (QuestProgressRequestProto_Builder*) builder;
+ (QuestProgressRequestProto_Builder*) builder;
+ (QuestProgressRequestProto_Builder*) builderWithPrototype:(QuestProgressRequestProto*) prototype;
- (QuestProgressRequestProto_Builder*) toBuilder;

+ (QuestProgressRequestProto*) parseFromData:(NSData*) data;
+ (QuestProgressRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestProgressRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (QuestProgressRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestProgressRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (QuestProgressRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface QuestProgressRequestProto_Builder : PBGeneratedMessageBuilder {
@private
  QuestProgressRequestProto* result;
}

- (QuestProgressRequestProto*) defaultInstance;

- (QuestProgressRequestProto_Builder*) clear;
- (QuestProgressRequestProto_Builder*) clone;

- (QuestProgressRequestProto*) build;
- (QuestProgressRequestProto*) buildPartial;

- (QuestProgressRequestProto_Builder*) mergeFrom:(QuestProgressRequestProto*) other;
- (QuestProgressRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (QuestProgressRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (QuestProgressRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (QuestProgressRequestProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (QuestProgressRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (QuestProgressRequestProto_Builder*) clearSender;

- (BOOL) hasQuestId;
- (int32_t) questId;
- (QuestProgressRequestProto_Builder*) setQuestId:(int32_t) value;
- (QuestProgressRequestProto_Builder*) clearQuestId;

- (BOOL) hasIsComplete;
- (BOOL) isComplete;
- (QuestProgressRequestProto_Builder*) setIsComplete:(BOOL) value;
- (QuestProgressRequestProto_Builder*) clearIsComplete;

- (NSMutableArray *)userQuestJobsList;
- (UserQuestJobProto*)userQuestJobsAtIndex:(NSUInteger)index;
- (QuestProgressRequestProto_Builder *)addUserQuestJobs:(UserQuestJobProto*)value;
- (QuestProgressRequestProto_Builder *)addAllUserQuestJobs:(NSArray *)array;
- (QuestProgressRequestProto_Builder *)clearUserQuestJobs;

- (NSMutableArray *)deleteUserMonsterUuidsList;
- (NSString*)deleteUserMonsterUuidsAtIndex:(NSUInteger)index;
- (QuestProgressRequestProto_Builder *)addDeleteUserMonsterUuids:(NSString*)value;
- (QuestProgressRequestProto_Builder *)addAllDeleteUserMonsterUuids:(NSArray *)array;
- (QuestProgressRequestProto_Builder *)clearDeleteUserMonsterUuids;
@end

@interface QuestProgressResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  QuestProgressResponseProto_QuestProgressStatus status;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) QuestProgressResponseProto_QuestProgressStatus status;

+ (QuestProgressResponseProto*) defaultInstance;
- (QuestProgressResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (QuestProgressResponseProto_Builder*) builder;
+ (QuestProgressResponseProto_Builder*) builder;
+ (QuestProgressResponseProto_Builder*) builderWithPrototype:(QuestProgressResponseProto*) prototype;
- (QuestProgressResponseProto_Builder*) toBuilder;

+ (QuestProgressResponseProto*) parseFromData:(NSData*) data;
+ (QuestProgressResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestProgressResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (QuestProgressResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestProgressResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (QuestProgressResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface QuestProgressResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  QuestProgressResponseProto* result;
}

- (QuestProgressResponseProto*) defaultInstance;

- (QuestProgressResponseProto_Builder*) clear;
- (QuestProgressResponseProto_Builder*) clone;

- (QuestProgressResponseProto*) build;
- (QuestProgressResponseProto*) buildPartial;

- (QuestProgressResponseProto_Builder*) mergeFrom:(QuestProgressResponseProto*) other;
- (QuestProgressResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (QuestProgressResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (QuestProgressResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (QuestProgressResponseProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (QuestProgressResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (QuestProgressResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (QuestProgressResponseProto_QuestProgressStatus) status;
- (QuestProgressResponseProto_Builder*) setStatus:(QuestProgressResponseProto_QuestProgressStatus) value;
- (QuestProgressResponseProto_Builder*) clearStatusList;
@end

@interface QuestRedeemRequestProto : PBGeneratedMessage {
@private
  BOOL hasQuestId_:1;
  BOOL hasSender_:1;
  int32_t questId;
  MinimumUserProtoWithMaxResources* sender;
}
- (BOOL) hasSender;
- (BOOL) hasQuestId;
@property (readonly, strong) MinimumUserProtoWithMaxResources* sender;
@property (readonly) int32_t questId;

+ (QuestRedeemRequestProto*) defaultInstance;
- (QuestRedeemRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (QuestRedeemRequestProto_Builder*) builder;
+ (QuestRedeemRequestProto_Builder*) builder;
+ (QuestRedeemRequestProto_Builder*) builderWithPrototype:(QuestRedeemRequestProto*) prototype;
- (QuestRedeemRequestProto_Builder*) toBuilder;

+ (QuestRedeemRequestProto*) parseFromData:(NSData*) data;
+ (QuestRedeemRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestRedeemRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (QuestRedeemRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestRedeemRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (QuestRedeemRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface QuestRedeemRequestProto_Builder : PBGeneratedMessageBuilder {
@private
  QuestRedeemRequestProto* result;
}

- (QuestRedeemRequestProto*) defaultInstance;

- (QuestRedeemRequestProto_Builder*) clear;
- (QuestRedeemRequestProto_Builder*) clone;

- (QuestRedeemRequestProto*) build;
- (QuestRedeemRequestProto*) buildPartial;

- (QuestRedeemRequestProto_Builder*) mergeFrom:(QuestRedeemRequestProto*) other;
- (QuestRedeemRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (QuestRedeemRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProtoWithMaxResources*) sender;
- (QuestRedeemRequestProto_Builder*) setSender:(MinimumUserProtoWithMaxResources*) value;
- (QuestRedeemRequestProto_Builder*) setSender_Builder:(MinimumUserProtoWithMaxResources_Builder*) builderForValue;
- (QuestRedeemRequestProto_Builder*) mergeSender:(MinimumUserProtoWithMaxResources*) value;
- (QuestRedeemRequestProto_Builder*) clearSender;

- (BOOL) hasQuestId;
- (int32_t) questId;
- (QuestRedeemRequestProto_Builder*) setQuestId:(int32_t) value;
- (QuestRedeemRequestProto_Builder*) clearQuestId;
@end

@interface QuestRedeemResponseProto : PBGeneratedMessage {
@private
  BOOL hasQuestId_:1;
  BOOL hasSender_:1;
  BOOL hasFump_:1;
  BOOL hasStatus_:1;
  int32_t questId;
  MinimumUserProtoWithMaxResources* sender;
  FullUserMonsterProto* fump;
  QuestRedeemResponseProto_QuestRedeemStatus status;
  NSMutableArray * mutableNewlyAvailableQuestsList;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
- (BOOL) hasFump;
- (BOOL) hasQuestId;
@property (readonly, strong) MinimumUserProtoWithMaxResources* sender;
@property (readonly, strong) NSArray * newlyAvailableQuestsList;
@property (readonly) QuestRedeemResponseProto_QuestRedeemStatus status;
@property (readonly, strong) FullUserMonsterProto* fump;
@property (readonly) int32_t questId;
- (FullQuestProto*)newlyAvailableQuestsAtIndex:(NSUInteger)index;

+ (QuestRedeemResponseProto*) defaultInstance;
- (QuestRedeemResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (QuestRedeemResponseProto_Builder*) builder;
+ (QuestRedeemResponseProto_Builder*) builder;
+ (QuestRedeemResponseProto_Builder*) builderWithPrototype:(QuestRedeemResponseProto*) prototype;
- (QuestRedeemResponseProto_Builder*) toBuilder;

+ (QuestRedeemResponseProto*) parseFromData:(NSData*) data;
+ (QuestRedeemResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestRedeemResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (QuestRedeemResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestRedeemResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (QuestRedeemResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface QuestRedeemResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  QuestRedeemResponseProto* result;
}

- (QuestRedeemResponseProto*) defaultInstance;

- (QuestRedeemResponseProto_Builder*) clear;
- (QuestRedeemResponseProto_Builder*) clone;

- (QuestRedeemResponseProto*) build;
- (QuestRedeemResponseProto*) buildPartial;

- (QuestRedeemResponseProto_Builder*) mergeFrom:(QuestRedeemResponseProto*) other;
- (QuestRedeemResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (QuestRedeemResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProtoWithMaxResources*) sender;
- (QuestRedeemResponseProto_Builder*) setSender:(MinimumUserProtoWithMaxResources*) value;
- (QuestRedeemResponseProto_Builder*) setSender_Builder:(MinimumUserProtoWithMaxResources_Builder*) builderForValue;
- (QuestRedeemResponseProto_Builder*) mergeSender:(MinimumUserProtoWithMaxResources*) value;
- (QuestRedeemResponseProto_Builder*) clearSender;

- (NSMutableArray *)newlyAvailableQuestsList;
- (FullQuestProto*)newlyAvailableQuestsAtIndex:(NSUInteger)index;
- (QuestRedeemResponseProto_Builder *)addNewlyAvailableQuests:(FullQuestProto*)value;
- (QuestRedeemResponseProto_Builder *)addAllNewlyAvailableQuests:(NSArray *)array;
- (QuestRedeemResponseProto_Builder *)clearNewlyAvailableQuests;

- (BOOL) hasStatus;
- (QuestRedeemResponseProto_QuestRedeemStatus) status;
- (QuestRedeemResponseProto_Builder*) setStatus:(QuestRedeemResponseProto_QuestRedeemStatus) value;
- (QuestRedeemResponseProto_Builder*) clearStatusList;

- (BOOL) hasFump;
- (FullUserMonsterProto*) fump;
- (QuestRedeemResponseProto_Builder*) setFump:(FullUserMonsterProto*) value;
- (QuestRedeemResponseProto_Builder*) setFump_Builder:(FullUserMonsterProto_Builder*) builderForValue;
- (QuestRedeemResponseProto_Builder*) mergeFump:(FullUserMonsterProto*) value;
- (QuestRedeemResponseProto_Builder*) clearFump;

- (BOOL) hasQuestId;
- (int32_t) questId;
- (QuestRedeemResponseProto_Builder*) setQuestId:(int32_t) value;
- (QuestRedeemResponseProto_Builder*) clearQuestId;
@end


// @@protoc_insertion_point(global_scope)
