//
//  GemPackageViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/14/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InAppPurchaseData.h"
#import "SalesMenuDelegate.h"

@interface GemPackageCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *packageIcon;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;

@property (nonatomic, retain) IBOutlet UILabel *gemLabel;

@property (nonatomic, retain) IBOutlet UILabel *priceLabel;

- (void) updateForPackageInfo:(id<InAppPurchaseData>)package;

@end

@interface GemPackageViewController : UIViewController <UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UIView *containerView;

@property (nonatomic, retain) IBOutlet UITableView *packagesTable;

@property (nonatomic, retain) NSArray *packages;
@property (nonatomic, weak) id<SalesMenuDelegate> delegate;

- (IBAction)cellClicked:(id)sender;

@end
