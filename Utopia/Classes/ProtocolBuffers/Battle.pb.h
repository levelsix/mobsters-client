// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "MonsterStuff.pb.h"
#import "Research.pb.h"
#import "Structure.pb.h"
#import "User.pb.h"
// @@protoc_insertion_point(imports)

@class BattleItemFactoryProto;
@class BattleItemFactoryProto_Builder;
@class BattleReplayProto;
@class BattleReplayProto_Builder;
@class ClanHouseProto;
@class ClanHouseProto_Builder;
@class ClanMemberTeamDonationProto;
@class ClanMemberTeamDonationProto_Builder;
@class CoordinateProto;
@class CoordinateProto_Builder;
@class EvoChamberProto;
@class EvoChamberProto_Builder;
@class FullUserMonsterProto;
@class FullUserMonsterProto_Builder;
@class FullUserProto;
@class FullUserProto_Builder;
@class FullUserStructureProto;
@class FullUserStructureProto_Builder;
@class HospitalProto;
@class HospitalProto_Builder;
@class ItemGemPriceProto;
@class ItemGemPriceProto_Builder;
@class ItemProto;
@class ItemProto_Builder;
@class LabProto;
@class LabProto_Builder;
@class MiniJobCenterProto;
@class MiniJobCenterProto_Builder;
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
@class MoneyTreeProto;
@class MoneyTreeProto_Builder;
@class MonsterBattleDialogueProto;
@class MonsterBattleDialogueProto_Builder;
@class MonsterLevelInfoProto;
@class MonsterLevelInfoProto_Builder;
@class MonsterProto;
@class MonsterProto_Builder;
@class ObstacleProto;
@class ObstacleProto_Builder;
@class PvpBoardHouseProto;
@class PvpBoardHouseProto_Builder;
@class PvpBoardObstacleProto;
@class PvpBoardObstacleProto_Builder;
@class PvpClanAvengeProto;
@class PvpClanAvengeProto_Builder;
@class PvpHistoryProto;
@class PvpHistoryProto_Builder;
@class PvpLeagueProto;
@class PvpLeagueProto_Builder;
@class PvpMonsterProto;
@class PvpMonsterProto_Builder;
@class PvpProto;
@class PvpProto_Builder;
@class PvpUserClanAvengeProto;
@class PvpUserClanAvengeProto_Builder;
@class ResearchHouseProto;
@class ResearchHouseProto_Builder;
@class ResearchPropertyProto;
@class ResearchPropertyProto_Builder;
@class ResearchProto;
@class ResearchProto_Builder;
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
@class UserCurrentMonsterTeamProto;
@class UserCurrentMonsterTeamProto_Builder;
@class UserEnhancementItemProto;
@class UserEnhancementItemProto_Builder;
@class UserEnhancementProto;
@class UserEnhancementProto_Builder;
@class UserFacebookInviteForSlotProto;
@class UserFacebookInviteForSlotProto_Builder;
@class UserItemProto;
@class UserItemProto_Builder;
@class UserItemSecretGiftProto;
@class UserItemSecretGiftProto_Builder;
@class UserItemUsageProto;
@class UserItemUsageProto_Builder;
@class UserMonsterCurrentExpProto;
@class UserMonsterCurrentExpProto_Builder;
@class UserMonsterCurrentHealthProto;
@class UserMonsterCurrentHealthProto_Builder;
@class UserMonsterEvolutionProto;
@class UserMonsterEvolutionProto_Builder;
@class UserMonsterHealingProto;
@class UserMonsterHealingProto_Builder;
@class UserMonsterSnapshotProto;
@class UserMonsterSnapshotProto_Builder;
@class UserObstacleProto;
@class UserObstacleProto_Builder;
@class UserPvpBoardObstacleProto;
@class UserPvpBoardObstacleProto_Builder;
@class UserPvpLeagueProto;
@class UserPvpLeagueProto_Builder;
@class UserResearchProto;
@class UserResearchProto_Builder;
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

typedef NS_ENUM(SInt32, BattleResult) {
  BattleResultAttackerWin = 1,
  BattleResultDefenderWin = 2,
  BattleResultAttackerFlee = 3,
};

BOOL BattleResultIsValidValue(BattleResult value);


