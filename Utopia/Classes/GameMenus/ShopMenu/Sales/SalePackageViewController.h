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

@interface SalePackageCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *itemIcon;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *quantityLabel;

@property (nonatomic, retain) IBOutlet UIImageView *cellBgd;

- (void) updateForDisplayItem:(SalesDisplayItemProto *)display isSpecial:(BOOL)isSpecial;

@end

@interface SalePackageViewController : PopupSubViewController <UITableViewDataSource> {
  SalesPackageProto *_sale;
  SKProduct *_product;
  
  BOOL _jiggleOn;
}

@property (nonatomic, retain) IBOutlet UIView *infoView;
@property (nonatomic, retain) IBOutlet UIView *containerView;

@property (nonatomic, retain) IBOutlet UIView *loadingView;

@property (nonatomic, retain) IBOutlet UIView *timerIcon;
@property (nonatomic, retain) IBOutlet THLabel *endsInLabel;
@property (nonatomic, retain) IBOutlet THLabel *timeLeftLabel;
@property (nonatomic, retain) IBOutlet THLabel *priceLabel;

@property (nonatomic, retain) IBOutlet UILabel *numItemsLabel;

@property (nonatomic, retain) IBOutlet UITableView *bonusItemsTable;

@property (nonatomic, assign) id<SalesMenuDelegate> delegate;

- (id) initWithSalePackageProto:(SalesPackageProto *)spp;

- (void) stopAllJiggling;
- (void) startAllJiggling;

@end
