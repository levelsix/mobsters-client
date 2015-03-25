//
//  MiniEventDetailsView.h
//  Utopia
//
//  Created by Behrouz Namakshenas on 3/24/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MiniEventManager.h"

@class THLabel;
@class SplitImageProgressBar;

@interface MiniEventDetailsView : UIView <MiniEventInfoViewProtocol>

@property (nonatomic, retain) IBOutlet UIImageView* eventInfoBackground;          // Static
@property (nonatomic, retain) IBOutlet UIImageView* eventInfoImage;
@property (nonatomic, retain) IBOutlet THLabel* eventInfoName;
@property (nonatomic, retain) IBOutlet THLabel* eventInfoDesc;
@property (nonatomic, retain) IBOutlet THLabel* eventInfoEndsIn;                  // Static
@property (nonatomic, retain) IBOutlet THLabel* eventInfoTimeLeft;
@property (nonatomic, retain) IBOutlet THLabel* eventInfoMyPoints;                // Static
@property (nonatomic, retain) IBOutlet THLabel* eventInfoPointsEearned;
@property (nonatomic, retain) IBOutlet UIImageView* progressBarBackground;        // Static
@property (nonatomic, retain) IBOutlet SplitImageProgressBar* pointsProgressBar;
@property (nonatomic, retain) IBOutlet UIImageView* tier1IndicatorArrow;
@property (nonatomic, retain) IBOutlet UILabel*     tier1IndicatorLabel;
@property (nonatomic, retain) IBOutlet UIImageView* tier2IndicatorArrow;
@property (nonatomic, retain) IBOutlet UILabel*     tier2IndicatorLabel;
@property (nonatomic, retain) IBOutlet UIImageView* tier3IndicatorArrow;
@property (nonatomic, retain) IBOutlet UILabel*     tier3IndicatorLabel;
@property (nonatomic, retain) IBOutlet UIView*  pointCounterView;
@property (nonatomic, retain) IBOutlet UILabel* pointCounterLabel;

@end
