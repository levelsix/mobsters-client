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
static const float kTierPointsProgressBarUpdateAnimationDuration = .5f;
static const float kTier1FixedDisplayPercentage = 1.f / 3.f;
static const float kTier2FixedDisplayPercentage = 2.f / 3.f;
static const float kTier3FixedDisplayPercentage = 1.f;
static const float kCollectRewardViewSlideAnimationDuration = .5f;

@implementation MiniEventDetailsView

- (void) awakeFromNib
{
  [super awakeFromNib];
  
  UIImageView* backgroundLeftCap = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eventblueheadercap.png"]];
  {
    backgroundLeftCap.frame = CGRectMake(self.eventInfoBackground.originX - 7, self.eventInfoBackground.originY, 7, self.eventInfoBackground.height);
    [self.eventInfoView insertSubview:backgroundLeftCap belowSubview:self.eventInfoBackground];
  }
  UIImageView* backgroundRightCap = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eventblueheadercap.png"]];
  {
    backgroundRightCap.frame = CGRectMake(self.eventInfoBackground.originX + self.eventInfoBackground.width, self.eventInfoBackground.originY, 7, self.eventInfoBackground.height);
    backgroundRightCap.layer.transform = CATransform3DMakeScale(-1, 1, 1);
    [self.eventInfoView insertSubview:backgroundRightCap belowSubview:self.eventInfoBackground];
  }
  
  UIImageView* progressBarLeftCap = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eventcounterbgcap.png"]];
  {
    progressBarLeftCap.frame = CGRectMake(self.progressBarBackground.originX - 5, self.progressBarBackground.originY, 5, self.progressBarBackground.height);
    [self.eventInfoView insertSubview:progressBarLeftCap belowSubview:self.progressBarBackground];
  }
  UIImageView* progressBarRightCap = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eventcounterbgcap.png"]];
  {
    progressBarRightCap.frame = CGRectMake(self.progressBarBackground.originX + self.progressBarBackground.width, self.progressBarBackground.originY, 5, self.progressBarBackground.height);
    progressBarRightCap.layer.transform = CATransform3DMakeScale(-1, 1, 1);
    [self.eventInfoView insertSubview:progressBarRightCap belowSubview:self.progressBarBackground];
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
  
  self.collectRewardView = nil;
}

- (void) dealloc
{
  [self.collectRewardView setDelegate:nil];
}

- (void) initializeWithUserMiniEvent:(UserMiniEvent*)userMiniEvent
{
  MiniEventProto* miniEvent = userMiniEvent.miniEvent;
  
  self.eventInfoName.text = [miniEvent.name uppercaseString];
  self.eventInfoDesc.text = miniEvent.desc;
  
  [self updateTimeLeftForEvent:userMiniEvent];
  
  [Globals imageNamed:miniEvent.img withView:self.eventInfoImage greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  
  const int pointsEarned = userMiniEvent.pointsEarned;
//const int maxPoints    = miniEvent.lvlEntered.tierThreeMinPts * kTierPointsProgressBarExtendBy;
  const int tier1Points  = miniEvent.lvlEntered.tierOneMinPts;
  const int tier2Points  = miniEvent.lvlEntered.tierTwoMinPts;
  const int tier3Points  = miniEvent.lvlEntered.tierThreeMinPts;
  
  self.eventInfoPointsEearned.text = [Globals commafyNumber:pointsEarned];
  self.pointCounterLabel.text = [Globals commafyNumber:pointsEarned];
  
  self.tier1IndicatorLabel.text = [NSString stringWithFormat:@"Tier 1 / %@", [Globals commafyNumber:tier1Points]];
  self.tier2IndicatorLabel.text = [NSString stringWithFormat:@"Tier 2 / %@", [Globals commafyNumber:tier2Points]];
  self.tier3IndicatorLabel.text = [NSString stringWithFormat:@"Tier 3 / %@", [Globals commafyNumber:tier3Points]];
  
  [self.tier1IndicatorLabel sizeToFit];
  [self.tier2IndicatorLabel sizeToFit];
  [self.tier3IndicatorLabel sizeToFit];
  
  /*
   * 4/21/15 - BN - Tier indicators are displayed at fixed positions,
   * hence the progress from one tier to the next will be non-linear
   *
  const float tier1IndicatorPos = self.pointsProgressBar.originX + self.pointsProgressBar.width * ((float)tier1Points / (float)maxPoints);
  const float tier2IndicatorPos = self.pointsProgressBar.originX + self.pointsProgressBar.width * ((float)tier2Points / (float)maxPoints);
  const float tier3IndicatorPos = self.pointsProgressBar.originX + self.pointsProgressBar.width * ((float)tier3Points / (float)maxPoints);
   */
  
  const float tier1IndicatorPos = self.pointsProgressBar.originX + self.pointsProgressBar.width * (kTier1FixedDisplayPercentage / kTierPointsProgressBarExtendBy);
  const float tier2IndicatorPos = self.pointsProgressBar.originX + self.pointsProgressBar.width * (kTier2FixedDisplayPercentage / kTierPointsProgressBarExtendBy);
  const float tier3IndicatorPos = self.pointsProgressBar.originX + self.pointsProgressBar.width * (kTier3FixedDisplayPercentage / kTierPointsProgressBarExtendBy);
  
  self.tier1IndicatorLabel.centerX = self.tier1IndicatorArrow.centerX = tier1IndicatorPos;
  self.tier2IndicatorLabel.centerX = self.tier2IndicatorArrow.centerX = tier2IndicatorPos;
  self.tier3IndicatorLabel.centerX = self.tier3IndicatorArrow.centerX = tier3IndicatorPos;
  
  _tier1Completed = (pointsEarned >= tier1Points);
  _tier2Completed = (pointsEarned >= tier2Points);
  _tier3Completed = (pointsEarned >= tier3Points);
  
  if (_tier1Completed) [self markTierAsComplete:1];
  if (_tier2Completed) [self markTierAsComplete:2];
  if (_tier3Completed) [self markTierAsComplete:3];
  
  if (_tier3Completed)
  {
    self.pointsProgressBar.percentage = 1.f;
    self.pointCounterView.hidden = YES;
  }
  else
  {
    /*
    self.pointsProgressBar.percentage = (float)pointsEarned / (float)maxPoints;
    self.pointCounterView.centerX = self.pointsProgressBar.originX + self.pointsProgressBar.width * ((float)pointsEarned / (float)maxPoints);
     */
    
    const float nonLinearPercentage = [self nonLinearPercentageForPointsEarned:pointsEarned tier1Points:tier1Points tier2Points:tier2Points tier3Points:tier3Points];
    
    self.pointsProgressBar.percentage = nonLinearPercentage;
    self.pointCounterView.centerX = self.pointsProgressBar.originX + self.pointsProgressBar.width * nonLinearPercentage;
  }
  
  _tierPrizes = [NSMutableArray arrayWithObjects:[NSMutableArray array], [NSMutableArray array], [NSMutableArray array], nil];
  for (MiniEventTierRewardProto* tierPrize in miniEvent.lvlEntered.rewardsList)
    [_tierPrizes[tierPrize.tierLvl - 1] addObject:tierPrize];
  
  [self.tier1PrizeView updateForTier:1 prizeList:_tierPrizes[0]];
  [self.tier2PrizeView updateForTier:2 prizeList:_tierPrizes[1]];
  [self.tier3PrizeView updateForTier:3 prizeList:_tierPrizes[2]];
  
  _tier1Redeemed = userMiniEvent.tierOneRedeemed;
  _tier2Redeemed = userMiniEvent.tierTwoRedeemed;
  _tier3Redeemed = userMiniEvent.tierThreeRedeemed;
  
  int lowestTierWithUnredeemedReward = 0;
  if      (_tier1Completed && !_tier1Redeemed) lowestTierWithUnredeemedReward = 1;
  else if (_tier2Completed && !_tier2Redeemed) lowestTierWithUnredeemedReward = 2;
  else if (_tier3Completed && !_tier3Redeemed) lowestTierWithUnredeemedReward = 3;
  
  if (lowestTierWithUnredeemedReward > 0)
  {
    [self displayCollectRewardViewForTier:lowestTierWithUnredeemedReward prizeList:_tierPrizes[lowestTierWithUnredeemedReward - 1] animate:NO];
  }
  
  // pointCounterView needs to stick out of its container view, but having
  // rounded corners on one of its parents requires clipping to bounds.
  // It will therefore be added to the TouchableSubviewsView as a subview
  UIView* ancestorView = [self getAncestorInViewHierarchyOfType:[TouchableSubviewsView class]];
  const CGPoint newPosition = [ancestorView convertPoint:self.pointCounterView.origin fromView:self.eventInfoView];
  [ancestorView addSubview:self.pointCounterView];
  self.pointCounterView.origin = newPosition;
}

- (float) nonLinearPercentageForPointsEarned:(int)pointsEarned tier1Points:(int)tier1Points tier2Points:(int)tier2Points tier3Points:(int)tier3Points
{
  // Tier indicators are displayed at fixed positions, hence
  // the progress from one tier to the next will be non-linear
  
  float nonLinearPercentage = 0.f;
  
  if (pointsEarned < tier1Points)
  {
    const float p = (float)pointsEarned / (float)tier1Points;
    nonLinearPercentage = p * kTier1FixedDisplayPercentage;
  }
  else if (pointsEarned < tier2Points)
  {
    const float p = (float)(pointsEarned - tier1Points) / (float)(tier2Points - tier1Points);
    nonLinearPercentage = kTier1FixedDisplayPercentage + p * (kTier2FixedDisplayPercentage - kTier1FixedDisplayPercentage);
  }
  else if (pointsEarned < tier3Points)
  {
    const float p = (float)(pointsEarned - tier2Points) / (float)(tier3Points - tier2Points);
    nonLinearPercentage = kTier2FixedDisplayPercentage + p * (kTier3FixedDisplayPercentage - kTier2FixedDisplayPercentage);
  }
  else
  {
    nonLinearPercentage = 1.f;
  }
  
  return nonLinearPercentage / kTierPointsProgressBarExtendBy;
}

- (void) updateForUserMiniEvent:(UserMiniEvent*)userMiniEvent
{
  MiniEventProto* miniEvent = userMiniEvent.miniEvent;
  
  const int pointsEarned = userMiniEvent.pointsEarned;
//const int maxPoints    = miniEvent.lvlEntered.tierThreeMinPts * kTierPointsProgressBarExtendBy;
  const int tier1Points  = miniEvent.lvlEntered.tierOneMinPts;
  const int tier2Points  = miniEvent.lvlEntered.tierTwoMinPts;
  const int tier3Points  = miniEvent.lvlEntered.tierThreeMinPts;
  
  self.eventInfoPointsEearned.text = [Globals commafyNumber:pointsEarned];
  self.pointCounterLabel.text = [Globals commafyNumber:pointsEarned];
  
  BOOL tier1Completed = (pointsEarned >= tier1Points);
  BOOL tier2Completed = (pointsEarned >= tier2Points);
  BOOL tier3Completed = (pointsEarned >= tier3Points);
  
  if (tier1Completed && !_tier1Completed) [self markTierAsComplete:1];
  if (tier2Completed && !_tier2Completed) [self markTierAsComplete:2];
  if (tier3Completed && !_tier3Completed) [self markTierAsComplete:3];
  
  if (tier3Completed && !_tier3Completed)
  {
    [self.pointsProgressBar animateToPercentage:1.f duration:kTierPointsProgressBarUpdateAnimationDuration completion:nil];
    [self.pointCounterView setHidden:YES];
  }
  else if (!tier3Completed)
  {
    /*
    [self.pointsProgressBar animateToPercentage:(float)pointsEarned / (float)maxPoints duration:kTierPointsProgressBarUpdateAnimationDuration completion:nil];
    [UIView animateWithDuration:kTierPointsProgressBarUpdateAnimationDuration animations:^{
      self.pointCounterView.centerX = self.pointsProgressBar.originX + self.pointsProgressBar.width * ((float)pointsEarned / (float)maxPoints);
    }];
     */
    
    const float nonLinearPercentage = [self nonLinearPercentageForPointsEarned:pointsEarned tier1Points:tier1Points tier2Points:tier2Points tier3Points:tier3Points];
    
    [self.pointsProgressBar animateToPercentage:nonLinearPercentage duration:kTierPointsProgressBarUpdateAnimationDuration completion:nil];
    [UIView animateWithDuration:kTierPointsProgressBarUpdateAnimationDuration animations:^{
      self.pointCounterView.centerX = self.pointsProgressBar.originX + self.pointsProgressBar.width * nonLinearPercentage;
    }];
  }
  
  _tier1Completed = tier1Completed;
  _tier2Completed = tier2Completed;
  _tier3Completed = tier3Completed;
  
  if (self.collectRewardView == nil)
  {
    int lowestTierWithUnredeemedReward = 0;
    if      (_tier1Completed && !_tier1Redeemed) lowestTierWithUnredeemedReward = 1;
    else if (_tier2Completed && !_tier2Redeemed) lowestTierWithUnredeemedReward = 2;
    else if (_tier3Completed && !_tier3Redeemed) lowestTierWithUnredeemedReward = 3;
    
    if (lowestTierWithUnredeemedReward > 0)
    {
      [self displayCollectRewardViewForTier:lowestTierWithUnredeemedReward prizeList:_tierPrizes[lowestTierWithUnredeemedReward - 1] animate:YES];
    }
  }
}

- (void) markTierAsComplete:(int)tier
{
  UILabel* tierIndicatorLabel = nil;
  MiniEventTierPrizeView* tierPrizeView = nil;
  
  switch (tier)
  {
    case 1: tierIndicatorLabel = self.tier1IndicatorLabel; tierPrizeView = self.tier1PrizeView; break;
    case 2: tierIndicatorLabel = self.tier2IndicatorLabel; tierPrizeView = self.tier2PrizeView; break;
    case 3: tierIndicatorLabel = self.tier3IndicatorLabel; tierPrizeView = self.tier3PrizeView; break;
    default: return;
  }
  
  tierIndicatorLabel.textColor = [UIColor colorWithHexString:@"469D00"];
  tierPrizeView.tierCheckmark.hidden = NO;

  UIImageView* tierCheckmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"requirementmet.png"]];
  tierCheckmark.frame = CGRectMake(tierIndicatorLabel.originX - 12, tierIndicatorLabel.centerY - 4, 10, 8);
  [self.eventInfoView insertSubview:tierCheckmark belowSubview:tierIndicatorLabel];
}

