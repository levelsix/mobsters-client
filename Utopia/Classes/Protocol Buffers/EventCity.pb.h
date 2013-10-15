// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "City.pb.h"
#import "Quest.pb.h"
#import "Structure.pb.h"
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
@class LoadCityRequestProto;
@class LoadCityRequestProto_Builder;
@class LoadCityResponseProto;
@class LoadCityResponseProto_Builder;
@class LoadPlayerCityRequestProto;
@class LoadPlayerCityRequestProto_Builder;
@class LoadPlayerCityResponseProto;
@class LoadPlayerCityResponseProto_Builder;
@class MinimumClanProto;
@class MinimumClanProto_Builder;
@class MinimumUserBuildStructJobProto;
@class MinimumUserBuildStructJobProto_Builder;
@class MinimumUserProto;
@class MinimumUserProtoWithLevel;
@class MinimumUserProtoWithLevel_Builder;
@class MinimumUserProto_Builder;
@class MinimumUserQuestTaskProto;
@class MinimumUserQuestTaskProto_Builder;
@class MinimumUserUpgradeStructJobProto;
@class MinimumUserUpgradeStructJobProto_Builder;
@class PurchaseCityExpansionRequestProto;
@class PurchaseCityExpansionRequestProto_Builder;
@class PurchaseCityExpansionResponseProto;
@class PurchaseCityExpansionResponseProto_Builder;
@class UpgradeStructJobProto;
@class UpgradeStructJobProto_Builder;
@class UserCityExpansionDataProto;
@class UserCityExpansionDataProto_Builder;
typedef enum {
  LoadPlayerCityResponseProto_LoadPlayerCityStatusSuccess = 1,
  LoadPlayerCityResponseProto_LoadPlayerCityStatusNoSuchPlayer = 2,
  LoadPlayerCityResponseProto_LoadPlayerCityStatusOtherFail = 3,
} LoadPlayerCityResponseProto_LoadPlayerCityStatus;

BOOL LoadPlayerCityResponseProto_LoadPlayerCityStatusIsValidValue(LoadPlayerCityResponseProto_LoadPlayerCityStatus value);

typedef enum {
  PurchaseCityExpansionResponseProto_PurchaseCityExpansionStatusSuccess = 1,
  PurchaseCityExpansionResponseProto_PurchaseCityExpansionStatusNotEnoughCoins = 2,
  PurchaseCityExpansionResponseProto_PurchaseCityExpansionStatusAlreadyExpanding = 3,
  PurchaseCityExpansionResponseProto_PurchaseCityExpansionStatusOtherFail = 4,
  PurchaseCityExpansionResponseProto_PurchaseCityExpansionStatusClientTooApartFromServerTime = 5,
} PurchaseCityExpansionResponseProto_PurchaseCityExpansionStatus;

BOOL PurchaseCityExpansionResponseProto_PurchaseCityExpansionStatusIsValidValue(PurchaseCityExpansionResponseProto_PurchaseCityExpansionStatus value);

typedef enum {
  LoadCityResponseProto_LoadCityStatusSuccess = 1,
  LoadCityResponseProto_LoadCityStatusNotAccessibleToUser = 2,
  LoadCityResponseProto_LoadCityStatusOtherFail = 3,
} LoadCityResponseProto_LoadCityStatus;

BOOL LoadCityResponseProto_LoadCityStatusIsValidValue(LoadCityResponseProto_LoadCityStatus value);


@interface EventCityRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface LoadPlayerCityRequestProto : PBGeneratedMessage {
@private
  BOOL hasCityOwnerId_:1;
  BOOL hasSender_:1;
  int32_t cityOwnerId;
  MinimumUserProto* sender;
}
- (BOOL) hasSender;
- (BOOL) hasCityOwnerId;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) int32_t cityOwnerId;

