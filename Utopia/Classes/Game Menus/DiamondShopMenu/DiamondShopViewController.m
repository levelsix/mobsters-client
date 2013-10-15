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

@implementation DiamondListing

- (void) updateForPurchaseData:(id<InAppPurchaseData>)product
{
  // Set Free offer title
  self.nameLabel.text = product.primaryTitle;
  
  // Set diamond quantity text
  self.boughtAmountLabel.text = product.secondaryTitle;
  
  self.costLabel.text = product.price;
  
  [Globals imageNamed:product.rewardPicName withView:self.diamondImageView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  self.productData = product;
}

- (UIImageView *) darkOverlay {
  // Can't do this in awakeFromNib because server side image will not be loaded yet.
  if (!_darkOverlay.image) {
    UIImage *darkOverlayImg = [Globals maskImage:_backgroundImage.image withColor:[UIColor colorWithWhite:0.f alpha:0.3f]];
    _darkOverlay.image = darkOverlayImg;
  }
  return _darkOverlay;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  self.darkOverlay.hidden = NO;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint loc = [touch locationInView:self];
  if ([self pointInside:loc withEvent:event]) {
    self.darkOverlay.hidden = NO;
  } else {
    self.darkOverlay.hidden = YES;
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint loc = [touch locationInView:self];
  if ([self pointInside:loc withEvent:event]) {
    self.darkOverlay.hidden = NO;
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    [self.productData makePurchaseWithViewController:(UIViewController *)self.superview.superview.superview];
  }
  self.darkOverlay.hidden = YES;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  self.darkOverlay.hidden = YES;
}

@end

@implementation DiamondListingContainer

- (void) awakeFromNib {
  [super awakeFromNib];
  [[NSBundle mainBundle] loadNibNamed:@"DiamondListing" owner:self options:nil];
  [self addSubview:self.diamondListing];
  [self setBackgroundColor:[UIColor clearColor]];
}

@end

@implementation DiamondListingCell

@end

@implementation DiamondShopViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  //add rope to the very top
  UIColor *c = [UIColor colorWithPatternImage:[Globals imageNamed:@"rope.png"]];
  UIView *leftRope = [[UIView alloc] initWithFrame:CGRectMake(14, -143, 3, 150)];
  UIView *rightRope = [[UIView alloc] initWithFrame:CGRectMake(463, -143, 2, 150)];
  leftRope.backgroundColor = c;
  rightRope.backgroundColor = c;
  [self.diamondTable addSubview:leftRope];
  [self.diamondTable addSubview:rightRope];
  
  self.title = @"Add Funds";
  [self setUpCloseButton];
  [self setUpImageBackButton];
  
}

- (void)viewWillAppear:(BOOL)animated {
  [self updateLabels];
  
  NSString *name = [InAppPurchaseData
                    adTakeoverResignedNotification];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(refreshTableView)
                                               name:name
                                             object:self];
}

- (void)viewWillDisappear:(BOOL)animated {
  
  NSLog(@"%@", NSStringFromCGRect(self.view.frame));
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateLabels {
  GameState *gs = [GameState sharedGameState];
  self.diamondLabel.text = [Globals commafyNumber:gs.gold];
  self.cashLabel.text = [Globals cashStringForNumber:gs.silver];
}

#pragma mark - UITableView delegate methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  Globals *gl = [Globals sharedGlobals];
  return (gl.iapPackages.count-1)/3 + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"DiamondListingCell";
  
  DiamondListingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"DiamondRow" owner:self options:nil];
    cell = self.diamondRow;
  }
  
  Globals *gl = [Globals sharedGlobals];
  GoldSaleProto *sale = nil;//[gs getCurrentDiamondSale];
  NSDictionary *dict = [[IAPHelper sharedIAPHelper] products];
  
  id arr[10] = {sale.package1SaleIdentifier, sale.packageS1SaleIdentifier, sale.package2SaleIdentifier, sale.packageS2SaleIdentifier, sale.package3SaleIdentifier, sale.packageS3SaleIdentifier, sale.package4SaleIdentifier, sale.packageS4SaleIdentifier, sale.package5SaleIdentifier, sale.packageS5SaleIdentifier};
  
  for (int i = 0; i < 3; i++) {
    int base = 3*indexPath.row;
    
    int index = base+i;
    
    int newIndex = index;
    if (newIndex >= gl.iapPackages.count) {
      newIndex = gl.iapPackages.count-1;
    }
    
    NSString *productId = [(InAppPurchasePackageProto *)[gl.iapPackages objectAtIndex:newIndex] iapPackageId];
    NSString *saleProductId = arr[index];
    SKProduct *product = [dict objectForKey:productId];
    SKProduct *saleProduct = [dict objectForKey:saleProductId];
    id <InAppPurchaseData> cellData = [InAppPurchaseData createWithProduct:product saleProduct:saleProduct];
    
    if (i == 0) {
      [cell.listing1.diamondListing updateForPurchaseData:cellData];
    }
    else if (i == 1) {
      if (index < gl.iapPackages.count) {
        cell.listing2.hidden = NO;
        [cell.listing2.diamondListing updateForPurchaseData:cellData];
      } else {
        cell.listing2.hidden = YES;
      }
    }
    else if (i == 2) {
      if (index < gl.iapPackages.count) {
        cell.listing3.hidden = NO;
        [cell.listing3.diamondListing updateForPurchaseData:cellData];
      } else {
        cell.listing3.hidden = YES;
      }
    }
  }
  
  // Hide the bottom ropes if this is the last cell
  UIView *r1 = [cell.contentView viewWithTag:133];
  UIView *r2 = [cell.contentView viewWithTag:134];
  if (indexPath.row == [self tableView:self.diamondTable numberOfRowsInSection:0]-1) {
    r1.hidden = YES;
    r2.hidden = YES;
  } else {
    r1.hidden = NO;
    r2.hidden = NO;
  }
  
  return cell;
}

-(void) refreshTableView
{
  [self.diamondTable reloadData];
}

@end
