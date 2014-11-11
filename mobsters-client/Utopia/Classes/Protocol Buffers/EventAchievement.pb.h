// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "AchievementStuff.pb.h"
#import "User.pb.h"
// @@protoc_insertion_point(imports)

@class AchievementProgressRequestProto;
@class AchievementProgressRequestProto_Builder;
@class AchievementProgressResponseProto;
@class AchievementProgressResponseProto_Builder;
@class AchievementProto;
@class AchievementProto_Builder;
@class AchievementRedeemRequestProto;
@class AchievementRedeemRequestProto_Builder;
@class AchievementRedeemResponseProto;
@class AchievementRedeemResponseProto_Builder;
@class ClanHouseProto;
@class ClanHouseProto_Builder;
@class CoordinateProto;
@class CoordinateProto_Builder;
@class EvoChamberProto;
@class EvoChamberProto_Builder;
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
@class TeamCenterProto;
@class TeamCenterProto_Builder;
@class TownHallProto;
@class TownHallProto_Builder;
@class TutorialStructProto;
@class TutorialStructProto_Builder;
@class UserAchievementProto;
@class UserAchievementProto_Builder;
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

typedef enum {
  AchievementProgressResponseProto_AchievementProgressStatusSuccess = 1,
  AchievementProgressResponseProto_AchievementProgressStatusFailOther = 2,
} AchievementProgressResponseProto_AchievementProgressStatus;

BOOL AchievementProgressResponseProto_AchievementProgressStatusIsValidValue(AchievementProgressResponseProto_AchievementProgressStatus value);

typedef enum {
  AchievementRedeemResponseProto_AchievementRedeemStatusSuccess = 1,
  AchievementRedeemResponseProto_AchievementRedeemStatusFailNotComplete = 2,
  AchievementRedeemResponseProto_AchievementRedeemStatusFailOther = 3,
  AchievementRedeemResponseProto_AchievementRedeemStatusFailAlreadyRedeemed = 4,
} AchievementRedeemResponseProto_AchievementRedeemStatus;

BOOL AchievementRedeemResponseProto_AchievementRedeemStatusIsValidValue(AchievementRedeemResponseProto_AchievementRedeemStatus value);


@interface EventAchievementRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface AchievementProgressRequestProto : PBGeneratedMessage {
@private
  BOOL hasClientTime_:1;
  BOOL hasSender_:1;
  int64_t clientTime;
  MinimumUserProto* sender;
  NSMutableArray * mutableUapListList;
}
- (BOOL) hasSender;
- (BOOL) hasClientTime;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly, strong) NSArray * uapListList;
@property (readonly) int64_t clientTime;
- (UserAchievementProto*)uapListAtIndex:(NSUInteger)index;

