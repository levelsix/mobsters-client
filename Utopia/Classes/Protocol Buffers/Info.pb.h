// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

@class GoldSaleProto;
@class GoldSaleProto_Builder;
@class InAppPurchasePackageProto;
@class InAppPurchasePackageProto_Builder;
typedef enum {
  EarnFreeDiamondsTypeFbConnect = 1,
  EarnFreeDiamondsTypeTapjoy = 2,
  EarnFreeDiamondsTypeFlurryVideo = 3,
  EarnFreeDiamondsTypeTwitter = 4,
} EarnFreeDiamondsType;

BOOL EarnFreeDiamondsTypeIsValidValue(EarnFreeDiamondsType value);


@interface InfoRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface InAppPurchasePackageProto : PBGeneratedMessage {
@private
  BOOL hasIsGold_:1;
  BOOL hasCurrencyAmount_:1;
  BOOL hasPackageId_:1;
  BOOL hasImageName_:1;
  BOOL isGold_:1;
  int32_t currencyAmount;
  NSString* packageId;
  NSString* imageName;
}
- (BOOL) hasPackageId;
- (BOOL) hasCurrencyAmount;
- (BOOL) hasIsGold;
- (BOOL) hasImageName;
@property (readonly, retain) NSString* packageId;
@property (readonly) int32_t currencyAmount;
- (BOOL) isGold;
@property (readonly, retain) NSString* imageName;

