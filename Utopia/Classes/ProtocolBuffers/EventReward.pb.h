// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "Chat.pb.h"
#import "Reward.pb.h"
#import "User.pb.h"
// @@protoc_insertion_point(imports)

@class ClanGiftProto;
@class ClanGiftProto_Builder;
@class ClanMemberTeamDonationProto;
@class ClanMemberTeamDonationProto_Builder;
@class CollectGiftRequestProto;
@class CollectGiftRequestProto_Builder;
@class CollectGiftResponseProto;
@class CollectGiftResponseProto_Builder;
@class ColorProto;
@class ColorProto_Builder;
@class DefaultLanguagesProto;
@class DefaultLanguagesProto_Builder;
@class DeleteGiftRequestProto;
@class DeleteGiftRequestProto_Builder;
@class DeleteGiftResponseProto;
@class DeleteGiftResponseProto_Builder;
@class FullUserMonsterProto;
@class FullUserMonsterProto_Builder;
@class FullUserProto;
@class FullUserProto_Builder;
@class GroupChatMessageProto;
@class GroupChatMessageProto_Builder;
@class ItemGemPriceProto;
@class ItemGemPriceProto_Builder;
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
@class PrivateChatDefaultLanguageProto;
@class PrivateChatDefaultLanguageProto_Builder;
@class PrivateChatPostProto;
@class PrivateChatPostProto_Builder;
@class ReceivedGiftResponseProto;
@class ReceivedGiftResponseProto_Builder;
@class RewardProto;
@class RewardProto_Builder;
@class SendTangoGiftRequestProto;
@class SendTangoGiftRequestProto_Builder;
@class SendTangoGiftResponseProto;
@class SendTangoGiftResponseProto_Builder;
@class StaticUserLevelInfoProto;
@class StaticUserLevelInfoProto_Builder;
@class TangoGiftProto;
@class TangoGiftProto_Builder;
@class TranslatedTextProto;
@class TranslatedTextProto_Builder;
@class UserClanGiftProto;
@class UserClanGiftProto_Builder;
@class UserCurrentMonsterTeamProto;
@class UserCurrentMonsterTeamProto_Builder;
@class UserEnhancementItemProto;
@class UserEnhancementItemProto_Builder;
@class UserEnhancementProto;
@class UserEnhancementProto_Builder;
@class UserFacebookInviteForSlotProto;
@class UserFacebookInviteForSlotProto_Builder;
@class UserGiftProto;
@class UserGiftProto_Builder;
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
@class UserPvpLeagueProto;
@class UserPvpLeagueProto_Builder;
@class UserRewardProto;
@class UserRewardProto_Builder;
@class UserTangoGiftProto;
@class UserTangoGiftProto_Builder;
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

typedef NS_ENUM(SInt32, SendTangoGiftResponseProto_SendTangoGiftStatus) {
  SendTangoGiftResponseProto_SendTangoGiftStatusSuccess = 1,
  SendTangoGiftResponseProto_SendTangoGiftStatusFailOther = 2,
};

BOOL SendTangoGiftResponseProto_SendTangoGiftStatusIsValidValue(SendTangoGiftResponseProto_SendTangoGiftStatus value);

typedef NS_ENUM(SInt32, DeleteGiftResponseProto_DeleteGiftStatus) {
  DeleteGiftResponseProto_DeleteGiftStatusSuccess = 1,
  DeleteGiftResponseProto_DeleteGiftStatusFailOther = 2,
};

BOOL DeleteGiftResponseProto_DeleteGiftStatusIsValidValue(DeleteGiftResponseProto_DeleteGiftStatus value);

typedef NS_ENUM(SInt32, CollectGiftResponseProto_CollectGiftStatus) {
  CollectGiftResponseProto_CollectGiftStatusSuccess = 1,
  CollectGiftResponseProto_CollectGiftStatusFailOther = 2,
};

BOOL CollectGiftResponseProto_CollectGiftStatusIsValidValue(CollectGiftResponseProto_CollectGiftStatus value);


@interface EventRewardRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface SendTangoGiftRequestProto : PBGeneratedMessage {
@private
  BOOL hasClientTime_:1;
  BOOL hasGemReward_:1;
  BOOL hasSenderTangoUserId_:1;
  BOOL hasSender_:1;
  int64_t clientTime;
  int32_t gemReward;
  NSString* senderTangoUserId;
  MinimumUserProto* sender;
  NSMutableArray * mutableTangoUserIdsList;
}
- (BOOL) hasSender;
- (BOOL) hasClientTime;
- (BOOL) hasSenderTangoUserId;
- (BOOL) hasGemReward;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) int64_t clientTime;
@property (readonly, strong) NSArray * tangoUserIdsList;
@property (readonly, strong) NSString* senderTangoUserId;
@property (readonly) int32_t gemReward;
- (NSString*)tangoUserIdsAtIndex:(NSUInteger)index;

