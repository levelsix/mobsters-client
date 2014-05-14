// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "MonsterStuff.pb.h"
#import "SharedEnumConfig.pb.h"
#import "Structure.pb.h"

@class CoordinateProto;
@class CoordinateProto_Builder;
@class FullUserMonsterProto;
@class FullUserMonsterProto_Builder;
@class FullUserStructureProto;
@class FullUserStructureProto_Builder;
@class HospitalProto;
@class HospitalProto_Builder;
@class LabProto;
@class LabProto_Builder;
@class MiniJobCenterProto;
@class MiniJobCenterProto_Builder;
@class MiniJobProto;
@class MiniJobProto_Builder;
@class MinimumObstacleProto;
@class MinimumObstacleProto_Builder;
@class MinimumUserMonsterProto;
@class MinimumUserMonsterProto_Builder;
@class MinimumUserMonsterSellProto;
@class MinimumUserMonsterSellProto_Builder;
@class MonsterBattleDialogueProto;
@class MonsterBattleDialogueProto_Builder;
@class MonsterLevelInfoProto;
@class MonsterLevelInfoProto_Builder;
@class MonsterProto;
@class MonsterProto_Builder;
@class ObstacleProto;
@class ObstacleProto_Builder;
@class ResidenceProto;
@class ResidenceProto_Builder;
@class ResourceGeneratorProto;
@class ResourceGeneratorProto_Builder;
@class ResourceStorageProto;
@class ResourceStorageProto_Builder;
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
@class UserMiniJobProto;
@class UserMiniJobProto_Builder;
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

@interface MiniJobConfigRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface MiniJobProto : PBGeneratedMessage {
@private
  BOOL hasChanceToAppear_:1;
  BOOL hasMiniJobId_:1;
  BOOL hasRequiredStructId_:1;
  BOOL hasCashReward_:1;
  BOOL hasOilReward_:1;
  BOOL hasGemReward_:1;
  BOOL hasMonsterIdReward_:1;
  BOOL hasMaxNumMonstersAllowed_:1;
  BOOL hasHpRequired_:1;
  BOOL hasAtkRequired_:1;
  BOOL hasMinDmgDealt_:1;
  BOOL hasMaxDmgDealt_:1;
  BOOL hasDurationMinMinutes_:1;
  BOOL hasDurationMaxMinutes_:1;
  BOOL hasName_:1;
  BOOL hasQuality_:1;
  Float32 chanceToAppear;
  int32_t miniJobId;
  int32_t requiredStructId;
  int32_t cashReward;
  int32_t oilReward;
  int32_t gemReward;
  int32_t monsterIdReward;
  int32_t maxNumMonstersAllowed;
  int32_t hpRequired;
  int32_t atkRequired;
  int32_t minDmgDealt;
  int32_t maxDmgDealt;
  int32_t durationMinMinutes;
  int32_t durationMaxMinutes;
  NSString* name;
  Quality quality;
}
- (BOOL) hasMiniJobId;
- (BOOL) hasRequiredStructId;
- (BOOL) hasName;
- (BOOL) hasCashReward;
- (BOOL) hasOilReward;
- (BOOL) hasGemReward;
- (BOOL) hasMonsterIdReward;
- (BOOL) hasQuality;
- (BOOL) hasMaxNumMonstersAllowed;
- (BOOL) hasChanceToAppear;
- (BOOL) hasHpRequired;
- (BOOL) hasAtkRequired;
- (BOOL) hasMinDmgDealt;
- (BOOL) hasMaxDmgDealt;
- (BOOL) hasDurationMinMinutes;
- (BOOL) hasDurationMaxMinutes;
@property (readonly) int32_t miniJobId;
@property (readonly) int32_t requiredStructId;
@property (readonly, retain) NSString* name;
@property (readonly) int32_t cashReward;
@property (readonly) int32_t oilReward;
@property (readonly) int32_t gemReward;
@property (readonly) int32_t monsterIdReward;
@property (readonly) Quality quality;
@property (readonly) int32_t maxNumMonstersAllowed;
@property (readonly) Float32 chanceToAppear;
@property (readonly) int32_t hpRequired;
@property (readonly) int32_t atkRequired;
@property (readonly) int32_t minDmgDealt;
@property (readonly) int32_t maxDmgDealt;
@property (readonly) int32_t durationMinMinutes;
@property (readonly) int32_t durationMaxMinutes;

