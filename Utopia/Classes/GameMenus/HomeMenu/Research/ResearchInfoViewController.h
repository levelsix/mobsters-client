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


@interface ResearchPrereqView : UpgradePrereqView

@end

@interface ResearchInfoView : UIView

@property (nonatomic, assign) IBOutlet UIView *cashButtonView;
@property (nonatomic, assign) IBOutlet UIView *oilButtonView;
@property (nonatomic, assign) IBOutlet NiceFontLabel12 *cashButtonLabel;
@property (nonatomic, assign) IBOutlet NiceFontLabel12 *oilButtonLabel;

@property (nonatomic, assign) IBOutlet UIImageView *bottomBarIcon;
@property (nonatomic, assign) IBOutlet NiceFontLabel12 *bottomBarTitle;
@property (nonatomic, assign) IBOutlet NiceFontLabel2 *bottomBarDescription;

@property (nonatomic, assign) IBOutlet ResearchPrereqView *prereqViewA;
@property (nonatomic, assign) IBOutlet ResearchPrereqView *prereqViewB;
@property (nonatomic, assign) IBOutlet ResearchPrereqView *prereqViewC;

@property (nonatomic, assign) IBOutlet ShrinkOnlyImageView *researchImage;
@property (nonatomic, assign) IBOutlet NiceFontLabel9 *researchName;
@property (nonatomic, assign) IBOutlet NiceFontLabel8 *researchTimeLabel;

@property (nonatomic, assign) IBOutlet NiceFontLabel9 *percentIncreseLabel;
@property (nonatomic, assign) IBOutlet SplitImageProgressBar *topPercentBar;
@property (nonatomic, assign) IBOutlet SplitImageProgressBar *botPercentBar;

@end

@interface ResearchInfoViewController : PopupSubViewController

-(id)initWithResearch:(ResearchProto *)research;

@property (nonatomic, assign) IBOutlet ResearchInfoView *view;

@end

@interface ResearchProto (prereqObject)

- (ResearchProto *)successorResearch;
- (ResearchProto *)predecessorResearch;
- (ResearchProto *)maxLevelResearch;
- (ResearchProto *)minLevelResearch;

@end

