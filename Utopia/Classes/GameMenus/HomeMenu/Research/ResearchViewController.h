//
//  ResearchViewController.h
//  Utopia
//
//  Created by Kenneth Cox on 2/27/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupSubViewController.h"
#import "SpeedupItemsFiller.h"
#import "ResearchUtil.h"

@interface ResearchViewController : PopupSubViewController <SpeedupItemsFillerDelegate> {
  BOOL _waitingForServer;
}

@property (nonatomic, retain) IBOutlet UIView *curResearchBar;

@property (nonatomic, retain) IBOutlet UIImageView *curResearchBarBgdLeft;
@property (nonatomic, retain) IBOutlet UIImageView *curResearchBarBgdRight;
@property (nonatomic, retain) IBOutlet UIImageView *curResearchBarBgdMiddle;

@property (nonatomic, retain) IBOutlet UILabel *researchNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLeftLabel;
@property (nonatomic, retain) IBOutlet UIImageView *researchIcon;

@property (nonatomic, retain) IBOutlet UILabel *freeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *speedupIcon;
@property (nonatomic, retain) IBOutlet UIView *finishLabelsView;
@property (nonatomic, retain) IBOutlet UIView *helpButtonView;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, retain) IBOutlet UIView *selectFieldView;

@property (nonatomic, retain) SpeedupItemsFiller *speedupItemsFiller;
@property (nonatomic, retain) ItemSelectViewController *itemSelectViewController;

- (UserResearch *) curResearch;

- (IBAction) finishNowClicked:(id)sender;
- (IBAction) helpButtonClicked:(id)sender;

@end

@interface ResearchCategoryCell : UITableViewCell

- (void) updateForDomain:(ResearchDomain) domain;

@property (nonatomic, retain) IBOutlet UIImageView *categoryIcon;
@property (nonatomic, retain) IBOutlet UILabel *categoryTitle;

@end