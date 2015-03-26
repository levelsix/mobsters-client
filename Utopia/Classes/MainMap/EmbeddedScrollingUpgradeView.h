//
//  EmbeddedScrollingUpgradeView.h
//  Utopia
//
//  Created by Kenneth Cox on 3/24/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "NibUtils.h"
#import "UpgradeViewController.h"

@interface ResearchPrereqView : UpgradePrereqView

@end

@interface EmbeddedPrereqView : UIView
@property (nonatomic, retain) IBOutlet ResearchPrereqView *prereqView;
@end

@interface DetailsProgressBarView : UIView
@property (nonatomic, retain) IBOutlet NiceFontLabel9 *detailName;
@property (nonatomic, retain) IBOutlet NiceFontLabel9 *increaseDescription;
@property (nonatomic, retain) IBOutlet NiceFontButton9 *detailButton;

@property (nonatomic, retain) IBOutlet SplitImageProgressBar *frontBar;
@property (nonatomic, retain) IBOutlet SplitImageProgressBar *backBar;

@end

@interface UpgradeTitleBarView : UIView

@property (nonatomic, retain) IBOutlet UILabel *title;

@end

@interface StrengthDetailsView : UIView
@property (nonatomic, retain) IBOutlet UILabel *strengthLabel;

@end

@interface EmbeddedScrollingUpgradeView : EmbeddedNibView {
  float _curY;
}

@property (nonatomic, retain) IBOutlet UIView *view;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@end
