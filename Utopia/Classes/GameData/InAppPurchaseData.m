//
//  InAppPurchaseData.m
//  Utopia
//
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "InAppPurchaseData.h"
#import "Globals.h"
#import "IAPHelper.h"
#import "OutgoingEventController.h"
#import "GameState.h"

@implementation InAppPurchaseData

@synthesize primaryTitle, moneyPrice, rewardPicName;
@synthesize resourceType, amountGained, gemPrice;

#pragma InAppPurchaseData

- (BOOL) makePurchaseWithDelegate:(id)delegate {
  if (_product) {
    [[IAPHelper sharedIAPHelper] buyProductIdentifier:_product withDelegate:delegate];
    return YES;
  }
  return NO;
}

#pragma mark  Create/Destroy
- (id) initWithProduct:(SKProduct *)product {
  if ((self = [super init])) {
    _product  = product;
    
    Globals *gl = [Globals sharedGlobals];
    
    primaryTitle = _product.localizedTitle;
    moneyPrice = [[IAPHelper sharedIAPHelper] priceForProduct:_product];
    resourceType = ResourceTypeGems;
    
    InAppPurchasePackageProto *p = [gl packageForProductId:_product.productIdentifier];
    rewardPicName = p.imageName;
    amountGained = p.currencyAmount;
  }
  return self;
}

+ (id<InAppPurchaseData>) createWithProduct:(SKProduct *)product {
  InAppPurchaseData *offer = [[InAppPurchaseData alloc] initWithProduct:product];
  return offer;
}

@end

@implementation ResourcePurchaseData

@synthesize primaryTitle, moneyPrice, rewardPicName;
@synthesize resourceType, amountGained, gemPrice;

- (id) initWithResourceType:(ResourceType)type amount:(int)amount percFill:(int)percFill storageTier:(int)storageTier title:(NSString *)title {
  if ((self = [super init])) {
    primaryTitle = title;
    resourceType = type;
    amountGained = amount;
    _percFill = percFill;
    
    Globals *gl = [Globals sharedGlobals];
    gemPrice = [gl calculateGemConversionForResourceType:type amount:amount];
    
    //Find highest storage of this resource
    GameState *gs = [GameState sharedGameState];
    UserStruct *us = nil;
    for (UserStruct *check in gs.myStructs) {
      ResourceStorageProto *gen = (ResourceStorageProto *)check.staticStruct;
      if (gen.structInfo.structType == StructureInfoProto_StructTypeResourceStorage &&
          gen.resourceType == type) {
        if (gen.structInfo.level > us.staticStruct.structInfo.level) {
          us = check;
        }
      }
    }
    
    rewardPicName = [NSString stringWithFormat:@"%dFunds%@", storageTier, us.staticStruct.structInfo.imgName];
  }
  return self;
}

+ (id<InAppPurchaseData>)createWithResourceType:(ResourceType)type amount:(int)amount percFill:(int)percFill storageTier:(int)storageTier title:(NSString *)title {
  return [[self alloc] initWithResourceType:type amount:amount percFill:percFill storageTier:storageTier title:title];
}

- (BOOL) makePurchaseWithDelegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  if (resourceType == ResourceTypeCash && (gs.maxCash-gs.cash < amountGained || amountGained <= 0)) {
    [Globals addAlertNotification:@"Not enough storage!"];
  } else if (resourceType == ResourceTypeOil && (gs.maxOil-gs.oil < amountGained || amountGained <= 0)) {
    [Globals addAlertNotification:@"Not enough storage!"];
  } else if (gemPrice > gs.gems) {
    [Globals addAlertNotification:@"Need more gems!"];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] exchangeGemsForResources:gemPrice resources:amountGained percFill:_percFill resType:resourceType delegate:delegate];
    return YES;
  }
  return NO;
}

@end
