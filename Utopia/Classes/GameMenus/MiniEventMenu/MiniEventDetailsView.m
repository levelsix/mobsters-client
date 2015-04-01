//
//  MiniEventDetailsView.m
//  Utopia
//
//  Created by Behrouz Namakshenas on 3/24/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "MiniEventDetailsView.h"
#import "MiniEventTierPrizeView.h"
#import "NibUtils.h"
#import "Globals.h"

static const float kTierPointsProgressBarExtendBy = 1.1f;

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
  self.eventInfoName.shadowBlur   = 1.2f;
  
  self.eventInfoDesc.shadowColor  = [UIColor colorWithWhite:.6 alpha:1.f];
  self.eventInfoDesc.shadowOffset = CGSizeMake(0, .5);
  self.eventInfoDesc.shadowBlur   = 1.2f;
  
  self.eventInfoEndsIn.shadowColor  = [UIColor colorWithWhite:.6 alpha:1.f];
  self.eventInfoEndsIn.shadowOffset = CGSizeMake(0, .5);
  self.eventInfoEndsIn.shadowBlur   = 1.2f;
  
  self.eventInfoTimeLeft.shadowColor  = [UIColor colorWithWhite:.25 alpha:1.f];
  self.eventInfoTimeLeft.shadowOffset = CGSizeMake(0, .5);
  self.eventInfoTimeLeft.shadowBlur   = 1.2f;
  
  self.eventInfoEventEnded.shadowColor  = [[UIColor colorWithHexString:@"BAF2FF"] colorWithAlphaComponent:.85f];
  self.eventInfoEventEnded.shadowOffset = CGSizeMake(0, .5);
  self.eventInfoEventEnded.shadowBlur   = 1.2f;
  
  self.eventInfoMyPoints.shadowColor  = [UIColor colorWithWhite:.6 alpha:1.f];
  self.eventInfoMyPoints.shadowOffset = CGSizeMake(0, .5);
  self.eventInfoMyPoints.shadowBlur   = 1.2f;
  
  self.eventInfoPointsEearned.gradientStartColor = [UIColor colorWithHexString:@"CAF45A"];
  self.eventInfoPointsEearned.gradientEndColor   = [UIColor colorWithHexString:@"AEEE3A"];
  self.eventInfoPointsEearned.shadowColor  = [UIColor colorWithWhite:.25 alpha:1.f];
  self.eventInfoPointsEearned.shadowOffset = CGSizeMake(0, 1);
  self.eventInfoPointsEearned.shadowBlur   = 1.2f;
  
  [self.tier1IndicatorLabel sizeToFit];
  [self.tier2IndicatorLabel sizeToFit];
  [self.tier3IndicatorLabel sizeToFit];
  
  self.tier1IndicatorLabel.centerX = self.tier1IndicatorArrow.centerX;
  self.tier2IndicatorLabel.centerX = self.tier2IndicatorArrow.centerX;
  self.tier3IndicatorLabel.centerX = self.tier3IndicatorArrow.centerX;
}

