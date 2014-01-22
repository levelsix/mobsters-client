#import <Foundation/Foundation.h>
#import "StoreKit/StoreKit.h"

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    NSDictionary * _products;
    SKProductsRequest * _request;
  
  id _purchaseDelegate;
}

@property (retain) NSDictionary *products;
@property (retain) SKProductsRequest *request;

+ (IAPHelper *) sharedIAPHelper;
- (void) requestProducts;
- (void) buyProductIdentifier:(SKProduct *)product withDelegate:(id)delegate;
- (NSString *) priceForProduct:(SKProduct *)product;

@end
