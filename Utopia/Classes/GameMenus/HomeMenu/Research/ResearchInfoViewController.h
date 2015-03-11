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

- (void) updateLabels;

@property (nonatomic, assign) IBOutlet UIView *cashButtonView;
@property (nonatomic, assign) IBOutlet UIView *oilButtonView;
@property (nonatomic, assign) IBOutlet UIView *finishButtonView;
@property (nonatomic, assign) IBOutlet UIView *helpButtonView;

@property (weak, nonatomic) IBOutlet NiceFontLabel12B *finishFreeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *finishSpeedupIcon;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *finishActivityIndicator;
@property (weak, nonatomic) IBOutlet GeneralButton *finishButton;

@property (nonatomic, assign) IBOutlet NiceFontLabel12 *cashButtonLabel;
@property (nonatomic, assign) IBOutlet NiceFontLabel12 *oilButtonLabel;

@property (nonatomic, assign) IBOutlet UIImageView *bottomBarIcon;
@property (nonatomic, assign) IBOutlet UIImageView *bottomBarImage;
@property (nonatomic, assign) IBOutlet NiceFontLabel12 *bottomBarTitle;
@property (nonatomic, assign) IBOutlet NiceFontLabel2 *bottomBarDescription;

@property (nonatomic, assign) IBOutlet UpgradeButton *cashButton;
@property (nonatomic, assign) IBOutlet UpgradeButton *oilButton;
@property (nonatomic, assign) IBOutlet UIImageView *cashIcon;
@property (nonatomic, assign) IBOutlet UIImageView *oilIcon;
@property (nonatomic, assign) IBOutlet NiceFontLabel12 *researchCashLabel;
@property (nonatomic, assign) IBOutlet NiceFontLabel12 *researchOilLabel;
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, assign) IBOutlet ResearchPrereqView *prereqViewA;
@property (nonatomic, assign) IBOutlet ResearchPrereqView *prereqViewB;
@property (nonatomic, assign) IBOutlet ResearchPrereqView *prereqViewC;

@property (nonatomic, assign) IBOutlet ShrinkOnlyImageView *researchImage;
@property (nonatomic, assign) IBOutlet NiceFontLabel9 *researchName;
@property (nonatomic, assign) IBOutlet NiceFontLabel8 *researchTimeLabel;

@property (nonatomic, assign) IBOutlet NiceFontLabel9 *percentIncreseLabel;
@property (nonatomic, assign) IBOutlet SplitImageProgressBar *topPercentBar;
@property (nonatomic, assign) IBOutlet SplitImageProgressBar *botPercentBar;

@property (nonatomic, assign) IBOutlet NiceFontLabel8T *timeLeftLabel;

@end

@interface ResearchInfoViewController : PopupSubViewController {
  UserResearch *_userResearch;
}

-(id)initWithResearch:(UserResearch *)userResearch;
- (void) updateLabels;
- (void) handlePerformResearchResponseProto:(FullEvent *)fe;

@property (nonatomic, assign) IBOutlet ResearchInfoView *view;

@end

