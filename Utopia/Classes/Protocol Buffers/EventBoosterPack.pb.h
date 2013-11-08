// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "BoosterPackStuff.pb.h"
#import "User.pb.h"

@class BoosterItemProto;
@class BoosterItemProto_Builder;
@class BoosterPackProto;
@class BoosterPackProto_Builder;
@class FullUserProto;
@class FullUserProto_Builder;
@class MinimumClanProto;
@class MinimumClanProto_Builder;
@class MinimumUserProto;
@class MinimumUserProtoWithFacebookId;
@class MinimumUserProtoWithFacebookId_Builder;
@class MinimumUserProtoWithLevel;
@class MinimumUserProtoWithLevel_Builder;
@class MinimumUserProto_Builder;
@class PurchaseBoosterPackRequestProto;
@class PurchaseBoosterPackRequestProto_Builder;
@class PurchaseBoosterPackResponseProto;
@class PurchaseBoosterPackResponseProto_Builder;
@class RareBoosterPurchaseProto;
@class RareBoosterPurchaseProto_Builder;
@class ReceivedRareBoosterPurchaseResponseProto;
@class ReceivedRareBoosterPurchaseResponseProto_Builder;
@class RetrieveBoosterPackRequestProto;
@class RetrieveBoosterPackRequestProto_Builder;
@class RetrieveBoosterPackResponseProto;
@class RetrieveBoosterPackResponseProto_Builder;
@class StaticLevelInfoProto;
@class StaticLevelInfoProto_Builder;
@class UserFacebookInviteForSlotProto;
@class UserFacebookInviteForSlotProto_Builder;
typedef enum {
  RetrieveBoosterPackResponseProto_RetrieveBoosterPackStatusSuccess = 1,
  RetrieveBoosterPackResponseProto_RetrieveBoosterPackStatusSomeFail = 2,
} RetrieveBoosterPackResponseProto_RetrieveBoosterPackStatus;

BOOL RetrieveBoosterPackResponseProto_RetrieveBoosterPackStatusIsValidValue(RetrieveBoosterPackResponseProto_RetrieveBoosterPackStatus value);

typedef enum {
  PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatusSuccess = 1,
  PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatusNotEnoughGold = 2,
  PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatusNotEnoughSilver = 3,
  PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatusOtherFail = 4,
  PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatusClientTooApartFromServerTime = 5,
} PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatus;

BOOL PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatusIsValidValue(PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatus value);


@interface EventBoosterPackRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface RetrieveBoosterPackRequestProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  MinimumUserProto* sender;
}
- (BOOL) hasSender;
@property (readonly, retain) MinimumUserProto* sender;