@interface BattleRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface PvpProto : PBGeneratedMessage {
@private
  BOOL hasProspectiveCashWinnings_:1;
  BOOL hasProspectiveOilWinnings_:1;
  BOOL hasMonsterIdDropped_:1;
  BOOL hasDefenderMsg_:1;
  BOOL hasDefender_:1;
  BOOL hasPvpLeagueStats_:1;
  BOOL hasCmtd_:1;
  int32_t prospectiveCashWinnings;
  int32_t prospectiveOilWinnings;
  int32_t monsterIdDropped;
  NSString* defenderMsg;
  MinimumUserProtoWithLevel* defender;
  UserPvpLeagueProto* pvpLeagueStats;
  ClanMemberTeamDonationProto* cmtd;
  NSMutableArray * mutableDefenderMonstersList;
  NSMutableArray * mutableUserBoardObstaclesList;
  NSMutableArray * mutableUserResearchList;
}
- (BOOL) hasDefender;
- (BOOL) hasProspectiveCashWinnings;
- (BOOL) hasProspectiveOilWinnings;
- (BOOL) hasPvpLeagueStats;
- (BOOL) hasDefenderMsg;
- (BOOL) hasCmtd;
- (BOOL) hasMonsterIdDropped;
@property (readonly, strong) MinimumUserProtoWithLevel* defender;
@property (readonly, strong) NSArray * defenderMonstersList;
@property (readonly) int32_t prospectiveCashWinnings;
@property (readonly) int32_t prospectiveOilWinnings;
@property (readonly, strong) UserPvpLeagueProto* pvpLeagueStats;
@property (readonly, strong) NSString* defenderMsg;
@property (readonly, strong) ClanMemberTeamDonationProto* cmtd;
@property (readonly) int32_t monsterIdDropped;
@property (readonly, strong) NSArray * userBoardObstaclesList;
@property (readonly, strong) NSArray * userResearchList;
- (PvpMonsterProto*)defenderMonstersAtIndex:(NSUInteger)index;
- (UserPvpBoardObstacleProto*)userBoardObstaclesAtIndex:(NSUInteger)index;
- (UserResearchProto*)userResearchAtIndex:(NSUInteger)index;

+ (PvpProto*) defaultInstance;
- (PvpProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PvpProto_Builder*) builder;
+ (PvpProto_Builder*) builder;
+ (PvpProto_Builder*) builderWithPrototype:(PvpProto*) prototype;
- (PvpProto_Builder*) toBuilder;

