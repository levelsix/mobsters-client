// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "MonsterStuff.pb.h"
#import "Structure.pb.h"
#import "User.pb.h"

@class CoordinateProto;
@class CoordinateProto_Builder;
@class FullUserMonsterProto;
@class FullUserMonsterProto_Builder;
@class FullUserProto;
@class FullUserProto_Builder;
@class FullUserStructureProto;
@class FullUserStructureProto_Builder;
@class HospitalProto;
@class HospitalProto_Builder;
@class LabProto;
@class LabProto_Builder;
@class LevelUpRequestProto;
@class LevelUpRequestProto_Builder;
@class LevelUpResponseProto;
@class LevelUpResponseProto_Builder;
@class LogoutRequestProto;
@class LogoutRequestProto_Builder;
@class MinimumClanProto;
@class MinimumClanProto_Builder;
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
@class MonsterLevelInfoProto;
@class MonsterLevelInfoProto_Builder;
@class MonsterProto;
@class MonsterProto_Builder;
@class ResidenceProto;
@class ResidenceProto_Builder;
@class ResourceGeneratorProto;
@class ResourceGeneratorProto_Builder;
@class ResourceStorageProto;
@class ResourceStorageProto_Builder;
@class RetrieveUsersForUserIdsRequestProto;
@class RetrieveUsersForUserIdsRequestProto_Builder;
@class RetrieveUsersForUserIdsResponseProto;
@class RetrieveUsersForUserIdsResponseProto_Builder;
@class SetFacebookIdRequestProto;
@class SetFacebookIdRequestProto_Builder;
@class SetFacebookIdResponseProto;
@class SetFacebookIdResponseProto_Builder;
@class StaticUserLevelInfoProto;
@class StaticUserLevelInfoProto_Builder;
@class StructureInfoProto;
@class StructureInfoProto_Builder;
@class TownHallProto;
@class TownHallProto_Builder;
@class UpdateClientUserResponseProto;
@class UpdateClientUserResponseProto_Builder;
@class UserCreateRequestProto;
@class UserCreateRequestProto_Builder;
@class UserCreateResponseProto;
@class UserCreateResponseProto_Builder;
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
typedef enum {
  UserCreateResponseProto_UserCreateStatusSuccess = 1,
  UserCreateResponseProto_UserCreateStatusFailInvalidName = 2,
  UserCreateResponseProto_UserCreateStatusFailUserWithUdidAlreadyExists = 3,
  UserCreateResponseProto_UserCreateStatusFailInvalidReferCode = 4,
  UserCreateResponseProto_UserCreateStatusFailUserWithFacebookIdExists = 5,
  UserCreateResponseProto_UserCreateStatusFailOther = 6,
} UserCreateResponseProto_UserCreateStatus;

BOOL UserCreateResponseProto_UserCreateStatusIsValidValue(UserCreateResponseProto_UserCreateStatus value);

typedef enum {
  LevelUpResponseProto_LevelUpStatusSuccess = 1,
  LevelUpResponseProto_LevelUpStatusNotEnoughExpToNextLevel = 2,
  LevelUpResponseProto_LevelUpStatusAlreadyAtMaxLevel = 3,
  LevelUpResponseProto_LevelUpStatusOtherFail = 4,
} LevelUpResponseProto_LevelUpStatus;

BOOL LevelUpResponseProto_LevelUpStatusIsValidValue(LevelUpResponseProto_LevelUpStatus value);

typedef enum {
  SetFacebookIdResponseProto_SetFacebookIdStatusSuccess = 1,
  SetFacebookIdResponseProto_SetFacebookIdStatusFailOther = 2,
} SetFacebookIdResponseProto_SetFacebookIdStatus;

BOOL SetFacebookIdResponseProto_SetFacebookIdStatusIsValidValue(SetFacebookIdResponseProto_SetFacebookIdStatus value);