+ (MiniJobProto*) defaultInstance;
- (MiniJobProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (MiniJobProto_Builder*) builder;
+ (MiniJobProto_Builder*) builder;
+ (MiniJobProto_Builder*) builderWithPrototype:(MiniJobProto*) prototype;

+ (MiniJobProto*) parseFromData:(NSData*) data;
+ (MiniJobProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (MiniJobProto*) parseFromInputStream:(NSInputStream*) input;
+ (MiniJobProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (MiniJobProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (MiniJobProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface MiniJobProto_Builder : PBGeneratedMessage_Builder {
@private
  MiniJobProto* result;
}

- (MiniJobProto*) defaultInstance;

- (MiniJobProto_Builder*) clear;
- (MiniJobProto_Builder*) clone;

- (MiniJobProto*) build;
- (MiniJobProto*) buildPartial;

- (MiniJobProto_Builder*) mergeFrom:(MiniJobProto*) other;
- (MiniJobProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (MiniJobProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasMiniJobId;
- (int32_t) miniJobId;
- (MiniJobProto_Builder*) setMiniJobId:(int32_t) value;
- (MiniJobProto_Builder*) clearMiniJobId;

- (BOOL) hasRequiredStructId;
- (int32_t) requiredStructId;
- (MiniJobProto_Builder*) setRequiredStructId:(int32_t) value;
- (MiniJobProto_Builder*) clearRequiredStructId;

- (BOOL) hasName;
- (NSString*) name;
- (MiniJobProto_Builder*) setName:(NSString*) value;
- (MiniJobProto_Builder*) clearName;

- (BOOL) hasCashReward;
- (int32_t) cashReward;
- (MiniJobProto_Builder*) setCashReward:(int32_t) value;
- (MiniJobProto_Builder*) clearCashReward;

- (BOOL) hasOilReward;
- (int32_t) oilReward;
- (MiniJobProto_Builder*) setOilReward:(int32_t) value;
- (MiniJobProto_Builder*) clearOilReward;

- (BOOL) hasGemReward;
- (int32_t) gemReward;
- (MiniJobProto_Builder*) setGemReward:(int32_t) value;
- (MiniJobProto_Builder*) clearGemReward;

- (BOOL) hasMonsterIdReward;
- (int32_t) monsterIdReward;
- (MiniJobProto_Builder*) setMonsterIdReward:(int32_t) value;
- (MiniJobProto_Builder*) clearMonsterIdReward;

- (BOOL) hasQuality;
- (Quality) quality;
- (MiniJobProto_Builder*) setQuality:(Quality) value;
- (MiniJobProto_Builder*) clearQuality;

- (BOOL) hasMaxNumMonstersAllowed;
- (int32_t) maxNumMonstersAllowed;
- (MiniJobProto_Builder*) setMaxNumMonstersAllowed:(int32_t) value;
- (MiniJobProto_Builder*) clearMaxNumMonstersAllowed;

- (BOOL) hasChanceToAppear;
- (Float32) chanceToAppear;
- (MiniJobProto_Builder*) setChanceToAppear:(Float32) value;
- (MiniJobProto_Builder*) clearChanceToAppear;

- (BOOL) hasHpRequired;
- (int32_t) hpRequired;
- (MiniJobProto_Builder*) setHpRequired:(int32_t) value;
- (MiniJobProto_Builder*) clearHpRequired;

- (BOOL) hasAtkRequired;
- (int32_t) atkRequired;
- (MiniJobProto_Builder*) setAtkRequired:(int32_t) value;
- (MiniJobProto_Builder*) clearAtkRequired;

- (BOOL) hasMinDmgDealt;
- (int32_t) minDmgDealt;
- (MiniJobProto_Builder*) setMinDmgDealt:(int32_t) value;
- (MiniJobProto_Builder*) clearMinDmgDealt;

- (BOOL) hasMaxDmgDealt;
- (int32_t) maxDmgDealt;
- (MiniJobProto_Builder*) setMaxDmgDealt:(int32_t) value;
- (MiniJobProto_Builder*) clearMaxDmgDealt;

- (BOOL) hasDurationMinMinutes;
- (int32_t) durationMinMinutes;
- (MiniJobProto_Builder*) setDurationMinMinutes:(int32_t) value;
- (MiniJobProto_Builder*) clearDurationMinMinutes;

- (BOOL) hasDurationMaxMinutes;
- (int32_t) durationMaxMinutes;
- (MiniJobProto_Builder*) setDurationMaxMinutes:(int32_t) value;
- (MiniJobProto_Builder*) clearDurationMaxMinutes;
@end

@interface UserMiniJobProto : PBGeneratedMessage {
@private
  BOOL hasUserMiniJobId_:1;
  BOOL hasTimeStarted_:1;
  BOOL hasTimeCompleted_:1;
  BOOL hasBaseDmgReceived_:1;
  BOOL hasDurationMinutes_:1;
  BOOL hasMiniJob_:1;
  int64_t userMiniJobId;
  int64_t timeStarted;
  int64_t timeCompleted;
  int32_t baseDmgReceived;
  int32_t durationMinutes;
  MiniJobProto* miniJob;
  NSMutableArray* mutableUserMonsterIdsList;
}
- (BOOL) hasUserMiniJobId;
- (BOOL) hasBaseDmgReceived;
- (BOOL) hasTimeStarted;
- (BOOL) hasTimeCompleted;
- (BOOL) hasDurationMinutes;
- (BOOL) hasMiniJob;
@property (readonly) int64_t userMiniJobId;
@property (readonly) int32_t baseDmgReceived;
@property (readonly) int64_t timeStarted;
@property (readonly) int64_t timeCompleted;
@property (readonly) int32_t durationMinutes;
@property (readonly, retain) MiniJobProto* miniJob;
- (NSArray*) userMonsterIdsList;
- (int64_t) userMonsterIdsAtIndex:(int32_t) index;

+ (UserMiniJobProto*) defaultInstance;
- (UserMiniJobProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (UserMiniJobProto_Builder*) builder;
+ (UserMiniJobProto_Builder*) builder;
+ (UserMiniJobProto_Builder*) builderWithPrototype:(UserMiniJobProto*) prototype;

+ (UserMiniJobProto*) parseFromData:(NSData*) data;
+ (UserMiniJobProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserMiniJobProto*) parseFromInputStream:(NSInputStream*) input;
+ (UserMiniJobProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserMiniJobProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (UserMiniJobProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface UserMiniJobProto_Builder : PBGeneratedMessage_Builder {
@private
  UserMiniJobProto* result;
}

- (UserMiniJobProto*) defaultInstance;

- (UserMiniJobProto_Builder*) clear;
- (UserMiniJobProto_Builder*) clone;

- (UserMiniJobProto*) build;
- (UserMiniJobProto*) buildPartial;

- (UserMiniJobProto_Builder*) mergeFrom:(UserMiniJobProto*) other;
- (UserMiniJobProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (UserMiniJobProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasUserMiniJobId;
- (int64_t) userMiniJobId;
- (UserMiniJobProto_Builder*) setUserMiniJobId:(int64_t) value;
- (UserMiniJobProto_Builder*) clearUserMiniJobId;

- (BOOL) hasBaseDmgReceived;
- (int32_t) baseDmgReceived;
- (UserMiniJobProto_Builder*) setBaseDmgReceived:(int32_t) value;
- (UserMiniJobProto_Builder*) clearBaseDmgReceived;

- (BOOL) hasTimeStarted;
- (int64_t) timeStarted;
- (UserMiniJobProto_Builder*) setTimeStarted:(int64_t) value;
- (UserMiniJobProto_Builder*) clearTimeStarted;

- (NSArray*) userMonsterIdsList;
- (int64_t) userMonsterIdsAtIndex:(int32_t) index;
- (UserMiniJobProto_Builder*) replaceUserMonsterIdsAtIndex:(int32_t) index with:(int64_t) value;
- (UserMiniJobProto_Builder*) addUserMonsterIds:(int64_t) value;
- (UserMiniJobProto_Builder*) addAllUserMonsterIds:(NSArray*) values;
- (UserMiniJobProto_Builder*) clearUserMonsterIdsList;

- (BOOL) hasTimeCompleted;
- (int64_t) timeCompleted;
- (UserMiniJobProto_Builder*) setTimeCompleted:(int64_t) value;
- (UserMiniJobProto_Builder*) clearTimeCompleted;

- (BOOL) hasDurationMinutes;
- (int32_t) durationMinutes;
- (UserMiniJobProto_Builder*) setDurationMinutes:(int32_t) value;
- (UserMiniJobProto_Builder*) clearDurationMinutes;

- (BOOL) hasMiniJob;
- (MiniJobProto*) miniJob;
- (UserMiniJobProto_Builder*) setMiniJob:(MiniJobProto*) value;
- (UserMiniJobProto_Builder*) setMiniJobBuilder:(MiniJobProto_Builder*) builderForValue;
- (UserMiniJobProto_Builder*) mergeMiniJob:(MiniJobProto*) value;
- (UserMiniJobProto_Builder*) clearMiniJob;
@end

