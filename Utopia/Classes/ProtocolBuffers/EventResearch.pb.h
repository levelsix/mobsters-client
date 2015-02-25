// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "Structure.pb.h"
#import "User.pb.h"
// @@protoc_insertion_point(imports)

@class ClanHouseProto;
@class ClanHouseProto_Builder;
@class CoordinateProto;
@class CoordinateProto_Builder;
@class EvoChamberProto;
@class EvoChamberProto_Builder;
@class FinishPerformingResearchRequestProto;
@class FinishPerformingResearchRequestProto_Builder;
@class FinishPerformingResearchResponseProto;
@class FinishPerformingResearchResponseProto_Builder;
@class FullUserProto;
@class FullUserProto_Builder;
@class FullUserStructureProto;
@class FullUserStructureProto_Builder;
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
@class ObstacleProto;
@class ObstacleProto_Builder;
@class PerformResearchRequestProto;
@class PerformResearchRequestProto_Builder;
@class PerformResearchResponseProto;
@class PerformResearchResponseProto_Builder;
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
@class UserFacebookInviteForSlotProto;
@class UserFacebookInviteForSlotProto_Builder;
@class UserObstacleProto;
@class UserObstacleProto_Builder;
@class UserPvpLeagueProto;
@class UserPvpLeagueProto_Builder;
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

typedef NS_ENUM(SInt32, PerformResearchResponseProto_PerformResearchStatus) {
  PerformResearchResponseProto_PerformResearchStatusSuccess = 1,
  PerformResearchResponseProto_PerformResearchStatusFailOther = 2,
  PerformResearchResponseProto_PerformResearchStatusFailInsufficientCash = 3,
  PerformResearchResponseProto_PerformResearchStatusFailInsufficientGems = 4,
  PerformResearchResponseProto_PerformResearchStatusFailInsufficientOil = 5,
};

BOOL PerformResearchResponseProto_PerformResearchStatusIsValidValue(PerformResearchResponseProto_PerformResearchStatus value);

typedef NS_ENUM(SInt32, FinishPerformingResearchResponseProto_FinishPerformingResearchStatus) {
  FinishPerformingResearchResponseProto_FinishPerformingResearchStatusSuccess = 1,
  FinishPerformingResearchResponseProto_FinishPerformingResearchStatusFailOther = 2,
  FinishPerformingResearchResponseProto_FinishPerformingResearchStatusFailNotEnoughGems = 3,
};

BOOL FinishPerformingResearchResponseProto_FinishPerformingResearchStatusIsValidValue(FinishPerformingResearchResponseProto_FinishPerformingResearchStatus value);


@interface EventResearchRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface PerformResearchRequestProto : PBGeneratedMessage {
@private
  BOOL hasClientTime_:1;
  BOOL hasResearchId_:1;
  BOOL hasGemsSpent_:1;
  BOOL hasUserResearchUuid_:1;
  BOOL hasSender_:1;
  BOOL hasResourceType_:1;
  BOOL hasResourceChange_:1;
  int64_t clientTime;
  int32_t researchId;
  int32_t gemsSpent;
  NSString* userResearchUuid;
  MinimumUserProto* sender;
  ResourceType resourceType;
  int32_t resourceChange;
}
- (BOOL) hasSender;
- (BOOL) hasResearchId;
- (BOOL) hasUserResearchUuid;
- (BOOL) hasClientTime;
- (BOOL) hasGemsSpent;
- (BOOL) hasResourceChange;
- (BOOL) hasResourceType;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) int32_t researchId;
@property (readonly, strong) NSString* userResearchUuid;
@property (readonly) int64_t clientTime;
@property (readonly) int32_t gemsSpent;
@property (readonly) int32_t resourceChange;
@property (readonly) ResourceType resourceType;

+ (PerformResearchRequestProto*) defaultInstance;
- (PerformResearchRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PerformResearchRequestProto_Builder*) builder;
+ (PerformResearchRequestProto_Builder*) builder;
+ (PerformResearchRequestProto_Builder*) builderWithPrototype:(PerformResearchRequestProto*) prototype;
- (PerformResearchRequestProto_Builder*) toBuilder;