+ (PvpProto*) parseFromData:(NSData*) data;
+ (PvpProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PvpProto*) parseFromInputStream:(NSInputStream*) input;
+ (PvpProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PvpProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PvpProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PvpProto_Builder : PBGeneratedMessageBuilder {
@private
  PvpProto* result;
}

- (PvpProto*) defaultInstance;

- (PvpProto_Builder*) clear;
- (PvpProto_Builder*) clone;

- (PvpProto*) build;
- (PvpProto*) buildPartial;

- (PvpProto_Builder*) mergeFrom:(PvpProto*) other;
- (PvpProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PvpProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasDefender;
- (MinimumUserProtoWithLevel*) defender;
- (PvpProto_Builder*) setDefender:(MinimumUserProtoWithLevel*) value;
- (PvpProto_Builder*) setDefender_Builder:(MinimumUserProtoWithLevel_Builder*) builderForValue;
- (PvpProto_Builder*) mergeDefender:(MinimumUserProtoWithLevel*) value;
- (PvpProto_Builder*) clearDefender;

- (NSMutableArray *)defenderMonstersList;
- (PvpMonsterProto*)defenderMonstersAtIndex:(NSUInteger)index;
- (PvpProto_Builder *)addDefenderMonsters:(PvpMonsterProto*)value;
- (PvpProto_Builder *)addAllDefenderMonsters:(NSArray *)array;
- (PvpProto_Builder *)clearDefenderMonsters;

- (BOOL) hasProspectiveCashWinnings;
- (int32_t) prospectiveCashWinnings;
- (PvpProto_Builder*) setProspectiveCashWinnings:(int32_t) value;
- (PvpProto_Builder*) clearProspectiveCashWinnings;

- (BOOL) hasProspectiveOilWinnings;
- (int32_t) prospectiveOilWinnings;
- (PvpProto_Builder*) setProspectiveOilWinnings:(int32_t) value;
- (PvpProto_Builder*) clearProspectiveOilWinnings;

- (BOOL) hasPvpLeagueStats;
- (UserPvpLeagueProto*) pvpLeagueStats;
- (PvpProto_Builder*) setPvpLeagueStats:(UserPvpLeagueProto*) value;
- (PvpProto_Builder*) setPvpLeagueStats_Builder:(UserPvpLeagueProto_Builder*) builderForValue;
- (PvpProto_Builder*) mergePvpLeagueStats:(UserPvpLeagueProto*) value;
- (PvpProto_Builder*) clearPvpLeagueStats;

- (BOOL) hasDefenderMsg;
- (NSString*) defenderMsg;
- (PvpProto_Builder*) setDefenderMsg:(NSString*) value;
- (PvpProto_Builder*) clearDefenderMsg;

- (BOOL) hasCmtd;
- (ClanMemberTeamDonationProto*) cmtd;
- (PvpProto_Builder*) setCmtd:(ClanMemberTeamDonationProto*) value;
- (PvpProto_Builder*) setCmtd_Builder:(ClanMemberTeamDonationProto_Builder*) builderForValue;
- (PvpProto_Builder*) mergeCmtd:(ClanMemberTeamDonationProto*) value;
- (PvpProto_Builder*) clearCmtd;

- (BOOL) hasMonsterIdDropped;
- (int32_t) monsterIdDropped;
- (PvpProto_Builder*) setMonsterIdDropped:(int32_t) value;
- (PvpProto_Builder*) clearMonsterIdDropped;

- (NSMutableArray *)userBoardObstaclesList;
- (UserPvpBoardObstacleProto*)userBoardObstaclesAtIndex:(NSUInteger)index;
- (PvpProto_Builder *)addUserBoardObstacles:(UserPvpBoardObstacleProto*)value;
- (PvpProto_Builder *)addAllUserBoardObstacles:(NSArray *)array;
- (PvpProto_Builder *)clearUserBoardObstacles;

- (NSMutableArray *)userResearchList;
- (UserResearchProto*)userResearchAtIndex:(NSUInteger)index;
- (PvpProto_Builder *)addUserResearch:(UserResearchProto*)value;
- (PvpProto_Builder *)addAllUserResearch:(NSArray *)array;
- (PvpProto_Builder *)clearUserResearch;
@end

@interface PvpMonsterProto : PBGeneratedMessage {
@private
  BOOL hasMonsterIdDropped_:1;
  BOOL hasDefenderMonster_:1;
  int32_t monsterIdDropped;
  MinimumUserMonsterProto* defenderMonster;
}
- (BOOL) hasDefenderMonster;
- (BOOL) hasMonsterIdDropped;
@property (readonly, strong) MinimumUserMonsterProto* defenderMonster;
@property (readonly) int32_t monsterIdDropped;

+ (PvpMonsterProto*) defaultInstance;
- (PvpMonsterProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PvpMonsterProto_Builder*) builder;
+ (PvpMonsterProto_Builder*) builder;
+ (PvpMonsterProto_Builder*) builderWithPrototype:(PvpMonsterProto*) prototype;
- (PvpMonsterProto_Builder*) toBuilder;

+ (PvpMonsterProto*) parseFromData:(NSData*) data;
+ (PvpMonsterProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PvpMonsterProto*) parseFromInputStream:(NSInputStream*) input;
+ (PvpMonsterProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PvpMonsterProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PvpMonsterProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PvpMonsterProto_Builder : PBGeneratedMessageBuilder {
@private
  PvpMonsterProto* result;
}

- (PvpMonsterProto*) defaultInstance;

- (PvpMonsterProto_Builder*) clear;
- (PvpMonsterProto_Builder*) clone;

- (PvpMonsterProto*) build;
- (PvpMonsterProto*) buildPartial;

- (PvpMonsterProto_Builder*) mergeFrom:(PvpMonsterProto*) other;
- (PvpMonsterProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PvpMonsterProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasDefenderMonster;
- (MinimumUserMonsterProto*) defenderMonster;
- (PvpMonsterProto_Builder*) setDefenderMonster:(MinimumUserMonsterProto*) value;
- (PvpMonsterProto_Builder*) setDefenderMonster_Builder:(MinimumUserMonsterProto_Builder*) builderForValue;
- (PvpMonsterProto_Builder*) mergeDefenderMonster:(MinimumUserMonsterProto*) value;
- (PvpMonsterProto_Builder*) clearDefenderMonster;

- (BOOL) hasMonsterIdDropped;
- (int32_t) monsterIdDropped;
- (PvpMonsterProto_Builder*) setMonsterIdDropped:(int32_t) value;
- (PvpMonsterProto_Builder*) clearMonsterIdDropped;
@end

@interface PvpHistoryProto : PBGeneratedMessage {
@private
  BOOL hasAttackerWon_:1;
  BOOL hasExactedRevenge_:1;
  BOOL hasClanAvenged_:1;
  BOOL hasBattleEndTime_:1;
  BOOL hasProspectiveCashWinnings_:1;
  BOOL hasProspectiveOilWinnings_:1;
  BOOL hasAttackerCashChange_:1;
  BOOL hasAttackerOilChange_:1;
  BOOL hasReplayId_:1;
  BOOL hasAttacker_:1;
  BOOL hasAttackerBefore_:1;
  BOOL hasAttackerAfter_:1;
  BOOL hasDefenderBefore_:1;
  BOOL hasDefenderAfter_:1;
  BOOL hasDefender_:1;
  BOOL hasDefenderCashChange_:1;
  BOOL hasDefenderOilChange_:1;
  BOOL attackerWon_:1;
  BOOL exactedRevenge_:1;
  BOOL clanAvenged_:1;
  int64_t battleEndTime;
  int32_t prospectiveCashWinnings;
  int32_t prospectiveOilWinnings;
  int32_t attackerCashChange;
  int32_t attackerOilChange;
  NSString* replayId;
  FullUserProto* attacker;
  UserPvpLeagueProto* attackerBefore;
  UserPvpLeagueProto* attackerAfter;
  UserPvpLeagueProto* defenderBefore;
  UserPvpLeagueProto* defenderAfter;
  FullUserProto* defender;
  int32_t defenderCashChange;
  int32_t defenderOilChange;
  NSMutableArray * mutableAttackersMonstersList;
}
- (BOOL) hasBattleEndTime;
- (BOOL) hasAttacker;
- (BOOL) hasAttackerWon;
- (BOOL) hasDefenderCashChange;
- (BOOL) hasDefenderOilChange;
- (BOOL) hasExactedRevenge;
- (BOOL) hasProspectiveCashWinnings;
- (BOOL) hasProspectiveOilWinnings;
- (BOOL) hasAttackerBefore;
- (BOOL) hasAttackerAfter;
- (BOOL) hasDefenderBefore;
- (BOOL) hasDefenderAfter;
- (BOOL) hasDefender;
- (BOOL) hasAttackerCashChange;
- (BOOL) hasAttackerOilChange;
- (BOOL) hasClanAvenged;
- (BOOL) hasReplayId;
@property (readonly) int64_t battleEndTime;
@property (readonly, strong) FullUserProto* attacker;
@property (readonly, strong) NSArray * attackersMonstersList;
- (BOOL) attackerWon;
@property (readonly) int32_t defenderCashChange;
@property (readonly) int32_t defenderOilChange;
- (BOOL) exactedRevenge;
@property (readonly) int32_t prospectiveCashWinnings;
@property (readonly) int32_t prospectiveOilWinnings;
@property (readonly, strong) UserPvpLeagueProto* attackerBefore;
@property (readonly, strong) UserPvpLeagueProto* attackerAfter;
@property (readonly, strong) UserPvpLeagueProto* defenderBefore;
@property (readonly, strong) UserPvpLeagueProto* defenderAfter;
@property (readonly, strong) FullUserProto* defender;
@property (readonly) int32_t attackerCashChange;
@property (readonly) int32_t attackerOilChange;
- (BOOL) clanAvenged;
@property (readonly, strong) NSString* replayId;
- (PvpMonsterProto*)attackersMonstersAtIndex:(NSUInteger)index;

+ (PvpHistoryProto*) defaultInstance;
- (PvpHistoryProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PvpHistoryProto_Builder*) builder;
+ (PvpHistoryProto_Builder*) builder;
+ (PvpHistoryProto_Builder*) builderWithPrototype:(PvpHistoryProto*) prototype;
- (PvpHistoryProto_Builder*) toBuilder;

+ (PvpHistoryProto*) parseFromData:(NSData*) data;
+ (PvpHistoryProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PvpHistoryProto*) parseFromInputStream:(NSInputStream*) input;
+ (PvpHistoryProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PvpHistoryProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PvpHistoryProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PvpHistoryProto_Builder : PBGeneratedMessageBuilder {
@private
  PvpHistoryProto* result;
}

- (PvpHistoryProto*) defaultInstance;

- (PvpHistoryProto_Builder*) clear;
- (PvpHistoryProto_Builder*) clone;

- (PvpHistoryProto*) build;
- (PvpHistoryProto*) buildPartial;

- (PvpHistoryProto_Builder*) mergeFrom:(PvpHistoryProto*) other;
- (PvpHistoryProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PvpHistoryProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasBattleEndTime;
- (int64_t) battleEndTime;
- (PvpHistoryProto_Builder*) setBattleEndTime:(int64_t) value;
- (PvpHistoryProto_Builder*) clearBattleEndTime;

- (BOOL) hasAttacker;
- (FullUserProto*) attacker;
- (PvpHistoryProto_Builder*) setAttacker:(FullUserProto*) value;
- (PvpHistoryProto_Builder*) setAttacker_Builder:(FullUserProto_Builder*) builderForValue;
- (PvpHistoryProto_Builder*) mergeAttacker:(FullUserProto*) value;
- (PvpHistoryProto_Builder*) clearAttacker;

- (NSMutableArray *)attackersMonstersList;
- (PvpMonsterProto*)attackersMonstersAtIndex:(NSUInteger)index;
- (PvpHistoryProto_Builder *)addAttackersMonsters:(PvpMonsterProto*)value;
- (PvpHistoryProto_Builder *)addAllAttackersMonsters:(NSArray *)array;
- (PvpHistoryProto_Builder *)clearAttackersMonsters;

- (BOOL) hasAttackerWon;
- (BOOL) attackerWon;
- (PvpHistoryProto_Builder*) setAttackerWon:(BOOL) value;
- (PvpHistoryProto_Builder*) clearAttackerWon;

- (BOOL) hasDefenderCashChange;
- (int32_t) defenderCashChange;
- (PvpHistoryProto_Builder*) setDefenderCashChange:(int32_t) value;
- (PvpHistoryProto_Builder*) clearDefenderCashChange;

- (BOOL) hasDefenderOilChange;
- (int32_t) defenderOilChange;
- (PvpHistoryProto_Builder*) setDefenderOilChange:(int32_t) value;
- (PvpHistoryProto_Builder*) clearDefenderOilChange;

- (BOOL) hasExactedRevenge;
- (BOOL) exactedRevenge;
- (PvpHistoryProto_Builder*) setExactedRevenge:(BOOL) value;
- (PvpHistoryProto_Builder*) clearExactedRevenge;

- (BOOL) hasProspectiveCashWinnings;
- (int32_t) prospectiveCashWinnings;
- (PvpHistoryProto_Builder*) setProspectiveCashWinnings:(int32_t) value;
- (PvpHistoryProto_Builder*) clearProspectiveCashWinnings;

- (BOOL) hasProspectiveOilWinnings;
- (int32_t) prospectiveOilWinnings;
- (PvpHistoryProto_Builder*) setProspectiveOilWinnings:(int32_t) value;
- (PvpHistoryProto_Builder*) clearProspectiveOilWinnings;

- (BOOL) hasAttackerBefore;
- (UserPvpLeagueProto*) attackerBefore;
- (PvpHistoryProto_Builder*) setAttackerBefore:(UserPvpLeagueProto*) value;
- (PvpHistoryProto_Builder*) setAttackerBefore_Builder:(UserPvpLeagueProto_Builder*) builderForValue;
- (PvpHistoryProto_Builder*) mergeAttackerBefore:(UserPvpLeagueProto*) value;
- (PvpHistoryProto_Builder*) clearAttackerBefore;

- (BOOL) hasAttackerAfter;
- (UserPvpLeagueProto*) attackerAfter;
- (PvpHistoryProto_Builder*) setAttackerAfter:(UserPvpLeagueProto*) value;
- (PvpHistoryProto_Builder*) setAttackerAfter_Builder:(UserPvpLeagueProto_Builder*) builderForValue;
- (PvpHistoryProto_Builder*) mergeAttackerAfter:(UserPvpLeagueProto*) value;
- (PvpHistoryProto_Builder*) clearAttackerAfter;

- (BOOL) hasDefenderBefore;
- (UserPvpLeagueProto*) defenderBefore;
- (PvpHistoryProto_Builder*) setDefenderBefore:(UserPvpLeagueProto*) value;
- (PvpHistoryProto_Builder*) setDefenderBefore_Builder:(UserPvpLeagueProto_Builder*) builderForValue;
- (PvpHistoryProto_Builder*) mergeDefenderBefore:(UserPvpLeagueProto*) value;
- (PvpHistoryProto_Builder*) clearDefenderBefore;

- (BOOL) hasDefenderAfter;
- (UserPvpLeagueProto*) defenderAfter;
- (PvpHistoryProto_Builder*) setDefenderAfter:(UserPvpLeagueProto*) value;
- (PvpHistoryProto_Builder*) setDefenderAfter_Builder:(UserPvpLeagueProto_Builder*) builderForValue;
- (PvpHistoryProto_Builder*) mergeDefenderAfter:(UserPvpLeagueProto*) value;
- (PvpHistoryProto_Builder*) clearDefenderAfter;

- (BOOL) hasDefender;
- (FullUserProto*) defender;
- (PvpHistoryProto_Builder*) setDefender:(FullUserProto*) value;
- (PvpHistoryProto_Builder*) setDefender_Builder:(FullUserProto_Builder*) builderForValue;
- (PvpHistoryProto_Builder*) mergeDefender:(FullUserProto*) value;
- (PvpHistoryProto_Builder*) clearDefender;

- (BOOL) hasAttackerCashChange;
- (int32_t) attackerCashChange;
- (PvpHistoryProto_Builder*) setAttackerCashChange:(int32_t) value;
- (PvpHistoryProto_Builder*) clearAttackerCashChange;

- (BOOL) hasAttackerOilChange;
- (int32_t) attackerOilChange;
- (PvpHistoryProto_Builder*) setAttackerOilChange:(int32_t) value;
- (PvpHistoryProto_Builder*) clearAttackerOilChange;

- (BOOL) hasClanAvenged;
- (BOOL) clanAvenged;
- (PvpHistoryProto_Builder*) setClanAvenged:(BOOL) value;
- (PvpHistoryProto_Builder*) clearClanAvenged;

- (BOOL) hasReplayId;
- (NSString*) replayId;
- (PvpHistoryProto_Builder*) setReplayId:(NSString*) value;
- (PvpHistoryProto_Builder*) clearReplayId;
@end

@interface PvpLeagueProto : PBGeneratedMessage {
@private
  BOOL hasLeagueId_:1;
  BOOL hasLeagueName_:1;
  BOOL hasImgPrefix_:1;
  BOOL hasDescription_:1;
  int32_t leagueId;
  NSString* leagueName;
  NSString* imgPrefix;
  NSString* description;
}
- (BOOL) hasLeagueId;
- (BOOL) hasLeagueName;
- (BOOL) hasImgPrefix;
- (BOOL) hasDescription;
@property (readonly) int32_t leagueId;
@property (readonly, strong) NSString* leagueName;
@property (readonly, strong) NSString* imgPrefix;
@property (readonly, strong) NSString* description;

+ (PvpLeagueProto*) defaultInstance;
- (PvpLeagueProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PvpLeagueProto_Builder*) builder;
+ (PvpLeagueProto_Builder*) builder;
+ (PvpLeagueProto_Builder*) builderWithPrototype:(PvpLeagueProto*) prototype;
- (PvpLeagueProto_Builder*) toBuilder;

+ (PvpLeagueProto*) parseFromData:(NSData*) data;
+ (PvpLeagueProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PvpLeagueProto*) parseFromInputStream:(NSInputStream*) input;
+ (PvpLeagueProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PvpLeagueProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PvpLeagueProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PvpLeagueProto_Builder : PBGeneratedMessageBuilder {
@private
  PvpLeagueProto* result;
}

- (PvpLeagueProto*) defaultInstance;

- (PvpLeagueProto_Builder*) clear;
- (PvpLeagueProto_Builder*) clone;

- (PvpLeagueProto*) build;
- (PvpLeagueProto*) buildPartial;

- (PvpLeagueProto_Builder*) mergeFrom:(PvpLeagueProto*) other;
- (PvpLeagueProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PvpLeagueProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasLeagueId;
- (int32_t) leagueId;
- (PvpLeagueProto_Builder*) setLeagueId:(int32_t) value;
- (PvpLeagueProto_Builder*) clearLeagueId;

- (BOOL) hasLeagueName;
- (NSString*) leagueName;
- (PvpLeagueProto_Builder*) setLeagueName:(NSString*) value;
- (PvpLeagueProto_Builder*) clearLeagueName;

- (BOOL) hasImgPrefix;
- (NSString*) imgPrefix;
- (PvpLeagueProto_Builder*) setImgPrefix:(NSString*) value;
- (PvpLeagueProto_Builder*) clearImgPrefix;

- (BOOL) hasDescription;
- (NSString*) description;
- (PvpLeagueProto_Builder*) setDescription:(NSString*) value;
- (PvpLeagueProto_Builder*) clearDescription;
@end

@interface PvpClanAvengeProto : PBGeneratedMessage {
@private
  BOOL hasBattleEndTime_:1;
  BOOL hasAvengeRequestTime_:1;
  BOOL hasClanAvengeUuid_:1;
  BOOL hasDefenderClanUuid_:1;
  BOOL hasAttacker_:1;
  BOOL hasDefender_:1;
  int64_t battleEndTime;
  int64_t avengeRequestTime;
  NSString* clanAvengeUuid;
  NSString* defenderClanUuid;
  MinimumUserProtoWithLevel* attacker;
  MinimumUserProto* defender;
  NSMutableArray * mutableUsersAvengingList;
}
- (BOOL) hasClanAvengeUuid;
- (BOOL) hasAttacker;
- (BOOL) hasDefender;
- (BOOL) hasBattleEndTime;
- (BOOL) hasAvengeRequestTime;
- (BOOL) hasDefenderClanUuid;
@property (readonly, strong) NSString* clanAvengeUuid;
@property (readonly, strong) NSArray * usersAvengingList;
@property (readonly, strong) MinimumUserProtoWithLevel* attacker;
@property (readonly, strong) MinimumUserProto* defender;
@property (readonly) int64_t battleEndTime;
@property (readonly) int64_t avengeRequestTime;
@property (readonly, strong) NSString* defenderClanUuid;
- (PvpUserClanAvengeProto*)usersAvengingAtIndex:(NSUInteger)index;

+ (PvpClanAvengeProto*) defaultInstance;
- (PvpClanAvengeProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PvpClanAvengeProto_Builder*) builder;
+ (PvpClanAvengeProto_Builder*) builder;
+ (PvpClanAvengeProto_Builder*) builderWithPrototype:(PvpClanAvengeProto*) prototype;
- (PvpClanAvengeProto_Builder*) toBuilder;

+ (PvpClanAvengeProto*) parseFromData:(NSData*) data;
+ (PvpClanAvengeProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PvpClanAvengeProto*) parseFromInputStream:(NSInputStream*) input;
+ (PvpClanAvengeProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PvpClanAvengeProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PvpClanAvengeProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PvpClanAvengeProto_Builder : PBGeneratedMessageBuilder {
@private
  PvpClanAvengeProto* result;
}

- (PvpClanAvengeProto*) defaultInstance;

- (PvpClanAvengeProto_Builder*) clear;
- (PvpClanAvengeProto_Builder*) clone;

- (PvpClanAvengeProto*) build;
- (PvpClanAvengeProto*) buildPartial;

- (PvpClanAvengeProto_Builder*) mergeFrom:(PvpClanAvengeProto*) other;
- (PvpClanAvengeProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PvpClanAvengeProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasClanAvengeUuid;
- (NSString*) clanAvengeUuid;
- (PvpClanAvengeProto_Builder*) setClanAvengeUuid:(NSString*) value;
- (PvpClanAvengeProto_Builder*) clearClanAvengeUuid;

- (NSMutableArray *)usersAvengingList;
- (PvpUserClanAvengeProto*)usersAvengingAtIndex:(NSUInteger)index;
- (PvpClanAvengeProto_Builder *)addUsersAvenging:(PvpUserClanAvengeProto*)value;
- (PvpClanAvengeProto_Builder *)addAllUsersAvenging:(NSArray *)array;
- (PvpClanAvengeProto_Builder *)clearUsersAvenging;

- (BOOL) hasAttacker;
- (MinimumUserProtoWithLevel*) attacker;
- (PvpClanAvengeProto_Builder*) setAttacker:(MinimumUserProtoWithLevel*) value;
- (PvpClanAvengeProto_Builder*) setAttacker_Builder:(MinimumUserProtoWithLevel_Builder*) builderForValue;
- (PvpClanAvengeProto_Builder*) mergeAttacker:(MinimumUserProtoWithLevel*) value;
- (PvpClanAvengeProto_Builder*) clearAttacker;

- (BOOL) hasDefender;
- (MinimumUserProto*) defender;
- (PvpClanAvengeProto_Builder*) setDefender:(MinimumUserProto*) value;
- (PvpClanAvengeProto_Builder*) setDefender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (PvpClanAvengeProto_Builder*) mergeDefender:(MinimumUserProto*) value;
- (PvpClanAvengeProto_Builder*) clearDefender;

- (BOOL) hasBattleEndTime;
- (int64_t) battleEndTime;
- (PvpClanAvengeProto_Builder*) setBattleEndTime:(int64_t) value;
- (PvpClanAvengeProto_Builder*) clearBattleEndTime;

- (BOOL) hasAvengeRequestTime;
- (int64_t) avengeRequestTime;
- (PvpClanAvengeProto_Builder*) setAvengeRequestTime:(int64_t) value;
- (PvpClanAvengeProto_Builder*) clearAvengeRequestTime;

- (BOOL) hasDefenderClanUuid;
- (NSString*) defenderClanUuid;
- (PvpClanAvengeProto_Builder*) setDefenderClanUuid:(NSString*) value;
- (PvpClanAvengeProto_Builder*) clearDefenderClanUuid;
@end

@interface PvpUserClanAvengeProto : PBGeneratedMessage {
@private
  BOOL hasAvengeTime_:1;
  BOOL hasUserUuid_:1;
  BOOL hasClanUuid_:1;
  BOOL hasClanAvengeUuid_:1;
  int64_t avengeTime;
  NSString* userUuid;
  NSString* clanUuid;
  NSString* clanAvengeUuid;
}
- (BOOL) hasUserUuid;
- (BOOL) hasClanUuid;
- (BOOL) hasClanAvengeUuid;
- (BOOL) hasAvengeTime;
@property (readonly, strong) NSString* userUuid;
@property (readonly, strong) NSString* clanUuid;
@property (readonly, strong) NSString* clanAvengeUuid;
@property (readonly) int64_t avengeTime;

+ (PvpUserClanAvengeProto*) defaultInstance;
- (PvpUserClanAvengeProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PvpUserClanAvengeProto_Builder*) builder;
+ (PvpUserClanAvengeProto_Builder*) builder;
+ (PvpUserClanAvengeProto_Builder*) builderWithPrototype:(PvpUserClanAvengeProto*) prototype;
- (PvpUserClanAvengeProto_Builder*) toBuilder;

+ (PvpUserClanAvengeProto*) parseFromData:(NSData*) data;
+ (PvpUserClanAvengeProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PvpUserClanAvengeProto*) parseFromInputStream:(NSInputStream*) input;
+ (PvpUserClanAvengeProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PvpUserClanAvengeProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PvpUserClanAvengeProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PvpUserClanAvengeProto_Builder : PBGeneratedMessageBuilder {
@private
  PvpUserClanAvengeProto* result;
}

- (PvpUserClanAvengeProto*) defaultInstance;

- (PvpUserClanAvengeProto_Builder*) clear;
- (PvpUserClanAvengeProto_Builder*) clone;

- (PvpUserClanAvengeProto*) build;
- (PvpUserClanAvengeProto*) buildPartial;

- (PvpUserClanAvengeProto_Builder*) mergeFrom:(PvpUserClanAvengeProto*) other;
- (PvpUserClanAvengeProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PvpUserClanAvengeProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasUserUuid;
- (NSString*) userUuid;
- (PvpUserClanAvengeProto_Builder*) setUserUuid:(NSString*) value;
- (PvpUserClanAvengeProto_Builder*) clearUserUuid;

- (BOOL) hasClanUuid;
- (NSString*) clanUuid;
- (PvpUserClanAvengeProto_Builder*) setClanUuid:(NSString*) value;
- (PvpUserClanAvengeProto_Builder*) clearClanUuid;

- (BOOL) hasClanAvengeUuid;
- (NSString*) clanAvengeUuid;
- (PvpUserClanAvengeProto_Builder*) setClanAvengeUuid:(NSString*) value;
- (PvpUserClanAvengeProto_Builder*) clearClanAvengeUuid;

- (BOOL) hasAvengeTime;
- (int64_t) avengeTime;
- (PvpUserClanAvengeProto_Builder*) setAvengeTime:(int64_t) value;
- (PvpUserClanAvengeProto_Builder*) clearAvengeTime;
@end

@interface BattleReplayProto : PBGeneratedMessage {
@private
  BOOL hasCreateTime_:1;
  BOOL hasReplayUuid_:1;
  BOOL hasCreatorUuid_:1;
  BOOL hasReplay_:1;
  int32_t createTime;
  NSString* replayUuid;
  NSString* creatorUuid;
  NSData* replay;
}
- (BOOL) hasReplayUuid;
- (BOOL) hasCreatorUuid;
- (BOOL) hasReplay;
- (BOOL) hasCreateTime;
@property (readonly, strong) NSString* replayUuid;
@property (readonly, strong) NSString* creatorUuid;
@property (readonly, strong) NSData* replay;
@property (readonly) int32_t createTime;

+ (BattleReplayProto*) defaultInstance;
- (BattleReplayProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (BattleReplayProto_Builder*) builder;
+ (BattleReplayProto_Builder*) builder;
+ (BattleReplayProto_Builder*) builderWithPrototype:(BattleReplayProto*) prototype;
- (BattleReplayProto_Builder*) toBuilder;

+ (BattleReplayProto*) parseFromData:(NSData*) data;
+ (BattleReplayProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BattleReplayProto*) parseFromInputStream:(NSInputStream*) input;
+ (BattleReplayProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BattleReplayProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (BattleReplayProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface BattleReplayProto_Builder : PBGeneratedMessageBuilder {
@private
  BattleReplayProto* result;
}

- (BattleReplayProto*) defaultInstance;

- (BattleReplayProto_Builder*) clear;
- (BattleReplayProto_Builder*) clone;

- (BattleReplayProto*) build;
- (BattleReplayProto*) buildPartial;

- (BattleReplayProto_Builder*) mergeFrom:(BattleReplayProto*) other;
- (BattleReplayProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (BattleReplayProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasReplayUuid;
- (NSString*) replayUuid;
- (BattleReplayProto_Builder*) setReplayUuid:(NSString*) value;
- (BattleReplayProto_Builder*) clearReplayUuid;

- (BOOL) hasCreatorUuid;
- (NSString*) creatorUuid;
- (BattleReplayProto_Builder*) setCreatorUuid:(NSString*) value;
- (BattleReplayProto_Builder*) clearCreatorUuid;

- (BOOL) hasReplay;
- (NSData*) replay;
- (BattleReplayProto_Builder*) setReplay:(NSData*) value;
- (BattleReplayProto_Builder*) clearReplay;

- (BOOL) hasCreateTime;
- (int32_t) createTime;
- (BattleReplayProto_Builder*) setCreateTime:(int32_t) value;
- (BattleReplayProto_Builder*) clearCreateTime;
@end


// @@protoc_insertion_point(global_scope)
