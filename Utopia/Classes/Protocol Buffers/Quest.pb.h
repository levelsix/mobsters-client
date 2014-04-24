// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "Chat.pb.h"
#import "MonsterStuff.pb.h"
#import "Structure.pb.h"

@class ColorProto;
@class ColorProto_Builder;
@class CoordinateProto;
@class CoordinateProto_Builder;
@class DialogueProto;
@class DialogueProto_Builder;
@class DialogueProto_SpeechSegmentProto;
@class DialogueProto_SpeechSegmentProto_Builder;
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
@class ItemProto;
@class ItemProto_Builder;
@class LabProto;
@class LabProto_Builder;
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
@class UserPvpLeagueProto;
@class UserPvpLeagueProto_Builder;
@class UserQuestJobProto;
@class UserQuestJobProto_Builder;
typedef enum {
  QuestJobProto_QuestJobTypeKillSpecificMonster = 1,
  QuestJobProto_QuestJobTypeKillMonsterInCity = 2,
  QuestJobProto_QuestJobTypeDonateMonster = 3,
  QuestJobProto_QuestJobTypeCompleteTask = 4,
  QuestJobProto_QuestJobTypeUpgradeStruct = 5,
  QuestJobProto_QuestJobTypeCollectSpecialItem = 6,
} QuestJobProto_QuestJobType;

BOOL QuestJobProto_QuestJobTypeIsValidValue(QuestJobProto_QuestJobType value);


