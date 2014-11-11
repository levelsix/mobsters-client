// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "Dev.pb.h"
#import "Item.pb.h"
#import "MonsterStuff.pb.h"
#import "User.pb.h"
// @@protoc_insertion_point(imports)

@class DevRequestProto;
@class DevRequestProto_Builder;
@class DevResponseProto;
@class DevResponseProto_Builder;
@class FullUserMonsterProto;
@class FullUserMonsterProto_Builder;
@class FullUserProto;
@class FullUserProto_Builder;
@class ItemProto;
@class ItemProto_Builder;
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
@class UserItemProto;
@class UserItemProto_Builder;
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
  DevResponseProto_DevStatusSuccess = 1,
  DevResponseProto_DevStatusFailOther = 2,
} DevResponseProto_DevStatus;

BOOL DevResponseProto_DevStatusIsValidValue(DevResponseProto_DevStatus value);


@interface EventDevRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface DevRequestProto : PBGeneratedMessage {
@private
  BOOL hasStaticDataId_:1;
  BOOL hasQuantity_:1;
  BOOL hasSender_:1;
  BOOL hasDevRequest_:1;
  int32_t staticDataId;
  int32_t quantity;
  MinimumUserProto* sender;
  DevRequest devRequest;
}
- (BOOL) hasSender;
- (BOOL) hasDevRequest;
- (BOOL) hasStaticDataId;
- (BOOL) hasQuantity;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) DevRequest devRequest;
@property (readonly) int32_t staticDataId;
@property (readonly) int32_t quantity;

+ (DevRequestProto*) defaultInstance;
- (DevRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (DevRequestProto_Builder*) builder;
+ (DevRequestProto_Builder*) builder;
+ (DevRequestProto_Builder*) builderWithPrototype:(DevRequestProto*) prototype;
- (DevRequestProto_Builder*) toBuilder;

+ (DevRequestProto*) parseFromData:(NSData*) data;
+ (DevRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (DevRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (DevRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (DevRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (DevRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface DevRequestProto_Builder : PBGeneratedMessageBuilder {
@private
  DevRequestProto* result;
}

- (DevRequestProto*) defaultInstance;

- (DevRequestProto_Builder*) clear;
- (DevRequestProto_Builder*) clone;

- (DevRequestProto*) build;
- (DevRequestProto*) buildPartial;

- (DevRequestProto_Builder*) mergeFrom:(DevRequestProto*) other;
- (DevRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (DevRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (DevRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (DevRequestProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (DevRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (DevRequestProto_Builder*) clearSender;

- (BOOL) hasDevRequest;
- (DevRequest) devRequest;
- (DevRequestProto_Builder*) setDevRequest:(DevRequest) value;
- (DevRequestProto_Builder*) clearDevRequest;

- (BOOL) hasStaticDataId;
- (int32_t) staticDataId;
- (DevRequestProto_Builder*) setStaticDataId:(int32_t) value;
- (DevRequestProto_Builder*) clearStaticDataId;

- (BOOL) hasQuantity;
- (int32_t) quantity;
- (DevRequestProto_Builder*) setQuantity:(int32_t) value;
- (DevRequestProto_Builder*) clearQuantity;
@end

@interface DevResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasUip_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  UserItemProto* uip;
  DevResponseProto_DevStatus status;
  NSMutableArray * mutableFumpList;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
- (BOOL) hasUip;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) DevResponseProto_DevStatus status;
@property (readonly, strong) NSArray * fumpList;
@property (readonly, strong) UserItemProto* uip;
- (FullUserMonsterProto*)fumpAtIndex:(NSUInteger)index;

+ (DevResponseProto*) defaultInstance;
- (DevResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (DevResponseProto_Builder*) builder;
+ (DevResponseProto_Builder*) builder;
+ (DevResponseProto_Builder*) builderWithPrototype:(DevResponseProto*) prototype;
- (DevResponseProto_Builder*) toBuilder;

+ (DevResponseProto*) parseFromData:(NSData*) data;
+ (DevResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (DevResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (DevResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (DevResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (DevResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface DevResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  DevResponseProto* result;
}

- (DevResponseProto*) defaultInstance;

- (DevResponseProto_Builder*) clear;
- (DevResponseProto_Builder*) clone;

- (DevResponseProto*) build;
- (DevResponseProto*) buildPartial;

- (DevResponseProto_Builder*) mergeFrom:(DevResponseProto*) other;
- (DevResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (DevResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (DevResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (DevResponseProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (DevResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (DevResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (DevResponseProto_DevStatus) status;
- (DevResponseProto_Builder*) setStatus:(DevResponseProto_DevStatus) value;
- (DevResponseProto_Builder*) clearStatus;

- (NSMutableArray *)fumpList;
- (FullUserMonsterProto*)fumpAtIndex:(NSUInteger)index;
- (DevResponseProto_Builder *)addFump:(FullUserMonsterProto*)value;
- (DevResponseProto_Builder *)addAllFump:(NSArray *)array;
- (DevResponseProto_Builder *)clearFump;

- (BOOL) hasUip;
- (UserItemProto*) uip;
- (DevResponseProto_Builder*) setUip:(UserItemProto*) value;
- (DevResponseProto_Builder*) setUip_Builder:(UserItemProto_Builder*) builderForValue;
- (DevResponseProto_Builder*) mergeUip:(UserItemProto*) value;
- (DevResponseProto_Builder*) clearUip;
@end


// @@protoc_insertion_point(global_scope)
