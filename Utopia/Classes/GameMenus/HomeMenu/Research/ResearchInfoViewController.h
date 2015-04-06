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
#import "SpeedupItemsFiller.h"

#import "FullEvent.h"
@interface ResearchPrereqView : UpgradePrereqView

@end

@interface ResearchInfoView : UIView


@property (nonatomic, retain) IBOutlet UILabel *freeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *speedupIcon;
@property (nonatomic, retain) IBOutlet UIView *finishLabelsView;

@property (nonatomic, assign) IBOutlet UIView *cashButtonView;
@property (nonatomic, assign) IBOutlet UIView *oilButtonView;
@property (nonatomic, assign) IBOutlet UIView *finishButtonView;
@property (nonatomic, retain) IBOutlet UIView *helpButtonView;

@property (nonatomic, assign) IBOutlet UILabel *cashButtonLabel;
@property (nonatomic, assign) IBOutlet UILabel *oilButtonLabel;

@property (nonatomic, assign) IBOutlet UIImageView *bottomBarIcon;
@property (nonatomic, assign) IBOutlet UIImageView *bottomBarBgd;
@property (nonatomic, assign) IBOutlet UILabel *bottomNameLabel;
@property (nonatomic, assign) IBOutlet UILabel *bottomDescLabel;

@property (nonatomic, assign) IBOutlet UIButton *cashButton;
@property (nonatomic, assign) IBOutlet UIButton *oilButton;
@property (nonatomic, assign) IBOutlet UIImageView *cashIcon;
@property (nonatomic, assign) IBOutlet UIImageView *oilIcon;
@property (nonatomic, assign) IBOutlet UILabel *researchCashLabel;
@property (nonatomic, assign) IBOutlet UILabel *researchOilLabel;
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, assign) IBOutlet ResearchPrereqView *prereqViewA;
@property (nonatomic, assign) IBOutlet ResearchPrereqView *prereqViewB;
@property (nonatomic, assign) IBOutlet ResearchPrereqView *prereqViewC;

@property (nonatomic, assign) IBOutlet ShrinkOnlyImageView *researchIcon;
@property (nonatomic, assign) IBOutlet UILabel *researchNameLabel;
@property (nonatomic, assign) IBOutlet UILabel *researchTimeLabel;

@property (nonatomic, assign) IBOutlet UILabel *researchTypeLabel;
@property (nonatomic, assign) IBOutlet UILabel *improvementLabel;
@property (nonatomic, assign) IBOutlet UIView *detailView;
@property (nonatomic, assign) IBOutlet SplitImageProgressBar *topPercentBar;
@property (nonatomic, assign) IBOutlet SplitImageProgressBar *botPercentBar;

@property (nonatomic, assign) IBOutlet UILabel *timeLeftLabel;

@end

@interface ResearchInfoViewController : PopupSubViewController <SpeedupItemsFillerDelegate, ResourceItemsFillerDelegate> {
  UserResearch *_userResearch;
  BOOL _waitingForServer;
}

@property (nonatomic, retain) SpeedupItemsFiller *speedupItemsFiller;
@property (nonatomic, retain) ItemSelectViewController *itemSelectViewController;
@property (nonatomic, retain) ResourceItemsFiller *resourceItemsFiller;

@property (nonatomic, assign) IBOutlet ResearchInfoView *view;

- (id) initWithResearch:(UserResearch *)userResearch;

@end
