// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "EventHeartbeat.pb.h"
// @@protoc_insertion_point(imports)

@implementation EventHeartbeatRoot
static PBExtensionRegistry* extensionRegistry = nil;
+ (PBExtensionRegistry*) extensionRegistry {
  return extensionRegistry;
}

+ (void) initialize {
  if (self == [EventHeartbeatRoot class]) {
    PBMutableExtensionRegistry* registry = [PBMutableExtensionRegistry registry];
    [self registerAllExtensions:registry];
    [UserRoot registerAllExtensions:registry];
    extensionRegistry = registry;
  }
}
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry {
}
@end

@interface HeartbeatRequestProto ()
@property (strong) NSString* heartbeatUuid;
@end

@implementation HeartbeatRequestProto

- (BOOL) hasHeartbeatUuid {
  return !!hasHeartbeatUuid_;
}
- (void) setHasHeartbeatUuid:(BOOL) value_ {
  hasHeartbeatUuid_ = !!value_;
}
@synthesize heartbeatUuid;
- (id) init {
  if ((self = [super init])) {
    self.heartbeatUuid = @"";
  }
  return self;
}
static HeartbeatRequestProto* defaultHeartbeatRequestProtoInstance = nil;
+ (void) initialize {
  if (self == [HeartbeatRequestProto class]) {
    defaultHeartbeatRequestProtoInstance = [[HeartbeatRequestProto alloc] init];
  }
}
+ (HeartbeatRequestProto*) defaultInstance {
  return defaultHeartbeatRequestProtoInstance;
}
- (HeartbeatRequestProto*) defaultInstance {
  return defaultHeartbeatRequestProtoInstance;
}
- (BOOL) isInitialized {
  return YES;
}
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output {
  if (self.hasHeartbeatUuid) {
    [output writeString:1 value:self.heartbeatUuid];
  }
  [self.unknownFields writeToCodedOutputStream:output];
}
- (SInt32) serializedSize {
  __block SInt32 size_ = memoizedSerializedSize;
  if (size_ != -1) {
    return size_;
  }

  size_ = 0;
  if (self.hasHeartbeatUuid) {
    size_ += computeStringSize(1, self.heartbeatUuid);
  }
  size_ += self.unknownFields.serializedSize;
  memoizedSerializedSize = size_;
  return size_;
}
+ (HeartbeatRequestProto*) parseFromData:(NSData*) data {
  return (HeartbeatRequestProto*)[[[HeartbeatRequestProto builder] mergeFromData:data] build];
}
+ (HeartbeatRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (HeartbeatRequestProto*)[[[HeartbeatRequestProto builder] mergeFromData:data extensionRegistry:extensionRegistry] build];
}
+ (HeartbeatRequestProto*) parseFromInputStream:(NSInputStream*) input {
  return (HeartbeatRequestProto*)[[[HeartbeatRequestProto builder] mergeFromInputStream:input] build];
}
+ (HeartbeatRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (HeartbeatRequestProto*)[[[HeartbeatRequestProto builder] mergeFromInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (HeartbeatRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input {
  return (HeartbeatRequestProto*)[[[HeartbeatRequestProto builder] mergeFromCodedInputStream:input] build];
}
+ (HeartbeatRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (HeartbeatRequestProto*)[[[HeartbeatRequestProto builder] mergeFromCodedInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (HeartbeatRequestProto_Builder*) builder {
  return [[HeartbeatRequestProto_Builder alloc] init];
}
+ (HeartbeatRequestProto_Builder*) builderWithPrototype:(HeartbeatRequestProto*) prototype {
  return [[HeartbeatRequestProto builder] mergeFrom:prototype];
}
- (HeartbeatRequestProto_Builder*) builder {
  return [HeartbeatRequestProto builder];
}
- (HeartbeatRequestProto_Builder*) toBuilder {
  return [HeartbeatRequestProto builderWithPrototype:self];
}
- (void) writeDescriptionTo:(NSMutableString*) output withIndent:(NSString*) indent {
  if (self.hasHeartbeatUuid) {
    [output appendFormat:@"%@%@: %@\n", indent, @"heartbeatUuid", self.heartbeatUuid];
  }
  [self.unknownFields writeDescriptionTo:output withIndent:indent];
}
- (BOOL) isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[HeartbeatRequestProto class]]) {
    return NO;
  }
  HeartbeatRequestProto *otherMessage = other;
  return
      self.hasHeartbeatUuid == otherMessage.hasHeartbeatUuid &&
      (!self.hasHeartbeatUuid || [self.heartbeatUuid isEqual:otherMessage.heartbeatUuid]) &&
      (self.unknownFields == otherMessage.unknownFields || (self.unknownFields != nil && [self.unknownFields isEqual:otherMessage.unknownFields]));
}
- (NSUInteger) hash {
  __block NSUInteger hashCode = 7;
  if (self.hasHeartbeatUuid) {
    hashCode = hashCode * 31 + [self.heartbeatUuid hash];
  }
  hashCode = hashCode * 31 + [self.unknownFields hash];
  return hashCode;
}
@end

@interface HeartbeatRequestProto_Builder()
@property (strong) HeartbeatRequestProto* result;
@end

@implementation HeartbeatRequestProto_Builder
@synthesize result;
- (id) init {
  if ((self = [super init])) {
    self.result = [[HeartbeatRequestProto alloc] init];
  }
  return self;
}
- (PBGeneratedMessage*) internalGetResult {
  return result;
}
- (HeartbeatRequestProto_Builder*) clear {
  self.result = [[HeartbeatRequestProto alloc] init];
  return self;
}
- (HeartbeatRequestProto_Builder*) clone {
  return [HeartbeatRequestProto builderWithPrototype:result];
}
- (HeartbeatRequestProto*) defaultInstance {
  return [HeartbeatRequestProto defaultInstance];
}
- (HeartbeatRequestProto*) build {
  [self checkInitialized];
  return [self buildPartial];
}
- (HeartbeatRequestProto*) buildPartial {
  HeartbeatRequestProto* returnMe = result;
  self.result = nil;
  return returnMe;
}
- (HeartbeatRequestProto_Builder*) mergeFrom:(HeartbeatRequestProto*) other {
  if (other == [HeartbeatRequestProto defaultInstance]) {
    return self;
  }
  if (other.hasHeartbeatUuid) {
    [self setHeartbeatUuid:other.heartbeatUuid];
  }
  [self mergeUnknownFields:other.unknownFields];
  return self;
}
- (HeartbeatRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input {
  return [self mergeFromCodedInputStream:input extensionRegistry:[PBExtensionRegistry emptyRegistry]];
}
- (HeartbeatRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
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
      case 10: {
        [self setHeartbeatUuid:[input readString]];
        break;
      }
    }
  }
}
- (BOOL) hasHeartbeatUuid {
  return result.hasHeartbeatUuid;
}
- (NSString*) heartbeatUuid {
  return result.heartbeatUuid;
}
- (HeartbeatRequestProto_Builder*) setHeartbeatUuid:(NSString*) value {
  result.hasHeartbeatUuid = YES;
  result.heartbeatUuid = value;
  return self;
}
- (HeartbeatRequestProto_Builder*) clearHeartbeatUuid {
  result.hasHeartbeatUuid = NO;
  result.heartbeatUuid = @"";
  return self;
}
@end

@interface HeartbeatResponseProto ()
@property (strong) MinimumUserProto* sender;
@property (strong) NSString* heartbeatUuid;
@end

@implementation HeartbeatResponseProto

- (BOOL) hasSender {
  return !!hasSender_;
}
- (void) setHasSender:(BOOL) value_ {
  hasSender_ = !!value_;
}
@synthesize sender;
- (BOOL) hasHeartbeatUuid {
  return !!hasHeartbeatUuid_;
}
- (void) setHasHeartbeatUuid:(BOOL) value_ {
  hasHeartbeatUuid_ = !!value_;
}
@synthesize heartbeatUuid;
- (id) init {
  if ((self = [super init])) {
    self.sender = [MinimumUserProto defaultInstance];
    self.heartbeatUuid = @"";
  }
  return self;
}
static HeartbeatResponseProto* defaultHeartbeatResponseProtoInstance = nil;
+ (void) initialize {
  if (self == [HeartbeatResponseProto class]) {
    defaultHeartbeatResponseProtoInstance = [[HeartbeatResponseProto alloc] init];
  }
}
+ (HeartbeatResponseProto*) defaultInstance {
  return defaultHeartbeatResponseProtoInstance;
}
- (HeartbeatResponseProto*) defaultInstance {
  return defaultHeartbeatResponseProtoInstance;
}
- (BOOL) isInitialized {
  return YES;
}
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output {
  if (self.hasSender) {
    [output writeMessage:1 value:self.sender];
  }
  if (self.hasHeartbeatUuid) {
    [output writeString:2 value:self.heartbeatUuid];
  }
  [self.unknownFields writeToCodedOutputStream:output];
}
- (SInt32) serializedSize {
  __block SInt32 size_ = memoizedSerializedSize;
  if (size_ != -1) {
    return size_;
  }

  size_ = 0;
  if (self.hasSender) {
    size_ += computeMessageSize(1, self.sender);
  }
  if (self.hasHeartbeatUuid) {
    size_ += computeStringSize(2, self.heartbeatUuid);
  }
  size_ += self.unknownFields.serializedSize;
  memoizedSerializedSize = size_;
  return size_;
}
+ (HeartbeatResponseProto*) parseFromData:(NSData*) data {
  return (HeartbeatResponseProto*)[[[HeartbeatResponseProto builder] mergeFromData:data] build];
}
+ (HeartbeatResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (HeartbeatResponseProto*)[[[HeartbeatResponseProto builder] mergeFromData:data extensionRegistry:extensionRegistry] build];
}
+ (HeartbeatResponseProto*) parseFromInputStream:(NSInputStream*) input {
  return (HeartbeatResponseProto*)[[[HeartbeatResponseProto builder] mergeFromInputStream:input] build];
}
+ (HeartbeatResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (HeartbeatResponseProto*)[[[HeartbeatResponseProto builder] mergeFromInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (HeartbeatResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input {
  return (HeartbeatResponseProto*)[[[HeartbeatResponseProto builder] mergeFromCodedInputStream:input] build];
}
+ (HeartbeatResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (HeartbeatResponseProto*)[[[HeartbeatResponseProto builder] mergeFromCodedInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (HeartbeatResponseProto_Builder*) builder {
  return [[HeartbeatResponseProto_Builder alloc] init];
}
+ (HeartbeatResponseProto_Builder*) builderWithPrototype:(HeartbeatResponseProto*) prototype {
  return [[HeartbeatResponseProto builder] mergeFrom:prototype];
}
- (HeartbeatResponseProto_Builder*) builder {
  return [HeartbeatResponseProto builder];
}
- (HeartbeatResponseProto_Builder*) toBuilder {
  return [HeartbeatResponseProto builderWithPrototype:self];
}
- (void) writeDescriptionTo:(NSMutableString*) output withIndent:(NSString*) indent {
  if (self.hasSender) {
    [output appendFormat:@"%@%@ {\n", indent, @"sender"];
    [self.sender writeDescriptionTo:output
                         withIndent:[NSString stringWithFormat:@"%@  ", indent]];
    [output appendFormat:@"%@}\n", indent];
  }
  if (self.hasHeartbeatUuid) {
    [output appendFormat:@"%@%@: %@\n", indent, @"heartbeatUuid", self.heartbeatUuid];
  }
  [self.unknownFields writeDescriptionTo:output withIndent:indent];
}
- (BOOL) isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[HeartbeatResponseProto class]]) {
    return NO;
  }
  HeartbeatResponseProto *otherMessage = other;
  return
      self.hasSender == otherMessage.hasSender &&
      (!self.hasSender || [self.sender isEqual:otherMessage.sender]) &&
      self.hasHeartbeatUuid == otherMessage.hasHeartbeatUuid &&
      (!self.hasHeartbeatUuid || [self.heartbeatUuid isEqual:otherMessage.heartbeatUuid]) &&
      (self.unknownFields == otherMessage.unknownFields || (self.unknownFields != nil && [self.unknownFields isEqual:otherMessage.unknownFields]));
}
- (NSUInteger) hash {
  __block NSUInteger hashCode = 7;
  if (self.hasSender) {
    hashCode = hashCode * 31 + [self.sender hash];
  }
  if (self.hasHeartbeatUuid) {
    hashCode = hashCode * 31 + [self.heartbeatUuid hash];
  }
  hashCode = hashCode * 31 + [self.unknownFields hash];
  return hashCode;
}
@end

@interface HeartbeatResponseProto_Builder()
@property (strong) HeartbeatResponseProto* result;
@end

@implementation HeartbeatResponseProto_Builder
@synthesize result;
- (id) init {
  if ((self = [super init])) {
    self.result = [[HeartbeatResponseProto alloc] init];
  }
  return self;
}
- (PBGeneratedMessage*) internalGetResult {
  return result;
}
- (HeartbeatResponseProto_Builder*) clear {
  self.result = [[HeartbeatResponseProto alloc] init];
  return self;
}
- (HeartbeatResponseProto_Builder*) clone {
  return [HeartbeatResponseProto builderWithPrototype:result];
}
- (HeartbeatResponseProto*) defaultInstance {
  return [HeartbeatResponseProto defaultInstance];
}
- (HeartbeatResponseProto*) build {
  [self checkInitialized];
  return [self buildPartial];
}
- (HeartbeatResponseProto*) buildPartial {
  HeartbeatResponseProto* returnMe = result;
  self.result = nil;
  return returnMe;
}
- (HeartbeatResponseProto_Builder*) mergeFrom:(HeartbeatResponseProto*) other {
  if (other == [HeartbeatResponseProto defaultInstance]) {
    return self;
  }
  if (other.hasSender) {
    [self mergeSender:other.sender];
  }
  if (other.hasHeartbeatUuid) {
    [self setHeartbeatUuid:other.heartbeatUuid];
  }
  [self mergeUnknownFields:other.unknownFields];
  return self;
}
- (HeartbeatResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input {
  return [self mergeFromCodedInputStream:input extensionRegistry:[PBExtensionRegistry emptyRegistry]];
}
- (HeartbeatResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
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
      case 10: {
        MinimumUserProto_Builder* subBuilder = [MinimumUserProto builder];
        if (self.hasSender) {
          [subBuilder mergeFrom:self.sender];
        }
        [input readMessage:subBuilder extensionRegistry:extensionRegistry];
        [self setSender:[subBuilder buildPartial]];
        break;
      }
      case 18: {
        [self setHeartbeatUuid:[input readString]];
        break;
      }
    }
  }
}
- (BOOL) hasSender {
  return result.hasSender;
}
- (MinimumUserProto*) sender {
  return result.sender;
}
- (HeartbeatResponseProto_Builder*) setSender:(MinimumUserProto*) value {
  result.hasSender = YES;
  result.sender = value;
  return self;
}
- (HeartbeatResponseProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue {
  return [self setSender:[builderForValue build]];
}
- (HeartbeatResponseProto_Builder*) mergeSender:(MinimumUserProto*) value {
  if (result.hasSender &&
      result.sender != [MinimumUserProto defaultInstance]) {
    result.sender =
      [[[MinimumUserProto builderWithPrototype:result.sender] mergeFrom:value] buildPartial];
  } else {
    result.sender = value;
  }
  result.hasSender = YES;
  return self;
}
- (HeartbeatResponseProto_Builder*) clearSender {
  result.hasSender = NO;
  result.sender = [MinimumUserProto defaultInstance];
  return self;
}
- (BOOL) hasHeartbeatUuid {
  return result.hasHeartbeatUuid;
}
- (NSString*) heartbeatUuid {
  return result.heartbeatUuid;
}
- (HeartbeatResponseProto_Builder*) setHeartbeatUuid:(NSString*) value {
  result.hasHeartbeatUuid = YES;
  result.heartbeatUuid = value;
  return self;
}
- (HeartbeatResponseProto_Builder*) clearHeartbeatUuid {
  result.hasHeartbeatUuid = NO;
  result.heartbeatUuid = @"";
  return self;
}
@end


// @@protoc_insertion_point(global_scope)
