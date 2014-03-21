// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "InAppPurchase.pb.h"
#import "Structure.pb.h"
#import "User.pb.h"

@class CoordinateProto;
@class CoordinateProto_Builder;
@class EarnFreeDiamondsRequestProto;
@class EarnFreeDiamondsRequestProto_Builder;
@class EarnFreeDiamondsResponseProto;
@class EarnFreeDiamondsResponseProto_Builder;
@class ExchangeGemsForResourcesRequestProto;
@class ExchangeGemsForResourcesRequestProto_Builder;
@class ExchangeGemsForResourcesResponseProto;
@class ExchangeGemsForResourcesResponseProto_Builder;
@class FullUserProto;
@class FullUserProto_Builder;
@class FullUserStructureProto;
@class FullUserStructureProto_Builder;
@class GoldSaleProto;
@class GoldSaleProto_Builder;
@class HospitalProto;
@class HospitalProto_Builder;
@class InAppPurchasePackageProto;
@class InAppPurchasePackageProto_Builder;
@class InAppPurchaseRequestProto;
@class InAppPurchaseRequestProto_Builder;
@class InAppPurchaseResponseProto;
@class InAppPurchaseResponseProto_Builder;
@class LabProto;
@class LabProto_Builder;
@class MinimumClanProto;
@class MinimumClanProto_Builder;
@class MinimumObstacleProto;
@class MinimumObstacleProto_Builder;
@class MinimumUserProto;
@class MinimumUserProtoWithFacebookId;
@class MinimumUserProtoWithFacebookId_Builder;
@class MinimumUserProtoWithLevel;
@class MinimumUserProtoWithLevel_Builder;
@class MinimumUserProtoWithMaxResources;
@class MinimumUserProtoWithMaxResources_Builder;
@class MinimumUserProto_Builder;
@class ObstacleProto;
@class ObstacleProto_Builder;
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
@class UserFacebookInviteForSlotProto;
@class UserFacebookInviteForSlotProto_Builder;
@class UserObstacleProto;
@class UserObstacleProto_Builder;
typedef enum {
  InAppPurchaseResponseProto_InAppPurchaseStatusSuccess = 1,
  InAppPurchaseResponseProto_InAppPurchaseStatusFail = 2,
  InAppPurchaseResponseProto_InAppPurchaseStatusDuplicateReceipt = 3,
} InAppPurchaseResponseProto_InAppPurchaseStatus;

BOOL InAppPurchaseResponseProto_InAppPurchaseStatusIsValidValue(InAppPurchaseResponseProto_InAppPurchaseStatus value);

typedef enum {
  EarnFreeDiamondsResponseProto_EarnFreeDiamondsStatusSuccess = 1,
  EarnFreeDiamondsResponseProto_EarnFreeDiamondsStatusClientTooApartFromServerTime = 2,
  EarnFreeDiamondsResponseProto_EarnFreeDiamondsStatusMethodNotSupported = 3,
  EarnFreeDiamondsResponseProto_EarnFreeDiamondsStatusOtherFail = 4,
} EarnFreeDiamondsResponseProto_EarnFreeDiamondsStatus;

BOOL EarnFreeDiamondsResponseProto_EarnFreeDiamondsStatusIsValidValue(EarnFreeDiamondsResponseProto_EarnFreeDiamondsStatus value);

typedef enum {
  ExchangeGemsForResourcesResponseProto_ExchangeGemsForResourcesStatusSuccess = 1,
  ExchangeGemsForResourcesResponseProto_ExchangeGemsForResourcesStatusFailOther = 2,
  ExchangeGemsForResourcesResponseProto_ExchangeGemsForResourcesStatusFailInsufficientGems = 3,
} ExchangeGemsForResourcesResponseProto_ExchangeGemsForResourcesStatus;

BOOL ExchangeGemsForResourcesResponseProto_ExchangeGemsForResourcesStatusIsValidValue(ExchangeGemsForResourcesResponseProto_ExchangeGemsForResourcesStatus value);


