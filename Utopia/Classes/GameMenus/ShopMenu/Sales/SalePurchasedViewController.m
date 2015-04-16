//
//  SalePurchasedViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/15/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SalePurchasedViewController.h"

#import "SalePackageViewController.h"
#import "InAppPurchaseData.h"
#import "Globals.h"

@interface SalePurchasedViewController ()

@end

@implementation SalePurchasedViewController

static NSString *nibName = @"SalePackageCell";

- (id) initWithSalePackageProto:(SalesPackageProto *)spp {
  if ((self = [super init])) {
    _sale = spp;
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  [self.bonusItemsTable registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellReuseIdentifier:nibName];
  self.bonusItemsTable.superview.layer.cornerRadius = 5.f;
  
  self.headerView.layer.cornerRadius = 5.f;
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (IBAction)closeClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

#pragma mark - Collection View Data Source/Delegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _sale.sdipList.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  SalePackageCell *cell = [tableView dequeueReusableCellWithIdentifier:nibName forIndexPath:indexPath];
  
  [cell updateForDisplayItem:_sale.sdipList[indexPath.row] isSpecial:indexPath.row == 0];
  
  return cell;
}

@end
