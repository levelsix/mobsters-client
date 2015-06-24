//
//  SoloSaleViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/24/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"
#import "SalePackageViewController.h"
#import "NibUtils.h"

#import "HudNotificationController.h"

@interface SoloSaleViewController : UIViewController <SalesMenuDelegate, TopBarNotification> {
  SalesPackageProto *_sale;
  
  dispatch_block_t _completion;
  
  BOOL _isLoading;
}

@property (nonatomic, retain) SalePackageViewController *saleViewController;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet LoadingView *loadingView;

- (id) initWithSalePackageProto:(SalesPackageProto *)spp;

@end
