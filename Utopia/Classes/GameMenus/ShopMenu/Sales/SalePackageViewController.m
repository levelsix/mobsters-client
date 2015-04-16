//
//  SalePackageViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/14/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SalePackageViewController.h"

#import "GameState.h"
#import "Globals.h"
#import "IAPHelper.h"
#import "InAppPurchaseData.h"

@implementation SalePackageCell

- (void) updateForDisplayItem:(SalesDisplayItemProto *)display isSpecial:(BOOL)isSpecial {
  GameState *gs = [GameState sharedGameState];
  NSString *imgName = nil;
  RewardProto *reward = display.reward;
  
  if (reward.typ == RewardProto_RewardTypeGems) {
    self.nameLabel.text = [NSString stringWithFormat:@"%@ Gems", [Globals commafyNumber:reward.amt]];
    self.quantityLabel.text = [NSString stringWithFormat:@"x1"];
    imgName = @"diamond.png";
  } else if (reward.typ == RewardProto_RewardTypeItem) {
    ItemProto *ip = [gs itemForId:reward.staticDataId];
    self.nameLabel.text = ip.name;
    self.quantityLabel.text = [NSString stringWithFormat:@"x%d", reward.amt];
    imgName = ip.imgName;
  }
  
  [Globals imageNamed:imgName withView:self.itemIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  
  CGSize size = self.itemIcon.image.size;
  if (self.itemIcon.width < size.width || self.itemIcon.height < size.height) {
    self.itemIcon.contentMode = UIViewContentModeScaleAspectFit;
  } else {
    self.itemIcon.contentMode = UIViewContentModeCenter;
  }
  
  if (isSpecial) {
    self.nameLabel.font = [UIFont fontWithName:@"Gotham-Ultra" size:self.nameLabel.font.pointSize];
    self.quantityLabel.font = [UIFont fontWithName:@"Gotham-Ultra" size:self.quantityLabel.font.pointSize];
    
    self.nameLabel.text = [self.nameLabel.text uppercaseString];
    
    self.cellBgd.hidden = NO;
  } else {
    self.nameLabel.font = [UIFont fontWithName:@"Gotham-Bold" size:self.nameLabel.font.pointSize];
    self.quantityLabel.font = [UIFont fontWithName:@"Gotham-Bold" size:self.quantityLabel.font.pointSize];
    
    self.cellBgd.hidden = YES;
  }
}

@end

@implementation SalePackageViewController

static NSString *nibName = @"SalePackageCell";

- (id) initWithSalePackageProto:(SalesPackageProto *)spp {
  if ((self = [super init])) {
    _sale = spp;
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  // Have to set it to red in nib so we can see it.
  self.view.backgroundColor = [UIColor clearColor];
  
  self.timeLeftLabel.gradientStartColor = [UIColor whiteColor];
  self.timeLeftLabel.gradientEndColor = [UIColor colorWithHexString:@"ffd8cc"];
  //  self.timeLeftLabel.shadowColor = [UIColor colorWithHexString:@"aa6b00c0"];
  self.timeLeftLabel.shadowBlur = 0.9f;
  
  self.endsInLabel.gradientStartColor = self.timeLeftLabel.gradientStartColor;
  self.endsInLabel.gradientEndColor = self.timeLeftLabel.gradientEndColor;
  self.endsInLabel.shadowColor = self.timeLeftLabel.shadowColor;
  self.endsInLabel.shadowBlur = self.timeLeftLabel.shadowBlur;
  
  self.priceLabel.strokeColor = [UIColor colorWithHexString:@"2a7204"];
  self.priceLabel.strokeSize = 1.f;
  self.priceLabel.gradientStartColor = [UIColor whiteColor];
  self.priceLabel.gradientEndColor = [UIColor colorWithHexString:@"e2ffcb"];
  self.priceLabel.shadowColor = nil;
  
  IAPHelper *iap = [IAPHelper sharedIAPHelper];
  SKProduct *prod = [iap productForIdentifier:_sale.salesProductId];
  self.priceLabel.text = [[IAPHelper sharedIAPHelper] priceForProduct:prod];
  _product = prod;
  
  [self.bonusItemsTable registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellReuseIdentifier:nibName];
  
  self.numItemsLabel.text = [NSString stringWithFormat:@"INCLUDES THESE %d ITEMS!", (int)_sale.sdipList.count];
  
  self.bonusItemsTable.superview.layer.cornerRadius = 5.f;
  //  self.bonusItemsCollectionView.superview.height += 0.5f;
  //  self.bonusItemsCollectionView.superview.width += 0.5f;
  
  [self loadCustomMenuProto:_sale.cmpList];
}

- (void) loadCustomMenuProto:(NSArray *)cmps {
  NSMutableArray *arr = [NSMutableArray array];
  for (CustomMenuProto *cmp in cmps) {
    [arr addObject:cmp.imageName];
  }
  
  cmps = [cmps sortedArrayUsingComparator:^NSComparisonResult(CustomMenuProto *obj1, CustomMenuProto *obj2) {
    return [@(obj1.positionZ) compare:@(obj2.positionZ)];
  }];
  
  BOOL success = [Globals checkAndLoadFiles:arr completion:^(BOOL success) {
    if (success) {
      for (int i = 0; i < cmps.count; i++) {
        CustomMenuProto *cmp = cmps[i];
        
        UIImageView *img = [[UIImageView alloc] initWithImage:[Globals imageNamed:cmp.imageName]];
        img.originX = cmp.positionX+self.infoView.originX;
        img.originY = cmp.positionY+self.infoView.originY;
        
        if (cmp.positionZ < 0) {
          [self.containerView insertSubview:img belowSubview:self.infoView];
        } else {
          [self.containerView insertSubview:img aboveSubview:self.infoView];
        }
        
        if (cmp.isJiggle) {
          [self jiggleBadge:img];
        }
        
        // Popup shadow view
        // Assume the bottom most view is a bgd
        if (i == 0) {
          img.layer.cornerRadius = 5.f;
          img.clipsToBounds = YES;
        }
      }
      
      // Create darkened view
      
      UIImage *img = [Globals maskImage:[Globals snapShotView:self.containerView] withColor:DARKEN_VIEW_COLOR];
      UIView *v = [[UIImageView alloc] initWithImage:img];
      v.tag = DARKEN_VIEW_TAG;
      [self.containerView addSubview:v];
    }
    
    [self.loadingView removeFromSuperview];
    self.loadingView = nil;
    
    self.containerView.hidden = NO;
  }];
  
  if (!success) {
    self.loadingView = [[NSBundle mainBundle] loadNibNamed:@"SalePackageLoadingView" owner:self options:nil][0];
    [self.view addSubview:self.loadingView];
    self.containerView.hidden = YES;
  }
}

static float rotationAmt = M_PI/15;
static float timePerRotation = 0.08;

- (void) jiggleBadge:(UIView *)v {
  v.layer.transform = CATransform3DIdentity;
  
  // Pause for 0.5 after first wiggle, 2.f for second wiggle, then repeat
  [UIView animateWithDuration:timePerRotation/2 delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
    v.layer.transform = CATransform3DMakeRotation(-rotationAmt, 0, 0, 1);
  } completion:^(BOOL finished) {
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    // Divide by 2 to account for autoreversing
    int repeatCt = 3;
    [animation setDuration:timePerRotation];
    [animation setRepeatCount:repeatCt];
    [animation setAutoreverses:YES];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFromValue:[NSNumber numberWithFloat:-rotationAmt]];
    [animation setToValue:[NSNumber numberWithFloat:rotationAmt]];
    [animation setDelegate:self];
    //[animation setBeginTime:CACurrentMediaTime()+4.f];
    [v.layer addAnimation:animation forKey:@"rotation"];
    
    [self performSelector:@selector(jiggleBadge:) withObject:v afterDelay:3.f];
  }];
}

