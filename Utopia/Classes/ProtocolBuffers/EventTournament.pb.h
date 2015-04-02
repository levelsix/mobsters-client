// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "TournamentStuff.pb.h"
#import "User.pb.h"
// @@protoc_insertion_point(imports)

@class ColorProto;
@class ColorProto_Builder;
@class DefaultLanguagesProto;
@class DefaultLanguagesProto_Builder;
@class FullUserProto;
@class FullUserProto_Builder;
@class GroupChatMessageProto;
@class GroupChatMessageProto_Builder;
@class MinimumClanProto;
@class MinimumClanProto_Builder;
@class MinimumUserProto;
@class MinimumUserProtoWithFacebookId;
@class MinimumUserProtoWithFacebookId_Builder;
@class MinimumUserProtoWithLevel;
@class MinimumUserProtoWithLevelForTournament;
@class MinimumUserProtoWithLevelForTournament_Builder;
@class MinimumUserProtoWithLevel_Builder;
@class MinimumUserProtoWithMaxResources;
@class MinimumUserProtoWithMaxResources_Builder;
@class MinimumUserProto_Builder;
@class PrivateChatDefaultLanguageProto;
@class PrivateChatDefaultLanguageProto_Builder;
@class PrivateChatPostProto;
@class PrivateChatPostProto_Builder;
@class RetrieveTournamentRankingsRequestProto;
@class RetrieveTournamentRankingsRequestProto_Builder;
@class RetrieveTournamentRankingsResponseProto;
@class RetrieveTournamentRankingsResponseProto_Builder;
@class StaticUserLevelInfoProto;
@class StaticUserLevelInfoProto_Builder;
@class TournamentEventProto;
@class TournamentEventProto_Builder;
@class TournamentEventRewardProto;
@class TournamentEventRewardProto_Builder;
@class TranslatedTextProto;
@class TranslatedTextProto_Builder;
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

typedef NS_ENUM(SInt32, RetrieveTournamentRankingsResponseProto_RetrieveTournamentStatus) {
  RetrieveTournamentRankingsResponseProto_RetrieveTournamentStatusSuccess = 1,
  RetrieveTournamentRankingsResponseProto_RetrieveTournamentStatusOtherFail = 2,
};

BOOL RetrieveTournamentRankingsResponseProto_RetrieveTournamentStatusIsValidValue(RetrieveTournamentRankingsResponseProto_RetrieveTournamentStatus value);


@interface EventTournamentRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface RetrieveTournamentRankingsRequestProto : PBGeneratedMessage {
@private
  BOOL hasEventId_:1;
  BOOL hasAfterThisRank_:1;
  BOOL hasSender_:1;
  int32_t eventId;
  int32_t afterThisRank;
  MinimumUserProto* sender;
}
- (BOOL) hasSender;
- (BOOL) hasEventId;
- (BOOL) hasAfterThisRank;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) int32_t eventId;
@property (readonly) int32_t afterThisRank;

