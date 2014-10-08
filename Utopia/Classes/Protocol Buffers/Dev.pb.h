// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

// @@protoc_insertion_point(imports)

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

typedef enum {
  DevRequestResetAccount = 1,
  DevRequestGetMonzter = 2,
  DevRequestFBGetCash = 3,
  DevRequestFBGetOil = 4,
  DevRequestFBGetGems = 5,
  DevRequestFBGetCashOilGems = 6,
} DevRequest;

BOOL DevRequestIsValidValue(DevRequest value);


@interface DevRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end


// @@protoc_insertion_point(global_scope)
