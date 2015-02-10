//
//  SaleViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/9/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

#import "NibUtils.h"
#import "Protocols.pb.h"

@interface SaleViewCell : UICollectionViewCell

@property (nonatomic, retain) IBOutlet UIImageView *itemIcon;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *quantityLabel;

@end

@interface SaleViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet UIImageView *timerIcon;
@property (nonatomic, retain) IBOutlet THLabel *timeLeftLabel;
@property (nonatomic, retain) IBOutlet THLabel *priceLabel;

@property (nonatomic, retain) IBOutlet UICollectionView *bonusItemsCollectionView;

@property (nonatomic, retain) IBOutlet LoadingView *loadingView;

@property (nonatomic, retain) BoosterPackProto *sale;
@property (nonatomic, retain) SKProduct *product;

@property (nonatomic, retain) NSTimer *updateTimer;

- (id) initWithSale:(BoosterPackProto *)sale product:(SKProduct *)product;

@end
