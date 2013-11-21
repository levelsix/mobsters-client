// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "Battle.pb.h"
#import "User.pb.h"

@class FullClanProto;
@class FullClanProtoWithClanSize;
@class FullClanProtoWithClanSize_Builder;
@class FullClanProto_Builder;
@class FullUserClanProto;
@class FullUserClanProto_Builder;
@class FullUserProto;
@class FullUserProto_Builder;
@class MinimumClanProto;
@class MinimumClanProto_Builder;
@class MinimumUserProto;
@class MinimumUserProtoForClans;
@class MinimumUserProtoForClans_Builder;
@class MinimumUserProtoWithBattleHistory;
@class MinimumUserProtoWithBattleHistory_Builder;
@class MinimumUserProtoWithFacebookId;
@class MinimumUserProtoWithFacebookId_Builder;
@class MinimumUserProtoWithLevel;
@class MinimumUserProtoWithLevel_Builder;
@class MinimumUserProto_Builder;
@class StaticUserLevelInfoProto;
@class StaticUserLevelInfoProto_Builder;
@class UserFacebookInviteForSlotProto;
@class UserFacebookInviteForSlotProto_Builder;
typedef enum {
  UserClanStatusMember = 1,
  UserClanStatusRequesting = 2,
} UserClanStatus;

BOOL UserClanStatusIsValidValue(UserClanStatus value);


@interface ClanRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface FullClanProto : PBGeneratedMessage {
@private
  BOOL hasRequestToJoinRequired_:1;
  BOOL hasCreateTime_:1;
  BOOL hasClanUuid_:1;
  BOOL hasName_:1;
  BOOL hasDescription_:1;
  BOOL hasTag_:1;
  BOOL hasOwner_:1;
  BOOL requestToJoinRequired_:1;
  int64_t createTime;
  NSString* clanUuid;
  NSString* name;
  NSString* description;
  NSString* tag;
  MinimumUserProto* owner;
}
- (BOOL) hasClanUuid;
- (BOOL) hasName;
- (BOOL) hasOwner;
- (BOOL) hasCreateTime;
- (BOOL) hasDescription;
- (BOOL) hasTag;
- (BOOL) hasRequestToJoinRequired;
@property (readonly, retain) NSString* clanUuid;
@property (readonly, retain) NSString* name;
@property (readonly, retain) MinimumUserProto* owner;
@property (readonly) int64_t createTime;
@property (readonly, retain) NSString* description;
@property (readonly, retain) NSString* tag;
- (BOOL) requestToJoinRequired;