+ (PerformResearchRequestProto*) parseFromData:(NSData*) data;
+ (PerformResearchRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PerformResearchRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (PerformResearchRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PerformResearchRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PerformResearchRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PerformResearchRequestProto_Builder : PBGeneratedMessageBuilder {
@private
  PerformResearchRequestProto* result;
}

- (PerformResearchRequestProto*) defaultInstance;

- (PerformResearchRequestProto_Builder*) clear;
- (PerformResearchRequestProto_Builder*) clone;

- (PerformResearchRequestProto*) build;
- (PerformResearchRequestProto*) buildPartial;

- (PerformResearchRequestProto_Builder*) mergeFrom:(PerformResearchRequestProto*) other;
- (PerformResearchRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PerformResearchRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (PerformResearchRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (PerformResearchRequestProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (PerformResearchRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (PerformResearchRequestProto_Builder*) clearSender;

- (BOOL) hasResearchId;
- (int32_t) researchId;
- (PerformResearchRequestProto_Builder*) setResearchId:(int32_t) value;
- (PerformResearchRequestProto_Builder*) clearResearchId;

- (BOOL) hasUserResearchUuid;
- (NSString*) userResearchUuid;
- (PerformResearchRequestProto_Builder*) setUserResearchUuid:(NSString*) value;
- (PerformResearchRequestProto_Builder*) clearUserResearchUuid;

- (BOOL) hasClientTime;
- (int64_t) clientTime;
- (PerformResearchRequestProto_Builder*) setClientTime:(int64_t) value;
- (PerformResearchRequestProto_Builder*) clearClientTime;

- (BOOL) hasGemsSpent;
- (int32_t) gemsSpent;
- (PerformResearchRequestProto_Builder*) setGemsSpent:(int32_t) value;
- (PerformResearchRequestProto_Builder*) clearGemsSpent;

- (BOOL) hasResourceChange;
- (int32_t) resourceChange;
- (PerformResearchRequestProto_Builder*) setResourceChange:(int32_t) value;
- (PerformResearchRequestProto_Builder*) clearResourceChange;

- (BOOL) hasResourceType;
- (ResourceType) resourceType;
- (PerformResearchRequestProto_Builder*) setResourceType:(ResourceType) value;
- (PerformResearchRequestProto_Builder*) clearResourceTypeList;
@end

@interface PerformResearchResponseProto : PBGeneratedMessage {
@private
  BOOL hasUserResearchUuid_:1;
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  NSString* userResearchUuid;
  MinimumUserProto* sender;
  PerformResearchResponseProto_PerformResearchStatus status;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
- (BOOL) hasUserResearchUuid;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) PerformResearchResponseProto_PerformResearchStatus status;
@property (readonly, strong) NSString* userResearchUuid;

+ (PerformResearchResponseProto*) defaultInstance;
- (PerformResearchResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PerformResearchResponseProto_Builder*) builder;
+ (PerformResearchResponseProto_Builder*) builder;
+ (PerformResearchResponseProto_Builder*) builderWithPrototype:(PerformResearchResponseProto*) prototype;
- (PerformResearchResponseProto_Builder*) toBuilder;

+ (PerformResearchResponseProto*) parseFromData:(NSData*) data;
+ (PerformResearchResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PerformResearchResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (PerformResearchResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PerformResearchResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PerformResearchResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PerformResearchResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  PerformResearchResponseProto* result;
}

- (PerformResearchResponseProto*) defaultInstance;

- (PerformResearchResponseProto_Builder*) clear;
- (PerformResearchResponseProto_Builder*) clone;

- (PerformResearchResponseProto*) build;
- (PerformResearchResponseProto*) buildPartial;

- (PerformResearchResponseProto_Builder*) mergeFrom:(PerformResearchResponseProto*) other;
- (PerformResearchResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PerformResearchResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (PerformResearchResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (PerformResearchResponseProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (PerformResearchResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (PerformResearchResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (PerformResearchResponseProto_PerformResearchStatus) status;
- (PerformResearchResponseProto_Builder*) setStatus:(PerformResearchResponseProto_PerformResearchStatus) value;
- (PerformResearchResponseProto_Builder*) clearStatusList;

- (BOOL) hasUserResearchUuid;
- (NSString*) userResearchUuid;
- (PerformResearchResponseProto_Builder*) setUserResearchUuid:(NSString*) value;
- (PerformResearchResponseProto_Builder*) clearUserResearchUuid;
@end

@interface FinishPerformingResearchRequestProto : PBGeneratedMessage {
@private
  BOOL hasGemsSpent_:1;
  BOOL hasUserResearchUuid_:1;
  BOOL hasSender_:1;
  int32_t gemsSpent;
  NSString* userResearchUuid;
  MinimumUserProto* sender;
}
- (BOOL) hasSender;
- (BOOL) hasUserResearchUuid;
- (BOOL) hasGemsSpent;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly, strong) NSString* userResearchUuid;
@property (readonly) int32_t gemsSpent;

+ (FinishPerformingResearchRequestProto*) defaultInstance;
- (FinishPerformingResearchRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (FinishPerformingResearchRequestProto_Builder*) builder;
+ (FinishPerformingResearchRequestProto_Builder*) builder;
+ (FinishPerformingResearchRequestProto_Builder*) builderWithPrototype:(FinishPerformingResearchRequestProto*) prototype;
- (FinishPerformingResearchRequestProto_Builder*) toBuilder;

+ (FinishPerformingResearchRequestProto*) parseFromData:(NSData*) data;
+ (FinishPerformingResearchRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FinishPerformingResearchRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (FinishPerformingResearchRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FinishPerformingResearchRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (FinishPerformingResearchRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface FinishPerformingResearchRequestProto_Builder : PBGeneratedMessageBuilder {
@private
  FinishPerformingResearchRequestProto* result;
}

- (FinishPerformingResearchRequestProto*) defaultInstance;

- (FinishPerformingResearchRequestProto_Builder*) clear;
- (FinishPerformingResearchRequestProto_Builder*) clone;

- (FinishPerformingResearchRequestProto*) build;
- (FinishPerformingResearchRequestProto*) buildPartial;

- (FinishPerformingResearchRequestProto_Builder*) mergeFrom:(FinishPerformingResearchRequestProto*) other;
- (FinishPerformingResearchRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (FinishPerformingResearchRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (FinishPerformingResearchRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (FinishPerformingResearchRequestProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (FinishPerformingResearchRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (FinishPerformingResearchRequestProto_Builder*) clearSender;

- (BOOL) hasUserResearchUuid;
- (NSString*) userResearchUuid;
- (FinishPerformingResearchRequestProto_Builder*) setUserResearchUuid:(NSString*) value;
- (FinishPerformingResearchRequestProto_Builder*) clearUserResearchUuid;

- (BOOL) hasGemsSpent;
- (int32_t) gemsSpent;
- (FinishPerformingResearchRequestProto_Builder*) setGemsSpent:(int32_t) value;
- (FinishPerformingResearchRequestProto_Builder*) clearGemsSpent;
@end

@interface FinishPerformingResearchResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  FinishPerformingResearchResponseProto_FinishPerformingResearchStatus status;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) FinishPerformingResearchResponseProto_FinishPerformingResearchStatus status;

+ (FinishPerformingResearchResponseProto*) defaultInstance;
- (FinishPerformingResearchResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (FinishPerformingResearchResponseProto_Builder*) builder;
+ (FinishPerformingResearchResponseProto_Builder*) builder;
+ (FinishPerformingResearchResponseProto_Builder*) builderWithPrototype:(FinishPerformingResearchResponseProto*) prototype;
- (FinishPerformingResearchResponseProto_Builder*) toBuilder;

+ (FinishPerformingResearchResponseProto*) parseFromData:(NSData*) data;
+ (FinishPerformingResearchResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FinishPerformingResearchResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (FinishPerformingResearchResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FinishPerformingResearchResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (FinishPerformingResearchResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface FinishPerformingResearchResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  FinishPerformingResearchResponseProto* result;
}

- (FinishPerformingResearchResponseProto*) defaultInstance;

- (FinishPerformingResearchResponseProto_Builder*) clear;
- (FinishPerformingResearchResponseProto_Builder*) clone;

- (FinishPerformingResearchResponseProto*) build;
- (FinishPerformingResearchResponseProto*) buildPartial;

- (FinishPerformingResearchResponseProto_Builder*) mergeFrom:(FinishPerformingResearchResponseProto*) other;
- (FinishPerformingResearchResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (FinishPerformingResearchResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (FinishPerformingResearchResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (FinishPerformingResearchResponseProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (FinishPerformingResearchResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (FinishPerformingResearchResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (FinishPerformingResearchResponseProto_FinishPerformingResearchStatus) status;
- (FinishPerformingResearchResponseProto_Builder*) setStatus:(FinishPerformingResearchResponseProto_FinishPerformingResearchStatus) value;
- (FinishPerformingResearchResponseProto_Builder*) clearStatusList;
@end


// @@protoc_insertion_point(global_scope)