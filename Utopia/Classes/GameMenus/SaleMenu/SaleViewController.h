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

@property (nonatomic, retain) IBOutlet UIImageView *cellBgd;

@end

@interface SaleViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate> {
  float _lastWigglePauseTime;
}

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet UIImageView *litBgdView;
@property (nonatomic, retain) IBOutlet UIImageView *builderIcon;

@property (nonatomic, retain) IBOutlet UIImageView *timerIcon;
@property (nonatomic, retain) IBOutlet THLabel *endsInLabel;
@property (nonatomic, retain) IBOutlet THLabel *timeLeftLabel;
@property (nonatomic, retain) IBOutlet THLabel *priceLabel;

@property (nonatomic, retain) IBOutlet UILabel *numItemsLabel;

@property (nonatomic, retain) IBOutlet UICollectionView *bonusItemsCollectionView;

@property (nonatomic, retain) IBOutlet LoadingView *loadingView;

@property (nonatomic, retain) BoosterPackProto *sale;
@property (nonatomic, retain) SKProduct *product;

@property (nonatomic, retain) NSTimer *updateTimer;

- (id) initWithSale:(BoosterPackProto *)sale product:(SKProduct *)product;

@end
