//
//  ResearchInfoViewController.h
//  Utopia
//
//  Created by Kenneth Cox on 3/2/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupSubViewController.h"
#import "ResearchDetailViewController.h"
#import "UpgradeViewController.h"

#import "FullEvent.h"
@interface ResearchPrereqView : UpgradePrereqView

@end

@interface ResearchInfoView : UIView

@property (nonatomic, assign) IBOutlet UIView *cashButtonView;
@property (nonatomic, assign) IBOutlet UIView *oilButtonView;
@property (nonatomic, assign) IBOutlet NiceFontLabel12 *cashButtonLabel;
@property (nonatomic, assign) IBOutlet NiceFontLabel12 *oilButtonLabel;

@property (nonatomic, assign) IBOutlet UIImageView *bottomBarIcon;
@property (nonatomic, assign) IBOutlet UIImageView *bottomBarImage;
@property (nonatomic, assign) IBOutlet NiceFontLabel12 *bottomBarTitle;
@property (nonatomic, assign) IBOutlet NiceFontLabel2 *bottomBarDescription;

@property (weak, nonatomic) IBOutlet UpgradeButton *cashButton;
@property (weak, nonatomic) IBOutlet UpgradeButton *oilButton;
@property (weak, nonatomic) IBOutlet UIImageView *cashIcon;
@property (weak, nonatomic) IBOutlet UIImageView *oilIcon;
@property (weak, nonatomic) IBOutlet NiceFontLabel12 *researchCashLabel;
@property (weak, nonatomic) IBOutlet NiceFontLabel12 *researchOilLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, assign) IBOutlet ResearchPrereqView *prereqViewA;
@property (nonatomic, assign) IBOutlet ResearchPrereqView *prereqViewB;
@property (nonatomic, assign) IBOutlet ResearchPrereqView *prereqViewC;

@property (nonatomic, assign) IBOutlet ShrinkOnlyImageView *researchImage;
@property (nonatomic, assign) IBOutlet NiceFontLabel9 *researchName;
@property (nonatomic, assign) IBOutlet NiceFontLabel8 *researchTimeLabel;

@property (nonatomic, assign) IBOutlet NiceFontLabel9 *percentIncreseLabel;
@property (nonatomic, assign) IBOutlet SplitImageProgressBar *topPercentBar;
@property (nonatomic, assign) IBOutlet SplitImageProgressBar *botPercentBar;

@property (weak, nonatomic) IBOutlet GemsButton *finishNowButton;
@property (weak, nonatomic) IBOutlet NiceFontLabel12B *gemAmount;
@property (weak, nonatomic) IBOutlet NiceFontLabel12B *finishLabel;
@property (weak, nonatomic) IBOutlet NiceFontLabel12B *freeLabel;

@property (weak, nonatomic) IBOutlet UIView *inactiveResearchBar;
@property (weak, nonatomic) IBOutlet UIView *activeResearchBar;

@end

@interface ResearchInfoViewController : PopupSubViewController {
  int _researchId;
}

-(id)initWithResearch:(ResearchProto *)research;

- (void) handlePerformResearchRequestProto:(FullEvent *)fe;

@property (nonatomic, assign) IBOutlet ResearchInfoView *view;

@end

