//
//  CarpenterViewController.h
//  Utopia
//
//  Created by Danny on 9/4/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "Globals.h"

@interface CarpenterListing : UIView {
  int _structId;
  BOOL _canClick;
}

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *rateLabel;
@property (nonatomic, strong) IBOutlet UILabel *costLabel;
@property (nonatomic, strong) IBOutlet UIImageView *buildingImageView;
@property (nonatomic, strong) IBOutlet UIImageView *moneyIcon;
@property (nonatomic, strong) IBOutlet UIButton *button;

@property (nonatomic, strong) FullStructureProto *fsp;

@end

@interface CarpenterListingContainer : UIView

@property (nonatomic, strong) IBOutlet CarpenterListing *carpenterListing;

@end

@interface CarpenterListingCell : UITableViewCell

@property (nonatomic, strong) IBOutlet CarpenterListingContainer *listing1;
@property (nonatomic, strong) IBOutlet CarpenterListingContainer *listing2;
@property (nonatomic, strong) IBOutlet CarpenterListingContainer *listing3;

@end

@interface CarpenterViewController : GenViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet CarpenterListingCell *carpRow;
@property (nonatomic, strong) IBOutlet UITableView *carpTable;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) NSMutableArray *structsList;

@property (nonatomic, strong) IBOutlet UILabel *cashLabel;
@property (nonatomic, strong) IBOutlet UILabel *diamondLabel;

- (void) reloadCarpenterStructs;
- (IBAction)goToGoldShop:(id)sender;

@end