+ (InAppPurchasePackageProto*) defaultInstance;
- (InAppPurchasePackageProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (InAppPurchasePackageProto_Builder*) builder;
+ (InAppPurchasePackageProto_Builder*) builder;
+ (InAppPurchasePackageProto_Builder*) builderWithPrototype:(InAppPurchasePackageProto*) prototype;

+ (InAppPurchasePackageProto*) parseFromData:(NSData*) data;
+ (InAppPurchasePackageProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (InAppPurchasePackageProto*) parseFromInputStream:(NSInputStream*) input;
+ (InAppPurchasePackageProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (InAppPurchasePackageProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (InAppPurchasePackageProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface InAppPurchasePackageProto_Builder : PBGeneratedMessage_Builder {
@private
  InAppPurchasePackageProto* result;
}

- (InAppPurchasePackageProto*) defaultInstance;

- (InAppPurchasePackageProto_Builder*) clear;
- (InAppPurchasePackageProto_Builder*) clone;

- (InAppPurchasePackageProto*) build;
- (InAppPurchasePackageProto*) buildPartial;

- (InAppPurchasePackageProto_Builder*) mergeFrom:(InAppPurchasePackageProto*) other;
- (InAppPurchasePackageProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (InAppPurchasePackageProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasPackageId;
- (NSString*) packageId;
- (InAppPurchasePackageProto_Builder*) setPackageId:(NSString*) value;
- (InAppPurchasePackageProto_Builder*) clearPackageId;

- (BOOL) hasCurrencyAmount;
- (int32_t) currencyAmount;
- (InAppPurchasePackageProto_Builder*) setCurrencyAmount:(int32_t) value;
- (InAppPurchasePackageProto_Builder*) clearCurrencyAmount;

- (BOOL) hasIsGold;
- (BOOL) isGold;
- (InAppPurchasePackageProto_Builder*) setIsGold:(BOOL) value;
- (InAppPurchasePackageProto_Builder*) clearIsGold;

- (BOOL) hasImageName;
- (NSString*) imageName;
- (InAppPurchasePackageProto_Builder*) setImageName:(NSString*) value;
- (InAppPurchasePackageProto_Builder*) clearImageName;
@end

@interface GoldSaleProto : PBGeneratedMessage {
@private
  BOOL hasIsBeginnerSale_:1;
  BOOL hasStartDate_:1;
  BOOL hasEndDate_:1;
  BOOL hasSaleId_:1;
  BOOL hasPackage1SaleIdentifier_:1;
  BOOL hasPackage2SaleIdentifier_:1;
  BOOL hasPackage3SaleIdentifier_:1;
  BOOL hasPackage4SaleIdentifier_:1;
  BOOL hasPackage5SaleIdentifier_:1;
  BOOL hasGoldShoppeImageName_:1;
  BOOL hasGoldBarImageName_:1;
  BOOL hasPackageS1SaleIdentifier_:1;
  BOOL hasPackageS2SaleIdentifier_:1;
  BOOL hasPackageS3SaleIdentifier_:1;
  BOOL hasPackageS4SaleIdentifier_:1;
  BOOL hasPackageS5SaleIdentifier_:1;
  BOOL isBeginnerSale_:1;
  int64_t startDate;
  int64_t endDate;
  int32_t saleId;
  NSString* package1SaleIdentifier;
  NSString* package2SaleIdentifier;
  NSString* package3SaleIdentifier;
  NSString* package4SaleIdentifier;
  NSString* package5SaleIdentifier;
  NSString* goldShoppeImageName;
  NSString* goldBarImageName;
  NSString* packageS1SaleIdentifier;
  NSString* packageS2SaleIdentifier;
  NSString* packageS3SaleIdentifier;
  NSString* packageS4SaleIdentifier;
  NSString* packageS5SaleIdentifier;
}
- (BOOL) hasSaleId;
- (BOOL) hasStartDate;
- (BOOL) hasEndDate;
- (BOOL) hasPackage1SaleIdentifier;
- (BOOL) hasPackage2SaleIdentifier;
- (BOOL) hasPackage3SaleIdentifier;
- (BOOL) hasPackage4SaleIdentifier;
- (BOOL) hasPackage5SaleIdentifier;
- (BOOL) hasGoldShoppeImageName;
- (BOOL) hasGoldBarImageName;
- (BOOL) hasPackageS1SaleIdentifier;
- (BOOL) hasPackageS2SaleIdentifier;
- (BOOL) hasPackageS3SaleIdentifier;
- (BOOL) hasPackageS4SaleIdentifier;
- (BOOL) hasPackageS5SaleIdentifier;
- (BOOL) hasIsBeginnerSale;
@property (readonly) int32_t saleId;
@property (readonly) int64_t startDate;
@property (readonly) int64_t endDate;
@property (readonly, retain) NSString* package1SaleIdentifier;
@property (readonly, retain) NSString* package2SaleIdentifier;
@property (readonly, retain) NSString* package3SaleIdentifier;
@property (readonly, retain) NSString* package4SaleIdentifier;
@property (readonly, retain) NSString* package5SaleIdentifier;
@property (readonly, retain) NSString* goldShoppeImageName;
@property (readonly, retain) NSString* goldBarImageName;
@property (readonly, retain) NSString* packageS1SaleIdentifier;
@property (readonly, retain) NSString* packageS2SaleIdentifier;
@property (readonly, retain) NSString* packageS3SaleIdentifier;
@property (readonly, retain) NSString* packageS4SaleIdentifier;
@property (readonly, retain) NSString* packageS5SaleIdentifier;
- (BOOL) isBeginnerSale;

+ (GoldSaleProto*) defaultInstance;
- (GoldSaleProto*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (GoldSaleProto_Builder*) builder;
+ (GoldSaleProto_Builder*) builder;
+ (GoldSaleProto_Builder*) builderWithPrototype:(GoldSaleProto*) prototype;

+ (GoldSaleProto*) parseFromData:(NSData*) data;
+ (GoldSaleProto*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (GoldSaleProto*) parseFromInputStream:(NSInputStream*) input;
+ (GoldSaleProto*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (GoldSaleProto*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (GoldSaleProto*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface GoldSaleProto_Builder : PBGeneratedMessage_Builder {
@private
  GoldSaleProto* result;
}

- (GoldSaleProto*) defaultInstance;

- (GoldSaleProto_Builder*) clear;
- (GoldSaleProto_Builder*) clone;

- (GoldSaleProto*) build;
- (GoldSaleProto*) buildPartial;

- (GoldSaleProto_Builder*) mergeFrom:(GoldSaleProto*) other;
- (GoldSaleProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (GoldSaleProto_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSaleId;
- (int32_t) saleId;
- (GoldSaleProto_Builder*) setSaleId:(int32_t) value;
- (GoldSaleProto_Builder*) clearSaleId;

- (BOOL) hasStartDate;
- (int64_t) startDate;
- (GoldSaleProto_Builder*) setStartDate:(int64_t) value;
- (GoldSaleProto_Builder*) clearStartDate;

- (BOOL) hasEndDate;
- (int64_t) endDate;
- (GoldSaleProto_Builder*) setEndDate:(int64_t) value;
- (GoldSaleProto_Builder*) clearEndDate;

- (BOOL) hasPackage1SaleIdentifier;
- (NSString*) package1SaleIdentifier;
- (GoldSaleProto_Builder*) setPackage1SaleIdentifier:(NSString*) value;
- (GoldSaleProto_Builder*) clearPackage1SaleIdentifier;

- (BOOL) hasPackage2SaleIdentifier;
- (NSString*) package2SaleIdentifier;
- (GoldSaleProto_Builder*) setPackage2SaleIdentifier:(NSString*) value;
- (GoldSaleProto_Builder*) clearPackage2SaleIdentifier;

- (BOOL) hasPackage3SaleIdentifier;
- (NSString*) package3SaleIdentifier;
- (GoldSaleProto_Builder*) setPackage3SaleIdentifier:(NSString*) value;
- (GoldSaleProto_Builder*) clearPackage3SaleIdentifier;

- (BOOL) hasPackage4SaleIdentifier;
- (NSString*) package4SaleIdentifier;
- (GoldSaleProto_Builder*) setPackage4SaleIdentifier:(NSString*) value;
- (GoldSaleProto_Builder*) clearPackage4SaleIdentifier;

- (BOOL) hasPackage5SaleIdentifier;
- (NSString*) package5SaleIdentifier;
- (GoldSaleProto_Builder*) setPackage5SaleIdentifier:(NSString*) value;
- (GoldSaleProto_Builder*) clearPackage5SaleIdentifier;

- (BOOL) hasGoldShoppeImageName;
- (NSString*) goldShoppeImageName;
- (GoldSaleProto_Builder*) setGoldShoppeImageName:(NSString*) value;
- (GoldSaleProto_Builder*) clearGoldShoppeImageName;

- (BOOL) hasGoldBarImageName;
- (NSString*) goldBarImageName;
- (GoldSaleProto_Builder*) setGoldBarImageName:(NSString*) value;
- (GoldSaleProto_Builder*) clearGoldBarImageName;

- (BOOL) hasPackageS1SaleIdentifier;
- (NSString*) packageS1SaleIdentifier;
- (GoldSaleProto_Builder*) setPackageS1SaleIdentifier:(NSString*) value;
- (GoldSaleProto_Builder*) clearPackageS1SaleIdentifier;

- (BOOL) hasPackageS2SaleIdentifier;
- (NSString*) packageS2SaleIdentifier;
- (GoldSaleProto_Builder*) setPackageS2SaleIdentifier:(NSString*) value;
- (GoldSaleProto_Builder*) clearPackageS2SaleIdentifier;

- (BOOL) hasPackageS3SaleIdentifier;
- (NSString*) packageS3SaleIdentifier;
- (GoldSaleProto_Builder*) setPackageS3SaleIdentifier:(NSString*) value;
- (GoldSaleProto_Builder*) clearPackageS3SaleIdentifier;

- (BOOL) hasPackageS4SaleIdentifier;
- (NSString*) packageS4SaleIdentifier;
- (GoldSaleProto_Builder*) setPackageS4SaleIdentifier:(NSString*) value;
- (GoldSaleProto_Builder*) clearPackageS4SaleIdentifier;

- (BOOL) hasPackageS5SaleIdentifier;
- (NSString*) packageS5SaleIdentifier;
- (GoldSaleProto_Builder*) setPackageS5SaleIdentifier:(NSString*) value;
- (GoldSaleProto_Builder*) clearPackageS5SaleIdentifier;

- (BOOL) hasIsBeginnerSale;
- (BOOL) isBeginnerSale;
- (GoldSaleProto_Builder*) setIsBeginnerSale:(BOOL) value;
- (GoldSaleProto_Builder*) clearIsBeginnerSale;
@end

