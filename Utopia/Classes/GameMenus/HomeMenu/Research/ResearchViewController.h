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

@interface ResearchViewController : PopupSubViewController <SpeedupItemsFillerDelegate>{
  UserResearch *_curResearch;
  BOOL _curResearchUp;
  BOOL _waitingForServer;
}
@property (nonatomic, retain) IBOutlet UIView *curReseaerchBar;
@property (nonatomic, retain) IBOutlet UILabel *curResearchTitle;
@property (nonatomic, retain) IBOutlet GeneralButton *helpButton;
@property (nonatomic, retain) IBOutlet GeneralButton *finishButton;
@property (nonatomic, retain) IBOutlet NiceFontLabel12B *finishFreeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *finishIcon;
@property (nonatomic, retain) IBOutlet NiceFontLabel8T *curTimeRemaining;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIView *selectFieldView;
@property (nonatomic, retain) IBOutlet UIImageView *researchIcon;

@property (nonatomic, retain) SpeedupItemsFiller *speedupItemsFiller;
@property (nonatomic, retain) ItemSelectViewController *itemSelectViewController;

- (IBAction)finishNowClicked:(id)sender;
- (IBAction)helpButtonClicked:(id)sender;

@end

@interface ResearchCategoryCell : UITableViewCell

- (void) updateForDomain:(ResearchDomain) domain;
@property (nonatomic, retain) IBOutlet UIImageView *categoryIcon;
@property (nonatomic, retain) IBOutlet UILabel *categoryTitle;
@property (nonatomic, retain) IBOutlet UIImageView *line;

@end