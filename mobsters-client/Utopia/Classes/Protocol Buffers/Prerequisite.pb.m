// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "Prerequisite.pb.h"
// @@protoc_insertion_point(imports)

@implementation PrerequisiteRoot
static PBExtensionRegistry* extensionRegistry = nil;
+ (PBExtensionRegistry*) extensionRegistry {
  return extensionRegistry;
}

+ (void) initialize {
  if (self == [PrerequisiteRoot class]) {
    PBMutableExtensionRegistry* registry = [PBMutableExtensionRegistry registry];
    [self registerAllExtensions:registry];
    [SharedEnumConfigRoot registerAllExtensions:registry];
    extensionRegistry = registry;
  }
}
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry {
}
@end

@interface PrereqProto ()
@property int32_t prereqId;
@property GameType gameType;
@property int32_t gameEntityId;
@property GameType prereqGameType;
@property int32_t prereqGameEntityId;
@property int32_t quantity;
@end

@implementation PrereqProto

- (BOOL) hasPrereqId {
  return !!hasPrereqId_;
}
- (void) setHasPrereqId:(BOOL) value_ {
  hasPrereqId_ = !!value_;
}
@synthesize prereqId;
- (BOOL) hasGameType {
  return !!hasGameType_;
}
- (void) setHasGameType:(BOOL) value_ {
  hasGameType_ = !!value_;
}
@synthesize gameType;
- (BOOL) hasGameEntityId {
  return !!hasGameEntityId_;
}
- (void) setHasGameEntityId:(BOOL) value_ {
  hasGameEntityId_ = !!value_;
}
@synthesize gameEntityId;
- (BOOL) hasPrereqGameType {
  return !!hasPrereqGameType_;
}
- (void) setHasPrereqGameType:(BOOL) value_ {
  hasPrereqGameType_ = !!value_;
}
@synthesize prereqGameType;
- (BOOL) hasPrereqGameEntityId {
  return !!hasPrereqGameEntityId_;
}
- (void) setHasPrereqGameEntityId:(BOOL) value_ {
  hasPrereqGameEntityId_ = !!value_;
}
@synthesize prereqGameEntityId;
- (BOOL) hasQuantity {
  return !!hasQuantity_;
}
- (void) setHasQuantity:(BOOL) value_ {
  hasQuantity_ = !!value_;
}
@synthesize quantity;
- (id) init {
  if ((self = [super init])) {
    self.prereqId = 0;
    self.gameType = GameTypeNoType;
    self.gameEntityId = 0;
    self.prereqGameType = GameTypeNoType;
    self.prereqGameEntityId = 0;
    self.quantity = 0;
  }
  return self;
}
static PrereqProto* defaultPrereqProtoInstance = nil;
+ (void) initialize {
  if (self == [PrereqProto class]) {
    defaultPrereqProtoInstance = [[PrereqProto alloc] init];
  }
}
+ (PrereqProto*) defaultInstance {
  return defaultPrereqProtoInstance;
}
- (PrereqProto*) defaultInstance {
  return defaultPrereqProtoInstance;
}
- (BOOL) isInitialized {
  return YES;
}
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output {
  if (self.hasPrereqId) {
    [output writeInt32:1 value:self.prereqId];
  }
  if (self.hasGameType) {
    [output writeEnum:2 value:self.gameType];
  }
  if (self.hasGameEntityId) {
    [output writeInt32:3 value:self.gameEntityId];
  }
  if (self.hasPrereqGameType) {
    [output writeEnum:4 value:self.prereqGameType];
  }
  if (self.hasPrereqGameEntityId) {
    [output writeInt32:5 value:self.prereqGameEntityId];
  }
  if (self.hasQuantity) {
    [output writeInt32:6 value:self.quantity];
  }
  [self.unknownFields writeToCodedOutputStream:output];
}
- (SInt32) serializedSize {
  __block SInt32 size_ = memoizedSerializedSize;
  if (size_ != -1) {
    return size_;
  }

  size_ = 0;
  if (self.hasPrereqId) {
    size_ += computeInt32Size(1, self.prereqId);
  }
  if (self.hasGameType) {
    size_ += computeEnumSize(2, self.gameType);
  }
  if (self.hasGameEntityId) {
    size_ += computeInt32Size(3, self.gameEntityId);
  }
  if (self.hasPrereqGameType) {
    size_ += computeEnumSize(4, self.prereqGameType);
  }
  if (self.hasPrereqGameEntityId) {
    size_ += computeInt32Size(5, self.prereqGameEntityId);
  }
  if (self.hasQuantity) {
    size_ += computeInt32Size(6, self.quantity);
  }
  size_ += self.unknownFields.serializedSize;
  memoizedSerializedSize = size_;
  return size_;
}
+ (PrereqProto*) parseFromData:(NSData*) data {
  return (PrereqProto*)[[[PrereqProto builder] mergeFromData:data] build];
}
+ (PrereqProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (PrereqProto*)[[[PrereqProto builder] mergeFromData:data extensionRegistry:extensionRegistry] build];
}
+ (PrereqProto*) parseFromInputStream:(NSInputStream*) input {
  return (PrereqProto*)[[[PrereqProto builder] mergeFromInputStream:input] build];
}
+ (PrereqProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (PrereqProto*)[[[PrereqProto builder] mergeFromInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (PrereqProto*) parseFromCodedInputStream:(PBCodedInputStream*) input {
  return (PrereqProto*)[[[PrereqProto builder] mergeFromCodedInputStream:input] build];
}
+ (PrereqProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (PrereqProto*)[[[PrereqProto builder] mergeFromCodedInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (PrereqProto_Builder*) builder {
  return [[PrereqProto_Builder alloc] init];
}
+ (PrereqProto_Builder*) builderWithPrototype:(PrereqProto*) prototype {
  return [[PrereqProto builder] mergeFrom:prototype];
}
- (PrereqProto_Builder*) builder {
  return [PrereqProto builder];
}
- (PrereqProto_Builder*) toBuilder {
  return [PrereqProto builderWithPrototype:self];
}
- (void) writeDescriptionTo:(NSMutableString*) output withIndent:(NSString*) indent {
  if (self.hasPrereqId) {
    [output appendFormat:@"%@%@: %@\n", indent, @"prereqId", [NSNumber numberWithInteger:self.prereqId]];
  }
  if (self.hasGameType) {
    [output appendFormat:@"%@%@: %d\n", indent, @"gameType", self.gameType];
  }
  if (self.hasGameEntityId) {
    [output appendFormat:@"%@%@: %@\n", indent, @"gameEntityId", [NSNumber numberWithInteger:self.gameEntityId]];
  }
  if (self.hasPrereqGameType) {
    [output appendFormat:@"%@%@: %d\n", indent, @"prereqGameType", self.prereqGameType];
  }
  if (self.hasPrereqGameEntityId) {
    [output appendFormat:@"%@%@: %@\n", indent, @"prereqGameEntityId", [NSNumber numberWithInteger:self.prereqGameEntityId]];
  }
  if (self.hasQuantity) {
    [output appendFormat:@"%@%@: %@\n", indent, @"quantity", [NSNumber numberWithInteger:self.quantity]];
  }
  [self.unknownFields writeDescriptionTo:output withIndent:indent];
}
- (BOOL) isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[PrereqProto class]]) {
    return NO;
  }
  PrereqProto *otherMessage = other;
  return
      self.hasPrereqId == otherMessage.hasPrereqId &&
      (!self.hasPrereqId || self.prereqId == otherMessage.prereqId) &&
      self.hasGameType == otherMessage.hasGameType &&
      (!self.hasGameType || self.gameType == otherMessage.gameType) &&
      self.hasGameEntityId == otherMessage.hasGameEntityId &&
      (!self.hasGameEntityId || self.gameEntityId == otherMessage.gameEntityId) &&
      self.hasPrereqGameType == otherMessage.hasPrereqGameType &&
      (!self.hasPrereqGameType || self.prereqGameType == otherMessage.prereqGameType) &&
      self.hasPrereqGameEntityId == otherMessage.hasPrereqGameEntityId &&
      (!self.hasPrereqGameEntityId || self.prereqGameEntityId == otherMessage.prereqGameEntityId) &&
      self.hasQuantity == otherMessage.hasQuantity &&
      (!self.hasQuantity || self.quantity == otherMessage.quantity) &&
      (self.unknownFields == otherMessage.unknownFields || (self.unknownFields != nil && [self.unknownFields isEqual:otherMessage.unknownFields]));
}
- (NSUInteger) hash {
  __block NSUInteger hashCode = 7;
  if (self.hasPrereqId) {
    hashCode = hashCode * 31 + [[NSNumber numberWithInteger:self.prereqId] hash];
  }
  if (self.hasGameType) {
    hashCode = hashCode * 31 + self.gameType;
  }
  if (self.hasGameEntityId) {
    hashCode = hashCode * 31 + [[NSNumber numberWithInteger:self.gameEntityId] hash];
  }
  if (self.hasPrereqGameType) {
    hashCode = hashCode * 31 + self.prereqGameType;
  }
  if (self.hasPrereqGameEntityId) {
    hashCode = hashCode * 31 + [[NSNumber numberWithInteger:self.prereqGameEntityId] hash];
  }
  if (self.hasQuantity) {
    hashCode = hashCode * 31 + [[NSNumber numberWithInteger:self.quantity] hash];
  }
  hashCode = hashCode * 31 + [self.unknownFields hash];
  return hashCode;
}
@end

@interface PrereqProto_Builder()
@property (strong) PrereqProto* result;
@end

@implementation PrereqProto_Builder
@synthesize result;
- (id) init {
  if ((self = [super init])) {
    self.result = [[PrereqProto alloc] init];
  }
  return self;
}
- (PBGeneratedMessage*) internalGetResult {
  return result;
}
- (PrereqProto_Builder*) clear {
  self.result = [[PrereqProto alloc] init];
  return self;
}
- (PrereqProto_Builder*) clone {
  return [PrereqProto builderWithPrototype:result];
}
- (PrereqProto*) defaultInstance {
  return [PrereqProto defaultInstance];
}
- (PrereqProto*) build {
  [self checkInitialized];
  return [self buildPartial];
}
- (PrereqProto*) buildPartial {
  PrereqProto* returnMe = result;
  self.result = nil;
  return returnMe;
}
- (PrereqProto_Builder*) mergeFrom:(PrereqProto*) other {
  if (other == [PrereqProto defaultInstance]) {
    return self;
  }
  if (other.hasPrereqId) {
    [self setPrereqId:other.prereqId];
  }
  if (other.hasGameType) {
    [self setGameType:other.gameType];
  }
  if (other.hasGameEntityId) {
    [self setGameEntityId:other.gameEntityId];
  }
  if (other.hasPrereqGameType) {
    [self setPrereqGameType:other.prereqGameType];
  }
  if (other.hasPrereqGameEntityId) {
    [self setPrereqGameEntityId:other.prereqGameEntityId];
  }
  if (other.hasQuantity) {
    [self setQuantity:other.quantity];
  }
  [self mergeUnknownFields:other.unknownFields];
  return self;
}
- (PrereqProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input {
  return [self mergeFromCodedInputStream:input extensionRegistry:[PBExtensionRegistry emptyRegistry]];
}
- (PrereqProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  PBUnknownFieldSetBuilder* unknownFields = [PBUnknownFieldSet builderWithUnknownFields:self.unknownFields];
  while (YES) {
    SInt32 tag = [input readTag];
    switch (tag) {
      case 0:
        [self setUnknownFields:[unknownFields build]];
        return self;
      default: {
        if (![self parseUnknownField:input unknownFields:unknownFields extensionRegistry:extensionRegistry tag:tag]) {
          [self setUnknownFields:[unknownFields build]];
          return self;
        }
        break;
      }
      case 8: {
        [self setPrereqId:[input readInt32]];
        break;
      }
      case 16: {
        GameType value = (GameType)[input readEnum];
        if (GameTypeIsValidValue(value)) {
          [self setGameType:value];
        } else {
          [unknownFields mergeVarintField:2 value:value];
        }
        break;
      }
      case 24: {
        [self setGameEntityId:[input readInt32]];
        break;
      }
      case 32: {
        GameType value = (GameType)[input readEnum];
        if (GameTypeIsValidValue(value)) {
          [self setPrereqGameType:value];
        } else {
          [unknownFields mergeVarintField:4 value:value];
        }
        break;
      }
      case 40: {
        [self setPrereqGameEntityId:[input readInt32]];
        break;
      }
      case 48: {
        [self setQuantity:[input readInt32]];
        break;
      }
    }
  }
}
- (BOOL) hasPrereqId {
  return result.hasPrereqId;
}
- (int32_t) prereqId {
  return result.prereqId;
}
- (PrereqProto_Builder*) setPrereqId:(int32_t) value {
  result.hasPrereqId = YES;
  result.prereqId = value;
  return self;
}
- (PrereqProto_Builder*) clearPrereqId {
  result.hasPrereqId = NO;
  result.prereqId = 0;
  return self;
}
- (BOOL) hasGameType {
  return result.hasGameType;
}
- (GameType) gameType {
  return result.gameType;
}
- (PrereqProto_Builder*) setGameType:(GameType) value {
  result.hasGameType = YES;
  result.gameType = value;
  return self;
}
- (PrereqProto_Builder*) clearGameType {
  result.hasGameType = NO;
  result.gameType = GameTypeNoType;
  return self;
}
- (BOOL) hasGameEntityId {
  return result.hasGameEntityId;
}
- (int32_t) gameEntityId {
  return result.gameEntityId;
}
- (PrereqProto_Builder*) setGameEntityId:(int32_t) value {
  result.hasGameEntityId = YES;
  result.gameEntityId = value;
  return self;
}
- (PrereqProto_Builder*) clearGameEntityId {
  result.hasGameEntityId = NO;
  result.gameEntityId = 0;
  return self;
}
- (BOOL) hasPrereqGameType {
  return result.hasPrereqGameType;
}
- (GameType) prereqGameType {
  return result.prereqGameType;
}
- (PrereqProto_Builder*) setPrereqGameType:(GameType) value {
  result.hasPrereqGameType = YES;
  result.prereqGameType = value;
  return self;
}
- (PrereqProto_Builder*) clearPrereqGameType {
  result.hasPrereqGameType = NO;
  result.prereqGameType = GameTypeNoType;
  return self;
}
- (BOOL) hasPrereqGameEntityId {
  return result.hasPrereqGameEntityId;
}
- (int32_t) prereqGameEntityId {
  return result.prereqGameEntityId;
}
- (PrereqProto_Builder*) setPrereqGameEntityId:(int32_t) value {
  result.hasPrereqGameEntityId = YES;
  result.prereqGameEntityId = value;
  return self;
}
- (PrereqProto_Builder*) clearPrereqGameEntityId {
  result.hasPrereqGameEntityId = NO;
  result.prereqGameEntityId = 0;
  return self;
}
- (BOOL) hasQuantity {
  return result.hasQuantity;
}
- (int32_t) quantity {
  return result.quantity;
}
- (PrereqProto_Builder*) setQuantity:(int32_t) value {
  result.hasQuantity = YES;
  result.quantity = value;
  return self;
}
- (PrereqProto_Builder*) clearQuantity {
  result.hasQuantity = NO;
  result.quantity = 0;
  return self;
}
@end


// @@protoc_insertion_point(global_scope)
