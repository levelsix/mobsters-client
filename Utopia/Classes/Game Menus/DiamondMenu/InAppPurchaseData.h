//
//  InAppPurchaseData.h
//  Utopia
//
//  Created by Kevin Calloway on 5/22/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#define UNKNOWN_PRICE_STR   @"$$$"
#define FREE_PRICE_STR      @"Free"
#define NO_CLIPS            @"No Clips Available"

@protocol InAppPurchaseData <NSObject>
@property(nonatomic, readonly) NSString *primaryTitle;
@property(nonatomic, readonly) NSString *secondaryTitle;
@property(nonatomic, readonly) BOOL isGold;
@property(nonatomic, readonly) NSString *price;
@property(nonatomic, readonly) NSString *salePrice;
@property(nonatomic, readonly) NSString *rewardPicName;
@property(nonatomic, readonly) int discount;

-(void) makePurchaseWithViewController:(UIViewController *)controller;
-(BOOL) purchaseAvailable;
@end

@interface InAppPurchaseData : NSObject<InAppPurchaseData> {
  SKProduct *_product;
  SKProduct *_saleProduct;
}

+(NSString *) unknownPrice;
+(NSString *) freePrice;
+(NSString *) adTakeoverResignedNotification;
+(void) postAdTakeoverResignedNotificationForSender:(id)sender;

#pragma Factory Methods
+(id<InAppPurchaseData>) createWithProduct:(SKProduct *)product saleProduct:(SKProduct *)saleProduct;
+(NSArray *) allSponsoredOffers;
@end
