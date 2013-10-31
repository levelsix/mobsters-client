// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

@class FullUserProto;
@class FullUserProto_Builder;
@class MinimumClanProto;
@class MinimumClanProto_Builder;
@class MinimumUserProto;
@class MinimumUserProtoWithLevel;
@class MinimumUserProtoWithLevel_Builder;
@class MinimumUserProto_Builder;
@class StaticLevelInfoProto;
@class StaticLevelInfoProto_Builder;

@interface UserRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface MinimumClanProto : PBGeneratedMessage {
@private
  BOOL hasRequestToJoinRequired_:1;
  BOOL hasCreateTime_:1;
  BOOL hasClanId_:1;
  BOOL hasOwnerId_:1;
  BOOL hasName_:1;
  BOOL hasDescription_:1;
  BOOL hasTag_:1;
  BOOL requestToJoinRequired_:1;
  int64_t createTime;
  int32_t clanId;
  int32_t ownerId;
  NSString* name;
  NSString* description;
  NSString* tag;
}
- (BOOL) hasClanId;
- (BOOL) hasName;
- (BOOL) hasOwnerId;
- (BOOL) hasCreateTime;
- (BOOL) hasDescription;
- (BOOL) hasTag;
- (BOOL) hasRequestToJoinRequired;
@property (readonly) int32_t clanId;
@property (readonly, retain) NSString* name;
@property (readonly) int32_t ownerId;
@property (readonly) int64_t createTime;
@property (readonly, retain) NSString* description;
@property (readonly, retain) NSString* tag;
- (BOOL) requestToJoinRequired;

