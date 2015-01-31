// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "Chat.pb.h"
#import "MonsterStuff.pb.h"
#import "SharedEnumConfig.pb.h"
#import "Structure.pb.h"
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
@class MonsterBattleDialogueProto;
@class MonsterBattleDialogueProto_Builder;
@class MonsterLevelInfoProto;
@class MonsterLevelInfoProto_Builder;
@class MonsterProto;
@class MonsterProto_Builder;
@class ObstacleProto;
@class ObstacleProto_Builder;
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
@class UserMonsterSnapshotProto;
@class UserMonsterSnapshotProto_Builder;
@class UserObstacleProto;
@class UserObstacleProto_Builder;
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

typedef NS_ENUM(SInt32, QuestJobProto_QuestJobType) {
  QuestJobProto_QuestJobTypeKillSpecificMonster = 1,
  QuestJobProto_QuestJobTypeKillMonsterInCity = 2,
  QuestJobProto_QuestJobTypeDonateMonster = 3,
  QuestJobProto_QuestJobTypeCompleteTask = 4,
  QuestJobProto_QuestJobTypeUpgradeStruct = 5,
  QuestJobProto_QuestJobTypeCollectSpecialItem = 6,
};

BOOL QuestJobProto_QuestJobTypeIsValidValue(QuestJobProto_QuestJobType value);


@interface QuestRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface FullQuestProto : PBGeneratedMessage {
@private
  BOOL hasIsCompleteMonster_:1;
  BOOL hasQuestId_:1;
  BOOL hasCashReward_:1;
  BOOL hasOilReward_:1;
  BOOL hasGemReward_:1;
  BOOL hasExpReward_:1;
  BOOL hasMonsterIdReward_:1;
  BOOL hasPriority_:1;
  BOOL hasName_:1;
  BOOL hasDescription_:1;
  BOOL hasDoneResponse_:1;
  BOOL hasQuestGiverName_:1;
  BOOL hasQuestGiverImagePrefix_:1;
  BOOL hasCarrotId_:1;
  BOOL hasAcceptDialogue_:1;
  BOOL hasQuestGiverImgOffset_:1;
  BOOL hasMonsterElement_:1;
  BOOL isCompleteMonster_:1;
  int32_t questId;
  int32_t cashReward;
  int32_t oilReward;
  int32_t gemReward;
  int32_t expReward;
  int32_t monsterIdReward;
  int32_t priority;
  NSString* name;
  NSString* description;
  NSString* doneResponse;
  NSString* questGiverName;
  NSString* questGiverImagePrefix;
  NSString* carrotId;
  DialogueProto* acceptDialogue;
  CoordinateProto* questGiverImgOffset;
  Element monsterElement;
  PBAppendableArray * mutableQuestsRequiredForThisList;
  NSMutableArray * mutableJobsList;
}
- (BOOL) hasQuestId;
- (BOOL) hasName;
- (BOOL) hasDescription;
- (BOOL) hasDoneResponse;
- (BOOL) hasAcceptDialogue;
- (BOOL) hasCashReward;
- (BOOL) hasOilReward;
- (BOOL) hasGemReward;
- (BOOL) hasExpReward;
- (BOOL) hasMonsterIdReward;
- (BOOL) hasIsCompleteMonster;
- (BOOL) hasQuestGiverName;
- (BOOL) hasQuestGiverImagePrefix;
- (BOOL) hasPriority;
- (BOOL) hasCarrotId;
- (BOOL) hasQuestGiverImgOffset;
- (BOOL) hasMonsterElement;
@property (readonly) int32_t questId;
@property (readonly, strong) NSString* name;
@property (readonly, strong) NSString* description;
@property (readonly, strong) NSString* doneResponse;
@property (readonly, strong) DialogueProto* acceptDialogue;
@property (readonly) int32_t cashReward;
@property (readonly) int32_t oilReward;
@property (readonly) int32_t gemReward;
@property (readonly) int32_t expReward;
@property (readonly) int32_t monsterIdReward;
- (BOOL) isCompleteMonster;
@property (readonly, strong) PBArray * questsRequiredForThisList;
@property (readonly, strong) NSString* questGiverName;
@property (readonly, strong) NSString* questGiverImagePrefix;
@property (readonly) int32_t priority;
@property (readonly, strong) NSString* carrotId;
@property (readonly, strong) CoordinateProto* questGiverImgOffset;
@property (readonly) Element monsterElement;
@property (readonly, strong) NSArray * jobsList;
- (int32_t)questsRequiredForThisAtIndex:(NSUInteger)index;
- (QuestJobProto*)jobsAtIndex:(NSUInteger)index;

