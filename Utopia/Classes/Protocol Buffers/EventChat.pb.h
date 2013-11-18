// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "Chat.pb.h"
#import "User.pb.h"

@class ColorProto;
@class ColorProto_Builder;
@class FullUserProto;
@class FullUserProto_Builder;
@class GeneralNotificationResponseProto;
@class GeneralNotificationResponseProto_Builder;
@class GroupChatMessageProto;
@class GroupChatMessageProto_Builder;
@class MinimumClanProto;
@class MinimumClanProto_Builder;
@class MinimumUserProto;
@class MinimumUserProtoWithFacebookId;
@class MinimumUserProtoWithFacebookId_Builder;
@class MinimumUserProtoWithLevel;
@class MinimumUserProtoWithLevel_Builder;
@class MinimumUserProto_Builder;
@class PrivateChatPostProto;
@class PrivateChatPostProto_Builder;
@class PrivateChatPostRequestProto;
@class PrivateChatPostRequestProto_Builder;
@class PrivateChatPostResponseProto;
@class PrivateChatPostResponseProto_Builder;
@class ReceivedGroupChatResponseProto;
@class ReceivedGroupChatResponseProto_Builder;
@class RetrievePrivateChatPostsRequestProto;
@class RetrievePrivateChatPostsRequestProto_Builder;
@class RetrievePrivateChatPostsResponseProto;
@class RetrievePrivateChatPostsResponseProto_Builder;
@class SendAdminMessageResponseProto;
@class SendAdminMessageResponseProto_Builder;
@class SendGroupChatRequestProto;
@class SendGroupChatRequestProto_Builder;
@class SendGroupChatResponseProto;
@class SendGroupChatResponseProto_Builder;
@class StaticUserLevelInfoProto;
@class StaticUserLevelInfoProto_Builder;
@class UserFacebookInviteForSlotProto;
@class UserFacebookInviteForSlotProto_Builder;
typedef enum {
  SendGroupChatResponseProto_SendGroupChatStatusSuccess = 1,
  SendGroupChatResponseProto_SendGroupChatStatusTooLong = 2,
  SendGroupChatResponseProto_SendGroupChatStatusOtherFail = 3,
  SendGroupChatResponseProto_SendGroupChatStatusBanned = 4,
} SendGroupChatResponseProto_SendGroupChatStatus;

BOOL SendGroupChatResponseProto_SendGroupChatStatusIsValidValue(SendGroupChatResponseProto_SendGroupChatStatus value);

typedef enum {
  PrivateChatPostResponseProto_PrivateChatPostStatusSuccess = 1,
  PrivateChatPostResponseProto_PrivateChatPostStatusNoContentSent = 2,
  PrivateChatPostResponseProto_PrivateChatPostStatusPostTooLarge = 3,
  PrivateChatPostResponseProto_PrivateChatPostStatusOtherFail = 4,
  PrivateChatPostResponseProto_PrivateChatPostStatusBanned = 5,
} PrivateChatPostResponseProto_PrivateChatPostStatus;

BOOL PrivateChatPostResponseProto_PrivateChatPostStatusIsValidValue(PrivateChatPostResponseProto_PrivateChatPostStatus value);

typedef enum {
  RetrievePrivateChatPostsResponseProto_RetrievePrivateChatPostsStatusSuccess = 1,
  RetrievePrivateChatPostsResponseProto_RetrievePrivateChatPostsStatusFail = 2,
} RetrievePrivateChatPostsResponseProto_RetrievePrivateChatPostsStatus;

BOOL RetrievePrivateChatPostsResponseProto_RetrievePrivateChatPostsStatusIsValidValue(RetrievePrivateChatPostsResponseProto_RetrievePrivateChatPostsStatus value);


@interface EventChatRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface SendAdminMessageResponseProto : PBGeneratedMessage {
@private
  BOOL hasSenderId_:1;
  BOOL hasMessage_:1;
  int32_t senderId;
  NSString* message;
}
- (BOOL) hasSenderId;
- (BOOL) hasMessage;
@property (readonly) int32_t senderId;
@property (readonly, retain) NSString* message;

