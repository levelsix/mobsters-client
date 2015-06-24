//
//  SoloSaleViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/24/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SoloSaleViewController.h"
#import "Globals.h"
#import "GameViewController.h"

@interface SoloSaleViewController ()

@end

@implementation SoloSaleViewController


- (id) initWithSalePackageProto:(SalesPackageProto *)spp {
  if ((self = [super init])) {
    _sale = spp;
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  SalePackageViewController *spvc = [[SalePackageViewController alloc] initWithSalePackageProto:_sale];
  [self addChildViewController:spvc];
  [self.view addSubview:spvc.view];
  spvc.view.center = CGPointMake(self.view.width/2, self.view.height/2);
  spvc.delegate = self;
  self.saleViewController = spvc;
  
  [Globals bounceView:spvc.view fadeInBgdView:self.bgdView];
}

- (void) iapClicked:(id<InAppPurchaseData>)iap {
  if (_isLoading) {
    return;
  }
  
  BOOL success = [iap makePurchaseWithDelegate:self];
  if (success) {
    GameViewController *gvc = [GameViewController baseController];
    [self.loadingView display:gvc.view];
    _isLoading = YES;
  }
}

- (void) handleInAppPurchaseResponseProto:(FullEvent *)fe {
  [self.loadingView stop];
  _isLoading = NO;
  
  [self closeClicked:nil];
}

- (IBAction) closeClicked:(id)sender {
  [Globals popOutView:self.saleViewController.view fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
    if (_completion) {
      _completion();
    }
  }];
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
  [gvc addChildViewController:self];
  self.view.frame = gvc.view.bounds;
  [gvc.view addSubview:self.view];
  
  _completion = completion;
}

- (void) endAbruptly {
  [self closeClicked:nil];
}

@end
