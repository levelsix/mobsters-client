//
//  FundsViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/29/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "FundsViewController.h"

#import "Globals.h"
#import "GameState.h"
#import "IAPHelper.h"
#import "InAppPurchaseData.h"
#import "GenericPopupController.h"

@implementation FundsViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.listView.cellClassName = @"FundsCardCell";
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self reloadListView];
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [self adjustSizeOfView];
}

- (void) adjustSizeOfView {
  CGSize cs = self.listView.collectionView.contentSize;
  CGRect f = self.view.frame;
  CGSize ss = self.view.superview.frame.size;
  if (cs.width < ss.width) {
    self.listView.collectionView.scrollEnabled = NO;
    
    f.size = cs;
    f.origin.x = ss.width/2-f.size.width/2;
    self.view.frame = f;
  } else {
    self.listView.collectionView.contentOffset = ccp(0,0);
    self.listView.collectionView.scrollEnabled = YES;
  }
}

#pragma mark - Reloading list view

- (void) reloadListView {
  [self reloadPackagesArray];
  [self.listView reloadTableAnimated:NO listObjects:self.packages];
  
  [self adjustSizeOfView];
}

- (void) reloadPackagesArray {
  NSMutableArray *packages = [NSMutableArray array];
  
  Globals *gl = [Globals sharedGlobals];
  IAPHelper *iap = [IAPHelper sharedIAPHelper];
  for (InAppPurchasePackageProto *pkg in gl.iapPackages) {
    if (pkg.iapPackageType == InAppPurchasePackageProto_InAppPurchasePackageTypeGems) {
      SKProduct *prod = iap.products[pkg.iapPackageId];
      if (prod) {
        [packages addObject:[InAppPurchaseData createWithProduct:prod]];
      }
    }
  }
  
//  GameState *gs = [GameState sharedGameState];
//  int maxCash = [gs maxCash];
//  [packages addObject:[ResourcePurchaseData createWithResourceType:ResourceTypeCash amount:maxCash*0.1 percFill:10 storageTier:2 title:@"Fill (10%)"]];
//  [packages addObject:[ResourcePurchaseData createWithResourceType:ResourceTypeCash amount:maxCash*0.5 percFill:50 storageTier:3 title:@"Fill (50%)"]];
//  [packages addObject:[ResourcePurchaseData createWithResourceType:ResourceTypeCash amount:maxCash-gs.cash percFill:100 storageTier:4 title:@"Fill Storages"]];
//  
//  int maxOil = [gs maxOil];
//  [packages addObject:[ResourcePurchaseData createWithResourceType:ResourceTypeOil amount:maxOil*0.1 percFill:10 storageTier:2 title:@"Fill (10%)"]];
//  [packages addObject:[ResourcePurchaseData createWithResourceType:ResourceTypeOil amount:maxOil*0.5 percFill:50 storageTier:3 title:@"Fill (50%)"]];
//  [packages addObject:[ResourcePurchaseData createWithResourceType:ResourceTypeOil amount:maxOil-gs.oil percFill:100 storageTier:4 title:@"Fill Storages"]];
//  
  self.packages = packages;
}

#pragma mark - List view delegate

- (void) listView:(ListCollectionView *)listView updateCell:(FundsCardCell *)cell forIndexPath:(NSIndexPath *)indexPath listObject:(id<InAppPurchaseData>)purch {
  GameState *gs = [GameState sharedGameState];
  BOOL greyscale = NO;
  
  if (purch.resourceType == ResourceTypeCash) {
    int max = [gs maxCash];
    int avail = max - gs.cash;
    
    greyscale = (avail < purch.amountGained || avail <= 0);
  } else if (purch.resourceType == ResourceTypeOil) {
    int max = [gs maxOil];
    int avail = max - gs.oil;
    
    greyscale = (avail < purch.amountGained || avail <= 0);
  }
  
  [cell updateForPackageInfo:purch isLocked:greyscale];
}

- (void) listView:(ListCollectionView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath {
  if (_isLoading) return;
  
  id<InAppPurchaseData> purch = self.packages[indexPath.row];
  
  _purchase = purch;
  if (purch.gemPrice) {
    GameState *gs = [GameState sharedGameState];
    if (!purch.amountGained ||
        (purch.resourceType == ResourceTypeCash && (purch.amountGained > gs.maxCash-gs.cash)) ||
        (purch.resourceType == ResourceTypeOil && (purch.amountGained > gs.maxOil-gs.oil))) {
      [Globals addAlertNotification:@"Not enough storage!"];
    } else {
      NSString *title = [NSString stringWithFormat:@"Buy %@?", [Globals stringForResourceType:purch.resourceType]];
      NSString *desc = [NSString stringWithFormat:@"Would you like to buy %@ %@?", [Globals commafyNumber:[purch amountGained]], [Globals stringForResourceType:purch.resourceType]];
      [GenericPopupController displayGemConfirmViewWithDescription:desc title:title gemCost:purch.gemPrice target:self selector:@selector(makePurchase)];
    }
  } else {
    [self makePurchase];
  }
}

- (void) makePurchase {
  BOOL success = [_purchase makePurchaseWithDelegate:self];
  _purchase = nil;
  if (success) {
    [self.loadingView display:self.parentViewController.view];
    _isLoading = YES;
  }
}

- (void) handleInAppPurchaseResponseProto:(FullEvent *)fe {
  [self.loadingView stop];
  _isLoading = NO;
  [self reloadListView];
}

- (void) handleExchangeGemsForResourcesResponseProto:(FullEvent *)fe {
  [self.loadingView stop];
  _isLoading = NO;
  [self reloadListView];
}

@end
