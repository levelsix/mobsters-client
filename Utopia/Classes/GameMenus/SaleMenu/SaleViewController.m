//
//  SaleViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/9/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SaleViewController.h"

#import "Globals.h"
#import "GameState.h"

#import "IAPHelper.h"

@implementation SaleViewCell

- (void) updateForDisplayItem:(BoosterDisplayItemProto *)display {
  GameState *gs = [GameState sharedGameState];
  NSString *imgName = nil;
  if (display.gemReward) {
    self.nameLabel.text = [NSString stringWithFormat:@"%@ Gems", [Globals commafyNumber:display.gemReward]];
    self.quantityLabel.text = [NSString stringWithFormat:@"x1"];
    imgName = @"diamond.png";
  } else if (display.itemId && display.itemQuantity) {
    ItemProto *ip = [gs itemForId:display.itemId];
    self.nameLabel.text = ip.name;
    self.quantityLabel.text = [NSString stringWithFormat:@"x%d", display.itemQuantity];
    imgName = ip.imgName;
  }
  
  [Globals imageNamed:imgName withView:self.itemIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  
  CGSize size = self.itemIcon.image.size;
  if (self.itemIcon.width < size.width || self.itemIcon.height < size.height) {
    self.itemIcon.contentMode = UIViewContentModeScaleAspectFit;
  } else {
    self.itemIcon.contentMode = UIViewContentModeCenter;
  }
}

@end

@interface SaleViewController ()

@end

@implementation SaleViewController

static NSString *nibName = @"SaleViewCell";

- (id) initWithSale:(BoosterPackProto *)sale product:(SKProduct *)product {
  if ((self = [super init])) {
    self.sale = sale;
    self.product = product;
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  self.timeLeftLabel.strokeColor = [UIColor colorWithHexString:@"c54a00"];
  self.timeLeftLabel.strokeSize = 1.f;
  self.timeLeftLabel.gradientStartColor = [UIColor whiteColor];
  self.timeLeftLabel.gradientEndColor = [UIColor colorWithHexString:@"ffe5ba"];
//  self.timeLeftLabel.shadowColor = [UIColor colorWithHexString:@"aa6b00c0"];
  self.timeLeftLabel.shadowBlur = 0.9f;
  
  self.endsInLabel.strokeColor = self.timeLeftLabel.strokeColor;
  self.endsInLabel.strokeSize = self.timeLeftLabel.strokeSize;
  self.endsInLabel.gradientStartColor = self.timeLeftLabel.gradientStartColor;
  self.endsInLabel.gradientEndColor = self.timeLeftLabel.gradientEndColor;
  self.endsInLabel.shadowColor = self.timeLeftLabel.shadowColor;
  self.endsInLabel.shadowBlur = self.timeLeftLabel.shadowBlur;
  
  self.priceLabel.strokeColor = [UIColor colorWithHexString:@"2a7204"];
  self.priceLabel.strokeSize = 1.f;
  self.priceLabel.gradientStartColor = [UIColor whiteColor];
  self.priceLabel.gradientEndColor = [UIColor colorWithHexString:@"e2ffcb"];
  self.priceLabel.shadowColor = nil;
  
  self.priceLabel.text = [[IAPHelper sharedIAPHelper] priceForProduct:self.product];
  
  [self.bonusItemsCollectionView registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellWithReuseIdentifier:nibName];
  
  self.numItemsLabel.text = [NSString stringWithFormat:@"INCLUDES THESE %d ITEMS!", (int)self.sale.displayItemsList.count];
  
  self.bonusItemsCollectionView.superview.layer.cornerRadius = 5.f;
  self.bonusItemsCollectionView.superview.height += 0.5f;
  self.bonusItemsCollectionView.superview.originX -= 0.5f;
}

- (void) fadeLitBgd {
  // flash in fast, fade out slow
  self.litBgdView.alpha = 0.f;
  [UIView animateWithDuration:.2f animations:^{
    self.litBgdView.alpha = 1.f;
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:1.8f animations:^{
      self.litBgdView.alpha = 0.f;
    } completion:^(BOOL finished) {
      [self fadeLitBgd];
    }];
  }];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.updateTimer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
  [self updateLabels];
  
  [self fadeLitBgd];
  
  [[CCDirector sharedDirector] pause];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [self.updateTimer invalidate];
  self.updateTimer = nil;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  [[CCDirector sharedDirector] resume];
}

- (void) updateLabels {
  GameState *gs = [GameState sharedGameState];
  
  int secsLeft = gs.timeLeftOnStarterSale;
  
  if (secsLeft >= 0) {
    self.timeLeftLabel.text = [@" " stringByAppendingString:[Globals convertTimeToShortString:secsLeft withAllDenominations:YES].uppercaseString];
    
    //[Globals adjustViewForCentering:self.timeLeftLabel.superview withLabel:self.timeLeftLabel];
  } else if (self.timerIcon) {
    [self.timerIcon removeFromSuperview];
    self.timerIcon = nil;
    
    [self.endsInLabel removeFromSuperview];
    self.endsInLabel = nil;
    
    self.timeLeftLabel.centerX = self.timeLeftLabel.superview.width/2;
    self.timeLeftLabel.textAlignment = NSTextAlignmentCenter;
    
    self.timeLeftLabel.text = @"Limited Time!";
  }
}

- (IBAction)buyClicked:(id)sender {
  [self.loadingView display:self.view];
  [[IAPHelper sharedIAPHelper] buyProductIdentifier:self.product withDelegate:self];
}

- (void) handleInAppPurchaseResponseProto:(FullEvent *)fe {
  [self.loadingView stop];
  
  InAppPurchaseResponseProto *proto = (InAppPurchaseResponseProto *)fe.event;
  if (proto.status == InAppPurchaseResponseProto_InAppPurchaseStatusSuccess) {
    [self closeClicked:nil];
  }
}

- (IBAction)closeClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

#pragma mark - Collection View Data Source/Delegate

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.sale.displayItemsList.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  SaleViewCell *cell = [self.bonusItemsCollectionView dequeueReusableCellWithReuseIdentifier:nibName forIndexPath:indexPath];
  
  [cell updateForDisplayItem:self.sale.displayItemsList[indexPath.row]];
  
  return cell;
}

@end
