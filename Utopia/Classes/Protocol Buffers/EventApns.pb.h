// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "User.pb.h"
// @@protoc_insertion_point(imports)

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

typedef NS_ENUM(SInt32, EnableAPNSResponseProto_EnableAPNSStatus) {
  EnableAPNSResponseProto_EnableAPNSStatusSuccess = 1,
  EnableAPNSResponseProto_EnableAPNSStatusNotEnabled = 2,
};

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
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly, strong) NSString* deviceToken;

+ (EnableAPNSRequestProto*) defaultInstance;
- (EnableAPNSRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (EnableAPNSRequestProto_Builder*) builder;
+ (EnableAPNSRequestProto_Builder*) builder;
+ (EnableAPNSRequestProto_Builder*) builderWithPrototype:(EnableAPNSRequestProto*) prototype;
- (EnableAPNSRequestProto_Builder*) toBuilder;

+ (EnableAPNSRequestProto*) parseFromData:(NSData*) data;
+ (EnableAPNSRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (EnableAPNSRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (EnableAPNSRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (EnableAPNSRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (EnableAPNSRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface EnableAPNSRequestProto_Builder : PBGeneratedMessageBuilder {
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
- (EnableAPNSRequestProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
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
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) EnableAPNSResponseProto_EnableAPNSStatus status;

+ (EnableAPNSResponseProto*) defaultInstance;
- (EnableAPNSResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (EnableAPNSResponseProto_Builder*) builder;
+ (EnableAPNSResponseProto_Builder*) builder;
+ (EnableAPNSResponseProto_Builder*) builderWithPrototype:(EnableAPNSResponseProto*) prototype;
- (EnableAPNSResponseProto_Builder*) toBuilder;

+ (EnableAPNSResponseProto*) parseFromData:(NSData*) data;
+ (EnableAPNSResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (EnableAPNSResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (EnableAPNSResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (EnableAPNSResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (EnableAPNSResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface EnableAPNSResponseProto_Builder : PBGeneratedMessageBuilder {
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
- (EnableAPNSResponseProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (EnableAPNSResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (EnableAPNSResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (EnableAPNSResponseProto_EnableAPNSStatus) status;
- (EnableAPNSResponseProto_Builder*) setStatus:(EnableAPNSResponseProto_EnableAPNSStatus) value;
- (EnableAPNSResponseProto_Builder*) clearStatus;
@end


// @@protoc_insertion_point(global_scope)
