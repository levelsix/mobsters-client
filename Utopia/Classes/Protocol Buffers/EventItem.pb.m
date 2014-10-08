// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "EventItem.pb.h"
// @@protoc_insertion_point(imports)

@implementation EventItemRoot
static PBExtensionRegistry* extensionRegistry = nil;
+ (PBExtensionRegistry*) extensionRegistry {
  return extensionRegistry;
}

+ (void) initialize {
  if (self == [EventItemRoot class]) {
    PBMutableExtensionRegistry* registry = [PBMutableExtensionRegistry registry];
    [self registerAllExtensions:registry];
    [BoosterPackStuffRoot registerAllExtensions:registry];
    [MonsterStuffRoot registerAllExtensions:registry];
    [UserRoot registerAllExtensions:registry];
    extensionRegistry = registry;
  }
}
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry {
}
@end

@interface TradeItemForBoosterRequestProto ()
@property (strong) MinimumUserProto* sender;
@property int32_t itemId;
@property int64_t clientTime;
@end

@implementation TradeItemForBoosterRequestProto

- (BOOL) hasSender {
  return !!hasSender_;
}
- (void) setHasSender:(BOOL) value_ {
  hasSender_ = !!value_;
}
@synthesize sender;
- (BOOL) hasItemId {
  return !!hasItemId_;
}
- (void) setHasItemId:(BOOL) value_ {
  hasItemId_ = !!value_;
}
@synthesize itemId;
- (BOOL) hasClientTime {
  return !!hasClientTime_;
}
- (void) setHasClientTime:(BOOL) value_ {
  hasClientTime_ = !!value_;
}
@synthesize clientTime;
- (id) init {
  if ((self = [super init])) {
    self.sender = [MinimumUserProto defaultInstance];
    self.itemId = 0;
    self.clientTime = 0L;
  }
  return self;
}
static TradeItemForBoosterRequestProto* defaultTradeItemForBoosterRequestProtoInstance = nil;
+ (void) initialize {
  if (self == [TradeItemForBoosterRequestProto class]) {
    defaultTradeItemForBoosterRequestProtoInstance = [[TradeItemForBoosterRequestProto alloc] init];
  }
}
+ (TradeItemForBoosterRequestProto*) defaultInstance {
  return defaultTradeItemForBoosterRequestProtoInstance;
}
- (TradeItemForBoosterRequestProto*) defaultInstance {
  return defaultTradeItemForBoosterRequestProtoInstance;
}
- (BOOL) isInitialized {
  return YES;
}
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output {
  if (self.hasSender) {
    [output writeMessage:1 value:self.sender];
  }
  if (self.hasItemId) {
    [output writeInt32:2 value:self.itemId];
  }
  if (self.hasClientTime) {
    [output writeInt64:3 value:self.clientTime];
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
  if (self.hasItemId) {
    size_ += computeInt32Size(2, self.itemId);
  }
  if (self.hasClientTime) {
    size_ += computeInt64Size(3, self.clientTime);
  }
  size_ += self.unknownFields.serializedSize;
  memoizedSerializedSize = size_;
  return size_;
}
+ (TradeItemForBoosterRequestProto*) parseFromData:(NSData*) data {
  return (TradeItemForBoosterRequestProto*)[[[TradeItemForBoosterRequestProto builder] mergeFromData:data] build];
}
+ (TradeItemForBoosterRequestProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (TradeItemForBoosterRequestProto*)[[[TradeItemForBoosterRequestProto builder] mergeFromData:data extensionRegistry:extensionRegistry] build];
}
+ (TradeItemForBoosterRequestProto*) parseFromInputStream:(NSInputStream*) input {
  return (TradeItemForBoosterRequestProto*)[[[TradeItemForBoosterRequestProto builder] mergeFromInputStream:input] build];
}
+ (TradeItemForBoosterRequestProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (TradeItemForBoosterRequestProto*)[[[TradeItemForBoosterRequestProto builder] mergeFromInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (TradeItemForBoosterRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input {
  return (TradeItemForBoosterRequestProto*)[[[TradeItemForBoosterRequestProto builder] mergeFromCodedInputStream:input] build];
}
+ (TradeItemForBoosterRequestProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (TradeItemForBoosterRequestProto*)[[[TradeItemForBoosterRequestProto builder] mergeFromCodedInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (TradeItemForBoosterRequestProto_Builder*) builder {
  return [[TradeItemForBoosterRequestProto_Builder alloc] init];
}
+ (TradeItemForBoosterRequestProto_Builder*) builderWithPrototype:(TradeItemForBoosterRequestProto*) prototype {
  return [[TradeItemForBoosterRequestProto builder] mergeFrom:prototype];
}
- (TradeItemForBoosterRequestProto_Builder*) builder {
  return [TradeItemForBoosterRequestProto builder];
}
- (TradeItemForBoosterRequestProto_Builder*) toBuilder {
  return [TradeItemForBoosterRequestProto builderWithPrototype:self];
}
- (void) writeDescriptionTo:(NSMutableString*) output withIndent:(NSString*) indent {
  if (self.hasSender) {
    [output appendFormat:@"%@%@ {\n", indent, @"sender"];
    [self.sender writeDescriptionTo:output
                         withIndent:[NSString stringWithFormat:@"%@  ", indent]];
    [output appendFormat:@"%@}\n", indent];
  }
  if (self.hasItemId) {
    [output appendFormat:@"%@%@: %@\n", indent, @"itemId", [NSNumber numberWithInteger:self.itemId]];
  }
  if (self.hasClientTime) {
    [output appendFormat:@"%@%@: %@\n", indent, @"clientTime", [NSNumber numberWithLongLong:self.clientTime]];
  }
  [self.unknownFields writeDescriptionTo:output withIndent:indent];
}
- (BOOL) isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[TradeItemForBoosterRequestProto class]]) {
    return NO;
  }
  TradeItemForBoosterRequestProto *otherMessage = other;
  return
      self.hasSender == otherMessage.hasSender &&
      (!self.hasSender || [self.sender isEqual:otherMessage.sender]) &&
      self.hasItemId == otherMessage.hasItemId &&
      (!self.hasItemId || self.itemId == otherMessage.itemId) &&
      self.hasClientTime == otherMessage.hasClientTime &&
      (!self.hasClientTime || self.clientTime == otherMessage.clientTime) &&
      (self.unknownFields == otherMessage.unknownFields || (self.unknownFields != nil && [self.unknownFields isEqual:otherMessage.unknownFields]));
}
- (NSUInteger) hash {
  __block NSUInteger hashCode = 7;
  if (self.hasSender) {
    hashCode = hashCode * 31 + [self.sender hash];
  }
  if (self.hasItemId) {
    hashCode = hashCode * 31 + [[NSNumber numberWithInteger:self.itemId] hash];
  }
  if (self.hasClientTime) {
    hashCode = hashCode * 31 + [[NSNumber numberWithLongLong:self.clientTime] hash];
  }
  hashCode = hashCode * 31 + [self.unknownFields hash];
  return hashCode;
}
@end

@interface TradeItemForBoosterRequestProto_Builder()
@property (strong) TradeItemForBoosterRequestProto* result;
@end

@implementation TradeItemForBoosterRequestProto_Builder
@synthesize result;
- (id) init {
  if ((self = [super init])) {
    self.result = [[TradeItemForBoosterRequestProto alloc] init];
  }
  return self;
}
- (PBGeneratedMessage*) internalGetResult {
  return result;
}
- (TradeItemForBoosterRequestProto_Builder*) clear {
  self.result = [[TradeItemForBoosterRequestProto alloc] init];
  return self;
}
- (TradeItemForBoosterRequestProto_Builder*) clone {
  return [TradeItemForBoosterRequestProto builderWithPrototype:result];
}
- (TradeItemForBoosterRequestProto*) defaultInstance {
  return [TradeItemForBoosterRequestProto defaultInstance];
}
- (TradeItemForBoosterRequestProto*) build {
  [self checkInitialized];
  return [self buildPartial];
}
- (TradeItemForBoosterRequestProto*) buildPartial {
  TradeItemForBoosterRequestProto* returnMe = result;
  self.result = nil;
  return returnMe;
}
- (TradeItemForBoosterRequestProto_Builder*) mergeFrom:(TradeItemForBoosterRequestProto*) other {
  if (other == [TradeItemForBoosterRequestProto defaultInstance]) {
    return self;
  }
  if (other.hasSender) {
    [self mergeSender:other.sender];
  }
  if (other.hasItemId) {
    [self setItemId:other.itemId];
  }
  if (other.hasClientTime) {
    [self setClientTime:other.clientTime];
  }
  [self mergeUnknownFields:other.unknownFields];
  return self;
}
- (TradeItemForBoosterRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input {
  return [self mergeFromCodedInputStream:input extensionRegistry:[PBExtensionRegistry emptyRegistry]];
}
- (TradeItemForBoosterRequestProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
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
        [self setItemId:[input readInt32]];
        break;
      }
      case 24: {
        [self setClientTime:[input readInt64]];
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
- (TradeItemForBoosterRequestProto_Builder*) setSender:(MinimumUserProto*) value {
  result.hasSender = YES;
  result.sender = value;
  return self;
}
- (TradeItemForBoosterRequestProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue {
  return [self setSender:[builderForValue build]];
}
- (TradeItemForBoosterRequestProto_Builder*) mergeSender:(MinimumUserProto*) value {
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
- (TradeItemForBoosterRequestProto_Builder*) clearSender {
  result.hasSender = NO;
  result.sender = [MinimumUserProto defaultInstance];
  return self;
}
- (BOOL) hasItemId {
  return result.hasItemId;
}
- (int32_t) itemId {
  return result.itemId;
}
- (TradeItemForBoosterRequestProto_Builder*) setItemId:(int32_t) value {
  result.hasItemId = YES;
  result.itemId = value;
  return self;
}
- (TradeItemForBoosterRequestProto_Builder*) clearItemId {
  result.hasItemId = NO;
  result.itemId = 0;
  return self;
}
- (BOOL) hasClientTime {
  return result.hasClientTime;
}
- (int64_t) clientTime {
  return result.clientTime;
}
- (TradeItemForBoosterRequestProto_Builder*) setClientTime:(int64_t) value {
  result.hasClientTime = YES;
  result.clientTime = value;
  return self;
}
- (TradeItemForBoosterRequestProto_Builder*) clearClientTime {
  result.hasClientTime = NO;
  result.clientTime = 0L;
  return self;
}
@end

@interface TradeItemForBoosterResponseProto ()
@property (strong) MinimumUserProto* sender;
@property TradeItemForBoosterResponseProto_TradeItemForBoosterStatus status;
@property (strong) NSMutableArray * mutableUpdatedOrNewList;
@property (strong) BoosterItemProto* prize;
@end

@implementation TradeItemForBoosterResponseProto

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
@synthesize mutableUpdatedOrNewList;
@dynamic updatedOrNewList;
- (BOOL) hasPrize {
  return !!hasPrize_;
}
- (void) setHasPrize:(BOOL) value_ {
  hasPrize_ = !!value_;
}
@synthesize prize;
- (id) init {
  if ((self = [super init])) {
    self.sender = [MinimumUserProto defaultInstance];
    self.status = TradeItemForBoosterResponseProto_TradeItemForBoosterStatusSuccess;
    self.prize = [BoosterItemProto defaultInstance];
  }
  return self;
}
static TradeItemForBoosterResponseProto* defaultTradeItemForBoosterResponseProtoInstance = nil;
+ (void) initialize {
  if (self == [TradeItemForBoosterResponseProto class]) {
    defaultTradeItemForBoosterResponseProtoInstance = [[TradeItemForBoosterResponseProto alloc] init];
  }
}
+ (TradeItemForBoosterResponseProto*) defaultInstance {
  return defaultTradeItemForBoosterResponseProtoInstance;
}
- (TradeItemForBoosterResponseProto*) defaultInstance {
  return defaultTradeItemForBoosterResponseProtoInstance;
}
- (NSArray *)updatedOrNewList {
  return mutableUpdatedOrNewList;
}
- (FullUserMonsterProto*)updatedOrNewAtIndex:(NSUInteger)index {
  return [mutableUpdatedOrNewList objectAtIndex:index];
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
  [self.updatedOrNewList enumerateObjectsUsingBlock:^(FullUserMonsterProto *element, NSUInteger idx, BOOL *stop) {
    [output writeMessage:3 value:element];
  }];
  if (self.hasPrize) {
    [output writeMessage:4 value:self.prize];
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
  [self.updatedOrNewList enumerateObjectsUsingBlock:^(FullUserMonsterProto *element, NSUInteger idx, BOOL *stop) {
    size_ += computeMessageSize(3, element);
  }];
  if (self.hasPrize) {
    size_ += computeMessageSize(4, self.prize);
  }
  size_ += self.unknownFields.serializedSize;
  memoizedSerializedSize = size_;
  return size_;
}
+ (TradeItemForBoosterResponseProto*) parseFromData:(NSData*) data {
  return (TradeItemForBoosterResponseProto*)[[[TradeItemForBoosterResponseProto builder] mergeFromData:data] build];
}
+ (TradeItemForBoosterResponseProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (TradeItemForBoosterResponseProto*)[[[TradeItemForBoosterResponseProto builder] mergeFromData:data extensionRegistry:extensionRegistry] build];
}
+ (TradeItemForBoosterResponseProto*) parseFromInputStream:(NSInputStream*) input {
  return (TradeItemForBoosterResponseProto*)[[[TradeItemForBoosterResponseProto builder] mergeFromInputStream:input] build];
}
+ (TradeItemForBoosterResponseProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (TradeItemForBoosterResponseProto*)[[[TradeItemForBoosterResponseProto builder] mergeFromInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (TradeItemForBoosterResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input {
  return (TradeItemForBoosterResponseProto*)[[[TradeItemForBoosterResponseProto builder] mergeFromCodedInputStream:input] build];
}
+ (TradeItemForBoosterResponseProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (TradeItemForBoosterResponseProto*)[[[TradeItemForBoosterResponseProto builder] mergeFromCodedInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (TradeItemForBoosterResponseProto_Builder*) builder {
  return [[TradeItemForBoosterResponseProto_Builder alloc] init];
}
+ (TradeItemForBoosterResponseProto_Builder*) builderWithPrototype:(TradeItemForBoosterResponseProto*) prototype {
  return [[TradeItemForBoosterResponseProto builder] mergeFrom:prototype];
}
- (TradeItemForBoosterResponseProto_Builder*) builder {
  return [TradeItemForBoosterResponseProto builder];
}
- (TradeItemForBoosterResponseProto_Builder*) toBuilder {
  return [TradeItemForBoosterResponseProto builderWithPrototype:self];
}
- (void) writeDescriptionTo:(NSMutableString*) output withIndent:(NSString*) indent {
  if (self.hasSender) {
    [output appendFormat:@"%@%@ {\n", indent, @"sender"];
    [self.sender writeDescriptionTo:output
                         withIndent:[NSString stringWithFormat:@"%@  ", indent]];
    [output appendFormat:@"%@}\n", indent];
  }
  if (self.hasStatus) {
    [output appendFormat:@"%@%@: %d\n", indent, @"status", self.status];
  }
  [self.updatedOrNewList enumerateObjectsUsingBlock:^(FullUserMonsterProto *element, NSUInteger idx, BOOL *stop) {
    [output appendFormat:@"%@%@ {\n", indent, @"updatedOrNew"];
    [element writeDescriptionTo:output
                     withIndent:[NSString stringWithFormat:@"%@  ", indent]];
    [output appendFormat:@"%@}\n", indent];
  }];
  if (self.hasPrize) {
    [output appendFormat:@"%@%@ {\n", indent, @"prize"];
    [self.prize writeDescriptionTo:output
                         withIndent:[NSString stringWithFormat:@"%@  ", indent]];
    [output appendFormat:@"%@}\n", indent];
  }
  [self.unknownFields writeDescriptionTo:output withIndent:indent];
}
- (BOOL) isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[TradeItemForBoosterResponseProto class]]) {
    return NO;
  }
  TradeItemForBoosterResponseProto *otherMessage = other;
  return
      self.hasSender == otherMessage.hasSender &&
      (!self.hasSender || [self.sender isEqual:otherMessage.sender]) &&
      self.hasStatus == otherMessage.hasStatus &&
      (!self.hasStatus || self.status == otherMessage.status) &&
      [self.updatedOrNewList isEqualToArray:otherMessage.updatedOrNewList] &&
      self.hasPrize == otherMessage.hasPrize &&
      (!self.hasPrize || [self.prize isEqual:otherMessage.prize]) &&
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
  [self.updatedOrNewList enumerateObjectsUsingBlock:^(FullUserMonsterProto *element, NSUInteger idx, BOOL *stop) {
    hashCode = hashCode * 31 + [element hash];
  }];
  if (self.hasPrize) {
    hashCode = hashCode * 31 + [self.prize hash];
  }
  hashCode = hashCode * 31 + [self.unknownFields hash];
  return hashCode;
}
@end

BOOL TradeItemForBoosterResponseProto_TradeItemForBoosterStatusIsValidValue(TradeItemForBoosterResponseProto_TradeItemForBoosterStatus value) {
  switch (value) {
    case TradeItemForBoosterResponseProto_TradeItemForBoosterStatusSuccess:
    case TradeItemForBoosterResponseProto_TradeItemForBoosterStatusFailOther:
    case TradeItemForBoosterResponseProto_TradeItemForBoosterStatusFailInsufficientItem:
      return YES;
    default:
      return NO;
  }
}
@interface TradeItemForBoosterResponseProto_Builder()
@property (strong) TradeItemForBoosterResponseProto* result;
@end

@implementation TradeItemForBoosterResponseProto_Builder
@synthesize result;
- (id) init {
  if ((self = [super init])) {
    self.result = [[TradeItemForBoosterResponseProto alloc] init];
  }
  return self;
}
- (PBGeneratedMessage*) internalGetResult {
  return result;
}
- (TradeItemForBoosterResponseProto_Builder*) clear {
  self.result = [[TradeItemForBoosterResponseProto alloc] init];
  return self;
}
- (TradeItemForBoosterResponseProto_Builder*) clone {
  return [TradeItemForBoosterResponseProto builderWithPrototype:result];
}
- (TradeItemForBoosterResponseProto*) defaultInstance {
  return [TradeItemForBoosterResponseProto defaultInstance];
}
- (TradeItemForBoosterResponseProto*) build {
  [self checkInitialized];
  return [self buildPartial];
}
- (TradeItemForBoosterResponseProto*) buildPartial {
  TradeItemForBoosterResponseProto* returnMe = result;
  self.result = nil;
  return returnMe;
}
- (TradeItemForBoosterResponseProto_Builder*) mergeFrom:(TradeItemForBoosterResponseProto*) other {
  if (other == [TradeItemForBoosterResponseProto defaultInstance]) {
    return self;
  }
  if (other.hasSender) {
    [self mergeSender:other.sender];
  }
  if (other.hasStatus) {
    [self setStatus:other.status];
  }
  if (other.mutableUpdatedOrNewList.count > 0) {
    if (result.mutableUpdatedOrNewList == nil) {
      result.mutableUpdatedOrNewList = [[NSMutableArray alloc] initWithArray:other.mutableUpdatedOrNewList];
    } else {
      [result.mutableUpdatedOrNewList addObjectsFromArray:other.mutableUpdatedOrNewList];
    }
  }
  if (other.hasPrize) {
    [self mergePrize:other.prize];
  }
  [self mergeUnknownFields:other.unknownFields];
  return self;
}
- (TradeItemForBoosterResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input {
  return [self mergeFromCodedInputStream:input extensionRegistry:[PBExtensionRegistry emptyRegistry]];
}
- (TradeItemForBoosterResponseProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
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
        TradeItemForBoosterResponseProto_TradeItemForBoosterStatus value = (TradeItemForBoosterResponseProto_TradeItemForBoosterStatus)[input readEnum];
        if (TradeItemForBoosterResponseProto_TradeItemForBoosterStatusIsValidValue(value)) {
          [self setStatus:value];
        } else {
          [unknownFields mergeVarintField:2 value:value];
        }
        break;
      }
      case 26: {
        FullUserMonsterProto_Builder* subBuilder = [FullUserMonsterProto builder];
        [input readMessage:subBuilder extensionRegistry:extensionRegistry];
        [self addUpdatedOrNew:[subBuilder buildPartial]];
        break;
      }
      case 34: {
        BoosterItemProto_Builder* subBuilder = [BoosterItemProto builder];
        if (self.hasPrize) {
          [subBuilder mergeFrom:self.prize];
        }
        [input readMessage:subBuilder extensionRegistry:extensionRegistry];
        [self setPrize:[subBuilder buildPartial]];
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
- (TradeItemForBoosterResponseProto_Builder*) setSender:(MinimumUserProto*) value {
  result.hasSender = YES;
  result.sender = value;
  return self;
}
- (TradeItemForBoosterResponseProto_Builder*) setSender_Builder:(MinimumUserProto_Builder*) builderForValue {
  return [self setSender:[builderForValue build]];
}
- (TradeItemForBoosterResponseProto_Builder*) mergeSender:(MinimumUserProto*) value {
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
- (TradeItemForBoosterResponseProto_Builder*) clearSender {
  result.hasSender = NO;
  result.sender = [MinimumUserProto defaultInstance];
  return self;
}
- (BOOL) hasStatus {
  return result.hasStatus;
}
- (TradeItemForBoosterResponseProto_TradeItemForBoosterStatus) status {
  return result.status;
}
- (TradeItemForBoosterResponseProto_Builder*) setStatus:(TradeItemForBoosterResponseProto_TradeItemForBoosterStatus) value {
  result.hasStatus = YES;
  result.status = value;
  return self;
}
- (TradeItemForBoosterResponseProto_Builder*) clearStatus {
  result.hasStatus = NO;
  result.status = TradeItemForBoosterResponseProto_TradeItemForBoosterStatusSuccess;
  return self;
}
- (NSMutableArray *)updatedOrNewList {
  return result.mutableUpdatedOrNewList;
}
- (FullUserMonsterProto*)updatedOrNewAtIndex:(NSUInteger)index {
  return [result updatedOrNewAtIndex:index];
}
- (TradeItemForBoosterResponseProto_Builder *)addUpdatedOrNew:(FullUserMonsterProto*)value {
  if (result.mutableUpdatedOrNewList == nil) {
    result.mutableUpdatedOrNewList = [[NSMutableArray alloc]init];
  }
  [result.mutableUpdatedOrNewList addObject:value];
  return self;
}
- (TradeItemForBoosterResponseProto_Builder *)addAllUpdatedOrNew:(NSArray *)array {
  if (result.mutableUpdatedOrNewList == nil) {
    result.mutableUpdatedOrNewList = [NSMutableArray array];
  }
  [result.mutableUpdatedOrNewList addObjectsFromArray:array];
  return self;
}
- (TradeItemForBoosterResponseProto_Builder *)clearUpdatedOrNew {
  result.mutableUpdatedOrNewList = nil;
  return self;
}
- (BOOL) hasPrize {
  return result.hasPrize;
}
- (BoosterItemProto*) prize {
  return result.prize;
}
- (TradeItemForBoosterResponseProto_Builder*) setPrize:(BoosterItemProto*) value {
  result.hasPrize = YES;
  result.prize = value;
  return self;
}
- (TradeItemForBoosterResponseProto_Builder*) setPrize_Builder:(BoosterItemProto_Builder*) builderForValue {
  return [self setPrize:[builderForValue build]];
}
- (TradeItemForBoosterResponseProto_Builder*) mergePrize:(BoosterItemProto*) value {
  if (result.hasPrize &&
      result.prize != [BoosterItemProto defaultInstance]) {
    result.prize =
      [[[BoosterItemProto builderWithPrototype:result.prize] mergeFrom:value] buildPartial];
  } else {
    result.prize = value;
  }
  result.hasPrize = YES;
  return self;
}
- (TradeItemForBoosterResponseProto_Builder*) clearPrize {
  result.hasPrize = NO;
  result.prize = [BoosterItemProto defaultInstance];
  return self;
}
@end


// @@protoc_insertion_point(global_scope)
