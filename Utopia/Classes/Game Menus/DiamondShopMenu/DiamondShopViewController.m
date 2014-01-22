//
//  DiamondShopViewController.m
//  Utopia
//
//  Created by Danny on 9/4/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "DiamondShopViewController.h"
#import "GameState.h"
#import "IAPHelper.h"

#define TABLE_CELL_WIDTH 150

@implementation DiamondListing

- (void) setViewToGreyScale:(UIView *)view {
  for (UIView *v in view.subviews) {
    if ([v isKindOfClass:[UIImageView class]]) {
      UIImageView *imgView = (UIImageView *)v;
      if (imgView.image) {
        imgView.image = [Globals greyScaleImageWithBaseImage:imgView.image];
      }
    }
    
    [self setViewToGreyScale:v];
  }
}

- (void) updateForPurchaseData:(id<InAppPurchaseData>)product greyscale:(BOOL)greyscale canAfford:(BOOL)canAfford {
  // Set Free offer title
  self.nameLabel.text = product.primaryTitle;
  
  if (product.moneyPrice) {
    self.moneyCostLabel.text = product.moneyPrice;
    
    self.moneyCostLabel.hidden = NO;
    self.gemsCostLabel.superview.hidden = YES;
  } else {
    self.gemsCostLabel.text = [Globals commafyNumber:product.gemPrice];
    [Globals adjustViewForCentering:self.gemsCostLabel.superview withLabel:self.gemsCostLabel];
    
    if (!canAfford) {
      self.gemsCostLabel.textColor = [Globals lightRedColor];
    } else {
      self.gemsCostLabel.textColor = [UIColor whiteColor];
    }
    
    self.moneyCostLabel.hidden = YES;
    self.gemsCostLabel.superview.hidden = NO;
  }
  
  if (product.resourceType == ResourceTypeGems) {
    self.gemsAmountLabel.text = [Globals commafyNumber:product.amountGained];
    [Globals adjustViewForCentering:self.gemsAmountLabel.superview withLabel:self.gemsAmountLabel];
    
    self.nameLabel.textColor = [Globals purplishPinkColor];
    
    self.gemsAmountLabel.superview.hidden = NO;
    self.cashAmountLabel.hidden = YES;
    self.oilAmountLabel.superview.hidden = YES;
  } else if (product.resourceType == ResourceTypeCash) {
    self.cashAmountLabel.text = [Globals cashStringForNumber:product.amountGained];
    
    self.nameLabel.textColor = [Globals greenColor];
    
    self.gemsAmountLabel.superview.hidden = YES;
    self.cashAmountLabel.hidden = NO;
    self.oilAmountLabel.superview.hidden = YES;
  } else if (product.resourceType == ResourceTypeOil) {
    self.oilAmountLabel.text = [Globals commafyNumber:product.amountGained];
    [Globals adjustViewForCentering:self.oilAmountLabel.superview withLabel:self.oilAmountLabel];
    
    self.nameLabel.textColor = [Globals yellowColor];
    
    self.gemsAmountLabel.superview.hidden = YES;
    self.cashAmountLabel.hidden = YES;
    self.oilAmountLabel.superview.hidden = NO;
  }
  
  self.bgdImageView.image = [Globals imageNamed:@"buildingbg.png"];
  self.gemCostIcon.image = [Globals imageNamed:@"diamond.png"];
  self.gemAmtIcon.image = [Globals imageNamed:@"diamond.png"];
  self.oilAmtIcon.image = [Globals imageNamed:@"oilicon.png"];
  self.packageIcon.image = nil;
  if (greyscale) [self setViewToGreyScale:self];
  [Globals imageNamed:product.rewardPicName withView:self.packageIcon greyscale:greyscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  self.productData = product;
}

@end

@implementation DiamondShopViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.title = @"Add Funds";
  [self setUpCloseButton];
  [self setUpImageBackButton];
  
  [self setupDiamondTable];
  [self reloadData];
}

