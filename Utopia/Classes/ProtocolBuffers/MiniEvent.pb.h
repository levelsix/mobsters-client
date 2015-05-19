// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

// @@protoc_insertion_point(imports)

@class MiniEventForPlayerLevelProto;
@class MiniEventForPlayerLevelProto_Builder;
@class MiniEventGoalProto;
@class MiniEventGoalProto_Builder;
@class MiniEventLeaderboardRewardProto;
@class MiniEventLeaderboardRewardProto_Builder;
@class MiniEventProto;
@class MiniEventProto_Builder;
@class MiniEventTierRewardProto;
@class MiniEventTierRewardProto_Builder;
@class UserMiniEventGoalProto;
@class UserMiniEventGoalProto_Builder;
@class UserMiniEventProto;
@class UserMiniEventProto_Builder;
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

typedef NS_ENUM(SInt32, MiniEventGoalProto_MiniEventGoalType) {
  MiniEventGoalProto_MiniEventGoalTypeNoGoal = 1,
  MiniEventGoalProto_MiniEventGoalTypeGainBuildingStrength = 2,
  MiniEventGoalProto_MiniEventGoalTypeGainResearchStrength = 3,
  MiniEventGoalProto_MiniEventGoalTypeSpinBasicGrab = 4,
  MiniEventGoalProto_MiniEventGoalTypeSpinUltimateGrab = 5,
  MiniEventGoalProto_MiniEventGoalTypeSpinMulti = 23,
  MiniEventGoalProto_MiniEventGoalTypeEnhanceCommon = 6,
  MiniEventGoalProto_MiniEventGoalTypeEnhanceRare = 7,
  MiniEventGoalProto_MiniEventGoalTypeEnhanceSuper = 8,
  MiniEventGoalProto_MiniEventGoalTypeEnhanceUltra = 9,
  MiniEventGoalProto_MiniEventGoalTypeEnhanceEpic = 10,
  MiniEventGoalProto_MiniEventGoalTypeClanHelp = 11,
  MiniEventGoalProto_MiniEventGoalTypeClanDonate = 12,
  MiniEventGoalProto_MiniEventGoalTypeBattleAvengeRequest = 13,
  MiniEventGoalProto_MiniEventGoalTypeBattleAvengeWin = 14,
  MiniEventGoalProto_MiniEventGoalTypeBattleRevengeWin = 15,
  MiniEventGoalProto_MiniEventGoalTypeStealCash = 16,
  MiniEventGoalProto_MiniEventGoalTypeStealOil = 17,
  MiniEventGoalProto_MiniEventGoalTypePvpCatchCommon = 18,
  MiniEventGoalProto_MiniEventGoalTypePvpCatchRare = 19,
  MiniEventGoalProto_MiniEventGoalTypePvpCatchSuper = 20,
  MiniEventGoalProto_MiniEventGoalTypePvpCatchUltra = 21,
  MiniEventGoalProto_MiniEventGoalTypePvpCatchEpic = 22,
};

BOOL MiniEventGoalProto_MiniEventGoalTypeIsValidValue(MiniEventGoalProto_MiniEventGoalType value);


@interface MiniEventRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface MiniEventProto : PBGeneratedMessage {
@private
  BOOL hasMiniEventStartTime_:1;
  BOOL hasMiniEventEndTime_:1;
  BOOL hasMiniEventId_:1;
  BOOL hasName_:1;
  BOOL hasDesc_:1;
  BOOL hasImg_:1;
  BOOL hasIcon_:1;
  BOOL hasLvlEntered_:1;
  int64_t miniEventStartTime;
  int64_t miniEventEndTime;
  int32_t miniEventId;
  NSString* name;
  NSString* desc;
  NSString* img;
  NSString* icon;
  MiniEventForPlayerLevelProto* lvlEntered;
  NSMutableArray * mutableGoalsList;
  NSMutableArray * mutableLeaderboardRewardsList;
}
- (BOOL) hasMiniEventId;
- (BOOL) hasMiniEventStartTime;
- (BOOL) hasMiniEventEndTime;
- (BOOL) hasLvlEntered;
- (BOOL) hasName;
- (BOOL) hasDesc;
- (BOOL) hasImg;
- (BOOL) hasIcon;
@property (readonly) int32_t miniEventId;
@property (readonly) int64_t miniEventStartTime;
@property (readonly) int64_t miniEventEndTime;
@property (readonly, strong) MiniEventForPlayerLevelProto* lvlEntered;
@property (readonly, strong) NSArray * goalsList;
@property (readonly, strong) NSArray * leaderboardRewardsList;
@property (readonly, strong) NSString* name;
@property (readonly, strong) NSString* desc;
@property (readonly, strong) NSString* img;
@property (readonly, strong) NSString* icon;
- (MiniEventGoalProto*)goalsAtIndex:(NSUInteger)index;
- (MiniEventLeaderboardRewardProto*)leaderboardRewardsAtIndex:(NSUInteger)index;

