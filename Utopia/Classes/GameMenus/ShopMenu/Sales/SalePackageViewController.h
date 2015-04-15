//
//  SalePackageViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/14/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupSubViewController.h"

#import "SalesMenuDelegate.h"
#import "Protocols.pb.h"
#import "NibUtils.h"

@interface SalePackageCell : UICollectionViewCell

@property (nonatomic, retain) IBOutlet UIImageView *itemIcon;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *quantityLabel;

@property (nonatomic, retain) IBOutlet UIImageView *cellBgd;

@end

@interface SalePackageViewController : PopupSubViewController {
  SalesPackageProto *_sale;
  SKProduct *_product;
}

@property (nonatomic, retain) IBOutlet UIView *infoView;
@property (nonatomic, retain) IBOutlet UIView *containerView;

@property (nonatomic, retain) IBOutlet THLabel *endsInLabel;
@property (nonatomic, retain) IBOutlet THLabel *timeLeftLabel;
@property (nonatomic, retain) IBOutlet THLabel *priceLabel;

@property (nonatomic, retain) IBOutlet UILabel *numItemsLabel;

@property (nonatomic, retain) IBOutlet UICollectionView *bonusItemsCollectionView;

@property (nonatomic, assign) id<SalesMenuDelegate> delegate;

- (id) initWithSalePackageProto:(SalesPackageProto *)spp;

@end
