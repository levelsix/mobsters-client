//
//  FundsViews.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/29/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "FundsViews.h"

#import "Globals.h"

@implementation FundsCardCell

- (void) updateForPackageInfo:(id<InAppPurchaseData>)package isLocked:(BOOL)isLocked {
  self.nameLabel.text = package.primaryTitle;
  
  self.resGainedLabel.text = [Globals commafyNumber:package.amountGained];
  self.gemIcon.hidden = package.resourceType != ResourceTypeGems;
  self.cashIcon.hidden = package.resourceType != ResourceTypeCash;
  self.oilIcon.hidden = package.resourceType != ResourceTypeOil;
  [Globals adjustViewForCentering:self.resGainedLabel.superview withLabel:self.resGainedLabel];
  
  if (package.moneyPrice) {
    self.priceMoneyLabel.text = package.moneyPrice;
    
    self.priceMoneyLabel.hidden = NO;
    self.priceGemLabel.superview.hidden = YES;
  } else {
    self.priceGemLabel.text = [Globals commafyNumber:package.gemPrice];
    [Globals adjustViewForCentering:self.priceGemLabel.superview withLabel:self.priceGemLabel];
    
    self.priceMoneyLabel.hidden = YES;
    self.priceGemLabel.superview.hidden = NO;
  }
  
  self.lockedView.hidden = !isLocked;
  self.unlockedView.hidden = isLocked;
  
  [Globals imageNamed:package.rewardPicName withView:self.packageIcon greyscale:isLocked indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
}

@end