@interface EventUserRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface UserCreateRequestProto : PBGeneratedMessage {
@private
  BOOL hasUsedDiamondsToBuilt_:1;
  BOOL hasTimeOfStructPurchase_:1;
  BOOL hasTimeOfStructBuild_:1;
  BOOL hasUdid_:1;
  BOOL hasName_:1;
  BOOL hasReferrerCode_:1;
  BOOL hasDeviceToken_:1;
  BOOL hasFacebookId_:1;
  BOOL hasStructCoords_:1;
  BOOL usedDiamondsToBuilt_:1;
  int64_t timeOfStructPurchase;
  int64_t timeOfStructBuild;
  NSString* udid;
  NSString* name;
  NSString* referrerCode;
  NSString* deviceToken;
  NSString* facebookId;
  CoordinateProto* structCoords;
}
- (BOOL) hasUdid;
- (BOOL) hasName;
- (BOOL) hasReferrerCode;
- (BOOL) hasDeviceToken;
- (BOOL) hasTimeOfStructPurchase;
- (BOOL) hasTimeOfStructBuild;
- (BOOL) hasStructCoords;
- (BOOL) hasUsedDiamondsToBuilt;
- (BOOL) hasFacebookId;
@property (readonly, retain) NSString* udid;
@property (readonly, retain) NSString* name;
@property (readonly, retain) NSString* referrerCode;
@property (readonly, retain) NSString* deviceToken;
@property (readonly) int64_t timeOfStructPurchase;
@property (readonly) int64_t timeOfStructBuild;
@property (readonly, retain) CoordinateProto* structCoords;
- (BOOL) usedDiamondsToBuilt;
@property (readonly, retain) NSString* facebookId;

