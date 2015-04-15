//
//  SalePurchasedViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/15/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Protocols.pb.h"

@interface SalePurchasedViewController : UIViewController {
  SalesPackageProto *_sale;
}

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;
@property (nonatomic, retain) IBOutlet UIView *headerView;

@property (nonatomic, retain) IBOutlet UICollectionView *bonusItemsCollectionView;

- (id) initWithSalePackageProto:(SalesPackageProto *)spp;

@end
