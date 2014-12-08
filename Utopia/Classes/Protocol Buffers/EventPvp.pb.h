// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "Battle.pb.h"
#import "MonsterStuff.pb.h"
#import "User.pb.h"
// @@protoc_insertion_point(imports)

@class BeginPvpBattleRequestProto;
@class BeginPvpBattleRequestProto_Builder;
@class BeginPvpBattleResponseProto;
@class BeginPvpBattleResponseProto_Builder;
@class EndPvpBattleRequestProto;
@class EndPvpBattleRequestProto_Builder;
@class EndPvpBattleResponseProto;
@class EndPvpBattleResponseProto_Builder;
@class FullUserMonsterProto;
@class FullUserMonsterProto_Builder;
@class FullUserProto;
@class FullUserProto_Builder;
@class MinimumClanProto;
@class MinimumClanProto_Builder;
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
@class PvpHistoryProto;
@class PvpHistoryProto_Builder;
@class PvpLeagueProto;
@class PvpLeagueProto_Builder;
@class PvpMonsterProto;
@class PvpMonsterProto_Builder;
@class PvpProto;
@class PvpProto_Builder;
@class QueueUpRequestProto;
@class QueueUpRequestProto_Builder;
@class QueueUpResponseProto;
@class QueueUpResponseProto_Builder;
@class StaticUserLevelInfoProto;
@class StaticUserLevelInfoProto_Builder;
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

typedef NS_ENUM(SInt32, QueueUpResponseProto_QueueUpStatus) {
  QueueUpResponseProto_QueueUpStatusSuccess = 1,
  QueueUpResponseProto_QueueUpStatusFailNotEnoughCash = 2,
  QueueUpResponseProto_QueueUpStatusFailOther = 3,
  QueueUpResponseProto_QueueUpStatusFailNotEnoughGems = 4,
};

BOOL QueueUpResponseProto_QueueUpStatusIsValidValue(QueueUpResponseProto_QueueUpStatus value);

typedef NS_ENUM(SInt32, BeginPvpBattleResponseProto_BeginPvpBattleStatus) {
  BeginPvpBattleResponseProto_BeginPvpBattleStatusSuccess = 1,
  BeginPvpBattleResponseProto_BeginPvpBattleStatusFailEnemyUnavailable = 2,
  BeginPvpBattleResponseProto_BeginPvpBattleStatusFailOther = 3,
};

BOOL BeginPvpBattleResponseProto_BeginPvpBattleStatusIsValidValue(BeginPvpBattleResponseProto_BeginPvpBattleStatus value);

typedef NS_ENUM(SInt32, EndPvpBattleResponseProto_EndPvpBattleStatus) {
  EndPvpBattleResponseProto_EndPvpBattleStatusSuccess = 1,
  EndPvpBattleResponseProto_EndPvpBattleStatusFailOther = 2,
  EndPvpBattleResponseProto_EndPvpBattleStatusFailBattleTookTooLong = 3,
};

BOOL EndPvpBattleResponseProto_EndPvpBattleStatusIsValidValue(EndPvpBattleResponseProto_EndPvpBattleStatus value);


@interface EventPvpRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface QueueUpRequestProto : PBGeneratedMessage {
@private
  BOOL hasClientTime_:1;
  BOOL hasAttackerElo_:1;
  BOOL hasAttacker_:1;
  int64_t clientTime;
  int32_t attackerElo;
  MinimumUserProto* attacker;
  NSMutableArray * mutableSeenUserUuidsList;
}
- (BOOL) hasAttacker;
- (BOOL) hasAttackerElo;
- (BOOL) hasClientTime;
@property (readonly, strong) MinimumUserProto* attacker;
@property (readonly) int32_t attackerElo;
@property (readonly, strong) NSArray * seenUserUuidsList;
@property (readonly) int64_t clientTime;
- (NSString*)seenUserUuidsAtIndex:(NSUInteger)index;

