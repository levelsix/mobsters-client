//
//  NotificationShopViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/17/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ShopViewController.h"

#import "HudNotificationController.h"

@interface NotificationShopViewController : ShopViewController <TopBarNotification> {
  SalesPackageProto *_initialSale;
  
  dispatch_block_t _completion;
}

- (id) initWithSalesPackage:(SalesPackageProto *)spp;

@end
