// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "User.pb.h"

@class EnableAPNSRequestProto;
@class EnableAPNSRequestProto_Builder;
@class EnableAPNSResponseProto;
@class EnableAPNSResponseProto_Builder;
@class FullUserProto;
@class FullUserProto_Builder;
@class MinimumClanProto;
@class MinimumClanProto_Builder;
@class MinimumUserProto;
@class MinimumUserProtoWithFacebookId;
@class MinimumUserProtoWithFacebookId_Builder;
@class MinimumUserProtoWithLevel;
@class MinimumUserProtoWithLevel_Builder;
@class MinimumUserProtoWithMaxResources;
@class MinimumUserProtoWithMaxResources_Builder;
@class MinimumUserProto_Builder;
@class StaticUserLevelInfoProto;
@class StaticUserLevelInfoProto_Builder;
@class UserFacebookInviteForSlotProto;
@class UserFacebookInviteForSlotProto_Builder;
typedef enum {
  EnableAPNSResponseProto_EnableAPNSStatusSuccess = 1,
  EnableAPNSResponseProto_EnableAPNSStatusNotEnabled = 2,
} EnableAPNSResponseProto_EnableAPNSStatus;

BOOL EnableAPNSResponseProto_EnableAPNSStatusIsValidValue(EnableAPNSResponseProto_EnableAPNSStatus value);


@interface EventApnsRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface EnableAPNSRequestProto : PBGeneratedMessage {
@private
  BOOL hasDeviceToken_:1;
  BOOL hasSender_:1;
  NSString* deviceToken;
  MinimumUserProto* sender;
}
- (BOOL) hasSender;
- (BOOL) hasDeviceToken;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly, retain) NSString* deviceToken;

+ (EnableAPNSRequestProto*) defaultInstance;
- (EnableAPNSRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (EnableAPNSRequestProto_Builder*) builder;
+ (EnableAPNSRequestProto_Builder*) builder;
+ (EnableAPNSRequestProto_Builder*) builderWithPrototype:(EnableAPNSRequestProto*) prototype;

+ (EnableAPNSRequestProto*) parseFromData:(NSData*) data;
+ (EnableAPNSRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (EnableAPNSRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (EnableAPNSRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (EnableAPNSRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (EnableAPNSRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface EnableAPNSRequestProto_Builder : PBGeneratedMessage_Builder {
@private
  EnableAPNSRequestProto* result;
}

- (EnableAPNSRequestProto*) defaultInstance;

- (EnableAPNSRequestProto_Builder*) clear;
- (EnableAPNSRequestProto_Builder*) clone;

- (EnableAPNSRequestProto*) build;
- (EnableAPNSRequestProto*) buildPartial;

- (EnableAPNSRequestProto_Builder*) mergeFrom:(EnableAPNSRequestProto*) other;
- (EnableAPNSRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (EnableAPNSRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (EnableAPNSRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (EnableAPNSRequestProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (EnableAPNSRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (EnableAPNSRequestProto_Builder*) clearSender;

- (BOOL) hasDeviceToken;
- (NSString*) deviceToken;
- (EnableAPNSRequestProto_Builder*) setDeviceToken:(NSString*) value;
- (EnableAPNSRequestProto_Builder*) clearDeviceToken;
@end

@interface EnableAPNSResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  EnableAPNSResponseProto_EnableAPNSStatus status;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) EnableAPNSResponseProto_EnableAPNSStatus status;

+ (EnableAPNSResponseProto*) defaultInstance;
- (EnableAPNSResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (EnableAPNSResponseProto_Builder*) builder;
+ (EnableAPNSResponseProto_Builder*) builder;
+ (EnableAPNSResponseProto_Builder*) builderWithPrototype:(EnableAPNSResponseProto*) prototype;

+ (EnableAPNSResponseProto*) parseFromData:(NSData*) data;
+ (EnableAPNSResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (EnableAPNSResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (EnableAPNSResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (EnableAPNSResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (EnableAPNSResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface EnableAPNSResponseProto_Builder : PBGeneratedMessage_Builder {
@private
  EnableAPNSResponseProto* result;
}

- (EnableAPNSResponseProto*) defaultInstance;

- (EnableAPNSResponseProto_Builder*) clear;
- (EnableAPNSResponseProto_Builder*) clone;

- (EnableAPNSResponseProto*) build;
- (EnableAPNSResponseProto*) buildPartial;

- (EnableAPNSResponseProto_Builder*) mergeFrom:(EnableAPNSResponseProto*) other;
- (EnableAPNSResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (EnableAPNSResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (EnableAPNSResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (EnableAPNSResponseProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (EnableAPNSResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (EnableAPNSResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (EnableAPNSResponseProto_EnableAPNSStatus) status;
- (EnableAPNSResponseProto_Builder*) setStatus:(EnableAPNSResponseProto_EnableAPNSStatus) value;
- (EnableAPNSResponseProto_Builder*) clearStatus;
@end

