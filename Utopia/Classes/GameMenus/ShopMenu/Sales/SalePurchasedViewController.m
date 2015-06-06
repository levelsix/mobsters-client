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
#import "GameState.h"

@interface SalePurchasedViewController ()

@end

@implementation SalePurchasedViewController

static NSString *nibName = @"SalePackageCell";

- (id) initWithSalePackageProto:(SalesPackageProto *)spp {
  if ((self = [super init])) {
    _sale = spp;
    
    NSMutableArray *saleDisplayItems = [_sale.sdipList mutableCopy];
    GameState *gs = [GameState sharedGameState];
    // If user already owns an item of type ItemTypeGachaMultiSpin and this sales package contains this item, only display it if the quantity is 1, i.e. just bought
    UserItem *ui = [[gs.itemUtil getItemsForType:ItemTypeGachaMultiSpin] firstObject];
    if (ui.quantity > 1) {
      for (SalesDisplayItemProto *sdip in _sale.sdipList)
        if (sdip.reward.typ == RewardProto_RewardTypeItem && [gs itemForId:sdip.reward.staticDataId].itemType == ItemTypeGachaMultiSpin)
          [saleDisplayItems removeObject:sdip];
    }
    _saleDisplayItems = [NSArray arrayWithArray:saleDisplayItems];
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  [self.bonusItemsTable registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellReuseIdentifier:nibName];
  self.bonusItemsTable.superview.layer.cornerRadius = POPUP_CORNER_RADIUS;
  
  self.headerView.layer.cornerRadius = POPUP_CORNER_RADIUS;
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  self.shadowView.layer.shadowOpacity = 0.3;
  self.shadowView.layer.shadowOffset = CGSizeMake(0, 0.5);
  self.shadowView.layer.shadowRadius = 1.5;
}

- (IBAction)closeClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

#pragma mark - Collection View Data Source/Delegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _saleDisplayItems.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  SalePackageCell *cell = [tableView dequeueReusableCellWithIdentifier:nibName forIndexPath:indexPath];
  
  [cell updateForDisplayItem:_saleDisplayItems[indexPath.row] isSpecial:NO];// indexPath.row == 0];
  
  return cell;
}

@end