- (void) reloadData {
  self.packageData = [NSMutableArray array];
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  IAPHelper *iap = [IAPHelper sharedIAPHelper];
  NSMutableArray *iaps = [NSMutableArray array];
  for (InAppPurchasePackageProto *pkg in gl.iapPackages) {
    SKProduct *prod = iap.products[pkg.iapPackageId];
    if (prod) {
      [iaps addObject:[InAppPurchaseData createWithProduct:prod]];
    }
  }
  [self.packageData addObject:iaps];
  
  NSMutableArray *cash = [NSMutableArray array];
  int maxCash = [gs maxCash];
  [cash addObject:[ResourcePurchaseData createWithResourceType:ResourceTypeCash amount:maxCash*0.1 title:@"Fill Storages by 10%"]];
  [cash addObject:[ResourcePurchaseData createWithResourceType:ResourceTypeCash amount:maxCash*0.5 title:@"Fill Storages by Half"]];
  [cash addObject:[ResourcePurchaseData createWithResourceType:ResourceTypeCash amount:maxCash-gs.silver title:@"Fill Cash Storages"]];
  [self.packageData addObject:cash];
  
  NSMutableArray *oil = [NSMutableArray array];
  int maxOil = [gs maxOil];
  [oil addObject:[ResourcePurchaseData createWithResourceType:ResourceTypeOil amount:maxOil*0.1 title:@"Fill Storages by 10%"]];
  [oil addObject:[ResourcePurchaseData createWithResourceType:ResourceTypeOil amount:maxOil*0.5 title:@"Fill Storages by Half"]];
  [oil addObject:[ResourcePurchaseData createWithResourceType:ResourceTypeOil amount:maxOil-gs.oil title:@"Fill Oil Storages"]];
  [self.packageData addObject:oil];
  
  [self.diamondTable reloadData];
}

- (IBAction) packageClicked:(id)sender {
  if (_isLoading) return;
  
  while (![sender isKindOfClass:[DiamondListing class]]) {
    sender = [sender superview];
  }
  
  DiamondListing *dl = (DiamondListing *)sender;
  BOOL success = [dl.productData makePurchaseWithDelegate:self];
  
  if (success) {
    [self.loadingView display:self.navigationController.view];
    _isLoading = YES;
  }
}

- (void) handleInAppPurchaseResponseProto:(FullEvent *)fe {
  [self.loadingView stop];
  _isLoading = NO;
  [self reloadData];
}

- (void) handleExchangeGemsForResourcesResponseProto:(FullEvent *)fe {
  [self.loadingView stop];
  _isLoading = NO;
  [self reloadData];
}

#pragma mark - EasyTableView delegate methods

- (void) setupDiamondTable {
  self.diamondTable = [[EasyTableView alloc] initWithFrame:self.tableContainerView.bounds numberOfColumns:0 ofWidth:TABLE_CELL_WIDTH];
  self.diamondTable.delegate = self;
  self.diamondTable.tableView.separatorColor = [UIColor clearColor];
  self.diamondTable.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [self.tableContainerView addSubview:self.diamondTable];
}

- (NSUInteger) numberOfSectionsInEasyTableView:(EasyTableView *)easyTableView {
  return 3;
}

- (NSUInteger) numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section {
  return [self.packageData[section] count];
}

- (UIView *) easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect withIndexPath:(NSIndexPath *)indexPath {
  [[NSBundle mainBundle] loadNibNamed:@"DiamondListing" owner:self options:nil];
  self.diamondListing.center = ccp(CGRectGetMidX(rect), CGRectGetMidY(rect));
  return self.diamondListing;
}

- (UIView *) easyTableView:(EasyTableView *)easyTableView viewForHeaderInSection:(NSInteger)section {
  return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, easyTableView.frame.size.height)];
}

- (NSString *) easyTableView:(EasyTableView *)easyTableView stringForHorizontalHeaderInDesction:(NSInteger)section {
  if (section == 0) {
    return @"Gems";
  } else if (section == 1) {
    return @"Cash";
  } else if (section == 2) {
    return @"Oil";
  }
  return nil;
}

- (void) easyTableView:(EasyTableView *)easyTableView setDataForView:(DiamondListing *)view forIndexPath:(NSIndexPath *)indexPath {
  GameState *gs = [GameState sharedGameState];
  BOOL greyscale = NO, canAfford = YES;
  id<InAppPurchaseData> purch = self.packageData[indexPath.section][indexPath.row];
  
  if (indexPath.section == 1) {
    int max = [gs maxCash];
    int avail = max - gs.silver;
    
    greyscale = (avail < purch.amountGained || avail <= 0);
  } else if (indexPath.section == 2) {
    int max = [gs maxOil];
    int avail = max - gs.oil;
    
    greyscale = (avail < purch.amountGained || avail <= 0);
  }
  
  if (gs.gold < purch.gemPrice) {
    canAfford = NO;
  }
  
  [view updateForPurchaseData:purch greyscale:greyscale canAfford:canAfford];
}

@end
