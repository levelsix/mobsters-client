//
//  MiniEventDetailsView.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 3/24/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "MiniEventDetailsView.h"
#import "NibUtils.h"

@implementation MiniEventDetailsView

- (void) awakeFromNib
{
  [super awakeFromNib];
  
  UIImageView* backgroundLeftCap = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eventblueheadercap.png"]];
  {
    backgroundLeftCap.frame = CGRectMake(self.eventInfoBackground.originX - 7, self.eventInfoBackground.originY, 7, self.eventInfoBackground.height);
    [self insertSubview:backgroundLeftCap belowSubview:self.eventInfoBackground];
  }
  UIImageView* backgroundRightCap = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eventblueheadercap.png"]];
  {
    backgroundRightCap.frame = CGRectMake(self.eventInfoBackground.originX + self.eventInfoBackground.width, self.eventInfoBackground.originY, 7, self.eventInfoBackground.height);
    backgroundRightCap.layer.transform = CATransform3DMakeScale(-1, 1, 1);
    [self insertSubview:backgroundRightCap belowSubview:self.eventInfoBackground];
  }
  
  UIImageView* progressBarLeftCap = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eventcounterbgcap.png"]];
  {
    progressBarLeftCap.frame = CGRectMake(self.progressBarBackground.originX - 5, self.progressBarBackground.originY, 5, self.progressBarBackground.height);
    [self insertSubview:progressBarLeftCap belowSubview:self.progressBarBackground];
  }
  UIImageView* progressBarRightCap = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eventcounterbgcap.png"]];
  {
    progressBarRightCap.frame = CGRectMake(self.progressBarBackground.originX + self.progressBarBackground.width, self.progressBarBackground.originY, 5, self.progressBarBackground.height);
    progressBarRightCap.layer.transform = CATransform3DMakeScale(-1, 1, 1);
    [self insertSubview:progressBarRightCap belowSubview:self.progressBarBackground];
  }
  
  self.eventInfoName.gradientStartColor = [UIColor whiteColor];
  self.eventInfoName.gradientEndColor   = [UIColor colorWithHexString:@"DCF8FF"];
  self.eventInfoName.shadowColor  = [UIColor colorWithWhite:.25 alpha:1.f];
  self.eventInfoName.shadowOffset = CGSizeMake(0, 1);
  self.eventInfoName.shadowBlur = 1.2f;
  
  self.eventInfoDesc.shadowColor  = [UIColor colorWithWhite:.6 alpha:1.f];
  self.eventInfoDesc.shadowOffset = CGSizeMake(0, .5);
  self.eventInfoDesc.shadowBlur = 1.2f;
  
  self.eventInfoEndsIn.shadowColor  = [UIColor colorWithWhite:.6 alpha:1.f];
  self.eventInfoEndsIn.shadowOffset = CGSizeMake(0, .5);
  self.eventInfoEndsIn.shadowBlur = 1.2f;
  
  self.eventInfoTimeLeft.shadowColor  = [UIColor colorWithWhite:.25 alpha:1.f];
  self.eventInfoTimeLeft.shadowOffset = CGSizeMake(0, .5);
  self.eventInfoTimeLeft.shadowBlur = 1.2f;
  
  self.eventInfoMyPoints.shadowColor  = [UIColor colorWithWhite:.6 alpha:1.f];
  self.eventInfoMyPoints.shadowOffset = CGSizeMake(0, .5);
  self.eventInfoMyPoints.shadowBlur = 1.2f;
  
  self.eventInfoPointsEearned.gradientStartColor = [UIColor colorWithHexString:@"CAF45A"];
  self.eventInfoPointsEearned.gradientEndColor   = [UIColor colorWithHexString:@"AEEE3A"];
  self.eventInfoPointsEearned.shadowColor  = [UIColor colorWithWhite:.25 alpha:1.f];
  self.eventInfoPointsEearned.shadowOffset = CGSizeMake(0, 1);
  self.eventInfoPointsEearned.shadowBlur = 1.2f;
  
  [self.tier1IndicatorLabel sizeToFit];
  [self.tier2IndicatorLabel sizeToFit];
  [self.tier3IndicatorLabel sizeToFit];
  
  self.tier1IndicatorLabel.centerX = self.tier1IndicatorArrow.centerX;
  self.tier2IndicatorLabel.centerX = self.tier2IndicatorArrow.centerX;
  self.tier3IndicatorLabel.centerX = self.tier3IndicatorArrow.centerX;
  
  self.tier1IndicatorLabel.textColor = [UIColor colorWithHexString:@"469D00"];
  {
    UIImageView* tierCheckmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"requirementmet.png"]];
    tierCheckmark.frame = CGRectMake(self.tier1IndicatorLabel.originX - 12, self.tier1IndicatorLabel.centerY - 3, 10, 8);
    [self insertSubview:tierCheckmark belowSubview:self.tier1IndicatorLabel];
  }
}

- (void) updateForMiniEvent
{
  [self.pointsProgressBar setPercentage:.45f];
}

@end