+ (RetrieveTournamentRankingsRequestProto*) defaultInstance;
- (RetrieveTournamentRankingsRequestProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (RetrieveTournamentRankingsRequestProto_Builder*) builder;
+ (RetrieveTournamentRankingsRequestProto_Builder*) builder;
+ (RetrieveTournamentRankingsRequestProto_Builder*) builderWithPrototype:(RetrieveTournamentRankingsRequestProto*) prototype;
- (RetrieveTournamentRankingsRequestProto_Builder*) toBuilder;

+ (RetrieveTournamentRankingsRequestProto*) parseFromData:(NSData*) data;
+ (RetrieveTournamentRankingsRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RetrieveTournamentRankingsRequestProto*) parseFromInputStream:(NSInputStream*) input;
+ (RetrieveTournamentRankingsRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RetrieveTournamentRankingsRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (RetrieveTournamentRankingsRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface RetrieveTournamentRankingsRequestProto_Builder : PBGeneratedMessageBuilder {
@private
  RetrieveTournamentRankingsRequestProto* result;
}

- (RetrieveTournamentRankingsRequestProto*) defaultInstance;

- (RetrieveTournamentRankingsRequestProto_Builder*) clear;
- (RetrieveTournamentRankingsRequestProto_Builder*) clone;

- (RetrieveTournamentRankingsRequestProto*) build;
- (RetrieveTournamentRankingsRequestProto*) buildPartial;

- (RetrieveTournamentRankingsRequestProto_Builder*) mergeFrom:(RetrieveTournamentRankingsRequestProto*) other;
- (RetrieveTournamentRankingsRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (RetrieveTournamentRankingsRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (RetrieveTournamentRankingsRequestProto_Builder*) setSender:(MinimumUserProto*) value;
- (RetrieveTournamentRankingsRequestProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (RetrieveTournamentRankingsRequestProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (RetrieveTournamentRankingsRequestProto_Builder*) clearSender;

- (BOOL) hasEventId;
- (int32_t) eventId;
- (RetrieveTournamentRankingsRequestProto_Builder*) setEventId:(int32_t) value;
- (RetrieveTournamentRankingsRequestProto_Builder*) clearEventId;

- (BOOL) hasAfterThisRank;
- (int32_t) afterThisRank;
- (RetrieveTournamentRankingsRequestProto_Builder*) setAfterThisRank:(int32_t) value;
- (RetrieveTournamentRankingsRequestProto_Builder*) clearAfterThisRank;
@end

@interface RetrieveTournamentRankingsResponseProto : PBGeneratedMessage {
@private
  BOOL hasEventId_:1;
  BOOL hasAfterThisRank_:1;
  BOOL hasSender_:1;
  BOOL hasRetriever_:1;
  BOOL hasStatus_:1;
  int32_t eventId;
  int32_t afterThisRank;
  MinimumUserProto* sender;
  MinimumUserProtoWithLevelForTournament* retriever;
  RetrieveTournamentRankingsResponseProto_RetrieveTournamentStatus status;
  NSMutableArray * mutableResultPlayersList;
  NSMutableArray * mutableFullUsersList;
}
- (BOOL) hasSender;
- (BOOL) hasStatus;
- (BOOL) hasEventId;
- (BOOL) hasAfterThisRank;
- (BOOL) hasRetriever;
@property (readonly, strong) MinimumUserProto* sender;
@property (readonly) RetrieveTournamentRankingsResponseProto_RetrieveTournamentStatus status;
@property (readonly) int32_t eventId;
@property (readonly) int32_t afterThisRank;
@property (readonly, strong) MinimumUserProtoWithLevelForTournament* retriever;
@property (readonly, strong) NSArray * resultPlayersList;
@property (readonly, strong) NSArray * fullUsersList;
- (MinimumUserProtoWithLevelForTournament*)resultPlayersAtIndex:(NSUInteger)index;
- (FullUserProto*)fullUsersAtIndex:(NSUInteger)index;

+ (RetrieveTournamentRankingsResponseProto*) defaultInstance;
- (RetrieveTournamentRankingsResponseProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (RetrieveTournamentRankingsResponseProto_Builder*) builder;
+ (RetrieveTournamentRankingsResponseProto_Builder*) builder;
+ (RetrieveTournamentRankingsResponseProto_Builder*) builderWithPrototype:(RetrieveTournamentRankingsResponseProto*) prototype;
- (RetrieveTournamentRankingsResponseProto_Builder*) toBuilder;

+ (RetrieveTournamentRankingsResponseProto*) parseFromData:(NSData*) data;
+ (RetrieveTournamentRankingsResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RetrieveTournamentRankingsResponseProto*) parseFromInputStream:(NSInputStream*) input;
+ (RetrieveTournamentRankingsResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RetrieveTournamentRankingsResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (RetrieveTournamentRankingsResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface RetrieveTournamentRankingsResponseProto_Builder : PBGeneratedMessageBuilder {
@private
  RetrieveTournamentRankingsResponseProto* result;
}

- (RetrieveTournamentRankingsResponseProto*) defaultInstance;

- (RetrieveTournamentRankingsResponseProto_Builder*) clear;
- (RetrieveTournamentRankingsResponseProto_Builder*) clone;

- (RetrieveTournamentRankingsResponseProto*) build;
- (RetrieveTournamentRankingsResponseProto*) buildPartial;

- (RetrieveTournamentRankingsResponseProto_Builder*) mergeFrom:(RetrieveTournamentRankingsResponseProto*) other;
- (RetrieveTournamentRankingsResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (RetrieveTournamentRankingsResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSender;
- (MinimumUserProto*) sender;
- (RetrieveTournamentRankingsResponseProto_Builder*) setSender:(MinimumUserProto*) value;
- (RetrieveTournamentRankingsResponseProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue;
- (RetrieveTournamentRankingsResponseProto_Builder*) mergeSender:(MinimumUserProto*) value;
- (RetrieveTournamentRankingsResponseProto_Builder*) clearSender;

- (BOOL) hasStatus;
- (RetrieveTournamentRankingsResponseProto_RetrieveTournamentStatus) status;
- (RetrieveTournamentRankingsResponseProto_Builder*) setStatus:(RetrieveTournamentRankingsResponseProto_RetrieveTournamentStatus) value;
- (RetrieveTournamentRankingsResponseProto_Builder*) clearStatusList;

- (BOOL) hasEventId;
- (int32_t) eventId;
- (RetrieveTournamentRankingsResponseProto_Builder*) setEventId:(int32_t) value;
- (RetrieveTournamentRankingsResponseProto_Builder*) clearEventId;

- (BOOL) hasAfterThisRank;
- (int32_t) afterThisRank;
- (RetrieveTournamentRankingsResponseProto_Builder*) setAfterThisRank:(int32_t) value;
- (RetrieveTournamentRankingsResponseProto_Builder*) clearAfterThisRank;

- (BOOL) hasRetriever;
- (MinimumUserProtoWithLevelForTournament*) retriever;
- (RetrieveTournamentRankingsResponseProto_Builder*) setRetriever:(MinimumUserProtoWithLevelForTournament*) value;
- (RetrieveTournamentRankingsResponseProto_Builder*) setRetriever_Builder:(MinimumUserProtoWithLevelForTournament_Builder*) builderForValue;
- (RetrieveTournamentRankingsResponseProto_Builder*) mergeRetriever:(MinimumUserProtoWithLevelForTournament*) value;
- (RetrieveTournamentRankingsResponseProto_Builder*) clearRetriever;

- (NSMutableArray *)resultPlayersList;
- (MinimumUserProtoWithLevelForTournament*)resultPlayersAtIndex:(NSUInteger)index;
- (RetrieveTournamentRankingsResponseProto_Builder *)addResultPlayers:(MinimumUserProtoWithLevelForTournament*)value;
- (RetrieveTournamentRankingsResponseProto_Builder *)addAllResultPlayers:(NSArray *)array;
- (RetrieveTournamentRankingsResponseProto_Builder *)clearResultPlayers;

- (NSMutableArray *)fullUsersList;
- (FullUserProto*)fullUsersAtIndex:(NSUInteger)index;
- (RetrieveTournamentRankingsResponseProto_Builder *)addFullUsers:(FullUserProto*)value;
- (RetrieveTournamentRankingsResponseProto_Builder *)addAllFullUsers:(NSArray *)array;
- (RetrieveTournamentRankingsResponseProto_Builder *)clearFullUsers;
@end


// @@protoc_insertion_point(global_scope)