- (void) updateLabels {
  GameState *gs = [GameState sharedGameState];
  
  int secsLeft;
  
  if (_sale.hasTimeEnd) {
    MSDate *endDate = [MSDate dateWithTimeIntervalSince1970:_sale.timeEnd/1000.];
    secsLeft = [endDate timeIntervalSinceNow];
    
    int mod = 60*60*24;
    secsLeft = (secsLeft % mod);
  } else {
    secsLeft = [gs timeLeftOnStarterSale];
  }
  
  if (secsLeft >= 0) {
    self.timeLeftLabel.text = [@" " stringByAppendingString:[Globals convertTimeToShortString:secsLeft withAllDenominations:YES].uppercaseString];
  } else if (self.timerIcon) {
    [self.timerIcon removeFromSuperview];
    self.timerIcon = nil;
    
    [self.endsInLabel removeFromSuperview];
    self.endsInLabel = nil;
    
    self.timeLeftLabel.centerX = self.timeLeftLabel.superview.width/2;
    self.timeLeftLabel.originY += 1.f;
    self.timeLeftLabel.textAlignment = NSTextAlignmentCenter;
    
    self.timeLeftLabel.text = @"LIMITED TIME!";
    self.timeLeftLabel.font = [UIFont fontWithName:self.timeLeftLabel.font.fontName size:self.timeLeftLabel.font.pointSize+3];
  }
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

- (IBAction) purchaseClicked:(id)sender {
  InAppPurchaseData *data = [InAppPurchaseData createWithProduct:_product saleUuid:_sale.uuid];
  [self.delegate iapClicked:data];
}

@end