+ (FullClanProto*) defaultInstance;
- (FullClanProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (FullClanProto_Builder*) builder;
+ (FullClanProto_Builder*) builder;
+ (FullClanProto_Builder*) builderWithPrototype:(FullClanProto*) prototype;

+ (FullClanProto*) parseFromData:(NSData*) data;
+ (FullClanProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FullClanProto*) parseFromInputStream:(NSInputStream*) input;
+ (FullClanProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FullClanProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (FullClanProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface FullClanProto_Builder : PBGeneratedMessage_Builder {
@private
  FullClanProto* result;
}

- (FullClanProto*) defaultInstance;

- (FullClanProto_Builder*) clear;
- (FullClanProto_Builder*) clone;

- (FullClanProto*) build;
- (FullClanProto*) buildPartial;

- (FullClanProto_Builder*) mergeFrom:(FullClanProto*) other;
- (FullClanProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (FullClanProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasClanUuid;
- (NSString*) clanUuid;
- (FullClanProto_Builder*) setClanUuid:(NSString*) value;
- (FullClanProto_Builder*) clearClanUuid;

- (BOOL) hasName;
- (NSString*) name;
- (FullClanProto_Builder*) setName:(NSString*) value;
- (FullClanProto_Builder*) clearName;

- (BOOL) hasOwner;
- (MinimumUserProto*) owner;
- (FullClanProto_Builder*) setOwner:(MinimumUserProto*) value;
- (FullClanProto_Builder*) setOwnerBuilder:(MinimumUserProto_Builder*) builderForValue;
- (FullClanProto_Builder*) mergeOwner:(MinimumUserProto*) value;
- (FullClanProto_Builder*) clearOwner;

- (BOOL) hasCreateTime;
- (int64_t) createTime;
- (FullClanProto_Builder*) setCreateTime:(int64_t) value;
- (FullClanProto_Builder*) clearCreateTime;

- (BOOL) hasDescription;
- (NSString*) description;
- (FullClanProto_Builder*) setDescription:(NSString*) value;
- (FullClanProto_Builder*) clearDescription;

- (BOOL) hasTag;
- (NSString*) tag;
- (FullClanProto_Builder*) setTag:(NSString*) value;
- (FullClanProto_Builder*) clearTag;

- (BOOL) hasRequestToJoinRequired;
- (BOOL) requestToJoinRequired;
- (FullClanProto_Builder*) setRequestToJoinRequired:(BOOL) value;
- (FullClanProto_Builder*) clearRequestToJoinRequired;
@end

@interface FullUserClanProto : PBGeneratedMessage {
@private
  BOOL hasRequestTime_:1;
  BOOL hasUserUuid_:1;
  BOOL hasClanUuid_:1;
  BOOL hasStatus_:1;
  int64_t requestTime;
  NSString* userUuid;
  NSString* clanUuid;
  UserClanStatus status;
}
- (BOOL) hasUserUuid;
- (BOOL) hasClanUuid;
- (BOOL) hasStatus;
- (BOOL) hasRequestTime;
@property (readonly, retain) NSString* userUuid;
@property (readonly, retain) NSString* clanUuid;
@property (readonly) UserClanStatus status;
@property (readonly) int64_t requestTime;

+ (FullUserClanProto*) defaultInstance;
- (FullUserClanProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (FullUserClanProto_Builder*) builder;
+ (FullUserClanProto_Builder*) builder;
+ (FullUserClanProto_Builder*) builderWithPrototype:(FullUserClanProto*) prototype;

+ (FullUserClanProto*) parseFromData:(NSData*) data;
+ (FullUserClanProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FullUserClanProto*) parseFromInputStream:(NSInputStream*) input;
+ (FullUserClanProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FullUserClanProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (FullUserClanProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface FullUserClanProto_Builder : PBGeneratedMessage_Builder {
@private
  FullUserClanProto* result;
}

- (FullUserClanProto*) defaultInstance;

- (FullUserClanProto_Builder*) clear;
- (FullUserClanProto_Builder*) clone;

- (FullUserClanProto*) build;
- (FullUserClanProto*) buildPartial;

- (FullUserClanProto_Builder*) mergeFrom:(FullUserClanProto*) other;
- (FullUserClanProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (FullUserClanProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasUserUuid;
- (NSString*) userUuid;
- (FullUserClanProto_Builder*) setUserUuid:(NSString*) value;
- (FullUserClanProto_Builder*) clearUserUuid;

- (BOOL) hasClanUuid;
- (NSString*) clanUuid;
- (FullUserClanProto_Builder*) setClanUuid:(NSString*) value;
- (FullUserClanProto_Builder*) clearClanUuid;

- (BOOL) hasStatus;
- (UserClanStatus) status;
- (FullUserClanProto_Builder*) setStatus:(UserClanStatus) value;
- (FullUserClanProto_Builder*) clearStatus;

- (BOOL) hasRequestTime;
- (int64_t) requestTime;
- (FullUserClanProto_Builder*) setRequestTime:(int64_t) value;
- (FullUserClanProto_Builder*) clearRequestTime;
@end

@interface FullClanProtoWithClanSize : PBGeneratedMessage {
@private
  BOOL hasClanSize_:1;
  BOOL hasClan_:1;
  int32_t clanSize;
  FullClanProto* clan;
}
- (BOOL) hasClan;
- (BOOL) hasClanSize;
@property (readonly, retain) FullClanProto* clan;
@property (readonly) int32_t clanSize;

+ (FullClanProtoWithClanSize*) defaultInstance;
- (FullClanProtoWithClanSize*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (FullClanProtoWithClanSize_Builder*) builder;
+ (FullClanProtoWithClanSize_Builder*) builder;
+ (FullClanProtoWithClanSize_Builder*) builderWithPrototype:(FullClanProtoWithClanSize*) prototype;

+ (FullClanProtoWithClanSize*) parseFromData:(NSData*) data;
+ (FullClanProtoWithClanSize*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FullClanProtoWithClanSize*) parseFromInputStream:(NSInputStream*) input;
+ (FullClanProtoWithClanSize*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (FullClanProtoWithClanSize*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (FullClanProtoWithClanSize*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface FullClanProtoWithClanSize_Builder : PBGeneratedMessage_Builder {
@private
  FullClanProtoWithClanSize* result;
}

- (FullClanProtoWithClanSize*) defaultInstance;

- (FullClanProtoWithClanSize_Builder*) clear;
- (FullClanProtoWithClanSize_Builder*) clone;

- (FullClanProtoWithClanSize*) build;
- (FullClanProtoWithClanSize*) buildPartial;

- (FullClanProtoWithClanSize_Builder*) mergeFrom:(FullClanProtoWithClanSize*) other;
- (FullClanProtoWithClanSize_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (FullClanProtoWithClanSize_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasClan;
- (FullClanProto*) clan;
- (FullClanProtoWithClanSize_Builder*) setClan:(FullClanProto*) value;
- (FullClanProtoWithClanSize_Builder*) setClanBuilder:(FullClanProto_Builder*) builderForValue;
- (FullClanProtoWithClanSize_Builder*) mergeClan:(FullClanProto*) value;
- (FullClanProtoWithClanSize_Builder*) clearClan;

- (BOOL) hasClanSize;
- (int32_t) clanSize;
- (FullClanProtoWithClanSize_Builder*) setClanSize:(int32_t) value;
- (FullClanProtoWithClanSize_Builder*) clearClanSize;
@end

@interface MinimumUserProtoForClans : PBGeneratedMessage {
@private
  BOOL hasMinUserProto_:1;
  BOOL hasClanStatus_:1;
  MinimumUserProtoWithBattleHistory* minUserProto;
  UserClanStatus clanStatus;
}
- (BOOL) hasMinUserProto;
- (BOOL) hasClanStatus;
@property (readonly, retain) MinimumUserProtoWithBattleHistory* minUserProto;
@property (readonly) UserClanStatus clanStatus;

+ (MinimumUserProtoForClans*) defaultInstance;
- (MinimumUserProtoForClans*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (MinimumUserProtoForClans_Builder*) builder;
+ (MinimumUserProtoForClans_Builder*) builder;
+ (MinimumUserProtoForClans_Builder*) builderWithPrototype:(MinimumUserProtoForClans*) prototype;

+ (MinimumUserProtoForClans*) parseFromData:(NSData*) data;
+ (MinimumUserProtoForClans*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (MinimumUserProtoForClans*) parseFromInputStream:(NSInputStream*) input;
+ (MinimumUserProtoForClans*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (MinimumUserProtoForClans*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (MinimumUserProtoForClans*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface MinimumUserProtoForClans_Builder : PBGeneratedMessage_Builder {
@private
  MinimumUserProtoForClans* result;
}

- (MinimumUserProtoForClans*) defaultInstance;

- (MinimumUserProtoForClans_Builder*) clear;
- (MinimumUserProtoForClans_Builder*) clone;

- (MinimumUserProtoForClans*) build;
- (MinimumUserProtoForClans*) buildPartial;

- (MinimumUserProtoForClans_Builder*) mergeFrom:(MinimumUserProtoForClans*) other;
- (MinimumUserProtoForClans_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (MinimumUserProtoForClans_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasMinUserProto;
- (MinimumUserProtoWithBattleHistory*) minUserProto;
- (MinimumUserProtoForClans_Builder*) setMinUserProto:(MinimumUserProtoWithBattleHistory*) value;
- (MinimumUserProtoForClans_Builder*) setMinUserProtoBuilder:(MinimumUserProtoWithBattleHistory_Builder*) builderForValue;
- (MinimumUserProtoForClans_Builder*) mergeMinUserProto:(MinimumUserProtoWithBattleHistory*) value;
- (MinimumUserProtoForClans_Builder*) clearMinUserProto;

- (BOOL) hasClanStatus;
- (UserClanStatus) clanStatus;
- (MinimumUserProtoForClans_Builder*) setClanStatus:(UserClanStatus) value;
- (MinimumUserProtoForClans_Builder*) clearClanStatus;
@end

