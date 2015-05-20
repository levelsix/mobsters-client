//
//  PurchaseHighRollerModeViewController.m
//  Utopia
//
//  Created by Kenneth Cox on 2/11/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "PurchaseHighRollerModeViewController.h"
#import "GameViewController.h"
#import "GameState.h"
#import "Globals.h"
#import "IAPHelper.h"

#define GREEN @"DEFFC2"

@implementation PurchaseHighRollerModeView

- (void) initFonts {
  self.purchaseLabel.gradientStartColor = [UIColor whiteColor];
  self.purchaseLabel.gradientEndColor = [UIColor colorWithHexString:GREEN];
  self.purchaseLabel.strokeSize = 1.f;
  self.purchaseLabel.shadowBlur = .5f;
  
  self.packagesLabel.gradientStartColor = [UIColor whiteColor];
  self.packagesLabel.gradientEndColor = [UIColor colorWithHexString:GREEN];
  self.packagesLabel.strokeSize = 1.f;
  self.packagesLabel.shadowBlur = .5f;
  
  NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.paragraghLabel.text];
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  [paragraphStyle setLineSpacing:1.5f];
  [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.paragraghLabel.text.length)];
}

- (void) updateForPurchaseMode:(BOOL)purchaseMode withHeadline:(NSString *)headline andMessage:(NSString *)message {
  self.titleLabel.text = headline;
  self.paragraghLabel.text = message;
  
  if (purchaseMode) {
    self.packagesView.hidden = YES;
    self.purchaseView.centerX = self.paragraghLabel.centerX;
  } else {
    self.purchaseView.hidden = YES;
    self.packagesView.centerX = self.paragraghLabel.centerX;
  }
}

@end

@implementation PurchaseHighRollerModeViewController

- (instancetype) init {
  if (self = [super init]) {
    _headline = @"Unlock High Roller";
    _message = @"Purchase a Package that includes \"High Roller Mode\" to unlock!";
    _purchaseMode = NO;
    _isLoading = NO;
    
    // If user doesn't own the High Roller mode item
    if ([[GameState sharedGameState].itemUtil getItemsForType:ItemTypeGachaMultiSpin].count == 0) {
      // If a sales package containing the High Roller mode item is not available and a standalone IAP for High Roller mode exists
      if (![[Globals sharedGlobals] highRollerModeSale] && [[Globals sharedGlobals] highRollerModeIapPackage]) {
        _message = [NSString stringWithFormat:@"Purchase \"High Roller Mode\" to spin %d times for a discount!", [Globals sharedGlobals].boosterPackNumberOfPacksGiven];
        _purchaseMode = YES;
      }
    }
    
    self.mainView.alpha = 0.f;
    self.bgView.alpha = 0.f;
  }
  return self;
}

- (void) viewDidLoad {
  PurchaseHighRollerModeView *view = (PurchaseHighRollerModeView *)self.view;
  [view updateForPurchaseMode:_purchaseMode withHeadline:_headline andMessage:_message];
  [view initFonts];
  
  if (_purchaseMode) {
    InAppPurchasePackageProto* iapPackage = [[Globals sharedGlobals] highRollerModeIapPackage];
    if (iapPackage) {
      SKProduct *product = [IAPHelper sharedIAPHelper].products[iapPackage.iapPackageId];
      if (product) {
        _highRollerModeIAP = [InAppPurchaseData createWithProduct:product saleUuid:nil];
        view.purchaseLabel.text = [[IAPHelper sharedIAPHelper] priceForProduct:product];
      }
    }
  }
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgView];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [self.loadingView stop];
  self.loadingView = nil;
}

- (IBAction) clickedPackages:(id)sender {
  [self close];
  
  if (!_purchaseMode) {
    if (self.delegate) {
      [self.delegate toPackagesTapped:YES];
    }
  }
}

- (IBAction) clickedPurchase:(id)sender {
  if (_purchaseMode) {
    if (![self attemptPurchase]) {
      [self close];
    }
  }
}

- (BOOL) attemptPurchase {
  if (_isLoading) {
    return NO;
  }
  
  if (_highRollerModeIAP) {
    self.loadingView = [[NSBundle mainBundle] loadNibNamed:@"LoadingSpinnerView" owner:self options:nil][0];
    [self.loadingView display:self.view];
    
    BOOL success = [_highRollerModeIAP makePurchaseWithDelegate:self];
    if (success) {
      _isLoading = YES;
    }
  }
  
  return _isLoading;
}

- (void) handleInAppPurchaseResponseProto:(FullEvent *)fe {
  [self.loadingView stop];
  self.loadingView = nil;
  
  _isLoading = NO;
  
  [self close];
  
  if (fe) {
    InAppPurchaseResponseProto *proto = (InAppPurchaseResponseProto *)fe.event;
    if (proto.status == InAppPurchaseResponseProto_InAppPurchaseStatusSuccess) {
      if (self.delegate) {
        [self.delegate highRollerModePurchased];
      }
    }
  }
}

- (IBAction) clickedClose:(id)sender {
  [self close];
}

- (void) close {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}
@end
