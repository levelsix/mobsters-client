//
//  InAppPurchaseData.h
//  Utopia
//
//  Created by Kevin Calloway on 5/22/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "Protocols.pb.h"

@protocol InAppPurchaseData <NSObject>

@property(nonatomic, copy) NSString *primaryTitle;
@property(nonatomic, assign) ResourceType resourceType;
@property(nonatomic, assign) int amountGained;
@property(nonatomic, assign) int gemPrice;
@property(nonatomic, copy) NSString *moneyPrice;
@property(nonatomic, copy) NSString *rewardPicName;

- (BOOL) makePurchaseWithDelegate:(id)delegate;

@end

@interface InAppPurchaseData : NSObject<InAppPurchaseData> {
  SKProduct *_product;
}

+ (id<InAppPurchaseData>) createWithProduct:(SKProduct *)product;

@end

@interface ResourcePurchaseData : NSObject<InAppPurchaseData>

+ (id<InAppPurchaseData>) createWithResourceType:(ResourceType)type amount:(int)amount title:(NSString *)title;

@end