@interface EventInAppPurchaseRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface InAppPurchaseRequestProto : PBGeneratedMessage {
@private
  BOOL hasReceipt_:1;
  BOOL hasLocalcents_:1;
  BOOL hasLocalcurrency_:1;
  BOOL hasLocale_:1;
  BOOL hasIpaddr_:1;
  BOOL hasSender_:1;
  NSString* receipt;
  NSString* localcents;
  NSString* localcurrency;
  NSString* locale;
  NSString* ipaddr;
  MinimumUserProto* sender;
}
- (BOOL) hasSender;
- (BOOL) hasReceipt;
- (BOOL) hasLocalcents;
- (BOOL) hasLocalcurrency;
- (BOOL) hasLocale;
- (BOOL) hasIpaddr;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly, retain) NSString* receipt;
@property (readonly, retain) NSString* localcents;
@property (readonly, retain) NSString* localcurrency;
@property (readonly, retain) NSString* locale;
@property (readonly, retain) NSString* ipaddr;

+ (InAppPurchaseRequestProto*) defaultInstance;
- (InAppPurchaseRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (InAppPurchaseRequestProto_Builder*) builder;
+ (InAppPurchaseRequestProto_Builder*) builder;
+ (InAppPurchaseRequestProto_Builder*) builderWithPrototype:(InAppPurchaseRequestProto*) prototype;

+ (InAppPurchaseRequestProto*) parseFromData:(NSData*) data;
+ (InAppPurchaseRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (InAppPurchaseRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (InAppPurchaseRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (InAppPurchaseRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (InAppPurchaseRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface InAppPurchaseRequestProto_Builder : PBGeneratedMessage_Builder {
@private
  InAppPurchaseRequestProto* result;
}

- (InAppPurchaseRequestProto*) defaultInstance;

- (InAppPurchaseRequestProto_Builder*) clear;
- (InAppPurchaseRequestProto_Builder*) clone;

- (InAppPurchaseRequestProto*) build;
- (InAppPurchaseRequestProto*) buildPartial;

- (InAppPurchaseRequestProto_Builder*) mergeFrom:(InAppPurchaseRequestProto*) other;
- (InAppPurchaseRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (InAppPurchaseRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (InAppPurchaseRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (InAppPurchaseRequestProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (InAppPurchaseRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (InAppPurchaseRequestProto_Builder*) clearSender;

- (BOOL) hasReceipt;
- (NSString*) receipt;
- (InAppPurchaseRequestProto_Builder*) setReceipt:(NSString*) value;
- (InAppPurchaseRequestProto_Builder*) clearReceipt;

- (BOOL) hasLocalcents;
- (NSString*) localcents;
- (InAppPurchaseRequestProto_Builder*) setLocalcents:(NSString*) value;
- (InAppPurchaseRequestProto_Builder*) clearLocalcents;

- (BOOL) hasLocalcurrency;
- (NSString*) localcurrency;
- (InAppPurchaseRequestProto_Builder*) setLocalcurrency:(NSString*) value;
- (InAppPurchaseRequestProto_Builder*) clearLocalcurrency;

- (BOOL) hasLocale;
- (NSString*) locale;
- (InAppPurchaseRequestProto_Builder*) setLocale:(NSString*) value;
- (InAppPurchaseRequestProto_Builder*) clearLocale;

- (BOOL) hasIpaddr;
- (NSString*) ipaddr;
- (InAppPurchaseRequestProto_Builder*) setIpaddr:(NSString*) value;
- (InAppPurchaseRequestProto_Builder*) clearIpaddr;
@end

@interface InAppPurchaseResponseProto : PBGeneratedMessage {
@private
  BOOL hasPackagePrice_:1;
  BOOL hasDiamondsGained_:1;
  BOOL hasCoinsGained_:1;
  BOOL hasPackageName_:1;
  BOOL hasReceipt_:1;
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  Float64 packagePrice;
  int32_t diamondsGained;
  int32_t coinsGained;
  NSString* packageName;
  NSString* receipt;
  MinimumUserProto* sender;
  InAppPurchaseResponseProto_InAppPurchaseStatus status;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
- (BOOL) hasDiamondsGained;
- (BOOL) hasCoinsGained;
- (BOOL) hasPackageName;
- (BOOL) hasPackagePrice;
- (BOOL) hasReceipt;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) InAppPurchaseResponseProto_InAppPurchaseStatus status;
@property (readonly) int32_t diamondsGained;
@property (readonly) int32_t coinsGained;
@property (readonly, retain) NSString* packageName;
@property (readonly) Float64 packagePrice;
@property (readonly, retain) NSString* receipt;

+ (InAppPurchaseResponseProto*) defaultInstance;
- (InAppPurchaseResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (InAppPurchaseResponseProto_Builder*) builder;
+ (InAppPurchaseResponseProto_Builder*) builder;
+ (InAppPurchaseResponseProto_Builder*) builderWithPrototype:(InAppPurchaseResponseProto*) prototype;

+ (InAppPurchaseResponseProto*) parseFromData:(NSData*) data;
+ (InAppPurchaseResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (InAppPurchaseResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (InAppPurchaseResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (InAppPurchaseResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (InAppPurchaseResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface InAppPurchaseResponseProto_Builder : PBGeneratedMessage_Builder {
@private
  InAppPurchaseResponseProto* result;
}

- (InAppPurchaseResponseProto*) defaultInstance;

- (InAppPurchaseResponseProto_Builder*) clear;
- (InAppPurchaseResponseProto_Builder*) clone;

- (InAppPurchaseResponseProto*) build;
- (InAppPurchaseResponseProto*) buildPartial;

- (InAppPurchaseResponseProto_Builder*) mergeFrom:(InAppPurchaseResponseProto*) other;
- (InAppPurchaseResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (InAppPurchaseResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (InAppPurchaseResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (InAppPurchaseResponseProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (InAppPurchaseResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (InAppPurchaseResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (InAppPurchaseResponseProto_InAppPurchaseStatus) status;
- (InAppPurchaseResponseProto_Builder*) setStatus:(InAppPurchaseResponseProto_InAppPurchaseStatus) value;
- (InAppPurchaseResponseProto_Builder*) clearStatus;

- (BOOL) hasDiamondsGained;
- (int32_t) diamondsGained;
- (InAppPurchaseResponseProto_Builder*) setDiamondsGained:(int32_t) value;
- (InAppPurchaseResponseProto_Builder*) clearDiamondsGained;

- (BOOL) hasCoinsGained;
- (int32_t) coinsGained;
- (InAppPurchaseResponseProto_Builder*) setCoinsGained:(int32_t) value;
- (InAppPurchaseResponseProto_Builder*) clearCoinsGained;

- (BOOL) hasPackageName;
- (NSString*) packageName;
- (InAppPurchaseResponseProto_Builder*) setPackageName:(NSString*) value;
- (InAppPurchaseResponseProto_Builder*) clearPackageName;

- (BOOL) hasPackagePrice;
- (Float64) packagePrice;
- (InAppPurchaseResponseProto_Builder*) setPackagePrice:(Float64) value;
- (InAppPurchaseResponseProto_Builder*) clearPackagePrice;

- (BOOL) hasReceipt;
- (NSString*) receipt;
- (InAppPurchaseResponseProto_Builder*) setReceipt:(NSString*) value;
- (InAppPurchaseResponseProto_Builder*) clearReceipt;
@end

@interface EarnFreeDiamondsRequestProto : PBGeneratedMessage {
@private
  BOOL hasClientTime_:1;
  BOOL hasSender_:1;
  BOOL hasFreeDiamondsType_:1;
  int64_t clientTime;
  MinimumUserProto* sender;
  EarnFreeDiamondsType freeDiamondsType;
}
- (BOOL) hasSender;
- (BOOL) hasFreeDiamondsType;
- (BOOL) hasClientTime;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) EarnFreeDiamondsType freeDiamondsType;
@property (readonly) int64_t clientTime;

+ (EarnFreeDiamondsRequestProto*) defaultInstance;
- (EarnFreeDiamondsRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (EarnFreeDiamondsRequestProto_Builder*) builder;
+ (EarnFreeDiamondsRequestProto_Builder*) builder;
+ (EarnFreeDiamondsRequestProto_Builder*) builderWithPrototype:(EarnFreeDiamondsRequestProto*) prototype;

+ (EarnFreeDiamondsRequestProto*) parseFromData:(NSData*) data;
+ (EarnFreeDiamondsRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (EarnFreeDiamondsRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (EarnFreeDiamondsRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (EarnFreeDiamondsRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (EarnFreeDiamondsRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface EarnFreeDiamondsRequestProto_Builder : PBGeneratedMessage_Builder {
@private
  EarnFreeDiamondsRequestProto* result;
}

- (EarnFreeDiamondsRequestProto*) defaultInstance;

- (EarnFreeDiamondsRequestProto_Builder*) clear;
- (EarnFreeDiamondsRequestProto_Builder*) clone;

- (EarnFreeDiamondsRequestProto*) build;
- (EarnFreeDiamondsRequestProto*) buildPartial;

- (EarnFreeDiamondsRequestProto_Builder*) mergeFrom:(EarnFreeDiamondsRequestProto*) other;
- (EarnFreeDiamondsRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (EarnFreeDiamondsRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (EarnFreeDiamondsRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (EarnFreeDiamondsRequestProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (EarnFreeDiamondsRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (EarnFreeDiamondsRequestProto_Builder*) clearSender;

- (BOOL) hasFreeDiamondsType;
- (EarnFreeDiamondsType) freeDiamondsType;
- (EarnFreeDiamondsRequestProto_Builder*) setFreeDiamondsType:(EarnFreeDiamondsType) value;
- (EarnFreeDiamondsRequestProto_Builder*) clearFreeDiamondsType;

- (BOOL) hasClientTime;
- (int64_t) clientTime;
- (EarnFreeDiamondsRequestProto_Builder*) setClientTime:(int64_t) value;
- (EarnFreeDiamondsRequestProto_Builder*) clearClientTime;
@end

@interface EarnFreeDiamondsResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  BOOL hasFreeDiamondsType_:1;
  MinimumUserProto* sender;
  EarnFreeDiamondsResponseProto_EarnFreeDiamondsStatus status;
  EarnFreeDiamondsType freeDiamondsType;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
- (BOOL) hasFreeDiamondsType;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) EarnFreeDiamondsResponseProto_EarnFreeDiamondsStatus status;
@property (readonly) EarnFreeDiamondsType freeDiamondsType;

+ (EarnFreeDiamondsResponseProto*) defaultInstance;
- (EarnFreeDiamondsResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (EarnFreeDiamondsResponseProto_Builder*) builder;
+ (EarnFreeDiamondsResponseProto_Builder*) builder;
+ (EarnFreeDiamondsResponseProto_Builder*) builderWithPrototype:(EarnFreeDiamondsResponseProto*) prototype;

+ (EarnFreeDiamondsResponseProto*) parseFromData:(NSData*) data;
+ (EarnFreeDiamondsResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (EarnFreeDiamondsResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (EarnFreeDiamondsResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (EarnFreeDiamondsResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (EarnFreeDiamondsResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface EarnFreeDiamondsResponseProto_Builder : PBGeneratedMessage_Builder {
@private
  EarnFreeDiamondsResponseProto* result;
}

- (EarnFreeDiamondsResponseProto*) defaultInstance;

- (EarnFreeDiamondsResponseProto_Builder*) clear;
- (EarnFreeDiamondsResponseProto_Builder*) clone;

- (EarnFreeDiamondsResponseProto*) build;
- (EarnFreeDiamondsResponseProto*) buildPartial;

- (EarnFreeDiamondsResponseProto_Builder*) mergeFrom:(EarnFreeDiamondsResponseProto*) other;
- (EarnFreeDiamondsResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (EarnFreeDiamondsResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (EarnFreeDiamondsResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (EarnFreeDiamondsResponseProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (EarnFreeDiamondsResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (EarnFreeDiamondsResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (EarnFreeDiamondsResponseProto_EarnFreeDiamondsStatus) status;
- (EarnFreeDiamondsResponseProto_Builder*) setStatus:(EarnFreeDiamondsResponseProto_EarnFreeDiamondsStatus) value;
- (EarnFreeDiamondsResponseProto_Builder*) clearStatus;

- (BOOL) hasFreeDiamondsType;
- (EarnFreeDiamondsType) freeDiamondsType;
- (EarnFreeDiamondsResponseProto_Builder*) setFreeDiamondsType:(EarnFreeDiamondsType) value;
- (EarnFreeDiamondsResponseProto_Builder*) clearFreeDiamondsType;
@end

@interface ExchangeGemsForResourcesRequestProto : PBGeneratedMessage {
@private
  BOOL hasClientTime_:1;
  BOOL hasNumGems_:1;
  BOOL hasNumResources_:1;
  BOOL hasSender_:1;
  BOOL hasResourceType_:1;
  int64_t clientTime;
  int32_t numGems;
  int32_t numResources;
  MinimumUserProtoWithMaxResources* sender;
  ResourceType resourceType;
}
- (BOOL) hasSender;
- (BOOL) hasNumGems;
- (BOOL) hasNumResources;
- (BOOL) hasResourceType;
- (BOOL) hasClientTime;
@property (readonly, retain) MinimumUserProtoWithMaxResources* sender;
@property (readonly) int32_t numGems;
@property (readonly) int32_t numResources;
@property (readonly) ResourceType resourceType;
@property (readonly) int64_t clientTime;

+ (ExchangeGemsForResourcesRequestProto*) defaultInstance;
- (ExchangeGemsForResourcesRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (ExchangeGemsForResourcesRequestProto_Builder*) builder;
+ (ExchangeGemsForResourcesRequestProto_Builder*) builder;
+ (ExchangeGemsForResourcesRequestProto_Builder*) builderWithPrototype:(ExchangeGemsForResourcesRequestProto*) prototype;

+ (ExchangeGemsForResourcesRequestProto*) parseFromData:(NSData*) data;
+ (ExchangeGemsForResourcesRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ExchangeGemsForResourcesRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (ExchangeGemsForResourcesRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ExchangeGemsForResourcesRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (ExchangeGemsForResourcesRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface ExchangeGemsForResourcesRequestProto_Builder : PBGeneratedMessage_Builder {
@private
  ExchangeGemsForResourcesRequestProto* result;
}

- (ExchangeGemsForResourcesRequestProto*) defaultInstance;

- (ExchangeGemsForResourcesRequestProto_Builder*) clear;
- (ExchangeGemsForResourcesRequestProto_Builder*) clone;

- (ExchangeGemsForResourcesRequestProto*) build;
- (ExchangeGemsForResourcesRequestProto*) buildPartial;

- (ExchangeGemsForResourcesRequestProto_Builder*) mergeFrom:(ExchangeGemsForResourcesRequestProto*) other;
- (ExchangeGemsForResourcesRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (ExchangeGemsForResourcesRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProtoWithMaxResources*) sender;
- (ExchangeGemsForResourcesRequestProto_Builder*) setSender:(MinimumUserProtoWithMaxResources*) value;
- (ExchangeGemsForResourcesRequestProto_Builder*) setSenderBuilder:(MinimumUserProtoWithMaxResources_Builder*) builderForValue;
- (ExchangeGemsForResourcesRequestProto_Builder*) mergeSender:(MinimumUserProtoWithMaxResources*) value;
- (ExchangeGemsForResourcesRequestProto_Builder*) clearSender;

- (BOOL) hasNumGems;
- (int32_t) numGems;
- (ExchangeGemsForResourcesRequestProto_Builder*) setNumGems:(int32_t) value;
- (ExchangeGemsForResourcesRequestProto_Builder*) clearNumGems;

- (BOOL) hasNumResources;
- (int32_t) numResources;
- (ExchangeGemsForResourcesRequestProto_Builder*) setNumResources:(int32_t) value;
- (ExchangeGemsForResourcesRequestProto_Builder*) clearNumResources;

- (BOOL) hasResourceType;
- (ResourceType) resourceType;
- (ExchangeGemsForResourcesRequestProto_Builder*) setResourceType:(ResourceType) value;
- (ExchangeGemsForResourcesRequestProto_Builder*) clearResourceType;

- (BOOL) hasClientTime;
- (int64_t) clientTime;
- (ExchangeGemsForResourcesRequestProto_Builder*) setClientTime:(int64_t) value;
- (ExchangeGemsForResourcesRequestProto_Builder*) clearClientTime;
@end

@interface ExchangeGemsForResourcesResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  MinimumUserProtoWithMaxResources* sender;
  ExchangeGemsForResourcesResponseProto_ExchangeGemsForResourcesStatus status;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
@property (readonly, retain) MinimumUserProtoWithMaxResources* sender;
@property (readonly) ExchangeGemsForResourcesResponseProto_ExchangeGemsForResourcesStatus status;

+ (ExchangeGemsForResourcesResponseProto*) defaultInstance;
- (ExchangeGemsForResourcesResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (ExchangeGemsForResourcesResponseProto_Builder*) builder;
+ (ExchangeGemsForResourcesResponseProto_Builder*) builder;
+ (ExchangeGemsForResourcesResponseProto_Builder*) builderWithPrototype:(ExchangeGemsForResourcesResponseProto*) prototype;

+ (ExchangeGemsForResourcesResponseProto*) parseFromData:(NSData*) data;
+ (ExchangeGemsForResourcesResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ExchangeGemsForResourcesResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (ExchangeGemsForResourcesResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ExchangeGemsForResourcesResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (ExchangeGemsForResourcesResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface ExchangeGemsForResourcesResponseProto_Builder : PBGeneratedMessage_Builder {
@private
  ExchangeGemsForResourcesResponseProto* result;
}

- (ExchangeGemsForResourcesResponseProto*) defaultInstance;

- (ExchangeGemsForResourcesResponseProto_Builder*) clear;
- (ExchangeGemsForResourcesResponseProto_Builder*) clone;

- (ExchangeGemsForResourcesResponseProto*) build;
- (ExchangeGemsForResourcesResponseProto*) buildPartial;

- (ExchangeGemsForResourcesResponseProto_Builder*) mergeFrom:(ExchangeGemsForResourcesResponseProto*) other;
- (ExchangeGemsForResourcesResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (ExchangeGemsForResourcesResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProtoWithMaxResources*) sender;
- (ExchangeGemsForResourcesResponseProto_Builder*) setSender:(MinimumUserProtoWithMaxResources*) value;
- (ExchangeGemsForResourcesResponseProto_Builder*) setSenderBuilder:(MinimumUserProtoWithMaxResources_Builder*) builderForValue;
- (ExchangeGemsForResourcesResponseProto_Builder*) mergeSender:(MinimumUserProtoWithMaxResources*) value;
- (ExchangeGemsForResourcesResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (ExchangeGemsForResourcesResponseProto_ExchangeGemsForResourcesStatus) status;
- (ExchangeGemsForResourcesResponseProto_Builder*) setStatus:(ExchangeGemsForResourcesResponseProto_ExchangeGemsForResourcesStatus) value;
- (ExchangeGemsForResourcesResponseProto_Builder*) clearStatus;
@end

