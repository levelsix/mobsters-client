//
//  NotificationShopViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/17/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "NotificationShopViewController.h"
#import "GameViewController.h"

@interface NotificationShopViewController ()

@end

@implementation NotificationShopViewController

- (id) initWithSalesPackage:(SalesPackageProto *)spp {
  if ((self = [super initWithNibName:@"ShopViewController" bundle:nil])) {
  }
  return self;
}

- (void) unloadAllControllers {
  // Call completion here since this happens after animation block ends
  [super unloadAllControllers];
  
  if (_completion) {
    _completion();
  }
}

#pragma mark - TopBarNotification protocol

- (NotificationLocationType) locationType {
  return NotificationLocationTypeFullScreen;
}

- (NotificationPriority) priority {
  return NotificationPriorityImmediate;
}

- (void) animateWithCompletionBlock:(dispatch_block_t)completion {
  // Swap stuff around so that top bar will just open it for us
  GameViewController *gvc = [GameViewController baseController];
  TopBarViewController *tvc = gvc.topBarViewController;
  ShopViewController *curShop = tvc.shopViewController;
  
  tvc.shopViewController = self;
  self.delegate = tvc;
  
  [tvc openShopWithFunds:_initialSale];
  
  tvc.shopViewController = curShop;
  
  _completion = completion;
}

- (void) endAbruptly {
  [self close];
}

@end
