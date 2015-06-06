//
//  GemPackageViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/14/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "GemPackageViewController.h"

#import "GameState.h"
#import "Globals.h"
#import "IAPHelper.h"

@implementation GemPackageCell

- (void) updateForPackageInfo:(id<InAppPurchaseData>)package {
  self.nameLabel.text = package.primaryTitle;
  
  self.gemLabel.text = [Globals commafyNumber:package.amountGained];
  
  if (package.moneyPrice) {
    self.priceLabel.text = package.moneyPrice;
  }
  
  [Globals imageNamed:package.rewardPicName withView:self.packageIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
}

- (void)cellTouchDown:(id)sender {
  self.bgCapLeft.highlighted  = YES;
  self.bgMiddle.highlighted   = YES;
  self.bgCapRight.highlighted = YES;
}

- (void)cellTouchUp:(id)sender {
  self.bgCapLeft.highlighted  = NO;
  self.bgMiddle.highlighted   = NO;
  self.bgCapRight.highlighted = NO;
}

@end

@implementation GemPackageViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.containerView.layer.cornerRadius = self.containerView.superview.layer.cornerRadius;
  
  UIView *v = [[UIView alloc] initWithFrame:self.containerView.superview.frame];
  v.backgroundColor = DARKEN_VIEW_COLOR;
  v.tag = DARKEN_VIEW_TAG;
  v.layer.cornerRadius = self.containerView.layer.cornerRadius-1;
  [self.view addSubview:v];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self reloadTable];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:IAPS_RETRIEVED_NOTIFICATION object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Reloading list view

- (void) reloadTable {
  [self reloadPackagesArray];
  [self.packagesTable reloadData];
}

- (void) reloadPackagesArray {
  NSMutableArray *packages = [NSMutableArray array];
  
  Globals *gl = [Globals sharedGlobals];
  IAPHelper *iap = [IAPHelper sharedIAPHelper];
  for (InAppPurchasePackageProto *pkg in gl.iapPackages) {
    if (pkg.iapPackageType == InAppPurchasePackageProto_InAppPurchasePackageTypeGems) {
      SKProduct *prod = iap.products[pkg.iapPackageId];
      if (prod) {
        [packages addObject:[InAppPurchaseData createWithProduct:prod saleUuid:nil]];
      }
    }
  }
  
  self.packages = packages;
}

#pragma mark - Table view delegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.packages.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  GemPackageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GemPackageCell"];
  if (!cell) {
    cell = [[NSBundle mainBundle] loadNibNamed:@"GemPackageCell" owner:self options:nil][0];
  }
  
  id<InAppPurchaseData> iap = self.packages[indexPath.row];
  [cell updateForPackageInfo:iap];
  
  return cell;
}

- (IBAction) cellClicked:(id)sender {
  UITableViewCell *cell = [sender getAncestorInViewHierarchyOfType:[UITableViewCell class]];
  NSIndexPath *ip = [self.packagesTable indexPathForCell:cell];
  
  if (ip.row >= 0 && ip.row < self.packages.count) {
    id<InAppPurchaseData> iap = self.packages[ip.row];
    [self.delegate iapClicked:iap];
  }
}

@end