+ (QueueUpRequestProto*) defaultInstance;
- (QueueUpRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (QueueUpRequestProto_Builder*) builder;
+ (QueueUpRequestProto_Builder*) builder;
+ (QueueUpRequestProto_Builder*) builderWithPrototype:(QueueUpRequestProto*) prototype;
- (QueueUpRequestProto_Builder*) toBuilder;

+ (QueueUpRequestProto*) parseFromData:(NSData*) data;
+ (QueueUpRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QueueUpRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (QueueUpRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QueueUpRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (QueueUpRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface QueueUpRequestProto_Builder : PBGeneratedMessageBuilder {
@private
  QueueUpRequestProto* result;
}

- (QueueUpRequestProto*) defaultInstance;

- (QueueUpRequestProto_Builder*) clear;
- (QueueUpRequestProto_Builder*) clone;

- (QueueUpRequestProto*) build;
- (QueueUpRequestProto*) buildPartial;

- (QueueUpRequestProto_Builder*) mergeFrom:(QueueUpRequestProto*) other;
- (QueueUpRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (QueueUpRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasAttacker;
- (MinimumUserProto*) attacker;
- (QueueUpRequestProto_Builder*) setAttacker:(MinimumUserProto*) value;
- (QueueUpRequestProto_Builder*) setAttacker_Builder:(MinimumUserProto_Builder*) builderForValue;
- (QueueUpRequestProto_Builder*) mergeAttacker:(MinimumUserProto*) value;
- (QueueUpRequestProto_Builder*) clearAttacker;

- (BOOL) hasAttackerElo;
- (int32_t) attackerElo;
- (QueueUpRequestProto_Builder*) setAttackerElo:(int32_t) value;
- (QueueUpRequestProto_Builder*) clearAttackerElo;

- (NSMutableArray *)seenUserUuidsList;
- (NSString*)seenUserUuidsAtIndex:(NSUInteger)index;
- (QueueUpRequestProto_Builder *)addSeenUserUuids:(NSString*)value;
- (QueueUpRequestProto_Builder *)addAllSeenUserUuids:(NSArray *)array;
- (QueueUpRequestProto_Builder *)clearSeenUserUuids;

- (BOOL) hasClientTime;
- (int64_t) clientTime;
- (QueueUpRequestProto_Builder*) setClientTime:(int64_t) value;
- (QueueUpRequestProto_Builder*) clearClientTime;
@end

@interface QueueUpResponseProto : PBGeneratedMessage {
@private
  BOOL hasAttacker_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* attacker;
  QueueUpResponseProto_QueueUpStatus status;
  NSMutableArray * mutableDefenderInfoListList;
}
- (BOOL) hasAttacker;
- (BOOL) hasStatus;
@property (readonly, strong) MinimumUserProto* attacker;
@property (readonly, strong) NSArray * defenderInfoListList;
@property (readonly) QueueUpResponseProto_QueueUpStatus status;
- (PvpProto*)defenderInfoListAtIndex:(NSUInteger)index;

+ (QueueUpResponseProto*) defaultInstance;
- (QueueUpResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (QueueUpResponseProto_Builder*) builder;
+ (QueueUpResponseProto_Builder*) builder;
+ (QueueUpResponseProto_Builder*) builderWithPrototype:(QueueUpResponseProto*) prototype;
- (QueueUpResponseProto_Builder*) toBuilder;

+ (QueueUpResponseProto*) parseFromData:(NSData*) data;
+ (QueueUpResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QueueUpResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (QueueUpResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (QueueUpResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (QueueUpResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface QueueUpResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  QueueUpResponseProto* result;
}

- (QueueUpResponseProto*) defaultInstance;

- (QueueUpResponseProto_Builder*) clear;
- (QueueUpResponseProto_Builder*) clone;

- (QueueUpResponseProto*) build;
- (QueueUpResponseProto*) buildPartial;

- (QueueUpResponseProto_Builder*) mergeFrom:(QueueUpResponseProto*) other;
- (QueueUpResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (QueueUpResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasAttacker;
- (MinimumUserProto*) attacker;
- (QueueUpResponseProto_Builder*) setAttacker:(MinimumUserProto*) value;
- (QueueUpResponseProto_Builder*) setAttacker_Builder:(MinimumUserProto_Builder*) builderForValue;
- (QueueUpResponseProto_Builder*) mergeAttacker:(MinimumUserProto*) value;
- (QueueUpResponseProto_Builder*) clearAttacker;

- (NSMutableArray *)defenderInfoListList;
- (PvpProto*)defenderInfoListAtIndex:(NSUInteger)index;
- (QueueUpResponseProto_Builder *)addDefenderInfoList:(PvpProto*)value;
- (QueueUpResponseProto_Builder *)addAllDefenderInfoList:(NSArray *)array;
- (QueueUpResponseProto_Builder *)clearDefenderInfoList;

- (BOOL) hasStatus;
- (QueueUpResponseProto_QueueUpStatus) status;
- (QueueUpResponseProto_Builder*) setStatus:(QueueUpResponseProto_QueueUpStatus) value;
- (QueueUpResponseProto_Builder*) clearStatus;
@end

@interface BeginPvpBattleRequestProto : PBGeneratedMessage {
@private
  BOOL hasExactingRevenge_:1;
  BOOL hasAttackStartTime_:1;
  BOOL hasPreviousBattleEndTime_:1;
  BOOL hasSenderElo_:1;
  BOOL hasSender_:1;
  BOOL hasEnemy_:1;
  BOOL exactingRevenge_:1;
  int64_t attackStartTime;
  int64_t previousBattleEndTime;
  int32_t senderElo;
  MinimumUserProto* sender;
  PvpProto* enemy;
}
- (BOOL) hasSender;
- (BOOL) hasSenderElo;
- (BOOL) hasAttackStartTime;
- (BOOL) hasEnemy;
- (BOOL) hasExactingRevenge;
- (BOOL) hasPreviousBattleEndTime;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) int32_t senderElo;
@property (readonly) int64_t attackStartTime;
@property (readonly, strong) PvpProto* enemy;
- (BOOL) exactingRevenge;
@property (readonly) int64_t previousBattleEndTime;

+ (BeginPvpBattleRequestProto*) defaultInstance;
- (BeginPvpBattleRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (BeginPvpBattleRequestProto_Builder*) builder;
+ (BeginPvpBattleRequestProto_Builder*) builder;
+ (BeginPvpBattleRequestProto_Builder*) builderWithPrototype:(BeginPvpBattleRequestProto*) prototype;
- (BeginPvpBattleRequestProto_Builder*) toBuilder;

+ (BeginPvpBattleRequestProto*) parseFromData:(NSData*) data;
+ (BeginPvpBattleRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BeginPvpBattleRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (BeginPvpBattleRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BeginPvpBattleRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (BeginPvpBattleRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface BeginPvpBattleRequestProto_Builder : PBGeneratedMessageBuilder {
@private
  BeginPvpBattleRequestProto* result;
}

- (BeginPvpBattleRequestProto*) defaultInstance;

- (BeginPvpBattleRequestProto_Builder*) clear;
- (BeginPvpBattleRequestProto_Builder*) clone;

- (BeginPvpBattleRequestProto*) build;
- (BeginPvpBattleRequestProto*) buildPartial;

- (BeginPvpBattleRequestProto_Builder*) mergeFrom:(BeginPvpBattleRequestProto*) other;
- (BeginPvpBattleRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (BeginPvpBattleRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (BeginPvpBattleRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (BeginPvpBattleRequestProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (BeginPvpBattleRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (BeginPvpBattleRequestProto_Builder*) clearSender;

- (BOOL) hasSenderElo;
- (int32_t) senderElo;
- (BeginPvpBattleRequestProto_Builder*) setSenderElo:(int32_t) value;
- (BeginPvpBattleRequestProto_Builder*) clearSenderElo;

- (BOOL) hasAttackStartTime;
- (int64_t) attackStartTime;
- (BeginPvpBattleRequestProto_Builder*) setAttackStartTime:(int64_t) value;
- (BeginPvpBattleRequestProto_Builder*) clearAttackStartTime;

- (BOOL) hasEnemy;
- (PvpProto*) enemy;
- (BeginPvpBattleRequestProto_Builder*) setEnemy:(PvpProto*) value;
- (BeginPvpBattleRequestProto_Builder*) setEnemy_Builder:(PvpProto_Builder*) builderForValue;
- (BeginPvpBattleRequestProto_Builder*) mergeEnemy:(PvpProto*) value;
- (BeginPvpBattleRequestProto_Builder*) clearEnemy;

- (BOOL) hasExactingRevenge;
- (BOOL) exactingRevenge;
- (BeginPvpBattleRequestProto_Builder*) setExactingRevenge:(BOOL) value;
- (BeginPvpBattleRequestProto_Builder*) clearExactingRevenge;

- (BOOL) hasPreviousBattleEndTime;
- (int64_t) previousBattleEndTime;
- (BeginPvpBattleRequestProto_Builder*) setPreviousBattleEndTime:(int64_t) value;
- (BeginPvpBattleRequestProto_Builder*) clearPreviousBattleEndTime;
@end

@interface BeginPvpBattleResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  BeginPvpBattleResponseProto_BeginPvpBattleStatus status;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) BeginPvpBattleResponseProto_BeginPvpBattleStatus status;

+ (BeginPvpBattleResponseProto*) defaultInstance;
- (BeginPvpBattleResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (BeginPvpBattleResponseProto_Builder*) builder;
+ (BeginPvpBattleResponseProto_Builder*) builder;
+ (BeginPvpBattleResponseProto_Builder*) builderWithPrototype:(BeginPvpBattleResponseProto*) prototype;
- (BeginPvpBattleResponseProto_Builder*) toBuilder;

+ (BeginPvpBattleResponseProto*) parseFromData:(NSData*) data;
+ (BeginPvpBattleResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BeginPvpBattleResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (BeginPvpBattleResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BeginPvpBattleResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (BeginPvpBattleResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface BeginPvpBattleResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  BeginPvpBattleResponseProto* result;
}

- (BeginPvpBattleResponseProto*) defaultInstance;

- (BeginPvpBattleResponseProto_Builder*) clear;
- (BeginPvpBattleResponseProto_Builder*) clone;

- (BeginPvpBattleResponseProto*) build;
- (BeginPvpBattleResponseProto*) buildPartial;

- (BeginPvpBattleResponseProto_Builder*) mergeFrom:(BeginPvpBattleResponseProto*) other;
- (BeginPvpBattleResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (BeginPvpBattleResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (BeginPvpBattleResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (BeginPvpBattleResponseProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (BeginPvpBattleResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (BeginPvpBattleResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (BeginPvpBattleResponseProto_BeginPvpBattleStatus) status;
- (BeginPvpBattleResponseProto_Builder*) setStatus:(BeginPvpBattleResponseProto_BeginPvpBattleStatus) value;
- (BeginPvpBattleResponseProto_Builder*) clearStatus;
@end

@interface EndPvpBattleRequestProto : PBGeneratedMessage {
@private
  BOOL hasUserAttacked_:1;
  BOOL hasUserWon_:1;
  BOOL hasNuPvpDmgMultiplier_:1;
  BOOL hasClientTime_:1;
  BOOL hasOilChange_:1;
  BOOL hasCashChange_:1;
  BOOL hasDefenderUuid_:1;
  BOOL hasSender_:1;
  BOOL userAttacked_:1;
  BOOL userWon_:1;
  Float32 nuPvpDmgMultiplier;
  int64_t clientTime;
  int32_t oilChange;
  int32_t cashChange;
  NSString* defenderUuid;
  MinimumUserProtoWithMaxResources* sender;
  PBAppendableArray * mutableMonsterDropIdsList;
}
- (BOOL) hasSender;
- (BOOL) hasDefenderUuid;
- (BOOL) hasUserAttacked;
- (BOOL) hasUserWon;
- (BOOL) hasClientTime;
- (BOOL) hasOilChange;
- (BOOL) hasCashChange;
- (BOOL) hasNuPvpDmgMultiplier;
@property (readonly, strong) MinimumUserProtoWithMaxResources* sender;
@property (readonly, strong) NSString* defenderUuid;
- (BOOL) userAttacked;
- (BOOL) userWon;
@property (readonly) int64_t clientTime;
@property (readonly) int32_t oilChange;
@property (readonly) int32_t cashChange;
@property (readonly) Float32 nuPvpDmgMultiplier;
@property (readonly, strong) PBArray * monsterDropIdsList;
- (int32_t)monsterDropIdsAtIndex:(NSUInteger)index;

+ (EndPvpBattleRequestProto*) defaultInstance;
- (EndPvpBattleRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (EndPvpBattleRequestProto_Builder*) builder;
+ (EndPvpBattleRequestProto_Builder*) builder;
+ (EndPvpBattleRequestProto_Builder*) builderWithPrototype:(EndPvpBattleRequestProto*) prototype;
- (EndPvpBattleRequestProto_Builder*) toBuilder;

+ (EndPvpBattleRequestProto*) parseFromData:(NSData*) data;
+ (EndPvpBattleRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (EndPvpBattleRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (EndPvpBattleRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (EndPvpBattleRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (EndPvpBattleRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface EndPvpBattleRequestProto_Builder : PBGeneratedMessageBuilder {
@private
  EndPvpBattleRequestProto* result;
}

- (EndPvpBattleRequestProto*) defaultInstance;

- (EndPvpBattleRequestProto_Builder*) clear;
- (EndPvpBattleRequestProto_Builder*) clone;

- (EndPvpBattleRequestProto*) build;
- (EndPvpBattleRequestProto*) buildPartial;

- (EndPvpBattleRequestProto_Builder*) mergeFrom:(EndPvpBattleRequestProto*) other;
- (EndPvpBattleRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (EndPvpBattleRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProtoWithMaxResources*) sender;
- (EndPvpBattleRequestProto_Builder*) setSender:(MinimumUserProtoWithMaxResources*) value;
- (EndPvpBattleRequestProto_Builder*) setSender_Builder:(MinimumUserProtoWithMaxResources_Builder*) builderForValue;
- (EndPvpBattleRequestProto_Builder*) mergeSender:(MinimumUserProtoWithMaxResources*) value;
- (EndPvpBattleRequestProto_Builder*) clearSender;

- (BOOL) hasDefenderUuid;
- (NSString*) defenderUuid;
- (EndPvpBattleRequestProto_Builder*) setDefenderUuid:(NSString*) value;
- (EndPvpBattleRequestProto_Builder*) clearDefenderUuid;

- (BOOL) hasUserAttacked;
- (BOOL) userAttacked;
- (EndPvpBattleRequestProto_Builder*) setUserAttacked:(BOOL) value;
- (EndPvpBattleRequestProto_Builder*) clearUserAttacked;

- (BOOL) hasUserWon;
- (BOOL) userWon;
- (EndPvpBattleRequestProto_Builder*) setUserWon:(BOOL) value;
- (EndPvpBattleRequestProto_Builder*) clearUserWon;

- (BOOL) hasClientTime;
- (int64_t) clientTime;
- (EndPvpBattleRequestProto_Builder*) setClientTime:(int64_t) value;
- (EndPvpBattleRequestProto_Builder*) clearClientTime;

- (BOOL) hasOilChange;
- (int32_t) oilChange;
- (EndPvpBattleRequestProto_Builder*) setOilChange:(int32_t) value;
- (EndPvpBattleRequestProto_Builder*) clearOilChange;

- (BOOL) hasCashChange;
- (int32_t) cashChange;
- (EndPvpBattleRequestProto_Builder*) setCashChange:(int32_t) value;
- (EndPvpBattleRequestProto_Builder*) clearCashChange;

- (BOOL) hasNuPvpDmgMultiplier;
- (Float32) nuPvpDmgMultiplier;
- (EndPvpBattleRequestProto_Builder*) setNuPvpDmgMultiplier:(Float32) value;
- (EndPvpBattleRequestProto_Builder*) clearNuPvpDmgMultiplier;

- (PBAppendableArray *)monsterDropIdsList;
- (int32_t)monsterDropIdsAtIndex:(NSUInteger)index;
- (EndPvpBattleRequestProto_Builder *)addMonsterDropIds:(int32_t)value;
- (EndPvpBattleRequestProto_Builder *)addAllMonsterDropIds:(NSArray *)array;
- (EndPvpBattleRequestProto_Builder *)setMonsterDropIdsValues:(const int32_t *)values count:(NSUInteger)count;
- (EndPvpBattleRequestProto_Builder *)clearMonsterDropIds;
@end

@interface EndPvpBattleResponseProto : PBGeneratedMessage {
@private
  BOOL hasAttackerAttacked_:1;
  BOOL hasAttackerWon_:1;
  BOOL hasDefenderUuid_:1;
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  BOOL attackerAttacked_:1;
  BOOL attackerWon_:1;
  NSString* defenderUuid;
  MinimumUserProtoWithMaxResources* sender;
  EndPvpBattleResponseProto_EndPvpBattleStatus status;
  NSMutableArray * mutableUpdatedOrNewList;
}
- (BOOL) hasSender;
- (BOOL) hasDefenderUuid;
- (BOOL) hasAttackerAttacked;
- (BOOL) hasAttackerWon;
- (BOOL) hasStatus;
@property (readonly, strong) MinimumUserProtoWithMaxResources* sender;
@property (readonly, strong) NSString* defenderUuid;
- (BOOL) attackerAttacked;
- (BOOL) attackerWon;
@property (readonly) EndPvpBattleResponseProto_EndPvpBattleStatus status;
@property (readonly, strong) NSArray * updatedOrNewList;
- (FullUserMonsterProto*)updatedOrNewAtIndex:(NSUInteger)index;

+ (EndPvpBattleResponseProto*) defaultInstance;
- (EndPvpBattleResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (EndPvpBattleResponseProto_Builder*) builder;
+ (EndPvpBattleResponseProto_Builder*) builder;
+ (EndPvpBattleResponseProto_Builder*) builderWithPrototype:(EndPvpBattleResponseProto*) prototype;
- (EndPvpBattleResponseProto_Builder*) toBuilder;

+ (EndPvpBattleResponseProto*) parseFromData:(NSData*) data;
+ (EndPvpBattleResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (EndPvpBattleResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (EndPvpBattleResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (EndPvpBattleResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (EndPvpBattleResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface EndPvpBattleResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  EndPvpBattleResponseProto* result;
}

- (EndPvpBattleResponseProto*) defaultInstance;

- (EndPvpBattleResponseProto_Builder*) clear;
- (EndPvpBattleResponseProto_Builder*) clone;

- (EndPvpBattleResponseProto*) build;
- (EndPvpBattleResponseProto*) buildPartial;

- (EndPvpBattleResponseProto_Builder*) mergeFrom:(EndPvpBattleResponseProto*) other;
- (EndPvpBattleResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (EndPvpBattleResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProtoWithMaxResources*) sender;
- (EndPvpBattleResponseProto_Builder*) setSender:(MinimumUserProtoWithMaxResources*) value;
- (EndPvpBattleResponseProto_Builder*) setSender_Builder:(MinimumUserProtoWithMaxResources_Builder*) builderForValue;
- (EndPvpBattleResponseProto_Builder*) mergeSender:(MinimumUserProtoWithMaxResources*) value;
- (EndPvpBattleResponseProto_Builder*) clearSender;

- (BOOL) hasDefenderUuid;
- (NSString*) defenderUuid;
- (EndPvpBattleResponseProto_Builder*) setDefenderUuid:(NSString*) value;
- (EndPvpBattleResponseProto_Builder*) clearDefenderUuid;

- (BOOL) hasAttackerAttacked;
- (BOOL) attackerAttacked;
- (EndPvpBattleResponseProto_Builder*) setAttackerAttacked:(BOOL) value;
- (EndPvpBattleResponseProto_Builder*) clearAttackerAttacked;

- (BOOL) hasAttackerWon;
- (BOOL) attackerWon;
- (EndPvpBattleResponseProto_Builder*) setAttackerWon:(BOOL) value;
- (EndPvpBattleResponseProto_Builder*) clearAttackerWon;

- (BOOL) hasStatus;
- (EndPvpBattleResponseProto_EndPvpBattleStatus) status;
- (EndPvpBattleResponseProto_Builder*) setStatus:(EndPvpBattleResponseProto_EndPvpBattleStatus) value;
- (EndPvpBattleResponseProto_Builder*) clearStatus;

- (NSMutableArray *)updatedOrNewList;
- (FullUserMonsterProto*)updatedOrNewAtIndex:(NSUInteger)index;
- (EndPvpBattleResponseProto_Builder *)addUpdatedOrNew:(FullUserMonsterProto*)value;
- (EndPvpBattleResponseProto_Builder *)addAllUpdatedOrNew:(NSArray *)array;
- (EndPvpBattleResponseProto_Builder *)clearUpdatedOrNew;
@end


// @@protoc_insertion_point(global_scope)
