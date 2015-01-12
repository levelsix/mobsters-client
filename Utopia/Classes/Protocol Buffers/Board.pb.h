// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "SharedEnumConfig.pb.h"
// @@protoc_insertion_point(imports)

@class BoardLayoutProto;
@class BoardLayoutProto_Builder;
@class BoardPropertyProto;
@class BoardPropertyProto_Builder;
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


@interface BoardRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface BoardLayoutProto : PBGeneratedMessage {
@private
  BOOL hasBoardId_:1;
  BOOL hasHeight_:1;
  BOOL hasWidth_:1;
  BOOL hasOrbElements_:1;
  int32_t boardId;
  int32_t height;
  int32_t width;
  int32_t orbElements;
  NSMutableArray * mutablePropertiesList;
}
- (BOOL) hasBoardId;
- (BOOL) hasHeight;
- (BOOL) hasWidth;
- (BOOL) hasOrbElements;
@property (readonly) int32_t boardId;
@property (readonly) int32_t height;
@property (readonly) int32_t width;
@property (readonly) int32_t orbElements;
@property (readonly, strong) NSArray * propertiesList;
- (BoardPropertyProto*)propertiesAtIndex:(NSUInteger)index;

+ (BoardLayoutProto*) defaultInstance;
- (BoardLayoutProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (BoardLayoutProto_Builder*) builder;
+ (BoardLayoutProto_Builder*) builder;
+ (BoardLayoutProto_Builder*) builderWithPrototype:(BoardLayoutProto*) prototype;
- (BoardLayoutProto_Builder*) toBuilder;

+ (BoardLayoutProto*) parseFromData:(NSData*) data;
+ (BoardLayoutProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BoardLayoutProto*) parseFromInputStream:(NSInputStream*) input;
+ (BoardLayoutProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BoardLayoutProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (BoardLayoutProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface BoardLayoutProto_Builder : PBGeneratedMessageBuilder {
@private
  BoardLayoutProto* result;
}

- (BoardLayoutProto*) defaultInstance;

- (BoardLayoutProto_Builder*) clear;
- (BoardLayoutProto_Builder*) clone;

- (BoardLayoutProto*) build;
- (BoardLayoutProto*) buildPartial;

- (BoardLayoutProto_Builder*) mergeFrom:(BoardLayoutProto*) other;
- (BoardLayoutProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (BoardLayoutProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasBoardId;
- (int32_t) boardId;
- (BoardLayoutProto_Builder*) setBoardId:(int32_t) value;
- (BoardLayoutProto_Builder*) clearBoardId;

- (BOOL) hasHeight;
- (int32_t) height;
- (BoardLayoutProto_Builder*) setHeight:(int32_t) value;
- (BoardLayoutProto_Builder*) clearHeight;

- (BOOL) hasWidth;
- (int32_t) width;
- (BoardLayoutProto_Builder*) setWidth:(int32_t) value;
- (BoardLayoutProto_Builder*) clearWidth;

- (BOOL) hasOrbElements;
- (int32_t) orbElements;
- (BoardLayoutProto_Builder*) setOrbElements:(int32_t) value;
- (BoardLayoutProto_Builder*) clearOrbElements;

- (NSMutableArray *)propertiesList;
- (BoardPropertyProto*)propertiesAtIndex:(NSUInteger)index;
- (BoardLayoutProto_Builder *)addProperties:(BoardPropertyProto*)value;
- (BoardLayoutProto_Builder *)addAllProperties:(NSArray *)array;
- (BoardLayoutProto_Builder *)clearProperties;
@end

@interface BoardPropertyProto : PBGeneratedMessage {
@private
  BOOL hasBoardPropertyId_:1;
  BOOL hasBoardId_:1;
  BOOL hasPosX_:1;
  BOOL hasPosY_:1;
  BOOL hasValue_:1;
  BOOL hasName_:1;
  BOOL hasElem_:1;
  int32_t boardPropertyId;
  int32_t boardId;
  int32_t posX;
  int32_t posY;
  int32_t value;
  NSString* name;
  Element elem;
}
- (BOOL) hasBoardPropertyId;
- (BOOL) hasBoardId;
- (BOOL) hasName;
- (BOOL) hasPosX;
- (BOOL) hasPosY;
- (BOOL) hasElem;
- (BOOL) hasValue;
@property (readonly) int32_t boardPropertyId;
@property (readonly) int32_t boardId;
@property (readonly, strong) NSString* name;
@property (readonly) int32_t posX;
@property (readonly) int32_t posY;
@property (readonly) Element elem;
@property (readonly) int32_t value;

+ (BoardPropertyProto*) defaultInstance;
- (BoardPropertyProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (BoardPropertyProto_Builder*) builder;
+ (BoardPropertyProto_Builder*) builder;
+ (BoardPropertyProto_Builder*) builderWithPrototype:(BoardPropertyProto*) prototype;
- (BoardPropertyProto_Builder*) toBuilder;

+ (BoardPropertyProto*) parseFromData:(NSData*) data;
+ (BoardPropertyProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BoardPropertyProto*) parseFromInputStream:(NSInputStream*) input;
+ (BoardPropertyProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BoardPropertyProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (BoardPropertyProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface BoardPropertyProto_Builder : PBGeneratedMessageBuilder {
@private
  BoardPropertyProto* result;
}

- (BoardPropertyProto*) defaultInstance;

- (BoardPropertyProto_Builder*) clear;
- (BoardPropertyProto_Builder*) clone;

- (BoardPropertyProto*) build;
- (BoardPropertyProto*) buildPartial;

- (BoardPropertyProto_Builder*) mergeFrom:(BoardPropertyProto*) other;
- (BoardPropertyProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (BoardPropertyProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasBoardPropertyId;
- (int32_t) boardPropertyId;
- (BoardPropertyProto_Builder*) setBoardPropertyId:(int32_t) value;
- (BoardPropertyProto_Builder*) clearBoardPropertyId;

- (BOOL) hasBoardId;
- (int32_t) boardId;
- (BoardPropertyProto_Builder*) setBoardId:(int32_t) value;
- (BoardPropertyProto_Builder*) clearBoardId;

- (BOOL) hasName;
- (NSString*) name;
- (BoardPropertyProto_Builder*) setName:(NSString*) value;
- (BoardPropertyProto_Builder*) clearName;

- (BOOL) hasPosX;
- (int32_t) posX;
- (BoardPropertyProto_Builder*) setPosX:(int32_t) value;
- (BoardPropertyProto_Builder*) clearPosX;

- (BOOL) hasPosY;
- (int32_t) posY;
- (BoardPropertyProto_Builder*) setPosY:(int32_t) value;
- (BoardPropertyProto_Builder*) clearPosY;

- (BOOL) hasElem;
- (Element) elem;
- (BoardPropertyProto_Builder*) setElem:(Element) value;
- (BoardPropertyProto_Builder*) clearElemList;

- (BOOL) hasValue;
- (int32_t) value;
- (BoardPropertyProto_Builder*) setValue:(int32_t) value;
- (BoardPropertyProto_Builder*) clearValue;
@end


// @@protoc_insertion_point(global_scope)