+ (MiniEventProto*) defaultInstance;
- (MiniEventProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (MiniEventProto_Builder*) builder;
+ (MiniEventProto_Builder*) builder;
+ (MiniEventProto_Builder*) builderWithPrototype:(MiniEventProto*) prototype;
- (MiniEventProto_Builder*) toBuilder;

+ (MiniEventProto*) parseFromData:(NSData*) data;
+ (MiniEventProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (MiniEventProto*) parseFromInputStream:(NSInputStream*) input;
+ (MiniEventProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (MiniEventProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (MiniEventProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface MiniEventProto_Builder : PBGeneratedMessageBuilder {
@private
  MiniEventProto* result;
}

- (MiniEventProto*) defaultInstance;

- (MiniEventProto_Builder*) clear;
- (MiniEventProto_Builder*) clone;

- (MiniEventProto*) build;
- (MiniEventProto*) buildPartial;

- (MiniEventProto_Builder*) mergeFrom:(MiniEventProto*) other;
- (MiniEventProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (MiniEventProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasMiniEventId;
- (int32_t) miniEventId;
- (MiniEventProto_Builder*) setMiniEventId:(int32_t) value;
- (MiniEventProto_Builder*) clearMiniEventId;

- (BOOL) hasMiniEventStartTime;
- (int64_t) miniEventStartTime;
- (MiniEventProto_Builder*) setMiniEventStartTime:(int64_t) value;
- (MiniEventProto_Builder*) clearMiniEventStartTime;

- (BOOL) hasMiniEventEndTime;
- (int64_t) miniEventEndTime;
- (MiniEventProto_Builder*) setMiniEventEndTime:(int64_t) value;
- (MiniEventProto_Builder*) clearMiniEventEndTime;

- (BOOL) hasLvlEntered;
- (MiniEventForPlayerLevelProto*) lvlEntered;
- (MiniEventProto_Builder*) setLvlEntered:(MiniEventForPlayerLevelProto*) value;
- (MiniEventProto_Builder*) setLvlEntered_Builder:(MiniEventForPlayerLevelProto_Builder*) builderForValue;
- (MiniEventProto_Builder*) mergeLvlEntered:(MiniEventForPlayerLevelProto*) value;
- (MiniEventProto_Builder*) clearLvlEntered;

- (NSMutableArray *)goalsList;
- (MiniEventGoalProto*)goalsAtIndex:(NSUInteger)index;
- (MiniEventProto_Builder *)addGoals:(MiniEventGoalProto*)value;
- (MiniEventProto_Builder *)addAllGoals:(NSArray *)array;
- (MiniEventProto_Builder *)clearGoals;

- (NSMutableArray *)leaderboardRewardsList;
- (MiniEventLeaderboardRewardProto*)leaderboardRewardsAtIndex:(NSUInteger)index;
- (MiniEventProto_Builder *)addLeaderboardRewards:(MiniEventLeaderboardRewardProto*)value;
- (MiniEventProto_Builder *)addAllLeaderboardRewards:(NSArray *)array;
- (MiniEventProto_Builder *)clearLeaderboardRewards;

- (BOOL) hasName;
- (NSString*) name;
- (MiniEventProto_Builder*) setName:(NSString*) value;
- (MiniEventProto_Builder*) clearName;

- (BOOL) hasDesc;
- (NSString*) desc;
- (MiniEventProto_Builder*) setDesc:(NSString*) value;
- (MiniEventProto_Builder*) clearDesc;

- (BOOL) hasImg;
- (NSString*) img;
- (MiniEventProto_Builder*) setImg:(NSString*) value;
- (MiniEventProto_Builder*) clearImg;

- (BOOL) hasIcon;
- (NSString*) icon;
- (MiniEventProto_Builder*) setIcon:(NSString*) value;
- (MiniEventProto_Builder*) clearIcon;
@end

@interface MiniEventGoalProto : PBGeneratedMessage {
@private
  BOOL hasMiniEventGoalId_:1;
  BOOL hasMiniEventId_:1;
  BOOL hasGoalAmt_:1;
  BOOL hasPointsGained_:1;
  BOOL hasGoalDesc_:1;
  BOOL hasActionDescription_:1;
  BOOL hasGoalType_:1;
  int32_t miniEventGoalId;
  int32_t miniEventId;
  int32_t goalAmt;
  int32_t pointsGained;
  NSString* goalDesc;
  NSString* actionDescription;
  MiniEventGoalProto_MiniEventGoalType goalType;
}
- (BOOL) hasMiniEventGoalId;
- (BOOL) hasMiniEventId;
- (BOOL) hasGoalType;
- (BOOL) hasGoalAmt;
- (BOOL) hasGoalDesc;
- (BOOL) hasPointsGained;
- (BOOL) hasActionDescription;
@property (readonly) int32_t miniEventGoalId;
@property (readonly) int32_t miniEventId;
@property (readonly) MiniEventGoalProto_MiniEventGoalType goalType;
@property (readonly) int32_t goalAmt;
@property (readonly, strong) NSString* goalDesc;
@property (readonly) int32_t pointsGained;
@property (readonly, strong) NSString* actionDescription;

+ (MiniEventGoalProto*) defaultInstance;
- (MiniEventGoalProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (MiniEventGoalProto_Builder*) builder;
+ (MiniEventGoalProto_Builder*) builder;
+ (MiniEventGoalProto_Builder*) builderWithPrototype:(MiniEventGoalProto*) prototype;
- (MiniEventGoalProto_Builder*) toBuilder;

+ (MiniEventGoalProto*) parseFromData:(NSData*) data;
+ (MiniEventGoalProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (MiniEventGoalProto*) parseFromInputStream:(NSInputStream*) input;
+ (MiniEventGoalProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (MiniEventGoalProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (MiniEventGoalProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface MiniEventGoalProto_Builder : PBGeneratedMessageBuilder {
@private
  MiniEventGoalProto* result;
}

- (MiniEventGoalProto*) defaultInstance;

- (MiniEventGoalProto_Builder*) clear;
- (MiniEventGoalProto_Builder*) clone;

- (MiniEventGoalProto*) build;
- (MiniEventGoalProto*) buildPartial;

- (MiniEventGoalProto_Builder*) mergeFrom:(MiniEventGoalProto*) other;
- (MiniEventGoalProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (MiniEventGoalProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasMiniEventGoalId;
- (int32_t) miniEventGoalId;
- (MiniEventGoalProto_Builder*) setMiniEventGoalId:(int32_t) value;
- (MiniEventGoalProto_Builder*) clearMiniEventGoalId;

- (BOOL) hasMiniEventId;
- (int32_t) miniEventId;
- (MiniEventGoalProto_Builder*) setMiniEventId:(int32_t) value;
- (MiniEventGoalProto_Builder*) clearMiniEventId;

- (BOOL) hasGoalType;
- (MiniEventGoalProto_MiniEventGoalType) goalType;
- (MiniEventGoalProto_Builder*) setGoalType:(MiniEventGoalProto_MiniEventGoalType) value;
- (MiniEventGoalProto_Builder*) clearGoalTypeList;

- (BOOL) hasGoalAmt;
- (int32_t) goalAmt;
- (MiniEventGoalProto_Builder*) setGoalAmt:(int32_t) value;
- (MiniEventGoalProto_Builder*) clearGoalAmt;

- (BOOL) hasGoalDesc;
- (NSString*) goalDesc;
- (MiniEventGoalProto_Builder*) setGoalDesc:(NSString*) value;
- (MiniEventGoalProto_Builder*) clearGoalDesc;

- (BOOL) hasPointsGained;
- (int32_t) pointsGained;
- (MiniEventGoalProto_Builder*) setPointsGained:(int32_t) value;
- (MiniEventGoalProto_Builder*) clearPointsGained;

- (BOOL) hasActionDescription;
- (NSString*) actionDescription;
- (MiniEventGoalProto_Builder*) setActionDescription:(NSString*) value;
- (MiniEventGoalProto_Builder*) clearActionDescription;
@end

@interface MiniEventForPlayerLevelProto : PBGeneratedMessage {
@private
  BOOL hasMefplId_:1;
  BOOL hasMiniEventId_:1;
  BOOL hasPlayerLvlMin_:1;
  BOOL hasPlayerLvlMax_:1;
  BOOL hasTierOneMinPts_:1;
  BOOL hasTierTwoMinPts_:1;
  BOOL hasTierThreeMinPts_:1;
  int32_t mefplId;
  int32_t miniEventId;
  int32_t playerLvlMin;
  int32_t playerLvlMax;
  int32_t tierOneMinPts;
  int32_t tierTwoMinPts;
  int32_t tierThreeMinPts;
  NSMutableArray * mutableRewardsList;
}
- (BOOL) hasMefplId;
- (BOOL) hasMiniEventId;
- (BOOL) hasPlayerLvlMin;
- (BOOL) hasPlayerLvlMax;
- (BOOL) hasTierOneMinPts;
- (BOOL) hasTierTwoMinPts;
- (BOOL) hasTierThreeMinPts;
@property (readonly) int32_t mefplId;
@property (readonly) int32_t miniEventId;
@property (readonly) int32_t playerLvlMin;
@property (readonly) int32_t playerLvlMax;
@property (readonly) int32_t tierOneMinPts;
@property (readonly) int32_t tierTwoMinPts;
@property (readonly) int32_t tierThreeMinPts;
@property (readonly, strong) NSArray * rewardsList;
- (MiniEventTierRewardProto*)rewardsAtIndex:(NSUInteger)index;

+ (MiniEventForPlayerLevelProto*) defaultInstance;
- (MiniEventForPlayerLevelProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (MiniEventForPlayerLevelProto_Builder*) builder;
+ (MiniEventForPlayerLevelProto_Builder*) builder;
+ (MiniEventForPlayerLevelProto_Builder*) builderWithPrototype:(MiniEventForPlayerLevelProto*) prototype;
- (MiniEventForPlayerLevelProto_Builder*) toBuilder;

+ (MiniEventForPlayerLevelProto*) parseFromData:(NSData*) data;
+ (MiniEventForPlayerLevelProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (MiniEventForPlayerLevelProto*) parseFromInputStream:(NSInputStream*) input;
+ (MiniEventForPlayerLevelProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (MiniEventForPlayerLevelProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (MiniEventForPlayerLevelProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface MiniEventForPlayerLevelProto_Builder : PBGeneratedMessageBuilder {
@private
  MiniEventForPlayerLevelProto* result;
}

- (MiniEventForPlayerLevelProto*) defaultInstance;

- (MiniEventForPlayerLevelProto_Builder*) clear;
- (MiniEventForPlayerLevelProto_Builder*) clone;

- (MiniEventForPlayerLevelProto*) build;
- (MiniEventForPlayerLevelProto*) buildPartial;

- (MiniEventForPlayerLevelProto_Builder*) mergeFrom:(MiniEventForPlayerLevelProto*) other;
- (MiniEventForPlayerLevelProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (MiniEventForPlayerLevelProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasMefplId;
- (int32_t) mefplId;
- (MiniEventForPlayerLevelProto_Builder*) setMefplId:(int32_t) value;
- (MiniEventForPlayerLevelProto_Builder*) clearMefplId;

- (BOOL) hasMiniEventId;
- (int32_t) miniEventId;
- (MiniEventForPlayerLevelProto_Builder*) setMiniEventId:(int32_t) value;
- (MiniEventForPlayerLevelProto_Builder*) clearMiniEventId;

- (BOOL) hasPlayerLvlMin;
- (int32_t) playerLvlMin;
- (MiniEventForPlayerLevelProto_Builder*) setPlayerLvlMin:(int32_t) value;
- (MiniEventForPlayerLevelProto_Builder*) clearPlayerLvlMin;

- (BOOL) hasPlayerLvlMax;
- (int32_t) playerLvlMax;
- (MiniEventForPlayerLevelProto_Builder*) setPlayerLvlMax:(int32_t) value;
- (MiniEventForPlayerLevelProto_Builder*) clearPlayerLvlMax;

- (BOOL) hasTierOneMinPts;
- (int32_t) tierOneMinPts;
- (MiniEventForPlayerLevelProto_Builder*) setTierOneMinPts:(int32_t) value;
- (MiniEventForPlayerLevelProto_Builder*) clearTierOneMinPts;

- (BOOL) hasTierTwoMinPts;
- (int32_t) tierTwoMinPts;
- (MiniEventForPlayerLevelProto_Builder*) setTierTwoMinPts:(int32_t) value;
- (MiniEventForPlayerLevelProto_Builder*) clearTierTwoMinPts;

- (BOOL) hasTierThreeMinPts;
- (int32_t) tierThreeMinPts;
- (MiniEventForPlayerLevelProto_Builder*) setTierThreeMinPts:(int32_t) value;
- (MiniEventForPlayerLevelProto_Builder*) clearTierThreeMinPts;

- (NSMutableArray *)rewardsList;
- (MiniEventTierRewardProto*)rewardsAtIndex:(NSUInteger)index;
- (MiniEventForPlayerLevelProto_Builder *)addRewards:(MiniEventTierRewardProto*)value;
- (MiniEventForPlayerLevelProto_Builder *)addAllRewards:(NSArray *)array;
- (MiniEventForPlayerLevelProto_Builder *)clearRewards;
@end

@interface MiniEventTierRewardProto : PBGeneratedMessage {
@private
  BOOL hasMetrId_:1;
  BOOL hasMefplId_:1;
  BOOL hasRewardId_:1;
  BOOL hasTierLvl_:1;
  int32_t metrId;
  int32_t mefplId;
  int32_t rewardId;
  int32_t tierLvl;
}
- (BOOL) hasMetrId;
- (BOOL) hasMefplId;
- (BOOL) hasRewardId;
- (BOOL) hasTierLvl;
@property (readonly) int32_t metrId;
@property (readonly) int32_t mefplId;
@property (readonly) int32_t rewardId;
@property (readonly) int32_t tierLvl;

+ (MiniEventTierRewardProto*) defaultInstance;
- (MiniEventTierRewardProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (MiniEventTierRewardProto_Builder*) builder;
+ (MiniEventTierRewardProto_Builder*) builder;
+ (MiniEventTierRewardProto_Builder*) builderWithPrototype:(MiniEventTierRewardProto*) prototype;
- (MiniEventTierRewardProto_Builder*) toBuilder;

+ (MiniEventTierRewardProto*) parseFromData:(NSData*) data;
+ (MiniEventTierRewardProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (MiniEventTierRewardProto*) parseFromInputStream:(NSInputStream*) input;
+ (MiniEventTierRewardProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (MiniEventTierRewardProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (MiniEventTierRewardProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface MiniEventTierRewardProto_Builder : PBGeneratedMessageBuilder {
@private
  MiniEventTierRewardProto* result;
}

- (MiniEventTierRewardProto*) defaultInstance;

- (MiniEventTierRewardProto_Builder*) clear;
- (MiniEventTierRewardProto_Builder*) clone;

- (MiniEventTierRewardProto*) build;
- (MiniEventTierRewardProto*) buildPartial;

- (MiniEventTierRewardProto_Builder*) mergeFrom:(MiniEventTierRewardProto*) other;
- (MiniEventTierRewardProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (MiniEventTierRewardProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasMetrId;
- (int32_t) metrId;
- (MiniEventTierRewardProto_Builder*) setMetrId:(int32_t) value;
- (MiniEventTierRewardProto_Builder*) clearMetrId;

- (BOOL) hasMefplId;
- (int32_t) mefplId;
- (MiniEventTierRewardProto_Builder*) setMefplId:(int32_t) value;
- (MiniEventTierRewardProto_Builder*) clearMefplId;

- (BOOL) hasRewardId;
- (int32_t) rewardId;
- (MiniEventTierRewardProto_Builder*) setRewardId:(int32_t) value;
- (MiniEventTierRewardProto_Builder*) clearRewardId;

- (BOOL) hasTierLvl;
- (int32_t) tierLvl;
- (MiniEventTierRewardProto_Builder*) setTierLvl:(int32_t) value;
- (MiniEventTierRewardProto_Builder*) clearTierLvl;
@end

@interface MiniEventLeaderboardRewardProto : PBGeneratedMessage {
@private
  BOOL hasMelrId_:1;
  BOOL hasMiniEventId_:1;
  BOOL hasRewardId_:1;
  BOOL hasLeaderboardMinPos_:1;
  int32_t melrId;
  int32_t miniEventId;
  int32_t rewardId;
  int32_t leaderboardMinPos;
}
- (BOOL) hasMelrId;
- (BOOL) hasMiniEventId;
- (BOOL) hasRewardId;
- (BOOL) hasLeaderboardMinPos;
@property (readonly) int32_t melrId;
@property (readonly) int32_t miniEventId;
@property (readonly) int32_t rewardId;
@property (readonly) int32_t leaderboardMinPos;

+ (MiniEventLeaderboardRewardProto*) defaultInstance;
- (MiniEventLeaderboardRewardProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (MiniEventLeaderboardRewardProto_Builder*) builder;
+ (MiniEventLeaderboardRewardProto_Builder*) builder;
+ (MiniEventLeaderboardRewardProto_Builder*) builderWithPrototype:(MiniEventLeaderboardRewardProto*) prototype;
- (MiniEventLeaderboardRewardProto_Builder*) toBuilder;

+ (MiniEventLeaderboardRewardProto*) parseFromData:(NSData*) data;
+ (MiniEventLeaderboardRewardProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (MiniEventLeaderboardRewardProto*) parseFromInputStream:(NSInputStream*) input;
+ (MiniEventLeaderboardRewardProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (MiniEventLeaderboardRewardProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (MiniEventLeaderboardRewardProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface MiniEventLeaderboardRewardProto_Builder : PBGeneratedMessageBuilder {
@private
  MiniEventLeaderboardRewardProto* result;
}

- (MiniEventLeaderboardRewardProto*) defaultInstance;

- (MiniEventLeaderboardRewardProto_Builder*) clear;
- (MiniEventLeaderboardRewardProto_Builder*) clone;

- (MiniEventLeaderboardRewardProto*) build;
- (MiniEventLeaderboardRewardProto*) buildPartial;

- (MiniEventLeaderboardRewardProto_Builder*) mergeFrom:(MiniEventLeaderboardRewardProto*) other;
- (MiniEventLeaderboardRewardProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (MiniEventLeaderboardRewardProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasMelrId;
- (int32_t) melrId;
- (MiniEventLeaderboardRewardProto_Builder*) setMelrId:(int32_t) value;
- (MiniEventLeaderboardRewardProto_Builder*) clearMelrId;

- (BOOL) hasMiniEventId;
- (int32_t) miniEventId;
- (MiniEventLeaderboardRewardProto_Builder*) setMiniEventId:(int32_t) value;
- (MiniEventLeaderboardRewardProto_Builder*) clearMiniEventId;

- (BOOL) hasRewardId;
- (int32_t) rewardId;
- (MiniEventLeaderboardRewardProto_Builder*) setRewardId:(int32_t) value;
- (MiniEventLeaderboardRewardProto_Builder*) clearRewardId;

- (BOOL) hasLeaderboardMinPos;
- (int32_t) leaderboardMinPos;
- (MiniEventLeaderboardRewardProto_Builder*) setLeaderboardMinPos:(int32_t) value;
- (MiniEventLeaderboardRewardProto_Builder*) clearLeaderboardMinPos;
@end

@interface UserMiniEventProto : PBGeneratedMessage {
@private
  BOOL hasTierOneRedeemed_:1;
  BOOL hasTierTwoRedeemed_:1;
  BOOL hasTierThreeRedeemed_:1;
  BOOL hasMiniEventId_:1;
  BOOL hasUserLvl_:1;
  BOOL hasUserUuid_:1;
  BOOL hasMiniEvent_:1;
  BOOL tierOneRedeemed_:1;
  BOOL tierTwoRedeemed_:1;
  BOOL tierThreeRedeemed_:1;
  int32_t miniEventId;
  int32_t userLvl;
  NSString* userUuid;
  MiniEventProto* miniEvent;
  NSMutableArray * mutableGoalsList;
}
- (BOOL) hasMiniEventId;
- (BOOL) hasUserUuid;
- (BOOL) hasUserLvl;
- (BOOL) hasTierOneRedeemed;
- (BOOL) hasTierTwoRedeemed;
- (BOOL) hasTierThreeRedeemed;
- (BOOL) hasMiniEvent;
@property (readonly) int32_t miniEventId;
@property (readonly, strong) NSString* userUuid;
@property (readonly) int32_t userLvl;
- (BOOL) tierOneRedeemed;
- (BOOL) tierTwoRedeemed;
- (BOOL) tierThreeRedeemed;
@property (readonly, strong) MiniEventProto* miniEvent;
@property (readonly, strong) NSArray * goalsList;
- (UserMiniEventGoalProto*)goalsAtIndex:(NSUInteger)index;

+ (UserMiniEventProto*) defaultInstance;
- (UserMiniEventProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (UserMiniEventProto_Builder*) builder;
+ (UserMiniEventProto_Builder*) builder;
+ (UserMiniEventProto_Builder*) builderWithPrototype:(UserMiniEventProto*) prototype;
- (UserMiniEventProto_Builder*) toBuilder;

+ (UserMiniEventProto*) parseFromData:(NSData*) data;
+ (UserMiniEventProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserMiniEventProto*) parseFromInputStream:(NSInputStream*) input;
+ (UserMiniEventProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserMiniEventProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (UserMiniEventProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface UserMiniEventProto_Builder : PBGeneratedMessageBuilder {
@private
  UserMiniEventProto* result;
}

- (UserMiniEventProto*) defaultInstance;

- (UserMiniEventProto_Builder*) clear;
- (UserMiniEventProto_Builder*) clone;

- (UserMiniEventProto*) build;
- (UserMiniEventProto*) buildPartial;

- (UserMiniEventProto_Builder*) mergeFrom:(UserMiniEventProto*) other;
- (UserMiniEventProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (UserMiniEventProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasMiniEventId;
- (int32_t) miniEventId;
- (UserMiniEventProto_Builder*) setMiniEventId:(int32_t) value;
- (UserMiniEventProto_Builder*) clearMiniEventId;

- (BOOL) hasUserUuid;
- (NSString*) userUuid;
- (UserMiniEventProto_Builder*) setUserUuid:(NSString*) value;
- (UserMiniEventProto_Builder*) clearUserUuid;

- (BOOL) hasUserLvl;
- (int32_t) userLvl;
- (UserMiniEventProto_Builder*) setUserLvl:(int32_t) value;
- (UserMiniEventProto_Builder*) clearUserLvl;

- (BOOL) hasTierOneRedeemed;
- (BOOL) tierOneRedeemed;
- (UserMiniEventProto_Builder*) setTierOneRedeemed:(BOOL) value;
- (UserMiniEventProto_Builder*) clearTierOneRedeemed;

- (BOOL) hasTierTwoRedeemed;
- (BOOL) tierTwoRedeemed;
- (UserMiniEventProto_Builder*) setTierTwoRedeemed:(BOOL) value;
- (UserMiniEventProto_Builder*) clearTierTwoRedeemed;

- (BOOL) hasTierThreeRedeemed;
- (BOOL) tierThreeRedeemed;
- (UserMiniEventProto_Builder*) setTierThreeRedeemed:(BOOL) value;
- (UserMiniEventProto_Builder*) clearTierThreeRedeemed;

- (BOOL) hasMiniEvent;
- (MiniEventProto*) miniEvent;
- (UserMiniEventProto_Builder*) setMiniEvent:(MiniEventProto*) value;
- (UserMiniEventProto_Builder*) setMiniEvent_Builder:(MiniEventProto_Builder*) builderForValue;
- (UserMiniEventProto_Builder*) mergeMiniEvent:(MiniEventProto*) value;
- (UserMiniEventProto_Builder*) clearMiniEvent;

- (NSMutableArray *)goalsList;
- (UserMiniEventGoalProto*)goalsAtIndex:(NSUInteger)index;
- (UserMiniEventProto_Builder *)addGoals:(UserMiniEventGoalProto*)value;
- (UserMiniEventProto_Builder *)addAllGoals:(NSArray *)array;
- (UserMiniEventProto_Builder *)clearGoals;
@end

@interface UserMiniEventGoalProto : PBGeneratedMessage {
@private
  BOOL hasMiniEventGoalId_:1;
  BOOL hasProgress_:1;
  BOOL hasUserUuid_:1;
  int32_t miniEventGoalId;
  int32_t progress;
  NSString* userUuid;
}
- (BOOL) hasUserUuid;
- (BOOL) hasMiniEventGoalId;
- (BOOL) hasProgress;
@property (readonly, strong) NSString* userUuid;
@property (readonly) int32_t miniEventGoalId;
@property (readonly) int32_t progress;

+ (UserMiniEventGoalProto*) defaultInstance;
- (UserMiniEventGoalProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (UserMiniEventGoalProto_Builder*) builder;
+ (UserMiniEventGoalProto_Builder*) builder;
+ (UserMiniEventGoalProto_Builder*) builderWithPrototype:(UserMiniEventGoalProto*) prototype;
- (UserMiniEventGoalProto_Builder*) toBuilder;

+ (UserMiniEventGoalProto*) parseFromData:(NSData*) data;
+ (UserMiniEventGoalProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserMiniEventGoalProto*) parseFromInputStream:(NSInputStream*) input;
+ (UserMiniEventGoalProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserMiniEventGoalProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (UserMiniEventGoalProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface UserMiniEventGoalProto_Builder : PBGeneratedMessageBuilder {
@private
  UserMiniEventGoalProto* result;
}

- (UserMiniEventGoalProto*) defaultInstance;

- (UserMiniEventGoalProto_Builder*) clear;
- (UserMiniEventGoalProto_Builder*) clone;

- (UserMiniEventGoalProto*) build;
- (UserMiniEventGoalProto*) buildPartial;

- (UserMiniEventGoalProto_Builder*) mergeFrom:(UserMiniEventGoalProto*) other;
- (UserMiniEventGoalProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (UserMiniEventGoalProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasUserUuid;
- (NSString*) userUuid;
- (UserMiniEventGoalProto_Builder*) setUserUuid:(NSString*) value;
- (UserMiniEventGoalProto_Builder*) clearUserUuid;

- (BOOL) hasMiniEventGoalId;
- (int32_t) miniEventGoalId;
- (UserMiniEventGoalProto_Builder*) setMiniEventGoalId:(int32_t) value;
- (UserMiniEventGoalProto_Builder*) clearMiniEventGoalId;

- (BOOL) hasProgress;
- (int32_t) progress;
- (UserMiniEventGoalProto_Builder*) setProgress:(int32_t) value;
- (UserMiniEventGoalProto_Builder*) clearProgress;
@end


// @@protoc_insertion_point(global_scope)
