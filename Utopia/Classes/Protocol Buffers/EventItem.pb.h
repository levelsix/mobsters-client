// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "BoosterPackStuff.pb.h"
#import "MonsterStuff.pb.h"
#import "User.pb.h"

@class BoosterDisplayItemProto;
@class BoosterDisplayItemProto_Builder;
@class BoosterItemProto;
@class BoosterItemProto_Builder;
@class BoosterPackProto;
@class BoosterPackProto_Builder;
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
@class RareBoosterPurchaseProto;
@class RareBoosterPurchaseProto_Builder;
@class StaticUserLevelInfoProto;
@class StaticUserLevelInfoProto_Builder;
@class TradeItemForBoosterRequestProto;
@class TradeItemForBoosterRequestProto_Builder;
@class TradeItemForBoosterResponseProto;
@class TradeItemForBoosterResponseProto_Builder;
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
typedef enum {
  TradeItemForBoosterResponseProto_TradeItemForBoosterStatusSuccess = 1,
  TradeItemForBoosterResponseProto_TradeItemForBoosterStatusFailOther = 2,
  TradeItemForBoosterResponseProto_TradeItemForBoosterStatusFailInsufficientItem = 3,
} TradeItemForBoosterResponseProto_TradeItemForBoosterStatus;

BOOL TradeItemForBoosterResponseProto_TradeItemForBoosterStatusIsValidValue(TradeItemForBoosterResponseProto_TradeItemForBoosterStatus value);


@interface EventItemRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface TradeItemForBoosterRequestProto : PBGeneratedMessage {
@private
  BOOL hasClientTime_:1;
  BOOL hasItemId_:1;
  BOOL hasSender_:1;
  int64_t clientTime;
  int32_t itemId;
  MinimumUserProto* sender;
}
- (BOOL) hasSender;
- (BOOL) hasItemId;
- (BOOL) hasClientTime;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) int32_t itemId;
@property (readonly) int64_t clientTime;

+ (TradeItemForBoosterRequestProto*) defaultInstance;
- (TradeItemForBoosterRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (TradeItemForBoosterRequestProto_Builder*) builder;
+ (TradeItemForBoosterRequestProto_Builder*) builder;
+ (TradeItemForBoosterRequestProto_Builder*) builderWithPrototype:(TradeItemForBoosterRequestProto*) prototype;

+ (TradeItemForBoosterRequestProto*) parseFromData:(NSData*) data;
+ (TradeItemForBoosterRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (TradeItemForBoosterRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (TradeItemForBoosterRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (TradeItemForBoosterRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (TradeItemForBoosterRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface TradeItemForBoosterRequestProto_Builder : PBGeneratedMessage_Builder {
@private
  TradeItemForBoosterRequestProto* result;
}

- (TradeItemForBoosterRequestProto*) defaultInstance;

- (TradeItemForBoosterRequestProto_Builder*) clear;
- (TradeItemForBoosterRequestProto_Builder*) clone;

- (TradeItemForBoosterRequestProto*) build;
- (TradeItemForBoosterRequestProto*) buildPartial;

- (TradeItemForBoosterRequestProto_Builder*) mergeFrom:(TradeItemForBoosterRequestProto*) other;
- (TradeItemForBoosterRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (TradeItemForBoosterRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (TradeItemForBoosterRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (TradeItemForBoosterRequestProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (TradeItemForBoosterRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (TradeItemForBoosterRequestProto_Builder*) clearSender;

- (BOOL) hasItemId;
- (int32_t) itemId;
- (TradeItemForBoosterRequestProto_Builder*) setItemId:(int32_t) value;
- (TradeItemForBoosterRequestProto_Builder*) clearItemId;

- (BOOL) hasClientTime;
- (int64_t) clientTime;
- (TradeItemForBoosterRequestProto_Builder*) setClientTime:(int64_t) value;
- (TradeItemForBoosterRequestProto_Builder*) clearClientTime;
@end

@interface TradeItemForBoosterResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasPrize_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  BoosterItemProto* prize;
  TradeItemForBoosterResponseProto_TradeItemForBoosterStatus status;
  NSMutableArray* mutableUpdatedOrNewList;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
- (BOOL) hasPrize;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) TradeItemForBoosterResponseProto_TradeItemForBoosterStatus status;
@property (readonly, retain) BoosterItemProto* prize;
- (NSArray*) updatedOrNewList;
- (FullUserMonsterProto*) updatedOrNewAtIndex:(int32_t) index;

+ (TradeItemForBoosterResponseProto*) defaultInstance;
- (TradeItemForBoosterResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (TradeItemForBoosterResponseProto_Builder*) builder;
+ (TradeItemForBoosterResponseProto_Builder*) builder;
+ (TradeItemForBoosterResponseProto_Builder*) builderWithPrototype:(TradeItemForBoosterResponseProto*) prototype;

+ (TradeItemForBoosterResponseProto*) parseFromData:(NSData*) data;
+ (TradeItemForBoosterResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (TradeItemForBoosterResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (TradeItemForBoosterResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (TradeItemForBoosterResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (TradeItemForBoosterResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface TradeItemForBoosterResponseProto_Builder : PBGeneratedMessage_Builder {
@private
  TradeItemForBoosterResponseProto* result;
}

- (TradeItemForBoosterResponseProto*) defaultInstance;

- (TradeItemForBoosterResponseProto_Builder*) clear;
- (TradeItemForBoosterResponseProto_Builder*) clone;

- (TradeItemForBoosterResponseProto*) build;
- (TradeItemForBoosterResponseProto*) buildPartial;

- (TradeItemForBoosterResponseProto_Builder*) mergeFrom:(TradeItemForBoosterResponseProto*) other;
- (TradeItemForBoosterResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (TradeItemForBoosterResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (TradeItemForBoosterResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (TradeItemForBoosterResponseProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (TradeItemForBoosterResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (TradeItemForBoosterResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (TradeItemForBoosterResponseProto_TradeItemForBoosterStatus) status;
- (TradeItemForBoosterResponseProto_Builder*) setStatus:(TradeItemForBoosterResponseProto_TradeItemForBoosterStatus) value;
- (TradeItemForBoosterResponseProto_Builder*) clearStatus;

- (NSArray*) updatedOrNewList;
- (FullUserMonsterProto*) updatedOrNewAtIndex:(int32_t) index;
- (TradeItemForBoosterResponseProto_Builder*) replaceUpdatedOrNewAtIndex:(int32_t) index with:(FullUserMonsterProto*) value;
- (TradeItemForBoosterResponseProto_Builder*) addUpdatedOrNew:(FullUserMonsterProto*) value;
- (TradeItemForBoosterResponseProto_Builder*) addAllUpdatedOrNew:(NSArray*) values;
- (TradeItemForBoosterResponseProto_Builder*) clearUpdatedOrNewList;

- (BOOL) hasPrize;
- (BoosterItemProto*) prize;
- (TradeItemForBoosterResponseProto_Builder*) setPrize:(BoosterItemProto*) value;
- (TradeItemForBoosterResponseProto_Builder*) setPrizeBuilder:(BoosterItemProto_Builder*) builderForValue;
- (TradeItemForBoosterResponseProto_Builder*) mergePrize:(BoosterItemProto*) value;
- (TradeItemForBoosterResponseProto_Builder*) clearPrize;
@end