+ (SendTangoGiftRequestProto*) defaultInstance;
- (SendTangoGiftRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (SendTangoGiftRequestProto_Builder*) builder;
+ (SendTangoGiftRequestProto_Builder*) builder;
+ (SendTangoGiftRequestProto_Builder*) builderWithPrototype:(SendTangoGiftRequestProto*) prototype;
- (SendTangoGiftRequestProto_Builder*) toBuilder;

+ (SendTangoGiftRequestProto*) parseFromData:(NSData*) data;
+ (SendTangoGiftRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SendTangoGiftRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (SendTangoGiftRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SendTangoGiftRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (SendTangoGiftRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface SendTangoGiftRequestProto_Builder : PBGeneratedMessageBuilder {
@private
  SendTangoGiftRequestProto* result;
}

- (SendTangoGiftRequestProto*) defaultInstance;

- (SendTangoGiftRequestProto_Builder*) clear;
- (SendTangoGiftRequestProto_Builder*) clone;

- (SendTangoGiftRequestProto*) build;
- (SendTangoGiftRequestProto*) buildPartial;

- (SendTangoGiftRequestProto_Builder*) mergeFrom:(SendTangoGiftRequestProto*) other;
- (SendTangoGiftRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (SendTangoGiftRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (SendTangoGiftRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (SendTangoGiftRequestProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (SendTangoGiftRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (SendTangoGiftRequestProto_Builder*) clearSender;

- (BOOL) hasClientTime;
- (int64_t) clientTime;
- (SendTangoGiftRequestProto_Builder*) setClientTime:(int64_t) value;
- (SendTangoGiftRequestProto_Builder*) clearClientTime;

- (NSMutableArray *)tangoUserIdsList;
- (NSString*)tangoUserIdsAtIndex:(NSUInteger)index;
- (SendTangoGiftRequestProto_Builder *)addTangoUserIds:(NSString*)value;
- (SendTangoGiftRequestProto_Builder *)addAllTangoUserIds:(NSArray *)array;
- (SendTangoGiftRequestProto_Builder *)clearTangoUserIds;

- (BOOL) hasSenderTangoUserId;
- (NSString*) senderTangoUserId;
- (SendTangoGiftRequestProto_Builder*) setSenderTangoUserId:(NSString*) value;
- (SendTangoGiftRequestProto_Builder*) clearSenderTangoUserId;

- (BOOL) hasGemReward;
- (int32_t) gemReward;
- (SendTangoGiftRequestProto_Builder*) setGemReward:(int32_t) value;
- (SendTangoGiftRequestProto_Builder*) clearGemReward;
@end

@interface SendTangoGiftResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  SendTangoGiftResponseProto_SendTangoGiftStatus status;
  NSMutableArray * mutableTangoUserIdsNotInToonSquadList;
  NSMutableArray * mutableTangoUserIdsInToonSquadList;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) SendTangoGiftResponseProto_SendTangoGiftStatus status;
@property (readonly, strong) NSArray * tangoUserIdsNotInToonSquadList;
@property (readonly, strong) NSArray * tangoUserIdsInToonSquadList;
- (NSString*)tangoUserIdsNotInToonSquadAtIndex:(NSUInteger)index;
- (NSString*)tangoUserIdsInToonSquadAtIndex:(NSUInteger)index;

+ (SendTangoGiftResponseProto*) defaultInstance;
- (SendTangoGiftResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (SendTangoGiftResponseProto_Builder*) builder;
+ (SendTangoGiftResponseProto_Builder*) builder;
+ (SendTangoGiftResponseProto_Builder*) builderWithPrototype:(SendTangoGiftResponseProto*) prototype;
- (SendTangoGiftResponseProto_Builder*) toBuilder;

+ (SendTangoGiftResponseProto*) parseFromData:(NSData*) data;
+ (SendTangoGiftResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SendTangoGiftResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (SendTangoGiftResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SendTangoGiftResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (SendTangoGiftResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface SendTangoGiftResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  SendTangoGiftResponseProto* result;
}

- (SendTangoGiftResponseProto*) defaultInstance;

- (SendTangoGiftResponseProto_Builder*) clear;
- (SendTangoGiftResponseProto_Builder*) clone;

- (SendTangoGiftResponseProto*) build;
- (SendTangoGiftResponseProto*) buildPartial;

- (SendTangoGiftResponseProto_Builder*) mergeFrom:(SendTangoGiftResponseProto*) other;
- (SendTangoGiftResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (SendTangoGiftResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (SendTangoGiftResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (SendTangoGiftResponseProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (SendTangoGiftResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (SendTangoGiftResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (SendTangoGiftResponseProto_SendTangoGiftStatus) status;
- (SendTangoGiftResponseProto_Builder*) setStatus:(SendTangoGiftResponseProto_SendTangoGiftStatus) value;
- (SendTangoGiftResponseProto_Builder*) clearStatusList;

- (NSMutableArray *)tangoUserIdsNotInToonSquadList;
- (NSString*)tangoUserIdsNotInToonSquadAtIndex:(NSUInteger)index;
- (SendTangoGiftResponseProto_Builder *)addTangoUserIdsNotInToonSquad:(NSString*)value;
- (SendTangoGiftResponseProto_Builder *)addAllTangoUserIdsNotInToonSquad:(NSArray *)array;
- (SendTangoGiftResponseProto_Builder *)clearTangoUserIdsNotInToonSquad;

- (NSMutableArray *)tangoUserIdsInToonSquadList;
- (NSString*)tangoUserIdsInToonSquadAtIndex:(NSUInteger)index;
- (SendTangoGiftResponseProto_Builder *)addTangoUserIdsInToonSquad:(NSString*)value;
- (SendTangoGiftResponseProto_Builder *)addAllTangoUserIdsInToonSquad:(NSArray *)array;
- (SendTangoGiftResponseProto_Builder *)clearTangoUserIdsInToonSquad;
@end

@interface ReceivedGiftResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasScope_:1;
  MinimumUserProto* sender;
  ChatScope scope;
  NSMutableArray * mutableUserGiftsList;
}
- (BOOL) hasSender;
- (BOOL) hasScope;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) ChatScope scope;
@property (readonly, strong) NSArray * userGiftsList;
- (UserGiftProto*)userGiftsAtIndex:(NSUInteger)index;

+ (ReceivedGiftResponseProto*) defaultInstance;
- (ReceivedGiftResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (ReceivedGiftResponseProto_Builder*) builder;
+ (ReceivedGiftResponseProto_Builder*) builder;
+ (ReceivedGiftResponseProto_Builder*) builderWithPrototype:(ReceivedGiftResponseProto*) prototype;
- (ReceivedGiftResponseProto_Builder*) toBuilder;

+ (ReceivedGiftResponseProto*) parseFromData:(NSData*) data;
+ (ReceivedGiftResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ReceivedGiftResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (ReceivedGiftResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ReceivedGiftResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (ReceivedGiftResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface ReceivedGiftResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  ReceivedGiftResponseProto* result;
}

- (ReceivedGiftResponseProto*) defaultInstance;

- (ReceivedGiftResponseProto_Builder*) clear;
- (ReceivedGiftResponseProto_Builder*) clone;

- (ReceivedGiftResponseProto*) build;
- (ReceivedGiftResponseProto*) buildPartial;

- (ReceivedGiftResponseProto_Builder*) mergeFrom:(ReceivedGiftResponseProto*) other;
- (ReceivedGiftResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (ReceivedGiftResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (ReceivedGiftResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (ReceivedGiftResponseProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (ReceivedGiftResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (ReceivedGiftResponseProto_Builder*) clearSender;

- (BOOL) hasScope;
- (ChatScope) scope;
- (ReceivedGiftResponseProto_Builder*) setScope:(ChatScope) value;
- (ReceivedGiftResponseProto_Builder*) clearScopeList;

- (NSMutableArray *)userGiftsList;
- (UserGiftProto*)userGiftsAtIndex:(NSUInteger)index;
- (ReceivedGiftResponseProto_Builder *)addUserGifts:(UserGiftProto*)value;
- (ReceivedGiftResponseProto_Builder *)addAllUserGifts:(NSArray *)array;
- (ReceivedGiftResponseProto_Builder *)clearUserGifts;
@end

@interface DeleteGiftRequestProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  MinimumUserProto* sender;
  NSMutableArray * mutableExpiredGiftsList;
}
- (BOOL) hasSender;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly, strong) NSArray * expiredGiftsList;
- (UserGiftProto*)expiredGiftsAtIndex:(NSUInteger)index;

+ (DeleteGiftRequestProto*) defaultInstance;
- (DeleteGiftRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (DeleteGiftRequestProto_Builder*) builder;
+ (DeleteGiftRequestProto_Builder*) builder;
+ (DeleteGiftRequestProto_Builder*) builderWithPrototype:(DeleteGiftRequestProto*) prototype;
- (DeleteGiftRequestProto_Builder*) toBuilder;

+ (DeleteGiftRequestProto*) parseFromData:(NSData*) data;
+ (DeleteGiftRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (DeleteGiftRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (DeleteGiftRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (DeleteGiftRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (DeleteGiftRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface DeleteGiftRequestProto_Builder : PBGeneratedMessageBuilder {
@private
  DeleteGiftRequestProto* result;
}

- (DeleteGiftRequestProto*) defaultInstance;

- (DeleteGiftRequestProto_Builder*) clear;
- (DeleteGiftRequestProto_Builder*) clone;

- (DeleteGiftRequestProto*) build;
- (DeleteGiftRequestProto*) buildPartial;

- (DeleteGiftRequestProto_Builder*) mergeFrom:(DeleteGiftRequestProto*) other;
- (DeleteGiftRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (DeleteGiftRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (DeleteGiftRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (DeleteGiftRequestProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (DeleteGiftRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (DeleteGiftRequestProto_Builder*) clearSender;

- (NSMutableArray *)expiredGiftsList;
- (UserGiftProto*)expiredGiftsAtIndex:(NSUInteger)index;
- (DeleteGiftRequestProto_Builder *)addExpiredGifts:(UserGiftProto*)value;
- (DeleteGiftRequestProto_Builder *)addAllExpiredGifts:(NSArray *)array;
- (DeleteGiftRequestProto_Builder *)clearExpiredGifts;
@end

@interface DeleteGiftResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  DeleteGiftResponseProto_DeleteGiftStatus status;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) DeleteGiftResponseProto_DeleteGiftStatus status;

+ (DeleteGiftResponseProto*) defaultInstance;
- (DeleteGiftResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (DeleteGiftResponseProto_Builder*) builder;
+ (DeleteGiftResponseProto_Builder*) builder;
+ (DeleteGiftResponseProto_Builder*) builderWithPrototype:(DeleteGiftResponseProto*) prototype;
- (DeleteGiftResponseProto_Builder*) toBuilder;

+ (DeleteGiftResponseProto*) parseFromData:(NSData*) data;
+ (DeleteGiftResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (DeleteGiftResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (DeleteGiftResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (DeleteGiftResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (DeleteGiftResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface DeleteGiftResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  DeleteGiftResponseProto* result;
}

- (DeleteGiftResponseProto*) defaultInstance;

- (DeleteGiftResponseProto_Builder*) clear;
- (DeleteGiftResponseProto_Builder*) clone;

- (DeleteGiftResponseProto*) build;
- (DeleteGiftResponseProto*) buildPartial;

- (DeleteGiftResponseProto_Builder*) mergeFrom:(DeleteGiftResponseProto*) other;
- (DeleteGiftResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (DeleteGiftResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (DeleteGiftResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (DeleteGiftResponseProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (DeleteGiftResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (DeleteGiftResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (DeleteGiftResponseProto_DeleteGiftStatus) status;
- (DeleteGiftResponseProto_Builder*) setStatus:(DeleteGiftResponseProto_DeleteGiftStatus) value;
- (DeleteGiftResponseProto_Builder*) clearStatusList;
@end

@interface CollectGiftRequestProto : PBGeneratedMessage {
@private
  BOOL hasClientTime_:1;
  BOOL hasSender_:1;
  int64_t clientTime;
  MinimumUserProtoWithMaxResources* sender;
  NSMutableArray * mutableUgUuidsList;
}
- (BOOL) hasSender;
- (BOOL) hasClientTime;
@property (readonly, strong) MinimumUserProtoWithMaxResources* sender;
@property (readonly) int64_t clientTime;
@property (readonly, strong) NSArray * ugUuidsList;
- (NSString*)ugUuidsAtIndex:(NSUInteger)index;

+ (CollectGiftRequestProto*) defaultInstance;
- (CollectGiftRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (CollectGiftRequestProto_Builder*) builder;
+ (CollectGiftRequestProto_Builder*) builder;
+ (CollectGiftRequestProto_Builder*) builderWithPrototype:(CollectGiftRequestProto*) prototype;
- (CollectGiftRequestProto_Builder*) toBuilder;

+ (CollectGiftRequestProto*) parseFromData:(NSData*) data;
+ (CollectGiftRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CollectGiftRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (CollectGiftRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CollectGiftRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (CollectGiftRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface CollectGiftRequestProto_Builder : PBGeneratedMessageBuilder {
@private
  CollectGiftRequestProto* result;
}

- (CollectGiftRequestProto*) defaultInstance;

- (CollectGiftRequestProto_Builder*) clear;
- (CollectGiftRequestProto_Builder*) clone;

- (CollectGiftRequestProto*) build;
- (CollectGiftRequestProto*) buildPartial;

- (CollectGiftRequestProto_Builder*) mergeFrom:(CollectGiftRequestProto*) other;
- (CollectGiftRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (CollectGiftRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProtoWithMaxResources*) sender;
- (CollectGiftRequestProto_Builder*) setSender:(MinimumUserProtoWithMaxResources*) value;
- (CollectGiftRequestProto_Builder*) setSender_Builder:(MinimumUserProtoWithMaxResources_Builder*) builderForValue;
- (CollectGiftRequestProto_Builder*) mergeSender:(MinimumUserProtoWithMaxResources*) value;
- (CollectGiftRequestProto_Builder*) clearSender;

- (BOOL) hasClientTime;
- (int64_t) clientTime;
- (CollectGiftRequestProto_Builder*) setClientTime:(int64_t) value;
- (CollectGiftRequestProto_Builder*) clearClientTime;

- (NSMutableArray *)ugUuidsList;
- (NSString*)ugUuidsAtIndex:(NSUInteger)index;
- (CollectGiftRequestProto_Builder *)addUgUuids:(NSString*)value;
- (CollectGiftRequestProto_Builder *)addAllUgUuids:(NSArray *)array;
- (CollectGiftRequestProto_Builder *)clearUgUuids;
@end

@interface CollectGiftResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasReward_:1;
  BOOL hasStatus_:1;
  MinimumUserProtoWithMaxResources* sender;
  UserRewardProto* reward;
  CollectGiftResponseProto_CollectGiftStatus status;
}
- (BOOL) hasSender;
- (BOOL) hasReward;
- (BOOL) hasStatus;
@property (readonly, strong) MinimumUserProtoWithMaxResources* sender;
@property (readonly, strong) UserRewardProto* reward;
@property (readonly) CollectGiftResponseProto_CollectGiftStatus status;

+ (CollectGiftResponseProto*) defaultInstance;
- (CollectGiftResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (CollectGiftResponseProto_Builder*) builder;
+ (CollectGiftResponseProto_Builder*) builder;
+ (CollectGiftResponseProto_Builder*) builderWithPrototype:(CollectGiftResponseProto*) prototype;
- (CollectGiftResponseProto_Builder*) toBuilder;

+ (CollectGiftResponseProto*) parseFromData:(NSData*) data;
+ (CollectGiftResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CollectGiftResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (CollectGiftResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (CollectGiftResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (CollectGiftResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface CollectGiftResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  CollectGiftResponseProto* result;
}

- (CollectGiftResponseProto*) defaultInstance;

- (CollectGiftResponseProto_Builder*) clear;
- (CollectGiftResponseProto_Builder*) clone;

- (CollectGiftResponseProto*) build;
- (CollectGiftResponseProto*) buildPartial;

- (CollectGiftResponseProto_Builder*) mergeFrom:(CollectGiftResponseProto*) other;
- (CollectGiftResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (CollectGiftResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProtoWithMaxResources*) sender;
- (CollectGiftResponseProto_Builder*) setSender:(MinimumUserProtoWithMaxResources*) value;
- (CollectGiftResponseProto_Builder*) setSender_Builder:(MinimumUserProtoWithMaxResources_Builder*) builderForValue;
- (CollectGiftResponseProto_Builder*) mergeSender:(MinimumUserProtoWithMaxResources*) value;
- (CollectGiftResponseProto_Builder*) clearSender;

- (BOOL) hasReward;
- (UserRewardProto*) reward;
- (CollectGiftResponseProto_Builder*) setReward:(UserRewardProto*) value;
- (CollectGiftResponseProto_Builder*) setReward_Builder:(UserRewardProto_Builder*) builderForValue;
- (CollectGiftResponseProto_Builder*) mergeReward:(UserRewardProto*) value;
- (CollectGiftResponseProto_Builder*) clearReward;

- (BOOL) hasStatus;
- (CollectGiftResponseProto_CollectGiftStatus) status;
- (CollectGiftResponseProto_Builder*) setStatus:(CollectGiftResponseProto_CollectGiftStatus) value;
- (CollectGiftResponseProto_Builder*) clearStatusList;
@end


// @@protoc_insertion_point(global_scope)