- (void) updateForUserMiniEvent:(UserMiniEvent*)userMiniEvent
{
  MiniEventProto* miniEvent = userMiniEvent.miniEvent;
  
  self.eventInfoName.text = [miniEvent.name uppercaseString];
  self.eventInfoDesc.text = miniEvent.desc;
  
  MSDate* eventEndTime = [MSDate dateWithTimeIntervalSince1970:userMiniEvent.miniEvent.miniEventEndTime / 1000.f];
  MSDate* now = [MSDate date];
  if ([now compare:eventEndTime] != NSOrderedAscending)
  {
    // Event already ended
    self.eventInfoTimerBackground.hidden = YES;
    self.eventInfoTimeLeft.hidden = YES;
    self.eventInfoEventEnded.hidden = NO;
  }
  else
  {
    const NSTimeInterval timeLeft = [eventEndTime timeIntervalSinceDate:now];
    self.eventInfoTimeLeft.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
    
    // TODO - Kick off a timer to update time left
  }
  
  [Globals imageNamed:miniEvent.img withView:self.eventInfoImage greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  
  const int pointsEarned = userMiniEvent.pointsEarned;
  const int maxPoints    = miniEvent.lvlEntered.tierThreeMinPts * kTierPointsProgressBarExtendBy;
  const int tier1Points  = miniEvent.lvlEntered.tierOneMinPts;
  const int tier2Points  = miniEvent.lvlEntered.tierTwoMinPts;
  const int tier3Points  = miniEvent.lvlEntered.tierThreeMinPts;
  
  self.eventInfoPointsEearned.text = [Globals commafyNumber:pointsEarned];
  self.pointCounterLabel.text = [Globals commafyNumber:pointsEarned];
  
  self.tier1IndicatorLabel.text = [NSString stringWithFormat:@"Tier 1 / %@", [Globals commafyNumber:tier1Points]];
  self.tier2IndicatorLabel.text = [NSString stringWithFormat:@"Tier 2 / %@", [Globals commafyNumber:tier2Points]];
  self.tier3IndicatorLabel.text = [NSString stringWithFormat:@"Tier 3 / %@", [Globals commafyNumber:tier3Points]];
  
  const float tier1IndicatorPos = self.pointsProgressBar.originX + self.pointsProgressBar.width * ((float)tier1Points / (float)maxPoints);
  const float tier2IndicatorPos = self.pointsProgressBar.originX + self.pointsProgressBar.width * ((float)tier2Points / (float)maxPoints);
  const float tier3IndicatorPos = self.pointsProgressBar.originX + self.pointsProgressBar.width * ((float)tier3Points / (float)maxPoints);
  
  self.tier1IndicatorLabel.centerX = self.tier1IndicatorArrow.centerX = tier1IndicatorPos;
  self.tier2IndicatorLabel.centerX = self.tier2IndicatorArrow.centerX = tier2IndicatorPos;
  self.tier3IndicatorLabel.centerX = self.tier3IndicatorArrow.centerX = tier3IndicatorPos;
  
  self.pointCounterView.centerX = self.pointsProgressBar.originX + self.pointsProgressBar.width * ((float)pointsEarned / (float)maxPoints);
  
  self.pointsProgressBar.percentage = (float)pointsEarned / (float)maxPoints;
  
  const bool tier1Completed = (pointsEarned >= tier1Points);
  const bool tier2Completed = (pointsEarned >= tier2Points);
  const bool tier3Completed = (pointsEarned >= tier3Points);
  
  _allTiersCompleted = tier1Completed && tier2Completed && tier3Completed;
  
  if (tier1Completed) [self markTierAsComplete:1];
  if (tier2Completed) [self markTierAsComplete:2];
  if (tier3Completed) [self markTierAsComplete:3];
  
  NSArray* allTierPrizes = miniEvent.lvlEntered.rewardsList;
  NSMutableArray* tier1Prizes = [NSMutableArray array];
  NSMutableArray* tier2Prizes = [NSMutableArray array];
  NSMutableArray* tier3Prizes = [NSMutableArray array];
  for (MiniEventTierRewardProto* tierPrize in allTierPrizes)
  {
    switch (tierPrize.tierLvl)
    {
      case 1: [tier1Prizes addObject:tierPrize]; break;
      case 2: [tier2Prizes addObject:tierPrize]; break;
      case 3: [tier3Prizes addObject:tierPrize]; break;
      default: break;
    }
  }
  
  [self.tier1PrizeView updateForTier:1 completed:tier1Completed prizeList:tier1Prizes];
  [self.tier2PrizeView updateForTier:2 completed:tier2Completed prizeList:tier2Prizes];
  [self.tier3PrizeView updateForTier:3 completed:tier3Completed prizeList:tier3Prizes];
  
  if (self.pointCounterView.superview == self)
  {
    // pointCounterView needs to stick out of its container view, but having
    // rounded corners on one of its parents requires clipping to bounds.
    // It will therefore be added to the TouchableSubviewsView as a subview
    UIView* ancestorView = [self getAncestorInViewHierarchyOfType:[TouchableSubviewsView class]];
    const CGPoint newPosition = [ancestorView convertPoint:self.pointCounterView.origin fromView:self];
    [ancestorView addSubview:self.pointCounterView];
    self.pointCounterView.origin = newPosition;
  }
}

- (void) markTierAsComplete:(int)tier
{
  UILabel* tierIndicatorLabel = nil;
  switch (tier)
  {
    case 1: tierIndicatorLabel = self.tier1IndicatorLabel; break;
    case 2: tierIndicatorLabel = self.tier2IndicatorLabel; break;
    case 3: tierIndicatorLabel = self.tier3IndicatorLabel; break;
    default: return;
  }
  
  tierIndicatorLabel.textColor = [UIColor colorWithHexString:@"469D00"];

  UIImageView* tierCheckmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"requirementmet.png"]];
  tierCheckmark.frame = CGRectMake(tierIndicatorLabel.originX - 12, tierIndicatorLabel.centerY - 4, 10, 8);
  [self insertSubview:tierCheckmark belowSubview:tierIndicatorLabel];
  
  if (tier == 3)
  {
    self.pointsProgressBar.percentage = 1.f;
    self.pointCounterView.hidden = YES;
  }
}

- (void) miniEventViewWillAppear
{
  if (!_allTiersCompleted) self.pointCounterView.hidden = NO;
}

- (void) miniEventViewWillDisappear
{
  self.pointCounterView.hidden = YES;
}

@end