- (void) displayCollectRewardViewForTier:(int)tier prizeList:(NSArray*)prizeList animate:(BOOL)animate
{
  if (animate)
  {
    UIView* viewToAnimateIn, *viewToAnimateOut;
    if (tier == 0)
    {
      self.eventInfoView.hidden = NO;
      self.eventInfoView.originX = self.width;
      
      viewToAnimateIn  = self.eventInfoView;
      viewToAnimateOut = self.collectRewardView;
    }
    else
    {
      MiniEventCollectRewardView* collectRewardView = [[NSBundle mainBundle] loadNibNamed:@"MiniEventCollectRewardView" owner:self options:nil][0];
      {
        [collectRewardView setDelegate:self];
        [collectRewardView setOriginX:self.width];
        [collectRewardView updateForTier:tier prizeList:prizeList];
        [self insertSubview:collectRewardView aboveSubview:self.eventInfoView];
      }
      
      viewToAnimateIn  = collectRewardView;
      viewToAnimateOut = self.collectRewardView == nil ? self.eventInfoView : self.collectRewardView;
      if (self.collectRewardView == nil) self.pointCounterView.hidden = YES;
    }
    
    [UIView animateWithDuration:kCollectRewardViewSlideAnimationDuration animations:
     ^{
       viewToAnimateIn.originX  -= self.width;
       viewToAnimateOut.originX -= self.width;
     } completion:^(BOOL finished)
     {
       self.collectRewardView = [viewToAnimateIn isKindOfClass:[MiniEventCollectRewardView class]] ? (MiniEventCollectRewardView*)viewToAnimateIn : nil;
       if ([viewToAnimateOut isKindOfClass:[MiniEventCollectRewardView class]]) [viewToAnimateOut removeFromSuperview];
       [self miniEventViewWillAppear];
     }];
  }
  else
  {
    self.collectRewardView = [[NSBundle mainBundle] loadNibNamed:@"MiniEventCollectRewardView" owner:self options:nil][0];
    {
      [self.collectRewardView setDelegate:self];
      [self.collectRewardView updateForTier:tier prizeList:prizeList];
      [self insertSubview:self.collectRewardView aboveSubview:self.eventInfoView];
    }
    
    self.eventInfoView.hidden = YES;
    self.pointCounterView.hidden = YES;
  }
}

