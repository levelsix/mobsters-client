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

@interface DiamondListing : UIView

@property (nonatomic, strong) id<InAppPurchaseData> productData;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *boughtAmountLabel;
@property (nonatomic, strong) IBOutlet UILabel *costLabel;
@property (nonatomic, strong) IBOutlet UIImageView *diamondImageView;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundImage;
@property (nonatomic, strong) IBOutlet UIImageView *darkOverlay;

- (void) updateForPurchaseData:(id<InAppPurchaseData>)product;

@end

@interface DiamondListingContainer : UIView

@property (nonatomic, strong) IBOutlet DiamondListing *diamondListing;

@end

//this is for the blank space at the bottom
@interface BlankCell : UITableViewCell

@end

@interface DiamondListingCell : UITableViewCell

@property (nonatomic, strong) IBOutlet DiamondListingContainer *listing1;
@property (nonatomic, strong) IBOutlet DiamondListingContainer *listing2;
@property (nonatomic, strong) IBOutlet DiamondListingContainer *listing3;

@end

@interface DiamondShopViewController : GenViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet DiamondListingCell *diamondRow;
@property (nonatomic, strong) IBOutlet BlankCell *blankCell;
@property (nonatomic, strong) IBOutlet UITableView *diamondTable;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) IBOutlet UILabel *cashLabel;
@property (nonatomic, strong) IBOutlet UILabel *gemLabel;

@end