+ (FullQuestProto*) defaultInstance;
- (FullQuestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (FullQuestProto_Builder*) builder;
+ (FullQuestProto_Builder*) builder;
+ (FullQuestProto_Builder*) builderWithPrototype:(FullQuestProto*) prototype;
- (FullQuestProto_Builder*) toBuilder;

+ (FullQuestProto*) parseFromData:(NSData*) data;
+ (FullQuestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FullQuestProto*) parseFromInputStream:(NSInputStream*) input;
+ (FullQuestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FullQuestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (FullQuestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface FullQuestProto_Builder : PBGeneratedMessageBuilder {
@private
  FullQuestProto* result;
}

- (FullQuestProto*) defaultInstance;

- (FullQuestProto_Builder*) clear;
- (FullQuestProto_Builder*) clone;

- (FullQuestProto*) build;
- (FullQuestProto*) buildPartial;

- (FullQuestProto_Builder*) mergeFrom:(FullQuestProto*) other;
- (FullQuestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (FullQuestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasQuestId;
- (int32_t) questId;
- (FullQuestProto_Builder*) setQuestId:(int32_t) value;
- (FullQuestProto_Builder*) clearQuestId;

- (BOOL) hasName;
- (NSString*) name;
- (FullQuestProto_Builder*) setName:(NSString*) value;
- (FullQuestProto_Builder*) clearName;

- (BOOL) hasDescription;
- (NSString*) description;
- (FullQuestProto_Builder*) setDescription:(NSString*) value;
- (FullQuestProto_Builder*) clearDescription;

- (BOOL) hasDoneResponse;
- (NSString*) doneResponse;
- (FullQuestProto_Builder*) setDoneResponse:(NSString*) value;
- (FullQuestProto_Builder*) clearDoneResponse;

- (BOOL) hasAcceptDialogue;
- (DialogueProto*) acceptDialogue;
- (FullQuestProto_Builder*) setAcceptDialogue:(DialogueProto*) value;
- (FullQuestProto_Builder*) setAcceptDialogue_Builder:(DialogueProto_Builder*) builderForValue;
- (FullQuestProto_Builder*) mergeAcceptDialogue:(DialogueProto*) value;
- (FullQuestProto_Builder*) clearAcceptDialogue;

- (BOOL) hasCashReward;
- (int32_t) cashReward;
- (FullQuestProto_Builder*) setCashReward:(int32_t) value;
- (FullQuestProto_Builder*) clearCashReward;

- (BOOL) hasOilReward;
- (int32_t) oilReward;
- (FullQuestProto_Builder*) setOilReward:(int32_t) value;
- (FullQuestProto_Builder*) clearOilReward;

- (BOOL) hasGemReward;
- (int32_t) gemReward;
- (FullQuestProto_Builder*) setGemReward:(int32_t) value;
- (FullQuestProto_Builder*) clearGemReward;

- (BOOL) hasExpReward;
- (int32_t) expReward;
- (FullQuestProto_Builder*) setExpReward:(int32_t) value;
- (FullQuestProto_Builder*) clearExpReward;

- (BOOL) hasMonsterIdReward;
- (int32_t) monsterIdReward;
- (FullQuestProto_Builder*) setMonsterIdReward:(int32_t) value;
- (FullQuestProto_Builder*) clearMonsterIdReward;

- (BOOL) hasIsCompleteMonster;
- (BOOL) isCompleteMonster;
- (FullQuestProto_Builder*) setIsCompleteMonster:(BOOL) value;
- (FullQuestProto_Builder*) clearIsCompleteMonster;

- (PBAppendableArray *)questsRequiredForThisList;
- (int32_t)questsRequiredForThisAtIndex:(NSUInteger)index;
- (FullQuestProto_Builder *)addQuestsRequiredForThis:(int32_t)value;
- (FullQuestProto_Builder *)addAllQuestsRequiredForThis:(NSArray *)array;
- (FullQuestProto_Builder *)setQuestsRequiredForThisValues:(const int32_t *)values count:(NSUInteger)count;
- (FullQuestProto_Builder *)clearQuestsRequiredForThis;

- (BOOL) hasQuestGiverName;
- (NSString*) questGiverName;
- (FullQuestProto_Builder*) setQuestGiverName:(NSString*) value;
- (FullQuestProto_Builder*) clearQuestGiverName;

- (BOOL) hasQuestGiverImagePrefix;
- (NSString*) questGiverImagePrefix;
- (FullQuestProto_Builder*) setQuestGiverImagePrefix:(NSString*) value;
- (FullQuestProto_Builder*) clearQuestGiverImagePrefix;

- (BOOL) hasPriority;
- (int32_t) priority;
- (FullQuestProto_Builder*) setPriority:(int32_t) value;
- (FullQuestProto_Builder*) clearPriority;

- (BOOL) hasCarrotId;
- (NSString*) carrotId;
- (FullQuestProto_Builder*) setCarrotId:(NSString*) value;
- (FullQuestProto_Builder*) clearCarrotId;

- (BOOL) hasQuestGiverImgOffset;
- (CoordinateProto*) questGiverImgOffset;
- (FullQuestProto_Builder*) setQuestGiverImgOffset:(CoordinateProto*) value;
- (FullQuestProto_Builder*) setQuestGiverImgOffset_Builder:(CoordinateProto_Builder*) builderForValue;
- (FullQuestProto_Builder*) mergeQuestGiverImgOffset:(CoordinateProto*) value;
- (FullQuestProto_Builder*) clearQuestGiverImgOffset;

- (BOOL) hasMonsterElement;
- (Element) monsterElement;
- (FullQuestProto_Builder*) setMonsterElement:(Element) value;
- (FullQuestProto_Builder*) clearMonsterElement;

- (NSMutableArray *)jobsList;
- (QuestJobProto*)jobsAtIndex:(NSUInteger)index;
- (FullQuestProto_Builder *)addJobs:(QuestJobProto*)value;
- (FullQuestProto_Builder *)addAllJobs:(NSArray *)array;
- (FullQuestProto_Builder *)clearJobs;
@end

@interface QuestJobProto : PBGeneratedMessage {
@private
  BOOL hasQuestJobId_:1;
  BOOL hasQuestId_:1;
  BOOL hasStaticDataId_:1;
  BOOL hasQuantity_:1;
  BOOL hasPriority_:1;
  BOOL hasCityId_:1;
  BOOL hasCityAssetNum_:1;
  BOOL hasDescription_:1;
  BOOL hasQuestJobType_:1;
  int32_t questJobId;
  int32_t questId;
  int32_t staticDataId;
  int32_t quantity;
  int32_t priority;
  int32_t cityId;
  int32_t cityAssetNum;
  NSString* description;
  QuestJobProto_QuestJobType questJobType;
}
- (BOOL) hasQuestJobId;
- (BOOL) hasQuestId;
- (BOOL) hasQuestJobType;
- (BOOL) hasDescription;
- (BOOL) hasStaticDataId;
- (BOOL) hasQuantity;
- (BOOL) hasPriority;
- (BOOL) hasCityId;
- (BOOL) hasCityAssetNum;
@property (readonly) int32_t questJobId;
@property (readonly) int32_t questId;
@property (readonly) QuestJobProto_QuestJobType questJobType;
@property (readonly, strong) NSString* description;
@property (readonly) int32_t staticDataId;
@property (readonly) int32_t quantity;
@property (readonly) int32_t priority;
@property (readonly) int32_t cityId;
@property (readonly) int32_t cityAssetNum;

+ (QuestJobProto*) defaultInstance;
- (QuestJobProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (QuestJobProto_Builder*) builder;
+ (QuestJobProto_Builder*) builder;
+ (QuestJobProto_Builder*) builderWithPrototype:(QuestJobProto*) prototype;
- (QuestJobProto_Builder*) toBuilder;

+ (QuestJobProto*) parseFromData:(NSData*) data;
+ (QuestJobProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestJobProto*) parseFromInputStream:(NSInputStream*) input;
+ (QuestJobProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestJobProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (QuestJobProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface QuestJobProto_Builder : PBGeneratedMessageBuilder {
@private
  QuestJobProto* result;
}

- (QuestJobProto*) defaultInstance;

- (QuestJobProto_Builder*) clear;
- (QuestJobProto_Builder*) clone;

- (QuestJobProto*) build;
- (QuestJobProto*) buildPartial;

- (QuestJobProto_Builder*) mergeFrom:(QuestJobProto*) other;
- (QuestJobProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (QuestJobProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasQuestJobId;
- (int32_t) questJobId;
- (QuestJobProto_Builder*) setQuestJobId:(int32_t) value;
- (QuestJobProto_Builder*) clearQuestJobId;

- (BOOL) hasQuestId;
- (int32_t) questId;
- (QuestJobProto_Builder*) setQuestId:(int32_t) value;
- (QuestJobProto_Builder*) clearQuestId;

- (BOOL) hasQuestJobType;
- (QuestJobProto_QuestJobType) questJobType;
- (QuestJobProto_Builder*) setQuestJobType:(QuestJobProto_QuestJobType) value;
- (QuestJobProto_Builder*) clearQuestJobType;

- (BOOL) hasDescription;
- (NSString*) description;
- (QuestJobProto_Builder*) setDescription:(NSString*) value;
- (QuestJobProto_Builder*) clearDescription;

- (BOOL) hasStaticDataId;
- (int32_t) staticDataId;
- (QuestJobProto_Builder*) setStaticDataId:(int32_t) value;
- (QuestJobProto_Builder*) clearStaticDataId;

- (BOOL) hasQuantity;
- (int32_t) quantity;
- (QuestJobProto_Builder*) setQuantity:(int32_t) value;
- (QuestJobProto_Builder*) clearQuantity;

- (BOOL) hasPriority;
- (int32_t) priority;
- (QuestJobProto_Builder*) setPriority:(int32_t) value;
- (QuestJobProto_Builder*) clearPriority;

- (BOOL) hasCityId;
- (int32_t) cityId;
- (QuestJobProto_Builder*) setCityId:(int32_t) value;
- (QuestJobProto_Builder*) clearCityId;

- (BOOL) hasCityAssetNum;
- (int32_t) cityAssetNum;
- (QuestJobProto_Builder*) setCityAssetNum:(int32_t) value;
- (QuestJobProto_Builder*) clearCityAssetNum;
@end

@interface DialogueProto : PBGeneratedMessage {
@private
  NSMutableArray * mutableSpeechSegmentList;
}
@property (readonly, strong) NSArray * speechSegmentList;
- (DialogueProto_SpeechSegmentProto*)speechSegmentAtIndex:(NSUInteger)index;

+ (DialogueProto*) defaultInstance;
- (DialogueProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (DialogueProto_Builder*) builder;
+ (DialogueProto_Builder*) builder;
+ (DialogueProto_Builder*) builderWithPrototype:(DialogueProto*) prototype;
- (DialogueProto_Builder*) toBuilder;

+ (DialogueProto*) parseFromData:(NSData*) data;
+ (DialogueProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (DialogueProto*) parseFromInputStream:(NSInputStream*) input;
+ (DialogueProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (DialogueProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (DialogueProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface DialogueProto_SpeechSegmentProto : PBGeneratedMessage {
@private
  BOOL hasIsLeftSide_:1;
  BOOL hasSpeaker_:1;
  BOOL hasSpeakerImage_:1;
  BOOL hasSpeakerText_:1;
  BOOL isLeftSide_:1;
  NSString* speaker;
  NSString* speakerImage;
  NSString* speakerText;
}
- (BOOL) hasSpeaker;
- (BOOL) hasSpeakerImage;
- (BOOL) hasSpeakerText;
- (BOOL) hasIsLeftSide;
@property (readonly, strong) NSString* speaker;
@property (readonly, strong) NSString* speakerImage;
@property (readonly, strong) NSString* speakerText;
- (BOOL) isLeftSide;

+ (DialogueProto_SpeechSegmentProto*) defaultInstance;
- (DialogueProto_SpeechSegmentProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (DialogueProto_SpeechSegmentProto_Builder*) builder;
+ (DialogueProto_SpeechSegmentProto_Builder*) builder;
+ (DialogueProto_SpeechSegmentProto_Builder*) builderWithPrototype:(DialogueProto_SpeechSegmentProto*) prototype;
- (DialogueProto_SpeechSegmentProto_Builder*) toBuilder;

+ (DialogueProto_SpeechSegmentProto*) parseFromData:(NSData*) data;
+ (DialogueProto_SpeechSegmentProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (DialogueProto_SpeechSegmentProto*) parseFromInputStream:(NSInputStream*) input;
+ (DialogueProto_SpeechSegmentProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (DialogueProto_SpeechSegmentProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (DialogueProto_SpeechSegmentProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface DialogueProto_SpeechSegmentProto_Builder : PBGeneratedMessageBuilder {
@private
  DialogueProto_SpeechSegmentProto* result;
}

- (DialogueProto_SpeechSegmentProto*) defaultInstance;

- (DialogueProto_SpeechSegmentProto_Builder*) clear;
- (DialogueProto_SpeechSegmentProto_Builder*) clone;

- (DialogueProto_SpeechSegmentProto*) build;
- (DialogueProto_SpeechSegmentProto*) buildPartial;

- (DialogueProto_SpeechSegmentProto_Builder*) mergeFrom:(DialogueProto_SpeechSegmentProto*) other;
- (DialogueProto_SpeechSegmentProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (DialogueProto_SpeechSegmentProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSpeaker;
- (NSString*) speaker;
- (DialogueProto_SpeechSegmentProto_Builder*) setSpeaker:(NSString*) value;
- (DialogueProto_SpeechSegmentProto_Builder*) clearSpeaker;

- (BOOL) hasSpeakerImage;
- (NSString*) speakerImage;
- (DialogueProto_SpeechSegmentProto_Builder*) setSpeakerImage:(NSString*) value;
- (DialogueProto_SpeechSegmentProto_Builder*) clearSpeakerImage;

- (BOOL) hasSpeakerText;
- (NSString*) speakerText;
- (DialogueProto_SpeechSegmentProto_Builder*) setSpeakerText:(NSString*) value;
- (DialogueProto_SpeechSegmentProto_Builder*) clearSpeakerText;

- (BOOL) hasIsLeftSide;
- (BOOL) isLeftSide;
- (DialogueProto_SpeechSegmentProto_Builder*) setIsLeftSide:(BOOL) value;
- (DialogueProto_SpeechSegmentProto_Builder*) clearIsLeftSide;
@end

@interface DialogueProto_Builder : PBGeneratedMessageBuilder {
@private
  DialogueProto* result;
}

- (DialogueProto*) defaultInstance;

- (DialogueProto_Builder*) clear;
- (DialogueProto_Builder*) clone;

- (DialogueProto*) build;
- (DialogueProto*) buildPartial;

- (DialogueProto_Builder*) mergeFrom:(DialogueProto*) other;
- (DialogueProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (DialogueProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (NSMutableArray *)speechSegmentList;
- (DialogueProto_SpeechSegmentProto*)speechSegmentAtIndex:(NSUInteger)index;
- (DialogueProto_Builder *)addSpeechSegment:(DialogueProto_SpeechSegmentProto*)value;
- (DialogueProto_Builder *)addAllSpeechSegment:(NSArray *)array;
- (DialogueProto_Builder *)clearSpeechSegment;
@end

@interface FullUserQuestProto : PBGeneratedMessage {
@private
  BOOL hasIsRedeemed_:1;
  BOOL hasIsComplete_:1;
  BOOL hasQuestId_:1;
  BOOL hasUserUuid_:1;
  BOOL isRedeemed_:1;
  BOOL isComplete_:1;
  int32_t questId;
  NSString* userUuid;
  NSMutableArray * mutableUserQuestJobsList;
}
- (BOOL) hasUserUuid;
- (BOOL) hasQuestId;
- (BOOL) hasIsRedeemed;
- (BOOL) hasIsComplete;
@property (readonly, strong) NSString* userUuid;
@property (readonly) int32_t questId;
- (BOOL) isRedeemed;
- (BOOL) isComplete;
@property (readonly, strong) NSArray * userQuestJobsList;
- (UserQuestJobProto*)userQuestJobsAtIndex:(NSUInteger)index;

+ (FullUserQuestProto*) defaultInstance;
- (FullUserQuestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (FullUserQuestProto_Builder*) builder;
+ (FullUserQuestProto_Builder*) builder;
+ (FullUserQuestProto_Builder*) builderWithPrototype:(FullUserQuestProto*) prototype;
- (FullUserQuestProto_Builder*) toBuilder;

+ (FullUserQuestProto*) parseFromData:(NSData*) data;
+ (FullUserQuestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FullUserQuestProto*) parseFromInputStream:(NSInputStream*) input;
+ (FullUserQuestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FullUserQuestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (FullUserQuestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface FullUserQuestProto_Builder : PBGeneratedMessageBuilder {
@private
  FullUserQuestProto* result;
}

- (FullUserQuestProto*) defaultInstance;

- (FullUserQuestProto_Builder*) clear;
- (FullUserQuestProto_Builder*) clone;

- (FullUserQuestProto*) build;
- (FullUserQuestProto*) buildPartial;

- (FullUserQuestProto_Builder*) mergeFrom:(FullUserQuestProto*) other;
- (FullUserQuestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (FullUserQuestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasUserUuid;
- (NSString*) userUuid;
- (FullUserQuestProto_Builder*) setUserUuid:(NSString*) value;
- (FullUserQuestProto_Builder*) clearUserUuid;

- (BOOL) hasQuestId;
- (int32_t) questId;
- (FullUserQuestProto_Builder*) setQuestId:(int32_t) value;
- (FullUserQuestProto_Builder*) clearQuestId;

- (BOOL) hasIsRedeemed;
- (BOOL) isRedeemed;
- (FullUserQuestProto_Builder*) setIsRedeemed:(BOOL) value;
- (FullUserQuestProto_Builder*) clearIsRedeemed;

- (BOOL) hasIsComplete;
- (BOOL) isComplete;
- (FullUserQuestProto_Builder*) setIsComplete:(BOOL) value;
- (FullUserQuestProto_Builder*) clearIsComplete;

- (NSMutableArray *)userQuestJobsList;
- (UserQuestJobProto*)userQuestJobsAtIndex:(NSUInteger)index;
- (FullUserQuestProto_Builder *)addUserQuestJobs:(UserQuestJobProto*)value;
- (FullUserQuestProto_Builder *)addAllUserQuestJobs:(NSArray *)array;
- (FullUserQuestProto_Builder *)clearUserQuestJobs;
@end

@interface UserQuestJobProto : PBGeneratedMessage {
@private
  BOOL hasIsComplete_:1;
  BOOL hasQuestId_:1;
  BOOL hasQuestJobId_:1;
  BOOL hasProgress_:1;
  BOOL isComplete_:1;
  int32_t questId;
  int32_t questJobId;
  int32_t progress;
}
- (BOOL) hasQuestId;
- (BOOL) hasQuestJobId;
- (BOOL) hasIsComplete;
- (BOOL) hasProgress;
@property (readonly) int32_t questId;
@property (readonly) int32_t questJobId;
- (BOOL) isComplete;
@property (readonly) int32_t progress;

+ (UserQuestJobProto*) defaultInstance;
- (UserQuestJobProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (UserQuestJobProto_Builder*) builder;
+ (UserQuestJobProto_Builder*) builder;
+ (UserQuestJobProto_Builder*) builderWithPrototype:(UserQuestJobProto*) prototype;
- (UserQuestJobProto_Builder*) toBuilder;

+ (UserQuestJobProto*) parseFromData:(NSData*) data;
+ (UserQuestJobProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserQuestJobProto*) parseFromInputStream:(NSInputStream*) input;
+ (UserQuestJobProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserQuestJobProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (UserQuestJobProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface UserQuestJobProto_Builder : PBGeneratedMessageBuilder {
@private
  UserQuestJobProto* result;
}

- (UserQuestJobProto*) defaultInstance;

- (UserQuestJobProto_Builder*) clear;
- (UserQuestJobProto_Builder*) clone;

- (UserQuestJobProto*) build;
- (UserQuestJobProto*) buildPartial;

- (UserQuestJobProto_Builder*) mergeFrom:(UserQuestJobProto*) other;
- (UserQuestJobProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (UserQuestJobProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasQuestId;
- (int32_t) questId;
- (UserQuestJobProto_Builder*) setQuestId:(int32_t) value;
- (UserQuestJobProto_Builder*) clearQuestId;

- (BOOL) hasQuestJobId;
- (int32_t) questJobId;
- (UserQuestJobProto_Builder*) setQuestJobId:(int32_t) value;
- (UserQuestJobProto_Builder*) clearQuestJobId;

- (BOOL) hasIsComplete;
- (BOOL) isComplete;
- (UserQuestJobProto_Builder*) setIsComplete:(BOOL) value;
- (UserQuestJobProto_Builder*) clearIsComplete;

- (BOOL) hasProgress;
- (int32_t) progress;
- (UserQuestJobProto_Builder*) setProgress:(int32_t) value;
- (UserQuestJobProto_Builder*) clearProgress;
@end


// @@protoc_insertion_point(global_scope)
