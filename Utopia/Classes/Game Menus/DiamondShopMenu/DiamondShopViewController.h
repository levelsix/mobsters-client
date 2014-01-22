//
//  DiamondShopViewController.h
//  Utopia
//
//  Created by Danny on 9/4/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "Globals.h"
#import <StoreKit/StoreKit.h>
#import "InAppPurchaseData.h"
#import "NibUtils.h"
#import "EasyTableView.h"

@interface DiamondListing : UIView

@property (nonatomic, strong) id<InAppPurchaseData> productData;

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;

@property (nonatomic, strong) IBOutlet UILabel *gemsAmountLabel;
@property (nonatomic, strong) IBOutlet UILabel *cashAmountLabel;
@property (nonatomic, strong) IBOutlet UILabel *oilAmountLabel;

@property (nonatomic, strong) IBOutlet UILabel *moneyCostLabel;
@property (nonatomic, strong) IBOutlet UILabel *gemsCostLabel;

@property (nonatomic, strong) IBOutlet UIImageView *packageIcon;
@property (nonatomic, strong) IBOutlet UIImageView *bgdImageView;

@property (nonatomic, strong) IBOutlet UIImageView *gemCostIcon;
@property (nonatomic, strong) IBOutlet UIImageView *gemAmtIcon;
@property (nonatomic, strong) IBOutlet UIImageView *oilAmtIcon;

- (void) updateForPurchaseData:(id<InAppPurchaseData>)product greyscale:(BOOL)greyscale canAfford:(BOOL)canAfford;

@end

@interface DiamondShopViewController : GenViewController <EasyTableViewDelegate> {
  BOOL _isLoading;
}

@property (nonatomic, strong) IBOutlet DiamondListing *diamondListing;
@property (nonatomic, strong) IBOutlet EasyTableView *diamondTable;
@property (nonatomic, strong) IBOutlet UIView *tableContainerView;

@property (nonatomic, strong) IBOutlet NSMutableArray *packageData;

@property (nonatomic, strong) IBOutlet LoadingView *loadingView;

- (IBAction) packageClicked:(id)sender;

@end
