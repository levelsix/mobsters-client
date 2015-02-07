// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "SharedEnumConfig.pb.h"
// @@protoc_insertion_point(imports)

@class ItemProto;
@class ItemProto_Builder;
@class UserItemProto;
@class UserItemProto_Builder;
@class UserItemSecretGiftProto;
@class UserItemSecretGiftProto_Builder;
@class UserItemUsageProto;
@class UserItemUsageProto_Builder;
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

typedef NS_ENUM(SInt32, ItemType) {
  ItemTypeBoosterPack = 1,
  ItemTypeItemOil = 2,
  ItemTypeItemCash = 3,
  ItemTypeSpeedUp = 4,
};

BOOL ItemTypeIsValidValue(ItemType value);


@interface ItemRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface UserItemProto : PBGeneratedMessage {
@private
  BOOL hasItemId_:1;
  BOOL hasQuantity_:1;
  BOOL hasUserUuid_:1;
  int32_t itemId;
  int32_t quantity;
  NSString* userUuid;
}
- (BOOL) hasUserUuid;
- (BOOL) hasItemId;
- (BOOL) hasQuantity;
@property (readonly, strong) NSString* userUuid;
@property (readonly) int32_t itemId;
@property (readonly) int32_t quantity;

+ (UserItemProto*) defaultInstance;
- (UserItemProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (UserItemProto_Builder*) builder;
+ (UserItemProto_Builder*) builder;
+ (UserItemProto_Builder*) builderWithPrototype:(UserItemProto*) prototype;
- (UserItemProto_Builder*) toBuilder;

+ (UserItemProto*) parseFromData:(NSData*) data;
+ (UserItemProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserItemProto*) parseFromInputStream:(NSInputStream*) input;
+ (UserItemProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserItemProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (UserItemProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface UserItemProto_Builder : PBGeneratedMessageBuilder {
@private
  UserItemProto* result;
}

- (UserItemProto*) defaultInstance;

- (UserItemProto_Builder*) clear;
- (UserItemProto_Builder*) clone;

- (UserItemProto*) build;
- (UserItemProto*) buildPartial;

- (UserItemProto_Builder*) mergeFrom:(UserItemProto*) other;
- (UserItemProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (UserItemProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasUserUuid;
- (NSString*) userUuid;
- (UserItemProto_Builder*) setUserUuid:(NSString*) value;
- (UserItemProto_Builder*) clearUserUuid;

- (BOOL) hasItemId;
- (int32_t) itemId;
- (UserItemProto_Builder*) setItemId:(int32_t) value;
- (UserItemProto_Builder*) clearItemId;

- (BOOL) hasQuantity;
- (int32_t) quantity;
- (UserItemProto_Builder*) setQuantity:(int32_t) value;
- (UserItemProto_Builder*) clearQuantity;
@end

@interface ItemProto : PBGeneratedMessage {
@private
  BOOL hasAlwaysDisplayToUser_:1;
  BOOL hasSecretGiftChance_:1;
  BOOL hasItemId_:1;
  BOOL hasStaticDataId_:1;
  BOOL hasAmount_:1;
  BOOL hasName_:1;
  BOOL hasImgName_:1;
  BOOL hasItemType_:1;
  BOOL alwaysDisplayToUser_:1;
  Float32 secretGiftChance;
  int32_t itemId;
  int32_t staticDataId;
  int32_t amount;
  NSString* name;
  NSString* imgName;
  ItemType itemType;
}
- (BOOL) hasItemId;
- (BOOL) hasName;
- (BOOL) hasImgName;
- (BOOL) hasItemType;
- (BOOL) hasStaticDataId;
- (BOOL) hasAmount;
- (BOOL) hasSecretGiftChance;
- (BOOL) hasAlwaysDisplayToUser;
@property (readonly) int32_t itemId;
@property (readonly, strong) NSString* name;
@property (readonly, strong) NSString* imgName;
@property (readonly) ItemType itemType;
@property (readonly) int32_t staticDataId;
@property (readonly) int32_t amount;
@property (readonly) Float32 secretGiftChance;
- (BOOL) alwaysDisplayToUser;

+ (ItemProto*) defaultInstance;
- (ItemProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (ItemProto_Builder*) builder;
+ (ItemProto_Builder*) builder;
+ (ItemProto_Builder*) builderWithPrototype:(ItemProto*) prototype;
- (ItemProto_Builder*) toBuilder;

+ (ItemProto*) parseFromData:(NSData*) data;
+ (ItemProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ItemProto*) parseFromInputStream:(NSInputStream*) input;
+ (ItemProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ItemProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (ItemProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface ItemProto_Builder : PBGeneratedMessageBuilder {
@private
  ItemProto* result;
}

- (ItemProto*) defaultInstance;

- (ItemProto_Builder*) clear;
- (ItemProto_Builder*) clone;

- (ItemProto*) build;
- (ItemProto*) buildPartial;

- (ItemProto_Builder*) mergeFrom:(ItemProto*) other;
- (ItemProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (ItemProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasItemId;
- (int32_t) itemId;
- (ItemProto_Builder*) setItemId:(int32_t) value;
- (ItemProto_Builder*) clearItemId;

- (BOOL) hasName;
- (NSString*) name;
- (ItemProto_Builder*) setName:(NSString*) value;
- (ItemProto_Builder*) clearName;

- (BOOL) hasImgName;
- (NSString*) imgName;
- (ItemProto_Builder*) setImgName:(NSString*) value;
- (ItemProto_Builder*) clearImgName;

- (BOOL) hasItemType;
- (ItemType) itemType;
- (ItemProto_Builder*) setItemType:(ItemType) value;
- (ItemProto_Builder*) clearItemTypeList;

- (BOOL) hasStaticDataId;
- (int32_t) staticDataId;
- (ItemProto_Builder*) setStaticDataId:(int32_t) value;
- (ItemProto_Builder*) clearStaticDataId;

- (BOOL) hasAmount;
- (int32_t) amount;
- (ItemProto_Builder*) setAmount:(int32_t) value;
- (ItemProto_Builder*) clearAmount;

- (BOOL) hasSecretGiftChance;
- (Float32) secretGiftChance;
- (ItemProto_Builder*) setSecretGiftChance:(Float32) value;
- (ItemProto_Builder*) clearSecretGiftChance;

- (BOOL) hasAlwaysDisplayToUser;
- (BOOL) alwaysDisplayToUser;
- (ItemProto_Builder*) setAlwaysDisplayToUser:(BOOL) value;
- (ItemProto_Builder*) clearAlwaysDisplayToUser;
@end

@interface UserItemUsageProto : PBGeneratedMessage {
@private
  BOOL hasTimeOfEntry_:1;
  BOOL hasItemId_:1;
  BOOL hasUsageUuid_:1;
  BOOL hasUserUuid_:1;
  BOOL hasUserDataUuid_:1;
  BOOL hasActionType_:1;
  int64_t timeOfEntry;
  int32_t itemId;
  NSString* usageUuid;
  NSString* userUuid;
  NSString* userDataUuid;
  GameActionType actionType;
}
- (BOOL) hasUsageUuid;
- (BOOL) hasUserUuid;
- (BOOL) hasItemId;
- (BOOL) hasTimeOfEntry;
- (BOOL) hasUserDataUuid;
- (BOOL) hasActionType;
@property (readonly, strong) NSString* usageUuid;
@property (readonly, strong) NSString* userUuid;
@property (readonly) int32_t itemId;
@property (readonly) int64_t timeOfEntry;
@property (readonly, strong) NSString* userDataUuid;
@property (readonly) GameActionType actionType;

+ (UserItemUsageProto*) defaultInstance;
- (UserItemUsageProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (UserItemUsageProto_Builder*) builder;
+ (UserItemUsageProto_Builder*) builder;
+ (UserItemUsageProto_Builder*) builderWithPrototype:(UserItemUsageProto*) prototype;
- (UserItemUsageProto_Builder*) toBuilder;

+ (UserItemUsageProto*) parseFromData:(NSData*) data;
+ (UserItemUsageProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserItemUsageProto*) parseFromInputStream:(NSInputStream*) input;
+ (UserItemUsageProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserItemUsageProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (UserItemUsageProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface UserItemUsageProto_Builder : PBGeneratedMessageBuilder {
@private
  UserItemUsageProto* result;
}

- (UserItemUsageProto*) defaultInstance;

- (UserItemUsageProto_Builder*) clear;
- (UserItemUsageProto_Builder*) clone;

- (UserItemUsageProto*) build;
- (UserItemUsageProto*) buildPartial;

- (UserItemUsageProto_Builder*) mergeFrom:(UserItemUsageProto*) other;
- (UserItemUsageProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (UserItemUsageProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasUsageUuid;
- (NSString*) usageUuid;
- (UserItemUsageProto_Builder*) setUsageUuid:(NSString*) value;
- (UserItemUsageProto_Builder*) clearUsageUuid;

- (BOOL) hasUserUuid;
- (NSString*) userUuid;
- (UserItemUsageProto_Builder*) setUserUuid:(NSString*) value;
- (UserItemUsageProto_Builder*) clearUserUuid;

- (BOOL) hasItemId;
- (int32_t) itemId;
- (UserItemUsageProto_Builder*) setItemId:(int32_t) value;
- (UserItemUsageProto_Builder*) clearItemId;

- (BOOL) hasTimeOfEntry;
- (int64_t) timeOfEntry;
- (UserItemUsageProto_Builder*) setTimeOfEntry:(int64_t) value;
- (UserItemUsageProto_Builder*) clearTimeOfEntry;

- (BOOL) hasUserDataUuid;
- (NSString*) userDataUuid;
- (UserItemUsageProto_Builder*) setUserDataUuid:(NSString*) value;
- (UserItemUsageProto_Builder*) clearUserDataUuid;

- (BOOL) hasActionType;
- (GameActionType) actionType;
- (UserItemUsageProto_Builder*) setActionType:(GameActionType) value;
- (UserItemUsageProto_Builder*) clearActionTypeList;
@end

@interface UserItemSecretGiftProto : PBGeneratedMessage {
@private
  BOOL hasCreateTime_:1;
  BOOL hasSecsTillCollection_:1;
  BOOL hasItemId_:1;
  BOOL hasUisgUuid_:1;
  BOOL hasUserUuid_:1;
  int64_t createTime;
  int32_t secsTillCollection;
  int32_t itemId;
  NSString* uisgUuid;
  NSString* userUuid;
}
- (BOOL) hasUisgUuid;
- (BOOL) hasUserUuid;
- (BOOL) hasSecsTillCollection;
- (BOOL) hasItemId;
- (BOOL) hasCreateTime;
@property (readonly, strong) NSString* uisgUuid;
@property (readonly, strong) NSString* userUuid;
@property (readonly) int32_t secsTillCollection;
@property (readonly) int32_t itemId;
@property (readonly) int64_t createTime;

+ (UserItemSecretGiftProto*) defaultInstance;
- (UserItemSecretGiftProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (UserItemSecretGiftProto_Builder*) builder;
+ (UserItemSecretGiftProto_Builder*) builder;
+ (UserItemSecretGiftProto_Builder*) builderWithPrototype:(UserItemSecretGiftProto*) prototype;
- (UserItemSecretGiftProto_Builder*) toBuilder;

+ (UserItemSecretGiftProto*) parseFromData:(NSData*) data;
+ (UserItemSecretGiftProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserItemSecretGiftProto*) parseFromInputStream:(NSInputStream*) input;
+ (UserItemSecretGiftProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (UserItemSecretGiftProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (UserItemSecretGiftProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface UserItemSecretGiftProto_Builder : PBGeneratedMessageBuilder {
@private
  UserItemSecretGiftProto* result;
}

- (UserItemSecretGiftProto*) defaultInstance;

- (UserItemSecretGiftProto_Builder*) clear;
- (UserItemSecretGiftProto_Builder*) clone;

- (UserItemSecretGiftProto*) build;
- (UserItemSecretGiftProto*) buildPartial;

- (UserItemSecretGiftProto_Builder*) mergeFrom:(UserItemSecretGiftProto*) other;
- (UserItemSecretGiftProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (UserItemSecretGiftProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasUisgUuid;
- (NSString*) uisgUuid;
- (UserItemSecretGiftProto_Builder*) setUisgUuid:(NSString*) value;
- (UserItemSecretGiftProto_Builder*) clearUisgUuid;

- (BOOL) hasUserUuid;
- (NSString*) userUuid;
- (UserItemSecretGiftProto_Builder*) setUserUuid:(NSString*) value;
- (UserItemSecretGiftProto_Builder*) clearUserUuid;

- (BOOL) hasSecsTillCollection;
- (int32_t) secsTillCollection;
- (UserItemSecretGiftProto_Builder*) setSecsTillCollection:(int32_t) value;
- (UserItemSecretGiftProto_Builder*) clearSecsTillCollection;

- (BOOL) hasItemId;
- (int32_t) itemId;
- (UserItemSecretGiftProto_Builder*) setItemId:(int32_t) value;
- (UserItemSecretGiftProto_Builder*) clearItemId;

- (BOOL) hasCreateTime;
- (int64_t) createTime;
- (UserItemSecretGiftProto_Builder*) setCreateTime:(int64_t) value;
- (UserItemSecretGiftProto_Builder*) clearCreateTime;
@end


// @@protoc_insertion_point(global_scope)
