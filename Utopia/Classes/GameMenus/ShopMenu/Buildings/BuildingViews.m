//
//  BuildingViews.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/29/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "BuildingViews.h"

#import "Globals.h"

#import "IAPHelper.h"

@implementation BuildingCardCell

- (void) updateForStructInfo:(StructureInfoProto *)structInfo townHall:(UserStruct *)townHall structs:(NSArray *)structs {
  self.moneyTreeView.hidden = YES;
  self.buildingView.hidden = NO;
  
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  [paragraphStyle setLineSpacing:1.8];
  [paragraphStyle setAlignment:NSTextAlignmentCenter];
  
  Globals *gl = [Globals sharedGlobals];
  TownHallProto *thp = (TownHallProto *)townHall.staticStructForCurrentConstructionLevel;
  
  self.nameLabel.text = structInfo.name;
  
  NSShadow *shadow = [[NSShadow alloc] init];
  shadow.shadowColor = self.descriptionLabel.shadowColor;
  shadow.shadowBlurRadius = 0.9;
  shadow.shadowOffset = CGSizeMake(0.0, 1.0);
  self.descriptionLabel.attributedText = [[NSAttributedString alloc] initWithString:structInfo.description attributes:@{NSShadowAttributeName:shadow, NSParagraphStyleAttributeName:paragraphStyle}];
  
  self.costLabel.text = [Globals commafyNumber:structInfo.buildCost];
  [Globals adjustViewForCentering:self.costLabel.superview withLabel:self.costLabel];
  self.cashIcon.hidden = structInfo.buildResourceType != ResourceTypeCash;
  self.oilIcon.hidden = structInfo.buildResourceType != ResourceTypeOil;
  
  self.timeLabel.text = [Globals convertTimeToShortString:structInfo.minutesToBuild*60];
  
  int cur = [gl calculateCurrentQuantityOfStructId:structInfo.structId structs:structs];
  int max = [gl calculateMaxQuantityOfStructId:structInfo.structId withTownHall:thp];
  TownHallProto *nextThp = [gl calculateNextTownHallForQuantityIncreaseForStructId:structInfo.structId];
  self.numOwnedLabel.text = [NSString stringWithFormat:@"Built: %d/%d", cur, max];
  
  BOOL greyscale = NO;
  NSMutableArray *incomplete = [[gl incompletePrereqsForStructId:structInfo.structId] mutableCopy];
  
  // Create a new prereq for th level
  if (cur >= max && nextThp) {
    PrereqProto_Builder *pre = [PrereqProto builder];
    pre.quantity = 1;
    pre.prereqGameType = GameTypeStructure;
    pre.prereqGameEntityId = nextThp.structInfo.structId;
    [incomplete addObject:pre.build];
  }
  
  if (incomplete.count) {
    self.lockedLabel.text = [NSString stringWithFormat:@"Requires %@", [[incomplete firstObject] prereqString]];
    self.lockedLabel.textColor = [UIColor colorWithRed:254/255.f green:2/255.f blue:0.f alpha:1.f];
    greyscale = YES;
  }
  // This means that nextThLevel was not found, meaning that the max number of this structure has already been built
  else if (cur >= max) {
    self.lockedLabel.text = @"Max Number Built";
    self.lockedLabel.textColor = [UIColor colorWithWhite:90/255.f alpha:1.f];
    greyscale = YES;
  }
  
  // Reassign the text with blurred shadow
  shadow = [[NSShadow alloc] init];
  shadow.shadowColor = self.lockedLabel.shadowColor;
  shadow.shadowBlurRadius = 0.9;
  shadow.shadowOffset = CGSizeMake(0.0, 1.0);
  self.lockedLabel.attributedText = [[NSAttributedString alloc] initWithString:self.lockedLabel.text attributes:@{NSShadowAttributeName:shadow, NSParagraphStyleAttributeName:paragraphStyle}];
  
  NSString *fileName = [NSString stringWithFormat:@"Menu%@", structInfo.imgName];
  [Globals imageNamed:fileName withView:self.buildingIcon greyscale:greyscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  self.lockedView.hidden = !greyscale;
  self.unlockedView.hidden = greyscale;
}

- (void) updateForMoneyTree:(MoneyTreeProto *)mtp {
  if (!self.moneyTreeView) {
    self.moneyTreeView = [[NSBundle mainBundle] loadNibNamed:@"BuildingMoneyTreeView" owner:self options:nil][0];
    
    [self.contentView addSubview:self.moneyTreeView];
    
    self.curCostLabel.gradientStartColor = [UIColor colorWithHexString:@"efff00"];
    self.curCostLabel.gradientEndColor = [UIColor colorWithHexString:@"11ff00"];
    
    self.timeLeftLabel.strokeColor = [UIColor colorWithHexString:@"61077b"];
    self.timeLeftLabel.strokeSize = 1.f;
    self.timeLeftLabel.gradientStartColor = [UIColor whiteColor];
    self.timeLeftLabel.gradientEndColor = [UIColor colorWithHexString:@"f9dbff"];
    self.timeLeftLabel.shadowBlur = 0.9f;
  }
  
  self.moneyTreeView.hidden = NO;
  self.buildingView.hidden = YES;
  
  self.producesLabel.text = [NSString stringWithFormat:@"Produces %d", (int)roundf(mtp.productionRate*24)];
  self.daysLabel.text = [NSString stringWithFormat:@"Lasts for %d Days.", mtp.daysOfDuration];
  
  IAPHelper *iap = [IAPHelper sharedIAPHelper];
  SKProduct *prod = [iap productForIdentifier:mtp.iapProductId];
  self.curCostLabel.text = [iap priceForProduct:prod];
  
  prod = [iap productForIdentifier:mtp.fakeIapproductId];
  self.oldCostLabel.text = [iap priceForProduct:prod];
}

- (void) updateTime:(int)secsLeft {
  if (secsLeft >= 0) {
    self.timeLeftLabel.text = [@" " stringByAppendingString:[Globals convertTimeToShortString:secsLeft withAllDenominations:YES].uppercaseString];
    
    //[Globals adjustViewForCentering:self.timeLeftLabel.superview withLabel:self.timeLeftLabel];
  } else if (self.timerIcon) {
    [self.timerIcon removeFromSuperview];
    self.timerIcon = nil;
    
    self.timeLeftLabel.centerX = self.timeLeftLabel.superview.width/2;
    self.timeLeftLabel.originY += 1.f;
    self.timeLeftLabel.textAlignment = NSTextAlignmentCenter;
    
    self.timeLeftLabel.text = @"LIMITED TIME!";
    //self.timeLeftLabel.font = [UIFont fontWithName:self.timeLeftLabel.font.fontName size:self.timeLeftLabel.font.pointSize];
  }
}

@end
