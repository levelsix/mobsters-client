//
//  MiniEventDetailsView.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 3/24/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MiniEventManager.h"
#import "MiniEventCollectRewardView.h"

@class THLabel;
@class ProgressBar;
@class MiniEventTierPrizeView;

@interface MiniEventDetailsView : UIView <MiniEventInfoViewProtocol, MiniEventCollectRewardCallbackDelegate>
{
  NSMutableArray* _tierPrizes;
  
  BOOL _tier1Completed;
  BOOL _tier2Completed;
  BOOL _tier3Completed;
  
  BOOL _tier1Redeemed;
  BOOL _tier2Redeemed;
  BOOL _tier3Redeemed;
}

@property (nonatomic, retain) IBOutlet UIView* eventInfoView;
@property (nonatomic, retain) IBOutlet UIImageView* eventInfoImage;
@property (nonatomic, retain) IBOutlet UILabel* eventInfoName;
@property (nonatomic, retain) IBOutlet UILabel* eventInfoDesc;
@property (nonatomic, retain) IBOutlet UILabel* eventInfoTimeLeft;
@property (nonatomic, retain) IBOutlet UILabel* eventInfoPointsEearned;
@property (nonatomic, retain) IBOutlet ProgressBar* pointsProgressBar;
@property (nonatomic, retain) IBOutlet UIImageView* tier1IndicatorArrow;
@property (nonatomic, retain) IBOutlet UILabel*     tier1IndicatorLabel;
@property (nonatomic, retain) IBOutlet UIImageView* tier2IndicatorArrow;
@property (nonatomic, retain) IBOutlet UILabel*     tier2IndicatorLabel;
@property (nonatomic, retain) IBOutlet UIImageView* tier3IndicatorArrow;
@property (nonatomic, retain) IBOutlet UILabel*     tier3IndicatorLabel;
@property (nonatomic, retain) IBOutlet UIView*  pointCounterView;
@property (nonatomic, retain) IBOutlet UILabel* pointCounterLabel;
@property (nonatomic, retain) IBOutlet MiniEventTierPrizeView* tier1PrizeView;
@property (nonatomic, retain) IBOutlet MiniEventTierPrizeView* tier2PrizeView;
@property (nonatomic, retain) IBOutlet MiniEventTierPrizeView* tier3PrizeView;

@property (nonatomic, retain) MiniEventCollectRewardView* collectRewardView;

@end