+ (UserCreateRequestProto*) defaultInstance;
- (UserCreateRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (UserCreateRequestProto_Builder*) builder;
+ (UserCreateRequestProto_Builder*) builder;
+ (UserCreateRequestProto_Builder*) builderWithPrototype:(UserCreateRequestProto*) prototype;

+ (UserCreateRequestProto*) parseFromData:(NSData*) data;
+ (UserCreateRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserCreateRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (UserCreateRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserCreateRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (UserCreateRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface UserCreateRequestProto_Builder : PBGeneratedMessage_Builder {
@private
  UserCreateRequestProto* result;
}

- (UserCreateRequestProto*) defaultInstance;

- (UserCreateRequestProto_Builder*) clear;
- (UserCreateRequestProto_Builder*) clone;

- (UserCreateRequestProto*) build;
- (UserCreateRequestProto*) buildPartial;

- (UserCreateRequestProto_Builder*) mergeFrom:(UserCreateRequestProto*) other;
- (UserCreateRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (UserCreateRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasUdid;
- (NSString*) udid;
- (UserCreateRequestProto_Builder*) setUdid:(NSString*) value;
- (UserCreateRequestProto_Builder*) clearUdid;

- (BOOL) hasName;
- (NSString*) name;
- (UserCreateRequestProto_Builder*) setName:(NSString*) value;
- (UserCreateRequestProto_Builder*) clearName;

- (BOOL) hasReferrerCode;
- (NSString*) referrerCode;
- (UserCreateRequestProto_Builder*) setReferrerCode:(NSString*) value;
- (UserCreateRequestProto_Builder*) clearReferrerCode;

- (BOOL) hasDeviceToken;
- (NSString*) deviceToken;
- (UserCreateRequestProto_Builder*) setDeviceToken:(NSString*) value;
- (UserCreateRequestProto_Builder*) clearDeviceToken;

- (BOOL) hasTimeOfStructPurchase;
- (int64_t) timeOfStructPurchase;
- (UserCreateRequestProto_Builder*) setTimeOfStructPurchase:(int64_t) value;
- (UserCreateRequestProto_Builder*) clearTimeOfStructPurchase;

- (BOOL) hasTimeOfStructBuild;
- (int64_t) timeOfStructBuild;
- (UserCreateRequestProto_Builder*) setTimeOfStructBuild:(int64_t) value;
- (UserCreateRequestProto_Builder*) clearTimeOfStructBuild;

- (BOOL) hasStructCoords;
- (CoordinateProto*) structCoords;
- (UserCreateRequestProto_Builder*) setStructCoords:(CoordinateProto*) value;
- (UserCreateRequestProto_Builder*) setStructCoordsBuilder:(CoordinateProto_Builder*) builderForValue;
- (UserCreateRequestProto_Builder*) mergeStructCoords:(CoordinateProto*) value;
- (UserCreateRequestProto_Builder*) clearStructCoords;

- (BOOL) hasUsedDiamondsToBuilt;
- (BOOL) usedDiamondsToBuilt;
- (UserCreateRequestProto_Builder*) setUsedDiamondsToBuilt:(BOOL) value;
- (UserCreateRequestProto_Builder*) clearUsedDiamondsToBuilt;

- (BOOL) hasFacebookId;
- (NSString*) facebookId;
- (UserCreateRequestProto_Builder*) setFacebookId:(NSString*) value;
- (UserCreateRequestProto_Builder*) clearFacebookId;
@end

@interface UserCreateResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  FullUserProto* sender;
  UserCreateResponseProto_UserCreateStatus status;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
@property (readonly, retain) FullUserProto* sender;
@property (readonly) UserCreateResponseProto_UserCreateStatus status;

+ (UserCreateResponseProto*) defaultInstance;
- (UserCreateResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (UserCreateResponseProto_Builder*) builder;
+ (UserCreateResponseProto_Builder*) builder;
+ (UserCreateResponseProto_Builder*) builderWithPrototype:(UserCreateResponseProto*) prototype;

+ (UserCreateResponseProto*) parseFromData:(NSData*) data;
+ (UserCreateResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserCreateResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (UserCreateResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserCreateResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (UserCreateResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface UserCreateResponseProto_Builder : PBGeneratedMessage_Builder {
@private
  UserCreateResponseProto* result;
}

- (UserCreateResponseProto*) defaultInstance;

- (UserCreateResponseProto_Builder*) clear;
- (UserCreateResponseProto_Builder*) clone;

- (UserCreateResponseProto*) build;
- (UserCreateResponseProto*) buildPartial;

- (UserCreateResponseProto_Builder*) mergeFrom:(UserCreateResponseProto*) other;
- (UserCreateResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (UserCreateResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (FullUserProto*) sender;
- (UserCreateResponseProto_Builder*) setSender:(FullUserProto*) value;
- (UserCreateResponseProto_Builder*) setSenderBuilder:(FullUserProto_Builder*) builderForValue;
- (UserCreateResponseProto_Builder*) mergeSender:(FullUserProto*) value;
- (UserCreateResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (UserCreateResponseProto_UserCreateStatus) status;
- (UserCreateResponseProto_Builder*) setStatus:(UserCreateResponseProto_UserCreateStatus) value;
- (UserCreateResponseProto_Builder*) clearStatus;
@end

@interface LevelUpRequestProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  MinimumUserProto* sender;
}
- (BOOL) hasSender;
@property (readonly, retain) MinimumUserProto* sender;

+ (LevelUpRequestProto*) defaultInstance;
- (LevelUpRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (LevelUpRequestProto_Builder*) builder;
+ (LevelUpRequestProto_Builder*) builder;
+ (LevelUpRequestProto_Builder*) builderWithPrototype:(LevelUpRequestProto*) prototype;

+ (LevelUpRequestProto*) parseFromData:(NSData*) data;
+ (LevelUpRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (LevelUpRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (LevelUpRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (LevelUpRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (LevelUpRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface LevelUpRequestProto_Builder : PBGeneratedMessage_Builder {
@private
  LevelUpRequestProto* result;
}

- (LevelUpRequestProto*) defaultInstance;

- (LevelUpRequestProto_Builder*) clear;
- (LevelUpRequestProto_Builder*) clone;

- (LevelUpRequestProto*) build;
- (LevelUpRequestProto*) buildPartial;

- (LevelUpRequestProto_Builder*) mergeFrom:(LevelUpRequestProto*) other;
- (LevelUpRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (LevelUpRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (LevelUpRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (LevelUpRequestProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (LevelUpRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (LevelUpRequestProto_Builder*) clearSender;
@end

@interface LevelUpResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  LevelUpResponseProto_LevelUpStatus status;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) LevelUpResponseProto_LevelUpStatus status;

+ (LevelUpResponseProto*) defaultInstance;
- (LevelUpResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (LevelUpResponseProto_Builder*) builder;
+ (LevelUpResponseProto_Builder*) builder;
+ (LevelUpResponseProto_Builder*) builderWithPrototype:(LevelUpResponseProto*) prototype;

+ (LevelUpResponseProto*) parseFromData:(NSData*) data;
+ (LevelUpResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (LevelUpResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (LevelUpResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (LevelUpResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (LevelUpResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface LevelUpResponseProto_Builder : PBGeneratedMessage_Builder {
@private
  LevelUpResponseProto* result;
}

- (LevelUpResponseProto*) defaultInstance;

- (LevelUpResponseProto_Builder*) clear;
- (LevelUpResponseProto_Builder*) clone;

- (LevelUpResponseProto*) build;
- (LevelUpResponseProto*) buildPartial;

- (LevelUpResponseProto_Builder*) mergeFrom:(LevelUpResponseProto*) other;
- (LevelUpResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (LevelUpResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (LevelUpResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (LevelUpResponseProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (LevelUpResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (LevelUpResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (LevelUpResponseProto_LevelUpStatus) status;
- (LevelUpResponseProto_Builder*) setStatus:(LevelUpResponseProto_LevelUpStatus) value;
- (LevelUpResponseProto_Builder*) clearStatus;
@end

@interface RetrieveUsersForUserIdsRequestProto : PBGeneratedMessage {
@private
  BOOL hasIncludeCurMonsterTeam_:1;
  BOOL hasSender_:1;
  BOOL includeCurMonsterTeam_:1;
  MinimumUserProto* sender;
  NSMutableArray* mutableRequestedUserIdsList;
}
- (BOOL) hasSender;
- (BOOL) hasIncludeCurMonsterTeam;
@property (readonly, retain) MinimumUserProto* sender;
- (BOOL) includeCurMonsterTeam;
- (NSArray*) requestedUserIdsList;
- (int32_t) requestedUserIdsAtIndex:(int32_t) index;

+ (RetrieveUsersForUserIdsRequestProto*) defaultInstance;
- (RetrieveUsersForUserIdsRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (RetrieveUsersForUserIdsRequestProto_Builder*) builder;
+ (RetrieveUsersForUserIdsRequestProto_Builder*) builder;
+ (RetrieveUsersForUserIdsRequestProto_Builder*) builderWithPrototype:(RetrieveUsersForUserIdsRequestProto*) prototype;

+ (RetrieveUsersForUserIdsRequestProto*) parseFromData:(NSData*) data;
+ (RetrieveUsersForUserIdsRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RetrieveUsersForUserIdsRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (RetrieveUsersForUserIdsRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RetrieveUsersForUserIdsRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (RetrieveUsersForUserIdsRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface RetrieveUsersForUserIdsRequestProto_Builder : PBGeneratedMessage_Builder {
@private
  RetrieveUsersForUserIdsRequestProto* result;
}

- (RetrieveUsersForUserIdsRequestProto*) defaultInstance;

- (RetrieveUsersForUserIdsRequestProto_Builder*) clear;
- (RetrieveUsersForUserIdsRequestProto_Builder*) clone;

- (RetrieveUsersForUserIdsRequestProto*) build;
- (RetrieveUsersForUserIdsRequestProto*) buildPartial;

- (RetrieveUsersForUserIdsRequestProto_Builder*) mergeFrom:(RetrieveUsersForUserIdsRequestProto*) other;
- (RetrieveUsersForUserIdsRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (RetrieveUsersForUserIdsRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (RetrieveUsersForUserIdsRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (RetrieveUsersForUserIdsRequestProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (RetrieveUsersForUserIdsRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (RetrieveUsersForUserIdsRequestProto_Builder*) clearSender;

- (NSArray*) requestedUserIdsList;
- (int32_t) requestedUserIdsAtIndex:(int32_t) index;
- (RetrieveUsersForUserIdsRequestProto_Builder*) replaceRequestedUserIdsAtIndex:(int32_t) index with:(int32_t) value;
- (RetrieveUsersForUserIdsRequestProto_Builder*) addRequestedUserIds:(int32_t) value;
- (RetrieveUsersForUserIdsRequestProto_Builder*) addAllRequestedUserIds:(NSArray*) values;
- (RetrieveUsersForUserIdsRequestProto_Builder*) clearRequestedUserIdsList;

- (BOOL) hasIncludeCurMonsterTeam;
- (BOOL) includeCurMonsterTeam;
- (RetrieveUsersForUserIdsRequestProto_Builder*) setIncludeCurMonsterTeam:(BOOL) value;
- (RetrieveUsersForUserIdsRequestProto_Builder*) clearIncludeCurMonsterTeam;
@end

@interface RetrieveUsersForUserIdsResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  MinimumUserProto* sender;
  NSMutableArray* mutableRequestedUsersList;
  NSMutableArray* mutableCurTeamList;
}
- (BOOL) hasSender;
@property (readonly, retain) MinimumUserProto* sender;
- (NSArray*) requestedUsersList;
- (FullUserProto*) requestedUsersAtIndex:(int32_t) index;
- (NSArray*) curTeamList;
- (UserCurrentMonsterTeamProto*) curTeamAtIndex:(int32_t) index;

+ (RetrieveUsersForUserIdsResponseProto*) defaultInstance;
- (RetrieveUsersForUserIdsResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (RetrieveUsersForUserIdsResponseProto_Builder*) builder;
+ (RetrieveUsersForUserIdsResponseProto_Builder*) builder;
+ (RetrieveUsersForUserIdsResponseProto_Builder*) builderWithPrototype:(RetrieveUsersForUserIdsResponseProto*) prototype;

+ (RetrieveUsersForUserIdsResponseProto*) parseFromData:(NSData*) data;
+ (RetrieveUsersForUserIdsResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RetrieveUsersForUserIdsResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (RetrieveUsersForUserIdsResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RetrieveUsersForUserIdsResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (RetrieveUsersForUserIdsResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface RetrieveUsersForUserIdsResponseProto_Builder : PBGeneratedMessage_Builder {
@private
  RetrieveUsersForUserIdsResponseProto* result;
}

- (RetrieveUsersForUserIdsResponseProto*) defaultInstance;

- (RetrieveUsersForUserIdsResponseProto_Builder*) clear;
- (RetrieveUsersForUserIdsResponseProto_Builder*) clone;

- (RetrieveUsersForUserIdsResponseProto*) build;
- (RetrieveUsersForUserIdsResponseProto*) buildPartial;

- (RetrieveUsersForUserIdsResponseProto_Builder*) mergeFrom:(RetrieveUsersForUserIdsResponseProto*) other;
- (RetrieveUsersForUserIdsResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (RetrieveUsersForUserIdsResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (RetrieveUsersForUserIdsResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (RetrieveUsersForUserIdsResponseProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (RetrieveUsersForUserIdsResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (RetrieveUsersForUserIdsResponseProto_Builder*) clearSender;

- (NSArray*) requestedUsersList;
- (FullUserProto*) requestedUsersAtIndex:(int32_t) index;
- (RetrieveUsersForUserIdsResponseProto_Builder*) replaceRequestedUsersAtIndex:(int32_t) index with:(FullUserProto*) value;
- (RetrieveUsersForUserIdsResponseProto_Builder*) addRequestedUsers:(FullUserProto*) value;
- (RetrieveUsersForUserIdsResponseProto_Builder*) addAllRequestedUsers:(NSArray*) values;
- (RetrieveUsersForUserIdsResponseProto_Builder*) clearRequestedUsersList;

- (NSArray*) curTeamList;
- (UserCurrentMonsterTeamProto*) curTeamAtIndex:(int32_t) index;
- (RetrieveUsersForUserIdsResponseProto_Builder*) replaceCurTeamAtIndex:(int32_t) index with:(UserCurrentMonsterTeamProto*) value;
- (RetrieveUsersForUserIdsResponseProto_Builder*) addCurTeam:(UserCurrentMonsterTeamProto*) value;
- (RetrieveUsersForUserIdsResponseProto_Builder*) addAllCurTeam:(NSArray*) values;
- (RetrieveUsersForUserIdsResponseProto_Builder*) clearCurTeamList;
@end

@interface LogoutRequestProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  MinimumUserProto* sender;
}
- (BOOL) hasSender;
@property (readonly, retain) MinimumUserProto* sender;

+ (LogoutRequestProto*) defaultInstance;
- (LogoutRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (LogoutRequestProto_Builder*) builder;
+ (LogoutRequestProto_Builder*) builder;
+ (LogoutRequestProto_Builder*) builderWithPrototype:(LogoutRequestProto*) prototype;

+ (LogoutRequestProto*) parseFromData:(NSData*) data;
+ (LogoutRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (LogoutRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (LogoutRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (LogoutRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (LogoutRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface LogoutRequestProto_Builder : PBGeneratedMessage_Builder {
@private
  LogoutRequestProto* result;
}

- (LogoutRequestProto*) defaultInstance;

- (LogoutRequestProto_Builder*) clear;
- (LogoutRequestProto_Builder*) clone;

- (LogoutRequestProto*) build;
- (LogoutRequestProto*) buildPartial;

- (LogoutRequestProto_Builder*) mergeFrom:(LogoutRequestProto*) other;
- (LogoutRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (LogoutRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (LogoutRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (LogoutRequestProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (LogoutRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (LogoutRequestProto_Builder*) clearSender;
@end

@interface UpdateClientUserResponseProto : PBGeneratedMessage {
@private
  BOOL hasTimeOfUserUpdate_:1;
  BOOL hasSender_:1;
  int64_t timeOfUserUpdate;
  FullUserProto* sender;
}
- (BOOL) hasSender;
- (BOOL) hasTimeOfUserUpdate;
@property (readonly, retain) FullUserProto* sender;
@property (readonly) int64_t timeOfUserUpdate;

+ (UpdateClientUserResponseProto*) defaultInstance;
- (UpdateClientUserResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (UpdateClientUserResponseProto_Builder*) builder;
+ (UpdateClientUserResponseProto_Builder*) builder;
+ (UpdateClientUserResponseProto_Builder*) builderWithPrototype:(UpdateClientUserResponseProto*) prototype;

+ (UpdateClientUserResponseProto*) parseFromData:(NSData*) data;
+ (UpdateClientUserResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UpdateClientUserResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (UpdateClientUserResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UpdateClientUserResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (UpdateClientUserResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface UpdateClientUserResponseProto_Builder : PBGeneratedMessage_Builder {
@private
  UpdateClientUserResponseProto* result;
}

- (UpdateClientUserResponseProto*) defaultInstance;

- (UpdateClientUserResponseProto_Builder*) clear;
- (UpdateClientUserResponseProto_Builder*) clone;

- (UpdateClientUserResponseProto*) build;
- (UpdateClientUserResponseProto*) buildPartial;

- (UpdateClientUserResponseProto_Builder*) mergeFrom:(UpdateClientUserResponseProto*) other;
- (UpdateClientUserResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (UpdateClientUserResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (FullUserProto*) sender;
- (UpdateClientUserResponseProto_Builder*) setSender:(FullUserProto*) value;
- (UpdateClientUserResponseProto_Builder*) setSenderBuilder:(FullUserProto_Builder*) builderForValue;
- (UpdateClientUserResponseProto_Builder*) mergeSender:(FullUserProto*) value;
- (UpdateClientUserResponseProto_Builder*) clearSender;

- (BOOL) hasTimeOfUserUpdate;
- (int64_t) timeOfUserUpdate;
- (UpdateClientUserResponseProto_Builder*) setTimeOfUserUpdate:(int64_t) value;
- (UpdateClientUserResponseProto_Builder*) clearTimeOfUserUpdate;
@end

@interface SetFacebookIdRequestProto : PBGeneratedMessage {
@private
  BOOL hasFbId_:1;
  BOOL hasSender_:1;
  NSString* fbId;
  MinimumUserProto* sender;
}
- (BOOL) hasSender;
- (BOOL) hasFbId;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly, retain) NSString* fbId;

+ (SetFacebookIdRequestProto*) defaultInstance;
- (SetFacebookIdRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (SetFacebookIdRequestProto_Builder*) builder;
+ (SetFacebookIdRequestProto_Builder*) builder;
+ (SetFacebookIdRequestProto_Builder*) builderWithPrototype:(SetFacebookIdRequestProto*) prototype;

+ (SetFacebookIdRequestProto*) parseFromData:(NSData*) data;
+ (SetFacebookIdRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SetFacebookIdRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (SetFacebookIdRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SetFacebookIdRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (SetFacebookIdRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface SetFacebookIdRequestProto_Builder : PBGeneratedMessage_Builder {
@private
  SetFacebookIdRequestProto* result;
}

- (SetFacebookIdRequestProto*) defaultInstance;

- (SetFacebookIdRequestProto_Builder*) clear;
- (SetFacebookIdRequestProto_Builder*) clone;

- (SetFacebookIdRequestProto*) build;
- (SetFacebookIdRequestProto*) buildPartial;

- (SetFacebookIdRequestProto_Builder*) mergeFrom:(SetFacebookIdRequestProto*) other;
- (SetFacebookIdRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (SetFacebookIdRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (SetFacebookIdRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (SetFacebookIdRequestProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (SetFacebookIdRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (SetFacebookIdRequestProto_Builder*) clearSender;

- (BOOL) hasFbId;
- (NSString*) fbId;
- (SetFacebookIdRequestProto_Builder*) setFbId:(NSString*) value;
- (SetFacebookIdRequestProto_Builder*) clearFbId;
@end

@interface SetFacebookIdResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  SetFacebookIdResponseProto_SetFacebookIdStatus status;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) SetFacebookIdResponseProto_SetFacebookIdStatus status;

+ (SetFacebookIdResponseProto*) defaultInstance;
- (SetFacebookIdResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (SetFacebookIdResponseProto_Builder*) builder;
+ (SetFacebookIdResponseProto_Builder*) builder;
+ (SetFacebookIdResponseProto_Builder*) builderWithPrototype:(SetFacebookIdResponseProto*) prototype;

+ (SetFacebookIdResponseProto*) parseFromData:(NSData*) data;
+ (SetFacebookIdResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SetFacebookIdResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (SetFacebookIdResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SetFacebookIdResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (SetFacebookIdResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface SetFacebookIdResponseProto_Builder : PBGeneratedMessage_Builder {
@private
  SetFacebookIdResponseProto* result;
}

- (SetFacebookIdResponseProto*) defaultInstance;

- (SetFacebookIdResponseProto_Builder*) clear;
- (SetFacebookIdResponseProto_Builder*) clone;

- (SetFacebookIdResponseProto*) build;
- (SetFacebookIdResponseProto*) buildPartial;

- (SetFacebookIdResponseProto_Builder*) mergeFrom:(SetFacebookIdResponseProto*) other;
- (SetFacebookIdResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (SetFacebookIdResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (SetFacebookIdResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (SetFacebookIdResponseProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (SetFacebookIdResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (SetFacebookIdResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (SetFacebookIdResponseProto_SetFacebookIdStatus) status;
- (SetFacebookIdResponseProto_Builder*) setStatus:(SetFacebookIdResponseProto_SetFacebookIdStatus) value;
- (SetFacebookIdResponseProto_Builder*) clearStatus;
@end

