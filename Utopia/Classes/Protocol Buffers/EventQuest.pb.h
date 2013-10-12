// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "City.pb.h"
#import "Quest.pb.h"
#import "User.pb.h"

@class BuildStructJobProto;
@class BuildStructJobProto_Builder;
@class CityElementProto;
@class CityElementProto_Builder;
@class CityExpansionCostProto;
@class CityExpansionCostProto_Builder;
@class CoordinateProto;
@class CoordinateProto_Builder;
@class DialogueProto;
@class DialogueProto_Builder;
@class DialogueProto_SpeechSegmentProto;
@class DialogueProto_SpeechSegmentProto_Builder;
@class FullCityProto;
@class FullCityProto_Builder;
@class FullQuestProto;
@class FullQuestProto_Builder;
@class FullStructureProto;
@class FullStructureProto_Builder;
@class FullUserProto;
@class FullUserProto_Builder;
@class FullUserQuestDataLargeProto;
@class FullUserQuestDataLargeProto_Builder;
@class FullUserStructureProto;
@class FullUserStructureProto_Builder;
@class MinimumClanProto;
@class MinimumClanProto_Builder;
@class MinimumUserBuildStructJobProto;
@class MinimumUserBuildStructJobProto_Builder;
@class MinimumUserPossessEquipJobProto;
@class MinimumUserPossessEquipJobProto_Builder;
@class MinimumUserProto;
@class MinimumUserProtoWithLevel;
@class MinimumUserProtoWithLevelForLeaderboard;
@class MinimumUserProtoWithLevelForLeaderboard_Builder;
@class MinimumUserProtoWithLevel_Builder;
@class MinimumUserProto_Builder;
@class MinimumUserQuestTaskProto;
@class MinimumUserQuestTaskProto_Builder;
@class MinimumUserUpgradeStructJobProto;
@class MinimumUserUpgradeStructJobProto_Builder;
@class PossessEquipJobProto;
@class PossessEquipJobProto_Builder;
@class QuestAcceptRequestProto;
@class QuestAcceptRequestProto_Builder;
@class QuestAcceptResponseProto;
@class QuestAcceptResponseProto_Builder;
@class QuestCompleteResponseProto;
@class QuestCompleteResponseProto_Builder;
@class QuestRedeemRequestProto;
@class QuestRedeemRequestProto_Builder;
@class QuestRedeemResponseProto;
@class QuestRedeemResponseProto_Builder;
@class UpgradeStructJobProto;
@class UpgradeStructJobProto_Builder;
@class UserCityExpansionDataProto;
@class UserCityExpansionDataProto_Builder;
@class UserQuestDetailsRequestProto;
@class UserQuestDetailsRequestProto_Builder;
@class UserQuestDetailsResponseProto;
@class UserQuestDetailsResponseProto_Builder;
typedef enum {
  QuestAcceptResponseProto_QuestAcceptStatusSuccess = 1,
  QuestAcceptResponseProto_QuestAcceptStatusNotAvailToUser = 2,
  QuestAcceptResponseProto_QuestAcceptStatusOtherFail = 3,
} QuestAcceptResponseProto_QuestAcceptStatus;

BOOL QuestAcceptResponseProto_QuestAcceptStatusIsValidValue(QuestAcceptResponseProto_QuestAcceptStatus value);

typedef enum {
  QuestRedeemResponseProto_QuestRedeemStatusSuccess = 1,
  QuestRedeemResponseProto_QuestRedeemStatusNotComplete = 2,
  QuestRedeemResponseProto_QuestRedeemStatusOtherFail = 3,
} QuestRedeemResponseProto_QuestRedeemStatus;

BOOL QuestRedeemResponseProto_QuestRedeemStatusIsValidValue(QuestRedeemResponseProto_QuestRedeemStatus value);

typedef enum {
  UserQuestDetailsResponseProto_UserQuestDetailsStatusSuccess = 1,
  UserQuestDetailsResponseProto_UserQuestDetailsStatusSuppliedQuestidCurrentlyNotInProgress = 2,
  UserQuestDetailsResponseProto_UserQuestDetailsStatusSomeFail = 3,
} UserQuestDetailsResponseProto_UserQuestDetailsStatus;

BOOL UserQuestDetailsResponseProto_UserQuestDetailsStatusIsValidValue(UserQuestDetailsResponseProto_UserQuestDetailsStatus value);


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
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) int32_t questId;