@interface QuestRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface FullQuestProto : PBGeneratedMessage {
@private
  BOOL hasIsCompleteMonster_:1;
  BOOL hasPriority_:1;
  BOOL hasMonsterIdReward_:1;
  BOOL hasExpReward_:1;
  BOOL hasGemReward_:1;
  BOOL hasOilReward_:1;
  BOOL hasCashReward_:1;
  BOOL hasQuestId_:1;
  BOOL hasDoneResponse_:1;
  BOOL hasDescription_:1;
  BOOL hasName_:1;
  BOOL hasQuestGiverName_:1;
  BOOL hasQuestGiverImagePrefix_:1;
  BOOL hasCarrotId_:1;
  BOOL hasAcceptDialogue_:1;
  BOOL hasQuestGiverImgOffset_:1;
  BOOL hasMonsterElement_:1;
  BOOL isCompleteMonster_:1;
  int32_t priority;
  int32_t monsterIdReward;
  int32_t expReward;
  int32_t gemReward;
  int32_t oilReward;
  int32_t cashReward;
  int32_t questId;
  NSString* doneResponse;
  NSString* description;
  NSString* name;
  NSString* questGiverName;
  NSString* questGiverImagePrefix;
  NSString* carrotId;
  DialogueProto* acceptDialogue;
  CoordinateProto* questGiverImgOffset;
  MonsterProto_MonsterElement monsterElement;
  NSMutableArray* mutableQuestsRequiredForThisList;
  NSMutableArray* mutableJobsList;
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
@property (readonly, retain) NSString* name;
@property (readonly, retain) NSString* description;
@property (readonly, retain) NSString* doneResponse;
@property (readonly, retain) DialogueProto* acceptDialogue;
@property (readonly) int32_t cashReward;
@property (readonly) int32_t oilReward;
@property (readonly) int32_t gemReward;
@property (readonly) int32_t expReward;
@property (readonly) int32_t monsterIdReward;
- (BOOL) isCompleteMonster;
@property (readonly, retain) NSString* questGiverName;
@property (readonly, retain) NSString* questGiverImagePrefix;
@property (readonly) int32_t priority;
@property (readonly, retain) NSString* carrotId;
@property (readonly, retain) CoordinateProto* questGiverImgOffset;
@property (readonly) MonsterProto_MonsterElement monsterElement;
- (NSArray*) questsRequiredForThisList;
- (int32_t) questsRequiredForThisAtIndex:(int32_t) index;
- (NSArray*) jobsList;
- (QuestJobProto*) jobsAtIndex:(int32_t) index;

+ (FullQuestProto*) defaultInstance;
- (FullQuestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (FullQuestProto_Builder*) builder;
+ (FullQuestProto_Builder*) builder;
+ (FullQuestProto_Builder*) builderWithPrototype:(FullQuestProto*) prototype;

+ (FullQuestProto*) parseFromData:(NSData*) data;
+ (FullQuestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FullQuestProto*) parseFromInputStream:(NSInputStream*) input;
+ (FullQuestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FullQuestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (FullQuestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface FullQuestProto_Builder : PBGeneratedMessage_Builder {
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
- (FullQuestProto_Builder*) setAcceptDialogueBuilder:(DialogueProto_Builder*) builderForValue;
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

- (NSArray*) questsRequiredForThisList;
- (int32_t) questsRequiredForThisAtIndex:(int32_t) index;
- (FullQuestProto_Builder*) replaceQuestsRequiredForThisAtIndex:(int32_t) index with:(int32_t) value;
- (FullQuestProto_Builder*) addQuestsRequiredForThis:(int32_t) value;
- (FullQuestProto_Builder*) addAllQuestsRequiredForThis:(NSArray*) values;
- (FullQuestProto_Builder*) clearQuestsRequiredForThisList;

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
- (FullQuestProto_Builder*) setQuestGiverImgOffsetBuilder:(CoordinateProto_Builder*) builderForValue;
- (FullQuestProto_Builder*) mergeQuestGiverImgOffset:(CoordinateProto*) value;
- (FullQuestProto_Builder*) clearQuestGiverImgOffset;

- (BOOL) hasMonsterElement;
- (MonsterProto_MonsterElement) monsterElement;
- (FullQuestProto_Builder*) setMonsterElement:(MonsterProto_MonsterElement) value;
- (FullQuestProto_Builder*) clearMonsterElement;

- (NSArray*) jobsList;
- (QuestJobProto*) jobsAtIndex:(int32_t) index;
- (FullQuestProto_Builder*) replaceJobsAtIndex:(int32_t) index with:(QuestJobProto*) value;
- (FullQuestProto_Builder*) addJobs:(QuestJobProto*) value;
- (FullQuestProto_Builder*) addAllJobs:(NSArray*) values;
- (FullQuestProto_Builder*) clearJobsList;
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
@property (readonly, retain) NSString* description;
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

+ (QuestJobProto*) parseFromData:(NSData*) data;
+ (QuestJobProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestJobProto*) parseFromInputStream:(NSInputStream*) input;
+ (QuestJobProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestJobProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (QuestJobProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface QuestJobProto_Builder : PBGeneratedMessage_Builder {
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
  NSMutableArray* mutableSpeechSegmentList;
}
- (NSArray*) speechSegmentList;
- (DialogueProto_SpeechSegmentProto*) speechSegmentAtIndex:(int32_t) index;

+ (DialogueProto*) defaultInstance;
- (DialogueProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (DialogueProto_Builder*) builder;
+ (DialogueProto_Builder*) builder;
+ (DialogueProto_Builder*) builderWithPrototype:(DialogueProto*) prototype;

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
@property (readonly, retain) NSString* speaker;
@property (readonly, retain) NSString* speakerImage;
@property (readonly, retain) NSString* speakerText;
- (BOOL) isLeftSide;

+ (DialogueProto_SpeechSegmentProto*) defaultInstance;
- (DialogueProto_SpeechSegmentProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (DialogueProto_SpeechSegmentProto_Builder*) builder;
+ (DialogueProto_SpeechSegmentProto_Builder*) builder;
+ (DialogueProto_SpeechSegmentProto_Builder*) builderWithPrototype:(DialogueProto_SpeechSegmentProto*) prototype;

+ (DialogueProto_SpeechSegmentProto*) parseFromData:(NSData*) data;
+ (DialogueProto_SpeechSegmentProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (DialogueProto_SpeechSegmentProto*) parseFromInputStream:(NSInputStream*) input;
+ (DialogueProto_SpeechSegmentProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (DialogueProto_SpeechSegmentProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (DialogueProto_SpeechSegmentProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface DialogueProto_SpeechSegmentProto_Builder : PBGeneratedMessage_Builder {
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

@interface DialogueProto_Builder : PBGeneratedMessage_Builder {
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

- (NSArray*) speechSegmentList;
- (DialogueProto_SpeechSegmentProto*) speechSegmentAtIndex:(int32_t) index;
- (DialogueProto_Builder*) replaceSpeechSegmentAtIndex:(int32_t) index with:(DialogueProto_SpeechSegmentProto*) value;
- (DialogueProto_Builder*) addSpeechSegment:(DialogueProto_SpeechSegmentProto*) value;
- (DialogueProto_Builder*) addAllSpeechSegment:(NSArray*) values;
- (DialogueProto_Builder*) clearSpeechSegmentList;
@end

@interface FullUserQuestProto : PBGeneratedMessage {
@private
  BOOL hasIsRedeemed_:1;
  BOOL hasIsComplete_:1;
  BOOL hasUserId_:1;
  BOOL hasQuestId_:1;
  BOOL isRedeemed_:1;
  BOOL isComplete_:1;
  int32_t userId;
  int32_t questId;
  NSMutableArray* mutableUserQuestJobsList;
}
- (BOOL) hasUserId;
- (BOOL) hasQuestId;
- (BOOL) hasIsRedeemed;
- (BOOL) hasIsComplete;
@property (readonly) int32_t userId;
@property (readonly) int32_t questId;
- (BOOL) isRedeemed;
- (BOOL) isComplete;
- (NSArray*) userQuestJobsList;
- (UserQuestJobProto*) userQuestJobsAtIndex:(int32_t) index;

+ (FullUserQuestProto*) defaultInstance;
- (FullUserQuestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (FullUserQuestProto_Builder*) builder;
+ (FullUserQuestProto_Builder*) builder;
+ (FullUserQuestProto_Builder*) builderWithPrototype:(FullUserQuestProto*) prototype;

+ (FullUserQuestProto*) parseFromData:(NSData*) data;
+ (FullUserQuestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FullUserQuestProto*) parseFromInputStream:(NSInputStream*) input;
+ (FullUserQuestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FullUserQuestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (FullUserQuestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface FullUserQuestProto_Builder : PBGeneratedMessage_Builder {
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

- (BOOL) hasUserId;
- (int32_t) userId;
- (FullUserQuestProto_Builder*) setUserId:(int32_t) value;
- (FullUserQuestProto_Builder*) clearUserId;

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

- (NSArray*) userQuestJobsList;
- (UserQuestJobProto*) userQuestJobsAtIndex:(int32_t) index;
- (FullUserQuestProto_Builder*) replaceUserQuestJobsAtIndex:(int32_t) index with:(UserQuestJobProto*) value;
- (FullUserQuestProto_Builder*) addUserQuestJobs:(UserQuestJobProto*) value;
- (FullUserQuestProto_Builder*) addAllUserQuestJobs:(NSArray*) values;
- (FullUserQuestProto_Builder*) clearUserQuestJobsList;
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

+ (UserQuestJobProto*) parseFromData:(NSData*) data;
+ (UserQuestJobProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserQuestJobProto*) parseFromInputStream:(NSInputStream*) input;
+ (UserQuestJobProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserQuestJobProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (UserQuestJobProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface UserQuestJobProto_Builder : PBGeneratedMessage_Builder {
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

@interface ItemProto : PBGeneratedMessage {
@private
  BOOL hasItemId_:1;
  BOOL hasName_:1;
  BOOL hasImgName_:1;
  BOOL hasBorderImgName_:1;
  BOOL hasColor_:1;
  int32_t itemId;
  NSString* name;
  NSString* imgName;
  NSString* borderImgName;
  ColorProto* color;
}
- (BOOL) hasItemId;
- (BOOL) hasName;
- (BOOL) hasImgName;
- (BOOL) hasBorderImgName;
- (BOOL) hasColor;
@property (readonly) int32_t itemId;
@property (readonly, retain) NSString* name;
@property (readonly, retain) NSString* imgName;
@property (readonly, retain) NSString* borderImgName;
@property (readonly, retain) ColorProto* color;

+ (ItemProto*) defaultInstance;
- (ItemProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (ItemProto_Builder*) builder;
+ (ItemProto_Builder*) builder;
+ (ItemProto_Builder*) builderWithPrototype:(ItemProto*) prototype;

+ (ItemProto*) parseFromData:(NSData*) data;
+ (ItemProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ItemProto*) parseFromInputStream:(NSInputStream*) input;
+ (ItemProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ItemProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (ItemProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface ItemProto_Builder : PBGeneratedMessage_Builder {
@private
  ItemProto* result;
}

- (ItemProto*) defaultInstance;

- (ItemProto_Builder*) clear;
- (ItemProto_Builder*) clone;

- (ItemProto*) build;
- (ItemProto*) buildPartial;

- (ItemProto_Builder*) mergeFrom:(ItemProto*) other;
- (ItemProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (ItemProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasItemId;
- (int32_t) itemId;
- (ItemProto_Builder*) setItemId:(int32_t) value;
- (ItemProto_Builder*) clearItemId;

- (BOOL) hasName;
- (NSString*) name;
- (ItemProto_Builder*) setName:(NSString*) value;
- (ItemProto_Builder*) clearName;

- (BOOL) hasImgName;
- (NSString*) imgName;
- (ItemProto_Builder*) setImgName:(NSString*) value;
- (ItemProto_Builder*) clearImgName;

- (BOOL) hasBorderImgName;
- (NSString*) borderImgName;
- (ItemProto_Builder*) setBorderImgName:(NSString*) value;
- (ItemProto_Builder*) clearBorderImgName;

- (BOOL) hasColor;
- (ColorProto*) color;
- (ItemProto_Builder*) setColor:(ColorProto*) value;
- (ItemProto_Builder*) setColorBuilder:(ColorProto_Builder*) builderForValue;
- (ItemProto_Builder*) mergeColor:(ColorProto*) value;
- (ItemProto_Builder*) clearColor;
@end