+ (MinimumClanProto*) defaultInstance;
- (MinimumClanProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (MinimumClanProto_Builder*) builder;
+ (MinimumClanProto_Builder*) builder;
+ (MinimumClanProto_Builder*) builderWithPrototype:(MinimumClanProto*) prototype;

+ (MinimumClanProto*) parseFromData:(NSData*) data;
+ (MinimumClanProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (MinimumClanProto*) parseFromInputStream:(NSInputStream*) input;
+ (MinimumClanProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (MinimumClanProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (MinimumClanProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface MinimumClanProto_Builder : PBGeneratedMessage_Builder {
@private
  MinimumClanProto* result;
}

- (MinimumClanProto*) defaultInstance;

- (MinimumClanProto_Builder*) clear;
- (MinimumClanProto_Builder*) clone;

- (MinimumClanProto*) build;
- (MinimumClanProto*) buildPartial;

- (MinimumClanProto_Builder*) mergeFrom:(MinimumClanProto*) other;
- (MinimumClanProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (MinimumClanProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasClanId;
- (int32_t) clanId;
- (MinimumClanProto_Builder*) setClanId:(int32_t) value;
- (MinimumClanProto_Builder*) clearClanId;

- (BOOL) hasName;
- (NSString*) name;
- (MinimumClanProto_Builder*) setName:(NSString*) value;
- (MinimumClanProto_Builder*) clearName;

- (BOOL) hasOwnerId;
- (int32_t) ownerId;
- (MinimumClanProto_Builder*) setOwnerId:(int32_t) value;
- (MinimumClanProto_Builder*) clearOwnerId;

- (BOOL) hasCreateTime;
- (int64_t) createTime;
- (MinimumClanProto_Builder*) setCreateTime:(int64_t) value;
- (MinimumClanProto_Builder*) clearCreateTime;

- (BOOL) hasDescription;
- (NSString*) description;
- (MinimumClanProto_Builder*) setDescription:(NSString*) value;
- (MinimumClanProto_Builder*) clearDescription;

- (BOOL) hasTag;
- (NSString*) tag;
- (MinimumClanProto_Builder*) setTag:(NSString*) value;
- (MinimumClanProto_Builder*) clearTag;

- (BOOL) hasRequestToJoinRequired;
- (BOOL) requestToJoinRequired;
- (MinimumClanProto_Builder*) setRequestToJoinRequired:(BOOL) value;
- (MinimumClanProto_Builder*) clearRequestToJoinRequired;
@end

@interface MinimumUserProto : PBGeneratedMessage {
@private
  BOOL hasUserId_:1;
  BOOL hasName_:1;
  BOOL hasClan_:1;
  int32_t userId;
  NSString* name;
  MinimumClanProto* clan;
}
- (BOOL) hasUserId;
- (BOOL) hasName;
- (BOOL) hasClan;
@property (readonly) int32_t userId;
@property (readonly, retain) NSString* name;
@property (readonly, retain) MinimumClanProto* clan;

+ (MinimumUserProto*) defaultInstance;
- (MinimumUserProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (MinimumUserProto_Builder*) builder;
+ (MinimumUserProto_Builder*) builder;
+ (MinimumUserProto_Builder*) builderWithPrototype:(MinimumUserProto*) prototype;

+ (MinimumUserProto*) parseFromData:(NSData*) data;
+ (MinimumUserProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (MinimumUserProto*) parseFromInputStream:(NSInputStream*) input;
+ (MinimumUserProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (MinimumUserProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (MinimumUserProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface MinimumUserProto_Builder : PBGeneratedMessage_Builder {
@private
  MinimumUserProto* result;
}

- (MinimumUserProto*) defaultInstance;

- (MinimumUserProto_Builder*) clear;
- (MinimumUserProto_Builder*) clone;

- (MinimumUserProto*) build;
- (MinimumUserProto*) buildPartial;

- (MinimumUserProto_Builder*) mergeFrom:(MinimumUserProto*) other;
- (MinimumUserProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (MinimumUserProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasUserId;
- (int32_t) userId;
- (MinimumUserProto_Builder*) setUserId:(int32_t) value;
- (MinimumUserProto_Builder*) clearUserId;

- (BOOL) hasName;
- (NSString*) name;
- (MinimumUserProto_Builder*) setName:(NSString*) value;
- (MinimumUserProto_Builder*) clearName;

- (BOOL) hasClan;
- (MinimumClanProto*) clan;
- (MinimumUserProto_Builder*) setClan:(MinimumClanProto*) value;
- (MinimumUserProto_Builder*) setClanBuilder:(MinimumClanProto_Builder*) builderForValue;
- (MinimumUserProto_Builder*) mergeClan:(MinimumClanProto*) value;
- (MinimumUserProto_Builder*) clearClan;
@end

@interface MinimumUserProtoWithLevel : PBGeneratedMessage {
@private
  BOOL hasLevel_:1;
  BOOL hasMinUserProto_:1;
  int32_t level;
  MinimumUserProto* minUserProto;
}
- (BOOL) hasMinUserProto;
- (BOOL) hasLevel;
@property (readonly, retain) MinimumUserProto* minUserProto;
@property (readonly) int32_t level;

+ (MinimumUserProtoWithLevel*) defaultInstance;
- (MinimumUserProtoWithLevel*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (MinimumUserProtoWithLevel_Builder*) builder;
+ (MinimumUserProtoWithLevel_Builder*) builder;
+ (MinimumUserProtoWithLevel_Builder*) builderWithPrototype:(MinimumUserProtoWithLevel*) prototype;

+ (MinimumUserProtoWithLevel*) parseFromData:(NSData*) data;
+ (MinimumUserProtoWithLevel*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (MinimumUserProtoWithLevel*) parseFromInputStream:(NSInputStream*) input;
+ (MinimumUserProtoWithLevel*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (MinimumUserProtoWithLevel*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (MinimumUserProtoWithLevel*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface MinimumUserProtoWithLevel_Builder : PBGeneratedMessage_Builder {
@private
  MinimumUserProtoWithLevel* result;
}

- (MinimumUserProtoWithLevel*) defaultInstance;

- (MinimumUserProtoWithLevel_Builder*) clear;
- (MinimumUserProtoWithLevel_Builder*) clone;

- (MinimumUserProtoWithLevel*) build;
- (MinimumUserProtoWithLevel*) buildPartial;

- (MinimumUserProtoWithLevel_Builder*) mergeFrom:(MinimumUserProtoWithLevel*) other;
- (MinimumUserProtoWithLevel_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (MinimumUserProtoWithLevel_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasMinUserProto;
- (MinimumUserProto*) minUserProto;
- (MinimumUserProtoWithLevel_Builder*) setMinUserProto:(MinimumUserProto*) value;
- (MinimumUserProtoWithLevel_Builder*) setMinUserProtoBuilder:(MinimumUserProto_Builder*) builderForValue;
- (MinimumUserProtoWithLevel_Builder*) mergeMinUserProto:(MinimumUserProto*) value;
- (MinimumUserProtoWithLevel_Builder*) clearMinUserProto;

- (BOOL) hasLevel;
- (int32_t) level;
- (MinimumUserProtoWithLevel_Builder*) setLevel:(int32_t) value;
- (MinimumUserProtoWithLevel_Builder*) clearLevel;
@end

@interface FullUserProto : PBGeneratedMessage {
@private
  BOOL hasHasReceivedfbReward_:1;
  BOOL hasHasActiveShield_:1;
  BOOL hasIsAdmin_:1;
  BOOL hasIsFake_:1;
  BOOL hasShieldEndTime_:1;
  BOOL hasLastLogoutTime_:1;
  BOOL hasLastLoginTime_:1;
  BOOL hasLastTimeQueued_:1;
  BOOL hasLastBattleNotificationTime_:1;
  BOOL hasCreateTime_:1;
  BOOL hasLastWallPostNotificationTime_:1;
  BOOL hasDefensesWon_:1;
  BOOL hasAttacksWon_:1;
  BOOL hasAttacksLost_:1;
  BOOL hasElo_:1;
  BOOL hasDefensesLost_:1;
  BOOL hasNumBadges_:1;
  BOOL hasApsalarId_:1;
  BOOL hasNumConsecutiveDaysPlayed_:1;
  BOOL hasNumBeginnerSalesPurchased_:1;
  BOOL hasUserId_:1;
  BOOL hasLevel_:1;
  BOOL hasGems_:1;
  BOOL hasCash_:1;
  BOOL hasExperience_:1;
  BOOL hasTasksCompleted_:1;
  BOOL hasBattlesWon_:1;
  BOOL hasBattlesLost_:1;
  BOOL hasFlees_:1;
  BOOL hasNumReferrals_:1;
  BOOL hasNumCoinsRetrievedFromStructs_:1;
  BOOL hasNumAdditionalMonsterSlots_:1;
  BOOL hasReferralCode_:1;
  BOOL hasUdid_:1;
  BOOL hasDeviceToken_:1;
  BOOL hasRank_:1;
  BOOL hasName_:1;
  BOOL hasKabamNaid_:1;
  BOOL hasClan_:1;
  BOOL hasReceivedfbReward_:1;
  BOOL hasActiveShield_:1;
  BOOL isAdmin_:1;
  BOOL isFake_:1;
  int64_t shieldEndTime;
  int64_t lastLogoutTime;
  int64_t lastLoginTime;
  int64_t lastTimeQueued;
  int64_t lastBattleNotificationTime;
  int64_t createTime;
  int64_t lastWallPostNotificationTime;
  int32_t defensesWon;
  int32_t attacksWon;
  int32_t attacksLost;
  int32_t elo;
  int32_t defensesLost;
  int32_t numBadges;
  int32_t apsalarId;
  int32_t numConsecutiveDaysPlayed;
  int32_t numBeginnerSalesPurchased;
  int32_t userId;
  int32_t level;
  int32_t gems;
  int32_t cash;
  int32_t experience;
  int32_t tasksCompleted;
  int32_t battlesWon;
  int32_t battlesLost;
  int32_t flees;
  int32_t numReferrals;
  int32_t numCoinsRetrievedFromStructs;
  int32_t numAdditionalMonsterSlots;
  NSString* referralCode;
  NSString* udid;
  NSString* deviceToken;
  NSString* rank;
  NSString* name;
  NSString* kabamNaid;
  MinimumClanProto* clan;
}
- (BOOL) hasUserId;
- (BOOL) hasName;
- (BOOL) hasLevel;
- (BOOL) hasGems;
- (BOOL) hasCash;
- (BOOL) hasExperience;
- (BOOL) hasTasksCompleted;
- (BOOL) hasBattlesWon;
- (BOOL) hasBattlesLost;
- (BOOL) hasFlees;
- (BOOL) hasReferralCode;
- (BOOL) hasNumReferrals;
- (BOOL) hasLastLoginTime;
- (BOOL) hasLastLogoutTime;
- (BOOL) hasIsFake;
- (BOOL) hasIsAdmin;
- (BOOL) hasNumCoinsRetrievedFromStructs;
- (BOOL) hasClan;
- (BOOL) hasHasReceivedfbReward;
- (BOOL) hasNumAdditionalMonsterSlots;
- (BOOL) hasNumBeginnerSalesPurchased;
- (BOOL) hasHasActiveShield;
- (BOOL) hasShieldEndTime;
- (BOOL) hasElo;
- (BOOL) hasRank;
- (BOOL) hasLastTimeQueued;
- (BOOL) hasAttacksWon;
- (BOOL) hasDefensesWon;
- (BOOL) hasAttacksLost;
- (BOOL) hasDefensesLost;
- (BOOL) hasUdid;
- (BOOL) hasDeviceToken;
- (BOOL) hasLastBattleNotificationTime;
- (BOOL) hasNumBadges;
- (BOOL) hasCreateTime;
- (BOOL) hasApsalarId;
- (BOOL) hasNumConsecutiveDaysPlayed;
- (BOOL) hasLastWallPostNotificationTime;
- (BOOL) hasKabamNaid;
@property (readonly) int32_t userId;
@property (readonly, retain) NSString* name;
@property (readonly) int32_t level;
@property (readonly) int32_t gems;
@property (readonly) int32_t cash;
@property (readonly) int32_t experience;
@property (readonly) int32_t tasksCompleted;
@property (readonly) int32_t battlesWon;
@property (readonly) int32_t battlesLost;
@property (readonly) int32_t flees;
@property (readonly, retain) NSString* referralCode;
@property (readonly) int32_t numReferrals;
@property (readonly) int64_t lastLoginTime;
@property (readonly) int64_t lastLogoutTime;
- (BOOL) isFake;
- (BOOL) isAdmin;
@property (readonly) int32_t numCoinsRetrievedFromStructs;
@property (readonly, retain) MinimumClanProto* clan;
- (BOOL) hasReceivedfbReward;
@property (readonly) int32_t numAdditionalMonsterSlots;
@property (readonly) int32_t numBeginnerSalesPurchased;
- (BOOL) hasActiveShield;
@property (readonly) int64_t shieldEndTime;
@property (readonly) int32_t elo;
@property (readonly, retain) NSString* rank;
@property (readonly) int64_t lastTimeQueued;
@property (readonly) int32_t attacksWon;
@property (readonly) int32_t defensesWon;
@property (readonly) int32_t attacksLost;
@property (readonly) int32_t defensesLost;
@property (readonly, retain) NSString* udid;
@property (readonly, retain) NSString* deviceToken;
@property (readonly) int64_t lastBattleNotificationTime;
@property (readonly) int32_t numBadges;
@property (readonly) int64_t createTime;
@property (readonly) int32_t apsalarId;
@property (readonly) int32_t numConsecutiveDaysPlayed;
@property (readonly) int64_t lastWallPostNotificationTime;
@property (readonly, retain) NSString* kabamNaid;

+ (FullUserProto*) defaultInstance;
- (FullUserProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (FullUserProto_Builder*) builder;
+ (FullUserProto_Builder*) builder;
+ (FullUserProto_Builder*) builderWithPrototype:(FullUserProto*) prototype;

+ (FullUserProto*) parseFromData:(NSData*) data;
+ (FullUserProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FullUserProto*) parseFromInputStream:(NSInputStream*) input;
+ (FullUserProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FullUserProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (FullUserProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface FullUserProto_Builder : PBGeneratedMessage_Builder {
@private
  FullUserProto* result;
}

- (FullUserProto*) defaultInstance;

- (FullUserProto_Builder*) clear;
- (FullUserProto_Builder*) clone;

- (FullUserProto*) build;
- (FullUserProto*) buildPartial;

- (FullUserProto_Builder*) mergeFrom:(FullUserProto*) other;
- (FullUserProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (FullUserProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasUserId;
- (int32_t) userId;
- (FullUserProto_Builder*) setUserId:(int32_t) value;
- (FullUserProto_Builder*) clearUserId;

- (BOOL) hasName;
- (NSString*) name;
- (FullUserProto_Builder*) setName:(NSString*) value;
- (FullUserProto_Builder*) clearName;

- (BOOL) hasLevel;
- (int32_t) level;
- (FullUserProto_Builder*) setLevel:(int32_t) value;
- (FullUserProto_Builder*) clearLevel;

- (BOOL) hasGems;
- (int32_t) gems;
- (FullUserProto_Builder*) setGems:(int32_t) value;
- (FullUserProto_Builder*) clearGems;

- (BOOL) hasCash;
- (int32_t) cash;
- (FullUserProto_Builder*) setCash:(int32_t) value;
- (FullUserProto_Builder*) clearCash;

- (BOOL) hasExperience;
- (int32_t) experience;
- (FullUserProto_Builder*) setExperience:(int32_t) value;
- (FullUserProto_Builder*) clearExperience;

- (BOOL) hasTasksCompleted;
- (int32_t) tasksCompleted;
- (FullUserProto_Builder*) setTasksCompleted:(int32_t) value;
- (FullUserProto_Builder*) clearTasksCompleted;

- (BOOL) hasBattlesWon;
- (int32_t) battlesWon;
- (FullUserProto_Builder*) setBattlesWon:(int32_t) value;
- (FullUserProto_Builder*) clearBattlesWon;

- (BOOL) hasBattlesLost;
- (int32_t) battlesLost;
- (FullUserProto_Builder*) setBattlesLost:(int32_t) value;
- (FullUserProto_Builder*) clearBattlesLost;

- (BOOL) hasFlees;
- (int32_t) flees;
- (FullUserProto_Builder*) setFlees:(int32_t) value;
- (FullUserProto_Builder*) clearFlees;

- (BOOL) hasReferralCode;
- (NSString*) referralCode;
- (FullUserProto_Builder*) setReferralCode:(NSString*) value;
- (FullUserProto_Builder*) clearReferralCode;

- (BOOL) hasNumReferrals;
- (int32_t) numReferrals;
- (FullUserProto_Builder*) setNumReferrals:(int32_t) value;
- (FullUserProto_Builder*) clearNumReferrals;

- (BOOL) hasLastLoginTime;
- (int64_t) lastLoginTime;
- (FullUserProto_Builder*) setLastLoginTime:(int64_t) value;
- (FullUserProto_Builder*) clearLastLoginTime;

- (BOOL) hasLastLogoutTime;
- (int64_t) lastLogoutTime;
- (FullUserProto_Builder*) setLastLogoutTime:(int64_t) value;
- (FullUserProto_Builder*) clearLastLogoutTime;

- (BOOL) hasIsFake;
- (BOOL) isFake;
- (FullUserProto_Builder*) setIsFake:(BOOL) value;
- (FullUserProto_Builder*) clearIsFake;

- (BOOL) hasIsAdmin;
- (BOOL) isAdmin;
- (FullUserProto_Builder*) setIsAdmin:(BOOL) value;
- (FullUserProto_Builder*) clearIsAdmin;

- (BOOL) hasNumCoinsRetrievedFromStructs;
- (int32_t) numCoinsRetrievedFromStructs;
- (FullUserProto_Builder*) setNumCoinsRetrievedFromStructs:(int32_t) value;
- (FullUserProto_Builder*) clearNumCoinsRetrievedFromStructs;

- (BOOL) hasClan;
- (MinimumClanProto*) clan;
- (FullUserProto_Builder*) setClan:(MinimumClanProto*) value;
- (FullUserProto_Builder*) setClanBuilder:(MinimumClanProto_Builder*) builderForValue;
- (FullUserProto_Builder*) mergeClan:(MinimumClanProto*) value;
- (FullUserProto_Builder*) clearClan;

- (BOOL) hasHasReceivedfbReward;
- (BOOL) hasReceivedfbReward;
- (FullUserProto_Builder*) setHasReceivedfbReward:(BOOL) value;
- (FullUserProto_Builder*) clearHasReceivedfbReward;

- (BOOL) hasNumAdditionalMonsterSlots;
- (int32_t) numAdditionalMonsterSlots;
- (FullUserProto_Builder*) setNumAdditionalMonsterSlots:(int32_t) value;
- (FullUserProto_Builder*) clearNumAdditionalMonsterSlots;

- (BOOL) hasNumBeginnerSalesPurchased;
- (int32_t) numBeginnerSalesPurchased;
- (FullUserProto_Builder*) setNumBeginnerSalesPurchased:(int32_t) value;
- (FullUserProto_Builder*) clearNumBeginnerSalesPurchased;

- (BOOL) hasHasActiveShield;
- (BOOL) hasActiveShield;
- (FullUserProto_Builder*) setHasActiveShield:(BOOL) value;
- (FullUserProto_Builder*) clearHasActiveShield;

- (BOOL) hasShieldEndTime;
- (int64_t) shieldEndTime;
- (FullUserProto_Builder*) setShieldEndTime:(int64_t) value;
- (FullUserProto_Builder*) clearShieldEndTime;

- (BOOL) hasElo;
- (int32_t) elo;
- (FullUserProto_Builder*) setElo:(int32_t) value;
- (FullUserProto_Builder*) clearElo;

- (BOOL) hasRank;
- (NSString*) rank;
- (FullUserProto_Builder*) setRank:(NSString*) value;
- (FullUserProto_Builder*) clearRank;

- (BOOL) hasLastTimeQueued;
- (int64_t) lastTimeQueued;
- (FullUserProto_Builder*) setLastTimeQueued:(int64_t) value;
- (FullUserProto_Builder*) clearLastTimeQueued;

- (BOOL) hasAttacksWon;
- (int32_t) attacksWon;
- (FullUserProto_Builder*) setAttacksWon:(int32_t) value;
- (FullUserProto_Builder*) clearAttacksWon;

- (BOOL) hasDefensesWon;
- (int32_t) defensesWon;
- (FullUserProto_Builder*) setDefensesWon:(int32_t) value;
- (FullUserProto_Builder*) clearDefensesWon;

- (BOOL) hasAttacksLost;
- (int32_t) attacksLost;
- (FullUserProto_Builder*) setAttacksLost:(int32_t) value;
- (FullUserProto_Builder*) clearAttacksLost;

- (BOOL) hasDefensesLost;
- (int32_t) defensesLost;
- (FullUserProto_Builder*) setDefensesLost:(int32_t) value;
- (FullUserProto_Builder*) clearDefensesLost;

- (BOOL) hasUdid;
- (NSString*) udid;
- (FullUserProto_Builder*) setUdid:(NSString*) value;
- (FullUserProto_Builder*) clearUdid;

- (BOOL) hasDeviceToken;
- (NSString*) deviceToken;
- (FullUserProto_Builder*) setDeviceToken:(NSString*) value;
- (FullUserProto_Builder*) clearDeviceToken;

- (BOOL) hasLastBattleNotificationTime;
- (int64_t) lastBattleNotificationTime;
- (FullUserProto_Builder*) setLastBattleNotificationTime:(int64_t) value;
- (FullUserProto_Builder*) clearLastBattleNotificationTime;

- (BOOL) hasNumBadges;
- (int32_t) numBadges;
- (FullUserProto_Builder*) setNumBadges:(int32_t) value;
- (FullUserProto_Builder*) clearNumBadges;

- (BOOL) hasCreateTime;
- (int64_t) createTime;
- (FullUserProto_Builder*) setCreateTime:(int64_t) value;
- (FullUserProto_Builder*) clearCreateTime;

- (BOOL) hasApsalarId;
- (int32_t) apsalarId;
- (FullUserProto_Builder*) setApsalarId:(int32_t) value;
- (FullUserProto_Builder*) clearApsalarId;

- (BOOL) hasNumConsecutiveDaysPlayed;
- (int32_t) numConsecutiveDaysPlayed;
- (FullUserProto_Builder*) setNumConsecutiveDaysPlayed:(int32_t) value;
- (FullUserProto_Builder*) clearNumConsecutiveDaysPlayed;

- (BOOL) hasLastWallPostNotificationTime;
- (int64_t) lastWallPostNotificationTime;
- (FullUserProto_Builder*) setLastWallPostNotificationTime:(int64_t) value;
- (FullUserProto_Builder*) clearLastWallPostNotificationTime;

- (BOOL) hasKabamNaid;
- (NSString*) kabamNaid;
- (FullUserProto_Builder*) setKabamNaid:(NSString*) value;
- (FullUserProto_Builder*) clearKabamNaid;
@end

@interface StaticLevelInfoProto : PBGeneratedMessage {
@private
  BOOL hasLevel_:1;
  BOOL hasRequiredExperience_:1;
  BOOL hasMaxCash_:1;
  int32_t level;
  int32_t requiredExperience;
  int32_t maxCash;
}
- (BOOL) hasLevel;
- (BOOL) hasRequiredExperience;
- (BOOL) hasMaxCash;
@property (readonly) int32_t level;
@property (readonly) int32_t requiredExperience;
@property (readonly) int32_t maxCash;

+ (StaticLevelInfoProto*) defaultInstance;
- (StaticLevelInfoProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (StaticLevelInfoProto_Builder*) builder;
+ (StaticLevelInfoProto_Builder*) builder;
+ (StaticLevelInfoProto_Builder*) builderWithPrototype:(StaticLevelInfoProto*) prototype;

+ (StaticLevelInfoProto*) parseFromData:(NSData*) data;
+ (StaticLevelInfoProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (StaticLevelInfoProto*) parseFromInputStream:(NSInputStream*) input;
+ (StaticLevelInfoProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (StaticLevelInfoProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (StaticLevelInfoProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface StaticLevelInfoProto_Builder : PBGeneratedMessage_Builder {
@private
  StaticLevelInfoProto* result;
}

- (StaticLevelInfoProto*) defaultInstance;

- (StaticLevelInfoProto_Builder*) clear;
- (StaticLevelInfoProto_Builder*) clone;

- (StaticLevelInfoProto*) build;
- (StaticLevelInfoProto*) buildPartial;

- (StaticLevelInfoProto_Builder*) mergeFrom:(StaticLevelInfoProto*) other;
- (StaticLevelInfoProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (StaticLevelInfoProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasLevel;
- (int32_t) level;
- (StaticLevelInfoProto_Builder*) setLevel:(int32_t) value;
- (StaticLevelInfoProto_Builder*) clearLevel;

- (BOOL) hasRequiredExperience;
- (int32_t) requiredExperience;
- (StaticLevelInfoProto_Builder*) setRequiredExperience:(int32_t) value;
- (StaticLevelInfoProto_Builder*) clearRequiredExperience;

- (BOOL) hasMaxCash;
- (int32_t) maxCash;
- (StaticLevelInfoProto_Builder*) setMaxCash:(int32_t) value;
- (StaticLevelInfoProto_Builder*) clearMaxCash;
@end