+ (SendAdminMessageResponseProto*) defaultInstance;
- (SendAdminMessageResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (SendAdminMessageResponseProto_Builder*) builder;
+ (SendAdminMessageResponseProto_Builder*) builder;
+ (SendAdminMessageResponseProto_Builder*) builderWithPrototype:(SendAdminMessageResponseProto*) prototype;

+ (SendAdminMessageResponseProto*) parseFromData:(NSData*) data;
+ (SendAdminMessageResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SendAdminMessageResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (SendAdminMessageResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SendAdminMessageResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (SendAdminMessageResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface SendAdminMessageResponseProto_Builder : PBGeneratedMessage_Builder {
@private
  SendAdminMessageResponseProto* result;
}

- (SendAdminMessageResponseProto*) defaultInstance;

- (SendAdminMessageResponseProto_Builder*) clear;
- (SendAdminMessageResponseProto_Builder*) clone;

- (SendAdminMessageResponseProto*) build;
- (SendAdminMessageResponseProto*) buildPartial;

- (SendAdminMessageResponseProto_Builder*) mergeFrom:(SendAdminMessageResponseProto*) other;
- (SendAdminMessageResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (SendAdminMessageResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSenderId;
- (int32_t) senderId;
- (SendAdminMessageResponseProto_Builder*) setSenderId:(int32_t) value;
- (SendAdminMessageResponseProto_Builder*) clearSenderId;

- (BOOL) hasMessage;
- (NSString*) message;
- (SendAdminMessageResponseProto_Builder*) setMessage:(NSString*) value;
- (SendAdminMessageResponseProto_Builder*) clearMessage;
@end

@interface GeneralNotificationResponseProto : PBGeneratedMessage {
@private
  BOOL hasTitle_:1;
  BOOL hasSubtitle_:1;
  BOOL hasRgb_:1;
  NSString* title;
  NSString* subtitle;
  ColorProto* rgb;
}
- (BOOL) hasTitle;
- (BOOL) hasSubtitle;
- (BOOL) hasRgb;
@property (readonly, retain) NSString* title;
@property (readonly, retain) NSString* subtitle;
@property (readonly, retain) ColorProto* rgb;

+ (GeneralNotificationResponseProto*) defaultInstance;
- (GeneralNotificationResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (GeneralNotificationResponseProto_Builder*) builder;
+ (GeneralNotificationResponseProto_Builder*) builder;
+ (GeneralNotificationResponseProto_Builder*) builderWithPrototype:(GeneralNotificationResponseProto*) prototype;

+ (GeneralNotificationResponseProto*) parseFromData:(NSData*) data;
+ (GeneralNotificationResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (GeneralNotificationResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (GeneralNotificationResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (GeneralNotificationResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (GeneralNotificationResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface GeneralNotificationResponseProto_Builder : PBGeneratedMessage_Builder {
@private
  GeneralNotificationResponseProto* result;
}

- (GeneralNotificationResponseProto*) defaultInstance;

- (GeneralNotificationResponseProto_Builder*) clear;
- (GeneralNotificationResponseProto_Builder*) clone;

- (GeneralNotificationResponseProto*) build;
- (GeneralNotificationResponseProto*) buildPartial;

- (GeneralNotificationResponseProto_Builder*) mergeFrom:(GeneralNotificationResponseProto*) other;
- (GeneralNotificationResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (GeneralNotificationResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasTitle;
- (NSString*) title;
- (GeneralNotificationResponseProto_Builder*) setTitle:(NSString*) value;
- (GeneralNotificationResponseProto_Builder*) clearTitle;

- (BOOL) hasSubtitle;
- (NSString*) subtitle;
- (GeneralNotificationResponseProto_Builder*) setSubtitle:(NSString*) value;
- (GeneralNotificationResponseProto_Builder*) clearSubtitle;

- (BOOL) hasRgb;
- (ColorProto*) rgb;
- (GeneralNotificationResponseProto_Builder*) setRgb:(ColorProto*) value;
- (GeneralNotificationResponseProto_Builder*) setRgbBuilder:(ColorProto_Builder*) builderForValue;
- (GeneralNotificationResponseProto_Builder*) mergeRgb:(ColorProto*) value;
- (GeneralNotificationResponseProto_Builder*) clearRgb;
@end

@interface SendGroupChatRequestProto : PBGeneratedMessage {
@private
  BOOL hasClientTime_:1;
  BOOL hasChatMessage_:1;
  BOOL hasSender_:1;
  BOOL hasScope_:1;
  int64_t clientTime;
  NSString* chatMessage;
  MinimumUserProto* sender;
  GroupChatScope scope;
}
- (BOOL) hasSender;
- (BOOL) hasScope;
- (BOOL) hasChatMessage;
- (BOOL) hasClientTime;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) GroupChatScope scope;
@property (readonly, retain) NSString* chatMessage;
@property (readonly) int64_t clientTime;

+ (SendGroupChatRequestProto*) defaultInstance;
- (SendGroupChatRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (SendGroupChatRequestProto_Builder*) builder;
+ (SendGroupChatRequestProto_Builder*) builder;
+ (SendGroupChatRequestProto_Builder*) builderWithPrototype:(SendGroupChatRequestProto*) prototype;

+ (SendGroupChatRequestProto*) parseFromData:(NSData*) data;
+ (SendGroupChatRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SendGroupChatRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (SendGroupChatRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SendGroupChatRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (SendGroupChatRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface SendGroupChatRequestProto_Builder : PBGeneratedMessage_Builder {
@private
  SendGroupChatRequestProto* result;
}

- (SendGroupChatRequestProto*) defaultInstance;

- (SendGroupChatRequestProto_Builder*) clear;
- (SendGroupChatRequestProto_Builder*) clone;

- (SendGroupChatRequestProto*) build;
- (SendGroupChatRequestProto*) buildPartial;

- (SendGroupChatRequestProto_Builder*) mergeFrom:(SendGroupChatRequestProto*) other;
- (SendGroupChatRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (SendGroupChatRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (SendGroupChatRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (SendGroupChatRequestProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (SendGroupChatRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (SendGroupChatRequestProto_Builder*) clearSender;

- (BOOL) hasScope;
- (GroupChatScope) scope;
- (SendGroupChatRequestProto_Builder*) setScope:(GroupChatScope) value;
- (SendGroupChatRequestProto_Builder*) clearScope;

- (BOOL) hasChatMessage;
- (NSString*) chatMessage;
- (SendGroupChatRequestProto_Builder*) setChatMessage:(NSString*) value;
- (SendGroupChatRequestProto_Builder*) clearChatMessage;

- (BOOL) hasClientTime;
- (int64_t) clientTime;
- (SendGroupChatRequestProto_Builder*) setClientTime:(int64_t) value;
- (SendGroupChatRequestProto_Builder*) clearClientTime;
@end

@interface SendGroupChatResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  SendGroupChatResponseProto_SendGroupChatStatus status;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) SendGroupChatResponseProto_SendGroupChatStatus status;

+ (SendGroupChatResponseProto*) defaultInstance;
- (SendGroupChatResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (SendGroupChatResponseProto_Builder*) builder;
+ (SendGroupChatResponseProto_Builder*) builder;
+ (SendGroupChatResponseProto_Builder*) builderWithPrototype:(SendGroupChatResponseProto*) prototype;

+ (SendGroupChatResponseProto*) parseFromData:(NSData*) data;
+ (SendGroupChatResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SendGroupChatResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (SendGroupChatResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SendGroupChatResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (SendGroupChatResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface SendGroupChatResponseProto_Builder : PBGeneratedMessage_Builder {
@private
  SendGroupChatResponseProto* result;
}

- (SendGroupChatResponseProto*) defaultInstance;

- (SendGroupChatResponseProto_Builder*) clear;
- (SendGroupChatResponseProto_Builder*) clone;

- (SendGroupChatResponseProto*) build;
- (SendGroupChatResponseProto*) buildPartial;

- (SendGroupChatResponseProto_Builder*) mergeFrom:(SendGroupChatResponseProto*) other;
- (SendGroupChatResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (SendGroupChatResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (SendGroupChatResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (SendGroupChatResponseProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (SendGroupChatResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (SendGroupChatResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (SendGroupChatResponseProto_SendGroupChatStatus) status;
- (SendGroupChatResponseProto_Builder*) setStatus:(SendGroupChatResponseProto_SendGroupChatStatus) value;
- (SendGroupChatResponseProto_Builder*) clearStatus;
@end

@interface ReceivedGroupChatResponseProto : PBGeneratedMessage {
@private
  BOOL hasIsAdmin_:1;
  BOOL hasChatMessage_:1;
  BOOL hasSender_:1;
  BOOL hasScope_:1;
  BOOL isAdmin_:1;
  NSString* chatMessage;
  MinimumUserProtoWithLevel* sender;
  GroupChatScope scope;
}
- (BOOL) hasSender;
- (BOOL) hasChatMessage;
- (BOOL) hasScope;
- (BOOL) hasIsAdmin;
@property (readonly, retain) MinimumUserProtoWithLevel* sender;
@property (readonly, retain) NSString* chatMessage;
@property (readonly) GroupChatScope scope;
- (BOOL) isAdmin;

+ (ReceivedGroupChatResponseProto*) defaultInstance;
- (ReceivedGroupChatResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (ReceivedGroupChatResponseProto_Builder*) builder;
+ (ReceivedGroupChatResponseProto_Builder*) builder;
+ (ReceivedGroupChatResponseProto_Builder*) builderWithPrototype:(ReceivedGroupChatResponseProto*) prototype;

+ (ReceivedGroupChatResponseProto*) parseFromData:(NSData*) data;
+ (ReceivedGroupChatResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ReceivedGroupChatResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (ReceivedGroupChatResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ReceivedGroupChatResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (ReceivedGroupChatResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface ReceivedGroupChatResponseProto_Builder : PBGeneratedMessage_Builder {
@private
  ReceivedGroupChatResponseProto* result;
}

- (ReceivedGroupChatResponseProto*) defaultInstance;

- (ReceivedGroupChatResponseProto_Builder*) clear;
- (ReceivedGroupChatResponseProto_Builder*) clone;

- (ReceivedGroupChatResponseProto*) build;
- (ReceivedGroupChatResponseProto*) buildPartial;

- (ReceivedGroupChatResponseProto_Builder*) mergeFrom:(ReceivedGroupChatResponseProto*) other;
- (ReceivedGroupChatResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (ReceivedGroupChatResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProtoWithLevel*) sender;
- (ReceivedGroupChatResponseProto_Builder*) setSender:(MinimumUserProtoWithLevel*) value;
- (ReceivedGroupChatResponseProto_Builder*) setSenderBuilder:(MinimumUserProtoWithLevel_Builder*) builderForValue;
- (ReceivedGroupChatResponseProto_Builder*) mergeSender:(MinimumUserProtoWithLevel*) value;
- (ReceivedGroupChatResponseProto_Builder*) clearSender;

- (BOOL) hasChatMessage;
- (NSString*) chatMessage;
- (ReceivedGroupChatResponseProto_Builder*) setChatMessage:(NSString*) value;
- (ReceivedGroupChatResponseProto_Builder*) clearChatMessage;

- (BOOL) hasScope;
- (GroupChatScope) scope;
- (ReceivedGroupChatResponseProto_Builder*) setScope:(GroupChatScope) value;
- (ReceivedGroupChatResponseProto_Builder*) clearScope;

- (BOOL) hasIsAdmin;
- (BOOL) isAdmin;
- (ReceivedGroupChatResponseProto_Builder*) setIsAdmin:(BOOL) value;
- (ReceivedGroupChatResponseProto_Builder*) clearIsAdmin;
@end

@interface PrivateChatPostRequestProto : PBGeneratedMessage {
@private
  BOOL hasRecipientId_:1;
  BOOL hasContent_:1;
  BOOL hasSender_:1;
  int32_t recipientId;
  NSString* content;
  MinimumUserProto* sender;
}
- (BOOL) hasSender;
- (BOOL) hasRecipientId;
- (BOOL) hasContent;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) int32_t recipientId;
@property (readonly, retain) NSString* content;

+ (PrivateChatPostRequestProto*) defaultInstance;
- (PrivateChatPostRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PrivateChatPostRequestProto_Builder*) builder;
+ (PrivateChatPostRequestProto_Builder*) builder;
+ (PrivateChatPostRequestProto_Builder*) builderWithPrototype:(PrivateChatPostRequestProto*) prototype;

+ (PrivateChatPostRequestProto*) parseFromData:(NSData*) data;
+ (PrivateChatPostRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PrivateChatPostRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (PrivateChatPostRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PrivateChatPostRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PrivateChatPostRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PrivateChatPostRequestProto_Builder : PBGeneratedMessage_Builder {
@private
  PrivateChatPostRequestProto* result;
}

- (PrivateChatPostRequestProto*) defaultInstance;

- (PrivateChatPostRequestProto_Builder*) clear;
- (PrivateChatPostRequestProto_Builder*) clone;

- (PrivateChatPostRequestProto*) build;
- (PrivateChatPostRequestProto*) buildPartial;

- (PrivateChatPostRequestProto_Builder*) mergeFrom:(PrivateChatPostRequestProto*) other;
- (PrivateChatPostRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PrivateChatPostRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (PrivateChatPostRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (PrivateChatPostRequestProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (PrivateChatPostRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (PrivateChatPostRequestProto_Builder*) clearSender;

- (BOOL) hasRecipientId;
- (int32_t) recipientId;
- (PrivateChatPostRequestProto_Builder*) setRecipientId:(int32_t) value;
- (PrivateChatPostRequestProto_Builder*) clearRecipientId;

- (BOOL) hasContent;
- (NSString*) content;
- (PrivateChatPostRequestProto_Builder*) setContent:(NSString*) value;
- (PrivateChatPostRequestProto_Builder*) clearContent;
@end

@interface PrivateChatPostResponseProto : PBGeneratedMessage {
@private
  BOOL hasSender_:1;
  BOOL hasPost_:1;
  BOOL hasStatus_:1;
  MinimumUserProto* sender;
  PrivateChatPostProto* post;
  PrivateChatPostResponseProto_PrivateChatPostStatus status;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
- (BOOL) hasPost;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) PrivateChatPostResponseProto_PrivateChatPostStatus status;
@property (readonly, retain) PrivateChatPostProto* post;

+ (PrivateChatPostResponseProto*) defaultInstance;
- (PrivateChatPostResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PrivateChatPostResponseProto_Builder*) builder;
+ (PrivateChatPostResponseProto_Builder*) builder;
+ (PrivateChatPostResponseProto_Builder*) builderWithPrototype:(PrivateChatPostResponseProto*) prototype;

+ (PrivateChatPostResponseProto*) parseFromData:(NSData*) data;
+ (PrivateChatPostResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PrivateChatPostResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (PrivateChatPostResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PrivateChatPostResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PrivateChatPostResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PrivateChatPostResponseProto_Builder : PBGeneratedMessage_Builder {
@private
  PrivateChatPostResponseProto* result;
}

- (PrivateChatPostResponseProto*) defaultInstance;

- (PrivateChatPostResponseProto_Builder*) clear;
- (PrivateChatPostResponseProto_Builder*) clone;

- (PrivateChatPostResponseProto*) build;
- (PrivateChatPostResponseProto*) buildPartial;

- (PrivateChatPostResponseProto_Builder*) mergeFrom:(PrivateChatPostResponseProto*) other;
- (PrivateChatPostResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PrivateChatPostResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (PrivateChatPostResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (PrivateChatPostResponseProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (PrivateChatPostResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (PrivateChatPostResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (PrivateChatPostResponseProto_PrivateChatPostStatus) status;
- (PrivateChatPostResponseProto_Builder*) setStatus:(PrivateChatPostResponseProto_PrivateChatPostStatus) value;
- (PrivateChatPostResponseProto_Builder*) clearStatus;

- (BOOL) hasPost;
- (PrivateChatPostProto*) post;
- (PrivateChatPostResponseProto_Builder*) setPost:(PrivateChatPostProto*) value;
- (PrivateChatPostResponseProto_Builder*) setPostBuilder:(PrivateChatPostProto_Builder*) builderForValue;
- (PrivateChatPostResponseProto_Builder*) mergePost:(PrivateChatPostProto*) value;
- (PrivateChatPostResponseProto_Builder*) clearPost;
@end

@interface RetrievePrivateChatPostsRequestProto : PBGeneratedMessage {
@private
  BOOL hasOtherUserId_:1;
  BOOL hasBeforePrivateChatId_:1;
  BOOL hasSender_:1;
  int32_t otherUserId;
  int32_t beforePrivateChatId;
  MinimumUserProto* sender;
}
- (BOOL) hasSender;
- (BOOL) hasOtherUserId;
- (BOOL) hasBeforePrivateChatId;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) int32_t otherUserId;
@property (readonly) int32_t beforePrivateChatId;

+ (RetrievePrivateChatPostsRequestProto*) defaultInstance;
- (RetrievePrivateChatPostsRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (RetrievePrivateChatPostsRequestProto_Builder*) builder;
+ (RetrievePrivateChatPostsRequestProto_Builder*) builder;
+ (RetrievePrivateChatPostsRequestProto_Builder*) builderWithPrototype:(RetrievePrivateChatPostsRequestProto*) prototype;

+ (RetrievePrivateChatPostsRequestProto*) parseFromData:(NSData*) data;
+ (RetrievePrivateChatPostsRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RetrievePrivateChatPostsRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (RetrievePrivateChatPostsRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RetrievePrivateChatPostsRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (RetrievePrivateChatPostsRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface RetrievePrivateChatPostsRequestProto_Builder : PBGeneratedMessage_Builder {
@private
  RetrievePrivateChatPostsRequestProto* result;
}

- (RetrievePrivateChatPostsRequestProto*) defaultInstance;

- (RetrievePrivateChatPostsRequestProto_Builder*) clear;
- (RetrievePrivateChatPostsRequestProto_Builder*) clone;

- (RetrievePrivateChatPostsRequestProto*) build;
- (RetrievePrivateChatPostsRequestProto*) buildPartial;

- (RetrievePrivateChatPostsRequestProto_Builder*) mergeFrom:(RetrievePrivateChatPostsRequestProto*) other;
- (RetrievePrivateChatPostsRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (RetrievePrivateChatPostsRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (RetrievePrivateChatPostsRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (RetrievePrivateChatPostsRequestProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (RetrievePrivateChatPostsRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (RetrievePrivateChatPostsRequestProto_Builder*) clearSender;

- (BOOL) hasOtherUserId;
- (int32_t) otherUserId;
- (RetrievePrivateChatPostsRequestProto_Builder*) setOtherUserId:(int32_t) value;
- (RetrievePrivateChatPostsRequestProto_Builder*) clearOtherUserId;

- (BOOL) hasBeforePrivateChatId;
- (int32_t) beforePrivateChatId;
- (RetrievePrivateChatPostsRequestProto_Builder*) setBeforePrivateChatId:(int32_t) value;
- (RetrievePrivateChatPostsRequestProto_Builder*) clearBeforePrivateChatId;
@end

@interface RetrievePrivateChatPostsResponseProto : PBGeneratedMessage {
@private
  BOOL hasBeforePrivateChatId_:1;
  BOOL hasOtherUserId_:1;
  BOOL hasSender_:1;
  BOOL hasStatus_:1;
  int32_t beforePrivateChatId;
  int32_t otherUserId;
  MinimumUserProto* sender;
  RetrievePrivateChatPostsResponseProto_RetrievePrivateChatPostsStatus status;
  NSMutableArray* mutablePostsList;
}
- (BOOL) hasSender;
- (BOOL) hasBeforePrivateChatId;
- (BOOL) hasStatus;
- (BOOL) hasOtherUserId;
@property (readonly, retain) MinimumUserProto* sender;
@property (readonly) int32_t beforePrivateChatId;
@property (readonly) RetrievePrivateChatPostsResponseProto_RetrievePrivateChatPostsStatus status;
@property (readonly) int32_t otherUserId;
- (NSArray*) postsList;
- (GroupChatMessageProto*) postsAtIndex:(int32_t) index;

+ (RetrievePrivateChatPostsResponseProto*) defaultInstance;
- (RetrievePrivateChatPostsResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (RetrievePrivateChatPostsResponseProto_Builder*) builder;
+ (RetrievePrivateChatPostsResponseProto_Builder*) builder;
+ (RetrievePrivateChatPostsResponseProto_Builder*) builderWithPrototype:(RetrievePrivateChatPostsResponseProto*) prototype;

+ (RetrievePrivateChatPostsResponseProto*) parseFromData:(NSData*) data;
+ (RetrievePrivateChatPostsResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RetrievePrivateChatPostsResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (RetrievePrivateChatPostsResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RetrievePrivateChatPostsResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (RetrievePrivateChatPostsResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface RetrievePrivateChatPostsResponseProto_Builder : PBGeneratedMessage_Builder {
@private
  RetrievePrivateChatPostsResponseProto* result;
}

- (RetrievePrivateChatPostsResponseProto*) defaultInstance;

- (RetrievePrivateChatPostsResponseProto_Builder*) clear;
- (RetrievePrivateChatPostsResponseProto_Builder*) clone;

- (RetrievePrivateChatPostsResponseProto*) build;
- (RetrievePrivateChatPostsResponseProto*) buildPartial;

- (RetrievePrivateChatPostsResponseProto_Builder*) mergeFrom:(RetrievePrivateChatPostsResponseProto*) other;
- (RetrievePrivateChatPostsResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (RetrievePrivateChatPostsResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (RetrievePrivateChatPostsResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (RetrievePrivateChatPostsResponseProto_Builder*) setSenderBuilder:(MinimumUserProto_Builder*) builderForValue;
- (RetrievePrivateChatPostsResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (RetrievePrivateChatPostsResponseProto_Builder*) clearSender;

- (NSArray*) postsList;
- (GroupChatMessageProto*) postsAtIndex:(int32_t) index;
- (RetrievePrivateChatPostsResponseProto_Builder*) replacePostsAtIndex:(int32_t) index with:(GroupChatMessageProto*) value;
- (RetrievePrivateChatPostsResponseProto_Builder*) addPosts:(GroupChatMessageProto*) value;
- (RetrievePrivateChatPostsResponseProto_Builder*) addAllPosts:(NSArray*) values;
- (RetrievePrivateChatPostsResponseProto_Builder*) clearPostsList;

- (BOOL) hasBeforePrivateChatId;
- (int32_t) beforePrivateChatId;
- (RetrievePrivateChatPostsResponseProto_Builder*) setBeforePrivateChatId:(int32_t) value;
- (RetrievePrivateChatPostsResponseProto_Builder*) clearBeforePrivateChatId;

- (BOOL) hasStatus;
- (RetrievePrivateChatPostsResponseProto_RetrievePrivateChatPostsStatus) status;
- (RetrievePrivateChatPostsResponseProto_Builder*) setStatus:(RetrievePrivateChatPostsResponseProto_RetrievePrivateChatPostsStatus) value;
- (RetrievePrivateChatPostsResponseProto_Builder*) clearStatus;

- (BOOL) hasOtherUserId;
- (int32_t) otherUserId;
- (RetrievePrivateChatPostsResponseProto_Builder*) setOtherUserId:(int32_t) value;
- (RetrievePrivateChatPostsResponseProto_Builder*) clearOtherUserId;
@end

