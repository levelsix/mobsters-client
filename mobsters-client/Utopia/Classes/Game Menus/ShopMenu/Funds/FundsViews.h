//
//  FundsViews.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/29/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ListCollectionView.h"
#import "InAppPurchaseData.h"

@interface FundsCardCell : ListCollectionViewCell

@property (nonatomic, retain) IBOutlet UIImageView *packageIcon;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;

@property (nonatomic, retain) IBOutlet UILabel *resGainedLabel;
@property (nonatomic, retain) IBOutlet UIImageView *cashIcon;
@property (nonatomic, retain) IBOutlet UIImageView *oilIcon;
@property (nonatomic, retain) IBOutlet UIImageView *gemIcon;

@property (nonatomic, retain) IBOutlet UILabel *priceMoneyLabel;
@property (nonatomic, retain) IBOutlet UIImageView *priceGemIcon;
@property (nonatomic, retain) IBOutlet UILabel *priceGemLabel;

@property (nonatomic, retain) IBOutlet UILabel *lockedLabel;

@property (nonatomic, retain) IBOutlet UIView *lockedView;
@property (nonatomic, retain) IBOutlet UIView *unlockedView;

- (void) updateForPackageInfo:(id<InAppPurchaseData>)package isLocked:(BOOL)isLocked;

@end