+ (QuestAcceptRequestProto*) defaultInstance;
- (QuestAcceptRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (QuestAcceptRequestProto_Builder*) builder;
+ (QuestAcceptRequestProto_Builder*) builder;
+ (QuestAcceptRequestProto_Builder*) builderWithPrototype:(QuestAcceptRequestProto*) prototype;

+ (QuestAcceptRequestProto*) parseFromData:(NSData*) data;
+ (QuestAcceptRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestAcceptRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (QuestAcceptRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestAcceptRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (QuestAcceptRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface QuestAcceptRequestProto_Builder : PBGeneratedMessage_Builder {
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
- (QuestAcceptRequestProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (QuestAcceptRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (QuestAcceptRequestProto_Builder*) clearSender;

- (BOOL) hasQuestId;
- (int32_t) questId;
- (QuestAcceptRequestProto_Builder*) setQuestId:(int32_t) value;
- (QuestAcceptRequestProto_Builder*) clearQuestId;
@end

@interface QuestAcceptResponseProto : PBGeneratedMessage {
@private
  BOOL hasCityIdOfAcceptedQuest_:1;
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  int32_t cityIdOfAcceptedQuest;
  MinimumUserProto* sender;
  QuestAcceptResponseProto_QuestAcceptStatus status;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
- (BOOL) hasCityIdOfAcceptedQuest;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) QuestAcceptResponseProto_QuestAcceptStatus status;
@property (readonly) int32_t cityIdOfAcceptedQuest;

+ (QuestAcceptResponseProto*) defaultInstance;
- (QuestAcceptResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (QuestAcceptResponseProto_Builder*) builder;
+ (QuestAcceptResponseProto_Builder*) builder;
+ (QuestAcceptResponseProto_Builder*) builderWithPrototype:(QuestAcceptResponseProto*) prototype;

+ (QuestAcceptResponseProto*) parseFromData:(NSData*) data;
+ (QuestAcceptResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestAcceptResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (QuestAcceptResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestAcceptResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (QuestAcceptResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface QuestAcceptResponseProto_Builder : PBGeneratedMessage_Builder {
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
- (QuestAcceptResponseProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (QuestAcceptResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (QuestAcceptResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (QuestAcceptResponseProto_QuestAcceptStatus) status;
- (QuestAcceptResponseProto_Builder*) setStatus:(QuestAcceptResponseProto_QuestAcceptStatus) value;
- (QuestAcceptResponseProto_Builder*) clearStatus;

- (BOOL) hasCityIdOfAcceptedQuest;
- (int32_t) cityIdOfAcceptedQuest;
- (QuestAcceptResponseProto_Builder*) setCityIdOfAcceptedQuest:(int32_t) value;
- (QuestAcceptResponseProto_Builder*) clearCityIdOfAcceptedQuest;
@end

@interface QuestCompleteResponseProto : PBGeneratedMessage {
@private
  BOOL hasQuestId_:1;
  BOOL hasSender_:1;
  BOOL hasCityElement_:1;
  int32_t questId;
  MinimumUserProto* sender;
  CityElementProto* cityElement;
}
- (BOOL) hasSender;
- (BOOL) hasQuestId;
- (BOOL) hasCityElement;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) int32_t questId;
@property (readonly, retain) CityElementProto* cityElement;

+ (QuestCompleteResponseProto*) defaultInstance;
- (QuestCompleteResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (QuestCompleteResponseProto_Builder*) builder;
+ (QuestCompleteResponseProto_Builder*) builder;
+ (QuestCompleteResponseProto_Builder*) builderWithPrototype:(QuestCompleteResponseProto*) prototype;

+ (QuestCompleteResponseProto*) parseFromData:(NSData*) data;
+ (QuestCompleteResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestCompleteResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (QuestCompleteResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestCompleteResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (QuestCompleteResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface QuestCompleteResponseProto_Builder : PBGeneratedMessage_Builder {
@private
  QuestCompleteResponseProto* result;
}

- (QuestCompleteResponseProto*) defaultInstance;

- (QuestCompleteResponseProto_Builder*) clear;
- (QuestCompleteResponseProto_Builder*) clone;

- (QuestCompleteResponseProto*) build;
- (QuestCompleteResponseProto*) buildPartial;

- (QuestCompleteResponseProto_Builder*) mergeFrom:(QuestCompleteResponseProto*) other;
- (QuestCompleteResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (QuestCompleteResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (QuestCompleteResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (QuestCompleteResponseProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (QuestCompleteResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (QuestCompleteResponseProto_Builder*) clearSender;

- (BOOL) hasQuestId;
- (int32_t) questId;
- (QuestCompleteResponseProto_Builder*) setQuestId:(int32_t) value;
- (QuestCompleteResponseProto_Builder*) clearQuestId;

- (BOOL) hasCityElement;
- (CityElementProto*) cityElement;
- (QuestCompleteResponseProto_Builder*) setCityElement:(CityElementProto*) value;
- (QuestCompleteResponseProto_Builder*) setCityElementBuilder:(CityElementProto_Builder*) builderForValue;
- (QuestCompleteResponseProto_Builder*) mergeCityElement:(CityElementProto*) value;
- (QuestCompleteResponseProto_Builder*) clearCityElement;
@end

@interface QuestRedeemRequestProto : PBGeneratedMessage {
@private
  BOOL hasQuestId_:1;
  BOOL hasSender_:1;
  int32_t questId;
  MinimumUserProto* sender;
}
- (BOOL) hasSender;
- (BOOL) hasQuestId;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) int32_t questId;

+ (QuestRedeemRequestProto*) defaultInstance;
- (QuestRedeemRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (QuestRedeemRequestProto_Builder*) builder;
+ (QuestRedeemRequestProto_Builder*) builder;
+ (QuestRedeemRequestProto_Builder*) builderWithPrototype:(QuestRedeemRequestProto*) prototype;

+ (QuestRedeemRequestProto*) parseFromData:(NSData*) data;
+ (QuestRedeemRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestRedeemRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (QuestRedeemRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestRedeemRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (QuestRedeemRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface QuestRedeemRequestProto_Builder : PBGeneratedMessage_Builder {
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
- (MinimumUserProto*) sender;
- (QuestRedeemRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (QuestRedeemRequestProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (QuestRedeemRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (QuestRedeemRequestProto_Builder*) clearSender;

- (BOOL) hasQuestId;
- (int32_t) questId;
- (QuestRedeemRequestProto_Builder*) setQuestId:(int32_t) value;
- (QuestRedeemRequestProto_Builder*) clearQuestId;
@end

@interface QuestRedeemResponseProto : PBGeneratedMessage {
@private
  BOOL hasMonsterId_:1;
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  int32_t monsterId;
  MinimumUserProto* sender;
  QuestRedeemResponseProto_QuestRedeemStatus status;
  NSMutableArray* mutableNewlyAvailableQuestsList;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
- (BOOL) hasMonsterId;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) QuestRedeemResponseProto_QuestRedeemStatus status;
@property (readonly) int32_t monsterId;
- (NSArray*) newlyAvailableQuestsList;
- (FullQuestProto*) newlyAvailableQuestsAtIndex:(int32_t) index;

+ (QuestRedeemResponseProto*) defaultInstance;
- (QuestRedeemResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (QuestRedeemResponseProto_Builder*) builder;
+ (QuestRedeemResponseProto_Builder*) builder;
+ (QuestRedeemResponseProto_Builder*) builderWithPrototype:(QuestRedeemResponseProto*) prototype;

+ (QuestRedeemResponseProto*) parseFromData:(NSData*) data;
+ (QuestRedeemResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestRedeemResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (QuestRedeemResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QuestRedeemResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (QuestRedeemResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface QuestRedeemResponseProto_Builder : PBGeneratedMessage_Builder {
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
- (MinimumUserProto*) sender;
- (QuestRedeemResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (QuestRedeemResponseProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (QuestRedeemResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (QuestRedeemResponseProto_Builder*) clearSender;

- (NSArray*) newlyAvailableQuestsList;
- (FullQuestProto*) newlyAvailableQuestsAtIndex:(int32_t) index;
- (QuestRedeemResponseProto_Builder*) replaceNewlyAvailableQuestsAtIndex:(int32_t) index with:(FullQuestProto*) value;
- (QuestRedeemResponseProto_Builder*) addNewlyAvailableQuests:(FullQuestProto*) value;
- (QuestRedeemResponseProto_Builder*) addAllNewlyAvailableQuests:(NSArray*) values;
- (QuestRedeemResponseProto_Builder*) clearNewlyAvailableQuestsList;

- (BOOL) hasStatus;
- (QuestRedeemResponseProto_QuestRedeemStatus) status;
- (QuestRedeemResponseProto_Builder*) setStatus:(QuestRedeemResponseProto_QuestRedeemStatus) value;
- (QuestRedeemResponseProto_Builder*) clearStatus;

- (BOOL) hasMonsterId;
- (int32_t) monsterId;
- (QuestRedeemResponseProto_Builder*) setMonsterId:(int32_t) value;
- (QuestRedeemResponseProto_Builder*) clearMonsterId;
@end

@interface UserQuestDetailsRequestProto : PBGeneratedMessage {
@private
  BOOL hasQuestId_:1;
  BOOL hasSender_:1;
  int32_t questId;
  MinimumUserProto* sender;
}
- (BOOL) hasSender;
- (BOOL) hasQuestId;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) int32_t questId;

+ (UserQuestDetailsRequestProto*) defaultInstance;
- (UserQuestDetailsRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (UserQuestDetailsRequestProto_Builder*) builder;
+ (UserQuestDetailsRequestProto_Builder*) builder;
+ (UserQuestDetailsRequestProto_Builder*) builderWithPrototype:(UserQuestDetailsRequestProto*) prototype;

+ (UserQuestDetailsRequestProto*) parseFromData:(NSData*) data;
+ (UserQuestDetailsRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserQuestDetailsRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (UserQuestDetailsRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserQuestDetailsRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (UserQuestDetailsRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface UserQuestDetailsRequestProto_Builder : PBGeneratedMessage_Builder {
@private
  UserQuestDetailsRequestProto* result;
}

- (UserQuestDetailsRequestProto*) defaultInstance;

- (UserQuestDetailsRequestProto_Builder*) clear;
- (UserQuestDetailsRequestProto_Builder*) clone;

- (UserQuestDetailsRequestProto*) build;
- (UserQuestDetailsRequestProto*) buildPartial;

- (UserQuestDetailsRequestProto_Builder*) mergeFrom:(UserQuestDetailsRequestProto*) other;
- (UserQuestDetailsRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (UserQuestDetailsRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (UserQuestDetailsRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (UserQuestDetailsRequestProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (UserQuestDetailsRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (UserQuestDetailsRequestProto_Builder*) clearSender;

- (BOOL) hasQuestId;
- (int32_t) questId;
- (UserQuestDetailsRequestProto_Builder*) setQuestId:(int32_t) value;
- (UserQuestDetailsRequestProto_Builder*) clearQuestId;
@end

@interface UserQuestDetailsResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  UserQuestDetailsResponseProto_UserQuestDetailsStatus status;
  NSMutableArray* mutableInProgressUserQuestDataList;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) UserQuestDetailsResponseProto_UserQuestDetailsStatus status;
- (NSArray*) inProgressUserQuestDataList;
- (FullUserQuestDataLargeProto*) inProgressUserQuestDataAtIndex:(int32_t) index;

+ (UserQuestDetailsResponseProto*) defaultInstance;
- (UserQuestDetailsResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (UserQuestDetailsResponseProto_Builder*) builder;
+ (UserQuestDetailsResponseProto_Builder*) builder;
+ (UserQuestDetailsResponseProto_Builder*) builderWithPrototype:(UserQuestDetailsResponseProto*) prototype;

+ (UserQuestDetailsResponseProto*) parseFromData:(NSData*) data;
+ (UserQuestDetailsResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserQuestDetailsResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (UserQuestDetailsResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserQuestDetailsResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (UserQuestDetailsResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface UserQuestDetailsResponseProto_Builder : PBGeneratedMessage_Builder {
@private
  UserQuestDetailsResponseProto* result;
}

- (UserQuestDetailsResponseProto*) defaultInstance;

- (UserQuestDetailsResponseProto_Builder*) clear;
- (UserQuestDetailsResponseProto_Builder*) clone;

- (UserQuestDetailsResponseProto*) build;
- (UserQuestDetailsResponseProto*) buildPartial;

- (UserQuestDetailsResponseProto_Builder*) mergeFrom:(UserQuestDetailsResponseProto*) other;
- (UserQuestDetailsResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (UserQuestDetailsResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (UserQuestDetailsResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (UserQuestDetailsResponseProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (UserQuestDetailsResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (UserQuestDetailsResponseProto_Builder*) clearSender;

- (NSArray*) inProgressUserQuestDataList;
- (FullUserQuestDataLargeProto*) inProgressUserQuestDataAtIndex:(int32_t) index;
- (UserQuestDetailsResponseProto_Builder*) replaceInProgressUserQuestDataAtIndex:(int32_t) index with:(FullUserQuestDataLargeProto*) value;
- (UserQuestDetailsResponseProto_Builder*) addInProgressUserQuestData:(FullUserQuestDataLargeProto*) value;
- (UserQuestDetailsResponseProto_Builder*) addAllInProgressUserQuestData:(NSArray*) values;
- (UserQuestDetailsResponseProto_Builder*) clearInProgressUserQuestDataList;

- (BOOL) hasStatus;
- (UserQuestDetailsResponseProto_UserQuestDetailsStatus) status;
- (UserQuestDetailsResponseProto_Builder*) setStatus:(UserQuestDetailsResponseProto_UserQuestDetailsStatus) value;
- (UserQuestDetailsResponseProto_Builder*) clearStatus;
@end

