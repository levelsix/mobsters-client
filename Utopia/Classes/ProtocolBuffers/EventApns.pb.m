// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "EventApns.pb.h"
// @@protoc_insertion_point(imports)

@implementation EventApnsRoot
static PBExtensionRegistry* extensionRegistry = nil;
+ (PBExtensionRegistry*) extensionRegistry {
  return extensionRegistry;
}

+ (void) initialize {
  if (self == [EventApnsRoot class]) {
    PBMutableExtensionRegistry* registry = [PBMutableExtensionRegistry registry];
    [self registerAllExtensions:registry];
    [SharedEnumConfigRoot registerAllExtensions:registry];
    [UserRoot registerAllExtensions:registry];
    extensionRegistry = registry;
  }
}
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry {
}
@end

@interface EnableAPNSRequestProto ()
@property (strong) MinimumUserProto* sender;
@property (strong) NSString* deviceToken;
@end

@implementation EnableAPNSRequestProto

- (BOOL) hasSender {
  return !!hasSender_;
}
- (void) setHasSender:(BOOL) value_ {
  hasSender_ = !!value_;
}
@synthesize sender;
- (BOOL) hasDeviceToken {
  return !!hasDeviceToken_;
}
- (void) setHasDeviceToken:(BOOL) value_ {
  hasDeviceToken_ = !!value_;
}
@synthesize deviceToken;
- (id) init {
  if ((self = [super init])) {
    self.sender = [MinimumUserProto defaultInstance];
    self.deviceToken = @"";
  }
  return self;
}
static EnableAPNSRequestProto* defaultEnableAPNSRequestProtoInstance = nil;
+ (void) initialize {
  if (self == [EnableAPNSRequestProto class]) {
    defaultEnableAPNSRequestProtoInstance = [[EnableAPNSRequestProto alloc] init];
  }
}
+ (EnableAPNSRequestProto*) defaultInstance {
  return defaultEnableAPNSRequestProtoInstance;
}
- (EnableAPNSRequestProto*) defaultInstance {
  return defaultEnableAPNSRequestProtoInstance;
}
- (BOOL) isInitialized {
  return YES;
}
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output {
  if (self.hasSender) {
    [output writeMessage:1 value:self.sender];
  }
  if (self.hasDeviceToken) {
    [output writeString:2 value:self.deviceToken];
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
  if (self.hasDeviceToken) {
    size_ += computeStringSize(2, self.deviceToken);
  }
  size_ += self.unknownFields.serializedSize;
  memoizedSerializedSize = size_;
  return size_;
}
+ (EnableAPNSRequestProto*) parseFromData:(NSData*) data {
  return (EnableAPNSRequestProto*)[[[EnableAPNSRequestProto builder] mergeFromData:data] build];
}
+ (EnableAPNSRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (EnableAPNSRequestProto*)[[[EnableAPNSRequestProto builder] mergeFromData:data extensionRegistry:extensionRegistry] build];
}
+ (EnableAPNSRequestProto*) parseFromInputStream:(NSInputStream*) input {
  return (EnableAPNSRequestProto*)[[[EnableAPNSRequestProto builder] mergeFromInputStream:input] build];
}
+ (EnableAPNSRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (EnableAPNSRequestProto*)[[[EnableAPNSRequestProto builder] mergeFromInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (EnableAPNSRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input {
  return (EnableAPNSRequestProto*)[[[EnableAPNSRequestProto builder] mergeFromCodedInputStream:input] build];
}
+ (EnableAPNSRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (EnableAPNSRequestProto*)[[[EnableAPNSRequestProto builder] mergeFromCodedInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (EnableAPNSRequestProto_Builder*) builder {
  return [[EnableAPNSRequestProto_Builder alloc] init];
}
+ (EnableAPNSRequestProto_Builder*) builderWithPrototype:(EnableAPNSRequestProto*) prototype {
  return [[EnableAPNSRequestProto builder] mergeFrom:prototype];
}
- (EnableAPNSRequestProto_Builder*) builder {
  return [EnableAPNSRequestProto builder];
}
- (EnableAPNSRequestProto_Builder*) toBuilder {
  return [EnableAPNSRequestProto builderWithPrototype:self];
}
- (void) writeDescriptionTo:(NSMutableString*) output withIndent:(NSString*) indent {
  if (self.hasSender) {
    [output appendFormat:@"%@%@ {\n", indent, @"sender"];
    [self.sender writeDescriptionTo:output
                         withIndent:[NSString stringWithFormat:@"%@  ", indent]];
    [output appendFormat:@"%@}\n", indent];
  }
  if (self.hasDeviceToken) {
    [output appendFormat:@"%@%@: %@\n", indent, @"deviceToken", self.deviceToken];
  }
  [self.unknownFields writeDescriptionTo:output withIndent:indent];
}
- (BOOL) isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[EnableAPNSRequestProto class]]) {
    return NO;
  }
  EnableAPNSRequestProto *otherMessage = other;
  return
      self.hasSender == otherMessage.hasSender &&
      (!self.hasSender || [self.sender isEqual:otherMessage.sender]) &&
      self.hasDeviceToken == otherMessage.hasDeviceToken &&
      (!self.hasDeviceToken || [self.deviceToken isEqual:otherMessage.deviceToken]) &&
      (self.unknownFields == otherMessage.unknownFields || (self.unknownFields != nil && [self.unknownFields isEqual:otherMessage.unknownFields]));
}
- (NSUInteger) hash {
  __block NSUInteger hashCode = 7;
  if (self.hasSender) {
    hashCode = hashCode * 31 + [self.sender hash];
  }
  if (self.hasDeviceToken) {
    hashCode = hashCode * 31 + [self.deviceToken hash];
  }
  hashCode = hashCode * 31 + [self.unknownFields hash];
  return hashCode;
}
@end

@interface EnableAPNSRequestProto_Builder()
@property (strong) EnableAPNSRequestProto* result;
@end

@implementation EnableAPNSRequestProto_Builder
@synthesize result;
- (id) init {
  if ((self = [super init])) {
    self.result = [[EnableAPNSRequestProto alloc] init];
  }
  return self;
}
- (PBGeneratedMessage*) internalGetResult {
  return result;
}
- (EnableAPNSRequestProto_Builder*) clear {
  self.result = [[EnableAPNSRequestProto alloc] init];
  return self;
}
- (EnableAPNSRequestProto_Builder*) clone {
  return [EnableAPNSRequestProto builderWithPrototype:result];
}
- (EnableAPNSRequestProto*) defaultInstance {
  return [EnableAPNSRequestProto defaultInstance];
}
- (EnableAPNSRequestProto*) build {
  [self checkInitialized];
  return [self buildPartial];
}
- (EnableAPNSRequestProto*) buildPartial {
  EnableAPNSRequestProto* returnMe = result;
  self.result = nil;
  return returnMe;
}
- (EnableAPNSRequestProto_Builder*) mergeFrom:(EnableAPNSRequestProto*) other {
  if (other == [EnableAPNSRequestProto defaultInstance]) {
    return self;
  }
  if (other.hasSender) {
    [self mergeSender:other.sender];
  }
  if (other.hasDeviceToken) {
    [self setDeviceToken:other.deviceToken];
  }
  [self mergeUnknownFields:other.unknownFields];
  return self;
}
- (EnableAPNSRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input {
  return [self mergeFromCodedInputStream:input extensionRegistry:[PBExtensionRegistry emptyRegistry]];
}
- (EnableAPNSRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
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
        [self setDeviceToken:[input readString]];
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
- (EnableAPNSRequestProto_Builder*) setSender:(MinimumUserProto*) value {
  result.hasSender = YES;
  result.sender = value;
  return self;
}
- (EnableAPNSRequestProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue {
  return [self setSender:[builderForValue build]];
}
- (EnableAPNSRequestProto_Builder*) mergeSender:(MinimumUserProto*) value {
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
- (EnableAPNSRequestProto_Builder*) clearSender {
  result.hasSender = NO;
  result.sender = [MinimumUserProto defaultInstance];
  return self;
}
- (BOOL) hasDeviceToken {
  return result.hasDeviceToken;
}
- (NSString*) deviceToken {
  return result.deviceToken;
}
- (EnableAPNSRequestProto_Builder*) setDeviceToken:(NSString*) value {
  result.hasDeviceToken = YES;
  result.deviceToken = value;
  return self;
}
- (EnableAPNSRequestProto_Builder*) clearDeviceToken {
  result.hasDeviceToken = NO;
  result.deviceToken = @"";
  return self;
}
@end

@interface EnableAPNSResponseProto ()
@property (strong) MinimumUserProto* sender;
@property ResponseStatus status;
@end

@implementation EnableAPNSResponseProto

- (BOOL) hasSender {
  return !!hasSender_;
}
- (void) setHasSender:(BOOL) value_ {
  hasSender_ = !!value_;
}
@synthesize sender;
- (BOOL) hasStatus {
  return !!hasStatus_;
}
- (void) setHasStatus:(BOOL) value_ {
  hasStatus_ = !!value_;
}
@synthesize status;
- (id) init {
  if ((self = [super init])) {
    self.sender = [MinimumUserProto defaultInstance];
    self.status = ResponseStatusSuccess;
  }
  return self;
}
static EnableAPNSResponseProto* defaultEnableAPNSResponseProtoInstance = nil;
+ (void) initialize {
  if (self == [EnableAPNSResponseProto class]) {
    defaultEnableAPNSResponseProtoInstance = [[EnableAPNSResponseProto alloc] init];
  }
}
+ (EnableAPNSResponseProto*) defaultInstance {
  return defaultEnableAPNSResponseProtoInstance;
}
- (EnableAPNSResponseProto*) defaultInstance {
  return defaultEnableAPNSResponseProtoInstance;
}
- (BOOL) isInitialized {
  return YES;
}
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output {
  if (self.hasSender) {
    [output writeMessage:1 value:self.sender];
  }
  if (self.hasStatus) {
    [output writeEnum:2 value:self.status];
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
  if (self.hasStatus) {
    size_ += computeEnumSize(2, self.status);
  }
  size_ += self.unknownFields.serializedSize;
  memoizedSerializedSize = size_;
  return size_;
}
+ (EnableAPNSResponseProto*) parseFromData:(NSData*) data {
  return (EnableAPNSResponseProto*)[[[EnableAPNSResponseProto builder] mergeFromData:data] build];
}
+ (EnableAPNSResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (EnableAPNSResponseProto*)[[[EnableAPNSResponseProto builder] mergeFromData:data extensionRegistry:extensionRegistry] build];
}
+ (EnableAPNSResponseProto*) parseFromInputStream:(NSInputStream*) input {
  return (EnableAPNSResponseProto*)[[[EnableAPNSResponseProto builder] mergeFromInputStream:input] build];
}
+ (EnableAPNSResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (EnableAPNSResponseProto*)[[[EnableAPNSResponseProto builder] mergeFromInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (EnableAPNSResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input {
  return (EnableAPNSResponseProto*)[[[EnableAPNSResponseProto builder] mergeFromCodedInputStream:input] build];
}
+ (EnableAPNSResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (EnableAPNSResponseProto*)[[[EnableAPNSResponseProto builder] mergeFromCodedInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (EnableAPNSResponseProto_Builder*) builder {
  return [[EnableAPNSResponseProto_Builder alloc] init];
}
+ (EnableAPNSResponseProto_Builder*) builderWithPrototype:(EnableAPNSResponseProto*) prototype {
  return [[EnableAPNSResponseProto builder] mergeFrom:prototype];
}
- (EnableAPNSResponseProto_Builder*) builder {
  return [EnableAPNSResponseProto builder];
}
- (EnableAPNSResponseProto_Builder*) toBuilder {
  return [EnableAPNSResponseProto builderWithPrototype:self];
}
- (void) writeDescriptionTo:(NSMutableString*) output withIndent:(NSString*) indent {
  if (self.hasSender) {
    [output appendFormat:@"%@%@ {\n", indent, @"sender"];
    [self.sender writeDescriptionTo:output
                         withIndent:[NSString stringWithFormat:@"%@  ", indent]];
    [output appendFormat:@"%@}\n", indent];
  }
  if (self.hasStatus) {
    [output appendFormat:@"%@%@: %@\n", indent, @"status", [NSNumber numberWithInteger:self.status]];
  }
  [self.unknownFields writeDescriptionTo:output withIndent:indent];
}
- (BOOL) isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[EnableAPNSResponseProto class]]) {
    return NO;
  }
  EnableAPNSResponseProto *otherMessage = other;
  return
      self.hasSender == otherMessage.hasSender &&
      (!self.hasSender || [self.sender isEqual:otherMessage.sender]) &&
      self.hasStatus == otherMessage.hasStatus &&
      (!self.hasStatus || self.status == otherMessage.status) &&
      (self.unknownFields == otherMessage.unknownFields || (self.unknownFields != nil && [self.unknownFields isEqual:otherMessage.unknownFields]));
}
- (NSUInteger) hash {
  __block NSUInteger hashCode = 7;
  if (self.hasSender) {
    hashCode = hashCode * 31 + [self.sender hash];
  }
  if (self.hasStatus) {
    hashCode = hashCode * 31 + self.status;
  }
  hashCode = hashCode * 31 + [self.unknownFields hash];
  return hashCode;
}
@end

@interface EnableAPNSResponseProto_Builder()
@property (strong) EnableAPNSResponseProto* result;
@end

@implementation EnableAPNSResponseProto_Builder
@synthesize result;
- (id) init {
  if ((self = [super init])) {
    self.result = [[EnableAPNSResponseProto alloc] init];
  }
  return self;
}
- (PBGeneratedMessage*) internalGetResult {
  return result;
}
- (EnableAPNSResponseProto_Builder*) clear {
  self.result = [[EnableAPNSResponseProto alloc] init];
  return self;
}
- (EnableAPNSResponseProto_Builder*) clone {
  return [EnableAPNSResponseProto builderWithPrototype:result];
}
- (EnableAPNSResponseProto*) defaultInstance {
  return [EnableAPNSResponseProto defaultInstance];
}
- (EnableAPNSResponseProto*) build {
  [self checkInitialized];
  return [self buildPartial];
}
- (EnableAPNSResponseProto*) buildPartial {
  EnableAPNSResponseProto* returnMe = result;
  self.result = nil;
  return returnMe;
}
- (EnableAPNSResponseProto_Builder*) mergeFrom:(EnableAPNSResponseProto*) other {
  if (other == [EnableAPNSResponseProto defaultInstance]) {
    return self;
  }
  if (other.hasSender) {
    [self mergeSender:other.sender];
  }
  if (other.hasStatus) {
    [self setStatus:other.status];
  }
  [self mergeUnknownFields:other.unknownFields];
  return self;
}
- (EnableAPNSResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input {
  return [self mergeFromCodedInputStream:input extensionRegistry:[PBExtensionRegistry emptyRegistry]];
}
- (EnableAPNSResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
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
      case 16: {
        ResponseStatus value = (ResponseStatus)[input readEnum];
        if (ResponseStatusIsValidValue(value)) {
          [self setStatus:value];
        } else {
          [unknownFields mergeVarintField:2 value:value];
        }
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
- (EnableAPNSResponseProto_Builder*) setSender:(MinimumUserProto*) value {
  result.hasSender = YES;
  result.sender = value;
  return self;
}
- (EnableAPNSResponseProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue {
  return [self setSender:[builderForValue build]];
}
- (EnableAPNSResponseProto_Builder*) mergeSender:(MinimumUserProto*) value {
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
- (EnableAPNSResponseProto_Builder*) clearSender {
  result.hasSender = NO;
  result.sender = [MinimumUserProto defaultInstance];
  return self;
}
- (BOOL) hasStatus {
  return result.hasStatus;
}
- (ResponseStatus) status {
  return result.status;
}
- (EnableAPNSResponseProto_Builder*) setStatus:(ResponseStatus) value {
  result.hasStatus = YES;
  result.status = value;
  return self;
}
- (EnableAPNSResponseProto_Builder*) clearStatusList {
  result.hasStatus = NO;
  result.status = ResponseStatusSuccess;
  return self;
}
@end


// @@protoc_insertion_point(global_scope)
