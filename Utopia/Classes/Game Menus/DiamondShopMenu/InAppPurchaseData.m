//
//  InAppPurchaseData.m
//  Utopia
//
//  Created by Kevin Calloway on 5/22/12.
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

- (id) initWithResourceType:(ResourceType)type amount:(int)amount title:(NSString *)title {
  if ((self = [super init])) {
    primaryTitle = title;
    resourceType = type;
    amountGained = amount;
    
    Globals *gl = [Globals sharedGlobals];
    gemPrice = [gl calculateGemConversionForResourceType:type amount:amount];
  }
  return self;
}

+ (id<InAppPurchaseData>)createWithResourceType:(ResourceType)type amount:(int)amount title:(NSString *)title {
  return [[self alloc] initWithResourceType:type amount:amount title:title];
}

- (BOOL) makePurchaseWithDelegate:(id)delegate {
  GameState *gs = [GameState sharedGameState];
  if (resourceType == ResourceTypeCash && (gs.maxCash-gs.silver < amountGained || amountGained <= 0)) {
    [Globals addAlertNotification:@"Not enough storage!"];
  } else if (resourceType == ResourceTypeOil && (gs.maxOil-gs.oil < amountGained || amountGained <= 0)) {
    [Globals addAlertNotification:@"Not enough storage!"];
  } else if (gemPrice > gs.gold) {
    [Globals addAlertNotification:@"Need more gold!"];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] exchangeGemsForResources:gemPrice resources:amountGained resType:resourceType delegate:delegate];
    return YES;
  }
  return NO;
}

@end
