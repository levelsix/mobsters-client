//
//  IAPHelper.m
//  InAppRage
//
//  Created by Ray Wenderlich on 2/28/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "IAPHelper.h"
#import "Protocols.pb.h"
#import "OutgoingEventController.h"
#import "Globals.h"
#import "LNSynthesizeSingleton.h"
#import "GameState.h"

@implementation IAPHelper

@synthesize  products = _products;
@synthesize request = _request;

LN_SYNTHESIZE_SINGLETON_FOR_CLASS(IAPHelper);

- (id)init {
  if ((self = [super init])) {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
  }
  return self;
}

- (void)requestProducts {
  Globals *gl = [Globals sharedGlobals];
  NSMutableSet *productIds = [NSMutableSet setWithArray:gl.productIdsToPackages.allKeys];
  
  if (productIds.count > 0) {
    self.request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIds];
    _request.delegate = self;
    [_request start];
  }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
  LNLog(@"Received products results for %d products...", (int)response.products.count);
  
  NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:response.products.count];
  for (SKProduct *p in response.products) {
    [d setObject:p forKey:p.productIdentifier];
  }
  self.products = d;
  self.request = nil;
  
  LNLog(@"Invalid product ids: %@", response.invalidProductIdentifiers);
  
  //  if (response.products.count == 0) {
  //    [self requestProducts];
  //  }
}

- (NSString*)base64forData:(NSData*)theData {
  const uint8_t* input = (const uint8_t*)[theData bytes];
  NSInteger length = [theData length];
  
  static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
  
  NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
  uint8_t* output = (uint8_t*)data.mutableBytes;
  
  NSInteger i;
  for (i=0; i < length; i += 3) {
    NSInteger value = 0;
    NSInteger j;
    for (j = i; j < (i + 3); j++) {
      value <<= 8;
      
      if (j < length) {
        value |= (0xFF & input[j]);
      }
    }
    
    NSInteger theIndex = (i / 3) * 4;
    output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
    output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
    output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
    output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
  }
  
  return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

- (NSString *) priceForProduct:(SKProduct *)product {
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
  [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
  [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  [numberFormatter setLocale:product.priceLocale];
  NSString *str = [numberFormatter stringFromNumber:product.price];
  return str;
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
  LNLog(@"completeTransaction...");
  
  Globals *gl = [Globals sharedGlobals];
  NSString *encodedReceipt = [self base64forData:transaction.transactionReceipt];
  NSString *productId = transaction.payment.productIdentifier;
  InAppPurchasePackageProto *pkg = [gl packageForProductId:productId];
  int goldAmt = pkg.currencyAmount;
  SKProduct *prod = [self.products objectForKey:productId];
  
  [[OutgoingEventController sharedOutgoingEventController] inAppPurchase:encodedReceipt goldAmt:goldAmt silverAmt:0 product:prod delegate:_purchaseDelegate];
  [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
  if (transaction.error.code != SKErrorPaymentCancelled)
  {
    LNLog(@"Transaction error: %@", transaction.error.localizedDescription);
    [Globals popupMessage:[NSString stringWithFormat:@"Error: %@", transaction.error.localizedDescription]];
  } else {
    // Transaction was cancelled
    [Analytics cancelledGoldPackage:transaction.payment.productIdentifier];
  }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
  [_purchaseDelegate performSelector:NSSelectorFromString(@"handleInAppPurchaseResponseProto:") withObject:nil];
#pragma clang diagnostic pop
  
  [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
  for (SKPaymentTransaction *transaction in transactions)
  {
    switch (transaction.transactionState)
    {
      case SKPaymentTransactionStatePurchased:
        [self completeTransaction:transaction];
        break;
      case SKPaymentTransactionStateFailed:
        [self failedTransaction:transaction];
        break;
      default:
        break;
    }
  }
}

- (void)buyProductIdentifier:(SKProduct *)product withDelegate:(id)delegate {
  if (!product) {
    [Globals popupMessage:@"An error has occurred processing this transaction.."];
    return;
  }
  
  LNLog(@"Buying %@...", product.debugDescription);
  
  SKPayment *payment = [SKPayment paymentWithProduct:product];
  [[SKPaymentQueue defaultQueue] addPayment:payment];
  
  _purchaseDelegate = delegate;
}

@end