+ (LoadPlayerCityRequestProto*) defaultInstance;
- (LoadPlayerCityRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (LoadPlayerCityRequestProto_Builder*) builder;
+ (LoadPlayerCityRequestProto_Builder*) builder;
+ (LoadPlayerCityRequestProto_Builder*) builderWithPrototype:(LoadPlayerCityRequestProto*) prototype;

+ (LoadPlayerCityRequestProto*) parseFromData:(NSData*) data;
+ (LoadPlayerCityRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (LoadPlayerCityRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (LoadPlayerCityRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (LoadPlayerCityRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (LoadPlayerCityRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface LoadPlayerCityRequestProto_Builder : PBGeneratedMessage_Builder {
@private
  LoadPlayerCityRequestProto* result;
}

- (LoadPlayerCityRequestProto*) defaultInstance;

- (LoadPlayerCityRequestProto_Builder*) clear;
- (LoadPlayerCityRequestProto_Builder*) clone;

- (LoadPlayerCityRequestProto*) build;
- (LoadPlayerCityRequestProto*) buildPartial;

- (LoadPlayerCityRequestProto_Builder*) mergeFrom:(LoadPlayerCityRequestProto*) other;
- (LoadPlayerCityRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (LoadPlayerCityRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (LoadPlayerCityRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (LoadPlayerCityRequestProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (LoadPlayerCityRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (LoadPlayerCityRequestProto_Builder*) clearSender;

- (BOOL) hasCityOwnerId;
- (int32_t) cityOwnerId;
- (LoadPlayerCityRequestProto_Builder*) setCityOwnerId:(int32_t) value;
- (LoadPlayerCityRequestProto_Builder*) clearCityOwnerId;
@end

@interface LoadPlayerCityResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasCityOwner_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  MinimumUserProto* cityOwner;
  LoadPlayerCityResponseProto_LoadPlayerCityStatus status;
  NSMutableArray* mutableOwnerNormStructsList;
  NSMutableArray* mutableUserCityExpansionDataProtoListList;
}
- (BOOL) hasSender;
- (BOOL) hasCityOwner;
- (BOOL) hasStatus;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly, retain) MinimumUserProto* cityOwner;
@property (readonly) LoadPlayerCityResponseProto_LoadPlayerCityStatus status;
- (NSArray*) ownerNormStructsList;
- (FullUserStructureProto*) ownerNormStructsAtIndex:(int32_t) index;
- (NSArray*) userCityExpansionDataProtoListList;
- (UserCityExpansionDataProto*) userCityExpansionDataProtoListAtIndex:(int32_t) index;

+ (LoadPlayerCityResponseProto*) defaultInstance;
- (LoadPlayerCityResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (LoadPlayerCityResponseProto_Builder*) builder;
+ (LoadPlayerCityResponseProto_Builder*) builder;
+ (LoadPlayerCityResponseProto_Builder*) builderWithPrototype:(LoadPlayerCityResponseProto*) prototype;

+ (LoadPlayerCityResponseProto*) parseFromData:(NSData*) data;
+ (LoadPlayerCityResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (LoadPlayerCityResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (LoadPlayerCityResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (LoadPlayerCityResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (LoadPlayerCityResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface LoadPlayerCityResponseProto_Builder : PBGeneratedMessage_Builder {
@private
  LoadPlayerCityResponseProto* result;
}

- (LoadPlayerCityResponseProto*) defaultInstance;

- (LoadPlayerCityResponseProto_Builder*) clear;
- (LoadPlayerCityResponseProto_Builder*) clone;

- (LoadPlayerCityResponseProto*) build;
- (LoadPlayerCityResponseProto*) buildPartial;

- (LoadPlayerCityResponseProto_Builder*) mergeFrom:(LoadPlayerCityResponseProto*) other;
- (LoadPlayerCityResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (LoadPlayerCityResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (LoadPlayerCityResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (LoadPlayerCityResponseProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (LoadPlayerCityResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (LoadPlayerCityResponseProto_Builder*) clearSender;

- (BOOL) hasCityOwner;
- (MinimumUserProto*) cityOwner;
- (LoadPlayerCityResponseProto_Builder*) setCityOwner:(MinimumUserProto*) value;
- (LoadPlayerCityResponseProto_Builder*) setCityOwnerBuilder:(MinimumUserProto_Builder*) builderForValue;
- (LoadPlayerCityResponseProto_Builder*) mergeCityOwner:(MinimumUserProto*) value;
- (LoadPlayerCityResponseProto_Builder*) clearCityOwner;

- (BOOL) hasStatus;
- (LoadPlayerCityResponseProto_LoadPlayerCityStatus) status;
- (LoadPlayerCityResponseProto_Builder*) setStatus:(LoadPlayerCityResponseProto_LoadPlayerCityStatus) value;
- (LoadPlayerCityResponseProto_Builder*) clearStatus;

- (NSArray*) ownerNormStructsList;
- (FullUserStructureProto*) ownerNormStructsAtIndex:(int32_t) index;
- (LoadPlayerCityResponseProto_Builder*) replaceOwnerNormStructsAtIndex:(int32_t) index with:(FullUserStructureProto*) value;
- (LoadPlayerCityResponseProto_Builder*) addOwnerNormStructs:(FullUserStructureProto*) value;
- (LoadPlayerCityResponseProto_Builder*) addAllOwnerNormStructs:(NSArray*) values;
- (LoadPlayerCityResponseProto_Builder*) clearOwnerNormStructsList;

- (NSArray*) userCityExpansionDataProtoListList;
- (UserCityExpansionDataProto*) userCityExpansionDataProtoListAtIndex:(int32_t) index;
- (LoadPlayerCityResponseProto_Builder*) replaceUserCityExpansionDataProtoListAtIndex:(int32_t) index with:(UserCityExpansionDataProto*) value;
- (LoadPlayerCityResponseProto_Builder*) addUserCityExpansionDataProtoList:(UserCityExpansionDataProto*) value;
- (LoadPlayerCityResponseProto_Builder*) addAllUserCityExpansionDataProtoList:(NSArray*) values;
- (LoadPlayerCityResponseProto_Builder*) clearUserCityExpansionDataProtoListList;
@end

@interface PurchaseCityExpansionRequestProto : PBGeneratedMessage {
@private
  BOOL hasTimeOfPurchase_:1;
  BOOL hasSender_:1;
  BOOL hasXPosition_:1;
  BOOL hasYPosition_:1;
  int64_t timeOfPurchase;
  MinimumUserProto* sender;
  int32_t xPosition;
  int32_t yPosition;
}
- (BOOL) hasSender;
- (BOOL) hasXPosition;
- (BOOL) hasYPosition;
- (BOOL) hasTimeOfPurchase;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) int32_t xPosition;
@property (readonly) int32_t yPosition;
@property (readonly) int64_t timeOfPurchase;

+ (PurchaseCityExpansionRequestProto*) defaultInstance;
- (PurchaseCityExpansionRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PurchaseCityExpansionRequestProto_Builder*) builder;
+ (PurchaseCityExpansionRequestProto_Builder*) builder;
+ (PurchaseCityExpansionRequestProto_Builder*) builderWithPrototype:(PurchaseCityExpansionRequestProto*) prototype;

+ (PurchaseCityExpansionRequestProto*) parseFromData:(NSData*) data;
+ (PurchaseCityExpansionRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PurchaseCityExpansionRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (PurchaseCityExpansionRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PurchaseCityExpansionRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PurchaseCityExpansionRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PurchaseCityExpansionRequestProto_Builder : PBGeneratedMessage_Builder {
@private
  PurchaseCityExpansionRequestProto* result;
}

- (PurchaseCityExpansionRequestProto*) defaultInstance;

- (PurchaseCityExpansionRequestProto_Builder*) clear;
- (PurchaseCityExpansionRequestProto_Builder*) clone;

- (PurchaseCityExpansionRequestProto*) build;
- (PurchaseCityExpansionRequestProto*) buildPartial;

- (PurchaseCityExpansionRequestProto_Builder*) mergeFrom:(PurchaseCityExpansionRequestProto*) other;
- (PurchaseCityExpansionRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PurchaseCityExpansionRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (PurchaseCityExpansionRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (PurchaseCityExpansionRequestProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (PurchaseCityExpansionRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (PurchaseCityExpansionRequestProto_Builder*) clearSender;

- (BOOL) hasXPosition;
- (int32_t) xPosition;
- (PurchaseCityExpansionRequestProto_Builder*) setXPosition:(int32_t) value;
- (PurchaseCityExpansionRequestProto_Builder*) clearXPosition;

- (BOOL) hasYPosition;
- (int32_t) yPosition;
- (PurchaseCityExpansionRequestProto_Builder*) setYPosition:(int32_t) value;
- (PurchaseCityExpansionRequestProto_Builder*) clearYPosition;

- (BOOL) hasTimeOfPurchase;
- (int64_t) timeOfPurchase;
- (PurchaseCityExpansionRequestProto_Builder*) setTimeOfPurchase:(int64_t) value;
- (PurchaseCityExpansionRequestProto_Builder*) clearTimeOfPurchase;
@end

@interface PurchaseCityExpansionResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasUcedp_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  UserCityExpansionDataProto* ucedp;
  PurchaseCityExpansionResponseProto_PurchaseCityExpansionStatus status;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
- (BOOL) hasUcedp;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) PurchaseCityExpansionResponseProto_PurchaseCityExpansionStatus status;
@property (readonly, retain) UserCityExpansionDataProto* ucedp;

+ (PurchaseCityExpansionResponseProto*) defaultInstance;
- (PurchaseCityExpansionResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PurchaseCityExpansionResponseProto_Builder*) builder;
+ (PurchaseCityExpansionResponseProto_Builder*) builder;
+ (PurchaseCityExpansionResponseProto_Builder*) builderWithPrototype:(PurchaseCityExpansionResponseProto*) prototype;

+ (PurchaseCityExpansionResponseProto*) parseFromData:(NSData*) data;
+ (PurchaseCityExpansionResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PurchaseCityExpansionResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (PurchaseCityExpansionResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PurchaseCityExpansionResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PurchaseCityExpansionResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PurchaseCityExpansionResponseProto_Builder : PBGeneratedMessage_Builder {
@private
  PurchaseCityExpansionResponseProto* result;
}

- (PurchaseCityExpansionResponseProto*) defaultInstance;

- (PurchaseCityExpansionResponseProto_Builder*) clear;
- (PurchaseCityExpansionResponseProto_Builder*) clone;

- (PurchaseCityExpansionResponseProto*) build;
- (PurchaseCityExpansionResponseProto*) buildPartial;

- (PurchaseCityExpansionResponseProto_Builder*) mergeFrom:(PurchaseCityExpansionResponseProto*) other;
- (PurchaseCityExpansionResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PurchaseCityExpansionResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (PurchaseCityExpansionResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (PurchaseCityExpansionResponseProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (PurchaseCityExpansionResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (PurchaseCityExpansionResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (PurchaseCityExpansionResponseProto_PurchaseCityExpansionStatus) status;
- (PurchaseCityExpansionResponseProto_Builder*) setStatus:(PurchaseCityExpansionResponseProto_PurchaseCityExpansionStatus) value;
- (PurchaseCityExpansionResponseProto_Builder*) clearStatus;

- (BOOL) hasUcedp;
- (UserCityExpansionDataProto*) ucedp;
- (PurchaseCityExpansionResponseProto_Builder*) setUcedp:(UserCityExpansionDataProto*) value;
- (PurchaseCityExpansionResponseProto_Builder*) setUcedpBuilder:(UserCityExpansionDataProto_Builder*) builderForValue;
- (PurchaseCityExpansionResponseProto_Builder*) mergeUcedp:(UserCityExpansionDataProto*) value;
- (PurchaseCityExpansionResponseProto_Builder*) clearUcedp;
@end

@interface LoadCityRequestProto : PBGeneratedMessage {
@private
  BOOL hasCityId_:1;
  BOOL hasSender_:1;
  int32_t cityId;
  MinimumUserProto* sender;
}
- (BOOL) hasSender;
- (BOOL) hasCityId;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) int32_t cityId;

+ (LoadCityRequestProto*) defaultInstance;
- (LoadCityRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (LoadCityRequestProto_Builder*) builder;
+ (LoadCityRequestProto_Builder*) builder;
+ (LoadCityRequestProto_Builder*) builderWithPrototype:(LoadCityRequestProto*) prototype;

+ (LoadCityRequestProto*) parseFromData:(NSData*) data;
+ (LoadCityRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (LoadCityRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (LoadCityRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (LoadCityRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (LoadCityRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface LoadCityRequestProto_Builder : PBGeneratedMessage_Builder {
@private
  LoadCityRequestProto* result;
}

- (LoadCityRequestProto*) defaultInstance;

- (LoadCityRequestProto_Builder*) clear;
- (LoadCityRequestProto_Builder*) clone;

- (LoadCityRequestProto*) build;
- (LoadCityRequestProto*) buildPartial;

- (LoadCityRequestProto_Builder*) mergeFrom:(LoadCityRequestProto*) other;
- (LoadCityRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (LoadCityRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (LoadCityRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (LoadCityRequestProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (LoadCityRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (LoadCityRequestProto_Builder*) clearSender;

- (BOOL) hasCityId;
- (int32_t) cityId;
- (LoadCityRequestProto_Builder*) setCityId:(int32_t) value;
- (LoadCityRequestProto_Builder*) clearCityId;
@end

@interface LoadCityResponseProto : PBGeneratedMessage {
@private
  BOOL hasCityId_:1;
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  int32_t cityId;
  MinimumUserProto* sender;
  LoadCityResponseProto_LoadCityStatus status;
  NSMutableArray* mutableCityElementsList;
  NSMutableArray* mutableInProgressUserQuestDataInCityList;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
- (BOOL) hasCityId;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) LoadCityResponseProto_LoadCityStatus status;
@property (readonly) int32_t cityId;
- (NSArray*) cityElementsList;
- (CityElementProto*) cityElementsAtIndex:(int32_t) index;
- (NSArray*) inProgressUserQuestDataInCityList;
- (FullUserQuestDataLargeProto*) inProgressUserQuestDataInCityAtIndex:(int32_t) index;

+ (LoadCityResponseProto*) defaultInstance;
- (LoadCityResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (LoadCityResponseProto_Builder*) builder;
+ (LoadCityResponseProto_Builder*) builder;
+ (LoadCityResponseProto_Builder*) builderWithPrototype:(LoadCityResponseProto*) prototype;

+ (LoadCityResponseProto*) parseFromData:(NSData*) data;
+ (LoadCityResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (LoadCityResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (LoadCityResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (LoadCityResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (LoadCityResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface LoadCityResponseProto_Builder : PBGeneratedMessage_Builder {
@private
  LoadCityResponseProto* result;
}

- (LoadCityResponseProto*) defaultInstance;

- (LoadCityResponseProto_Builder*) clear;
- (LoadCityResponseProto_Builder*) clone;

- (LoadCityResponseProto*) build;
- (LoadCityResponseProto*) buildPartial;

- (LoadCityResponseProto_Builder*) mergeFrom:(LoadCityResponseProto*) other;
- (LoadCityResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (LoadCityResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (LoadCityResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (LoadCityResponseProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (LoadCityResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (LoadCityResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (LoadCityResponseProto_LoadCityStatus) status;
- (LoadCityResponseProto_Builder*) setStatus:(LoadCityResponseProto_LoadCityStatus) value;
- (LoadCityResponseProto_Builder*) clearStatus;

- (NSArray*) cityElementsList;
- (CityElementProto*) cityElementsAtIndex:(int32_t) index;
- (LoadCityResponseProto_Builder*) replaceCityElementsAtIndex:(int32_t) index with:(CityElementProto*) value;
- (LoadCityResponseProto_Builder*) addCityElements:(CityElementProto*) value;
- (LoadCityResponseProto_Builder*) addAllCityElements:(NSArray*) values;
- (LoadCityResponseProto_Builder*) clearCityElementsList;

- (BOOL) hasCityId;
- (int32_t) cityId;
- (LoadCityResponseProto_Builder*) setCityId:(int32_t) value;
- (LoadCityResponseProto_Builder*) clearCityId;

- (NSArray*) inProgressUserQuestDataInCityList;
- (FullUserQuestDataLargeProto*) inProgressUserQuestDataInCityAtIndex:(int32_t) index;
- (LoadCityResponseProto_Builder*) replaceInProgressUserQuestDataInCityAtIndex:(int32_t) index with:(FullUserQuestDataLargeProto*) value;
- (LoadCityResponseProto_Builder*) addInProgressUserQuestDataInCity:(FullUserQuestDataLargeProto*) value;
- (LoadCityResponseProto_Builder*) addAllInProgressUserQuestDataInCity:(NSArray*) values;
- (LoadCityResponseProto_Builder*) clearInProgressUserQuestDataInCityList;
@end

