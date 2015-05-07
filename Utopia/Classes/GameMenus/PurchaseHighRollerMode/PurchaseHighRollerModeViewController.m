//
//  PurchaseHighRollerModeViewController.m
//  Utopia
//
//  Created by Kenneth Cox on 2/11/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "PurchaseHighRollerModeViewController.h"
#import "Globals.h"

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
  
  self.purchaseView.hidden = YES;
  self.packagesView.centerX = self.paragraghLabel.centerX;
}

- (void) updateWithHeadline:(NSString *) headline andMessage:(NSString *) message {
  self.titleLabel.text = headline;
  self.paragraghLabel.text = message;
}

@end

@implementation PurchaseHighRollerModeViewController

- (id) initWithHeadline:(NSString *) headline andMessage:(NSString *) message {
  if ((self = [super init])) {
    _headline = headline;
    _message = message;
    
    self.mainView.alpha = 0.f;
    self.bgView.alpha = 0.f;
  }
  return self;
}

- (void) viewDidLoad {
  PurchaseHighRollerModeView *view = (PurchaseHighRollerModeView *)self.view;
  [view updateWithHeadline:_headline andMessage:_message];
  [view initFonts];
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgView];
}

- (IBAction) clickedPackages:(id)sender {
  [self close];
  
  if (self.delegate) {
    [self.delegate toPackagesTapped];
  }
}

- (IBAction) clickedPurchase:(id)sender {
  [self close];
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