+ (RetrieveBoosterPackRequestProto*) defaultInstance;
- (RetrieveBoosterPackRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (RetrieveBoosterPackRequestProto_Builder*) builder;
+ (RetrieveBoosterPackRequestProto_Builder*) builder;
+ (RetrieveBoosterPackRequestProto_Builder*) builderWithPrototype:(RetrieveBoosterPackRequestProto*) prototype;

+ (RetrieveBoosterPackRequestProto*) parseFromData:(NSData*) data;
+ (RetrieveBoosterPackRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RetrieveBoosterPackRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (RetrieveBoosterPackRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RetrieveBoosterPackRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (RetrieveBoosterPackRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface RetrieveBoosterPackRequestProto_Builder : PBGeneratedMessage_Builder {
@private
  RetrieveBoosterPackRequestProto* result;
}

- (RetrieveBoosterPackRequestProto*) defaultInstance;

- (RetrieveBoosterPackRequestProto_Builder*) clear;
- (RetrieveBoosterPackRequestProto_Builder*) clone;

- (RetrieveBoosterPackRequestProto*) build;
- (RetrieveBoosterPackRequestProto*) buildPartial;

- (RetrieveBoosterPackRequestProto_Builder*) mergeFrom:(RetrieveBoosterPackRequestProto*) other;
- (RetrieveBoosterPackRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (RetrieveBoosterPackRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (RetrieveBoosterPackRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (RetrieveBoosterPackRequestProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (RetrieveBoosterPackRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (RetrieveBoosterPackRequestProto_Builder*) clearSender;
@end

@interface RetrieveBoosterPackResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  RetrieveBoosterPackResponseProto_RetrieveBoosterPackStatus status;
  NSMutableArray* mutablePacksList;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) RetrieveBoosterPackResponseProto_RetrieveBoosterPackStatus status;
- (NSArray*) packsList;
- (BoosterPackProto*) packsAtIndex:(int32_t) index;

+ (RetrieveBoosterPackResponseProto*) defaultInstance;
- (RetrieveBoosterPackResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (RetrieveBoosterPackResponseProto_Builder*) builder;
+ (RetrieveBoosterPackResponseProto_Builder*) builder;
+ (RetrieveBoosterPackResponseProto_Builder*) builderWithPrototype:(RetrieveBoosterPackResponseProto*) prototype;

+ (RetrieveBoosterPackResponseProto*) parseFromData:(NSData*) data;
+ (RetrieveBoosterPackResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RetrieveBoosterPackResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (RetrieveBoosterPackResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RetrieveBoosterPackResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (RetrieveBoosterPackResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface RetrieveBoosterPackResponseProto_Builder : PBGeneratedMessage_Builder {
@private
  RetrieveBoosterPackResponseProto* result;
}

- (RetrieveBoosterPackResponseProto*) defaultInstance;

- (RetrieveBoosterPackResponseProto_Builder*) clear;
- (RetrieveBoosterPackResponseProto_Builder*) clone;

- (RetrieveBoosterPackResponseProto*) build;
- (RetrieveBoosterPackResponseProto*) buildPartial;

- (RetrieveBoosterPackResponseProto_Builder*) mergeFrom:(RetrieveBoosterPackResponseProto*) other;
- (RetrieveBoosterPackResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (RetrieveBoosterPackResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (RetrieveBoosterPackResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (RetrieveBoosterPackResponseProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (RetrieveBoosterPackResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (RetrieveBoosterPackResponseProto_Builder*) clearSender;

- (NSArray*) packsList;
- (BoosterPackProto*) packsAtIndex:(int32_t) index;
- (RetrieveBoosterPackResponseProto_Builder*) replacePacksAtIndex:(int32_t) index with:(BoosterPackProto*) value;
- (RetrieveBoosterPackResponseProto_Builder*) addPacks:(BoosterPackProto*) value;
- (RetrieveBoosterPackResponseProto_Builder*) addAllPacks:(NSArray*) values;
- (RetrieveBoosterPackResponseProto_Builder*) clearPacksList;

- (BOOL) hasStatus;
- (RetrieveBoosterPackResponseProto_RetrieveBoosterPackStatus) status;
- (RetrieveBoosterPackResponseProto_Builder*) setStatus:(RetrieveBoosterPackResponseProto_RetrieveBoosterPackStatus) value;
- (RetrieveBoosterPackResponseProto_Builder*) clearStatus;
@end

@interface PurchaseBoosterPackRequestProto : PBGeneratedMessage {
@private
  BOOL hasClientTime_:1;
  BOOL hasBoosterPackId_:1;
  BOOL hasSender_:1;
  int64_t clientTime;
  int32_t boosterPackId;
  MinimumUserProto* sender;
}
- (BOOL) hasSender;
- (BOOL) hasBoosterPackId;
- (BOOL) hasClientTime;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) int32_t boosterPackId;
@property (readonly) int64_t clientTime;

+ (PurchaseBoosterPackRequestProto*) defaultInstance;
- (PurchaseBoosterPackRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PurchaseBoosterPackRequestProto_Builder*) builder;
+ (PurchaseBoosterPackRequestProto_Builder*) builder;
+ (PurchaseBoosterPackRequestProto_Builder*) builderWithPrototype:(PurchaseBoosterPackRequestProto*) prototype;

+ (PurchaseBoosterPackRequestProto*) parseFromData:(NSData*) data;
+ (PurchaseBoosterPackRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PurchaseBoosterPackRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (PurchaseBoosterPackRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PurchaseBoosterPackRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PurchaseBoosterPackRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PurchaseBoosterPackRequestProto_Builder : PBGeneratedMessage_Builder {
@private
  PurchaseBoosterPackRequestProto* result;
}

- (PurchaseBoosterPackRequestProto*) defaultInstance;

- (PurchaseBoosterPackRequestProto_Builder*) clear;
- (PurchaseBoosterPackRequestProto_Builder*) clone;

- (PurchaseBoosterPackRequestProto*) build;
- (PurchaseBoosterPackRequestProto*) buildPartial;

- (PurchaseBoosterPackRequestProto_Builder*) mergeFrom:(PurchaseBoosterPackRequestProto*) other;
- (PurchaseBoosterPackRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PurchaseBoosterPackRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (PurchaseBoosterPackRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (PurchaseBoosterPackRequestProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (PurchaseBoosterPackRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (PurchaseBoosterPackRequestProto_Builder*) clearSender;

- (BOOL) hasBoosterPackId;
- (int32_t) boosterPackId;
- (PurchaseBoosterPackRequestProto_Builder*) setBoosterPackId:(int32_t) value;
- (PurchaseBoosterPackRequestProto_Builder*) clearBoosterPackId;

- (BOOL) hasClientTime;
- (int64_t) clientTime;
- (PurchaseBoosterPackRequestProto_Builder*) setClientTime:(int64_t) value;
- (PurchaseBoosterPackRequestProto_Builder*) clearClientTime;
@end

@interface PurchaseBoosterPackResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatus status;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatus status;

+ (PurchaseBoosterPackResponseProto*) defaultInstance;
- (PurchaseBoosterPackResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PurchaseBoosterPackResponseProto_Builder*) builder;
+ (PurchaseBoosterPackResponseProto_Builder*) builder;
+ (PurchaseBoosterPackResponseProto_Builder*) builderWithPrototype:(PurchaseBoosterPackResponseProto*) prototype;

+ (PurchaseBoosterPackResponseProto*) parseFromData:(NSData*) data;
+ (PurchaseBoosterPackResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PurchaseBoosterPackResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (PurchaseBoosterPackResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PurchaseBoosterPackResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PurchaseBoosterPackResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PurchaseBoosterPackResponseProto_Builder : PBGeneratedMessage_Builder {
@private
  PurchaseBoosterPackResponseProto* result;
}

- (PurchaseBoosterPackResponseProto*) defaultInstance;

- (PurchaseBoosterPackResponseProto_Builder*) clear;
- (PurchaseBoosterPackResponseProto_Builder*) clone;

- (PurchaseBoosterPackResponseProto*) build;
- (PurchaseBoosterPackResponseProto*) buildPartial;

- (PurchaseBoosterPackResponseProto_Builder*) mergeFrom:(PurchaseBoosterPackResponseProto*) other;
- (PurchaseBoosterPackResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PurchaseBoosterPackResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (PurchaseBoosterPackResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (PurchaseBoosterPackResponseProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (PurchaseBoosterPackResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (PurchaseBoosterPackResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatus) status;
- (PurchaseBoosterPackResponseProto_Builder*) setStatus:(PurchaseBoosterPackResponseProto_PurchaseBoosterPackStatus) value;
- (PurchaseBoosterPackResponseProto_Builder*) clearStatus;
@end

@interface ReceivedRareBoosterPurchaseResponseProto : PBGeneratedMessage {
@private
  BOOL hasRareBoosterPurchase_:1;
  RareBoosterPurchaseProto* rareBoosterPurchase;
}
- (BOOL) hasRareBoosterPurchase;
@property (readonly, retain) RareBoosterPurchaseProto* rareBoosterPurchase;

+ (ReceivedRareBoosterPurchaseResponseProto*) defaultInstance;
- (ReceivedRareBoosterPurchaseResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (ReceivedRareBoosterPurchaseResponseProto_Builder*) builder;
+ (ReceivedRareBoosterPurchaseResponseProto_Builder*) builder;
+ (ReceivedRareBoosterPurchaseResponseProto_Builder*) builderWithPrototype:(ReceivedRareBoosterPurchaseResponseProto*) prototype;

+ (ReceivedRareBoosterPurchaseResponseProto*) parseFromData:(NSData*) data;
+ (ReceivedRareBoosterPurchaseResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ReceivedRareBoosterPurchaseResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (ReceivedRareBoosterPurchaseResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ReceivedRareBoosterPurchaseResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (ReceivedRareBoosterPurchaseResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface ReceivedRareBoosterPurchaseResponseProto_Builder : PBGeneratedMessage_Builder {
@private
  ReceivedRareBoosterPurchaseResponseProto* result;
}

- (ReceivedRareBoosterPurchaseResponseProto*) defaultInstance;

- (ReceivedRareBoosterPurchaseResponseProto_Builder*) clear;
- (ReceivedRareBoosterPurchaseResponseProto_Builder*) clone;

- (ReceivedRareBoosterPurchaseResponseProto*) build;
- (ReceivedRareBoosterPurchaseResponseProto*) buildPartial;

- (ReceivedRareBoosterPurchaseResponseProto_Builder*) mergeFrom:(ReceivedRareBoosterPurchaseResponseProto*) other;
- (ReceivedRareBoosterPurchaseResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (ReceivedRareBoosterPurchaseResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasRareBoosterPurchase;
- (RareBoosterPurchaseProto*) rareBoosterPurchase;
- (ReceivedRareBoosterPurchaseResponseProto_Builder*) setRareBoosterPurchase:(RareBoosterPurchaseProto*) value;
- (ReceivedRareBoosterPurchaseResponseProto_Builder*) setRareBoosterPurchaseBuilder:(RareBoosterPurchaseProto_Builder*) builderForValue;
- (ReceivedRareBoosterPurchaseResponseProto_Builder*) mergeRareBoosterPurchase:(RareBoosterPurchaseProto*) value;
- (ReceivedRareBoosterPurchaseResponseProto_Builder*) clearRareBoosterPurchase;
@end

