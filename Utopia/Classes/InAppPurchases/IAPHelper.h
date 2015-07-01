#import <Foundation/Foundation.h>
#import "StoreKit/StoreKit.h"

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    NSDictionary * _products;
    SKProductsRequest * _request;
  
  id _purchaseDelegate;
}

@property (retain) NSDictionary *products;
@property (retain) SKProductsRequest *request;
@property (retain) SKPaymentTransaction *lastTransaction;

+ (IAPHelper *) sharedIAPHelper;
- (void) requestProducts;
- (void) buyProductIdentifier:(SKProduct *)product saleUuid:(NSString *)saleUuid withDelegate:(id)delegate;
- (NSString *) priceForProduct:(SKProduct *)product;
- (NSString *) base64forData:(NSData *)theData;
- (SKProduct *) productForIdentifier:(NSString *)productId;

@end