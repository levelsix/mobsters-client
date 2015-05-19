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
  Reward *reward = [[Reward alloc] initWithReward:display.reward];
  
  NSString *imgName = [reward imgName];
  NSString *quantityStr = [NSString stringWithFormat:@"x%d", [reward quantity]];
  NSString *name = [reward name];
  
  self.nameLabel.text = name;
  self.quantityLabel.text = quantityStr;
  
  [Globals imageNamed:imgName withView:self.itemIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  
  CGSize size = self.itemIcon.image.size;
  if (!self.itemIcon.image || self.itemIcon.width < size.width || self.itemIcon.height < size.height) {
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
    
    NSMutableArray *saleDisplayItems = [_sale.sdipList mutableCopy];
    GameState *gs = [GameState sharedGameState];
    // If user already owns an item of type ItemTypeGachaMultiSpin and
    // this sales package contains this item, do not display it
    if ([gs.itemUtil getItemsForType:ItemTypeGachaMultiSpin].count > 0) {
      for (SalesDisplayItemProto *sdip in saleDisplayItems)
        if (sdip.reward.typ == RewardProto_RewardTypeItem && [gs itemForId:sdip.reward.staticDataId].itemType == ItemTypeGachaMultiSpin)
          [saleDisplayItems removeObject:sdip];
    }
    _saleDisplayItems = [NSArray arrayWithArray:saleDisplayItems];
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
  
#ifndef APPSTORE
  NSString *debugStr = [NSString stringWithFormat:@"#%d: ", _sale.salesPackageId];
#else
  NSString *debugStr = @"";
#endif
  self.numItemsLabel.text = [NSString stringWithFormat:@"%@INCLUDES THESE %d ITEMS!", debugStr, (int)_saleDisplayItems.count];
  
  if (_sale.titleColor.length > 0) {
    self.numItemsLabel.textColor = [UIColor colorWithHexString:_sale.titleColor];
  }
  
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
    int posZ1 = obj1.positionZ;
    int posZ2 = obj2.positionZ;
    
    // negative numbers need to go in ascending order, positive numbers in decending. i.e. -3 -2 -1 1 2 3 would become -3 -2 -1 3 2 1
    if (posZ1 > 0 && posZ2 > 0) {
      return [@(obj2.positionZ) compare:@(obj1.positionZ)];
    }
    return [@(obj1.positionZ) compare:@(obj2.positionZ)];
  }];
  
  BOOL success = [Globals checkAndLoadFiles:arr completion:^(BOOL success) {
    [self.loadingView removeFromSuperview];
    self.loadingView = nil;
    
    self.containerView.hidden = NO;
    
    if (success) {
      for (int i = 0; i < cmps.count; i++) {
        CustomMenuProto *cmp = cmps[i];
        
        UIImageView *img = [[UIImageView alloc] initWithImage:[Globals imageNamed:cmp.imageName]];
        img.originX = cmp.positionX+self.infoView.originX;
        img.originY = cmp.positionY+self.infoView.originY;
        img.tag = cmp.positionZ;
        
        if (cmp.positionZ < 0) {
          [self.containerView insertSubview:img belowSubview:self.infoView];
        } else {
          [self.containerView insertSubview:img aboveSubview:self.infoView];
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
      v.alpha = 0.f;
      [self.containerView addSubview:v];
    }
  }];
  
  if (!success) {
    self.loadingView = [[NSBundle mainBundle] loadNibNamed:@"SalePackageLoadingView" owner:self options:nil][0];
    [self.view addSubview:self.loadingView];
    self.containerView.hidden = YES;
  }
}

- (void) stopAllJiggling {
  if (_jiggleOn) {
    for (CustomMenuProto *cmp in _sale.cmpList) {
      if (cmp.isJiggle) {
        UIView *v = [self.containerView viewWithTag:cmp.positionZ];
        [v.layer removeAllAnimations];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(jiggleBadge:) object:v];
      }
    }
    
    _jiggleOn = NO;
  }
}

- (void) startAllJiggling {
  if (!_jiggleOn) {
    for (CustomMenuProto *cmp in _sale.cmpList) {
      if (cmp.isJiggle) {
        [self jiggleBadge:[self.containerView viewWithTag:cmp.positionZ]];
      }
    }
    
    _jiggleOn = YES;
  }
}

static float rotationAmt = M_PI/15;
static float timePerRotation = 0.08;

- (void) jiggleBadge:(UIView *)v {
  // Pause for 0.5 after first wiggle, 2.f for second wiggle, then repeat
  [UIView animateWithDuration:timePerRotation/2 delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
    v.layer.transform = CATransform3DMakeRotation(-rotationAmt, 0, 0, 1);
  } completion:^(BOOL finished) {
    if (finished) {
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
      [animation setValue:v forKey:@"JiggleView"];
      //[animation setBeginTime:CACurrentMediaTime()+4.f];
      [v.layer addAnimation:animation forKey:@"rotation"];
    } else {
      v.layer.transform = CATransform3DIdentity;
    }
  }];
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
  UIView *v = [anim valueForKey:@"JiggleView"];
  if (flag) {
    [UIView animateWithDuration:timePerRotation/2 delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
      v.layer.transform = CATransform3DIdentity;
    } completion:^(BOOL finished) {
      [self performSelector:@selector(jiggleBadge:) withObject:v afterDelay:3.f];
    }];
  } else {
    v.layer.transform = CATransform3DIdentity;
  }
}

- (void) updateLabels {
  GameState *gs = [GameState sharedGameState];
  
  int secsLeft = [gs timeLeftOnSale:_sale];
  
  if (secsLeft >= 0) {
    self.timeLeftLabel.text = [@" " stringByAppendingString:[Globals convertTimeToShortString:secsLeft withAllDenominations:YES].uppercaseString];
  } else if (self.timerIcon) {
    [self.timerIcon removeFromSuperview];
    self.timerIcon = nil;
    
    [self.endsInLabel removeFromSuperview];
    self.endsInLabel = nil;
    
    self.timeLeftLabel.centerX = self.timeLeftLabel.superview.width/2;
    self.timeLeftLabel.textAlignment = NSTextAlignmentCenter;
    
    self.timeLeftLabel.text = @"LIMITED TIME!";
  }
}

#pragma mark - Collection View Data Source/Delegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _saleDisplayItems.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  SalePackageCell *cell = [tableView dequeueReusableCellWithIdentifier:nibName forIndexPath:indexPath];
  
  [cell updateForDisplayItem:_saleDisplayItems[indexPath.row] isSpecial:indexPath.row == 0];
  
  return cell;
}

- (IBAction) purchaseClicked:(id)sender {
  InAppPurchaseData *data = [InAppPurchaseData createWithProduct:_product saleUuid:_sale.uuid];
  [self.delegate iapClicked:data];
}

@end