+ (AchievementProgressRequestProto*) defaultInstance;
- (AchievementProgressRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (AchievementProgressRequestProto_Builder*) builder;
+ (AchievementProgressRequestProto_Builder*) builder;
+ (AchievementProgressRequestProto_Builder*) builderWithPrototype:(AchievementProgressRequestProto*) prototype;
- (AchievementProgressRequestProto_Builder*) toBuilder;

+ (AchievementProgressRequestProto*) parseFromData:(NSData*) data;
+ (AchievementProgressRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (AchievementProgressRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (AchievementProgressRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (AchievementProgressRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (AchievementProgressRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface AchievementProgressRequestProto_Builder : PBGeneratedMessageBuilder {
@private
  AchievementProgressRequestProto* result;
}

- (AchievementProgressRequestProto*) defaultInstance;

- (AchievementProgressRequestProto_Builder*) clear;
- (AchievementProgressRequestProto_Builder*) clone;

- (AchievementProgressRequestProto*) build;
- (AchievementProgressRequestProto*) buildPartial;

- (AchievementProgressRequestProto_Builder*) mergeFrom:(AchievementProgressRequestProto*) other;
- (AchievementProgressRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (AchievementProgressRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (AchievementProgressRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (AchievementProgressRequestProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (AchievementProgressRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (AchievementProgressRequestProto_Builder*) clearSender;

- (NSMutableArray *)uapListList;
- (UserAchievementProto*)uapListAtIndex:(NSUInteger)index;
- (AchievementProgressRequestProto_Builder *)addUapList:(UserAchievementProto*)value;
- (AchievementProgressRequestProto_Builder *)addAllUapList:(NSArray *)array;
- (AchievementProgressRequestProto_Builder *)clearUapList;

- (BOOL) hasClientTime;
- (int64_t) clientTime;
- (AchievementProgressRequestProto_Builder*) setClientTime:(int64_t) value;
- (AchievementProgressRequestProto_Builder*) clearClientTime;
@end

@interface AchievementProgressResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  AchievementProgressResponseProto_AchievementProgressStatus status;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) AchievementProgressResponseProto_AchievementProgressStatus status;

+ (AchievementProgressResponseProto*) defaultInstance;
- (AchievementProgressResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (AchievementProgressResponseProto_Builder*) builder;
+ (AchievementProgressResponseProto_Builder*) builder;
+ (AchievementProgressResponseProto_Builder*) builderWithPrototype:(AchievementProgressResponseProto*) prototype;
- (AchievementProgressResponseProto_Builder*) toBuilder;

+ (AchievementProgressResponseProto*) parseFromData:(NSData*) data;
+ (AchievementProgressResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (AchievementProgressResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (AchievementProgressResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (AchievementProgressResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (AchievementProgressResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface AchievementProgressResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  AchievementProgressResponseProto* result;
}

- (AchievementProgressResponseProto*) defaultInstance;

- (AchievementProgressResponseProto_Builder*) clear;
- (AchievementProgressResponseProto_Builder*) clone;

- (AchievementProgressResponseProto*) build;
- (AchievementProgressResponseProto*) buildPartial;

- (AchievementProgressResponseProto_Builder*) mergeFrom:(AchievementProgressResponseProto*) other;
- (AchievementProgressResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (AchievementProgressResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (AchievementProgressResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (AchievementProgressResponseProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (AchievementProgressResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (AchievementProgressResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (AchievementProgressResponseProto_AchievementProgressStatus) status;
- (AchievementProgressResponseProto_Builder*) setStatus:(AchievementProgressResponseProto_AchievementProgressStatus) value;
- (AchievementProgressResponseProto_Builder*) clearStatus;
@end

@interface AchievementRedeemRequestProto : PBGeneratedMessage {
@private
  BOOL hasClientTime_:1;
  BOOL hasAchievementId_:1;
  BOOL hasSender_:1;
  int64_t clientTime;
  int32_t achievementId;
  MinimumUserProto* sender;
}
- (BOOL) hasSender;
- (BOOL) hasAchievementId;
- (BOOL) hasClientTime;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) int32_t achievementId;
@property (readonly) int64_t clientTime;

+ (AchievementRedeemRequestProto*) defaultInstance;
- (AchievementRedeemRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (AchievementRedeemRequestProto_Builder*) builder;
+ (AchievementRedeemRequestProto_Builder*) builder;
+ (AchievementRedeemRequestProto_Builder*) builderWithPrototype:(AchievementRedeemRequestProto*) prototype;
- (AchievementRedeemRequestProto_Builder*) toBuilder;

+ (AchievementRedeemRequestProto*) parseFromData:(NSData*) data;
+ (AchievementRedeemRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (AchievementRedeemRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (AchievementRedeemRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (AchievementRedeemRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (AchievementRedeemRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface AchievementRedeemRequestProto_Builder : PBGeneratedMessageBuilder {
@private
  AchievementRedeemRequestProto* result;
}

- (AchievementRedeemRequestProto*) defaultInstance;

- (AchievementRedeemRequestProto_Builder*) clear;
- (AchievementRedeemRequestProto_Builder*) clone;

- (AchievementRedeemRequestProto*) build;
- (AchievementRedeemRequestProto*) buildPartial;

- (AchievementRedeemRequestProto_Builder*) mergeFrom:(AchievementRedeemRequestProto*) other;
- (AchievementRedeemRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (AchievementRedeemRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (AchievementRedeemRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (AchievementRedeemRequestProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (AchievementRedeemRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (AchievementRedeemRequestProto_Builder*) clearSender;

- (BOOL) hasAchievementId;
- (int32_t) achievementId;
- (AchievementRedeemRequestProto_Builder*) setAchievementId:(int32_t) value;
- (AchievementRedeemRequestProto_Builder*) clearAchievementId;

- (BOOL) hasClientTime;
- (int64_t) clientTime;
- (AchievementRedeemRequestProto_Builder*) setClientTime:(int64_t) value;
- (AchievementRedeemRequestProto_Builder*) clearClientTime;
@end

@interface AchievementRedeemResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  AchievementRedeemResponseProto_AchievementRedeemStatus status;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) AchievementRedeemResponseProto_AchievementRedeemStatus status;

+ (AchievementRedeemResponseProto*) defaultInstance;
- (AchievementRedeemResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (AchievementRedeemResponseProto_Builder*) builder;
+ (AchievementRedeemResponseProto_Builder*) builder;
+ (AchievementRedeemResponseProto_Builder*) builderWithPrototype:(AchievementRedeemResponseProto*) prototype;
- (AchievementRedeemResponseProto_Builder*) toBuilder;

+ (AchievementRedeemResponseProto*) parseFromData:(NSData*) data;
+ (AchievementRedeemResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (AchievementRedeemResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (AchievementRedeemResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (AchievementRedeemResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (AchievementRedeemResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface AchievementRedeemResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  AchievementRedeemResponseProto* result;
}

- (AchievementRedeemResponseProto*) defaultInstance;

- (AchievementRedeemResponseProto_Builder*) clear;
- (AchievementRedeemResponseProto_Builder*) clone;

- (AchievementRedeemResponseProto*) build;
- (AchievementRedeemResponseProto*) buildPartial;

- (AchievementRedeemResponseProto_Builder*) mergeFrom:(AchievementRedeemResponseProto*) other;
- (AchievementRedeemResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (AchievementRedeemResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (AchievementRedeemResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (AchievementRedeemResponseProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (AchievementRedeemResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (AchievementRedeemResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (AchievementRedeemResponseProto_AchievementRedeemStatus) status;
- (AchievementRedeemResponseProto_Builder*) setStatus:(AchievementRedeemResponseProto_AchievementRedeemStatus) value;
- (AchievementRedeemResponseProto_Builder*) clearStatus;
@end


// @@protoc_insertion_point(global_scope)
