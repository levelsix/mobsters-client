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
typedef enum {
  FullQuestProto_QuestTypeKillMonster = 1,
  FullQuestProto_QuestTypeDonateMonster = 2,
  FullQuestProto_QuestTypeCompleteTask = 3,
  FullQuestProto_QuestTypeCollectCoinsFromHome = 4,
  FullQuestProto_QuestTypeBuildStruct = 5,
  FullQuestProto_QuestTypeUpgradeStruct = 6,
  FullQuestProto_QuestTypeMonsterAppear = 7,
  FullQuestProto_QuestTypeCollectSpecialItem = 8,
} FullQuestProto_QuestType;

BOOL FullQuestProto_QuestTypeIsValidValue(FullQuestProto_QuestType value);


@interface QuestRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface FullQuestProto : PBGeneratedMessage {
@private
  BOOL hasIsAchievement_:1;
  BOOL hasIsCompleteMonster_:1;
  BOOL hasPriority_:1;
  BOOL hasMonsterIdReward_:1;
  BOOL hasExpReward_:1;
  BOOL hasGemReward_:1;
  BOOL hasOilReward_:1;
  BOOL hasCashReward_:1;
  BOOL hasQuantity_:1;
  BOOL hasStaticDataId_:1;
  BOOL hasCityId_:1;
  BOOL hasQuestId_:1;
  BOOL hasJobDescription_:1;
  BOOL hasDoneResponse_:1;
  BOOL hasDescription_:1;
  BOOL hasName_:1;
  BOOL hasQuestGiverName_:1;
  BOOL hasQuestGiverImagePrefix_:1;
  BOOL hasCarrotId_:1;
  BOOL hasAcceptDialogue_:1;
  BOOL hasQuestGiverImgOffset_:1;
  BOOL hasQuestType_:1;
  BOOL hasMonsterElement_:1;
  BOOL isAchievement_:1;
  BOOL isCompleteMonster_:1;
  int32_t priority;
  int32_t monsterIdReward;
  int32_t expReward;
  int32_t gemReward;
  int32_t oilReward;
  int32_t cashReward;
  int32_t quantity;
  int32_t staticDataId;
  int32_t cityId;
  int32_t questId;
  NSString* jobDescription;
  NSString* doneResponse;
  NSString* description;
  NSString* name;
  NSString* questGiverName;
  NSString* questGiverImagePrefix;
  NSString* carrotId;
  DialogueProto* acceptDialogue;
  CoordinateProto* questGiverImgOffset;
  FullQuestProto_QuestType questType;
  MonsterProto_MonsterElement monsterElement;
  NSMutableArray* mutableQuestsRequiredForThisList;
}
- (BOOL) hasQuestId;
- (BOOL) hasCityId;
- (BOOL) hasName;
- (BOOL) hasDescription;
- (BOOL) hasDoneResponse;
- (BOOL) hasAcceptDialogue;
- (BOOL) hasQuestType;
- (BOOL) hasJobDescription;
- (BOOL) hasStaticDataId;
- (BOOL) hasQuantity;
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
- (BOOL) hasIsAchievement;
- (BOOL) hasQuestGiverImgOffset;
- (BOOL) hasMonsterElement;
@property (readonly) int32_t questId;
@property (readonly) int32_t cityId;
@property (readonly, retain) NSString* name;
@property (readonly, retain) NSString* description;
@property (readonly, retain) NSString* doneResponse;
@property (readonly, retain) DialogueProto* acceptDialogue;
@property (readonly) FullQuestProto_QuestType questType;
@property (readonly, retain) NSString* jobDescription;
@property (readonly) int32_t staticDataId;
@property (readonly) int32_t quantity;
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
- (BOOL) isAchievement;
@property (readonly, retain) CoordinateProto* questGiverImgOffset;
@property (readonly) MonsterProto_MonsterElement monsterElement;
- (NSArray*) questsRequiredForThisList;
- (int32_t) questsRequiredForThisAtIndex:(int32_t) index;

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

- (BOOL) hasCityId;
- (int32_t) cityId;
- (FullQuestProto_Builder*) setCityId:(int32_t) value;
- (FullQuestProto_Builder*) clearCityId;

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

- (BOOL) hasQuestType;
- (FullQuestProto_QuestType) questType;
- (FullQuestProto_Builder*) setQuestType:(FullQuestProto_QuestType) value;
- (FullQuestProto_Builder*) clearQuestType;

- (BOOL) hasJobDescription;
- (NSString*) jobDescription;
- (FullQuestProto_Builder*) setJobDescription:(NSString*) value;
- (FullQuestProto_Builder*) clearJobDescription;

- (BOOL) hasStaticDataId;
- (int32_t) staticDataId;
- (FullQuestProto_Builder*) setStaticDataId:(int32_t) value;
- (FullQuestProto_Builder*) clearStaticDataId;

- (BOOL) hasQuantity;
- (int32_t) quantity;
- (FullQuestProto_Builder*) setQuantity:(int32_t) value;
- (FullQuestProto_Builder*) clearQuantity;

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

- (BOOL) hasIsAchievement;
- (BOOL) isAchievement;
- (FullQuestProto_Builder*) setIsAchievement:(BOOL) value;
- (FullQuestProto_Builder*) clearIsAchievement;

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
  BOOL hasProgress_:1;
  BOOL isRedeemed_:1;
  BOOL isComplete_:1;
  int32_t userId;
  int32_t questId;
  int32_t progress;
}
- (BOOL) hasUserId;
- (BOOL) hasQuestId;
- (BOOL) hasIsRedeemed;
- (BOOL) hasIsComplete;
- (BOOL) hasProgress;
@property (readonly) int32_t userId;
@property (readonly) int32_t questId;
- (BOOL) isRedeemed;
- (BOOL) isComplete;
@property (readonly) int32_t progress;

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

- (BOOL) hasProgress;
- (int32_t) progress;
- (FullUserQuestProto_Builder*) setProgress:(int32_t) value;
- (FullUserQuestProto_Builder*) clearProgress;
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

