//
//  CarpenterViewController.h
//  Utopia
//
//  Created by Danny on 9/4/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "Globals.h"
#import "EasyTableView.h"

@interface CarpenterListing : UIView

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *buildTimeLabel;
@property (nonatomic, strong) IBOutlet UILabel *buildCashCostLabel;
@property (nonatomic, strong) IBOutlet UILabel *buildOilCostLabel;
@property (nonatomic, strong) IBOutlet UILabel *quantityLabel;
@property (nonatomic, strong) IBOutlet UIImageView *buildingImageView;
@property (nonatomic, strong) IBOutlet UIImageView *bgdImageView;
@property (nonatomic, strong) IBOutlet UIImageView *bgdInfoImageView;
@property (nonatomic, strong) IBOutlet UIButton *infoButton;

@property (nonatomic, strong) IBOutlet UILabel *nameDescriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, strong) IBOutlet UIView *mainView;
@property (nonatomic, strong) IBOutlet UIView *descriptionView;

@property (nonatomic, strong) StructureInfoProto *structInfo;

@property (nonatomic, assign) BOOL isFlipped;

- (void) flip;

@end

@interface CarpenterViewController : GenViewController <EasyTableViewDelegate>

@property (nonatomic, strong) IBOutlet CarpenterListing *carpListing;
@property (nonatomic, strong) IBOutlet UIView *tableContainerView;
@property (nonatomic, strong) IBOutlet EasyTableView *structTable;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) NSMutableArray *structsList;

@property (nonatomic, strong) IBOutlet UILabel *cashLabel;
@property (nonatomic, strong) IBOutlet UILabel *diamondLabel;

- (void) reloadCarpenterStructs;
- (IBAction)goToGoldShop:(id)sender;

- (IBAction)buildingClicked:(id)sender;
- (IBAction)infoClicked:(id)sender;

@end