- (void) rewardCollectedForTier:(int)tier
{
  switch (tier)
  {
    case 1: _tier1Redeemed = YES; break;
    case 2: _tier2Redeemed = YES; break;
    case 3: _tier3Redeemed = YES; break;
    default: break;
  }
  
  int nextTierWithUnredeemedReward = 0;
  if (tier == 1 && _tier2Completed && !_tier2Redeemed) nextTierWithUnredeemedReward = 2;
  if (tier == 2 && _tier3Completed && !_tier3Redeemed) nextTierWithUnredeemedReward = 3;

  [self displayCollectRewardViewForTier:nextTierWithUnredeemedReward
                              prizeList:nextTierWithUnredeemedReward > 0 ? _tierPrizes[nextTierWithUnredeemedReward - 1] : nil
                                animate:YES];
}

- (void) updateTimeLeftForEvent:(UserMiniEvent*)userMiniEvent
{
  if ([userMiniEvent eventHasEnded])
  {
    // Event has ended
    self.eventInfoTimerBackground.hidden = YES;
    self.eventInfoTimeLeft.hidden = YES;
    self.eventInfoEventEnded.hidden = NO;
  }
  else
  {
    const NSTimeInterval timeLeft = [userMiniEvent secondsTillEventEndTime];
    self.eventInfoTimeLeft.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
  }
}

- (void) miniEventViewWillAppear
{
  if (self.collectRewardView == nil && !_tier3Completed) self.pointCounterView.hidden = NO;
}

- (void) miniEventViewWillDisappear
{
  self.pointCounterView.hidden = YES;
}

@end
